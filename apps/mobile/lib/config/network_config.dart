/// Network configuration for the College Communication App.
/// Centralized configuration for all networking components.
library;

/// Network configuration class
class NetworkConfig {
  /// Connectivity settings
  static const Duration connectivityCheckInterval = Duration(seconds: 5);
  static const Duration networkQualityCheckInterval = Duration(seconds: 30);
  static const int connectivityRetryAttempts = 3;
  static const Duration connectivityRetryDelay = Duration(seconds: 2);

  /// Offline queue settings
  static const int maxQueueSize = 100;
  static const int maxRetries = 3;
  static const Duration queueExpiry = Duration(days: 7);
  static const List<int> retryDelaysSeconds = [1, 2, 4]; // Exponential backoff
  static const int queuePriority = 5; // Default priority (1-10 scale)

  /// Cache settings
  static const int maxCacheSizeMB = 50;
  static const Duration shortTTL = Duration(minutes: 5);
  static const Duration defaultTTL = Duration(hours: 1);
  static const Duration longTTL = Duration(days: 1);
  static const bool enableCompression = true;
  static const int compressionThresholdBytes = 1024; // 1KB

  /// Background sync settings
  static const Duration backgroundSyncInterval = Duration(minutes: 15);
  static const Duration cacheCleanupInterval = Duration(hours: 24);
  static const bool requiresBatteryNotLow = true;
  static const bool requiresNetworkConnected = true;

  /// Conflict resolution settings
  static const String defaultConflictStrategy = 'newerWins';
  static const bool enableOptimisticLocking = true;
  static const bool autoResolveConflicts = true;

  /// Mesh network settings
  static const Duration meshNodeTimeout = Duration(minutes: 5);
  static const Duration meshPairingTimeout = Duration(minutes: 5);
  static const int maxMeshConnections = 10;
  static const int meshMessageHistorySize = 1000;
  static const bool enableAutoConnect = true;
  static const bool enableHiddenNodes = true;

  /// Mesh connection ranges (approximate)
  static const double bluetoothRangeFeet = 30;
  static const double wifiDirectRangeFeet = 200;
  static const double wifiRouterRangeFeet = 300;

  /// WebRTC settings
  static const List<Map<String, String>> iceServers = [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
    {'urls': 'stun:stun2.l.google.com:19302'},
    {'urls': 'stun:stun3.l.google.com:19302'},
    {'urls': 'stun:stun4.l.google.com:19302'},
  ];

  static const Map<String, dynamic> webrtcDataChannelConfig = {
    'ordered': true,
    'maxRetransmitTime': 3000,
  };

  static const bool enableWebRTC = true;
  static const Duration webrtcConnectionTimeout = Duration(seconds: 30);
  static const int webrtcMaxPacketSize = 16384; // 16KB

  /// Message delivery settings
  static const Duration typingIndicatorTimeout = Duration(seconds: 10);
  static const Duration deliveryStatusPollInterval = Duration(seconds: 10);
  static const Duration messageRetentionPeriod = Duration(days: 30);
  static const bool enableDeliveryTracking = true;
  static const bool enableTypingIndicators = true;
  static const bool enableReadReceipts = true;

  /// Performance settings
  static const int maxConcurrentRequests = 5;
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration longRequestTimeout = Duration(seconds: 60);
  static const int maxRetryAttempts = 3;
  static const bool enableRequestDeduplication = true;

  /// Analytics settings
  static const bool enableNetworkAnalytics = true;
  static const Duration analyticsReportInterval = Duration(hours: 1);
  static const bool trackBandwidthUsage = true;
  static const bool trackConnectionQuality = true;

  /// Security settings
  static const bool requireEncryption = true;
  static const bool validateCertificates = true;
  static const Duration sessionTimeout = Duration(hours: 24);
  static const int maxLoginAttempts = 5;
  static const Duration loginLockoutDuration = Duration(minutes: 15);

  /// API endpoints (Appwrite - configured in appwrite_config.dart)
  // Note: These are legacy fields from Supabase migration
  // Use AppwriteConfig for actual API endpoints

  /// Feature flags
  static const bool enableMeshNetwork = true;
  static const bool enableOfflineMode = true;
  static const bool enableBackgroundSync = true;
  static const bool enableSmartCaching = true;
  static const bool enableConflictResolution = true;
  static const bool enableWebRTCSignaling = true;
  static const bool enableMessageDelivery = true;

  /// Network quality thresholds (in milliseconds)
  static const int excellentLatencyMs = 100;
  static const int goodLatencyMs = 300;
  static const int poorLatencyMs = 1000;

  /// Bandwidth thresholds (in Kbps)
  static const int minBandwidthKbps = 100;
  static const int goodBandwidthKbps = 1000;
  static const int excellentBandwidthKbps = 5000;

  /// Debug settings
  static const bool enableDebugLogging = true;
  static const bool enableNetworkTracing = false;
  static const bool enablePerformanceMonitoring = true;
  static const bool verboseLogging = false;

  /// Validate configuration
  static bool validate() {
    final errors = <String>[];

    // Validate queue settings
    if (maxQueueSize <= 0) {
      errors.add('maxQueueSize must be positive');
    }
    if (maxRetries < 0) {
      errors.add('maxRetries must be non-negative');
    }

    // Validate cache settings
    if (maxCacheSizeMB <= 0) {
      errors.add('maxCacheSizeMB must be positive');
    }

    // Validate mesh settings
    if (maxMeshConnections <= 0) {
      errors.add('maxMeshConnections must be positive');
    }

    // Validate timeouts
    if (requestTimeout.inMilliseconds <= 0) {
      errors.add('requestTimeout must be positive');
    }

    if (errors.isNotEmpty) {
      throw Exception('Network configuration errors: ${errors.join(", ")}');
    }

    return true;
  }

