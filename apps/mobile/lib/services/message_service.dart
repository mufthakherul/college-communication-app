import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

  // Send message (direct Firestore operation)
  Future<String> sendMessage({
    required String recipientId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final message = {
        'senderId': currentUserId,
        'recipientId': recipientId,
        'content': content,
        'type': type.name,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      };

      final docRef = await _firestore.collection('messages').add(message);

      // Create notification for recipient
      await _createNotification(
        userId: recipientId,
        title: 'New Message',
        body: content.length > 50 ? '${content.substring(0, 50)}...' : content,
        type: 'message',
        data: {
          'messageId': docRef.id,
          'senderId': currentUserId,
        },
      );

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Mark message as read (direct Firestore operation)
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _firestore.collection('messages').doc(messageId).update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  // Helper to create notification
  Future<void> _createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'type': type,
        'title': title,
        'body': body,
        'data': data ?? {},
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      // Don't throw error if notification creation fails
      print('Failed to create notification: $e');
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
