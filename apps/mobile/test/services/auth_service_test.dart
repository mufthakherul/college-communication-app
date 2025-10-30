import 'package:flutter_test/flutter_test.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/repositories/mock_auth_repository.dart';
import 'package:campus_mesh/repositories/auth_repository.dart';

/// Unit tests for AuthService demonstrating the repository pattern.
/// 
/// These tests use MockAuthRepository to test authentication logic
/// without requiring Firebase or any network connection.
void main() {
  group('AuthService with MockRepository', () {
    late AuthService authService;

    setUp(() {
      // Create AuthService with mock repository for testing
      authService = AuthService(
        repository: MockAuthRepository(),
      );
    });

    test('should have no user signed in initially', () {
      expect(authService.currentUserId, isNull);
    });

    test('should sign in with valid demo credentials', () async {
      final userId = await authService.signInWithEmailAndPassword(
        'student@demo.com',
        'demo123',
      );

      expect(userId, isNotEmpty);
      expect(authService.currentUserId, equals(userId));
    });

    test('should throw AuthException with invalid email', () async {
      expect(
        () => authService.signInWithEmailAndPassword(
          'invalid@demo.com',
          'demo123',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('should throw AuthException with wrong password', () async {
      expect(
        () => authService.signInWithEmailAndPassword(
          'student@demo.com',
          'wrongpassword',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('should register new user successfully', () async {
      final userId = await authService.registerWithEmailAndPassword(
        'newuser@test.com',
        'password123',
        'Test User',
      );

      expect(userId, isNotEmpty);
      expect(authService.currentUserId, equals(userId));
    });

    test('should throw AuthException when registering duplicate email', () async {
      // Register first user
      await authService.registerWithEmailAndPassword(
        'duplicate@test.com',
        'password123',
        'User One',
      );

      // Try to register with same email
      expect(
        () => authService.registerWithEmailAndPassword(
          'duplicate@test.com',
          'password123',
          'User Two',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('should throw AuthException with weak password', () async {
      expect(
        () => authService.registerWithEmailAndPassword(
          'newuser@test.com',
          '123', // Too short
          'Test User',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('should sign out successfully', () async {
      // Sign in first
      await authService.signInWithEmailAndPassword(
        'student@demo.com',
        'demo123',
      );
      expect(authService.currentUserId, isNotNull);

      // Sign out
      await authService.signOut();
      expect(authService.currentUserId, isNull);
    });

    test('should get user profile after sign in', () async {
      final userId = await authService.signInWithEmailAndPassword(
        'student@demo.com',
        'demo123',
      );

      final profile = await authService.getUserProfile(userId);

      expect(profile, isNotNull);
      expect(profile?.email, equals('student@demo.com'));
      expect(profile?.displayName, equals('Demo Student'));
    });

    test('should get current user profile', () async {
      await authService.signInWithEmailAndPassword(
        'teacher@demo.com',
        'demo123',
      );

      final profile = await authService.getCurrentUserProfile();

      expect(profile, isNotNull);
      expect(profile?.email, equals('teacher@demo.com'));
      expect(profile?.displayName, equals('Demo Teacher'));
    });

    test('should return null for current profile when not signed in', () async {
      final profile = await authService.getCurrentUserProfile();
      expect(profile, isNull);
    });

    test('should update user profile', () async {
      final userId = await authService.signInWithEmailAndPassword(
        'student@demo.com',
        'demo123',
      );

      await authService.updateUserProfile({
        'department': 'Engineering',
        'year': '4th Year',
      });

      final profile = await authService.getUserProfile(userId);
      expect(profile?.department, equals('Engineering'));
      expect(profile?.year, equals('4th Year'));
    });

    test('should throw AuthException when updating without sign in', () async {
      expect(
        () => authService.updateUserProfile({'department': 'Engineering'}),
        throwsA(isA<AuthException>()),
      );
    });

    test('should send password reset email for existing user', () async {
      // Should not throw for existing user
      await authService.resetPassword('student@demo.com');
    });

    test('should throw AuthException for non-existent email', () async {
      expect(
        () => authService.resetPassword('nonexistent@demo.com'),
        throwsA(isA<AuthException>()),
      );
    });

    test('should emit auth state changes', () async {
      final states = <String?>[];

      // Listen to auth state changes
      final subscription = authService.authStateChanges.listen((userId) {
        states.add(userId);
      });

      // Sign in
      await authService.signInWithEmailAndPassword(
        'student@demo.com',
        'demo123',
      );
      await Future.delayed(const Duration(milliseconds: 100));

      // Sign out
      await authService.signOut();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(states.length, greaterThanOrEqualTo(2));
      expect(states.first, isNotNull); // User ID after sign in
      expect(states.last, isNull); // Null after sign out

      await subscription.cancel();
    });

    test('should sign in all demo users', () async {
      // Test student
      var userId = await authService.signInWithEmailAndPassword(
        'student@demo.com',
        'demo123',
      );
      expect(userId, isNotEmpty);
      await authService.signOut();

      // Test teacher
      userId = await authService.signInWithEmailAndPassword(
        'teacher@demo.com',
        'demo123',
      );
      expect(userId, isNotEmpty);
      await authService.signOut();

      // Test admin
      userId = await authService.signInWithEmailAndPassword(
        'admin@demo.com',
        'demo123',
      );
      expect(userId, isNotEmpty);
      await authService.signOut();
    });

    test('should delete user account', () async {
      // Register new user
      final userId = await authService.registerWithEmailAndPassword(
        'todelete@test.com',
        'password123',
        'Delete Me',
      );

      expect(authService.currentUserId, equals(userId));

      // Delete account
      await authService.deleteAccount();

      expect(authService.currentUserId, isNull);
    });

    test('should throw AuthException when deleting without sign in', () async {
      expect(
        () => authService.deleteAccount(),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('AuthException', () {
    test('should format message correctly', () {
      final exception = AuthException('Test message');
      expect(exception.toString(), equals('AuthException: Test message'));
    });

    test('should format message with code', () {
      final exception = AuthException('Test message', 'test-code');
      expect(
        exception.toString(),
        equals('AuthException [test-code]: Test message'),
      );
    });
  });
}
