import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:campus_mesh/services/app_logger_service.dart';
import 'package:campus_mesh/services/connectivity_service.dart';
import 'package:campus_mesh/services/notice_service.dart';
import 'package:campus_mesh/services/message_service.dart';
import 'package:campus_mesh/models/notice_model.dart';
import 'package:campus_mesh/models/message_model.dart';

/// Service to queue actions when offline and sync when online with retry logic
class OfflineQueueService {
  static final OfflineQueueService _instance = OfflineQueueService._internal();
  factory OfflineQueueService() => _instance;
  OfflineQueueService._internal();

  static const String _queueKey = 'offline_queue';
  static const String _analyticsKey = 'sync_analytics';
  static const int _maxQueueSize = 100;
  static const int _maxRetries = 3;
  static const Duration _queueExpiry = Duration(days: 7);

  final List<OfflineAction> _queue = [];
  final _connectivityService = ConnectivityService();
  final _noticeService = NoticeService();
  final _messageService = MessageService();

  // Analytics
  int _totalSynced = 0;
  int _totalFailed = 0;
  DateTime? _lastSyncAttempt;

  /// Add an action to the queue with priority and size management
  Future<void> addAction(OfflineAction action) async {
    // Remove expired actions
    _removeExpiredActions();

    // Check queue size limit
    if (_queue.length >= _maxQueueSize) {
      if (kDebugMode) {
        logger.warning(
          'Queue full, removing oldest low-priority action',
          category: 'OfflineQueue',
        );
      }
      _removeOldestLowPriorityAction();
    }

    _queue.add(action);
    _sortQueueByPriority();
    await _saveQueue();

    if (kDebugMode) {
      logger.debug(
        'Action queued: ${action.type} (priority: ${action.priority})',
        category: 'OfflineQueue',
      );
    }
  }

  /// Remove expired actions from queue
  void _removeExpiredActions() {
    final now = DateTime.now();
    _queue.removeWhere((action) {
      final age = now.difference(action.timestamp);
      return age > _queueExpiry;
    });
  }

  /// Remove oldest low-priority action
  void _removeOldestLowPriorityAction() {
    if (_queue.isEmpty) return;

    // Sort by priority (ascending) and timestamp (ascending)
    _queue.sort((a, b) {
      final priorityCompare = a.priority.compareTo(b.priority);
      if (priorityCompare != 0) return priorityCompare;
      return a.timestamp.compareTo(b.timestamp);
    });

    // Remove the first (lowest priority, oldest)
    if (_queue.isNotEmpty) {
      _queue.removeAt(0);
    }
  }

  /// Sort queue by priority (high to low)
  void _sortQueueByPriority() {
    _queue.sort((a, b) => b.priority.compareTo(a.priority));
  }

