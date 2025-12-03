class GroupModel {
  GroupModel({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    required this.groupType,
    this.avatarUrl,
    required this.memberCount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  factory GroupModel.fromJson(Map<String, dynamic> data) {
    return GroupModel(
      id: data[r'$id'] ?? data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] as String?,
      ownerId: data['owner_id'] ?? data['ownerId'] ?? '',
      groupType: data['group_type'] ?? data['groupType'] ?? 'project',
      avatarUrl: data['avatar_url'] as String?,
      memberCount: data['member_count'] ?? data['memberCount'] ?? 0,
      isActive: data['is_active'] ?? data['isActive'] ?? true,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : DateTime.now(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final String groupType; // 'class', 'department', 'project', 'interest'
  final String? avatarUrl;
  final int memberCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'owner_id': ownerId,
      'group_type': groupType,
      'avatar_url': avatarUrl,
      'member_count': memberCount,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  GroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    String? groupType,
    String? avatarUrl,
    int? memberCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      groupType: groupType ?? this.groupType,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      memberCount: memberCount ?? this.memberCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() =>
      'GroupModel(id: $id, name: $name, memberCount: $memberCount)';
}
