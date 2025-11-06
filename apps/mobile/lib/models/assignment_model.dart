enum AssignmentStatus { pending, submitted, graded, late }

class AssignmentModel {

  AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.teacherId,
    required this.teacherName,
    required this.dueDate,
    required this.maxMarks,
    this.attachmentUrl,
    required this.createdAt,
    this.updatedAt,
    this.targetGroups = const [],
    this.department = '',
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> data) {
    return AssignmentModel(
      id: data['id'] ?? data[r'$id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      subject: data['subject'] ?? '',
      teacherId: data['teacher_id'] ?? '',
      teacherName: data['teacher_name'] ?? '',
      dueDate: DateTime.parse(data['due_date']),
      maxMarks: data['max_marks'] ?? 100,
      attachmentUrl: data['attachment_url'],
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'])
          : null,
      targetGroups: data['target_groups'] != null
          ? List<String>.from(data['target_groups'])
          : [],
      department: data['department'] ?? '',
    );
  }
  final String id;
  final String title;
  final String description;
  final String subject;
  final String teacherId;
  final String teacherName;
  final DateTime dueDate;
  final int maxMarks;
  final String? attachmentUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> targetGroups; // Which classes/groups this is for
  final String department;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'due_date': dueDate.toIso8601String(),
      'max_marks': maxMarks,
      'attachment_url': attachmentUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'target_groups': targetGroups,
      'department': department,
    };
  }

  bool get isOverdue => DateTime.now().isAfter(dueDate);

  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
}

class AssignmentSubmissionModel {

  AssignmentSubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    required this.submissionDate,
    this.submissionText,
    this.attachmentUrl,
    required this.status,
    this.marksObtained,
    this.feedback,
    this.gradedAt,
  });

  factory AssignmentSubmissionModel.fromJson(Map<String, dynamic> data) {
    return AssignmentSubmissionModel(
      id: data['id'] ?? data[r'$id'] ?? '',
      assignmentId: data['assignment_id'] ?? '',
      studentId: data['student_id'] ?? '',
      studentName: data['student_name'] ?? '',
      submissionDate: DateTime.parse(data['submission_date']),
      submissionText: data['submission_text'],
      attachmentUrl: data['attachment_url'],
      status: _parseStatus(data['status']),
      marksObtained: data['marks_obtained'],
      feedback: data['feedback'],
      gradedAt:
          data['graded_at'] != null ? DateTime.parse(data['graded_at']) : null,
    );
  }
  final String id;
  final String assignmentId;
  final String studentId;
  final String studentName;
  final DateTime submissionDate;
  final String? submissionText;
  final String? attachmentUrl;
  final AssignmentStatus status;
  final int? marksObtained;
  final String? feedback;
  final DateTime? gradedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignment_id': assignmentId,
      'student_id': studentId,
      'student_name': studentName,
      'submission_date': submissionDate.toIso8601String(),
      'submission_text': submissionText,
      'attachment_url': attachmentUrl,
      'status': status.name,
      'marks_obtained': marksObtained,
      'feedback': feedback,
      'graded_at': gradedAt?.toIso8601String(),
    };
  }

  static AssignmentStatus _parseStatus(String? statusStr) {
    switch (statusStr?.toLowerCase()) {
      case 'submitted':
        return AssignmentStatus.submitted;
      case 'graded':
        return AssignmentStatus.graded;
      case 'late':
        return AssignmentStatus.late;
      default:
        return AssignmentStatus.pending;
    }
  }
}
