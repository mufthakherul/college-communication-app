import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// OneSignal push notification service
/// Provides cross-platform push notification support
class OneSignalService {
  factory OneSignalService() => _instance;
  OneSignalService._internal();
  // Singleton pattern
  static final OneSignalService _instance = OneSignalService._internal();

  bool _initialized = false;

  /// Initialize OneSignal
  /// Should be called in main() after Flutter binding is initialized
  Future<void> initialize(String appId) async {
    if (_initialized) {
      if (kDebugMode) {
        debugPrint('OneSignal already initialized');
      }
      return;
    }

    try {
      // Initialize OneSignal
      OneSignal.initialize(appId);

      // Request notification permission
      await OneSignal.Notifications.requestPermission(true);

      // Set up notification opened handler
      OneSignal.Notifications.addClickListener(_handleNotificationOpened);

      // Set up notification received handler (foreground)
      OneSignal.Notifications.addForegroundWillDisplayListener(
        _handleNotificationReceived,
      );

      _initialized = true;

      if (kDebugMode) {
        debugPrint('OneSignal initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to initialize OneSignal: $e');
      }
    }
  }

  /// Login a user to OneSignal
  /// Associates notifications with a specific user ID
  Future<void> loginUser(String userId, {String? email}) async {
    try {
      await OneSignal.login(userId);

      // Add email tag if provided
      if (email != null) {
        await setUserTags({'email': email});
      }

      if (kDebugMode) {
        debugPrint('User logged in to OneSignal: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to login user to OneSignal: $e');
      }
    }
  }

  /// Logout the current user
  Future<void> logoutUser() async {
    try {
      await OneSignal.logout();

      if (kDebugMode) {
        debugPrint('User logged out from OneSignal');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to logout user from OneSignal: $e');
      }
    }
  }

  /// Set user tags for segmentation
  Future<void> setUserTags(Map<String, String> tags) async {
    try {
      OneSignal.User.addTags(tags);

      if (kDebugMode) {
        debugPrint('User tags set: $tags');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to set user tags: $e');
      }
    }
  }

  /// Remove user tags
  Future<void> removeUserTags(List<String> keys) async {
    try {
      OneSignal.User.removeTags(keys);

      if (kDebugMode) {
        debugPrint('User tags removed: $keys');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to remove user tags: $e');
      }
    }
  }

  /// Get the OneSignal player ID
  String? getPlayerId() {
    return OneSignal.User.pushSubscription.id;
  }

  /// Check if user has granted notification permission
  Future<bool> hasNotificationPermission() async {
    return OneSignal.Notifications.permission;
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    return OneSignal.Notifications.requestPermission(true);
  }

  /// Handle notification opened (user tapped on notification)
  void _handleNotificationOpened(OSNotificationClickEvent event) {
    if (kDebugMode) {
      debugPrint('Notification opened: ${event.notification.notificationId}');
    }

    final additionalData = event.notification.additionalData;
    if (additionalData != null) {
      // Handle navigation based on notification data
      _handleNotificationNavigation(additionalData);
    }
  }

  /// Handle notification received in foreground
  void _handleNotificationReceived(OSNotificationWillDisplayEvent event) {
    if (kDebugMode) {
      debugPrint('Notification received: ${event.notification.notificationId}');
    }

    // Show the notification
    event.notification.display();
  }

  /// Handle navigation based on notification data
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    if (kDebugMode) {
      debugPrint('Notification data: $data');
    }

    // Navigation logic will be implemented in the app
    // This is a placeholder for the navigation handler
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    if (type == null || id == null) return;

    // TODO: Implement navigation based on type
    // Example:
    // - type: 'notice' -> Navigate to notice detail
    // - type: 'message' -> Navigate to message thread
    // - type: 'announcement' -> Navigate to announcements
  }

  /// Send a notification (requires REST API key - server-side only)
  /// This is just documentation - actual sending should be done from Edge Functions
  static String getSendNotificationExample() {
    return r'''
// Example: Send notification from Supabase Edge Function
const sendNotification = async (userIds: string[], title: string, message: string, data: any) => {
  const response = await fetch('https://onesignal.com/api/v1/notifications', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Basic ${Deno.env.get('ONESIGNAL_REST_API_KEY')}`,
    },
    body: JSON.stringify({
      app_id: Deno.env.get('ONESIGNAL_APP_ID'),
      include_external_user_ids: userIds,
      headings: { en: title },
      contents: { en: message },
      data: data,
    }),
  });
  
  return await response.json();
};
''';
  }
}
