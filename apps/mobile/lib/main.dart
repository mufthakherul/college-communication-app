import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:campus_mesh/screens/auth/login_screen.dart';
import 'package:campus_mesh/screens/home_screen.dart';
import 'package:campus_mesh/services/theme_service.dart';
import 'package:campus_mesh/services/cache_service.dart';
import 'package:campus_mesh/services/offline_queue_service.dart';
import 'package:campus_mesh/services/background_sync_service.dart';
import 'package:campus_mesh/services/sentry_service.dart';
import 'package:campus_mesh/services/onesignal_service.dart';
import 'package:campus_mesh/services/appwrite_service.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/services/security_service.dart';

void main() async {
  // Wrap entire initialization in error handler
  try {
    await _initializeApp();
  } catch (e, stackTrace) {
    // If initialization fails catastrophically, show error screen
    debugPrint('Fatal initialization error: $e');
    debugPrint('Stack trace: $stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
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
                  Text(
                    'The app encountered an error during startup. Please reinstall the app or contact support.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 16),
                    Text(
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
  }
}

Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SECURITY: Perform security checks on startup
  if (kReleaseMode) {
    try {
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

  // Initialize Appwrite
  try {
    AppwriteService().init();
  } catch (e) {
    debugPrint('Failed to initialize Appwrite: $e');
    // Critical error - but continue to show error screen
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
  final String message;

  const SecurityBlockedApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Security Alert',
      debugShowCheckedModeBanner: false,
      theme: ThemeService.lightTheme,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
                Text(
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
