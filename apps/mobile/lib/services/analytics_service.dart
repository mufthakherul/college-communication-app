import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Analytics service for tracking user activity and app usage
/// Integrates with Supabase Edge Functions for detailed analytics
class AnalyticsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Track generic activity
  Future<void> trackActivity(String action, Map<String, dynamic> metadata) async {
    try {
      await _supabase.functions.invoke(
        'track-activity',
        body: {
          'action': action,
          'metadata': metadata,
        },
      );
    } catch (e) {
      // Silently fail to not disrupt user experience
      if (kDebugMode) {
        debugPrint('Failed to track activity: $e');
      }
    }
  }

  // Track screen views
  Future<void> trackScreenView(String screenName) async {
    await trackActivity('screen_view', {'screen': screenName});
  }

  // Track notice views
  Future<void> trackNoticeView(String noticeId, String noticeTitle) async {
    await trackActivity('view_notice', {
      'noticeId': noticeId,
      'title': noticeTitle,
    });
  }

  // Track notice creation
  Future<void> trackNoticeCreated(String noticeId, String noticeType) async {
    await trackActivity('create_notice', {
      'noticeId': noticeId,
      'type': noticeType,
    });
  }

  // Track message sent
  Future<void> trackMessageSent(String recipientId, String messageType) async {
    await trackActivity('send_message', {
      'recipientId': recipientId,
      'type': messageType,
    });
  }

  // Track message read
  Future<void> trackMessageRead(String messageId) async {
    await trackActivity('read_message', {
      'messageId': messageId,
    });
  }

  // Track app launch
  Future<void> trackAppLaunch(String version, String platform) async {
    await trackActivity('app_launch', {
      'version': version,
      'platform': platform,
    });
  }

  // Track feature usage
  Future<void> trackFeatureUsage(String featureName, Map<String, dynamic>? params) async {
    await trackActivity('feature_usage', {
      'feature': featureName,
      ...?params,
    });
  }

  // Track errors (non-critical)
  Future<void> trackError(String errorType, String errorMessage) async {
    await trackActivity('error', {
      'type': errorType,
      'message': errorMessage,
    });
  }
}

/// Admin analytics service for generating reports
/// Requires admin role to access
class AdminAnalyticsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> generateUserActivityReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabase.functions.invoke(
        'generate-analytics',
        body: {
          'reportType': 'user_activity',
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to generate report');
      }

      return response.data['report'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to generate user activity report: $e');
    }
  }

  Future<Map<String, dynamic>> generateNoticesReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabase.functions.invoke(
        'generate-analytics',
        body: {
          'reportType': 'notices',
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to generate report');
      }

      return response.data['report'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to generate notices report: $e');
    }
  }

  Future<Map<String, dynamic>> generateMessagesReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabase.functions.invoke(
        'generate-analytics',
        body: {
          'reportType': 'messages',
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to generate report');
      }

      return response.data['report'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to generate messages report: $e');
    }
  }

  // Get real-time analytics from database views
  Future<List<Map<String, dynamic>>> getDailyActiveUsers(int days) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final response = await _supabase
          .from('daily_active_users')
          .select()
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String())
          .order('date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get daily active users: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getNoticeEngagement(int limit) async {
    try {
      final response = await _supabase
          .from('notice_engagement')
          .select()
          .limit(limit)
          .order('views', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get notice engagement: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMessageStatistics(int days) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final response = await _supabase
          .from('message_statistics')
          .select()
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String())
          .order('date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get message statistics: $e');
    }
  }
}
