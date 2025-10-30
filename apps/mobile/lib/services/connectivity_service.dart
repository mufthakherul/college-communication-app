import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service to monitor network connectivity status
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final _connectivityController = StreamController<bool>.broadcast();
  bool _isOnline = true;
  DateTime? _lastSyncTime;

  /// Stream of connectivity status changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Current connectivity status
  bool get isOnline => _isOnline;

  /// Last successful sync time
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Set connectivity status (for testing and future real connectivity checks)
  void setConnectivity(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      _connectivityController.add(_isOnline);
      if (kDebugMode) {
        print('Connectivity changed: ${_isOnline ? "Online" : "Offline"}');
      }
    }
  }

  /// Update last sync time
  void updateLastSyncTime() {
    _lastSyncTime = DateTime.now();
  }

  /// Get human-readable last sync time
  String getLastSyncTimeText() {
    if (_lastSyncTime == null) {
      return 'Never synced';
    }

    final now = DateTime.now();
    final difference = now.difference(_lastSyncTime!);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void dispose() {
    _connectivityController.close();
  }
}
