# Analytics & Monitoring Setup Guide

## Overview

This guide explains how to set up comprehensive analytics and crash reporting for the RPI Communication App using Supabase built-in features and third-party integrations.

## Table of Contents

1. [Supabase Built-in Analytics](#supabase-built-in-analytics)
2. [Custom Analytics with Edge Functions](#custom-analytics-with-edge-functions)
3. [Crash Reporting with Sentry](#crash-reporting-with-sentry)
4. [Performance Monitoring](#performance-monitoring)
5. [Push Notifications with OneSignal](#push-notifications-with-onesignal)

---

## Supabase Built-in Analytics

Supabase provides built-in analytics in the dashboard for free.

### What's Included

- **Database Activity:** Query performance, connections, transactions
- **API Usage:** Request counts, response times, errors
- **Storage Metrics:** Bandwidth, storage size, file operations
- **Auth Metrics:** Sign-ups, sign-ins, active users

### Accessing Analytics

1. Go to Supabase Dashboard
2. Select your project
3. Navigate to "Reports" section
4. View metrics for:
   - API requests
   - Database queries
   - Auth activity
   - Storage usage

### Custom Queries

Use PostgreSQL views for custom analytics:

```sql
-- Create view for daily active users
CREATE VIEW daily_active_users AS
SELECT 
  DATE(created_at) as date,
  COUNT(DISTINCT user_id) as active_users
FROM user_activity
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- Create view for notice engagement
CREATE VIEW notice_engagement AS
SELECT 
  n.id,
  n.title,
  n.type,
  COUNT(DISTINCT ua.user_id) as views,
  n.created_at
FROM notices n
LEFT JOIN user_activity ua ON ua.data->>'noticeId' = n.id::text
WHERE ua.activity_type = 'view_notice'
GROUP BY n.id, n.title, n.type, n.created_at
ORDER BY views DESC;

-- Create view for message statistics
CREATE VIEW message_statistics AS
SELECT 
  DATE(created_at) as date,
  type,
  COUNT(*) as count,
  SUM(CASE WHEN read = true THEN 1 ELSE 0 END) as read_count
FROM messages
GROUP BY DATE(created_at), type
ORDER BY date DESC;
```

---

## Custom Analytics with Edge Functions

We've implemented Edge Functions for detailed analytics.

### Available Analytics

#### 1. Track User Activity

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsService {
  final _supabase = Supabase.instance.client;

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
      debugPrint('Failed to track activity: $e');
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

  // Track message sent
  Future<void> trackMessageSent(String recipientId, String messageType) async {
    await trackActivity('send_message', {
      'recipientId': recipientId,
      'type': messageType,
    });
  }
}
```

#### 2. Generate Analytics Reports

```dart
class AdminAnalyticsService {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> generateUserActivityReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
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
  }

  Future<Map<String, dynamic>> generateNoticesReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _supabase.functions.invoke(
      'generate-analytics',
      body: {
        'reportType': 'notices',
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
    );

    return response.data['report'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> generateMessagesReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _supabase.functions.invoke(
      'generate-analytics',
      body: {
        'reportType': 'messages',
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      },
    );

    return response.data['report'] as Map<String, dynamic>;
  }
}
```

### Integration in App

Add to main.dart:

```dart
// Initialize analytics
final analytics = AnalyticsService();

// Track app launch
await analytics.trackActivity('app_launch', {
  'version': '1.0.0',
  'platform': Platform.operatingSystem,
});
```

Add to NavigatorObserver:

```dart
class AnalyticsNavigatorObserver extends NavigatorObserver {
  final AnalyticsService analytics;

  AnalyticsNavigatorObserver(this.analytics);

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      analytics.trackScreenView(route.settings.name!);
    }
  }
}
```

---

## Crash Reporting with Sentry

Sentry provides excellent crash reporting and error tracking.

### 1. Setup Sentry Account

1. Go to [sentry.io](https://sentry.io)
2. Create free account (10,000 errors/month free)
3. Create new Flutter project
4. Copy your DSN

### 2. Add Sentry to pubspec.yaml

```yaml
dependencies:
  sentry_flutter: ^7.14.0
```

### 3. Initialize Sentry

Update `main.dart`:

```dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN';
      options.environment = kReleaseMode ? 'production' : 'development';
      options.tracesSampleRate = 1.0; // 100% of transactions
      
      // Release tracking
      options.release = 'campus_mesh@1.0.0+1';
      
      // Before send callback to filter events
      options.beforeSend = (event, hint) {
        // Filter out demo mode errors
        if (event.tags?['demo_mode'] == 'true') {
          return null;
        }
        return event;
      };
    },
    appRunner: () => runApp(const CampusMeshApp()),
  );
}
```

### 4. Capture Errors

Automatic error capture:

```dart
// Errors are automatically captured
try {
  await riskyOperation();
} catch (e, stackTrace) {
  // Error will be sent to Sentry automatically
  rethrow;
}
```

Manual error capture:

```dart
import 'package:sentry_flutter/sentry_flutter.dart';

