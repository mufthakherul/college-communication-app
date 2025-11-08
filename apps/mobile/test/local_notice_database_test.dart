import 'package:flutter_test/flutter_test.dart';
import 'package:campus_mesh/services/local_notice_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final db = LocalNoticeDatabase();

  group('LocalNoticeDatabase', () {
    test('Upsert and retrieve active notices', () async {
      await db.upsertNotices([
        {
          'id': 'n1',
          'title': 'Title 1',
          'content': 'Content 1',
          'type': 'announcement',
          'target_audience': 'all',
          'author_id': 'u1',
          'source': 'admin',
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        },
      ]);

      final rows = await db.getActiveNotices();
      expect(rows.length, greaterThanOrEqualTo(1));
      expect(rows.first['title'], 'Title 1');
    });

    test('Cleanup removes expired notices', () async {
      final pastDate =
          DateTime.now().subtract(const Duration(days: 40)).toIso8601String();
      await db.upsertNotices([
        {
          'id': 'expired',
          'title': 'Old',
          'content': 'Old content',
          'type': 'announcement',
          'target_audience': 'all',
          'author_id': 'u1',
          'source': 'admin',
          'is_active': true,
          'created_at': pastDate,
          'expires_at': pastDate,
        },
      ]);

      final deleted = await db.cleanupOldNotices(daysToKeep: 30);
      expect(deleted, greaterThanOrEqualTo(1));
    });
  });
}
