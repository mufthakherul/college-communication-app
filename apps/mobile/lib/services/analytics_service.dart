import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Track user activity
  Future<void> trackUserActivity({
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        return; // Don't throw error, just skip tracking
      }

      final activity = {
        'userId': currentUserId,
        'action': action,
        'metadata': metadata ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('userActivity').add(activity);
    } catch (e) {
      // Don't throw error for analytics tracking failures
      print('Failed to track user activity: $e');
    }
  }

  // Generate user activity report (admin only)
  Future<Map<String, dynamic>> generateUserActivityReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('userActivity')
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .get();

      final activities = snapshot.docs.map((doc) => doc.data()).toList();

      return {
        'totalActivities': activities.length,
        'uniqueUsers': activities.map((a) => a['userId']).toSet().length,
        'topActions': _getTopActions(activities),
        'dailyBreakdown': _getDailyBreakdown(activities),
      };
    } catch (e) {
      throw Exception('Failed to generate user activity report: $e');
    }
  }

  // Generate notices report (admin only)
  Future<Map<String, dynamic>> generateNoticesReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('notices')
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .where('createdAt', isLessThanOrEqualTo: endDate)
          .get();

      final notices = snapshot.docs.map((doc) => doc.data()).toList();

      return {
        'totalNotices': notices.length,
        'activeNotices': notices.where((n) => n['isActive'] == true).length,
        'byType': _getNoticesByType(notices),
        'byAuthor': _getNoticesByAuthor(notices),
      };
    } catch (e) {
      throw Exception('Failed to generate notices report: $e');
    }
  }

  // Generate messages report (admin only)
  Future<Map<String, dynamic>> generateMessagesReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('messages')
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .where('createdAt', isLessThanOrEqualTo: endDate)
          .get();

      final messages = snapshot.docs.map((doc) => doc.data()).toList();

      return {
        'totalMessages': messages.length,
        'readMessages': messages.where((m) => m['read'] == true).length,
        'byType': _getMessagesByType(messages),
      };
    } catch (e) {
      throw Exception('Failed to generate messages report: $e');
    }
  }

  // Helper methods
  Map<String, int> _getTopActions(List<Map<String, dynamic>> activities) {
    final actionCounts = <String, int>{};
    for (final activity in activities) {
      final action = activity['action'] as String;
      actionCounts[action] = (actionCounts[action] ?? 0) + 1;
    }

    final sortedEntries = actionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries.take(10));
  }

  Map<String, int> _getDailyBreakdown(List<Map<String, dynamic>> activities) {
    final dailyCounts = <String, int>{};
    for (final activity in activities) {
      final timestamp = activity['timestamp'] as Timestamp?;
      if (timestamp != null) {
        final date = timestamp.toDate().toIso8601String().split('T')[0];
        dailyCounts[date] = (dailyCounts[date] ?? 0) + 1;
      }
    }
    return dailyCounts;
  }

  Map<String, int> _getNoticesByType(List<Map<String, dynamic>> notices) {
    final typeCounts = <String, int>{};
    for (final notice in notices) {
      final type = notice['type'] as String;
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }
    return typeCounts;
  }

  Map<String, int> _getNoticesByAuthor(List<Map<String, dynamic>> notices) {
    final authorCounts = <String, int>{};
    for (final notice in notices) {
      final authorId = notice['authorId'] as String;
      authorCounts[authorId] = (authorCounts[authorId] ?? 0) + 1;
    }
    return authorCounts;
  }

  Map<String, int> _getMessagesByType(List<Map<String, dynamic>> messages) {
    final typeCounts = <String, int>{};
    for (final message in messages) {
      final type = message['type'] as String;
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }
    return typeCounts;
  }
}
