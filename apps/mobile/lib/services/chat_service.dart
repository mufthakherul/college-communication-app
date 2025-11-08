import 'dart:async';
import 'dart:math';

import 'package:appwrite/appwrite.dart';
import 'package:campus_mesh/appwrite_config.dart';
import 'package:campus_mesh/services/appwrite_service.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/services/connectivity_service.dart';
import 'package:campus_mesh/services/local_chat_database.dart';
import 'package:flutter/foundation.dart';

/// Service for managing chats and conversations
class ChatService {
  final _appwrite = AppwriteService();
  final _authService = AuthService();
  final _localDb = LocalChatDatabase();
  final _connectivityService = ConnectivityService();

  /// Generate unique invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(
      8,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Create P2P chat (works offline)
  Future<String> createP2PChat(String otherUserId) async {
    final currentUserId = _authService.currentUserId;
    if (currentUserId == null) {
      throw Exception('User must be authenticated');
    }

    final chatId = ID.unique();
    final now = DateTime.now().toIso8601String();
    final participantIds = [currentUserId, otherUserId]..sort();

    // Check if offline
    if (!_connectivityService.isOnline) {
      // Save locally
      await _localDb.saveChat({
        'id': chatId,
        'name': null,
        'type': 'p2p',
        'participant_ids': participantIds.join(','),
        'creator_id': currentUserId,
        'created_at': now,
        'sync_status': 'pending',
        'is_restricted': 0,
      });

      debugPrint('P2P chat created offline: $chatId');
      return chatId;
    }

    // Create online
    try {
      final document = await _appwrite.databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.studyGroupsCollectionId,
        documentId: chatId,
        data: {
          'name': null,
          'type': 'p2p',
          'participant_ids': participantIds,
          'creator_id': currentUserId,
          'created_at': now,
          'is_active': true,
        },
      );

      debugPrint('P2P chat created online: ${document.$id}');
      return document.$id;
    } on AppwriteException catch (e) {
      // If network error, save locally
      if (e.code == 0 || e.code == 408 || e.code == 503) {
        await _localDb.saveChat({
          'id': chatId,
          'name': null,
          'type': 'p2p',
          'participant_ids': participantIds.join(','),
          'creator_id': currentUserId,
          'created_at': now,
          'sync_status': 'pending',
          'is_restricted': 0,
        });

        debugPrint('P2P chat created offline (fallback): $chatId');
        return chatId;
      }
      rethrow;
    }
  }

  /// Create group chat (works offline)
  Future<String> createGroupChat({
    required String name,
    required List<String> participantIds,
  }) async {
    final currentUserId = _authService.currentUserId;
    if (currentUserId == null) {
      throw Exception('User must be authenticated');
    }

    if (!participantIds.contains(currentUserId)) {
      participantIds.add(currentUserId);
    }

    final chatId = ID.unique();
    final now = DateTime.now().toIso8601String();
    final inviteCode = _generateInviteCode();

    // Check if offline
    if (!_connectivityService.isOnline) {
      // Save locally
      await _localDb.saveChat({
        'id': chatId,
        'name': name,
        'type': 'group',
        'participant_ids': participantIds.join(','),
        'creator_id': currentUserId,
        'created_at': now,
        'sync_status': 'pending',
        'is_restricted': 0,
        'invite_code': inviteCode,
      });

      debugPrint('Group chat created offline: $chatId');
      return chatId;
    }

    // Create online
    try {
      final document = await _appwrite.databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.studyGroupsCollectionId,
        documentId: chatId,
        data: {
          'name': name,
          'type': 'group',
          'participant_ids': participantIds,
          'creator_id': currentUserId,
          'created_at': now,
          'is_active': true,
          'invite_code': inviteCode,
        },
      );

      debugPrint('Group chat created online: ${document.$id}');
      return document.$id;
    } on AppwriteException catch (e) {
      // If network error, save locally
      if (e.code == 0 || e.code == 408 || e.code == 503) {
        await _localDb.saveChat({
          'id': chatId,
          'name': name,
          'type': 'group',
          'participant_ids': participantIds.join(','),
          'creator_id': currentUserId,
          'created_at': now,
          'sync_status': 'pending',
          'is_restricted': 0,
          'invite_code': inviteCode,
        });

        debugPrint('Group chat created offline (fallback): $chatId');
        return chatId;
      }
      rethrow;
    }
  }

  /// Join group chat by invite code (works offline)
  Future<void> joinGroupByInviteCode(String inviteCode) async {
    final currentUserId = _authService.currentUserId;
    if (currentUserId == null) {
      throw Exception('User must be authenticated');
    }

    // Check local database first
    final localChat = await _localDb.getChatByInviteCode(inviteCode);
    if (localChat != null) {
      // Add user to local chat
      final participants = (localChat['participant_ids'] as String).split(',');
      if (!participants.contains(currentUserId)) {
        participants.add(currentUserId);
        await _localDb.saveChat({
          ...localChat,
          'participant_ids': participants.join(','),
        });
      }
      debugPrint('Joined local chat: ${localChat['id']}');
      return;
    }

    // Try online
    if (_connectivityService.isOnline) {
      try {
        final docs = await _appwrite.databases.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.studyGroupsCollectionId,
          queries: [Query.equal('invite_code', inviteCode), Query.limit(1)],
        );

        if (docs.documents.isEmpty) {
          throw Exception('Invalid invite code');
        }

        final chat = docs.documents.first;
        final participantIds = List<String>.from(
          chat.data['participant_ids'] ?? [],
        );

        if (!participantIds.contains(currentUserId)) {
          participantIds.add(currentUserId);
          await _appwrite.databases.updateDocument(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.studyGroupsCollectionId,
            documentId: chat.$id,
            data: {'participant_ids': participantIds},
          );
        }

        debugPrint('Joined online chat: ${chat.$id}');
      } catch (e) {
        throw Exception('Failed to join chat: $e');
      }
    } else {
      throw Exception('Cannot join chat: offline and code not found locally');
    }
  }

  /// Get chat invite URL
  String getChatInviteUrl(String inviteCode) {
    // This can be a deep link or web URL
    return 'https://rpi-communication.app/join/$inviteCode';
  }

  /// Restrict/unrestrict chat (admin/teacher only)
  Future<void> updateChatRestriction({
    required String chatId,
    required bool isRestricted,
    String? reason,
  }) async {
    final currentUserId = _authService.currentUserId;
    if (currentUserId == null) {
      throw Exception('User must be authenticated');
    }

    final now = DateTime.now().toIso8601String();

    // Update local database
    await _localDb.updateChatRestriction(
      chatId,
      isRestricted: isRestricted,
      restrictedBy: currentUserId,
      restrictedAt: now,
      reason: reason,
    );

    // Update online if connected
    if (_connectivityService.isOnline) {
      try {
        await _appwrite.databases.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.studyGroupsCollectionId,
          documentId: chatId,
          data: {
            'is_restricted': isRestricted,
            'restricted_by': currentUserId,
            'restricted_at': now,
            'restriction_reason': reason,
          },
        );
        debugPrint('Chat restriction updated online: $chatId');
      } catch (e) {
        debugPrint('Failed to update restriction online: $e');
        // Local update already done
      }
    }
  }

  /// Get chat history (for admins/teachers)
  Future<List<Map<String, dynamic>>> getChatHistory(String chatId) async {
    // This would fetch all messages for the chat
    // Implementation depends on message storage structure
    debugPrint('Fetching chat history for: $chatId');
    // TODO(copilot): Implement based on message service structure
    return [];
  }

  /// Get group participants
  Future<List<Map<String, dynamic>>> getGroupParticipants(
    String groupId,
  ) async {
    try {
      final chat = await _appwrite.databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.studyGroupsCollectionId,
        documentId: groupId,
      );

      final participantIds = List<String>.from(
        chat.data['participant_ids'] as List? ?? [],
      );

      if (participantIds.isEmpty) {
        return [];
      }

      // Fetch participant details
      final participants = <Map<String, dynamic>>[];
      for (final participantId in participantIds) {
        try {
          final userDoc = await _appwrite.databases.getDocument(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.usersCollectionId,
            documentId: participantId,
          );

          participants.add({
            'id': participantId,
            'name': userDoc.data['display_name'] ?? 'Unknown',
            'photo': userDoc.data['photo_url'] as String?,
            'email': userDoc.data['email'] as String?,
          });
        } catch (e) {
          debugPrint('Failed to fetch participant info for $participantId: $e');
          // Add placeholder
          participants.add({
            'id': participantId,
            'name': 'Unknown',
            'photo': null,
            'email': null,
          });
        }
      }

      return participants;
    } catch (e) {
      debugPrint('Failed to get group participants: $e');
      rethrow;
    }
  }

  /// Leave a group
  Future<void> leaveGroup(String groupId) async {
    final currentUserId = _authService.currentUserId;
    if (currentUserId == null) {
      throw Exception('User must be authenticated');
    }

    try {
      // Get current group
      final chat = await _appwrite.databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.studyGroupsCollectionId,
        documentId: groupId,
      );

      // Remove current user from participants
      final participantIds = List<String>.from(
        chat.data['participant_ids'] as List? ?? [],
      );
      participantIds.removeWhere((id) => id == currentUserId);

      // Update group
      if (_connectivityService.isOnline) {
        await _appwrite.databases.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.studyGroupsCollectionId,
          documentId: groupId,
          data: {'participant_ids': participantIds},
        );
        debugPrint('Left group: $groupId');
      }

      // Also update locally
      await _localDb.removeUserFromChat(groupId, currentUserId);
    } catch (e) {
      debugPrint('Failed to leave group: $e');
      rethrow;
    }
  }
}
