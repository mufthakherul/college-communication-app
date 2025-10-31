import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:campus_mesh/models/message_model.dart';
import 'package:campus_mesh/services/appwrite_service.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/appwrite_config.dart';

class MessageService {
  final _appwrite = AppwriteService();
  final _authService = AuthService();
  
  StreamController<List<MessageModel>>? _messagesController;
  StreamController<int>? _unreadCountController;

  // Get current user ID
  String? get _currentUserId => _authService.currentUserId;

  // Validate UUID format to prevent injection
  bool _isValidUuid(String uuid) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(uuid);
  }

  // Get messages between current user and another user
  Stream<List<MessageModel>> getMessages(String otherUserId) {
    final currentUserId = _currentUserId;
    if (currentUserId == null || !_isValidUuid(otherUserId)) {
      return Stream.value([]);
    }

    _messagesController ??= StreamController<List<MessageModel>>.broadcast(
      onListen: () => _startMessagesPolling(otherUserId),
      onCancel: () => _stopMessagesPolling(),
    );
    
    return _messagesController!.stream;
  }

  Timer? _messagesPollingTimer;
  String? _currentOtherUserId;
  
  void _startMessagesPolling(String otherUserId) {
    _currentOtherUserId = otherUserId;
    _fetchMessages(otherUserId);
    _messagesPollingTimer = Timer.periodic(
      const Duration(seconds: 3), 
      (_) => _fetchMessages(otherUserId),
    );
  }
  
  void _stopMessagesPolling() {
    _messagesPollingTimer?.cancel();
    _messagesPollingTimer = null;
    _currentOtherUserId = null;
  }
  
  Future<void> _fetchMessages(String otherUserId) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return;
    
    try {
      final docs = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        queries: [
          Query.or([
            Query.and([
              Query.equal('sender_id', currentUserId),
              Query.equal('recipient_id', otherUserId),
            ]),
            Query.and([
              Query.equal('sender_id', otherUserId),
              Query.equal('recipient_id', currentUserId),
            ]),
          ]),
          Query.orderAsc('created_at'),
          Query.limit(100),
        ],
      );
      
      final messages = docs.documents
          .map((doc) => MessageModel.fromJson(doc.data))
          .toList();
      
      _messagesController?.add(messages);
    } catch (e) {
      _messagesController?.addError(e);
    }
  }

  // Get recent conversations
  Stream<List<MessageModel>> getRecentConversations() async* {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      yield [];
      return;
    }

    while (true) {
      try {
        final docs = await _appwrite.databases.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.messagesCollectionId,
          queries: [
            Query.or([
              Query.equal('sender_id', currentUserId),
              Query.equal('recipient_id', currentUserId),
            ]),
            Query.orderDesc('created_at'),
            Query.limit(50),
          ],
        );
        
        final messages = docs.documents
            .map((doc) => MessageModel.fromJson(doc.data))
            .toList();
        
        yield messages;
      } catch (e) {
        yield [];
      }
      
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  // Send message
  Future<String> sendMessage({
    required String recipientId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    try {
      final currentUserId = _currentUserId;
      if (currentUserId == null) {
        throw Exception('User must be authenticated to send messages');
      }

      // Validate recipient ID format
      if (!_isValidUuid(recipientId)) {
        throw Exception('Invalid recipient ID format');
      }

      final document = await _appwrite.databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        documentId: ID.unique(),
        data: {
          'sender_id': currentUserId,
          'recipient_id': recipientId,
          'content': content,
          'type': type.name,
          'read': false,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      return document.$id;
    } on AppwriteException catch (e) {
      throw Exception('Failed to send message: ${e.message}');
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      final currentUserId = _currentUserId;
      if (currentUserId == null) {
        throw Exception('User must be authenticated to mark messages as read');
      }

      await _appwrite.databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        documentId: messageId,
        data: {
          'read': true,
          'read_at': DateTime.now().toIso8601String(),
        },
      );
    } on AppwriteException catch (e) {
      throw Exception('Failed to mark message as read: ${e.message}');
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  // Get unread message count
  Stream<int> getUnreadCount() {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      return Stream.value(0);
    }

    _unreadCountController ??= StreamController<int>.broadcast(
      onListen: () => _startUnreadCountPolling(),
      onCancel: () => _stopUnreadCountPolling(),
    );
    
    return _unreadCountController!.stream;
  }

  Timer? _unreadCountPollingTimer;
  
  void _startUnreadCountPolling() {
    _fetchUnreadCount();
    _unreadCountPollingTimer = Timer.periodic(
      const Duration(seconds: 5), 
      (_) => _fetchUnreadCount(),
    );
  }
  
  void _stopUnreadCountPolling() {
    _unreadCountPollingTimer?.cancel();
    _unreadCountPollingTimer = null;
  }
  
  Future<void> _fetchUnreadCount() async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      _unreadCountController?.add(0);
      return;
    }
    
    try {
      final docs = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        queries: [
          Query.equal('recipient_id', currentUserId),
          Query.equal('read', false),
        ],
      );
      
      _unreadCountController?.add(docs.total);
    } catch (e) {
      _unreadCountController?.add(0);
    }
  }
  
  // Clean up
  void dispose() {
    _stopMessagesPolling();
    _stopUnreadCountPolling();
    _messagesController?.close();
    _messagesController = null;
    _unreadCountController?.close();
    _unreadCountController = null;
  }
}
