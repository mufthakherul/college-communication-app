import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Message delivery status
enum MessageDeliveryStatus {
  sending, // Message is being sent
  sent, // Message sent to server
  delivered, // Message delivered to recipient's device
  read, // Message read by recipient
  failed, // Message failed to send
}

/// Typing indicator status
enum TypingStatus {
  typing,
  stopped,
}

/// Message delivery tracking
class MessageDeliveryTracking {
  final String messageId;
  MessageDeliveryStatus status;
  DateTime? sentAt;
  DateTime? deliveredAt;
  DateTime? readAt;
  String? errorMessage;

  MessageDeliveryTracking({
    required this.messageId,
    this.status = MessageDeliveryStatus.sending,
    this.sentAt,
    this.deliveredAt,
    this.readAt,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'status': status.name,
        'sentAt': sentAt?.toIso8601String(),
        'deliveredAt': deliveredAt?.toIso8601String(),
        'readAt': readAt?.toIso8601String(),
        'errorMessage': errorMessage,
      };

  factory MessageDeliveryTracking.fromJson(Map<String, dynamic> json) =>
      MessageDeliveryTracking(
        messageId: json['messageId'] as String,
        status: MessageDeliveryStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => MessageDeliveryStatus.sending,
        ),
        sentAt: json['sentAt'] != null
            ? DateTime.parse(json['sentAt'] as String)
            : null,
        deliveredAt: json['deliveredAt'] != null
            ? DateTime.parse(json['deliveredAt'] as String)
            : null,
        readAt: json['readAt'] != null
            ? DateTime.parse(json['readAt'] as String)
            : null,
        errorMessage: json['errorMessage'] as String?,
      );
}

/// Typing indicator
class TypingIndicator {
  final String userId;
  final String conversationId;
  final TypingStatus status;
  final DateTime timestamp;

  TypingIndicator({
    required this.userId,
    required this.conversationId,
    required this.status,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'conversationId': conversationId,
        'status': status.name,
        'timestamp': timestamp.toIso8601String(),
      };

  factory TypingIndicator.fromJson(Map<String, dynamic> json) =>
      TypingIndicator(
        userId: json['userId'] as String,
        conversationId: json['conversationId'] as String,
        status: TypingStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => TypingStatus.stopped,
        ),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  bool get isStale {
    final now = DateTime.now();
    return now.difference(timestamp) > const Duration(seconds: 10);
  }
}

/// Service to track message delivery and typing indicators
class MessageDeliveryService {
  static final MessageDeliveryService _instance =
      MessageDeliveryService._internal();
  factory MessageDeliveryService() => _instance;
  MessageDeliveryService._internal();

  final _supabase = Supabase.instance.client;
  final Map<String, MessageDeliveryTracking> _deliveryTracking = {};
  final Map<String, TypingIndicator> _typingIndicators = {};
  final _deliveryStatusController =
      StreamController<MessageDeliveryTracking>.broadcast();
  final _typingController = StreamController<TypingIndicator>.broadcast();

  Timer? _typingCleanupTimer;
  Timer? _deliveryPollingTimer;
  String? _currentUserId;
  bool _isInitialized = false;

  /// Stream of delivery status updates
  Stream<MessageDeliveryTracking> get deliveryStatusStream =>
      _deliveryStatusController.stream;

  /// Stream of typing indicator updates
  Stream<TypingIndicator> get typingStream => _typingController.stream;

  /// Initialize service
  Future<void> initialize(String currentUserId) async {
    if (_isInitialized) return;

    try {
      _currentUserId = currentUserId;
      _isInitialized = true;

      // Start typing indicator cleanup timer
      _typingCleanupTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _cleanupStaleTypingIndicators(),
      );

      // Start delivery status polling (for messages waiting for delivery)
      _deliveryPollingTimer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => _pollDeliveryStatus(),
      );

      // Subscribe to real-time delivery updates
      _subscribeToDeliveryUpdates();

      // Subscribe to typing indicators
      _subscribeToTypingIndicators();

