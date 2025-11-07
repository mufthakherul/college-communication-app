// ignore_for_file: cascade_invocations
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Sentry crash reporting service
/// Provides error tracking and performance monitoring
class SentryService {
  factory SentryService() => _instance;
  SentryService._internal();
  // Singleton pattern
  static final SentryService _instance = SentryService._internal();

  /// Initialize Sentry
  /// Should be called in main() before runApp()
  static Future<void> initialize({
    required String dsn,
    String? environment,
    String? release,
    double tracesSampleRate = 1.0,
  }) async {
    await SentryFlutter.init((options) {
      options.dsn = dsn;
      options.environment =
          environment ?? (kReleaseMode ? 'production' : 'development');
      options.release = release ?? 'campus_mesh@1.0.0+1';
      options.tracesSampleRate = tracesSampleRate;

      // Enable auto session tracking
      options.enableAutoSessionTracking = true;

      // Set debug mode based on build mode
      options.debug = kDebugMode;

      // Filter events before sending
      options.beforeSend = (event, {hint}) {
        // Filter out demo mode errors
        if (event.tags?['demo_mode'] == 'true') {
          return null;
        }

        // Filter out development errors in production
        if (kReleaseMode && event.environment == 'development') {
          return null;
        }

        return event;
      };

      // Add breadcrumbs for better context
      options.maxBreadcrumbs = 100;
    });
  }

  /// Capture an exception manually
  Future<void> captureException(
    dynamic exception, {
    dynamic stackTrace,
    String? context,
    Map<String, dynamic>? extra,
  }) async {
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      hint: Hint.withMap({
        if (context != null) 'context': context,
        if (extra != null) ...extra,
      }),
    );
  }

  /// Capture a message
  Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? extra,
  }) async {
    await Sentry.captureMessage(
      message,
      level: level,
      hint: extra != null ? Hint.withMap(extra) : null,
    );
  }

  /// Set user context
  void setUser({
    required String id,
    String? email,
    String? username,
    Map<String, dynamic>? data,
  }) {
    Sentry.configureScope((scope) {
      scope.setUser(
        SentryUser(id: id, email: email, username: username, data: data),
      );
    });
  }

  /// Clear user context
  void clearUser() {
    Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }

  /// Set a tag
  void setTag(String key, String value) {
    Sentry.configureScope((scope) {
      scope.setTag(key, value);
    });
  }

  /// Set multiple tags
  void setTags(Map<String, String> tags) {
    Sentry.configureScope((scope) {
      tags.forEach((key, value) {
        scope.setTag(key, value);
      });
    });
  }

  /// Add breadcrumb
  void addBreadcrumb({
    required String message,
    String? category,
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? data,
  }) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category,
        level: level,
        data: data,
      ),
    );
  }

  /// Start a transaction for performance monitoring
  ISentrySpan startTransaction(
    String operation,
    String description, {
    Map<String, dynamic>? data,
  }) {
    final transaction = Sentry.startTransaction(
      operation,
      description,
      bindToScope: true,
    );

    if (data != null) {
      data.forEach(transaction.setData);
    }

    return transaction;
  }

  /// Measure a function's performance
  Future<T> measurePerformance<T>(
    String operation,
    String description,
    Future<T> Function() function,
  ) async {
    final transaction = startTransaction(operation, description);

    try {
      final result = await function();
      transaction.status = const SpanStatus.ok();
      return result;
    } catch (e) {
      transaction.status = const SpanStatus.internalError();
      rethrow;
    } finally {
      await transaction.finish();
    }
  }

  /// Track a screen view
  void trackScreenView(String screenName) {
    addBreadcrumb(
      message: 'Screen view: $screenName',
      category: 'navigation',
      level: SentryLevel.info,
    );
  }

  /// Track a user action
  void trackAction(String action, {Map<String, dynamic>? data}) {
    addBreadcrumb(
      message: action,
      category: 'user_action',
      level: SentryLevel.info,
      data: data,
    );
  }
}
