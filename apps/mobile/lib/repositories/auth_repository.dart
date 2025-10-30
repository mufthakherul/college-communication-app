import '../models/user_model.dart';

/// Abstract repository interface for authentication operations.
/// 
/// This interface defines all authentication-related operations without
/// specifying the implementation details. This allows for easy migration
/// to different authentication providers (Firebase, Supabase, custom backend, etc.)
/// without changing the UI or business logic.
/// 
/// Implementation examples:
/// - [FirebaseAuthRepository] - Uses Firebase Authentication
/// - [MockAuthRepository] - Uses local mock data for testing/demo
abstract class AuthRepository {
  /// Get the currently authenticated user ID.
  /// Returns null if no user is authenticated.
  String? get currentUserId;

  /// Stream that emits the current user ID whenever auth state changes.
  /// Emits null when user signs out.
  Stream<String?> get authStateChanges;

  /// Sign in with email and password.
  /// 
  /// Returns the user ID on success.
  /// Throws [AuthException] on failure.
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Register a new user with email and password.
  /// 
  /// Returns the user ID on success.
  /// Throws [AuthException] on failure.
  Future<String> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign out the current user.
  /// 
  /// Throws [AuthException] on failure.
  Future<void> signOut();

  /// Send password reset email to the given email address.
  /// 
  /// Throws [AuthException] on failure.
  Future<void> sendPasswordResetEmail(String email);

  /// Get user profile data from the database.
  /// 
  /// Returns null if user profile doesn't exist.
  /// Throws [AuthException] on failure.
  Future<UserModel?> getUserProfile(String uid);

  /// Create or update user profile in the database.
  /// 
  /// Throws [AuthException] on failure.
  Future<void> saveUserProfile(UserModel user);

  /// Update specific fields in user profile.
  /// 
  /// Throws [AuthException] on failure.
  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates);

  /// Delete user account and associated data.
  /// 
  /// Throws [AuthException] on failure.
  Future<void> deleteUserAccount(String uid);
}

/// Exception thrown by auth repository operations.
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, [this.code]);

  @override
  String toString() => code != null ? 'AuthException [$code]: $message' : 'AuthException: $message';
}
