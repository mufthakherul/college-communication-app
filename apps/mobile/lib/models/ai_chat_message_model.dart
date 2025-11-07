class AIChatMessage {
  AIChatMessage({
    required this.id,
    required this.sessionId,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  factory AIChatMessage.fromMap(Map<String, dynamic> map) {
    return AIChatMessage(
      id: map['id'] as String,
      sessionId: map['sessionId'] as String,
      content: map['content'] as String,
      isUser: (map['isUser'] as int) == 1,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
  final String id;
  final String sessionId;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'content': content,
      'isUser': isUser ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  AIChatMessage copyWith({
    String? id,
    String? sessionId,
    String? content,
    bool? isUser,
    DateTime? timestamp,
  }) {
    return AIChatMessage(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