      if (kDebugMode) {
        print('Message delivery service initialized for user: $currentUserId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing message delivery service: $e');
      }
    }
  }

  /// Subscribe to real-time delivery updates
  void _subscribeToDeliveryUpdates() {
    _supabase
        .from('message_delivery_status')
        .stream(primaryKey: ['message_id'])
        .eq('recipient_id', _currentUserId!)
        .listen((List<Map<String, dynamic>> data) {
          for (final row in data) {
            final tracking = _parseDeliveryStatus(row);
            _updateDeliveryStatus(tracking);
          }
        });
  }

  /// Subscribe to typing indicators
  void _subscribeToTypingIndicators() {
    _supabase
        .from('typing_indicators')
        .stream(primaryKey: ['user_id', 'conversation_id'])
        .neq('user_id', _currentUserId!)
        .listen((List<Map<String, dynamic>> data) {
          for (final row in data) {
            final indicator = TypingIndicator.fromJson(row);
            _updateTypingIndicator(indicator);
          }
        });
  }

  /// Parse delivery status from database row
  MessageDeliveryTracking _parseDeliveryStatus(Map<String, dynamic> row) {
    return MessageDeliveryTracking(
      messageId: row['message_id'] as String,
      status: MessageDeliveryStatus.values.firstWhere(
        (s) => s.name == row['status'],
        orElse: () => MessageDeliveryStatus.sending,
      ),
      sentAt: row['sent_at'] != null
          ? DateTime.parse(row['sent_at'] as String)
          : null,
      deliveredAt: row['delivered_at'] != null
          ? DateTime.parse(row['delivered_at'] as String)
          : null,
      readAt: row['read_at'] != null
          ? DateTime.parse(row['read_at'] as String)
          : null,
    );
  }

  /// Track message delivery
  Future<void> trackMessageDelivery(
    String messageId, {
    MessageDeliveryStatus status = MessageDeliveryStatus.sending,
  }) async {
    final tracking = MessageDeliveryTracking(
      messageId: messageId,
      status: status,
      sentAt: status.index >= MessageDeliveryStatus.sent.index
          ? DateTime.now()
          : null,
    );

    _deliveryTracking[messageId] = tracking;
    _deliveryStatusController.add(tracking);

    // Update database
    await _updateDeliveryStatusInDatabase(tracking);
  }

  /// Update delivery status
  Future<void> updateDeliveryStatus(
    String messageId,
    MessageDeliveryStatus status, {
    String? errorMessage,
  }) async {
    var tracking = _deliveryTracking[messageId];

    if (tracking == null) {
      tracking = MessageDeliveryTracking(messageId: messageId, status: status);
      _deliveryTracking[messageId] = tracking;
    }

    tracking.status = status;
    tracking.errorMessage = errorMessage;

    switch (status) {
      case MessageDeliveryStatus.sent:
        tracking.sentAt ??= DateTime.now();
        break;
      case MessageDeliveryStatus.delivered:
        tracking.deliveredAt ??= DateTime.now();
        break;
      case MessageDeliveryStatus.read:
        tracking.readAt ??= DateTime.now();
        break;
      default:
        break;
    }

    _deliveryStatusController.add(tracking);

    // Update database
    await _updateDeliveryStatusInDatabase(tracking);
  }

  /// Update delivery status in database
  Future<void> _updateDeliveryStatusInDatabase(
    MessageDeliveryTracking tracking,
  ) async {
    try {
      await _supabase.from('message_delivery_status').upsert({
        'message_id': tracking.messageId,
        'status': tracking.status.name,
        'sent_at': tracking.sentAt?.toIso8601String(),
        'delivered_at': tracking.deliveredAt?.toIso8601String(),
        'read_at': tracking.readAt?.toIso8601String(),
        'error_message': tracking.errorMessage,
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (kDebugMode) {
        print(
          'Updated delivery status for ${tracking.messageId}: ${tracking.status.name}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating delivery status: $e');
      }
    }
  }

  /// Update internal tracking
  void _updateDeliveryStatus(MessageDeliveryTracking tracking) {
    _deliveryTracking[tracking.messageId] = tracking;
    _deliveryStatusController.add(tracking);
  }

  /// Get delivery status
  MessageDeliveryTracking? getDeliveryStatus(String messageId) {
    return _deliveryTracking[messageId];
  }

  /// Get all tracked messages
  List<MessageDeliveryTracking> getAllTracking() {
    return _deliveryTracking.values.toList();
  }

  /// Poll delivery status for pending messages
  Future<void> _pollDeliveryStatus() async {
    final pendingMessages = _deliveryTracking.entries
        .where((e) =>
            e.value.status == MessageDeliveryStatus.sending ||
            e.value.status == MessageDeliveryStatus.sent)
        .map((e) => e.key)
        .toList();

    if (pendingMessages.isEmpty) return;

    try {
      final response = await _supabase
          .from('message_delivery_status')
          .select()
          .inFilter('message_id', pendingMessages);

      for (final row in response) {
        final tracking = _parseDeliveryStatus(row);
        _updateDeliveryStatus(tracking);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error polling delivery status: $e');
      }
    }
  }

  /// Send typing indicator
  Future<void> sendTypingIndicator(
    String conversationId,
    TypingStatus status,
  ) async {
    if (!_isInitialized || _currentUserId == null) return;

    try {
      final indicator = TypingIndicator(
        userId: _currentUserId!,
        conversationId: conversationId,
        status: status,
      );

      // Update database
      await _supabase.from('typing_indicators').upsert({
        'user_id': indicator.userId,
        'conversation_id': indicator.conversationId,
        'status': indicator.status.name,
        'timestamp': indicator.timestamp.toIso8601String(),
      });

      if (kDebugMode) {
        print(
          'Sent typing indicator for conversation $conversationId: ${status.name}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending typing indicator: $e');
      }
    }
  }

  /// Update typing indicator
  void _updateTypingIndicator(TypingIndicator indicator) {
    final key = '${indicator.userId}_${indicator.conversationId}';
    _typingIndicators[key] = indicator;
    _typingController.add(indicator);
  }

  /// Get typing users in conversation
  List<String> getTypingUsers(String conversationId) {
    return _typingIndicators.entries
        .where((e) =>
            e.value.conversationId == conversationId &&
            e.value.status == TypingStatus.typing &&
            !e.value.isStale)
        .map((e) => e.value.userId)
        .toList();
  }

  /// Clean up stale typing indicators
  void _cleanupStaleTypingIndicators() {
    _typingIndicators.removeWhere((key, indicator) => indicator.isStale);
  }

  /// Mark message as delivered
  Future<void> markAsDelivered(String messageId) async {
    await updateDeliveryStatus(messageId, MessageDeliveryStatus.delivered);
  }

  /// Mark message as read
  Future<void> markAsRead(String messageId) async {
    await updateDeliveryStatus(messageId, MessageDeliveryStatus.read);
  }

  /// Mark multiple messages as read
  Future<void> markMultipleAsRead(List<String> messageIds) async {
    for (final messageId in messageIds) {
      await markAsRead(messageId);
    }
  }

  /// Get delivery statistics
  Map<String, dynamic> getStatistics() {
    final stats = {
      'totalTracked': _deliveryTracking.length,
      'sending': 0,
      'sent': 0,
      'delivered': 0,
      'read': 0,
      'failed': 0,
      'activeTypingIndicators': _typingIndicators.values
          .where((i) => !i.isStale && i.status == TypingStatus.typing)
          .length,
    };

    for (final tracking in _deliveryTracking.values) {
      switch (tracking.status) {
        case MessageDeliveryStatus.sending:
          stats['sending'] = (stats['sending'] as int) + 1;
          break;
        case MessageDeliveryStatus.sent:
          stats['sent'] = (stats['sent'] as int) + 1;
          break;
        case MessageDeliveryStatus.delivered:
          stats['delivered'] = (stats['delivered'] as int) + 1;
          break;
        case MessageDeliveryStatus.read:
          stats['read'] = (stats['read'] as int) + 1;
          break;
        case MessageDeliveryStatus.failed:
          stats['failed'] = (stats['failed'] as int) + 1;
          break;
      }
    }

    return stats;
  }

  /// Clear old tracking data
  Future<void> clearOldTracking({Duration age = const Duration(days: 7)}) async {
    final cutoff = DateTime.now().subtract(age);

    _deliveryTracking.removeWhere((key, tracking) {
      final timestamp =
          tracking.readAt ??
          tracking.deliveredAt ??
          tracking.sentAt ??
          DateTime.now();
      return timestamp.isBefore(cutoff);
    });

    if (kDebugMode) {
      print('Cleared old tracking data older than $age');
    }
  }

  /// Dispose resources
  void dispose() {
    _typingCleanupTimer?.cancel();
    _deliveryPollingTimer?.cancel();
    _deliveryStatusController.close();
    _typingController.close();
    _isInitialized = false;
  }
}
