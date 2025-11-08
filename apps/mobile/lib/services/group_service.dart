// ignore_for_file: depend_on_referenced_packages

import 'package:appwrite/appwrite.dart';
import 'package:campus_mesh/models/group_member_model.dart';
import 'package:campus_mesh/models/group_model.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class GroupService {
  final Databases _database;
  final AuthService _authService;
  static const String _groupsCollectionId = 'groups';
  static const String _groupMembersCollectionId = 'group_members';
  static const String _databaseId = 'rpi_communication';

  GroupService({required Databases database, required AuthService authService})
    : _database = database,
      _authService = authService;

  /// Create a new group
  Future<GroupModel> createGroup({
    required String name,
    required String description,
    required String groupType,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      final groupId =
          'grp_${DateTime.now().millisecondsSinceEpoch}_${currentUserId.substring(0, 8)}';

      final data = {
        'name': name,
        'description': description,
        'owner_id': currentUserId,
        'group_type': groupType,
        'avatar_url': avatarUrl,
        'member_count': 1, // Start with creator
        'is_active': true,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'metadata': metadata,
      };

      final response = await _database.createDocument(
        databaseId: _databaseId,
        collectionId: _groupsCollectionId,
        documentId: groupId,
        data: data,
        permissions: [
          Permission.read(Role.team('group_${groupId}_members')),
          Permission.update(Role.user(currentUserId)),
          Permission.delete(Role.user(currentUserId)),
        ],
      );

      // Add creator as admin member
      await addMember(groupId: groupId, userId: currentUserId, role: 'admin');

      debugPrint('✅ Group created: $groupId');
      return GroupModel.fromJson(response.data);
    } catch (e) {
      debugPrint('❌ Error creating group: $e');
      rethrow;
    }
  }

  /// Add a member to a group
  Future<GroupMemberModel> addMember({
    required String groupId,
    required String userId,
    required String role,
    String? nickname,
  }) async {
    try {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Verify user is group admin or owner
      final isMemberAdmin = await _isUserGroupAdmin(groupId, currentUserId);
      if (!isMemberAdmin) {
        throw Exception('Only group admins can add members');
      }

      final memberId = 'group_${groupId}_user_$userId';
      final now = DateTime.now();

      final data = {
        'group_id': groupId,
        'user_id': userId,
        'role': role,
        'nickname': nickname ?? '',
        'status': 'active',
        'joined_at': now.toIso8601String(),
        'unread_count': 0,
        'metadata': {},
      };

      final response = await _database.createDocument(
        databaseId: _databaseId,
        collectionId: _groupMembersCollectionId,
        documentId: memberId,
        data: data,
        permissions: [
          Permission.read(Role.user(userId)),
          Permission.read(Role.team('group_${groupId}_admins')),
          Permission.update(Role.user(userId)),
          Permission.update(Role.team('group_${groupId}_admins')),
          Permission.delete(Role.team('group_${groupId}_admins')),
        ],
      );

      // Increment group member count
      await _incrementMemberCount(groupId);

      debugPrint('✅ Member added to group: $userId');
      return GroupMemberModel.fromJson(response.data);
    } catch (e) {
      debugPrint('❌ Error adding member: $e');
      rethrow;
    }
  }

  /// Remove a member from a group
  Future<void> removeMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Verify user is group admin or removing themselves
      final isMemberAdmin = await _isUserGroupAdmin(groupId, currentUserId);
      if (!isMemberAdmin && currentUserId != userId) {
        throw Exception('Only group admins can remove members');
      }

      final memberId = 'group_${groupId}_user_$userId';
      await _database.deleteDocument(
        databaseId: _databaseId,
        collectionId: _groupMembersCollectionId,
        documentId: memberId,
      );

      // Decrement group member count
      await _decrementMemberCount(groupId);

      debugPrint('✅ Member removed from group: $userId');
    } catch (e) {
      debugPrint('❌ Error removing member: $e');
      rethrow;
    }
  }

  /// Get all groups for current user
  Future<List<GroupModel>> getUserGroups() async {
    try {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Query group_members to get user's groups
      final memberDocs = await _database.listDocuments(
        databaseId: _databaseId,
        collectionId: _groupMembersCollectionId,
        queries: [
          Query.equal('user_id', currentUserId),
          Query.orderDesc('joined_at'),
        ],
      );

      if (memberDocs.documents.isEmpty) {
        return [];
      }

      // Get group IDs from member docs
      final groupIds = memberDocs.documents
          .map((doc) => doc.data['group_id'] as String)
          .toList();

      // Query groups collection
      // Note: Appwrite doesn't have Query.isIn, so fetch all and filter
      final allGroupDocs = await _database.listDocuments(
        databaseId: _databaseId,
        collectionId: _groupsCollectionId,
        queries: [Query.equal('is_active', true), Query.limit(100)],
      );

      // Filter by group IDs
      final groupDocs =
          allGroupDocs.documents
              .where((doc) => groupIds.contains(doc.$id))
              .toList()
            ..sort((a, b) {
              final aDate = DateTime.tryParse(a.data['updated_at'] ?? '');
              final bDate = DateTime.tryParse(b.data['updated_at'] ?? '');
              if (aDate == null || bDate == null) return 0;
              return bDate.compareTo(aDate);
            });

      return groupDocs.map((doc) => GroupModel.fromJson(doc.data)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching user groups: $e');
      return [];
    }
  }

  /// Get group details
  Future<GroupModel?> getGroupDetails(String groupId) async {
    try {
      final doc = await _database.getDocument(
        databaseId: _databaseId,
        collectionId: _groupsCollectionId,
        documentId: groupId,
      );

      return GroupModel.fromJson(doc.data);
    } catch (e) {
      debugPrint('❌ Error fetching group details: $e');
      return null;
    }
  }

  /// Get all members of a group
  Future<List<GroupMemberModel>> getGroupMembers(String groupId) async {
    try {
      final docs = await _database.listDocuments(
        databaseId: _databaseId,
        collectionId: _groupMembersCollectionId,
        queries: [
          Query.equal('group_id', groupId),
          Query.equal('status', 'active'),
          Query.orderAsc('joined_at'),
        ],
      );

      return docs.documents
          .map((doc) => GroupMemberModel.fromJson(doc.data))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching group members: $e');
      return [];
    }
  }

  /// Update member role
  Future<void> updateMemberRole({
    required String groupId,
    required String userId,
    required String newRole,
  }) async {
    try {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Verify user is group admin
      final isMemberAdmin = await _isUserGroupAdmin(groupId, currentUserId);
      if (!isMemberAdmin) {
        throw Exception('Only group admins can update member roles');
      }

      final memberId = 'group_${groupId}_user_$userId';
      await _database.updateDocument(
        databaseId: _databaseId,
        collectionId: _groupMembersCollectionId,
        documentId: memberId,
        data: {'role': newRole},
      );

      debugPrint('✅ Member role updated: $userId -> $newRole');
    } catch (e) {
      debugPrint('❌ Error updating member role: $e');
      rethrow;
    }
  }

  /// Mute/unmute member
  Future<void> updateMemberStatus({
    required String groupId,
    required String userId,
    required String status,
  }) async {
    try {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // User can mute themselves or admin can mute others
      final isMemberAdmin = await _isUserGroupAdmin(groupId, currentUserId);
      if (!isMemberAdmin && currentUserId != userId) {
        throw Exception('Only group admins can update member status');
      }

      final memberId = 'group_${groupId}_user_$userId';
      await _database.updateDocument(
        databaseId: _databaseId,
        collectionId: _groupMembersCollectionId,
        documentId: memberId,
        data: {'status': status},
      );

      debugPrint('✅ Member status updated: $userId -> $status');
    } catch (e) {
      debugPrint('❌ Error updating member status: $e');
      rethrow;
    }
  }

  /// Update group information
  Future<void> updateGroupInfo({
    required String groupId,
    String? name,
    String? description,
    String? avatarUrl,
  }) async {
    try {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get group to verify user is owner
      final group = await getGroupDetails(groupId);
      if (group == null) {
        throw Exception('Group not found');
      }

      if (group.ownerId != currentUserId) {
        throw Exception('Only group owner can update group info');
      }

      final updateData = {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _database.updateDocument(
        databaseId: _databaseId,
        collectionId: _groupsCollectionId,
        documentId: groupId,
        data: updateData,
      );

      debugPrint('✅ Group updated: $groupId');
    } catch (e) {
      debugPrint('❌ Error updating group: $e');
      rethrow;
    }
  }

  /// Delete a group
  Future<void> deleteGroup(String groupId) async {
    try {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Get group to verify user is owner
      final group = await getGroupDetails(groupId);
      if (group == null) {
        throw Exception('Group not found');
      }

      if (group.ownerId != currentUserId) {
        throw Exception('Only group owner can delete group');
      }

      // Soft delete: just mark as inactive
      await _database.updateDocument(
        databaseId: _databaseId,
        collectionId: _groupsCollectionId,
        documentId: groupId,
        data: {'is_active': false},
      );

      debugPrint('✅ Group deleted: $groupId');
    } catch (e) {
      debugPrint('❌ Error deleting group: $e');
      rethrow;
    }
  }

  /// Get unread count for a group
  Future<int> getUnreadCount(String groupId) async {
    try {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        return 0;
      }

      final memberId = 'group_$groupId' + '_user_$currentUserId';
      final doc = await _database.getDocument(
        databaseId: _databaseId,
        collectionId: _groupMembersCollectionId,
        documentId: memberId,
      );

      return doc.data['unread_count'] ?? 0;
    } catch (e) {
      debugPrint('⚠️  Error getting unread count: $e');
      return 0;
    }
  }

  /// Mark group messages as read
  Future<void> markGroupAsRead(String groupId) async {
    try {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final memberId = 'group_$groupId' + '_user_$currentUserId';
      await _database.updateDocument(
        databaseId: _databaseId,
        collectionId: _groupMembersCollectionId,
        documentId: memberId,
        data: {
          'unread_count': 0,
          'last_seen_at': DateTime.now().toIso8601String(),
        },
      );

      debugPrint('✅ Group marked as read: $groupId');
    } catch (e) {
      debugPrint('❌ Error marking group as read: $e');
    }
  }

  // Private helper methods

  /// Check if user is group admin
  Future<bool> _isUserGroupAdmin(String groupId, String userId) async {
    try {
      final memberId = 'group_${groupId}_user_$userId';
      final doc = await _database.getDocument(
        databaseId: _databaseId,
        collectionId: _groupMembersCollectionId,
        documentId: memberId,
      );

      final role = doc.data['role'] as String?;
      return role == 'admin' || role == 'moderator';
    } catch (e) {
      debugPrint('⚠️  Error checking admin status: $e');
      return false;
    }
  }

  /// Increment group member count
  Future<void> _incrementMemberCount(String groupId) async {
    try {
      final group = await getGroupDetails(groupId);
      if (group != null) {
        await _database.updateDocument(
          databaseId: _databaseId,
          collectionId: _groupsCollectionId,
          documentId: groupId,
          data: {'member_count': group.memberCount + 1},
        );
      }
    } catch (e) {
      debugPrint('⚠️  Error incrementing member count: $e');
    }
  }

  /// Decrement group member count
  Future<void> _decrementMemberCount(String groupId) async {
    try {
      final group = await getGroupDetails(groupId);
      if (group != null && group.memberCount > 0) {
        await _database.updateDocument(
          databaseId: _databaseId,
          collectionId: _groupsCollectionId,
          documentId: groupId,
          data: {'member_count': group.memberCount - 1},
        );
      }
    } catch (e) {
      debugPrint('⚠️  Error decrementing member count: $e');
    }
  }

  void dispose() {
    // Cleanup if needed
  }
}
