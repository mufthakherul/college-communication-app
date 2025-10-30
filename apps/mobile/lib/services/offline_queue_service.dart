import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Service to queue actions when offline and sync when online
class OfflineQueueService {
  static final OfflineQueueService _instance = OfflineQueueService._internal();
  factory OfflineQueueService() => _instance;
  OfflineQueueService._internal();

  static const String _queueKey = 'offline_queue';
  final List<OfflineAction> _queue = [];

  /// Add an action to the queue
  Future<void> addAction(OfflineAction action) async {
    _queue.add(action);
    await _saveQueue();
    if (kDebugMode) {
      print('Action queued: ${action.type}');
    }
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
        print('Error loading queue: $e');
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
        print('Error saving queue: $e');
      }
    }
  }

  /// Get pending actions count
  int get pendingActionsCount => _queue.length;

  /// Get all pending actions
  List<OfflineAction> get pendingActions => List.unmodifiable(_queue);

  /// Process queue (to be called when back online)
  Future<void> processQueue() async {
    if (_queue.isEmpty) return;

    if (kDebugMode) {
      print('Processing ${_queue.length} queued actions');
    }

    final actions = List<OfflineAction>.from(_queue);
    _queue.clear();
    await _saveQueue();

    // Process actions (implementation depends on specific action types)
    for (final action in actions) {
      try {
        // TODO: Implement actual processing based on action type
        if (kDebugMode) {
          print('Processed action: ${action.type}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error processing action: $e');
        }
        // Re-queue failed actions
        await addAction(action);
      }
    }
  }

  /// Clear all queued actions
  Future<void> clearQueue() async {
    _queue.clear();
    await _saveQueue();
  }
}

/// Represents an offline action to be synced later
class OfflineAction {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  OfflineAction({
    required this.type,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'type': type,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
      };

  factory OfflineAction.fromJson(Map<String, dynamic> json) => OfflineAction(
        type: json['type'] as String,
        data: json['data'] as Map<String, dynamic>,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
