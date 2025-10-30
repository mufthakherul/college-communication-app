import 'package:flutter_test/flutter_test.dart';
import 'package:campus_mesh/models/notice_model.dart';

void main() {
  group('NoticeModel', () {
    test('should create NoticeModel with required fields', () {
      final notice = NoticeModel(
        id: 'notice123',
        title: 'Test Notice',
        content: 'This is a test notice',
        type: NoticeType.announcement,
        targetAudience: 'all',
        authorId: 'author123',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        isActive: true,
      );

      expect(notice.id, 'notice123');
      expect(notice.title, 'Test Notice');
      expect(notice.content, 'This is a test notice');
      expect(notice.type, NoticeType.announcement);
      expect(notice.targetAudience, 'all');
      expect(notice.authorId, 'author123');
      expect(notice.isActive, true);
    });

    test('should convert NoticeModel to Map', () {
      final notice = NoticeModel(
        id: 'notice123',
        title: 'Test Notice',
        content: 'Content',
        type: NoticeType.event,
        targetAudience: 'students',
        authorId: 'author123',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        isActive: true,
      );

      final map = notice.toMap();

      expect(map['title'], 'Test Notice');
      expect(map['content'], 'Content');
      expect(map['type'], 'event');
      expect(map['targetAudience'], 'students');
      expect(map['authorId'], 'author123');
      expect(map['isActive'], true);
    });

    test('should handle all NoticeType enum values', () {
      expect(NoticeType.announcement.name, 'announcement');
      expect(NoticeType.event.name, 'event');
      expect(NoticeType.urgent.name, 'urgent');
    });

    test('should handle optional expiresAt field', () {
      final expiry = DateTime(2024, 12, 31);
      
      final noticeWithExpiry = NoticeModel(
        id: 'notice1',
        title: 'Test',
        content: 'Content',
        type: NoticeType.announcement,
        targetAudience: 'all',
        authorId: 'author123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        expiresAt: expiry,
        isActive: true,
      );

      expect(noticeWithExpiry.expiresAt, expiry);

      final noticeWithoutExpiry = NoticeModel(
        id: 'notice2',
        title: 'Test',
        content: 'Content',
        type: NoticeType.announcement,
        targetAudience: 'all',
        authorId: 'author123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      expect(noticeWithoutExpiry.expiresAt, null);
    });

    test('should support different target audiences', () {
      final audiences = ['all', 'students', 'teachers', 'admin'];
      
      for (var audience in audiences) {
        final notice = NoticeModel(
          id: 'notice123',
          title: 'Test',
          content: 'Content',
          type: NoticeType.announcement,
          targetAudience: audience,
          authorId: 'author123',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
        );
        
        expect(notice.targetAudience, audience);
      }
    });

    test('should track active status', () {
      final activeNotice = NoticeModel(
        id: 'notice1',
        title: 'Active',
        content: 'Content',
        type: NoticeType.announcement,
        targetAudience: 'all',
        authorId: 'author123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      expect(activeNotice.isActive, true);

      final inactiveNotice = NoticeModel(
        id: 'notice2',
        title: 'Inactive',
        content: 'Content',
        type: NoticeType.announcement,
        targetAudience: 'all',
        authorId: 'author123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: false,
      );

      expect(inactiveNotice.isActive, false);
    });
  });
}
