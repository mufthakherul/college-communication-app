import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campus_mesh/models/notice_model.dart';

/// Search service for full-text search across notices
/// Uses PostgreSQL full-text search capabilities
class SearchService {
  final SupabaseClient _supabase = Supabase.instance.client;

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

      final List<dynamic> data = response as List<dynamic>;
      return data.map((item) {
        final Map<String, dynamic> noticeData = {
          'id': item['id'],
          'title': item['title'],
          'content': item['content'],
          'type': item['type'],
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

      return (response as List<dynamic>)
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

      return (response as List<dynamic>)
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

      return (response as List<dynamic>)
          .map((item) => item['title'] as String)
          .toSet() // Remove duplicates
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Search across multiple content types (notices, messages, etc.)
  Future<Map<String, List<dynamic>>> universalSearch(String query) async {
    if (query.trim().isEmpty) {
      return {
        'notices': [],
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

      final notices = (noticesResponse as List<dynamic>)
          .map((item) => NoticeModel.fromJson(item as Map<String, dynamic>))
          .toList();

      // Search users (for admins/teachers to find students)
      final usersResponse = await _supabase
          .from('users')
          .select('id, display_name, email, role')
          .or('display_name.ilike.$searchTerm,email.ilike.$searchTerm')
          .eq('is_active', true)
          .limit(10);

      final users = usersResponse as List<dynamic>;

      return {
        'notices': notices,
        'users': users,
      };
    } catch (e) {
      throw Exception('Failed to perform universal search: $e');
    }
  }
}
