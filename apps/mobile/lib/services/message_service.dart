// ignore_for_file: cascade_invocations
import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:campus_mesh/appwrite_config.dart';
import 'package:campus_mesh/models/message_model.dart';
import 'package:campus_mesh/services/appwrite_service.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/services/connectivity_service.dart';
import 'package:campus_mesh/services/local_message_database.dart';
import 'package:campus_mesh/utils/input_validator.dart';
import 'package:flutter/foundation.dart';

class MessageService {
  final _appwrite = AppwriteService();
  final _authService = AuthService();
  final _localDb = LocalMessageDatabase();
  final _connectivityService = ConnectivityService();

  StreamController<List<MessageModel>>? _messagesController;
  StreamController<int>? _unreadCountController;

  // Get current user ID
  String? get _currentUserId => _authService.currentUserId;

  // Get messages between current user and another user
  Stream<List<MessageModel>> getMessages(String otherUserId) {
    final currentUserId = _currentUserId;
    if (currentUserId == null ||
        !InputValidator.isValidDocumentId(otherUserId)) {
      return Stream.value([]);
    }

    _messagesController ??= StreamController<List<MessageModel>>.broadcast(
      onListen: () => _startMessagesPolling(otherUserId),
      onCancel: _stopMessagesPolling,
    );

    return _messagesController!.stream;
  }

  Timer? _messagesPollingTimer;

