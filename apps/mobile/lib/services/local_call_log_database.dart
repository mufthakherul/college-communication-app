import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalCallLogDatabase {
  factory LocalCallLogDatabase() => _instance;
  LocalCallLogDatabase._internal();
  static final LocalCallLogDatabase _instance =
      LocalCallLogDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'campus_mesh_calls.db');
    _db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE call_logs (
        id TEXT PRIMARY KEY,
        peer_id TEXT NOT NULL,
        is_video INTEGER NOT NULL,
        started_at TEXT NOT NULL,
        ended_at TEXT,
        status TEXT NOT NULL,
        error TEXT
      )
    ''');
    await db.execute('CREATE INDEX idx_call_peer ON call_logs(peer_id)');
    debugPrint('Local call log database created');
  }

  Future<void> logStart({
    required String id,
    required String peerId,
    required bool isVideo,
    required String startedAt,
  }) async {
    final db = await database;
    await db.insert('call_logs', {
      'id': id,
      'peer_id': peerId,
      'is_video': isVideo ? 1 : 0,
      'started_at': startedAt,
      'status': 'ongoing',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> logEnd({
    required String id,
    required String endedAt,
    required String status,
    String? error,
  }) async {
    final db = await database;
    await db.update(
      'call_logs',
      {
        'ended_at': endedAt,
        'status': status,
        if (error != null) 'error': error,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> cleanupOld({int daysToKeep = 30}) async {
    final db = await database;
    final cutoff = DateTime.now()
        .subtract(Duration(days: daysToKeep))
        .toIso8601String();
    return db.delete(
      'call_logs',
      where: 'ended_at IS NOT NULL AND ended_at < ?',
      whereArgs: [cutoff],
    );
  }

  Future<List<Map<String, dynamic>>> recent({int limit = 50}) async {
    final db = await database;
    return db.query('call_logs', orderBy: 'started_at DESC', limit: limit);
  }
}
