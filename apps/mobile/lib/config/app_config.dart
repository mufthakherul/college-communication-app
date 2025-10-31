/// Application configuration management
/// Handles environment-specific settings and sensitive data

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Singleton pattern
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  /// Initialize configuration from environment file
  static Future<void> initialize({String? environment}) async {
    final envFile = environment != null ? '.env.$environment' : '.env';
    
    try {
      await dotenv.load(fileName: envFile);
    } catch (e) {
      // Fallback to default .env if specific environment file not found
      try {
        await dotenv.load(fileName: '.env');
      } catch (e) {
        // If .env also not found, use defaults (for demo mode)
        print('Warning: No .env file found, using default configuration');
      }
    }
  }

  // Supabase Configuration
  String get supabaseUrl => 
      dotenv.get('SUPABASE_URL', fallback: '');
  
  String get supabaseAnonKey => 
      dotenv.get('SUPABASE_ANON_KEY', fallback: '');

  // App Information
  String get appName => 
      dotenv.get('APP_NAME', fallback: 'RPI Communication');
  
  String get collegeName => 
      dotenv.get('COLLEGE_NAME', fallback: 'Rangpur Polytechnic Institute');
  
  String get collegeWebsite => 
      dotenv.get('COLLEGE_WEBSITE', fallback: 'https://rangpur.polytech.gov.bd');

  // Security Features
  bool get enableRootDetection => 
      dotenv.get('ENABLE_ROOT_DETECTION', fallback: 'false') == 'true';
  
  bool get enableTamperingDetection => 
      dotenv.get('ENABLE_TAMPERING_DETECTION', fallback: 'false') == 'true';
  
  bool get enableCertificatePinning => 
      dotenv.get('ENABLE_CERTIFICATE_PINNING', fallback: 'false') == 'true';

  // Feature Flags
  bool get enableDemoMode => 
      dotenv.get('ENABLE_DEMO_MODE', fallback: 'true') == 'true';
  
  bool get enableMeshNetwork => 
      dotenv.get('ENABLE_MESH_NETWORK', fallback: 'true') == 'true';
  
  bool get enableOfflineMode => 
      dotenv.get('ENABLE_OFFLINE_MODE', fallback: 'true') == 'true';
  
  bool get enableAnalytics => 
      dotenv.get('ENABLE_ANALYTICS', fallback: 'false') == 'true';

  // Analytics & Monitoring
  String? get sentryDsn => 
      dotenv.maybeGet('SENTRY_DSN');
  
  String? get oneSignalAppId => 
      dotenv.maybeGet('ONESIGNAL_APP_ID');

  // Environment
  String get environment => 
      dotenv.get('ENVIRONMENT', fallback: 'development');

  bool get isProduction => environment == 'production';
  bool get isDevelopment => environment == 'development';
  bool get isStaging => environment == 'staging';

  /// Check if Supabase is configured
  bool get isSupabaseConfigured {
    return supabaseUrl.isNotEmpty && 
           supabaseAnonKey.isNotEmpty &&
           !supabaseUrl.contains('YOUR_') &&
           !supabaseAnonKey.contains('YOUR_');
  }

  /// Check if analytics is configured
  bool get isAnalyticsConfigured {
    return enableAnalytics && 
           (sentryDsn != null && sentryDsn!.isNotEmpty);
  }

  /// Get configuration summary for debugging
  Map<String, dynamic> getSummary() {
    return {
      'environment': environment,
      'appName': appName,
      'collegeName': collegeName,
      'supabaseConfigured': isSupabaseConfigured,
      'securityFeatures': {
        'rootDetection': enableRootDetection,
        'tamperingDetection': enableTamperingDetection,
        'certificatePinning': enableCertificatePinning,
      },
      'features': {
        'demoMode': enableDemoMode,
        'meshNetwork': enableMeshNetwork,
        'offlineMode': enableOfflineMode,
        'analytics': enableAnalytics,
      },
      'analyticsConfigured': isAnalyticsConfigured,
    };
  }

  /// Validate configuration
  void validate() {
    if (isProduction) {
      if (!isSupabaseConfigured) {
        throw Exception(
          'Supabase must be configured in production environment. '
          'Please set SUPABASE_URL and SUPABASE_ANON_KEY in .env.production'
        );
      }
      
      if (!enableRootDetection) {
        print('Warning: Root detection is disabled in production');
      }
      
      if (!enableTamperingDetection) {
        print('Warning: Tampering detection is disabled in production');
      }
    }
  }
}
