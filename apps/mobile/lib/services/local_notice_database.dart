import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Local database service for storing notices offline
class LocalNoticeDatabase {
  factory LocalNoticeDatabase() => _instance;
  LocalNoticeDatabase._internal();
  static final LocalNoticeDatabase _instance = LocalNoticeDatabase._internal();

  Database? _database;

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'campus_mesh_notices.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE local_notices (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        type TEXT NOT NULL,
        target_audience TEXT NOT NULL,
        author_id TEXT,
        source TEXT NOT NULL,
        source_url TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT,
        updated_at TEXT,
        expires_at TEXT,
        cached_at TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_local_notices_active ON local_notices(is_active)',
    );
    await db.execute(
      'CREATE INDEX idx_local_notices_created ON local_notices(created_at)',
    );

    debugPrint('Local notice database created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Placeholder for future upgrades
    debugPrint('LocalNoticeDatabase upgraded from $oldVersion to $newVersion');
  }

  /// Upsert a batch of notices
  Future<void> upsertNotices(List<Map<String, dynamic>> notices) async {
    if (notices.isEmpty) return;
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();
    for (final n in notices) {
      final data = {
        'id': n['id'] ?? n['\$id'] ?? '',
        'title': n['title'],
        'content': n['content'],
        'type': n['type'],
        'target_audience': n['target_audience'] ?? n['targetAudience'] ?? 'all',
        'author_id': n['author_id'] ?? n['authorId'],
        'source': n['source'] ?? 'admin',
        'source_url': n['source_url'],
        'is_active': (n['is_active'] ?? true) ? 1 : 0,
        'created_at': n['created_at'],
        'updated_at': n['updated_at'],
        'expires_at': n['expires_at'],
        'cached_at': now,
      };
      batch.insert(
        'local_notices',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Get cached active notices
  Future<List<Map<String, dynamic>>> getActiveNotices({int limit = 100}) async {
    final db = await database;
    return db.query(
      'local_notices',
      where: 'is_active = 1',
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  /// Clear all notices
  Future<int> clearAll() async {
    final db = await database;
    return db.delete('local_notices');
  }

  /// Delete notices older than [daysToKeep] or expired
  Future<int> cleanupOldNotices({int daysToKeep = 30}) async {
    final db = await database;
    final cutoff = DateTime.now()
        .subtract(Duration(days: daysToKeep))
        .toIso8601String();

    // Delete expired by expires_at OR cached_at older than cutoff
    final deleted = await db.delete(
      'local_notices',
      where: '(expires_at IS NOT NULL AND expires_at < ?) OR cached_at < ?',
      whereArgs: [cutoff, cutoff],
    );
    return deleted;
  }
}
