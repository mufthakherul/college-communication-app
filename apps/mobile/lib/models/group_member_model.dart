class GroupMemberModel {

  GroupMemberModel({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.role,
    this.nickname,
    required this.status,
    required this.joinedAt,
    this.lastSeenAt,
    required this.unreadCount,
    this.metadata,
    this.userDisplayName,
    this.userPhotoUrl,
    this.userEmail,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> data) {
    return GroupMemberModel(
      id: data[r'$id'] ?? data['id'] ?? '',
      groupId: data['group_id'] ?? data['groupId'] ?? '',
      userId: data['user_id'] ?? data['userId'] ?? '',
      role: data['role'] ?? 'member',
      nickname: data['nickname'] as String?,
      status: data['status'] ?? 'active',
      joinedAt: data['joined_at'] != null
          ? DateTime.parse(data['joined_at'])
          : DateTime.now(),
      lastSeenAt: data['last_seen_at'] != null
          ? DateTime.parse(data['last_seen_at'])
          : null,
      unreadCount: data['unread_count'] ?? 0,
      metadata: data['metadata'] as Map<String, dynamic>?,
      userDisplayName: data['user_display_name'] as String?,
      userPhotoUrl: data['user_photo_url'] as String?,
      userEmail: data['user_email'] as String?,
    );
  }
  final String id; // Format: group_{groupId}_user_{userId}
  final String groupId;
  final String userId;
  final String role; // 'admin', 'moderator', 'member'
  final String? nickname;
  final String status; // 'active', 'muted', 'blocked', 'inactive'
  final DateTime joinedAt;
  final DateTime? lastSeenAt;
  final int unreadCount;
  final Map<String, dynamic>? metadata;

  // Denormalized fields for UI display
  final String? userDisplayName;
  final String? userPhotoUrl;
  final String? userEmail;

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'user_id': userId,
      'role': role,
      'nickname': nickname,
      'status': status,
      'joined_at': joinedAt.toIso8601String(),
      'last_seen_at': lastSeenAt?.toIso8601String(),
      'unread_count': unreadCount,
      'metadata': metadata,
    };
  }

  GroupMemberModel copyWith({
    String? id,
    String? groupId,
    String? userId,
    String? role,
    String? nickname,
    String? status,
    DateTime? joinedAt,
    DateTime? lastSeenAt,
    int? unreadCount,
    Map<String, dynamic>? metadata,
    String? userDisplayName,
    String? userPhotoUrl,
    String? userEmail,
  }) {
    return GroupMemberModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      nickname: nickname ?? this.nickname,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      unreadCount: unreadCount ?? this.unreadCount,
      metadata: metadata ?? this.metadata,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      userEmail: userEmail ?? this.userEmail,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isModerator => role == 'moderator';
  bool get isActive => status == 'active';
  bool get isMuted => status == 'muted';

  @override
  String toString() =>
      'GroupMemberModel(id: $id, userId: $userId, role: $role, status: $status)';
}
