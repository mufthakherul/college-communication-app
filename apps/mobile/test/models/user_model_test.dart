import 'package:flutter_test/flutter_test.dart';
import 'package:campus_mesh/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('should create UserModel from valid data', () {
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
    });

    test('should convert UserModel to JSON', () {
      final user = UserModel(
        uid: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        role: UserRole.teacher,
        photoURL: '',
        department: 'Mathematics',
        year: '2024',
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
      );

      final json = user.toJson();

      expect(json['id'], 'user123');
      expect(json['email'], 'test@example.com');
      expect(json['display_name'], 'Test User');
      expect(json['role'], 'teacher');
      expect(json['department'], 'Mathematics');
      expect(json['is_active'], true);
    });

    test('should parse UserRole enum correctly', () {
      expect(UserRole.student.name, 'student');
      expect(UserRole.teacher.name, 'teacher');
      expect(UserRole.admin.name, 'admin');
    });

    test('should handle empty optional fields', () {
      final user = UserModel(
        uid: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        role: UserRole.student,
        photoURL: '',
        department: '',
        year: '',
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(user.photoURL, '');
      expect(user.department, '');
      expect(user.year, '');
    });

    test('should validate role types', () {
      final roles = [UserRole.student, UserRole.teacher, UserRole.admin];

      for (final role in roles) {
        final user = UserModel(
          uid: 'user123',
          email: 'test@example.com',
          displayName: 'Test User',
          role: role,
          photoURL: '',
          department: 'Test',
          year: '2024',
          isActive: true,
          createdAt: DateTime.now(),
        );

        expect(user.role, role);
      }
    });
  });
}
