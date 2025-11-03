import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

/// Local database service for storing chat/conversation metadata offline
class LocalChatDatabase {
  static final LocalChatDatabase _instance = LocalChatDatabase._internal();
  factory LocalChatDatabase() => _instance;
  LocalChatDatabase._internal();

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
    final path = join(dbPath, 'campus_mesh_chats.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Chats/conversations table for offline storage
    await db.execute('''
      CREATE TABLE local_chats (
        id TEXT PRIMARY KEY,
        name TEXT,
        type TEXT NOT NULL,
        participant_ids TEXT NOT NULL,
        creator_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        synced_at TEXT,
        is_restricted INTEGER NOT NULL DEFAULT 0,
        restricted_by TEXT,
        restricted_at TEXT,
        restriction_reason TEXT,
        invite_code TEXT,
        last_message TEXT,
        last_message_at TEXT
      )
    ''');

    // Index for faster queries
    await db.execute('''
      CREATE INDEX idx_local_chats_type ON local_chats(type)
    ''');
    await db.execute('''
      CREATE INDEX idx_local_chats_creator ON local_chats(creator_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_local_chats_sync_status ON local_chats(sync_status)
    ''');

    debugPrint('Local chat database created successfully');
  }

  /// Save chat locally
  Future<void> saveChat(Map<String, dynamic> chat) async {
    final db = await database;
    await db.insert(
      'local_chats',
      chat,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('Chat saved locally: ${chat['id']}');
  }

  /// Get all pending chats for sync
  Future<List<Map<String, dynamic>>> getPendingChats() async {
    final db = await database;
    return await db.query(
      'local_chats',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
    );
  }

  /// Get chat by ID
  Future<Map<String, dynamic>?> getChat(String chatId) async {
    final db = await database;
    final results = await db.query(
      'local_chats',
      where: 'id = ?',
      whereArgs: [chatId],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Get all chats for a user
  Future<List<Map<String, dynamic>>> getUserChats(String userId) async {
    final db = await database;
    return await db.query(
      'local_chats',
      where: 'participant_ids LIKE ?',
      whereArgs: ['%$userId%'],
      orderBy: 'last_message_at DESC',
    );
  }

  /// Update chat sync status
  Future<void> updateChatSyncStatus(
    String chatId,
    String status, {
    String? syncedAt,
  }) async {
    final db = await database;
    final data = <String, dynamic>{
      'sync_status': status,
    };
    if (syncedAt != null) data['synced_at'] = syncedAt;

    await db.update(
      'local_chats',
      data,
      where: 'id = ?',
      whereArgs: [chatId],
    );
    debugPrint('Chat $chatId sync status updated to $status');
  }

  /// Update chat restriction status
  Future<void> updateChatRestriction(
    String chatId, {
    required bool isRestricted,
    String? restrictedBy,
    String? restrictedAt,
    String? reason,
  }) async {
    final db = await database;
    final data = <String, dynamic>{
      'is_restricted': isRestricted ? 1 : 0,
      'restricted_by': restrictedBy,
      'restricted_at': restrictedAt,
      'restriction_reason': reason,
    };

    await db.update(
      'local_chats',
      data,
      where: 'id = ?',
      whereArgs: [chatId],
    );
    debugPrint('Chat $chatId restriction updated: $isRestricted');
  }

  /// Update last message info
  Future<void> updateLastMessage(
    String chatId,
    String message,
    String timestamp,
  ) async {
    final db = await database;
    await db.update(
      'local_chats',
      {
        'last_message': message,
        'last_message_at': timestamp,
      },
      where: 'id = ?',
      whereArgs: [chatId],
    );
  }

  /// Get chat by invite code
  Future<Map<String, dynamic>?> getChatByInviteCode(String inviteCode) async {
    final db = await database;
    final results = await db.query(
      'local_chats',
      where: 'invite_code = ?',
      whereArgs: [inviteCode],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Delete chat
  Future<void> deleteChat(String chatId) async {
    final db = await database;
    await db.delete(
      'local_chats',
      where: 'id = ?',
      whereArgs: [chatId],
    );
    debugPrint('Chat deleted: $chatId');
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
