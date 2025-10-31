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
  WidgetsFlutterBinding.ensureInitialized();

  // SECURITY: Perform security checks on startup
  if (kReleaseMode) {
    final securityService = SecurityService();
    final securityResult = await securityService.performSecurityChecks();
    
    if (!securityService.shouldAllowAppExecution(securityResult)) {
      // Critical security issue detected - show error and exit
      runApp(SecurityBlockedApp(
        message: securityService.getSecurityWarningMessage(securityResult),
      ));
      return;
    }
    
    // Log security warnings but allow execution
    if (!securityResult.allChecksPassed) {
      debugPrint('Security warning: ${securityService.getSecurityWarningMessage(securityResult)}');
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
    await SentryService.initialize(
      dsn: sentryDsn,
      environment: kReleaseMode ? 'production' : 'development',
      release: 'campus_mesh@1.0.0+1',
      tracesSampleRate: kReleaseMode ? 0.2 : 1.0, // Sample 20% in production
    );
  }

  // Initialize Appwrite
  AppwriteService().init();
  
  // Initialize auth service
  await AuthService().initialize();

  // Initialize OneSignal (push notifications)
  // Replace 'YOUR_ONESIGNAL_APP_ID' with your actual OneSignal App ID
  // Get it from: https://app.onesignal.com/apps/YOUR_APP_ID/settings
  const oneSignalAppId = String.fromEnvironment(
    'ONESIGNAL_APP_ID',
    defaultValue: '', // Empty by default - configure via --dart-define
  );

  if (oneSignalAppId.isNotEmpty) {
    await OneSignalService().initialize(oneSignalAppId);
  }

  // Load theme preference
  await ThemeService().loadThemePreference();

  // Initialize cache service
  await CacheService().initialize();

  // Load offline queue
  final offlineQueueService = OfflineQueueService();
  await offlineQueueService.loadQueue();
  await offlineQueueService.loadAnalytics();

  // Initialize background sync
  final backgroundSyncService = BackgroundSyncService();
  await backgroundSyncService.initialize();
  await backgroundSyncService.registerOfflineQueueSync();
  await backgroundSyncService.registerCacheCleanup();

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

  const SecurityBlockedApp({
    super.key,
    required this.message,
  });

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
                const Icon(
                  Icons.security,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Security Alert',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
