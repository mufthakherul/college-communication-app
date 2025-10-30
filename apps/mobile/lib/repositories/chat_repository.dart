import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

/// Abstract repository interface for chat operations
/// This allows for future backend flexibility and easier testing
abstract class ChatRepository {
  /// Get messages between two users in real-time
  Stream<List<MessageModel>> getMessages(String currentUserId, String otherUserId);
  
  /// Get recent conversations for the current user
  Stream<List<MessageModel>> getRecentConversations(String currentUserId);
  
  /// Send a message (returns the message ID)
  Future<String> sendMessage({
    required String senderId,
    required String recipientId,
    required String content,
    required MessageType type,
  });
  
  /// Mark a message as read
  Future<void> markMessageAsRead(String messageId);
  
  /// Get unread message count for a user
  Stream<int> getUnreadCount(String userId);
  
  /// Get unread count for a specific conversation
  Stream<int> getConversationUnreadCount(String currentUserId, String otherUserId);
}

/// Firestore implementation of ChatRepository
class FirestoreChatRepository implements ChatRepository {
  final FirebaseFirestore _firestore;

  FirestoreChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<MessageModel>> getMessages(String currentUserId, String otherUserId) {
    return _firestore
        .collection('messages')
        .where('participants', arrayContains: currentUserId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .where((msg) =>
              (msg.senderId == currentUserId && msg.recipientId == otherUserId) ||
              (msg.senderId == otherUserId && msg.recipientId == currentUserId))
          .toList();
    });
  }

  @override
  Stream<List<MessageModel>> getRecentConversations(String currentUserId) {
    return _firestore
        .collection('messages')
        .where('participants', arrayContains: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();
      
      // Group by conversation partner and get the latest message
      final Map<String, MessageModel> conversations = {};
      for (final message in messages) {
        final otherUserId = message.senderId == currentUserId
            ? message.recipientId
            : message.senderId;
        
        if (!conversations.containsKey(otherUserId) ||
            (message.createdAt != null &&
                conversations[otherUserId]!.createdAt != null &&
                message.createdAt!.isAfter(conversations[otherUserId]!.createdAt!))) {
          conversations[otherUserId] = message;
        }
      }
      
      final conversationList = conversations.values.toList()
        ..sort((a, b) {
          if (a.createdAt == null || b.createdAt == null) return 0;
          return b.createdAt!.compareTo(a.createdAt!);
        });
      
      return conversationList;
    });
  }

  @override
  Future<String> sendMessage({
    required String senderId,
    required String recipientId,
    required String content,
    required MessageType type,
  }) async {
    final message = {
      'senderId': senderId,
      'recipientId': recipientId,
      'content': content,
      'type': type.name,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
      'readAt': null,
      'participants': [senderId, recipientId], // For efficient querying
    };

    final docRef = await _firestore.collection('messages').add(message);
    return docRef.id;
  }

  @override
  Future<void> markMessageAsRead(String messageId) async {
    await _firestore.collection('messages').doc(messageId).update({
      'read': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('messages')
        .where('recipientId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Stream<int> getConversationUnreadCount(String currentUserId, String otherUserId) {
    return _firestore
        .collection('messages')
        .where('senderId', isEqualTo: otherUserId)
        .where('recipientId', isEqualTo: currentUserId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
