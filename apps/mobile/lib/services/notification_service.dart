import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campus_mesh/models/notification_model.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user ID
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  // Initialize notifications
  // Note: Push notifications via FCM need to be set up separately
  // Consider using services like OneSignal, Pusher, or a custom solution
  Future<void> initialize() async {
    if (kDebugMode) {
      debugPrint('Notification service initialized');
      debugPrint(
        'Note: Push notifications require third-party service integration',
      );
    }
  }

  // Get notifications for current user
  Stream<List<NotificationModel>> getNotifications() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50)
        .map(
          (data) =>
              data.map((item) => NotificationModel.fromJson(item)).toList(),
        );
  }

  // Get unread notification count
  Stream<int> getUnreadCount() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value(0);
    }

    return _supabase.from('notifications').stream(primaryKey: ['id']).map((
      data,
    ) {
      // Filter in memory for unread notifications for current user
      return data.where((item) {
        final notificationUserId = item['user_id'] as String?;
        final read = item['read'] as bool? ?? false;
        return notificationUserId == userId && !read;
      }).length;
    });
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await _supabase
          .from('notifications')
          .update({'read': true})
          .eq('user_id', userId)
          .eq('read', false);
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }
}
