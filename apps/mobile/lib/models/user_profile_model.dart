import 'package:campus_mesh/models/user_model.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.userId,
    required this.role,
    this.bio,
    this.phoneNumber,
    // Student fields
    this.shift,
    this.group,
    this.classRoll,
    this.academicSession,
    this.registrationNo,
    this.guardianName,
    this.guardianPhone,
    // Teacher fields
    this.designation,
    this.officeRoom,
    this.subjects,
    this.qualification,
    this.officeHours,
    // Admin fields
    this.adminTitle,
    this.adminScopes,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> data) {
    return UserProfile(
      id: data['id'] ?? data[r'$id'] ?? '',
      userId: data['user_id'] ?? '',
      role: _parseRole(data['role']),
      bio: data['bio'],
      phoneNumber: data['phone_number'],
      // Student
      shift: data['shift'],
      group: data['group'],
      classRoll: data['class_roll'],
      academicSession: data['academic_session'],
      registrationNo: data['registration_no'],
      guardianName: data['guardian_name'],
      guardianPhone: data['guardian_phone'],
      // Teacher
      designation: data['designation'],
      officeRoom: data['office_room'],
      subjects: data['subjects'] != null ? List<String>.from(data['subjects'] as List) : null,
      qualification: data['qualification'],
      officeHours: data['office_hours'],
      // Admin
      adminTitle: data['admin_title'],
      adminScopes: data['admin_scopes'] != null ? List<String>.from(data['admin_scopes'] as List) : null,
      createdAt: data['created_at'] != null ? DateTime.parse(data['created_at']) : null,
      updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at']) : null,
    );
  }

  final String id;
  final String userId;
  final UserRole role;
  
  // Common fields
  final String? bio;
  final String? phoneNumber;
  
  // Student-specific
  final String? shift;
  final String? group;
  final String? classRoll;
  final String? academicSession;
  final String? registrationNo;
  final String? guardianName;
  final String? guardianPhone;
  
  // Teacher-specific
  final String? designation;
  final String? officeRoom;
  final List<String>? subjects;
  final String? qualification;
  final String? officeHours;
  
  // Admin-specific
  final String? adminTitle;
  final List<String>? adminScopes;
  
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'role': role.name,
      if (bio != null) 'bio': bio,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      // Student
      if (shift != null) 'shift': shift,
      if (group != null) 'group': group,
      if (classRoll != null) 'class_roll': classRoll,
      if (academicSession != null) 'academic_session': academicSession,
      if (registrationNo != null) 'registration_no': registrationNo,
      if (guardianName != null) 'guardian_name': guardianName,
      if (guardianPhone != null) 'guardian_phone': guardianPhone,
      // Teacher
      if (designation != null) 'designation': designation,
      if (officeRoom != null) 'office_room': officeRoom,
      if (subjects != null) 'subjects': subjects,
      if (qualification != null) 'qualification': qualification,
      if (officeHours != null) 'office_hours': officeHours,
      // Admin
      if (adminTitle != null) 'admin_title': adminTitle,
      if (adminScopes != null) 'admin_scopes': adminScopes,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  static UserRole _parseRole(String? roleStr) {
    switch (roleStr?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'teacher':
        return UserRole.teacher;
      case 'student':
      default:
        return UserRole.student;
    }
  }

  UserProfile copyWith({
    String? id,
    String? userId,
    UserRole? role,
    String? bio,
    String? phoneNumber,
    String? shift,
    String? group,
    String? classRoll,
    String? academicSession,
    String? registrationNo,
    String? guardianName,
    String? guardianPhone,
    String? designation,
    String? officeRoom,
    List<String>? subjects,
    String? qualification,
    String? officeHours,
    String? adminTitle,
    List<String>? adminScopes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      shift: shift ?? this.shift,
      group: group ?? this.group,
      classRoll: classRoll ?? this.classRoll,
      academicSession: academicSession ?? this.academicSession,
      registrationNo: registrationNo ?? this.registrationNo,
      guardianName: guardianName ?? this.guardianName,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      designation: designation ?? this.designation,
      officeRoom: officeRoom ?? this.officeRoom,
      subjects: subjects ?? this.subjects,
      qualification: qualification ?? this.qualification,
      officeHours: officeHours ?? this.officeHours,
      adminTitle: adminTitle ?? this.adminTitle,
      adminScopes: adminScopes ?? this.adminScopes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
