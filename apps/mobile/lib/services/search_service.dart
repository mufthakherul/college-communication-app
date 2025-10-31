import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campus_mesh/models/notice_model.dart';
import 'package:campus_mesh/models/message_model.dart';

/// Search service for full-text search across notices, messages, and more
/// Uses PostgreSQL full-text search capabilities
class SearchService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Search notices using full-text search
  /// Returns notices ranked by relevance
  Future<List<NoticeModel>> searchNotices(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      // Use PostgreSQL full-text search function
      final response = await _supabase
          .rpc('search_notices', params: {'search_query': query});

      if (response == null) {
        return [];
      }

      final data = response as List<dynamic>;
      return data.map((item) {
        final itemMap = item as Map<String, dynamic>;
        final Map<String, dynamic> noticeData = {
          'id': itemMap['id'],
          'title': itemMap['title'],
          'content': itemMap['content'],
          'type': itemMap['type'],
          'is_active': true,
          // Other fields will use defaults
        };
        return NoticeModel.fromJson(noticeData);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search notices: $e');
    }
  }

  /// Simple search in notices (fallback if full-text search not available)
  Future<List<NoticeModel>> simpleSearchNotices(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final searchTerm = '%${query.toLowerCase()}%';
      
      final response = await _supabase
          .from('notices')
          .select()
          .eq('is_active', true)
          .or('title.ilike.$searchTerm,content.ilike.$searchTerm')
          .order('created_at', ascending: false)
          .limit(50);

      return response
          .map((item) => NoticeModel.fromJson(item as Map<String, dynamic>))
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
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final searchTerm = '%${query.toLowerCase()}%';
      
      final response = await _supabase
          .from('notices')
          .select()
          .eq('is_active', true)
          .eq('type', type.name)
          .or('title.ilike.$searchTerm,content.ilike.$searchTerm')
          .order('created_at', ascending: false)
          .limit(50);

      return response
          .map((item) => NoticeModel.fromJson(item as Map<String, dynamic>))
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
      final searchTerm = '%${query.toLowerCase()}%';
      
      // Get matching notice titles as suggestions
      final response = await _supabase
          .from('notices')
          .select('title')
          .eq('is_active', true)
          .ilike('title', searchTerm)
          .order('created_at', ascending: false)
          .limit(10);

      return response
          .map((item) => (item as Map<String, dynamic>)['title'] as String)
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
      final searchTerm = '%${query.toLowerCase()}%';
      
      // Search in user's messages (sent or received)
      final response = await _supabase
          .from('messages')
          .select()
          .or('sender_id.eq.$userId,recipient_id.eq.$userId')
          .ilike('content', searchTerm)
          .order('created_at', ascending: false)
          .limit(50);

      return response
          .map((item) => MessageModel.fromJson(item as Map<String, dynamic>))
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
      final searchTerm = '%${query.toLowerCase()}%';
      
      // Search in conversation with specific user
      final response = await _supabase
          .from('messages')
          .select()
          .or('and(sender_id.eq.$userId,recipient_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,recipient_id.eq.$userId)')
          .ilike('content', searchTerm)
          .order('created_at', ascending: false)
          .limit(50);

      return response
          .map((item) => MessageModel.fromJson(item as Map<String, dynamic>))
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
      final searchTerm = '%${query.toLowerCase()}%';
      
      var queryBuilder = _supabase
          .from('messages')
          .select()
          .or('sender_id.eq.$userId,recipient_id.eq.$userId')
          .eq('type', type.name);

      // Only apply content filter if query is provided
      if (query.trim().isNotEmpty) {
        queryBuilder = queryBuilder.ilike('content', searchTerm);
      }

      final response = await queryBuilder
          .order('created_at', ascending: false)
          .limit(50);

      return response
          .map((item) => MessageModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search messages by type: $e');
    }
  }

  /// Search across multiple content types (notices, messages, etc.)
  Future<Map<String, List<dynamic>>> universalSearch(String query) async {
    if (query.trim().isEmpty) {
      return {
        'notices': [],
        'messages': [],
        'users': [],
      };
    }

    try {
      final searchTerm = '%${query.toLowerCase()}%';
      
      // Search notices
      final noticesResponse = await _supabase
          .from('notices')
          .select()
          .eq('is_active', true)
          .or('title.ilike.$searchTerm,content.ilike.$searchTerm')
          .order('created_at', ascending: false)
          .limit(20);

      final notices = noticesResponse
          .map((item) => NoticeModel.fromJson(item as Map<String, dynamic>))
          .toList();

      // Search messages
      final messages = await searchMessages(query);

      // Search users (for admins/teachers to find students)
      final usersResponse = await _supabase
          .from('users')
          .select('id, display_name, email, role')
          .or('display_name.ilike.$searchTerm,email.ilike.$searchTerm')
          .eq('is_active', true)
          .limit(10);

      final users = usersResponse;

      return {
        'notices': notices,
        'messages': messages,
        'users': users,
      };
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
