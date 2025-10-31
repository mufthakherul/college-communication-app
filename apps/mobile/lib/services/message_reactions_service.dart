import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  final _supabase = Supabase.instance.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

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

      // Get user name
      final userProfile = await _supabase
          .from('profiles')
          .select('full_name')
          .eq('id', userId)
          .single();

      final userName = userProfile['full_name'] as String? ?? 'User';

      // Check if user already reacted to this message
      final existing = await _supabase
          .from('message_reactions')
          .select()
          .eq('message_id', messageId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        // Update existing reaction
        await _supabase
            .from('message_reactions')
            .update({
              'reaction': reaction.name,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('message_id', messageId)
            .eq('user_id', userId);

        if (kDebugMode) {
          print('Updated reaction for message $messageId to ${reaction.emoji}');
        }
      } else {
        // Insert new reaction
        await _supabase.from('message_reactions').insert({
          'message_id': messageId,
          'user_id': userId,
          'user_name': userName,
          'reaction': reaction.name,
        });

        if (kDebugMode) {
          print('Added reaction ${reaction.emoji} to message $messageId');
        }
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

      await _supabase
          .from('message_reactions')
          .delete()
          .eq('message_id', messageId)
          .eq('user_id', userId);

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
    return _supabase
        .from('message_reactions')
        .stream(primaryKey: ['message_id', 'user_id'])
        .eq('message_id', messageId)
        .map(
          (data) => data.map((item) => ReactionData.fromJson(item)).toList(),
        );
  }

  /// Get reaction summary for a message (count by reaction type)
  Future<Map<MessageReaction, int>> getReactionSummary(String messageId) async {
    try {
      final reactions = await _supabase
          .from('message_reactions')
          .select('reaction')
          .eq('message_id', messageId);

      final summary = <MessageReaction, int>{};

      for (final item in reactions) {
        final reactionName = item['reaction'] as String;
        final reaction = MessageReaction.values.firstWhere(
          (r) => r.name == reactionName,
          orElse: () => MessageReaction.like,
        );

        summary[reaction] = (summary[reaction] ?? 0) + 1;
      }

      return summary;
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

      final result = await _supabase
          .from('message_reactions')
          .select('reaction')
          .eq('message_id', messageId)
          .eq('user_id', userId)
          .maybeSingle();

      if (result == null) return null;

      final reactionName = result['reaction'] as String;
      return MessageReaction.values.firstWhere(
        (r) => r.name == reactionName,
        orElse: () => MessageReaction.like,
      );
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
      final reactions = await _supabase
          .from('message_reactions')
          .select()
          .eq('message_id', messageId)
          .order('created_at', ascending: false);

      return reactions.map((item) => ReactionData.fromJson(item)).toList();
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
      final count = await _supabase
          .from('message_reactions')
          .select()
          .eq('message_id', messageId)
          .count();

      return count.count;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting reaction count: $e');
      }
      return 0;
    }
  }
}
