import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:campus_mesh/appwrite_config.dart';

/// Appwrite service singleton for managing Appwrite SDK instances
class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;
  AppwriteService._internal();

  late Client client;
  late Account account;
  late Databases databases;
  late Storage storage;
  late Realtime realtime;

  bool _initialized = false;

  /// Initialize Appwrite client and services
  void init() {
    if (_initialized) return;

    client = Client()
        .setEndpoint(AppwriteConfig.endpoint)
        .setProject(AppwriteConfig.projectId);

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
    realtime = Realtime(client);

    _initialized = true;
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
