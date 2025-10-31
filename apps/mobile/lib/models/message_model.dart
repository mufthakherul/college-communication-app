import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, file }

class MessageModel {
  final String id;
  final String senderId;
  final String recipientId;
  final String content;
  final MessageType type;
  final DateTime? createdAt;
  final bool read;
  final DateTime? readAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.type,
    this.createdAt,
    this.read = false,
    this.readAt,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      recipientId: data['recipientId'] ?? '',
      content: data['content'] ?? '',
      type: _parseType(data['type']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      read: data['read'] ?? false,
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'recipientId': recipientId,
      'content': content,
      'type': type.name,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'read': read,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }

  static MessageType _parseType(String? typeStr) {
    switch (typeStr?.toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'text':
      default:
        return MessageType.text;
    }
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? recipientId,
    String? content,
    MessageType? type,
    DateTime? createdAt,
    bool? read,
    DateTime? readAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
      readAt: readAt ?? this.readAt,
    );
  }
}
