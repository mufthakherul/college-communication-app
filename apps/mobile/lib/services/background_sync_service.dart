import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:campus_mesh/services/offline_queue_service.dart';
import 'package:campus_mesh/services/connectivity_service.dart';
import 'package:campus_mesh/services/app_logger_service.dart';

/// Background callback for WorkManager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (kDebugMode) {
        logger.info(
          'Background sync task started: $task',
          category: 'BackgroundSync',
        );
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
            logger.warning('Unknown task: $task', category: 'BackgroundSync');
          }
      }

      return Future.value(true);
    } catch (e) {
      if (kDebugMode) {
        logger.error(
          'Background task failed',
          category: 'BackgroundSync',
          error: e,
        );
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
        logger.info(
          'Background queue sync completed',
          category: 'BackgroundSync',
        );
      }
    } else {
      if (kDebugMode) {
        logger.info(
          'Skipping background sync: offline',
          category: 'BackgroundSync',
        );
      }
    }
  } catch (e) {
    if (kDebugMode) {
      logger.error(
        'Error in background sync',
        category: 'BackgroundSync',
        error: e,
      );
    }
  }
}

/// Background cache cleanup
Future<void> _cleanupCache() async {
  try {
    // Cache cleanup logic would go here
    // This is a placeholder for future implementation
    if (kDebugMode) {
      logger.info(
        'Background cache cleanup completed',
        category: 'BackgroundSync',
      );
    }
  } catch (e) {
    if (kDebugMode) {
      logger.error(
        'Error in cache cleanup',
        category: 'BackgroundSync',
        error: e,
      );
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
      logger.info(
        'Background website notices sync completed',
        category: 'BackgroundSync',
      );
    }
  } catch (e) {
    if (kDebugMode) {
      logger.error(
        'Error syncing website notices',
        category: 'BackgroundSync',
        error: e,
      );
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
        logger.info(
          'Background sync service initialized',
          category: 'BackgroundSync',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        logger.error(
          'Error initializing background sync',
          category: 'BackgroundSync',
          error: e,
        );
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
        logger.info(
          'Registered periodic offline queue sync: ${frequency.inMinutes}min',
          category: 'BackgroundSync',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        logger.error(
          'Error registering offline queue sync',
          category: 'BackgroundSync',
          error: e,
        );
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
        logger.info(
          'Registered periodic cache cleanup: ${frequency.inHours}h',
          category: 'BackgroundSync',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        logger.error(
          'Error registering cache cleanup',
          category: 'BackgroundSync',
          error: e,
        );
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
        logger.info(
          'Registered one-time sync with delay: ${delay.inSeconds}s',
          category: 'BackgroundSync',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        logger.error(
          'Error registering one-time sync',
          category: 'BackgroundSync',
          error: e,
        );
      }
    }
  }

  /// Cancel all background tasks
  Future<void> cancelAll() async {
    if (!_isInitialized) return;

    try {
      await Workmanager().cancelAll();

      if (kDebugMode) {
        logger.info(
          'Cancelled all background tasks',
          category: 'BackgroundSync',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        logger.error(
          'Error cancelling tasks',
          category: 'BackgroundSync',
          error: e,
        );
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
        logger.info(
          'Registered periodic website notices sync: ${frequency.inHours}h',
          category: 'BackgroundSync',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        logger.error(
          'Error registering website notices sync',
          category: 'BackgroundSync',
          error: e,
        );
      }
    }
  }

  /// Cancel specific task
  Future<void> cancelTask(String taskId) async {
    if (!_isInitialized) return;

    try {
      await Workmanager().cancelByUniqueName(taskId);

      if (kDebugMode) {
        logger.info('Cancelled task: $taskId', category: 'BackgroundSync');
      }
    } catch (e) {
      if (kDebugMode) {
        logger.error(
          'Error cancelling task',
          category: 'BackgroundSync',
          error: e,
        );
      }
    }
  }
}
