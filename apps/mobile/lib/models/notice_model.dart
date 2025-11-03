enum NoticeType { announcement, event, urgent }

enum NoticeSource { admin, scraped }

class NoticeModel {
  final String id;
  final String title;
  final String content;
  final NoticeType type;
  final String targetAudience;
  final String authorId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;
  final bool isActive;
  final NoticeSource source;
  final String? sourceUrl; // For scraped notices

  NoticeModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.targetAudience,
    required this.authorId,
    this.createdAt,
    this.updatedAt,
    this.expiresAt,
    this.isActive = true,
    this.source = NoticeSource.admin,
    this.sourceUrl,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> data) {
    return NoticeModel(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      type: _parseType(data['type']),
      targetAudience:
          data['target_audience'] ?? data['targetAudience'] ?? 'all',
      authorId: data['author_id'] ?? data['authorId'] ?? '',
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : null,
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : null,
      expiresAt: data['expires_at'] != null
          ? DateTime.parse(data['expires_at'])
          : null,
      isActive: data['is_active'] ?? data['isActive'] ?? true,
      source: _parseSource(data['source']),
      sourceUrl: data['source_url'] ?? data['sourceUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'type': type.name,
      'target_audience': targetAudience,
      'author_id': authorId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'is_active': isActive,
      'source': source.name,
      'source_url': sourceUrl,
    };
  }

  static NoticeType _parseType(String? typeStr) {
    switch (typeStr?.toLowerCase()) {
      case 'event':
        return NoticeType.event;
      case 'urgent':
        return NoticeType.urgent;
      case 'announcement':
      default:
        return NoticeType.announcement;
    }
  }

  static NoticeSource _parseSource(String? sourceStr) {
    switch (sourceStr?.toLowerCase()) {
      case 'scraped':
        return NoticeSource.scraped;
      case 'admin':
      default:
        return NoticeSource.admin;
    }
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}
