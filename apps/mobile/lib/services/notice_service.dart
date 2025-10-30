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

  // Create notice (direct Firestore write)
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
        throw Exception('User must be authenticated to create notices');
      }

      final notice = NoticeModel(
        id: '', // Will be set by Firestore
        title: title,
        content: content,
        type: type,
        targetAudience: targetAudience,
        authorId: currentUserId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        expiresAt: expiresAt,
        isActive: true,
      );

      final docRef = await _firestore.collection('notices').add(notice.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create notice: $e');
    }
  }

  // Update notice (direct Firestore write)
  // Note: Authorization is enforced by Firestore Security Rules
  Future<void> updateNotice({
    required String noticeId,
    Map<String, dynamic>? updates,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('User must be authenticated to update notices');
      }

      final noticeDoc = await _firestore.collection('notices').doc(noticeId).get();
      if (!noticeDoc.exists) {
        throw Exception('Notice not found');
      }

      final updateData = {
        ...?updates,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('notices').doc(noticeId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update notice: $e');
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
