import 'dart:async';
import '../models/user_model.dart';
import 'auth_repository.dart';

/// Mock implementation of [AuthRepository] for testing and demo purposes.
/// 
/// This implementation stores user data in memory and doesn't require
/// any backend service. Perfect for:
/// - Unit testing
/// - Integration testing
/// - Demo mode
/// - Development without Firebase
/// 
/// Features:
/// - In-memory user storage
/// - Simulated authentication delays
/// - Pre-seeded demo users
class MockAuthRepository implements AuthRepository {
  final Map<String, _MockUser> _users = {};
  final Map<String, UserModel> _profiles = {};
  String? _currentUserId;
  final _authStateController = StreamController<String?>.broadcast();

  /// Create a mock repository with optional pre-seeded users.
  MockAuthRepository({List<_MockUser>? seedUsers}) {
    // Add seed users if provided
    if (seedUsers != null) {
      for (final user in seedUsers) {
        _users[user.email] = user;
      }
    }

    // Add default demo users
    _addDemoUsers();
  }

  void _addDemoUsers() {
    // Demo student
    final studentUser = _MockUser(
      uid: 'demo-student-001',
      email: 'student@demo.com',
      password: 'demo123',
      displayName: 'Demo Student',
    );
    _users[studentUser.email] = studentUser;
    _profiles[studentUser.uid] = UserModel(
      uid: studentUser.uid,
      email: studentUser.email,
      displayName: studentUser.displayName,
      role: UserRole.student,
      department: 'Computer Science',
      year: '3rd Year',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Demo teacher
    final teacherUser = _MockUser(
      uid: 'demo-teacher-001',
      email: 'teacher@demo.com',
      password: 'demo123',
      displayName: 'Demo Teacher',
    );
    _users[teacherUser.email] = teacherUser;
    _profiles[teacherUser.uid] = UserModel(
      uid: teacherUser.uid,
      email: teacherUser.email,
      displayName: teacherUser.displayName,
      role: UserRole.teacher,
      department: 'Computer Science',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Demo admin
    final adminUser = _MockUser(
      uid: 'demo-admin-001',
      email: 'admin@demo.com',
      password: 'demo123',
      displayName: 'Demo Admin',
    );
    _users[adminUser.email] = adminUser;
    _profiles[adminUser.uid] = UserModel(
      uid: adminUser.uid,
      email: adminUser.email,
      displayName: adminUser.displayName,
      role: UserRole.admin,
      department: 'Administration',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  String? get currentUserId => _currentUserId;

  @override
  Stream<String?> get authStateChanges => _authStateController.stream;

  @override
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final user = _users[email.toLowerCase()];
    
    if (user == null) {
      throw AuthException('No user found with this email address', 'user-not-found');
    }

    if (user.password != password) {
      throw AuthException('Incorrect password', 'wrong-password');
    }

    _currentUserId = user.uid;
    _authStateController.add(_currentUserId);

    return user.uid;
  }

  @override
  Future<String> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    email = email.toLowerCase();

    if (_users.containsKey(email)) {
      throw AuthException(
        'An account already exists with this email',
        'email-already-in-use',
      );
    }

    if (password.length < 6) {
      throw AuthException(
        'Password is too weak. Use at least 6 characters',
        'weak-password',
      );
    }

    final uid = 'mock-${DateTime.now().millisecondsSinceEpoch}';
    final user = _MockUser(
      uid: uid,
      email: email,
      password: password,
      displayName: displayName,
    );

    _users[email] = user;

    // Create default user profile
    final profile = UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      role: UserRole.student, // Default role
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _profiles[uid] = profile;

    _currentUserId = uid;
    _authStateController.add(_currentUserId);

    return uid;
  }

  @override
  Future<void> signOut() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    _currentUserId = null;
    _authStateController.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    email = email.toLowerCase();

    if (!_users.containsKey(email)) {
      throw AuthException('No user found with this email address', 'user-not-found');
    }

    // In a real implementation, this would send an email
    // For mock, we just simulate success
  }

  @override
  Future<UserModel?> getUserProfile(String uid) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    return _profiles[uid];
  }

  @override
  Future<void> saveUserProfile(UserModel user) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    _profiles[user.uid] = user.copyWith(
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final profile = _profiles[uid];
    if (profile == null) {
      throw AuthException('User profile not found');
    }

    _profiles[uid] = profile.copyWith(
      displayName: updates['displayName'] ?? profile.displayName,
      photoURL: updates['photoURL'] ?? profile.photoURL,
      department: updates['department'] ?? profile.department,
      year: updates['year'] ?? profile.year,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteUserAccount(String uid) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Find and remove user from email map
    _users.removeWhere((email, user) => user.uid == uid);
    _profiles.remove(uid);

    if (_currentUserId == uid) {
      _currentUserId = null;
      _authStateController.add(null);
    }
  }

  /// Clean up resources
  void dispose() {
    _authStateController.close();
  }
}

/// Internal class to represent a mock user with credentials
class _MockUser {
  final String uid;
  final String email;
  final String password;
  final String displayName;

  _MockUser({
    required this.uid,
    required this.email,
    required this.password,
    required this.displayName,
  });
}