  /// Get configuration summary
  static Map<String, dynamic> getSummary() {
    return {
      'connectivity': {
        'checkInterval': connectivityCheckInterval.inSeconds,
        'retryAttempts': connectivityRetryAttempts,
      },
      'offlineQueue': {
        'maxSize': maxQueueSize,
        'maxRetries': maxRetries,
        'expiryDays': queueExpiry.inDays,
      },
      'cache': {
        'maxSizeMB': maxCacheSizeMB,
        'defaultTTLMinutes': defaultTTL.inMinutes,
        'compressionEnabled': enableCompression,
      },
      'meshNetwork': {
        'maxConnections': maxMeshConnections,
        'autoConnect': enableAutoConnect,
        'timeoutMinutes': meshNodeTimeout.inMinutes,
      },
      'webrtc': {
        'enabled': enableWebRTC,
        'iceServers': iceServers.length,
        'maxPacketSizeKB': webrtcMaxPacketSize ~/ 1024,
      },
      'messageDelivery': {
        'trackingEnabled': enableDeliveryTracking,
        'typingIndicators': enableTypingIndicators,
        'readReceipts': enableReadReceipts,
      },
      'performance': {
        'maxConcurrentRequests': maxConcurrentRequests,
        'requestTimeoutSeconds': requestTimeout.inSeconds,
      },
      'features': {
        'meshNetwork': enableMeshNetwork,
        'offlineMode': enableOfflineMode,
        'backgroundSync': enableBackgroundSync,
        'smartCaching': enableSmartCaching,
        'conflictResolution': enableConflictResolution,
        'webrtcSignaling': enableWebRTCSignaling,
      },
    };
  }

  /// Get feature flags
  static Map<String, bool> getFeatureFlags() {
    return {
      'meshNetwork': enableMeshNetwork,
      'offlineMode': enableOfflineMode,
      'backgroundSync': enableBackgroundSync,
      'smartCaching': enableSmartCaching,
      'conflictResolution': enableConflictResolution,
      'webrtcSignaling': enableWebRTCSignaling,
      'messageDelivery': enableMessageDelivery,
    };
  }

  /// Get environment-specific configuration
  static Map<String, dynamic> getEnvironmentConfig(String environment) {
    switch (environment) {
      case 'production':
        return {
          'debugLogging': false,
          'networkTracing': false,
          'verboseLogging': false,
          'maxCacheSizeMB': maxCacheSizeMB,
          'backgroundSyncInterval': backgroundSyncInterval,
        };
      case 'staging':
        return {
          'debugLogging': true,
          'networkTracing': false,
          'verboseLogging': false,
          'maxCacheSizeMB': maxCacheSizeMB ~/ 2,
          'backgroundSyncInterval': const Duration(minutes: 5),
        };
      case 'development':
        return {
          'debugLogging': true,
          'networkTracing': true,
          'verboseLogging': true,
          'maxCacheSizeMB': 10,
          'backgroundSyncInterval': const Duration(minutes: 1),
        };
      default:
        return {};
    }
  }

  /// Check if feature is enabled
  static bool isFeatureEnabled(String feature) {
    return getFeatureFlags()[feature] ?? false;
  }

  /// Get network quality threshold
  static String getNetworkQualityLevel(int latencyMs) {
    if (latencyMs < excellentLatencyMs) return 'excellent';
    if (latencyMs < goodLatencyMs) return 'good';
    if (latencyMs < poorLatencyMs) return 'poor';
    return 'bad';
  }

  /// Get recommended action for network quality
  static String getRecommendedAction(String quality) {
    switch (quality) {
      case 'excellent':
        return 'All features available';
      case 'good':
        return 'Normal operation';
      case 'poor':
        return 'Consider enabling offline mode';
      case 'bad':
        return 'Use offline mode or mesh network';
      default:
        return 'Check connection';
    }
  }
}

/// Network profile configurations for different scenarios
class NetworkProfiles {
  /// High performance profile
  static Map<String, dynamic> get highPerformance => {
        'maxConcurrentRequests': 10,
        'cacheSize': 100,
        'backgroundSync': const Duration(minutes: 5),
        'meshConnections': 20,
      };

  /// Balanced profile (default)
  static Map<String, dynamic> get balanced => {
        'maxConcurrentRequests': NetworkConfig.maxConcurrentRequests,
        'cacheSize': NetworkConfig.maxCacheSizeMB,
        'backgroundSync': NetworkConfig.backgroundSyncInterval,
        'meshConnections': NetworkConfig.maxMeshConnections,
      };

  /// Battery saver profile
  static Map<String, dynamic> get batterySaver => {
        'maxConcurrentRequests': 2,
        'cacheSize': 20,
        'backgroundSync': const Duration(hours: 1),
        'meshConnections': 3,
      };

  /// Offline first profile
  static Map<String, dynamic> get offlineFirst => {
        'maxConcurrentRequests': 1,
        'cacheSize': 50,
        'backgroundSync': const Duration(hours: 2),
        'meshConnections': 5,
        'aggressiveCaching': true,
      };

  /// Get profile by name
  static Map<String, dynamic> getProfile(String name) {
    switch (name) {
      case 'highPerformance':
        return highPerformance;
      case 'batterySaver':
        return batterySaver;
      case 'offlineFirst':
        return offlineFirst;
      default:
        return balanced;
    }
  }
}
