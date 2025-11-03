import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:campus_mesh/services/local_message_database.dart';
import 'package:campus_mesh/services/connectivity_service.dart';
import 'package:appwrite/appwrite.dart';
import 'package:campus_mesh/services/appwrite_service.dart';
import 'package:campus_mesh/appwrite_config.dart';

/// Service to sync offline messages when connection is restored
class OfflineMessageSyncService {
  static final OfflineMessageSyncService _instance =
      OfflineMessageSyncService._internal();
  factory OfflineMessageSyncService() => _instance;
  OfflineMessageSyncService._internal();

  final _localDb = LocalMessageDatabase();
  final _connectivityService = ConnectivityService();
  final _appwrite = AppwriteService();

  bool _isSyncing = false;
  Timer? _syncTimer;

  static const int _maxRetries = 3;
  static const Duration _syncInterval = Duration(minutes: 5);

  /// Initialize the sync service
  Future<void> initialize() async {
    // Start periodic sync when online
    _syncTimer = Timer.periodic(_syncInterval, (_) => syncMessages());

    // Listen to connectivity changes
    _connectivityService.connectivityStream.listen((isOnline) {
      if (isOnline) {
        debugPrint('Connection restored, initiating message sync...');
        syncMessages();
      }
    });
  }

  /// Sync all pending messages
  Future<void> syncMessages() async {
    if (_isSyncing) {
      debugPrint('Sync already in progress, skipping...');
      return;
    }

    if (!_connectivityService.isOnline) {
      debugPrint('Cannot sync: offline');
      return;
    }

    _isSyncing = true;
    debugPrint('Starting message sync...');

    try {
      final pendingMessages = await _localDb.getPendingMessages();
      debugPrint('Found ${pendingMessages.length} pending messages to sync');

      int successCount = 0;
      int failureCount = 0;

      for (final message in pendingMessages) {
        try {
          await _syncMessage(message);
          successCount++;
        } catch (e) {
          debugPrint('Failed to sync message ${message['id']}: $e');
          failureCount++;

          // Increment retry count
          await _localDb.incrementRetryCount(message['id']);

          // Update error message
          await _localDb.updateMessageSyncStatus(
            message['id'],
            'failed',
            error: e.toString(),
          );

          // Check if exceeded max retries
          final retryCount = (message['retry_count'] as int?) ?? 0;
          if (retryCount >= _maxRetries) {
            debugPrint(
              'Message ${message['id']} exceeded max retries, '
              'marking as permanently failed',
            );
            await _localDb.updateMessageSyncStatus(
              message['id'],
              'permanently_failed',
            );
          }
        }
      }

      debugPrint(
        'Message sync complete: $successCount succeeded, $failureCount failed',
      );

      // Cleanup old synced messages
      await _cleanupOldMessages();
    } catch (e) {
      debugPrint('Error during message sync: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync a single message
  Future<void> _syncMessage(Map<String, dynamic> localMessage) async {
    final isGroupMessage = (localMessage['is_group_message'] as int) == 1;
    final messageId = localMessage['id'] as String;

    debugPrint('Syncing message: $messageId (group: $isGroupMessage)');

    if (isGroupMessage) {
      // Group messages need approval
      await _syncGroupMessage(localMessage);
    } else {
      // P2P messages can be synced directly
      await _syncP2PMessage(localMessage);
    }
  }

  /// Sync P2P message (no approval needed)
  Future<void> _syncP2PMessage(Map<String, dynamic> localMessage) async {
    final messageId = localMessage['id'] as String;

    try {
      // Send message directly to Appwrite (avoid circular dependency)
      await _appwrite.databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        documentId: ID.unique(),
        data: {
          'sender_id': localMessage['sender_id'],
          'recipient_id': localMessage['recipient_id'],
          'content': localMessage['content'],
          'type': localMessage['type'],
          'read': false,
          'created_at': localMessage['created_at'],
        },
      );

      // Mark as synced
      await _localDb.updateMessageSyncStatus(
        messageId,
        'synced',
        syncedAt: DateTime.now().toIso8601String(),
      );

      debugPrint('P2P message synced successfully: $messageId');
    } catch (e) {
      debugPrint('Failed to sync P2P message $messageId: $e');
      throw Exception('Failed to sync P2P message: $e');
    }
  }

  /// Sync group message (needs approval)
  Future<void> _syncGroupMessage(Map<String, dynamic> localMessage) async {
    final messageId = localMessage['id'] as String;
    final groupId = localMessage['group_id'] as String?;

    if (groupId == null) {
      throw Exception('Group message missing group_id');
    }

    try {
      // Upload message to pending collection (waiting for approval)
      final document = await _appwrite.databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesPendingCollectionId,
        documentId: ID.unique(),
        data: {
          'local_message_id': messageId,
          'sender_id': localMessage['sender_id'],
          'group_id': groupId,
          'content': localMessage['content'],
          'type': localMessage['type'],
          'created_at': localMessage['created_at'],
          'approval_status': 'pending',
          'submitted_at': DateTime.now().toIso8601String(),
        },
      );

      // Update local message status
      await _localDb.updateMessageSyncStatus(
        messageId,
        'pending_approval',
        syncedAt: DateTime.now().toIso8601String(),
      );

      await _localDb.updateMessageApprovalStatus(
        messageId,
        'pending',
      );

      debugPrint(
        'Group message uploaded for approval: $messageId -> ${document.$id}',
      );
    } catch (e) {
      debugPrint('Failed to sync group message $messageId: $e');
      throw Exception('Failed to sync group message: $e');
    }
  }

  /// Check and update approval status for pending group messages
  Future<void> checkApprovalStatus() async {
    try {
      final pendingApprovalMessages =
          await _localDb.database.then((db) => db.query(
                'local_messages',
                where: 'approval_status = ?',
                whereArgs: ['pending'],
              ));

      for (final message in pendingApprovalMessages) {
        try {
          // Query pending collection for approval status
          final messageId = message['id'] as String;
          final docs = await _appwrite.databases.listDocuments(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.messagesPendingCollectionId,
            queries: [
              Query.equal('local_message_id', messageId),
              Query.limit(1),
            ],
          );

          if (docs.documents.isNotEmpty) {
            final pendingDoc = docs.documents.first;
            final approvalStatus = pendingDoc.data['approval_status'] as String;

            if (approvalStatus == 'approved') {
              // Message was approved
              await _localDb.updateMessageApprovalStatus(
                messageId,
                'approved',
                approvedBy: pendingDoc.data['approved_by'] as String?,
                approvedAt: pendingDoc.data['approved_at'] as String?,
              );

              await _localDb.updateMessageSyncStatus(
                messageId,
                'synced',
              );

              debugPrint('Message $messageId was approved');
            } else if (approvalStatus == 'rejected') {
              // Message was rejected
              await _localDb.updateMessageApprovalStatus(
                messageId,
                'rejected',
                approvedBy: pendingDoc.data['approved_by'] as String?,
              );

              await _localDb.updateMessageSyncStatus(
                messageId,
                'rejected',
              );

              debugPrint('Message $messageId was rejected');
            }
          }
        } catch (e) {
          debugPrint('Error checking approval status for message: $e');
        }
      }
    } catch (e) {
      debugPrint('Error checking approval statuses: $e');
    }
  }

  /// Cleanup old synced messages
  Future<void> _cleanupOldMessages() async {
    try {
      final deletedCount = await _localDb.cleanupSyncedMessages(daysToKeep: 7);
      if (deletedCount > 0) {
        debugPrint('Cleaned up $deletedCount old synced messages');
      }
    } catch (e) {
      debugPrint('Error cleaning up old messages: $e');
    }
  }

  /// Get sync statistics
  Future<Map<String, int>> getSyncStatistics() async {
    return await _localDb.getSyncStatistics();
  }

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }
}
