import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:campus_mesh/models/ai_chat_message_model.dart';
import 'package:campus_mesh/models/ai_chat_session_model.dart';

class AIChatDatabase {
  static final AIChatDatabase _instance = AIChatDatabase._internal();
  static Database? _database;

  factory AIChatDatabase() => _instance;

  AIChatDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ai_chat.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create sessions table
        await db.execute('''
          CREATE TABLE sessions (
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            title TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            lastMessageAt TEXT NOT NULL,
            messageCount INTEGER NOT NULL
          )
        ''');

        // Create messages table
        await db.execute('''
          CREATE TABLE messages (
            id TEXT PRIMARY KEY,
            sessionId TEXT NOT NULL,
            content TEXT NOT NULL,
            isUser INTEGER NOT NULL,
            timestamp TEXT NOT NULL,
            FOREIGN KEY (sessionId) REFERENCES sessions (id) ON DELETE CASCADE
          )
        ''');

        // Create indexes
        await db
            .execute('CREATE INDEX idx_sessions_userId ON sessions (userId)');
        await db.execute(
            'CREATE INDEX idx_messages_sessionId ON messages (sessionId)');
      },
    );
  }

  // Session operations
  Future<String> createSession(AIChatSession session) async {
    final db = await database;
    await db.insert('sessions', session.toMap());
    return session.id;
  }

  Future<List<AIChatSession>> getSessions(String userId) async {
    final db = await database;
    final maps = await db.query(
      'sessions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'lastMessageAt DESC',
    );
    return maps.map((map) => AIChatSession.fromMap(map)).toList();
  }

  Future<AIChatSession?> getSession(String sessionId) async {
    final db = await database;
    final maps = await db.query(
      'sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return AIChatSession.fromMap(maps.first);
  }

  Future<void> updateSession(AIChatSession session) async {
    final db = await database;
    await db.update(
      'sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<void> deleteSession(String sessionId) async {
    final db = await database;
    await db.delete(
      'sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  // Message operations
  Future<String> addMessage(AIChatMessage message) async {
    final db = await database;
    await db.insert('messages', message.toMap());
    return message.id;
  }

  Future<List<AIChatMessage>> getMessages(String sessionId) async {
    final db = await database;
    final maps = await db.query(
      'messages',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );
    return maps.map((map) => AIChatMessage.fromMap(map)).toList();
  }

  Future<void> deleteMessage(String messageId) async {
    final db = await database;
    await db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  Future<void> deleteAllMessagesInSession(String sessionId) async {
    final db = await database;
    await db.delete(
      'messages',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
    );
  }

  // Clear all data (for logout)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('messages');
    await db.delete('sessions');
  }

  // Get message count for a session
  Future<int> getMessageCount(String sessionId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM messages WHERE sessionId = ?',
      [sessionId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
