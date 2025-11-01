import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:campus_mesh/models/timetable_model.dart';
import 'package:campus_mesh/services/appwrite_service.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/appwrite_config.dart';

class TimetableService {
  final _appwrite = AppwriteService();
  final _authService = AuthService();

  StreamController<List<TimetableModel>>? _timetablesController;
  Timer? _pollingTimer;

  String? get _currentUserId => _authService.currentUserId;

  // Get all timetables (polling-based stream)
  Stream<List<TimetableModel>> getTimetables() {
    _timetablesController ??= StreamController<List<TimetableModel>>.broadcast(
      onListen: () => _startPolling(),
      onCancel: () => _stopPolling(),
    );
    return _timetablesController!.stream;
  }

  void _startPolling() {
    _fetchTimetables();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchTimetables(),
    );
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _fetchTimetables() async {
    try {
      final docs = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.timetablesCollectionId,
        queries: [Query.orderDesc('created_at'), Query.limit(100)],
      );

      final timetables = docs.documents
          .map((doc) => TimetableModel.fromJson(doc.data))
          .toList();

      _timetablesController?.add(timetables);
    } catch (e) {
      debugPrint('Error fetching timetables: $e');
      _timetablesController?.addError(e);
    }
  }

  // Get timetable by department and shift
  Future<TimetableModel?> getTimetableByClass(
    String department,
    String shift,
  ) async {
    try {
      final docs = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.timetablesCollectionId,
        queries: [
          Query.equal('department', department),
          Query.equal('shift', shift),
          Query.limit(1),
        ],
      );

      if (docs.documents.isEmpty) return null;

      return TimetableModel.fromJson(docs.documents.first.data);
    } catch (e) {
      debugPrint('Error fetching timetable: $e');
      return null;
    }
  }

  // Get single timetable
  Future<TimetableModel?> getTimetable(String timetableId) async {
    try {
      final doc = await _appwrite.databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.timetablesCollectionId,
        documentId: timetableId,
      );

      return TimetableModel.fromJson(doc.data);
    } catch (e) {
      debugPrint('Error fetching timetable: $e');
      return null;
    }
  }

  // Create timetable (admin only)
  Future<TimetableModel?> createTimetable(TimetableModel timetable) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _appwrite.databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.timetablesCollectionId,
        documentId: ID.unique(),
        data: timetable.toJson(),
      );

      _fetchTimetables();

      return TimetableModel.fromJson(doc.data);
    } catch (e) {
      debugPrint('Error creating timetable: $e');
      return null;
    }
  }

  // Update timetable (admin only)
  Future<bool> updateTimetable(
    String timetableId,
    Map<String, dynamic> updates,
  ) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      updates['updated_at'] = DateTime.now().toIso8601String();

      await _appwrite.databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.timetablesCollectionId,
        documentId: timetableId,
        data: updates,
      );

      _fetchTimetables();

      return true;
    } catch (e) {
      debugPrint('Error updating timetable: $e');
      return false;
    }
  }

  // Delete timetable (admin only)
  Future<bool> deleteTimetable(String timetableId) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not authenticated');
      }

      await _appwrite.databases.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.timetablesCollectionId,
        documentId: timetableId,
      );

      _fetchTimetables();

      return true;
    } catch (e) {
      debugPrint('Error deleting timetable: $e');
      return false;
    }
  }

  void dispose() {
    _pollingTimer?.cancel();
    _timetablesController?.close();
  }
}
