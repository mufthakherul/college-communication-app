import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Update user role (admin only)
  Future<void> updateUserRole({
    required String userId,
    required String newRole,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  // Request admin approval
  Future<String> requestAdminApproval({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final approvalRequest = {
        'userId': currentUserId,
        'type': type,
        'data': data,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection('approvalRequests')
          .add(approvalRequest);

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create approval request: $e');
    }
  }

  // Process approval request (admin only)
  Future<void> processApprovalRequest({
    required String requestId,
    required String action, // 'approved' or 'rejected'
    String? reason,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore.collection('approvalRequests').doc(requestId).update({
        'status': action,
        'processedBy': currentUserId,
        'processedAt': FieldValue.serverTimestamp(),
        'reason': reason,
      });
    } catch (e) {
      throw Exception('Failed to process approval request: $e');
    }
  }

  // Get all approval requests (admin only)
  Stream<List<Map<String, dynamic>>> getApprovalRequests() {
    return _firestore
        .collection('approvalRequests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }

  // Get user's approval requests
  Stream<List<Map<String, dynamic>>> getUserApprovalRequests() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('approvalRequests')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }
}
