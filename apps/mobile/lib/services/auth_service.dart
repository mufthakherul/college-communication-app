import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';
import 'package:campus_mesh/models/user_model.dart';
import 'package:campus_mesh/services/appwrite_service.dart';
import 'package:campus_mesh/appwrite_config.dart';
import 'package:campus_mesh/utils/input_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_mesh/services/ai_chatbot_service.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _appwrite = AppwriteService();
  static const String _userIdKey = 'current_user_id';

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

      // Save to local storage for quick access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, user.$id);

      // Session exists, user is authenticated
      debugPrint('Session restored for user: ${user.$id}');
    } catch (e) {
      // No active session, try to load from local storage
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedUserId = prefs.getString(_userIdKey);
        if (cachedUserId != null) {
          debugPrint(
            'Found cached user ID: $cachedUserId, but no active session',
          );
        }
      } catch (storageError) {
        debugPrint('Error accessing local storage: $storageError');
      }
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
    // Input validation
    if (!InputValidator.isValidEmail(email)) {
      throw Exception('invalid-email: Please enter a valid email address.');
    }

    if (password.isEmpty || password.length < 6) {
      throw Exception(
          'invalid-password: Password must be at least 6 characters.');
    }

    // Ensure Appwrite is initialized
    if (!_appwrite.isInitialized) {
      debugPrint('⚠️ Appwrite not initialized, initializing now...');
      _appwrite.init();
    }

    try {
      debugPrint('🔐 Attempting sign in for email: $email');
      final session = await _appwrite.account.createEmailPasswordSession(
        email: email.trim().toLowerCase(),
        password: password,
      );
      _currentUserId = session.userId;
      debugPrint('✅ Sign in successful for user: ${session.userId}');
      return session.userId;
    } on AppwriteException catch (e) {
      debugPrint('❌ Sign in failed: ${e.message} (Code: ${e.code})');

      // Provide user-friendly error messages
      if (e.code == 401 || e.message?.contains('Invalid credentials') == true) {
        throw Exception('invalid-credentials: Invalid email or password.');
      } else if (e.message?.contains('network') == true || e.code == 0) {
        throw Exception('network: Please check your internet connection.');
      } else if (e.message?.contains('user') == true &&
          e.message?.contains('blocked') == true) {
        throw Exception('user-blocked: This account has been disabled.');
      }

      throw Exception('Failed to sign in: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      debugPrint('❌ Unexpected sign in error: $e');
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
    // Input validation
    if (!InputValidator.isValidEmail(email)) {
      throw Exception('invalid-email: Please enter a valid email address.');
    }

    final passwordError = InputValidator.validatePassword(password);
    if (passwordError != null) {
      throw Exception('weak-password: $passwordError');
    }

    final sanitizedName = InputValidator.sanitizeName(displayName);
    if (sanitizedName == null || sanitizedName.isEmpty) {
      throw Exception('invalid-name: Please enter a valid name.');
    }

    if (!InputValidator.isValidPhone(phoneNumber)) {
      throw Exception('invalid-phone: Please enter a valid phone number.');
    }

    // Ensure Appwrite is initialized
    if (!_appwrite.isInitialized) {
      debugPrint('⚠️ Appwrite not initialized, initializing now...');
      _appwrite.init();
    }

    try {
      debugPrint('📝 Starting registration for email: $email');

      // Create account
      final user = await _appwrite.account.create(
        userId: ID.unique(),
        email: email.trim().toLowerCase(),
        password: password,
        name: sanitizedName,
      );
      debugPrint('✅ Account created with ID: ${user.$id}');

      // Create session
      debugPrint('🔐 Creating session...');
      await _appwrite.account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      debugPrint('✅ Session created');

      _currentUserId = user.$id;

      // Create user profile in database
      try {
        debugPrint('💾 Creating user profile in database...');
        await _appwrite.databases.createDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.usersCollectionId,
          documentId: user.$id,
          data: {
            'email': email.trim().toLowerCase(),
            'display_name': sanitizedName,
            'phone_number': phoneNumber.trim(),
            'role': 'student', // Default role
            'is_active': true,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          },
        );
        debugPrint('✅ User profile created successfully');
      } catch (dbError) {
        debugPrint('❌ Profile creation error: $dbError');

        // If profile creation fails, delete the account to maintain consistency
        try {
          debugPrint(
              '🗑️ Cleaning up account due to profile creation failure...');
          await _appwrite.account.deleteSession(sessionId: 'current');
        } catch (cleanupError) {
          debugPrint('⚠️ Cleanup error: $cleanupError');
        }

        // Provide specific error messages
        if (dbError.toString().contains('document_already_exists')) {
          throw Exception(
            'An account with this email already exists. '
            'Please sign in instead.',
          );
        } else if (dbError.toString().contains('collection_not_found')) {
          throw Exception(
            'Database configuration error. '
            'Please contact support with error: Collection not found.',
          );
        } else if (dbError.toString().contains('document_invalid_structure') ||
            dbError.toString().contains('Unknown attribute')) {
          throw Exception(
            'Database not configured. '
            'Please ensure all required attributes are created '
            'in the users collection. '
            'See APPWRITE_DATABASE_QUICKSTART.md for setup instructions.',
          );
        } else if (dbError.toString().contains('unauthorized')) {
          throw Exception('Database permission error. Please contact support.');
        }

        throw Exception(
          'Failed to create user profile. Error: '
          '${dbError.toString().length > 100 ? dbError.toString().substring(0, 100) : dbError}',
        );
      }

      debugPrint(
          '🎉 Registration completed successfully for user: ${user.$id}');
      return user.$id;
    } on AppwriteException catch (e) {
      debugPrint('❌ Appwrite exception during registration: ${e.message}');
      debugPrint('   Code: ${e.code}, Type: ${e.type}');

      // Provide user-friendly error messages
      if (e.code == 409 || e.message?.contains('already exists') == true) {
        throw Exception(
            'email-already-in-use: This email is already registered.');
      } else if (e.code == 400 && e.message?.contains('password') == true) {
        throw Exception(
            'weak-password: Password must be at least 8 characters.');
      } else if (e.message?.contains('network') == true || e.code == 0) {
        throw Exception(
            'network: Please check your internet connection and try again.');
      }

      throw Exception('Failed to register: ${e.message ?? 'Unknown error'}');
    } catch (e) {
      debugPrint('❌ Unexpected error during registration: $e');
      throw Exception('Failed to register: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _appwrite.account.deleteSession(sessionId: 'current');
      _currentUserId = null;

      // Clear from local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);

      // Clear AI chatbot API key (but keep chat history)
      // User will need to re-enter API key after login
      try {
        final aiService = AIChatbotService();
        await aiService.clearApiKey();
      } catch (e) {
        debugPrint('Failed to clear AI API key: $e');
      }
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
      // Ensure we have a valid session first
      if (_currentUserId == null) {
        // Try to get current user from Appwrite without full initialization
        try {
          final user = await _appwrite.account.get();
          _currentUserId = user.$id;
        } catch (e) {
          throw Exception('No user signed in. Please log in again.');
        }
      }

      await _appwrite.databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: _currentUserId!,
        data: {...updates, 'updated_at': DateTime.now().toIso8601String()},
      );
    } on AppwriteException catch (e) {
      // Handle session expiry specifically
      if (e.code == 401) {
        _currentUserId = null;
        throw Exception('Session expired. Please log in again.');
      }
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
      // Email verification status is tracked by Appwrite Auth, not in user profile
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
