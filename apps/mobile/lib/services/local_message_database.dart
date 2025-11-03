import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

/// Local database service for storing messages offline
class LocalMessageDatabase {
  static final LocalMessageDatabase _instance =
      LocalMessageDatabase._internal();
  factory LocalMessageDatabase() => _instance;
  LocalMessageDatabase._internal();

  Database? _database;

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'campus_mesh_messages.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Messages table for offline storage
    await db.execute('''
      CREATE TABLE local_messages (
        id TEXT PRIMARY KEY,
        sender_id TEXT NOT NULL,
        recipient_id TEXT NOT NULL,
        content TEXT NOT NULL,
        type TEXT NOT NULL,
        is_group_message INTEGER NOT NULL DEFAULT 0,
        group_id TEXT,
        created_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        approval_status TEXT,
        approved_by TEXT,
        approved_at TEXT,
        synced_at TEXT,
        retry_count INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        local_file_path TEXT,
        attachment_type TEXT
      )
    ''');

    // Index for faster queries
    await db.execute('''
      CREATE INDEX idx_local_messages_sender ON local_messages(sender_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_local_messages_recipient ON local_messages(recipient_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_local_messages_group ON local_messages(group_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_local_messages_sync_status ON local_messages(sync_status)
    ''');

    debugPrint('Local message database created successfully');
  }

  /// Upgrade database schema
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future schema upgrades
    debugPrint('Database upgraded from version $oldVersion to $newVersion');
  }

  /// Save message locally
  Future<void> saveMessage(Map<String, dynamic> message) async {
    final db = await database;
    // Use ignore to prevent overwriting existing messages
    // This prevents data loss if message exists from another source
    await db.insert(
      'local_messages',
      message,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    debugPrint('Message saved locally: ${message['id']}');
  }

  /// Get all pending messages for sync
  Future<List<Map<String, dynamic>>> getPendingMessages() async {
    final db = await database;
    return await db.query(
      'local_messages',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
    );
  }

  /// Get messages for a conversation
  Future<List<Map<String, dynamic>>> getConversationMessages(
    String userId1,
    String userId2,
  ) async {
    final db = await database;
    return await db.query(
      'local_messages',
      where: '(sender_id = ? AND recipient_id = ?) OR '
          '(sender_id = ? AND recipient_id = ?)',
      whereArgs: [userId1, userId2, userId2, userId1],
      orderBy: 'created_at ASC',
    );
  }

  /// Get group messages
  Future<List<Map<String, dynamic>>> getGroupMessages(String groupId) async {
    final db = await database;
    return await db.query(
      'local_messages',
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'created_at ASC',
    );
  }

  /// Update message sync status
  Future<void> updateMessageSyncStatus(
    String messageId,
    String status, {
    String? syncedAt,
    String? error,
  }) async {
    final db = await database;
    final data = <String, dynamic>{
      'sync_status': status,
    };
    if (syncedAt != null) data['synced_at'] = syncedAt;
    if (error != null) data['last_error'] = error;

    await db.update(
      'local_messages',
      data,
      where: 'id = ?',
      whereArgs: [messageId],
    );
    debugPrint('Message $messageId sync status updated to $status');
  }

  /// Update message approval status
  Future<void> updateMessageApprovalStatus(
    String messageId,
    String status, {
    String? approvedBy,
    String? approvedAt,
  }) async {
    final db = await database;
    final data = <String, dynamic>{
      'approval_status': status,
    };
    if (approvedBy != null) data['approved_by'] = approvedBy;
    if (approvedAt != null) data['approved_at'] = approvedAt;

    await db.update(
      'local_messages',
      data,
      where: 'id = ?',
      whereArgs: [messageId],
    );
    debugPrint('Message $messageId approval status updated to $status');
  }

  /// Increment retry count
  Future<void> incrementRetryCount(String messageId) async {
    final db = await database;
    await db.rawUpdate('''
      UPDATE local_messages 
      SET retry_count = retry_count + 1 
      WHERE id = ?
    ''', [messageId]);
  }

  /// Delete synced messages older than specified days
  Future<int> cleanupSyncedMessages({int daysToKeep = 7}) async {
    final db = await database;
    final cutoffDate =
        DateTime.now().subtract(Duration(days: daysToKeep)).toIso8601String();

    return await db.delete(
      'local_messages',
      where: 'sync_status = ? AND synced_at < ?',
      whereArgs: ['synced', cutoffDate],
    );
  }

  /// Get message by ID
  Future<Map<String, dynamic>?> getMessage(String messageId) async {
    final db = await database;
    final results = await db.query(
      'local_messages',
      where: 'id = ?',
      whereArgs: [messageId],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Delete message
  Future<void> deleteMessage(String messageId) async {
    final db = await database;
    await db.delete(
      'local_messages',
      where: 'id = ?',
      whereArgs: [messageId],
    );
    debugPrint('Message deleted: $messageId');
  }

  /// Get sync statistics
  Future<Map<String, int>> getSyncStatistics() async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT 
        sync_status,
        COUNT(*) as count
      FROM local_messages
      GROUP BY sync_status
    ''');

    final stats = <String, int>{};
    for (final row in results) {
      stats[row['sync_status'] as String] = row['count'] as int;
    }
    return stats;
  }

  /// Close database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