  /// Load queue from storage
  Future<void> loadQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey);
      if (queueJson != null) {
        final List<dynamic> decoded = jsonDecode(queueJson);
        _queue.clear();
        _queue.addAll(decoded.map((e) => OfflineAction.fromJson(e)));
      }
    } catch (e) {
      if (kDebugMode) {
        logger.error('Error loading queue', category: 'OfflineQueue', error: e);
      }
    }
  }

  /// Save queue to storage
  Future<void> _saveQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = jsonEncode(_queue.map((e) => e.toJson()).toList());
      await prefs.setString(_queueKey, queueJson);
    } catch (e) {
      if (kDebugMode) {
        logger.error('Error saving queue', category: 'OfflineQueue', error: e);
      }
    }
  }

  /// Get pending actions count
  int get pendingActionsCount => _queue.length;

  /// Get all pending actions
  List<OfflineAction> get pendingActions => List.unmodifiable(_queue);

  /// Process queue with retry logic and exponential backoff
  Future<void> processQueue() async {
    if (_queue.isEmpty) return;

    // Check if online and network quality is sufficient
    if (!_connectivityService.isOnline) {
      if (kDebugMode) {
        logger.info('Cannot process queue: offline', category: 'OfflineQueue');
      }
      return;
    }

    _lastSyncAttempt = DateTime.now();

    if (kDebugMode) {
      logger.info(
        'Processing ${_queue.length} queued actions',
        category: 'OfflineQueue',
      );
    }

    final actions = List<OfflineAction>.from(_queue);
    _queue.clear();

    int successCount = 0;
    int failureCount = 0;

    // Process actions with retry logic
    for (final action in actions) {
      bool success = false;
      Exception? lastError;

      // Retry with exponential backoff
      for (int attempt = 0;
          attempt <= action.retryCount && attempt < _maxRetries;
          attempt++) {
        try {
          if (attempt > 0) {
            // Exponential backoff: 1s, 2s, 4s
            final delaySeconds = pow(2, attempt - 1).toInt();
            if (kDebugMode) {
              logger.info(
                'Retrying action ${action.type} after ${delaySeconds}s (attempt ${attempt + 1})',
                category: 'OfflineQueue',
              );
            }
            await Future.delayed(Duration(seconds: delaySeconds));
          }

          await _executeAction(action);
          success = true;
          successCount++;

          if (kDebugMode) {
            logger.debug(
              '✓ Processed action: ${action.type}',
              category: 'OfflineQueue',
            );
          }
          break;
        } catch (e) {
          lastError = e is Exception ? e : Exception(e.toString());
          if (kDebugMode) {
            logger.warning(
              '✗ Error processing action ${action.type} (attempt ${attempt + 1})',
              category: 'OfflineQueue',
              metadata: {'error': e.toString()},
            );
          }
        }
      }

      // Re-queue failed actions if not exceeded max retries
      if (!success) {
        failureCount++;
        if (action.retryCount < _maxRetries) {
          final updatedAction = OfflineAction(
            type: action.type,
            data: action.data,
            timestamp: action.timestamp,
            retryCount: action.retryCount + 1,
            priority: action.priority,
            lastError: lastError?.toString(),
          );
          _queue.add(updatedAction);

          if (kDebugMode) {
            logger.info(
              'Re-queued failed action: ${action.type} (retry ${updatedAction.retryCount}/$_maxRetries)',
              category: 'OfflineQueue',
            );
          }
        } else {
          if (kDebugMode) {
            logger.warning(
              'Action ${action.type} exceeded max retries, dropping',
              category: 'OfflineQueue',
            );
          }
        }
      }
    }

    // Update analytics
    _totalSynced += successCount;
    _totalFailed += failureCount;
    await _saveAnalytics();

    // Save updated queue
    await _saveQueue();

    if (kDebugMode) {
      logger.info(
        'Queue processing complete: $successCount succeeded, $failureCount failed',
        category: 'OfflineQueue',
      );
    }

    // Update last sync time if any action succeeded
    if (successCount > 0) {
      _connectivityService.updateLastSyncTime();
    }
  }

  /// Execute a specific action based on its type
  Future<void> _executeAction(OfflineAction action) async {
    switch (action.type) {
      case 'create_notice':
        await _executeCreateNotice(action.data);
        break;
      case 'update_notice':
        await _executeUpdateNotice(action.data);
        break;
      case 'delete_notice':
        await _executeDeleteNotice(action.data);
        break;
      case 'send_message':
        await _executeSendMessage(action.data);
        break;
      case 'mark_message_read':
        await _executeMarkMessageRead(action.data);
        break;
      default:
        throw Exception('Unknown action type: ${action.type}');
    }
  }

  /// Execute create notice action
  Future<void> _executeCreateNotice(Map<String, dynamic> data) async {
    await _noticeService.createNotice(
      title: data['title'] as String,
      content: data['content'] as String,
      type: NoticeType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => NoticeType.announcement,
      ),
      targetAudience: data['targetAudience'] as String,
      expiresAt: data['expiresAt'] != null
          ? DateTime.parse(data['expiresAt'] as String)
          : null,
    );
  }

  /// Execute update notice action
  Future<void> _executeUpdateNotice(Map<String, dynamic> data) async {
    final updates = Map<String, dynamic>.from(data);
    final noticeId = updates.remove('noticeId') as String;

    await _noticeService.updateNotice(noticeId: noticeId, updates: updates);
  }

  /// Execute delete notice action
  Future<void> _executeDeleteNotice(Map<String, dynamic> data) async {
    await _noticeService.deleteNotice(data['noticeId'] as String);
  }

  /// Execute send message action
  Future<void> _executeSendMessage(Map<String, dynamic> data) async {
    await _messageService.sendMessage(
      recipientId: data['recipientId'] as String,
      content: data['content'] as String,
      type: data['type'] != null
          ? MessageType.values.firstWhere(
              (t) => t.name == data['type'],
              orElse: () => MessageType.text,
            )
          : MessageType.text,
    );
  }

  /// Execute mark message as read action
  Future<void> _executeMarkMessageRead(Map<String, dynamic> data) async {
    await _messageService.markMessageAsRead(data['messageId'] as String);
  }

  /// Clear all queued actions
  Future<void> clearQueue() async {
    _queue.clear();
    await _saveQueue();
  }

  /// Get sync analytics
  Map<String, dynamic> getAnalytics() {
    return {
      'totalSynced': _totalSynced,
      'totalFailed': _totalFailed,
      'lastSyncAttempt': _lastSyncAttempt?.toIso8601String(),
      'queueSize': _queue.length,
    };
  }

  /// Save analytics to storage
  Future<void> _saveAnalytics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final analyticsJson = jsonEncode({
        'totalSynced': _totalSynced,
        'totalFailed': _totalFailed,
        'lastSyncAttempt': _lastSyncAttempt?.toIso8601String(),
      });
      await prefs.setString(_analyticsKey, analyticsJson);
    } catch (e) {
      if (kDebugMode) {
        logger.error(
          'Error saving analytics',
          category: 'OfflineQueue',
          error: e,
        );
      }
    }
  }

  /// Load analytics from storage
  Future<void> loadAnalytics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final analyticsJson = prefs.getString(_analyticsKey);
      if (analyticsJson != null) {
        final decoded = jsonDecode(analyticsJson) as Map<String, dynamic>;
        _totalSynced = (decoded['totalSynced'] as int?) ?? 0;
        _totalFailed = (decoded['totalFailed'] as int?) ?? 0;
        _lastSyncAttempt = decoded['lastSyncAttempt'] != null
            ? DateTime.parse(decoded['lastSyncAttempt'] as String)
            : null;
      }
    } catch (e) {
      if (kDebugMode) {
        logger.error(
          'Error loading analytics',
          category: 'OfflineQueue',
          error: e,
        );
      }
    }
  }
}

/// Represents an offline action to be synced later with retry support
class OfflineAction {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;
  final int priority; // Higher number = higher priority
  final String? lastError;

  OfflineAction({
    required this.type,
    required this.data,
    DateTime? timestamp,
    this.retryCount = 0,
    this.priority = 5, // Default medium priority
    this.lastError,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'type': type,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
        'retryCount': retryCount,
        'priority': priority,
        'lastError': lastError,
      };

  factory OfflineAction.fromJson(Map<String, dynamic> json) => OfflineAction(
        type: json['type'] as String,
        data: json['data'] as Map<String, dynamic>,
        timestamp: DateTime.parse(json['timestamp'] as String),
        retryCount: json['retryCount'] ?? 0,
        priority: json['priority'] ?? 5,
        lastError: json['lastError'] as String?,
      );
}
