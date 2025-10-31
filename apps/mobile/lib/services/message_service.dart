import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campus_mesh/models/message_model.dart';

class MessageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user ID
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  // Validate UUID format to prevent injection
  bool _isValidUuid(String uuid) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(uuid);
  }

  // Get messages between current user and another user
  Stream<List<MessageModel>> getMessages(String otherUserId) {
    final currentUserId = _currentUserId;
    if (currentUserId == null || !_isValidUuid(otherUserId)) {
      return Stream.value([]);
    }

    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((data) {
          // Filter in memory for messages between the two users
          return data
              .where((item) {
                final senderId = item['sender_id'] as String?;
                final recipientId = item['recipient_id'] as String?;
                return (senderId == currentUserId &&
                        recipientId == otherUserId) ||
                    (senderId == otherUserId && recipientId == currentUserId);
              })
              .map((item) => MessageModel.fromJson(item))
              .toList();
        });
  }

  // Get recent conversations
  Stream<List<MessageModel>> getRecentConversations() {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {
          // Filter in memory for messages involving current user
          return data
              .where((item) {
                final senderId = item['sender_id'] as String?;
                final recipientId = item['recipient_id'] as String?;
                return senderId == currentUserId ||
                    recipientId == currentUserId;
              })
              .take(50)
              .map((item) => MessageModel.fromJson(item))
              .toList();
        });
  }

  // Send message
  Future<String> sendMessage({
    required String recipientId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    try {
      final currentUserId = _currentUserId;
      if (currentUserId == null) {
        throw Exception('User must be authenticated to send messages');
      }

      // Validate recipient ID format
      if (!_isValidUuid(recipientId)) {
        throw Exception('Invalid recipient ID format');
      }

      final message = {
        'sender_id': currentUserId,
        'recipient_id': recipientId,
        'content': content,
        'type': type.name,
        'read': false,
      };

      final response = await _supabase
          .from('messages')
          .insert(message)
          .select()
          .single();

      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Mark message as read
  // Note: Authorization check (recipient only) is enforced by PostgreSQL Row Level Security
  Future<void> markMessageAsRead(String messageId) async {
    try {
      final currentUserId = _currentUserId;
      if (currentUserId == null) {
        throw Exception('User must be authenticated to mark messages as read');
      }

      await _supabase
          .from('messages')
          .update({'read': true, 'read_at': DateTime.now().toIso8601String()})
          .eq('id', messageId);
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  // Get unread message count
  Stream<int> getUnreadCount() {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      return Stream.value(0);
    }

    return _supabase.from('messages').stream(primaryKey: ['id']).map((data) {
      // Filter in memory for unread messages to current user
      return data.where((item) {
        final recipientId = item['recipient_id'] as String?;
        final read = item['read'] as bool? ?? false;
        return recipientId == currentUserId && !read;
      }).length;
    });
  }
}
