import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Network quality levels
enum NetworkQuality {
  excellent, // High speed, low latency
  good, // Normal speed
  poor, // Slow connection
  offline, // No connection
}

/// Service to monitor network connectivity status with automatic detection
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal() {
    _initConnectivityListener();
  }

  final _connectivity = Connectivity();
  final _connectivityController = StreamController<bool>.broadcast();
  final _networkQualityController =
      StreamController<NetworkQuality>.broadcast();

  bool _isOnline = true;
  DateTime? _lastSyncTime;
  NetworkQuality _networkQuality = NetworkQuality.good;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Stream of connectivity status changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Stream of network quality changes
  Stream<NetworkQuality> get networkQualityStream =>
      _networkQualityController.stream;

  /// Current connectivity status
  bool get isOnline => _isOnline;

  /// Current network quality
  NetworkQuality get networkQuality => _networkQuality;

  /// Last successful sync time
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Initialize automatic connectivity listener
  void _initConnectivityListener() {
    // Check initial connectivity
    _checkConnectivity();

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _handleConnectivityChange(results);
      },
      onError: (error) {
        if (kDebugMode) {
          print('Connectivity listener error: $error');
        }
      },
    );
  }

  /// Handle connectivity changes
  Future<void> _handleConnectivityChange(
    List<ConnectivityResult> results,
  ) async {
    final hasConnection = results.isNotEmpty &&
        results.any((result) => result != ConnectivityResult.none);

    final wasOnline = _isOnline;
    _isOnline = hasConnection;

    if (wasOnline != _isOnline) {
      _connectivityController.add(_isOnline);
      if (kDebugMode) {
        print('Connectivity changed: ${_isOnline ? "Online" : "Offline"}');
        if (_isOnline) {
          print('Connection types: ${results.map((r) => r.name).join(", ")}');
        }
      }
    }

    // Update network quality based on connection type
    if (hasConnection) {
      await _updateNetworkQuality(results);
    } else {
      _updateNetworkQualityValue(NetworkQuality.offline);
    }
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      await _handleConnectivityChange(results);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connectivity: $e');
      }
    }
  }

  /// Update network quality based on connection type
  Future<void> _updateNetworkQuality(List<ConnectivityResult> results) async {
    NetworkQuality quality = NetworkQuality.good;

    if (results.contains(ConnectivityResult.ethernet) ||
        results.contains(ConnectivityResult.wifi)) {
      // WiFi/Ethernet typically provides good quality
      quality = NetworkQuality.excellent;
    } else if (results.contains(ConnectivityResult.mobile)) {
      // Mobile data - assume good quality (could be enhanced with speed test)
      quality = NetworkQuality.good;
    } else if (results.contains(ConnectivityResult.bluetooth) ||
        results.contains(ConnectivityResult.vpn)) {
      // Bluetooth or VPN might be slower
      quality = NetworkQuality.poor;
    }

    _updateNetworkQualityValue(quality);
  }

  /// Update network quality value and notify listeners
  void _updateNetworkQualityValue(NetworkQuality quality) {
    if (_networkQuality != quality) {
      _networkQuality = quality;
      _networkQualityController.add(_networkQuality);
      if (kDebugMode) {
        print('Network quality changed: ${_networkQuality.name}');
      }
    }
  }

  /// Set connectivity status (for testing and manual control)
  void setConnectivity(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      _connectivityController.add(_isOnline);
      _updateNetworkQualityValue(
        isOnline ? NetworkQuality.good : NetworkQuality.offline,
      );
      if (kDebugMode) {
        print('Connectivity manually set: ${_isOnline ? "Online" : "Offline"}');
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

  /// Get network quality description
  String getNetworkQualityText() {
    switch (_networkQuality) {
      case NetworkQuality.excellent:
        return 'Excellent';
      case NetworkQuality.good:
        return 'Good';
      case NetworkQuality.poor:
        return 'Poor';
      case NetworkQuality.offline:
        return 'Offline';
    }
  }

  /// Check if network quality is sufficient for operation
  bool get isNetworkQualitySufficient =>
      _networkQuality != NetworkQuality.offline &&
      _networkQuality != NetworkQuality.poor;

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
    _networkQualityController.close();
  }
}
