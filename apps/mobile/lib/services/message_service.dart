import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get messages between current user and another user
  Stream<List<MessageModel>> getMessages(String otherUserId) {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('messages')
        .where('senderId', whereIn: [currentUserId, otherUserId])
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc))
              .where((msg) =>
                  (msg.senderId == currentUserId &&
                      msg.recipientId == otherUserId) ||
                  (msg.senderId == otherUserId &&
                      msg.recipientId == currentUserId))
              .toList();
        });
  }

  // Get recent conversations
  Stream<List<MessageModel>> getRecentConversations() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('messages')
        .where('senderId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList());
  }

  // Send message (using Cloud Function)
  Future<String> sendMessage({
    required String recipientId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    try {
      final callable = _functions.httpsCallable('sendMessage');
      final result = await callable.call({
        'recipientId': recipientId,
        'content': content,
        'type': type.name,
      });

      return result.data['messageId'] as String;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Mark message as read (using Cloud Function)
  Future<void> markMessageAsRead(String messageId) async {
    try {
      final callable = _functions.httpsCallable('markMessageAsRead');
      await callable.call({'messageId': messageId});
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

    return _firestore
        .collection('messages')
        .where('recipientId', isEqualTo: currentUserId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
