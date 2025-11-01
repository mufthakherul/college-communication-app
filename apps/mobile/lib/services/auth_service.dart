import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';
import 'package:campus_mesh/models/user_model.dart';
import 'package:campus_mesh/services/appwrite_service.dart';
import 'package:campus_mesh/appwrite_config.dart';

class AuthService {
  final _appwrite = AppwriteService();

  // Get current user ID
  String? _currentUserId;
  String? get currentUserId => _currentUserId;

  // Get current user object
  Future<UserModel?> get currentUser async {
    if (_currentUserId == null) return null;
    try {
      return await getUserProfile(_currentUserId!);
    } catch (e) {
      return null;
    }
  }

  // Initialize and get current user
  Future<void> initialize() async {
    try {
      // Try to get current session from Appwrite
      final user = await _appwrite.account.get();
      _currentUserId = user.$id;

      // Session exists, user is authenticated
      debugPrint('Session restored for user: ${user.$id}');
    } catch (e) {
      // No active session
      _currentUserId = null;
      debugPrint('No active session found');
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _appwrite.isAuthenticated();
  }

  // Sign in with email and password
  Future<String> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final session = await _appwrite.account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      _currentUserId = session.userId;
      return session.userId;
    } on AppwriteException catch (e) {
      throw Exception('Failed to sign in: ${e.message}');
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Register with email and password
  Future<String> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    String phoneNumber,
  ) async {
    try {
      // Create account
      final user = await _appwrite.account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: displayName,
      );

      // Create session
      await _appwrite.account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      _currentUserId = user.$id;

      // Create user profile in database
      try {
        await _appwrite.databases.createDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.usersCollectionId,
          documentId: user.$id,
          data: {
            'email': email,
            'display_name': displayName,
            'phone_number': phoneNumber,
            'role': 'student', // Default role
            'is_active': true,
            'email_verified': false, // New field for email verification
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
        );
      } catch (dbError) {
        // If profile creation fails, delete the account
        try {
          await _appwrite.account.deleteSession(sessionId: 'current');
        } catch (_) {}

        // Log the specific error for debugging but show generic message to user
        if (kDebugMode) {
          debugPrint('Profile creation error: $dbError');
        }
        throw Exception(
          'Failed to create user profile. Please try again or contact support.',
        );
      }

      return user.$id;
    } on AppwriteException catch (e) {
      throw Exception('Failed to register: ${e.message}');
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _appwrite.account.deleteSession(sessionId: 'current');
      _currentUserId = null;
    } on AppwriteException catch (e) {
      throw Exception('Failed to sign out: ${e.message}');
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final document = await _appwrite.databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: uid,
      );

      return UserModel.fromJson(document.data);
    } on AppwriteException catch (e) {
      throw Exception('Failed to get user profile: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      if (_currentUserId == null) throw Exception('No user signed in');

      await _appwrite.databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: _currentUserId!,
        data: {...updates, 'updated_at': DateTime.now().toIso8601String()},
      );
    } on AppwriteException catch (e) {
      throw Exception('Failed to update user profile: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _appwrite.account.createRecovery(
        email: email,
        url:
            'https://rpi-communication.app/reset-password', // Update with your app URL
      );
    } on AppwriteException catch (e) {
      throw Exception('Failed to send password reset email: ${e.message}');
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _appwrite.account.createVerification(
        url: 'https://rpi-communication.app/verify-email',
      );
    } on AppwriteException catch (e) {
      throw Exception('Failed to send verification email: ${e.message}');
    } catch (e) {
      throw Exception('Failed to send verification email: $e');
    }
  }

  // Confirm email verification
  Future<void> confirmEmailVerification(String userId, String secret) async {
    try {
      await _appwrite.account.updateVerification(
        userId: userId,
        secret: secret,
      );

      // Update user profile to mark email as verified
      if (_currentUserId != null) {
        await updateUserProfile({'email_verified': true});
      }
    } on AppwriteException catch (e) {
      throw Exception('Failed to verify email: ${e.message}');
    } catch (e) {
      throw Exception('Failed to verify email: $e');
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    try {
      final user = await _appwrite.account.get();
      return user.emailVerification;
    } catch (e) {
      return false;
    }
  }
}
