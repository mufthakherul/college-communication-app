import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:campus_mesh/appwrite_config.dart';
import 'package:flutter/foundation.dart';

/// Appwrite service singleton for managing Appwrite SDK instances
class AppwriteService {
  factory AppwriteService() {
    // Ensure initialization on every access in release mode
    if (!_instance._initialized) {
      debugPrint('WARNING: AppwriteService accessed before initialization!');
      _instance.init();
    }
    return _instance;
  }
  AppwriteService._internal();
  static final AppwriteService _instance = AppwriteService._internal();

  late Client client;
  late Account account;
  late Databases databases;
  late Storage storage;
  late Realtime realtime;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Initialize Appwrite client and services
  void init() {
    if (_initialized) {
      debugPrint('AppwriteService already initialized');
      return;
    }

    try {
      debugPrint(
        'Initializing Appwrite with endpoint: ${AppwriteConfig.endpoint}',
      );
      debugPrint('Project ID: ${AppwriteConfig.projectId}');

      client = Client()
          .setEndpoint(AppwriteConfig.endpoint)
          .setProject(AppwriteConfig.projectId)
          .setSelfSigned(status: false); // Ensure HTTPS is properly validated

      account = Account(client);
      databases = Databases(client);
      storage = Storage(client);
      realtime = Realtime(client);

      _initialized = true;
      debugPrint('✅ Appwrite initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to initialize Appwrite: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Appwrite initialization failed: $e');
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      await account.get();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get current user session
  Future<models.User?> getCurrentUser() async {
    try {
      return await account.get();
    } catch (e) {
      return null;
    }
  }
}
