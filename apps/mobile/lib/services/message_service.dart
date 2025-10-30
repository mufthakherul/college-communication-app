import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';
import '../repositories/chat_repository.dart';

class MessageService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatRepository _chatRepository;

  MessageService({ChatRepository? chatRepository})
      : _chatRepository = chatRepository ?? FirestoreChatRepository();

  // Get messages between current user and another user
  Stream<List<MessageModel>> getMessages(String otherUserId) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _chatRepository.getMessages(currentUserId, otherUserId);
  }

  // Get recent conversations
  Stream<List<MessageModel>> getRecentConversations() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _chatRepository.getRecentConversations(currentUserId);
  }

  // Send message (direct Firestore write, no Cloud Functions)
  Future<String> sendMessage({
    required String recipientId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception('User must be authenticated to send messages');
    }

    try {
      return await _chatRepository.sendMessage(
        senderId: currentUserId,
        recipientId: recipientId,
        content: content,
        type: type,
      );
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Mark message as read (direct Firestore update, no Cloud Functions)
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _chatRepository.markMessageAsRead(messageId);
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  // Get unread message count
  Stream<int> getUnreadCount() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return Stream.value(0);
    }

    return _chatRepository.getUnreadCount(currentUserId);
  }

  // Get unread count for a specific conversation
  Stream<int> getConversationUnreadCount(String otherUserId) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return Stream.value(0);
    }

    return _chatRepository.getConversationUnreadCount(currentUserId, otherUserId);
  }
}
