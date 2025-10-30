import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notice_model.dart';

class NoticeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all active notices
  Stream<List<NoticeModel>> getNotices() {
    return _firestore
        .collection('notices')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => NoticeModel.fromFirestore(doc)).toList());
  }

  // Get notices by type
  Stream<List<NoticeModel>> getNoticesByType(NoticeType type) {
    return _firestore
        .collection('notices')
        .where('isActive', isEqualTo: true)
        .where('type', isEqualTo: type.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => NoticeModel.fromFirestore(doc)).toList());
  }

  // Get single notice
  Future<NoticeModel?> getNotice(String noticeId) async {
    try {
      final doc = await _firestore.collection('notices').doc(noticeId).get();
      if (doc.exists) {
        return NoticeModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get notice: $e');
    }
  }

  // Create notice (direct Firestore operation)
  Future<String> createNotice({
    required String title,
    required String content,
    required NoticeType type,
    required String targetAudience,
    DateTime? expiresAt,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final notice = {
        'title': title,
        'content': content,
        'type': type.name,
        'targetAudience': targetAudience,
        'authorId': currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'expiresAt': expiresAt,
        'isActive': true,
      };

      final docRef = await _firestore.collection('notices').add(notice);

      // Send notifications to target audience
      await _sendNoticeNotifications(
        noticeId: docRef.id,
        title: title,
        content: content,
        targetAudience: targetAudience,
        noticeType: type.name,
      );

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create notice: $e');
    }
  }

  // Update notice (direct Firestore operation)
  Future<void> updateNotice({
    required String noticeId,
    Map<String, dynamic>? updates,
  }) async {
    try {
      final updateData = {
        ...?updates,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('notices').doc(noticeId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update notice: $e');
    }
  }

  // Helper to send notifications for notices
  Future<void> _sendNoticeNotifications({
    required String noticeId,
    required String title,
    required String content,
    required String targetAudience,
    required String noticeType,
  }) async {
    try {
      // Get users matching target audience
      Query<Map<String, dynamic>> usersQuery = _firestore
          .collection('users')
          .where('isActive', isEqualTo: true);

      if (targetAudience != 'all') {
        usersQuery = usersQuery.where('role', isEqualTo: targetAudience);
      }

      final usersSnapshot = await usersQuery.get();

      // Create notifications for all target users
      final batch = _firestore.batch();
      for (final userDoc in usersSnapshot.docs) {
        final notificationRef = _firestore.collection('notifications').doc();
        batch.set(notificationRef, {
          'userId': userDoc.id,
          'type': 'notice',
          'title': title,
          'body': content.length > 100 
              ? '${content.substring(0, 100)}...' 
              : content,
          'data': {
            'noticeId': noticeId,
            'type': noticeType,
          },
          'createdAt': FieldValue.serverTimestamp(),
          'read': false,
        });
      }

      await batch.commit();
    } catch (e) {
      // Don't throw error if notification creation fails
      print('Failed to send notice notifications: $e');
    }
  }

  // Delete notice
  Future<void> deleteNotice(String noticeId) async {
    try {
      await updateNotice(
        noticeId: noticeId,
        updates: {'isActive': false},
      );
    } catch (e) {
      throw Exception('Failed to delete notice: $e');
    }
  }
}
