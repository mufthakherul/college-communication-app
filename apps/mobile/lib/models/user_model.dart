import 'package:cloud_firestore/cloud_firestore.dart';

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
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'] ?? '',
      role: _parseRole(data['role']),
      department: data['department'] ?? '',
      year: data['year'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'role': role.name,
      'department': department,
      'year': year,
      'isActive': isActive,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
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
    );
  }
}
