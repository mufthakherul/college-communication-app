// ignore_for_file: do_not_use_environment
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:campus_mesh/screens/auth/login_screen.dart';
import 'package:campus_mesh/screens/home_screen.dart';
import 'package:campus_mesh/services/appwrite_service.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/services/background_sync_service.dart';
import 'package:campus_mesh/services/cache_service.dart';
import 'package:campus_mesh/services/mesh_message_sync_service.dart';
import 'package:campus_mesh/services/offline_message_sync_service.dart';
import 'package:campus_mesh/services/offline_queue_service.dart';
import 'package:campus_mesh/services/onesignal_service.dart';
import 'package:campus_mesh/services/security_service.dart';
import 'package:campus_mesh/services/sentry_service.dart';
import 'package:campus_mesh/services/theme_service.dart';

/// Initialize essential services that are required for basic app functionality
Future<void> _initializeEssentialServices() async {
  // Initialize cache first - needed by many other services
  await CacheService().initialize();

  // Initialize auth service (required for most features)
  try {
    await AuthService().initialize();
  } catch (e) {
    debugPrint('Failed to initialize auth service: $e');
    // Continue without auth - will show login screen
  }

  // Initialize crash reporting in release mode
  if (kReleaseMode) {
    try {
      const sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');
      if (sentryDsn.isNotEmpty) {
        await SentryService.initialize(
          dsn: sentryDsn,
          environment: 'production',
          release: 'campus_mesh@2.0.0+2',
          tracesSampleRate: 0.2,
        );
      }
    } catch (e) {
      debugPrint('Failed to initialize Sentry: $e');
    }
  }
}

