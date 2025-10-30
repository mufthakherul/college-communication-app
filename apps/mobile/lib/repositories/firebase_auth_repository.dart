import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

/// Firebase implementation of [AuthRepository].
/// 
/// This implementation uses Firebase Authentication for user authentication
/// and Cloud Firestore for storing user profile data.
/// 
/// Features:
/// - Email/password authentication
/// - Real-time auth state monitoring
/// - User profile management in Firestore
/// - Automatic error mapping to [AuthException]
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Stream<String?> get authStateChanges {
    return _auth.authStateChanges().map((user) => user?.uid);
  }

  @override
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw AuthException('Sign in failed: No user returned');
      }
      
      return credential.user!.uid;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to sign in: $e');
    }
  }

  @override
  Future<String> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create user account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('Registration failed: No user returned');
      }

      final user = credential.user!;

      // Update display name
      await user.updateDisplayName(displayName);

      // Create user profile in Firestore
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        role: UserRole.student, // Default role
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await saveUserProfile(userModel);

      return user.uid;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to register: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Failed to sign out: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to send password reset email: $e');
    }
  }

  @override
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (!doc.exists) {
        return null;
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw AuthException('Failed to get user profile: $e');
    }
  }

  @override
  Future<void> saveUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(
            user.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      throw AuthException('Failed to save user profile: $e');
    }
  }

  @override
  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AuthException('Failed to update user profile: $e');
    }
  }

  @override
  Future<void> deleteUserAccount(String uid) async {
    try {
      // Delete user profile from Firestore
      await _firestore.collection('users').doc(uid).delete();
      
      // Delete Firebase Auth account
      final user = _auth.currentUser;
      if (user != null && user.uid == uid) {
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to delete user account: $e');
    }
  }

  /// Maps Firebase Auth exceptions to [AuthException] with user-friendly messages.
  AuthException _mapFirebaseAuthException(FirebaseAuthException e) {
    String message;
    
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found with this email address';
        break;
      case 'wrong-password':
        message = 'Incorrect password';
        break;
      case 'invalid-email':
        message = 'Invalid email address';
        break;
      case 'user-disabled':
        message = 'This account has been disabled';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email';
        break;
      case 'weak-password':
        message = 'Password is too weak. Use at least 6 characters';
        break;
      case 'operation-not-allowed':
        message = 'This operation is not allowed';
        break;
      case 'invalid-credential':
        message = 'Invalid credentials provided';
        break;
      case 'requires-recent-login':
        message = 'Please sign in again to perform this action';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your connection';
        break;
      default:
        message = e.message ?? 'An authentication error occurred';
    }
    
    return AuthException(message, e.code);
  }
}
