import 'package:campus_mesh/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

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
        shift: 'Day',
        group: 'A',
        classRoll: '101',
        academicSession: '2023-2024',
        phoneNumber: '+880123456789',
      );

      expect(user.uid, 'user123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.role, UserRole.student);
      expect(user.department, 'Computer Science');
      expect(user.year, '2024');
      expect(user.isActive, true);
      expect(user.shift, 'Day');
      expect(user.group, 'A');
      expect(user.classRoll, '101');
      expect(user.academicSession, '2023-2024');
      expect(user.phoneNumber, '+880123456789');
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
        shift: 'Morning',
        group: 'B',
        classRoll: '205',
        academicSession: '2024-2025',
        phoneNumber: '+880987654321',
      );

      final json = user.toJson();

      expect(json['id'], 'user123');
      expect(json['email'], 'test@example.com');
      expect(json['display_name'], 'Test User');
      expect(json['role'], 'teacher');
      expect(json['department'], 'Mathematics');
      expect(json['is_active'], true);
      expect(json['shift'], 'Morning');
      expect(json['group'], 'B');
      expect(json['class_roll'], '205');
      expect(json['academic_session'], '2024-2025');
      expect(json['phone_number'], '+880987654321');
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

    test('should parse new student fields from JSON', () {
      final json = {
        'id': 'student123',
        'email': 'student@example.com',
        'display_name': 'Student User',
        'role': 'student',
        'department': 'Computer Technology',
        'year': '3rd',
        'is_active': true,
        'created_at': '2024-01-01T00:00:00.000Z',
        'shift': 'Day',
        'group': 'A',
        'class_roll': '12345',
        'academic_session': '2023-2024',
        'phone_number': '+8801712345678',
      };

      final user = UserModel.fromJson(json);

      expect(user.shift, 'Day');
      expect(user.group, 'A');
      expect(user.classRoll, '12345');
      expect(user.academicSession, '2023-2024');
      expect(user.phoneNumber, '+8801712345678');
    });

    test('should handle missing new fields gracefully', () {
      final json = {
        'id': 'student123',
        'email': 'student@example.com',
        'display_name': 'Student User',
        'role': 'student',
        'department': 'Computer Technology',
        'year': '3rd',
        'is_active': true,
        'created_at': '2024-01-01T00:00:00.000Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.shift, '');
      expect(user.group, '');
      expect(user.classRoll, '');
      expect(user.academicSession, '');
      expect(user.phoneNumber, '');
    });
  });
}
