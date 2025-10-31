enum UserRole { student, teacher, admin }

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoURL;
  final UserRole role;
  final String department;
  final String year;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // New student-specific fields
  final String shift; // Morning/Day/Evening
  final String group; // Academic group (A, B, C, etc.)
  final String classRoll; // Roll number in class
  final String academicSession; // Academic year/session
  final String phoneNumber; // Contact phone (private)

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL = '',
    required this.role,
    this.department = '',
    this.year = '',
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.shift = '',
    this.group = '',
    this.classRoll = '',
    this.academicSession = '',
    this.phoneNumber = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> data) {
    return UserModel(
      uid: data['id'] ?? data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['display_name'] ?? data['displayName'] ?? '',
      photoURL: data['photo_url'] ?? data['photoURL'] ?? '',
      role: _parseRole(data['role']),
      department: data['department'] ?? '',
      year: data['year'] ?? '',
      isActive: data['is_active'] ?? data['isActive'] ?? true,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : null,
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : null,
      shift: data['shift'] ?? '',
      group: data['group'] ?? '',
      classRoll: data['class_roll'] ?? '',
      academicSession: data['academic_session'] ?? '',
      phoneNumber: data['phone_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': uid,
      'email': email,
      'display_name': displayName,
      'photo_url': photoURL,
      'role': role.name,
      'department': department,
      'year': year,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'shift': shift,
      'group': group,
      'class_roll': classRoll,
      'academic_session': academicSession,
      'phone_number': phoneNumber,
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

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    UserRole? role,
    String? department,
    String? year,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? shift,
    String? group,
    String? classRoll,
    String? academicSession,
    String? phoneNumber,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      department: department ?? this.department,
      year: year ?? this.year,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shift: shift ?? this.shift,
      group: group ?? this.group,
      classRoll: classRoll ?? this.classRoll,
      academicSession: academicSession ?? this.academicSession,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
