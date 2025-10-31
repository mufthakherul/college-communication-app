import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campus_mesh/models/message_model.dart';

class MessageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user ID
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  // Get messages between current user and another user
  Stream<List<MessageModel>> getMessages(String otherUserId) {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .or('and(sender_id.eq.$currentUserId,recipient_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,recipient_id.eq.$currentUserId)')
        .order('created_at', ascending: true)
        .map((data) => data.map((item) => MessageModel.fromJson(item)).toList());
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
        .or('sender_id.eq.$currentUserId,recipient_id.eq.$currentUserId')
        .order('created_at', ascending: false)
        .limit(50)
        .map(
          (data) => data.map((item) => MessageModel.fromJson(item)).toList(),
        );
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

      await _supabase.from('messages').update({
        'read': true,
        'read_at': DateTime.now().toIso8601String(),
      }).eq('id', messageId);
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

    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('recipient_id', currentUserId)
        .eq('read', false)
        .map((data) => data.length);
  }
}
