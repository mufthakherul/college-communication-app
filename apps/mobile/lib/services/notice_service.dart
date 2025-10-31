import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campus_mesh/models/notice_model.dart';

class NoticeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user ID
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  // Get all active notices
  Stream<List<NoticeModel>> getNotices() {
    return _supabase
        .from('notices')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .map((data) => data.map((item) => NoticeModel.fromJson(item)).toList());
  }

  // Get notices by type
  Stream<List<NoticeModel>> getNoticesByType(NoticeType type) {
    return _supabase
        .from('notices')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {
          // Filter in memory for active notices of the specified type
          return data
              .where((item) {
                final isActive = item['is_active'] as bool? ?? false;
                final noticeType = item['type'] as String?;
                return isActive && noticeType == type.name;
              })
              .map((item) => NoticeModel.fromJson(item))
              .toList();
        });
  }

  // Get single notice
  Future<NoticeModel?> getNotice(String noticeId) async {
    try {
      final response = await _supabase
          .from('notices')
          .select()
          .eq('id', noticeId)
          .single();

      return NoticeModel.fromJson(response);
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

      final notice = {
        'title': title,
        'content': content,
        'type': type.name,
        'target_audience': targetAudience,
        'author_id': currentUserId,
        'expires_at': expiresAt?.toIso8601String(),
        'is_active': true,
      };

      final response = await _supabase
          .from('notices')
          .insert(notice)
          .select()
          .single();

      return response['id'] as String;
    } catch (e) {
      throw Exception('Failed to create notice: $e');
    }
  }

  // Update notice
  // Note: Authorization is enforced by PostgreSQL Row Level Security
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

      await _supabase.from('notices').update(updateData).eq('id', noticeId);
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
}
