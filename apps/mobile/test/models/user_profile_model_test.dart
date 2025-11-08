import 'package:campus_mesh/models/user_profile_model.dart';
import 'package:campus_mesh/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfile', () {
    test('fromJson parses full student profile', () {
      final json = {
        'id': 'profile123',
        'user_id': 'user123',
        'role': 'student',
        'bio': 'Hello there',
        'phone_number': '+8801712345678',
        'shift': 'Day',
        'group': 'A',
        'class_roll': '101',
        'academic_session': '2023-2024',
        'registration_no': 'REG-2024-1234',
        'guardian_name': 'Parent Name',
        'guardian_phone': '+8801700000000',
        'created_at': '2024-01-01T00:00:00.000Z',
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.id, 'profile123');
      expect(profile.userId, 'user123');
      expect(profile.role, UserRole.student);
      expect(profile.bio, 'Hello there');
      expect(profile.phoneNumber, '+8801712345678');
      expect(profile.shift, 'Day');
      expect(profile.group, 'A');
      expect(profile.classRoll, '101');
      expect(profile.academicSession, '2023-2024');
      expect(profile.registrationNo, 'REG-2024-1234');
      expect(profile.guardianName, 'Parent Name');
      expect(profile.guardianPhone, '+8801700000000');
      expect(profile.createdAt, isNotNull);
    });

    test('toJson includes only provided optional fields', () {
      final profile = UserProfile(
        id: 'p1',
        userId: 'u1',
        role: UserRole.teacher,
        designation: 'Lecturer',
      );

      final json = profile.toJson();
      expect(json['user_id'], 'u1');
      expect(json['role'], 'teacher');
      expect(json.containsKey('designation'), isTrue);
      expect(json.containsKey('shift'), isFalse);
      expect(json['created_at'], isA<String>());
    });

    test('copyWith updates selected fields', () {
      final base = UserProfile(
        id: 'p2',
        userId: 'u2',
        role: UserRole.admin,
        adminTitle: 'Coordinator',
      );
      final updated = base.copyWith(adminTitle: 'Director');
      expect(updated.adminTitle, 'Director');
      expect(updated.role, UserRole.admin);
      expect(updated.userId, 'u2');
    });
  });
}
