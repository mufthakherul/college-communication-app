enum MessageType { text, image, file, video, audio, document }

class MessageModel {
  final String id;
  final String senderId;
  final String recipientId;
  final String content;
  final MessageType type;
  final DateTime? createdAt;
  final bool read;
  final DateTime? readAt;
  final String? attachmentUrl; // URL for file attachments
  final String? attachmentName; // Original file name
  final int? attachmentSize; // File size in bytes
  final String? thumbnailUrl; // Thumbnail for images/videos
  final Map<String, dynamic>? metadata; // Additional metadata

  MessageModel({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.type,
    this.createdAt,
    this.read = false,
    this.readAt,
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentSize,
    this.thumbnailUrl,
    this.metadata,
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
      attachmentUrl: data['attachment_url'] as String?,
      attachmentName: data['attachment_name'] as String?,
      attachmentSize: data['attachment_size'] as int?,
      thumbnailUrl: data['thumbnail_url'] as String?,
      metadata: data['metadata'] as Map<String, dynamic>?,
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
      'attachment_url': attachmentUrl,
      'attachment_name': attachmentName,
      'attachment_size': attachmentSize,
      'thumbnail_url': thumbnailUrl,
      'metadata': metadata,
    };
  }

  static MessageType _parseType(String? typeStr) {
    switch (typeStr?.toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'video':
        return MessageType.video;
      case 'audio':
        return MessageType.audio;
      case 'document':
        return MessageType.document;
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
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
    String? thumbnailUrl,
    Map<String, dynamic>? metadata,
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
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentName: attachmentName ?? this.attachmentName,
      attachmentSize: attachmentSize ?? this.attachmentSize,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      metadata: metadata ?? this.metadata,
    );
  }
  
  /// Check if message has attachment
  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;
  
  /// Get file extension from attachment name
  String? get fileExtension {
    if (attachmentName == null) return null;
    final parts = attachmentName!.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : null;
  }
  
  /// Get human-readable file size
  String get formattedFileSize {
    if (attachmentSize == null) return '';
    final bytes = attachmentSize!;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
