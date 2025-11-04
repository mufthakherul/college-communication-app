import 'package:flutter/foundation.dart';
import 'package:campus_mesh/services/auth_service.dart';

/// Available reaction emojis for messages
enum MessageReaction {
  like, // 👍
  love, // ❤️
  laugh, // 😂
  wow, // 😮
  sad, // 😢
  angry, // 😠
  fire, // 🔥
  celebrate, // 🎉
  thumbsDown, // 👎
  clap, // 👏
}

/// Extension to get emoji for reaction
extension MessageReactionEmoji on MessageReaction {
  String get emoji {
    switch (this) {
      case MessageReaction.like:
        return '👍';
      case MessageReaction.love:
        return '❤️';
      case MessageReaction.laugh:
        return '😂';
      case MessageReaction.wow:
        return '😮';
      case MessageReaction.sad:
        return '😢';
      case MessageReaction.angry:
        return '😠';
      case MessageReaction.fire:
        return '🔥';
      case MessageReaction.celebrate:
        return '🎉';
      case MessageReaction.thumbsDown:
        return '👎';
      case MessageReaction.clap:
        return '👏';
    }
  }

  String get name {
    switch (this) {
      case MessageReaction.like:
        return 'Like';
      case MessageReaction.love:
        return 'Love';
      case MessageReaction.laugh:
        return 'Laugh';
      case MessageReaction.wow:
        return 'Wow';
      case MessageReaction.sad:
        return 'Sad';
      case MessageReaction.angry:
        return 'Angry';
      case MessageReaction.fire:
        return 'Fire';
      case MessageReaction.celebrate:
        return 'Celebrate';
      case MessageReaction.thumbsDown:
        return 'Thumbs Down';
      case MessageReaction.clap:
        return 'Clap';
    }
  }
}

/// Reaction data model
class ReactionData {
  final String messageId;
  final String userId;
  final String userName;
  final MessageReaction reaction;
  final DateTime createdAt;

  ReactionData({
    required this.messageId,
    required this.userId,
    required this.userName,
    required this.reaction,
    required this.createdAt,
  });

  factory ReactionData.fromJson(Map<String, dynamic> json) {
    return ReactionData(
      messageId: json['message_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String? ?? 'Unknown',
      reaction: MessageReaction.values.firstWhere(
        (r) => r.name == json['reaction'],
        orElse: () => MessageReaction.like,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'message_id': messageId,
    'user_id': userId,
    'user_name': userName,
    'reaction': reaction.name,
    'created_at': createdAt.toIso8601String(),
  };
}

/// Service to handle message reactions (emojis)
class MessageReactionsService {
  static final MessageReactionsService _instance =
      MessageReactionsService._internal();
  factory MessageReactionsService() => _instance;
  MessageReactionsService._internal();

  final _authService = AuthService();

  String? get _currentUserId => _authService.currentUserId;

  /// Add reaction to a message
  Future<void> addReaction({
    required String messageId,
    required MessageReaction reaction,
  }) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('User must be authenticated');
      }

      // Stub implementation - would require custom Appwrite collection for reactions
      if (kDebugMode) {
        print('Added reaction ${reaction.emoji} to message $messageId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding reaction: $e');
      }
      rethrow;
    }
  }

  /// Remove reaction from a message
  Future<void> removeReaction({required String messageId}) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('User must be authenticated');
      }

      // Stub implementation
      if (kDebugMode) {
        print('Removed reaction from message $messageId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing reaction: $e');
      }
      rethrow;
    }
  }

  /// Get reactions for a message
  Stream<List<ReactionData>> getReactions(String messageId) {
    // Stub implementation
    return Stream.value([]);
  }

  /// Get reaction summary for a message (count by reaction type)
  Future<Map<MessageReaction, int>> getReactionSummary(String messageId) async {
    try {
      // Stub implementation
      if (kDebugMode) {
        print('Getting reaction summary for message $messageId');
      }
      return {};
    } catch (e) {
      if (kDebugMode) {
        print('Error getting reaction summary: $e');
      }
      return {};
    }
  }

  /// Check if current user has reacted to a message
  Future<MessageReaction?> getUserReaction(String messageId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) return null;

      // Stub implementation
      if (kDebugMode) {
        print('Getting user reaction for message $messageId');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user reaction: $e');
      }
      return null;
    }
  }

  /// Get all reactions with user details
  Future<List<ReactionData>> getReactionsWithUsers(String messageId) async {
    try {
      // Stub implementation
      if (kDebugMode) {
        print('Getting reactions with users for message $messageId');
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error getting reactions with users: $e');
      }
      return [];
    }
  }

  /// Get total reaction count for a message
  Future<int> getReactionCount(String messageId) async {
    try {
      // Stub implementation
      if (kDebugMode) {
        print('Getting reaction count for message $messageId');
      }
      return 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting reaction count: $e');
      }
      return 0;
    }
  }
}