  void _startMessagesPolling(String otherUserId) {
    _fetchMessages(otherUserId);
    _messagesPollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _fetchMessages(otherUserId),
    );
  }

  void _stopMessagesPolling() {
    _messagesPollingTimer?.cancel();
    _messagesPollingTimer = null;
  }

  Future<void> _fetchMessages(String otherUserId) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return;

    try {
      final allMessages = <MessageModel>[];

      // Validate user IDs to prevent crashes
      if (!InputValidator.isValidDocumentId(otherUserId) &&
          !InputValidator.isValidUuid(otherUserId)) {
        debugPrint('Invalid otherUserId format: $otherUserId');
        _messagesController?.add([]);
        return;
      }

      // Fetch online messages if connected
      if (_connectivityService.isOnline) {
        try {
          // Fetch messages sent by current user to other user
          final sentDocs = await _appwrite.databases.listDocuments(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.messagesCollectionId,
            queries: [
              Query.equal('sender_id', currentUserId),
              Query.equal('recipient_id', otherUserId),
              Query.limit(100),
            ],
          );

          // Fetch messages received by current user from other user
          final receivedDocs = await _appwrite.databases.listDocuments(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.messagesCollectionId,
            queries: [
              Query.equal('sender_id', otherUserId),
              Query.equal('recipient_id', currentUserId),
              Query.limit(100),
            ],
          );

          // Add online messages
          allMessages.addAll(
            sentDocs.documents.map((doc) => MessageModel.fromJson(doc.data)),
          );
          allMessages.addAll(
            receivedDocs.documents.map(
              (doc) => MessageModel.fromJson(doc.data),
            ),
          );
        } catch (e) {
          // Continue to show local messages even if online fetch fails
          debugPrint('Failed to fetch online messages: $e');
        }
      }

      // Fetch local messages (pending sync)
      try {
        final localMessages = await _localDb.getConversationMessages(
          currentUserId,
          otherUserId,
        );
        for (final localMsg in localMessages) {
          // Convert to MessageModel with sync status
          allMessages.add(
            MessageModel(
              id: localMsg['id'] as String,
              senderId: localMsg['sender_id'] as String,
              recipientId: localMsg['recipient_id'] as String,
              content: localMsg['content'] as String,
              type: MessageType.values.firstWhere(
                (t) => t.name == localMsg['type'],
                orElse: () => MessageType.text,
              ),
              read: false,
              createdAt: DateTime.parse(localMsg['created_at'] as String),
              syncStatus: _parseSyncStatus(localMsg['sync_status'] as String?),
              approvalStatus: localMsg['approval_status'] as String?,
            ),
          );
        }
      } catch (e) {
        debugPrint('Failed to fetch local messages: $e');
      }

      // Sort by created_at with error handling
      try {
        allMessages.sort((a, b) {
          final aTime = a.createdAt;
          final bTime = b.createdAt;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return aTime.compareTo(bTime);
        });
      } catch (sortError) {
        debugPrint('Error sorting messages: $sortError');
        // Continue with unsorted messages
      }

      _messagesController?.add(allMessages);
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      // Don't propagate error, just log it and return empty list
      _messagesController?.add([]);
    }
  }

  // Get recent conversations
  Stream<List<MessageModel>> getRecentConversations() async* {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      yield [];
      return;
    }

    while (true) {
      try {
        // Fetch messages sent by current user
        final sentDocs = await _appwrite.databases.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.messagesCollectionId,
          queries: [
            Query.equal('sender_id', currentUserId),
            Query.orderDesc('created_at'),
            Query.limit(50),
          ],
        );

        // Fetch messages received by current user
        final receivedDocs = await _appwrite.databases.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.messagesCollectionId,
          queries: [
            Query.equal('recipient_id', currentUserId),
            Query.orderDesc('created_at'),
            Query.limit(50),
          ],
        );

        // Combine and sort
        final allMessages = [
          ...sentDocs.documents.map((doc) => MessageModel.fromJson(doc.data)),
          ...receivedDocs.documents.map(
            (doc) => MessageModel.fromJson(doc.data),
          ),
        ];

        try {
          allMessages.sort((a, b) {
            final aTime = a.createdAt;
            final bTime = b.createdAt;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });
        } catch (sortError) {
          debugPrint('Error sorting recent conversations: $sortError');
          // Continue with unsorted messages
        }

        final messages = allMessages.take(50).toList();

        yield messages;
      } catch (e) {
        debugPrint('Error fetching recent conversations: $e');
        yield [];
      }

      await Future.delayed(const Duration(seconds: 5));
    }
  }

  // Send message (with offline support)
  Future<String> sendMessage({
    required String recipientId,
    required String content,
    MessageType type = MessageType.text,
    bool isGroupMessage = false,
    String? groupId,
  }) async {
    try {
      final currentUserId = _currentUserId;
      if (currentUserId == null) {
        throw Exception('User must be authenticated to send messages');
      }

      // Validate recipient ID format - accept both UUID and Appwrite document IDs
      // Allow system user IDs and common patterns
      if (recipientId.isEmpty || recipientId.length > 255) {
        throw Exception('Invalid recipient: Recipient ID is empty or too long');
      }

      // Basic validation - just check it's not obviously malformed
      if (recipientId.contains(RegExp(r'''[<>"'\\/]'''))) {
        throw Exception(
          'Invalid recipient: Recipient ID contains invalid characters',
        );
      }

      // Sanitize message content
      final sanitizedContent = InputValidator.sanitizeMessage(content);
      if (sanitizedContent == null || sanitizedContent.isEmpty) {
        throw Exception('Message content is required');
      }

      if (sanitizedContent.length > InputValidator.maxMessageLength) {
        throw Exception(
          'Message is too long '
          '(max ${InputValidator.maxMessageLength} characters)',
        );
      }

      final messageId = ID.unique();
      final now = DateTime.now().toIso8601String();

      // Check if online
      if (!_connectivityService.isOnline) {
        // Save locally when offline
        await _localDb.saveMessage({
          'id': messageId,
          'sender_id': currentUserId,
          'recipient_id': recipientId,
          'content': sanitizedContent,
          'type': type.name,
          'is_group_message': isGroupMessage ? 1 : 0,
          'group_id': groupId,
          'created_at': now,
          'sync_status': 'pending',
          'approval_status': isGroupMessage ? 'pending' : null,
          'retry_count': 0,
        });

        return messageId;
      }

      // Send to server when online
      final document = await _appwrite.databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        documentId: messageId,
        data: {
          'sender_id': currentUserId,
          'recipient_id': recipientId,
          'content': sanitizedContent,
          'type': type.name,
          'read': false,
          'created_at': now,
        },
        permissions: [
          Permission.read(Role.user(currentUserId)),
          Permission.read(Role.user(recipientId)),
          Permission.update(Role.user(currentUserId)),
          Permission.update(Role.user(recipientId)),
          Permission.delete(Role.user(currentUserId)),
        ],
      );

      return document.$id;
    } on AppwriteException catch (e) {
      // If network error (code 0) or timeout, save locally for later sync
      // Common network-related error codes:
      // 0 (network error), 408 (timeout), 503 (service unavailable)
      if (e.code == 0 || e.code == 408 || e.code == 503) {
        final messageId = ID.unique();
        final currentUserId = _currentUserId;
        if (currentUserId != null) {
          await _localDb.saveMessage({
            'id': messageId,
            'sender_id': currentUserId,
            'recipient_id': recipientId,
            'content': InputValidator.sanitizeMessage(content) ?? content,
            'type': type.name,
            'is_group_message': isGroupMessage ? 1 : 0,
            'group_id': groupId,
            'created_at': DateTime.now().toIso8601String(),
            'sync_status': 'pending',
            'approval_status': isGroupMessage ? 'pending' : null,
            'retry_count': 0,
            'last_error': e.message,
          });
          return messageId;
        }
      }
      throw Exception('Failed to send message: ${e.message}');
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      final currentUserId = _currentUserId;
      if (currentUserId == null) {
        throw Exception('User must be authenticated to mark messages as read');
      }

      await _appwrite.databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        documentId: messageId,
        data: {'read': true, 'read_at': DateTime.now().toIso8601String()},
      );
    } on AppwriteException catch (e) {
      throw Exception('Failed to mark message as read: ${e.message}');
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  // Get unread message count
  Stream<int> getUnreadCount() {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      return Stream.value(0);
    }

    _unreadCountController ??= StreamController<int>.broadcast(
      onListen: _startUnreadCountPolling,
      onCancel: _stopUnreadCountPolling,
    );

    return _unreadCountController!.stream;
  }

  Timer? _unreadCountPollingTimer;

  void _startUnreadCountPolling() {
    _fetchUnreadCount();
    _unreadCountPollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchUnreadCount(),
    );
  }

  void _stopUnreadCountPolling() {
    _unreadCountPollingTimer?.cancel();
    _unreadCountPollingTimer = null;
  }

  Future<void> _fetchUnreadCount() async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      _unreadCountController?.add(0);
      return;
    }

    try {
      final docs = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        queries: [
          Query.equal('recipient_id', currentUserId),
          Query.equal('read', false),
        ],
      );

      _unreadCountController?.add(docs.total);
    } catch (e) {
      _unreadCountController?.add(0);
    }
  }

  // Parse sync status
  MessageSyncStatus? _parseSyncStatus(String? statusStr) {
    switch (statusStr?.toLowerCase()) {
      case 'pending':
        return MessageSyncStatus.pending;
      case 'failed':
      case 'permanently_failed':
        return MessageSyncStatus.failed;
      case 'pending_approval':
        return MessageSyncStatus.pendingApproval;
      case 'synced':
        return MessageSyncStatus.synced;
      default:
        return null;
    }
  }

  /// Get messages for a group chat
  Stream<List<MessageModel>> getGroupMessages(String groupId) {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return (() async* {
      // Yield initial messages
      yield await _fetchGroupMessagesSync(groupId);

      // Then yield updates periodically
      yield* Stream.periodic(const Duration(seconds: 3), (_) {
        return _fetchGroupMessagesSync(groupId);
      }).asyncMap((future) => future);
    }).call();
  }

  /// Fetch group messages (synchronous version for stream)
  Future<List<MessageModel>> _fetchGroupMessagesSync(String groupId) async {
    try {
      final allMessages = <MessageModel>[];

      // Fetch from online database if connected
      if (_connectivityService.isOnline) {
        try {
          final docs = await _appwrite.databases.listDocuments(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.messagesCollectionId,
            queries: [
              Query.equal('group_id', groupId),
              Query.orderDesc('created_at'),
              Query.limit(100),
            ],
          );

          allMessages.addAll(
            docs.documents.map((doc) => MessageModel.fromJson(doc.data)),
          );
        } catch (e) {
          debugPrint('Failed to fetch online group messages: $e');
        }
      }

      // Fetch from local database (pending sync)
      try {
        final localMessages = await _localDb.getGroupMessages(groupId);
        for (final localMsg in localMessages) {
          allMessages.add(
            MessageModel(
              id: localMsg['id'] as String,
              senderId: localMsg['sender_id'] as String,
              recipientId: localMsg['recipient_id'] as String,
              content: localMsg['content'] as String,
              type: MessageType.values.firstWhere(
                (t) => t.name == localMsg['type'],
                orElse: () => MessageType.text,
              ),
              read: false,
              createdAt: DateTime.parse(localMsg['created_at'] as String),
              syncStatus: _parseSyncStatus(localMsg['sync_status'] as String?),
              groupId: groupId,
              senderDisplayName: localMsg['sender_display_name'] as String?,
              isGroupMessage: true,
            ),
          );
        }
      } catch (e) {
        debugPrint('Failed to fetch local group messages: $e');
      }

      // Sort by created_at
      allMessages.sort((a, b) {
        final aTime = a.createdAt;
        final bTime = b.createdAt;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return aTime.compareTo(bTime);
      });

      return allMessages;
    } catch (e) {
      debugPrint('Error fetching group messages: $e');
      return [];
    }
  }

  /// Send a message to a group
  Future<void> sendGroupMessage({
    required String groupId,
    required String groupName,
    required String content,
  }) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      throw Exception('User must be authenticated');
    }

    final messageId = ID.unique();
    final now = DateTime.now().toIso8601String();

    // Get sender info (name and photo)
    var senderDisplayName = 'Unknown';
    String? senderPhotoUrl;
    try {
      final authService = AuthService();
      final userProfile = await authService.getUserProfile(currentUserId);
      senderDisplayName = userProfile?.displayName ?? 'Unknown';
      senderPhotoUrl = userProfile?.photoURL;
    } catch (e) {
      debugPrint('Failed to get sender info: $e');
    }

    final messageData = {
      'id': messageId,
      'sender_id': currentUserId,
      'recipient_id': groupId,
      'group_id': groupId,
      'group_name': groupName,
      'sender_display_name': senderDisplayName,
      'sender_photo_url': senderPhotoUrl,
      'content': content,
      'type': 'text',
      'created_at': now,
      'read': false,
    };

    // Check if offline
    if (!_connectivityService.isOnline) {
      // Save locally
      await _localDb.saveMessage({...messageData, 'sync_status': 'pending'});
      debugPrint('Group message saved locally: $messageId');
      return;
    }

    // Send to database
    try {
      await _appwrite.databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        documentId: messageId,
        data: messageData,
      );
      debugPrint('Group message sent: $messageId');
    } on AppwriteException catch (e) {
      // If network error, save locally
      if (e.code == 0 || e.code == 408 || e.code == 503) {
        await _localDb.saveMessage({...messageData, 'sync_status': 'pending'});
        debugPrint('Group message saved locally (fallback): $messageId');
      } else {
        rethrow;
      }
    }
  }

  /// Mark group messages as read
  Future<void> markGroupMessagesAsRead(String groupId) async {
    try {
      final currentUserId = _currentUserId;
      if (currentUserId == null) return;

      // Update all unread messages in the group where current user is recipient
      final docs = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        queries: [
          Query.equal('group_id', groupId),
          Query.equal('read', false),
          Query.limit(100), // Batch process
        ],
      );

      for (final doc in docs.documents) {
        try {
          await _appwrite.databases.updateDocument(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.messagesCollectionId,
            documentId: doc.$id,
            data: {'read': true, 'read_at': DateTime.now().toIso8601String()},
          );
        } catch (e) {
          debugPrint('Error marking message as read: $e');
        }
      }

      debugPrint('✅ Group messages marked as read: $groupId');
    } catch (e) {
      debugPrint('❌ Error marking group messages as read: $e');
    }
  }

  /// Search group messages
  Future<List<MessageModel>> searchGroupMessages({
    required String groupId,
    required String query,
    int limit = 50,
  }) async {
    try {
      final docs = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        queries: [Query.equal('group_id', groupId), Query.limit(limit)],
      );

      final messages = docs.documents
          .map((doc) => MessageModel.fromJson(doc.data))
          .where(
            (msg) => msg.content.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();

      return messages;
    } catch (e) {
      debugPrint('❌ Error searching group messages: $e');
      return [];
    }
  }

  /// Get group message by ID
  Future<MessageModel?> getGroupMessageById(String messageId) async {
    try {
      final doc = await _appwrite.databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        documentId: messageId,
      );

      return MessageModel.fromJson(doc.data);
    } catch (e) {
      debugPrint('❌ Error fetching group message: $e');
      return null;
    }
  }

  /// Update message reaction
  Future<void> addReaction({
    required String messageId,
    required String emoji,
  }) async {
    try {
      final currentUserId = _currentUserId;
      if (currentUserId == null) return;

      final message = await getGroupMessageById(messageId);
      if (message == null) return;

      final reactions =
          message.metadata?['reactions'] as Map<String, dynamic>? ?? {};
      final userIds = (reactions[emoji] as List?) ?? [];

      if (!userIds.contains(currentUserId)) {
        userIds.add(currentUserId);
        reactions[emoji] = userIds;

        await _appwrite.databases.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.messagesCollectionId,
          documentId: messageId,
          data: {
            'metadata': {'reactions': reactions},
          },
        );

        debugPrint('✅ Reaction added: $emoji');
      }
    } catch (e) {
      debugPrint('❌ Error adding reaction: $e');
    }
  }

  /// Delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      final currentUserId = _currentUserId;
      if (currentUserId == null) return;

      // Verify user is the sender
      final message = await getGroupMessageById(messageId);
      if (message != null && message.senderId != currentUserId) {
        throw Exception('Can only delete your own messages');
      }

      await _appwrite.databases.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        documentId: messageId,
      );

      debugPrint('✅ Message deleted: $messageId');
    } catch (e) {
      debugPrint('❌ Error deleting message: $e');
    }
  }

  // Clean up
  void dispose() {
    try {
      _stopMessagesPolling();
    } catch (e) {
      debugPrint('Error stopping messages polling: $e');
    }

    try {
      _stopUnreadCountPolling();
    } catch (e) {
      debugPrint('Error stopping unread count polling: $e');
    }

    try {
      _messagesController?.close();
    } catch (e) {
      debugPrint('Error closing messages controller: $e');
    }
    _messagesController = null;

    try {
      _unreadCountController?.close();
    } catch (e) {
      debugPrint('Error closing unread count controller: $e');
    }
    _unreadCountController = null;
  }
}
