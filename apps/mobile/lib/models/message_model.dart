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

  factory MessageModel.fromJson(Map<String, dynamic> data) {
    return MessageModel(
      id: data['id'] ?? '',
      senderId: data['sender_id'] ?? data['senderId'] ?? '',
      recipientId: data['recipient_id'] ?? data['recipientId'] ?? '',
      content: data['content'] ?? '',
      type: _parseType(data['type']),
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : null,
      read: data['read'] ?? false,
      readAt: data['read_at'] != null
          ? DateTime.parse(data['read_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender_id': senderId,
      'recipient_id': recipientId,
      'content': content,
      'type': type.name,
      'created_at': createdAt?.toIso8601String(),
      'read': read,
      'read_at': readAt?.toIso8601String(),
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
