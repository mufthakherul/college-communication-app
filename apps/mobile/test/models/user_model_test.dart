import 'package:campus_mesh/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

// NOTE: The user model now only contains core identity fields.
// Extended profile fields (shift, group, classRoll, etc.) moved to UserProfile.
// These tests were updated to reflect the split between authentication user and detailed profile.

void main() {
  group('UserModel', () {
    test('creates UserModel from valid data', () {
      final user = UserModel(
        uid: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        role: UserRole.student,
        photoURL: 'https://example.com/photo.jpg',
        department: 'Computer Science',
        year: '2024',
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(user.uid, 'user123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.role, UserRole.student);
      expect(user.department, 'Computer Science');
      expect(user.year, '2024');
      expect(user.isActive, true);
      expect(user.photoURL, isNotEmpty);
    });

    test('toJson outputs expected core fields', () {
      final user = UserModel(
        uid: 'u456',
        email: 'teacher@example.com',
        displayName: 'Teacher User',
        role: UserRole.teacher,
        department: 'Mathematics',
        year: '2025',
        isActive: false,
        createdAt: DateTime(2024, 2, 10),
      );
      final json = user.toJson();
      expect(json['id'], 'u456');
      expect(json['email'], 'teacher@example.com');
      expect(json['display_name'], 'Teacher User');
      expect(json['role'], 'teacher');
      expect(json['department'], 'Mathematics');
      expect(json['year'], '2025');
      expect(json['is_active'], false);
      expect(json.containsKey('shift'), isFalse);
    });

    test('parseRole enum mapping', () {
      expect(UserRole.student.name, 'student');
      expect(UserRole.teacher.name, 'teacher');
      expect(UserRole.admin.name, 'admin');
    });

    test('empty optional fields default correctly', () {
      final user = UserModel(
        uid: 'user789',
        email: 'empty@example.com',
        displayName: 'Empty User',
        role: UserRole.student,
        department: '',
        year: '',
        isActive: true,
      );
      expect(user.department, '');
      expect(user.year, '');
    });

    test('fromJson handles multiple id keys', () {
      final json = {
        r'$id': 'appwrite123',
        'email': 'student@example.com',
        'display_name': 'Student User',
        'role': 'student',
        'department': 'Computer Tech',
        'year': '3rd',
      };
      final user = UserModel.fromJson(json);
      expect(user.uid, 'appwrite123');
      expect(user.role, UserRole.student);
    });

    test('copyWith returns modified instance', () {
      final user = UserModel(
        uid: 'base',
        email: 'base@example.com',
        displayName: 'Base User',
        role: UserRole.teacher,
      );
      final updated = user.copyWith(displayName: 'Updated User', role: UserRole.admin);
      expect(updated.displayName, 'Updated User');
      expect(updated.role, UserRole.admin);
      expect(updated.uid, 'base'); // unchanged
    });
  });
}
