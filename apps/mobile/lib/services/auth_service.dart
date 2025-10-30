import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/firebase_auth_repository.dart';

/// Service layer for authentication operations.
/// 
/// This service uses the repository pattern to abstract away the
/// authentication implementation details. By default, it uses Firebase
/// Authentication, but can be configured to use any [AuthRepository]
/// implementation (e.g., mock repository for testing).
/// 
/// Benefits of this approach:
/// - Easy to switch authentication providers
/// - Easy to test with mock implementations
/// - Decouples UI from authentication backend
/// - Single source of truth for auth operations
class AuthService {
  final AuthRepository _repository;

  /// Create an AuthService with a specific repository.
  /// 
  /// If no repository is provided, uses [FirebaseAuthRepository] by default.
  AuthService({AuthRepository? repository})
      : _repository = repository ?? FirebaseAuthRepository();

  /// Get the current user ID.
  /// Returns null if no user is authenticated.
  String? get currentUserId => _repository.currentUserId;

  /// Stream that emits the current user ID whenever auth state changes.
  /// Emits null when user signs out.
  Stream<String?> get authStateChanges => _repository.authStateChanges;

  /// Sign in with email and password.
  /// 
  /// Returns the user ID on success.
  /// Throws [AuthException] on failure.
  Future<String> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Register a new user with email and password.
  /// 
  /// Returns the user ID on success.
  /// Throws [AuthException] on failure.
  Future<String> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    return await _repository.registerWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  /// Sign out the current user.
  /// 
  /// Throws [AuthException] on failure.
  Future<void> signOut() async {
    await _repository.signOut();
  }

  /// Get user profile data.
  /// 
  /// Returns null if user profile doesn't exist.
  /// Throws [AuthException] on failure.
  Future<UserModel?> getUserProfile(String uid) async {
    return await _repository.getUserProfile(uid);
  }

  /// Get the current user's profile.
  /// 
  /// Returns null if no user is signed in or profile doesn't exist.
  /// Throws [AuthException] on failure.
  Future<UserModel?> getCurrentUserProfile() async {
    final uid = currentUserId;
    if (uid == null) return null;
    return await getUserProfile(uid);
  }

  /// Update specific fields in the current user's profile.
  /// 
  /// Throws [AuthException] if no user is signed in or update fails.
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    final uid = currentUserId;
    if (uid == null) {
      throw AuthException('No user signed in');
    }
    await _repository.updateUserProfile(uid, updates);
  }

  /// Send password reset email.
  /// 
  /// Throws [AuthException] on failure.
  Future<void> resetPassword(String email) async {
    await _repository.sendPasswordResetEmail(email);
  }

  /// Delete the current user's account and all associated data.
  /// 
  /// Throws [AuthException] if no user is signed in or deletion fails.
  Future<void> deleteAccount() async {
    final uid = currentUserId;
    if (uid == null) {
      throw AuthException('No user signed in');
    }
    await _repository.deleteUserAccount(uid);
  }
}
