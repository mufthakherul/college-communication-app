import 'package:campus_mesh/models/notice_model.dart';
import 'package:campus_mesh/models/message_model.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/services/appwrite_service.dart';
import 'package:campus_mesh/appwrite_config.dart';
import 'package:campus_mesh/utils/input_validator.dart';
import 'package:appwrite/appwrite.dart';

/// Search service for full-text search across notices, messages, and more
/// Note: Simplified implementation using Appwrite search capabilities
class SearchService {
  final _appwrite = AppwriteService();
  final _authService = AuthService();

  String? get _currentUserId => _authService.currentUserId;

  /// Search notices using Appwrite search
  /// Returns notices ranked by relevance
  Future<List<NoticeModel>> searchNotices(String query) async {
    // Sanitize search query to prevent injection
    final sanitizedQuery = InputValidator.sanitizeSearchQuery(query);
    if (sanitizedQuery == null || sanitizedQuery.isEmpty) {
      return [];
    }

    try {
      // Use Appwrite search
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.noticesCollectionId,
        queries: [
          Query.search('title', sanitizedQuery),
          Query.equal('is_active', true),
          Query.orderDesc('created_at'),
          Query.limit(50),
        ],
      );

      return response.documents
          .map((doc) => NoticeModel.fromJson(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to search notices: $e');
    }
  }

  /// Simple search in notices (searches content as well)
  Future<List<NoticeModel>> simpleSearchNotices(String query) async {
    // Sanitize search query to prevent injection
    final sanitizedQuery = InputValidator.sanitizeSearchQuery(query);
    if (sanitizedQuery == null || sanitizedQuery.isEmpty) {
      return [];
    }

    try {
      // Search in both title and content
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.noticesCollectionId,
        queries: [
          Query.search('content', sanitizedQuery),
          Query.equal('is_active', true),
          Query.orderDesc('created_at'),
          Query.limit(50),
        ],
      );

      return response.documents
          .map((doc) => NoticeModel.fromJson(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to search notices: $e');
    }
  }

  /// Search notices by type
  Future<List<NoticeModel>> searchNoticesByType(
    String query,
    NoticeType type,
  ) async {
    // Sanitize search query to prevent injection
    final sanitizedQuery = InputValidator.sanitizeSearchQuery(query);
    if (sanitizedQuery == null || sanitizedQuery.isEmpty) {
      return [];
    }

    try {
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.noticesCollectionId,
        queries: [
          Query.search('title', sanitizedQuery),
          Query.equal('is_active', true),
          Query.equal('type', type.name),
          Query.orderDesc('created_at'),
          Query.limit(50),
        ],
      );

      return response.documents
          .map((doc) => NoticeModel.fromJson(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to search notices by type: $e');
    }
  }

  /// Get search suggestions based on query
  Future<List<String>> getSearchSuggestions(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      // Get matching notice titles as suggestions
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.noticesCollectionId,
        queries: [
          Query.search('title', query),
          Query.equal('is_active', true),
          Query.orderDesc('created_at'),
          Query.limit(10),
        ],
      );

      return response.documents
          .map((doc) => doc.data['title'] as String)
          .toSet() // Remove duplicates
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Search messages
  Future<List<MessageModel>> searchMessages(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final userId = _currentUserId;
    if (userId == null) {
      return [];
    }

    try {
      // Search in user's messages (sent or received)
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        queries: [
          Query.search('content', query),
          Query.equal('sender_id', userId),
          Query.orderDesc('created_at'),
          Query.limit(50),
        ],
      );

      return response.documents
          .map((doc) => MessageModel.fromJson(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to search messages: $e');
    }
  }

  /// Search messages with specific user
  Future<List<MessageModel>> searchMessagesWithUser(
    String query,
    String otherUserId,
  ) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final userId = _currentUserId;
    if (userId == null) {
      return [];
    }

    try {
      // Search in conversation with specific user
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        queries: [
          Query.search('content', query),
          Query.equal('sender_id', userId),
          Query.equal('recipient_id', otherUserId),
          Query.orderDesc('created_at'),
          Query.limit(50),
        ],
      );

      return response.documents
          .map((doc) => MessageModel.fromJson(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to search messages with user: $e');
    }
  }

  /// Search messages by type (text, image, file, etc.)
  Future<List<MessageModel>> searchMessagesByType(
    String query,
    MessageType type,
  ) async {
    if (query.trim().isEmpty && type == MessageType.text) {
      return [];
    }

    final userId = _currentUserId;
    if (userId == null) {
      return [];
    }

    try {
      final queries = <String>[
        Query.equal('sender_id', userId),
        Query.equal('type', type.name),
        Query.orderDesc('created_at'),
        Query.limit(50),
      ];

      // Only apply content filter if query is provided
      if (query.trim().isNotEmpty) {
        queries.insert(0, Query.search('content', query));
      }

      final response = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        queries: queries,
      );

      return response.documents
          .map((doc) => MessageModel.fromJson(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to search messages by type: $e');
    }
  }

  /// Search across multiple content types (notices, messages, etc.)
  Future<Map<String, List<dynamic>>> universalSearch(String query) async {
    if (query.trim().isEmpty) {
      return {'notices': [], 'messages': [], 'users': []};
    }

    try {
      // Search notices
      final noticesResponse = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.noticesCollectionId,
        queries: [
          Query.search('title', query),
          Query.equal('is_active', true),
          Query.orderDesc('created_at'),
          Query.limit(20),
        ],
      );

      final notices = noticesResponse.documents
          .map((doc) => NoticeModel.fromJson(doc.data))
          .toList();

      // Search messages
      final messages = await searchMessages(query);

      // Search users (for admins/teachers to find students)
      final usersResponse = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [
          Query.search('display_name', query),
          Query.equal('is_active', true),
          Query.limit(10),
        ],
      );

      final users = usersResponse.documents.map((doc) => doc.data).toList();

      return {'notices': notices, 'messages': messages, 'users': users};
    } catch (e) {
      throw Exception('Failed to perform universal search: $e');
    }
  }

  /// Get recent searches (can be stored locally)
  List<String> getRecentSearches() {
    // TODO: Implement local storage for search history
    return [];
  }

  /// Save search query to history
  Future<void> saveSearchQuery(String query) async {
    // TODO: Implement local storage for search history
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    // TODO: Implement clearing of search history
  }
}
