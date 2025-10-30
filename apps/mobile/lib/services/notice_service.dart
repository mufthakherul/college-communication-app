import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/notice_model.dart';

class NoticeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

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

  // Create notice (using Cloud Function)
  Future<String> createNotice({
    required String title,
    required String content,
    required NoticeType type,
    required String targetAudience,
    DateTime? expiresAt,
  }) async {
    try {
      final callable = _functions.httpsCallable('createNotice');
      final result = await callable.call({
        'title': title,
        'content': content,
        'type': type.name,
        'targetAudience': targetAudience,
        'expiresAt': expiresAt?.toIso8601String(),
      });

      return result.data['noticeId'] as String;
    } catch (e) {
      throw Exception('Failed to create notice: $e');
    }
  }

  // Update notice (using Cloud Function)
  Future<void> updateNotice({
    required String noticeId,
    Map<String, dynamic>? updates,
  }) async {
    try {
      final callable = _functions.httpsCallable('updateNotice');
      await callable.call({
        'noticeId': noticeId,
        'updates': updates,
      });
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