void main() {
  // Wrap in error zone to catch all errors including async ones
  runZonedGuarded(() async {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      // Log to crash reporting
      if (kReleaseMode) {
        SentryService().captureException(details.exception, stackTrace: details.stack);
      }
    };
    
    await _initializeApp();
  }, (error, stack) {
    debugPrint('Fatal error: $error');
    debugPrint('Stack trace: $stack');
    if (kReleaseMode) {
      SentryService().captureException(error, stackTrace: stack);
    }
    // If initialization fails catastrophically, show error screen
    debugPrint('Fatal initialization error: $error');
    debugPrint('Stack trace: $stack');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 80, color: Colors.red),
                  const SizedBox(height: 24),
                  const Text(
                    'Initialization Error',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'The app encountered an error during startup. Please reinstall the app or contact support.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 16),
                    SelectableText(
                      'Error: $error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  });
}

Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // STARTUP: Handle initialization sequentially to avoid race conditions
  try {
    debugPrint('Initializing essential services...');
    await _initializeEssentialServices();
  } catch (e, stack) {
    debugPrint('Failed to initialize essential services: $e\n$stack');
    // Allow continuing with basic functionality
  }

  // SECURITY: Perform security checks on startup
  if (kReleaseMode) {
    try {
      // Load bare minimum cache and security services first
      await CacheService().initialize();
      
      final securityService = SecurityService();
      final securityResult = await securityService.performSecurityChecks();

      if (!securityService.shouldAllowAppExecution(securityResult)) {
        // Critical security issue detected - show error and exit
        runApp(
          SecurityBlockedApp(
            message: securityService.getSecurityWarningMessage(securityResult),
          ),
        );
        return;
      }

      // Log security warnings but allow execution
      if (!securityResult.allChecksPassed) {
        debugPrint(
          'Security warning: ${securityService.getSecurityWarningMessage(securityResult)}',
        );
      }
    } catch (e) {
      debugPrint('Security check failed: $e');
      // Continue app execution - fail open for user experience
      // Production deployments should monitor these errors
    }
  }

  // Initialize Sentry (crash reporting)
  // Replace 'YOUR_SENTRY_DSN' with your actual Sentry DSN
  // Get it from: https://sentry.io/settings/YOUR_ORG/projects/YOUR_PROJECT/keys/
  const sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '', // Empty by default - configure via --dart-define
  );

  if (sentryDsn.isNotEmpty) {
    try {
      await SentryService.initialize(
        dsn: sentryDsn,
        environment: kReleaseMode ? 'production' : 'development',
        release: 'campus_mesh@2.0.0+2',
        tracesSampleRate: kReleaseMode ? 0.2 : 1.0, // Sample 20% in production
      );
    } catch (e) {
      debugPrint('Failed to initialize Sentry: $e');
      // Continue app execution even if Sentry fails
    }
  }

  // Initialize Appwrite - CRITICAL: Must be done before any service uses it
  try {
    debugPrint('🚀 Starting Appwrite initialization...');
    AppwriteService().init();
    debugPrint('✅ Appwrite initialization complete');
  } catch (e, stackTrace) {
    debugPrint('❌ CRITICAL: Failed to initialize Appwrite: $e');
    debugPrint('Stack trace: $stackTrace');
    // Show error to user - app cannot function without backend
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, size: 80, color: Colors.red),
                  const SizedBox(height: 24),
                  const Text(
                    'Backend Connection Error',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cannot connect to backend services. Please check your internet connection and try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 16),
                    SelectableText(
                      'Error: $e',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }

  // Initialize auth service
  try {
    await AuthService().initialize();
  } catch (e) {
    debugPrint('Failed to initialize auth service: $e');
    // Continue without auth - will show login screen
  }

  // Initialize OneSignal (push notifications)
  // Replace 'YOUR_ONESIGNAL_APP_ID' with your actual OneSignal App ID
  // Get it from: https://app.onesignal.com/apps/YOUR_APP_ID/settings
  const oneSignalAppId = String.fromEnvironment(
    'ONESIGNAL_APP_ID',
    defaultValue: '', // Empty by default - configure via --dart-define
  );

  if (oneSignalAppId.isNotEmpty) {
    try {
      await OneSignalService().initialize(oneSignalAppId);
    } catch (e) {
      debugPrint('Failed to initialize OneSignal: $e');
      // Continue app execution even if OneSignal fails
    }
  }

  // Load theme preference
  try {
    await ThemeService().loadThemePreference();
  } catch (e) {
    debugPrint('Failed to load theme preference: $e');
    // Continue with default theme
  }

  // Initialize cache service
  try {
    await CacheService().initialize();
  } catch (e) {
    debugPrint('Failed to initialize cache service: $e');
    // Continue without cache
  }

  // Load offline queue
  try {
    final offlineQueueService = OfflineQueueService();
    await offlineQueueService.loadQueue();
    await offlineQueueService.loadAnalytics();
  } catch (e) {
    debugPrint('Failed to initialize offline queue: $e');
    // Continue without offline queue
  }

  // Initialize background sync
  try {
    final backgroundSyncService = BackgroundSyncService();
    await backgroundSyncService.initialize();
    await backgroundSyncService.registerOfflineQueueSync();
    await backgroundSyncService.registerCacheCleanup();
  } catch (e) {
    debugPrint('Failed to initialize background sync: $e');
    // Continue without background sync
  }

  // Initialize offline message sync
  try {
    final offlineMessageSyncService = OfflineMessageSyncService();
    await offlineMessageSyncService.initialize();
  } catch (e) {
    debugPrint('Failed to initialize offline message sync: $e');
    // Continue without offline message sync
  }

  // Initialize mesh message sync (P2P when nearby) - Deferred until after app start
  Future.microtask(() async {
    try {
      final meshSync = MeshMessageSyncService();
      await meshSync.initialize();
    } catch (e) {
      debugPrint('Failed to initialize mesh message sync: $e');
    }
  });

  // Start the app UI first, then initialize remaining services
  runApp(const CampusMeshApp());
}

class CampusMeshApp extends StatefulWidget {
  const CampusMeshApp({super.key});

  @override
  State<CampusMeshApp> createState() => _CampusMeshAppState();
}

class _CampusMeshAppState extends State<CampusMeshApp> {
  final _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RPI Communication',
      debugShowCheckedModeBanner: false,
      theme: ThemeService.lightTheme,
      darkTheme: ThemeService.darkTheme,
      themeMode: _themeService.themeMode,
      builder: (context, child) {
        // Show debug banner in debug mode
        if (kDebugMode && child != null) {
          return Banner(
            message: 'DEBUG',
            location: BannerLocation.topEnd,
            child: child,
          );
        }
        return child ?? const SizedBox.shrink();
      },
      home: FutureBuilder<bool>(
        future: AuthService().isAuthenticated(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final isAuthenticated = snapshot.data ?? false;
          if (isAuthenticated) {
            return const HomeScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}

/// Security blocked app - shown when critical security checks fail
class SecurityBlockedApp extends StatelessWidget {
  const SecurityBlockedApp({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Security Alert',
      debugShowCheckedModeBanner: false,
      theme: ThemeService.lightTheme,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                const Text(
                  'Security Alert',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SelectableText(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Please download the official app from trusted sources.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
