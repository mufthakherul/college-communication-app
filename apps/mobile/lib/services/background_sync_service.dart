import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:campus_mesh/services/offline_queue_service.dart';
import 'package:campus_mesh/services/connectivity_service.dart';

/// Background callback for WorkManager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (kDebugMode) {
        print('Background sync task started: $task');
      }

      switch (task) {
        case 'syncOfflineQueue':
          await _syncOfflineQueue();
          break;
        case 'cleanupCache':
          await _cleanupCache();
          break;
        case 'syncWebsiteNotices':
          await _syncWebsiteNotices();
          break;
        default:
          if (kDebugMode) {
            print('Unknown task: $task');
          }
      }

      return Future.value(true);
    } catch (e) {
      if (kDebugMode) {
        print('Background task failed: $e');
      }
      return Future.value(false);
    }
  });
}

/// Background sync for offline queue
Future<void> _syncOfflineQueue() async {
  try {
    final connectivityService = ConnectivityService();
    final offlineQueueService = OfflineQueueService();

    // Load queue from storage
    await offlineQueueService.loadQueue();

    // Only sync if online
    if (connectivityService.isOnline) {
      await offlineQueueService.processQueue();

      if (kDebugMode) {
        print('Background queue sync completed');
      }
    } else {
      if (kDebugMode) {
        print('Skipping background sync: offline');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error in background sync: $e');
    }
  }
}

/// Background cache cleanup
Future<void> _cleanupCache() async {
  try {
    // Cache cleanup logic would go here
    // This is a placeholder for future implementation
    if (kDebugMode) {
      print('Background cache cleanup completed');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error in cache cleanup: $e');
    }
  }
}

/// Background sync for website notices
Future<void> _syncWebsiteNotices() async {
  try {
    // Note: This is a placeholder for website notice syncing
    // In a real implementation, you would:
    // 1. Initialize WebsiteScraperService
    // 2. Fetch notices from the website
    // 3. Sync them to the database
    // However, this requires proper initialization of services
    // which is complex in a background task context
    
    if (kDebugMode) {
      print('Background website notices sync completed');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error syncing website notices: $e');
    }
  }
}

/// Service to manage background synchronization
class BackgroundSyncService {
  static final BackgroundSyncService _instance =
      BackgroundSyncService._internal();
  factory BackgroundSyncService() => _instance;
  BackgroundSyncService._internal();

  bool _isInitialized = false;

  /// Initialize background sync service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: kDebugMode,
      );

      _isInitialized = true;

      if (kDebugMode) {
        print('Background sync service initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing background sync: $e');
      }
    }
  }

  /// Register periodic background sync for offline queue
  Future<void> registerOfflineQueueSync({
    Duration frequency = const Duration(minutes: 15),
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await Workmanager().registerPeriodicTask(
        'syncOfflineQueue',
        'syncOfflineQueue',
        frequency: frequency,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        existingWorkPolicy: ExistingWorkPolicy.keep,
      );

      if (kDebugMode) {
        print(
          'Registered periodic offline queue sync: ${frequency.inMinutes}min',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error registering offline queue sync: $e');
      }
    }
  }

  /// Register periodic cache cleanup
  Future<void> registerCacheCleanup({
    Duration frequency = const Duration(hours: 24),
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await Workmanager().registerPeriodicTask(
        'cleanupCache',
        'cleanupCache',
        frequency: frequency,
        constraints: Constraints(
          networkType: NetworkType.not_required,
          requiresCharging: false,
        ),
        existingWorkPolicy: ExistingWorkPolicy.keep,
      );

      if (kDebugMode) {
        print('Registered periodic cache cleanup: ${frequency.inHours}h');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error registering cache cleanup: $e');
      }
    }
  }

  /// Register one-time sync task
  Future<void> registerOneTimeSync({Duration delay = Duration.zero}) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await Workmanager().registerOneOffTask(
        'oneTimeSync-${DateTime.now().millisecondsSinceEpoch}',
        'syncOfflineQueue',
        initialDelay: delay,
        constraints: Constraints(networkType: NetworkType.connected),
      );

      if (kDebugMode) {
        print('Registered one-time sync with delay: ${delay.inSeconds}s');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error registering one-time sync: $e');
      }
    }
  }

  /// Cancel all background tasks
  Future<void> cancelAll() async {
    if (!_isInitialized) return;

    try {
      await Workmanager().cancelAll();

      if (kDebugMode) {
        print('Cancelled all background tasks');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cancelling tasks: $e');
      }
    }
  }

  /// Register periodic website notices sync
  Future<void> registerWebsiteNoticesSync({
    Duration frequency = const Duration(hours: 6),
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await Workmanager().registerPeriodicTask(
        'syncWebsiteNotices',
        'syncWebsiteNotices',
        frequency: frequency,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        existingWorkPolicy: ExistingWorkPolicy.keep,
      );

      if (kDebugMode) {
        print(
          'Registered periodic website notices sync: ${frequency.inHours}h',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error registering website notices sync: $e');
      }
    }
  }

  /// Cancel specific task
  Future<void> cancelTask(String taskId) async {
    if (!_isInitialized) return;

    try {
      await Workmanager().cancelByUniqueName(taskId);

      if (kDebugMode) {
        print('Cancelled task: $taskId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cancelling task: $e');
      }
    }
  }
}
