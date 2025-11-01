import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:campus_mesh/models/notice_model.dart';
import 'package:campus_mesh/services/appwrite_service.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/appwrite_config.dart';

class NoticeService {
  final _appwrite = AppwriteService();
  final _authService = AuthService();

  StreamController<List<NoticeModel>>? _noticesController;

  // Get current user ID
  String? get _currentUserId => _authService.currentUserId;

  // Get all active notices (polling-based stream for compatibility)
  Stream<List<NoticeModel>> getNotices() {
    _noticesController ??= StreamController<List<NoticeModel>>.broadcast(
      onListen: () => _startPolling(),
      onCancel: () => _stopPolling(),
    );
    return _noticesController!.stream;
  }

  Timer? _pollingTimer;

  void _startPolling() {
    _fetchNotices(); // Fetch immediately
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => _fetchNotices());
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _fetchNotices() async {
    try {
      final docs = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.noticesCollectionId,
        queries: [
          Query.equal('is_active', true),
          Query.orderDesc('created_at'),
          Query.limit(100),
        ],
      );

      final notices =
          docs.documents.map((doc) => NoticeModel.fromJson(doc.data)).toList();

      _noticesController?.add(notices);
    } catch (e) {
      _noticesController?.addError(e);
    }
  }

  // Get notices by type
  Stream<List<NoticeModel>> getNoticesByType(NoticeType type) {
    return getNotices().map((notices) {
      return notices.where((notice) => notice.type == type).toList();
    });
  }

  // Get single notice
  Future<NoticeModel?> getNotice(String noticeId) async {
    try {
      final document = await _appwrite.databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.noticesCollectionId,
        documentId: noticeId,
      );

      return NoticeModel.fromJson(document.data);
    } on AppwriteException catch (e) {
      throw Exception('Failed to get notice: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get notice: $e');
    }
  }

  // Create notice
  Future<String> createNotice({
    required String title,
    required String content,
    required NoticeType type,
    required String targetAudience,
    DateTime? expiresAt,
  }) async {
    try {
      final currentUserId = _currentUserId;
      if (currentUserId == null) {
        throw Exception('User must be authenticated to create notices');
      }

      final document = await _appwrite.databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.noticesCollectionId,
        documentId: ID.unique(),
        data: {
          'title': title,
          'content': content,
          'type': type.name,
          'target_audience': targetAudience,
          'author_id': currentUserId,
          'expires_at': expiresAt?.toIso8601String(),
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      return document.$id;
    } on AppwriteException catch (e) {
      throw Exception('Failed to create notice: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create notice: $e');
    }
  }

  // Update notice
  Future<void> updateNotice({
    required String noticeId,
    Map<String, dynamic>? updates,
  }) async {
    try {
      final currentUserId = _currentUserId;
      if (currentUserId == null) {
        throw Exception('User must be authenticated to update notices');
      }

      final updateData = {
        ...?updates,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _appwrite.databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.noticesCollectionId,
        documentId: noticeId,
        data: updateData,
      );
    } on AppwriteException catch (e) {
      throw Exception('Failed to update notice: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update notice: $e');
    }
  }

  // Delete notice
  Future<void> deleteNotice(String noticeId) async {
    try {
      await updateNotice(noticeId: noticeId, updates: {'is_active': false});
    } catch (e) {
      throw Exception('Failed to delete notice: $e');
    }
  }

  // Clean up
  void dispose() {
    _stopPolling();
    _noticesController?.close();
    _noticesController = null;
  }
}
