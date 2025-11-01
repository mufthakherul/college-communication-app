import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:campus_mesh/models/assignment_model.dart';
import 'package:campus_mesh/services/appwrite_service.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/appwrite_config.dart';

class AssignmentService {
  final _appwrite = AppwriteService();
  final _authService = AuthService();

  StreamController<List<AssignmentModel>>? _assignmentsController;
  Timer? _pollingTimer;

  String? get _currentUserId => _authService.currentUserId;

  // Get all assignments (polling-based stream)
  Stream<List<AssignmentModel>> getAssignments() {
    _assignmentsController ??=
        StreamController<List<AssignmentModel>>.broadcast(
      onListen: () => _startPolling(),
      onCancel: () => _stopPolling(),
    );
    return _assignmentsController!.stream;
  }

  void _startPolling() {
    _fetchAssignments();
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 10), (_) => _fetchAssignments());
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _fetchAssignments() async {
    try {
      final docs = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.assignmentsCollectionId,
        queries: [
          Query.orderDesc('due_date'),
          Query.limit(100),
        ],
      );

      final assignments = docs.documents
          .map((doc) => AssignmentModel.fromJson(doc.data))
          .toList();

      _assignmentsController?.add(assignments);
    } catch (e) {
      debugPrint('Error fetching assignments: $e');
      _assignmentsController?.addError(e);
    }
  }

  // Get assignments by subject
  Future<List<AssignmentModel>> getAssignmentsBySubject(String subject) async {
    try {
      final docs = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.assignmentsCollectionId,
        queries: [
          Query.equal('subject', subject),
          Query.orderDesc('due_date'),
          Query.limit(100),
        ],
      );

      return docs.documents
          .map((doc) => AssignmentModel.fromJson(doc.data))
          .toList();
    } catch (e) {
      debugPrint('Error fetching assignments by subject: $e');
      return [];
    }
  }

  // Get single assignment
  Future<AssignmentModel?> getAssignment(String assignmentId) async {
    try {
      final doc = await _appwrite.databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.assignmentsCollectionId,
        documentId: assignmentId,
      );

      return AssignmentModel.fromJson(doc.data);
    } catch (e) {
      debugPrint('Error fetching assignment: $e');
      return null;
    }
  }

  // Create assignment (teacher/admin only)
  Future<AssignmentModel?> createAssignment(AssignmentModel assignment) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _appwrite.databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.assignmentsCollectionId,
        documentId: ID.unique(),
        data: assignment.toJson(),
      );

      _fetchAssignments();

      return AssignmentModel.fromJson(doc.data);
    } catch (e) {
      debugPrint('Error creating assignment: $e');
      return null;
    }
  }

  // Update assignment (teacher/admin only)
  Future<bool> updateAssignment(
      String assignmentId, Map<String, dynamic> updates) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      updates['updated_at'] = DateTime.now().toIso8601String();

      await _appwrite.databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.assignmentsCollectionId,
        documentId: assignmentId,
        data: updates,
      );

      _fetchAssignments();

      return true;
    } catch (e) {
      debugPrint('Error updating assignment: $e');
      return false;
    }
  }

  // Delete assignment (teacher/admin only)
  Future<bool> deleteAssignment(String assignmentId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _appwrite.databases.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.assignmentsCollectionId,
        documentId: assignmentId,
      );

      _fetchAssignments();

      return true;
    } catch (e) {
      debugPrint('Error deleting assignment: $e');
      return false;
    }
  }

  // Submit assignment (student only)
  Future<AssignmentSubmissionModel?> submitAssignment(
      AssignmentSubmissionModel submission) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _appwrite.databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.assignmentSubmissionsCollectionId,
        documentId: ID.unique(),
        data: submission.toJson(),
      );

      return AssignmentSubmissionModel.fromJson(doc.data);
    } catch (e) {
      debugPrint('Error submitting assignment: $e');
      return null;
    }
  }

  // Get student submissions
  Future<List<AssignmentSubmissionModel>> getStudentSubmissions(
      String studentId) async {
    try {
      final docs = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.assignmentSubmissionsCollectionId,
        queries: [
          Query.equal('student_id', studentId),
          Query.orderDesc('submission_date'),
        ],
      );

      return docs.documents
          .map((doc) => AssignmentSubmissionModel.fromJson(doc.data))
          .toList();
    } catch (e) {
      debugPrint('Error fetching student submissions: $e');
      return [];
    }
  }

  void dispose() {
    _pollingTimer?.cancel();
    _assignmentsController?.close();
  }
}
