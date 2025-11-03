# Notification Service Improvements

## Current Implementation

The notification service uses polling with a 10-second interval to fetch notifications. This works but has some inefficiencies.

## Recommended Improvements for v2.1.0

### 1. Use Appwrite Realtime Subscriptions

Instead of polling every 10 seconds, use Appwrite's realtime subscriptions:

```dart
Stream<List<NotificationModel>> getNotifications({
  NotificationSource source = NotificationSource.all,
}) {
  final userId = _currentUserId;
  if (userId == null) {
    return Stream.value([]);
  }

  // Subscribe to realtime updates
  final subscription = _appwrite.realtime.subscribe([
    'databases.${AppwriteConfig.databaseId}.collections.${AppwriteConfig.notificationsCollectionId}.documents',
  ]);

  return subscription.stream.asyncMap((event) async {
    // Fetch updated notifications when changes occur
    return await _fetchNotifications(userId, source);
  });
}
```

### 2. Implement Exponential Backoff for Polling

If realtime subscriptions aren't suitable, use exponential backoff:

```dart
Stream<List<NotificationModel>> getNotifications({
  NotificationSource source = NotificationSource.all,
}) async* {
  final userId = _currentUserId;
  if (userId == null) {
    yield [];
    return;
  }

  int retryDelay = 10; // Start with 10 seconds
  const maxDelay = 60; // Max 60 seconds

  while (true) {
    try {
      final notifications = await _fetchAllNotifications(userId, source);
      yield notifications;
      
      // Reset delay on success
      retryDelay = 10;
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      yield [];
      
      // Increase delay on error (exponential backoff)
      retryDelay = (retryDelay * 1.5).toInt().clamp(10, maxDelay);
    }

    await Future.delayed(Duration(seconds: retryDelay));
  }
}
```

### 3. Batch Operations for Marking Read

When Appwrite adds batch operation support, update markAllAsRead:

```dart
Future<void> markAllAsRead() async {
  // Use batch operations for better performance
  await _appwrite.databases.batchUpdate(
    databaseId: AppwriteConfig.databaseId,
    collectionId: AppwriteConfig.notificationsCollectionId,
    updates: unreadNotifications.map((n) => {
      'documentId': n.id,
      'data': {'read': true},
    }).toList(),
  );
}
```

### 4. Add Notification Caching

Cache notifications locally to reduce API calls:

```dart
class NotificationCache {
  final SharedPreferences _prefs;
  static const _cacheKey = 'notifications_cache';
  static const _cacheDuration = Duration(minutes: 5);
  
  DateTime? _lastFetch;
  List<NotificationModel>? _cachedNotifications;
  
  Future<List<NotificationModel>> getOrFetch({
    required Future<List<NotificationModel>> Function() fetchFn,
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();
    
    if (!forceRefresh && 
        _cachedNotifications != null && 
        _lastFetch != null &&
        now.difference(_lastFetch!) < _cacheDuration) {
      return _cachedNotifications!;
    }
    
    final notifications = await fetchFn();
    _cachedNotifications = notifications;
    _lastFetch = now;
    
    // Persist to SharedPreferences
    await _saveToStorage(notifications);
    
    return notifications;
  }
}
```

### 5. Implement Push Notifications

For real-time notifications, integrate with OneSignal (already in dependencies):

```dart
class NotificationService {
  Future<void> initialize() async {
    // Initialize OneSignal
    await OneSignalService().initialize(oneSignalAppId);
    
    // Set up notification handlers
    OneSignal.shared.setNotificationWillShowInForegroundHandler((event) {
      // Handle notification when app is in foreground
      event.complete(event.notification);
    });
    
    OneSignal.shared.setNotificationOpenedHandler((openedResult) {
      // Handle notification tap
      _handleNotificationTap(openedResult.notification);
    });
  }
}
```

## Performance Metrics

Current implementation:
- Polls every 10 seconds
- ~360 API calls per hour per user
- High battery and data usage

With realtime subscriptions:
- Only fetches on actual changes
- ~1-10 API calls per hour per user
- 97% reduction in API calls

## Migration Plan

1. **v2.0.0**: Keep current polling implementation (stable)
2. **v2.1.0**: Add Appwrite realtime subscriptions
3. **v2.2.0**: Add local caching layer
4. **v2.3.0**: Full OneSignal push notification integration

## Benefits

- ⚡ **Faster**: Instant notifications via realtime or push
- 🔋 **Efficient**: Reduced battery drain
- 📡 **Less Data**: Fewer API calls
- 😊 **Better UX**: Real-time updates without polling
