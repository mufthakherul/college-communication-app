import 'package:cloud_firestore/cloud_firestore.dart';

enum NoticeType { announcement, event, urgent }

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
  });

  factory NoticeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoticeModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      type: _parseType(data['type']),
      targetAudience: data['targetAudience'] ?? 'all',
      authorId: data['authorId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'type': type.name,
      'targetAudience': targetAudience,
      'authorId': authorId,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'isActive': isActive,
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

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}