// Capture error manually
try {
  await operation();
} catch (e, stackTrace) {
  await Sentry.captureException(
    e,
    stackTrace: stackTrace,
    hint: Hint.withMap({'context': 'user_profile_update'}),
  );
}

// Capture message
await Sentry.captureMessage(
  'User completed onboarding',
  level: SentryLevel.info,
);
```

### 5. Add Context

Add user context:

```dart
Sentry.configureScope((scope) {
  scope.setUser(SentryUser(
    id: user.id,
    email: user.email,
    username: user.displayName,
  ));
  
  scope.setTag('user_role', user.role);
  scope.setTag('demo_mode', 'false');
});
```

### 6. Performance Monitoring

Track performance:

```dart
// Track transaction
final transaction = Sentry.startTransaction(
  'notice_load',
  'load',
);

try {
  await loadNotice();
  transaction.status = SpanStatus.ok();
} catch (e) {
  transaction.status = SpanStatus.internalError();
  rethrow;
} finally {
  await transaction.finish();
}

// Track span within transaction
final span = transaction.startChild('database_query');
try {
  await performQuery();
} finally {
  await span.finish();
}
```

---

## Performance Monitoring

### Built-in Monitoring

Use Supabase Dashboard:
1. Go to "Database" → "Performance"
2. View slow queries
3. Optimize with indexes

### Application Performance

Create performance service:

```dart
class PerformanceMonitoringService {
  final Map<String, DateTime> _startTimes = {};

  void startTrace(String name) {
    _startTimes[name] = DateTime.now();
  }

  Future<void> stopTrace(String name) async {
    if (!_startTimes.containsKey(name)) return;
    
    final duration = DateTime.now().difference(_startTimes[name]!);
    _startTimes.remove(name);

    // Log to analytics
    await AnalyticsService().trackActivity('performance_trace', {
      'name': name,
      'duration_ms': duration.inMilliseconds,
    });

    // Log to Sentry for slow operations
    if (duration.inMilliseconds > 1000) {
      await Sentry.captureMessage(
        'Slow operation: $name took ${duration.inMilliseconds}ms',
        level: SentryLevel.warning,
      );
    }
  }
}

// Usage
final perf = PerformanceMonitoringService();

perf.startTrace('load_notices');
await noticeService.getNotices();
await perf.stopTrace('load_notices');
```

---

## Push Notifications with OneSignal

OneSignal provides free push notifications (10,000 subscribers free).

### 1. Setup OneSignal

1. Go to [onesignal.com](https://onesignal.com)
2. Create free account
3. Create new app
4. Configure for Flutter (Android & iOS)
5. Get App ID

### 2. Add OneSignal to pubspec.yaml

```yaml
dependencies:
  onesignal_flutter: ^5.0.0
```

### 3. Configure OneSignal

Update `main.dart`:

```dart
import 'package:onesignal_flutter/onesignal_flutter.dart';

Future<void> initializeOneSignal() async {
  // Initialize OneSignal
  OneSignal.initialize('YOUR_ONESIGNAL_APP_ID');

  // Request permission
  await OneSignal.Notifications.requestPermission(true);

  // Set user tags
  final user = Supabase.instance.client.auth.currentUser;
  if (user != null) {
    OneSignal.login(user.id);
    OneSignal.User.addTags({
      'user_id': user.id,
      'email': user.email ?? '',
    });
  }

  // Handle notification clicked
  OneSignal.Notifications.addClickListener((event) {
    final data = event.notification.additionalData;
    if (data?['type'] == 'notice') {
      // Navigate to notice
      final noticeId = data?['noticeId'];
      // Handle navigation
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(...);
  await initializeOneSignal();
  runApp(const CampusMeshApp());
}
```

### 4. Send Notifications

Send from Edge Function or manually:

```typescript
// In send-notification Edge Function
const sendPushNotification = async (userIds: string[], title: string, message: string, data: any) => {
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
  })
  
  return await response.json()
}
```

---

## Cost Summary

| Service | Free Tier | Cost After |
|---------|-----------|------------|
| Supabase Analytics | Unlimited | N/A |
| Sentry | 10,000 errors/month | $26/month |
| OneSignal | 10,000 subscribers | $9/month |

**Recommendation:** Stay on free tiers for college use case.

---

## Best Practices

1. **Privacy:** Always get user consent before tracking
2. **Performance:** Don't track too frequently
3. **Storage:** Clean old analytics data regularly
4. **Testing:** Test analytics in development before production
5. **Monitoring:** Set up alerts for critical errors

## Support

- [Supabase Analytics Docs](https://supabase.com/docs/guides/platform/metrics)
- [Sentry Flutter Docs](https://docs.sentry.io/platforms/flutter/)
- [OneSignal Flutter Docs](https://documentation.onesignal.com/docs/flutter-sdk-setup)
