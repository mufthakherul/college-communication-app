import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'connectivity_service.dart';

/// Mesh network node information
class MeshNode {
  final String id;
  final String name;
  final DateTime connectedAt;
  final String connectionType; // 'bluetooth', 'wifi-direct'
  bool isActive;

  MeshNode({
    required this.id,
    required this.name,
    required this.connectedAt,
    required this.connectionType,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'connectedAt': connectedAt.toIso8601String(),
        'connectionType': connectionType,
        'isActive': isActive,
      };

  factory MeshNode.fromJson(Map<String, dynamic> json) => MeshNode(
        id: json['id'] as String,
        name: json['name'] as String,
        connectedAt: DateTime.parse(json['connectedAt'] as String),
        connectionType: json['connectionType'] as String,
        isActive: json['isActive'] ?? true,
      );
}

/// Mesh message for peer-to-peer communication
class MeshMessage {
  final String id;
  final String senderId;
  final String type; // 'notice', 'message', 'sync_request', 'sync_response'
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  final List<String> routePath; // Track message route to prevent loops

  MeshMessage({
    required this.id,
    required this.senderId,
    required this.type,
    required this.payload,
    DateTime? timestamp,
    List<String>? routePath,
  })  : timestamp = timestamp ?? DateTime.now(),
        routePath = routePath ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'type': type,
        'payload': payload,
        'timestamp': timestamp.toIso8601String(),
        'routePath': routePath,
      };

  factory MeshMessage.fromJson(Map<String, dynamic> json) => MeshMessage(
        id: json['id'] as String,
        senderId: json['senderId'] as String,
        type: json['type'] as String,
        payload: json['payload'] as Map<String, dynamic>,
        timestamp: DateTime.parse(json['timestamp'] as String),
        routePath: (json['routePath'] as List?)?.cast<String>() ?? [],
      );

  MeshMessage copyWithRoute(String nodeId) {
    return MeshMessage(
      id: id,
      senderId: senderId,
      type: type,
      payload: payload,
      timestamp: timestamp,
      routePath: [...routePath, nodeId],
    );
  }
}

/// Mesh network service for peer-to-peer communication
/// Enables communication even without internet using Bluetooth and WiFi Direct
class MeshNetworkService {
  static final MeshNetworkService _instance = MeshNetworkService._internal();
  factory MeshNetworkService() => _instance;
  MeshNetworkService._internal();

  final _connectivityService = ConnectivityService();
  NearbyService? _nearbyService;
  
  final Map<String, MeshNode> _connectedNodes = {};
  final List<MeshMessage> _messageHistory = [];
  final _messageController = StreamController<MeshMessage>.broadcast();
  final _nodeController = StreamController<List<MeshNode>>.broadcast();
  
  bool _isInitialized = false;
  bool _isAdvertising = false;
  bool _isDiscovering = false;
  String? _deviceId;
  String? _deviceName;

  static const int _maxMessageHistory = 1000;
  static const Duration _nodeTimeout = Duration(minutes: 5);

  /// Stream of incoming mesh messages
  Stream<MeshMessage> get messageStream => _messageController.stream;

  /// Stream of connected nodes updates
  Stream<List<MeshNode>> get nodesStream => _nodeController.stream;

  /// List of currently connected nodes
  List<MeshNode> get connectedNodes => _connectedNodes.values.toList();

  /// Check if mesh network is active
  bool get isActive => _isInitialized && (_isAdvertising || _isDiscovering);

  /// Initialize mesh network service
  Future<void> initialize({
    required String deviceId,
    required String deviceName,
  }) async {
    if (_isInitialized) return;

    try {
      _deviceId = deviceId;
      _deviceName = deviceName;

      _nearbyService = NearbyService();
      
      // Initialize the nearby service
      await _nearbyService!.init(
        serviceType: 'campus-mesh',
        deviceName: deviceName,
        strategy: Strategy.P2P_CLUSTER,
        callback: (isRunning) {
          if (kDebugMode) {
            print('Nearby service running: $isRunning');
          }
        },
      );

      _isInitialized = true;

      if (kDebugMode) {
        print('Mesh network initialized: $deviceName ($deviceId)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing mesh network: $e');
      }
    }
  }

  /// Start advertising (make device discoverable)
  Future<void> startAdvertising() async {
    if (!_isInitialized || _isAdvertising) return;

    try {
      await _nearbyService!.startAdvertising(
        deviceName: _deviceName!,
        discovery: true,
      );

      _isAdvertising = true;

      if (kDebugMode) {
        print('Started advertising mesh network');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error starting advertising: $e');
      }
    }
  }

  /// Stop advertising
  Future<void> stopAdvertising() async {
    if (!_isAdvertising) return;

    try {
      await _nearbyService!.stopAdvertising();
      _isAdvertising = false;

      if (kDebugMode) {
        print('Stopped advertising');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping advertising: $e');
      }
    }
  }

  /// Start discovering nearby devices
  Future<void> startDiscovery() async {
    if (!_isInitialized || _isDiscovering) return;

    try {
      await _nearbyService!.startBrowsing(
        discovery: true,
        callback: _handleDeviceDiscovered,
      );

      _isDiscovering = true;

      if (kDebugMode) {
        print('Started discovering devices');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error starting discovery: $e');
      }
    }
  }

  /// Stop discovering
  Future<void> stopDiscovery() async {
    if (!_isDiscovering) return;

    try {
      await _nearbyService!.stopBrowsing();
      _isDiscovering = false;

      if (kDebugMode) {
        print('Stopped discovering');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping discovery: $e');
      }
    }
  }

  /// Handle discovered device
  void _handleDeviceDiscovered(Device device) {
    if (kDebugMode) {
      print('Discovered device: ${device.deviceName} (${device.deviceId})');
    }

    // Try to connect to the device
    _connectToDevice(device);
  }

  /// Connect to a discovered device
  Future<void> _connectToDevice(Device device) async {
    try {
      await _nearbyService!.connectToDevice(device);

      // Add to connected nodes
      final node = MeshNode(
        id: device.deviceId,
        name: device.deviceName,
        connectedAt: DateTime.now(),
        connectionType: 'bluetooth', // Could be wifi-direct based on strategy
      );

      _connectedNodes[device.deviceId] = node;
      _nodeController.add(connectedNodes);

      if (kDebugMode) {
        print('Connected to device: ${device.deviceName}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error connecting to device: $e');
      }
    }
  }

  /// Disconnect from a device
  Future<void> disconnectFromDevice(String deviceId) async {
    try {
      final node = _connectedNodes[deviceId];
      if (node != null) {
        // Disconnect logic would go here
        _connectedNodes.remove(deviceId);
        _nodeController.add(connectedNodes);

        if (kDebugMode) {
          print('Disconnected from device: ${node.name}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error disconnecting: $e');
      }
    }
  }

  /// Send message to specific node
  Future<void> sendMessage(String recipientId, MeshMessage message) async {
    try {
      final node = _connectedNodes[recipientId];
      if (node == null || !node.isActive) {
        throw Exception('Node not connected: $recipientId');
      }

      final jsonStr = jsonEncode(message.toJson());
      await _nearbyService!.sendMessage(recipientId, jsonStr);

      if (kDebugMode) {
        print('Sent message to ${node.name}: ${message.type}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
      rethrow;
    }
  }

  /// Broadcast message to all connected nodes
  Future<void> broadcastMessage(MeshMessage message) async {
    // Add self to route path to prevent echo
    final routedMessage = message.copyWithRoute(_deviceId!);

    for (final node in _connectedNodes.values) {
      if (node.isActive && !routedMessage.routePath.contains(node.id)) {
        try {
          await sendMessage(node.id, routedMessage);
        } catch (e) {
          if (kDebugMode) {
            print('Failed to send to ${node.name}: $e');
          }
        }
      }
    }
  }

  /// Handle received message
  void _handleReceivedMessage(String senderId, String data) {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final message = MeshMessage.fromJson(json);

      // Check if we've already seen this message (prevent loops)
      if (_messageHistory.any((m) => m.id == message.id)) {
        if (kDebugMode) {
          print('Ignoring duplicate message: ${message.id}');
        }
        return;
      }

      // Add to history
      _messageHistory.add(message);
      if (_messageHistory.length > _maxMessageHistory) {
        _messageHistory.removeAt(0);
      }

      // Notify listeners
      _messageController.add(message);

      if (kDebugMode) {
        print('Received message from $senderId: ${message.type}');
      }

      // Forward message to other nodes if not already in route
      if (!message.routePath.contains(_deviceId)) {
        _forwardMessage(message, excludeNodeId: senderId);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling message: $e');
      }
    }
  }

  /// Forward message to other nodes (mesh routing)
  Future<void> _forwardMessage(MeshMessage message, {String? excludeNodeId}) async {
    final routedMessage = message.copyWithRoute(_deviceId!);

    for (final node in _connectedNodes.values) {
      if (node.isActive &&
          node.id != excludeNodeId &&
          !routedMessage.routePath.contains(node.id)) {
        try {
          await sendMessage(node.id, routedMessage);
          if (kDebugMode) {
            print('Forwarded message to ${node.name}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Failed to forward to ${node.name}: $e');
          }
        }
      }
    }
  }

  /// Clean up inactive nodes
  Future<void> cleanupInactiveNodes() async {
    final now = DateTime.now();
    final toRemove = <String>[];

    for (final entry in _connectedNodes.entries) {
      if (now.difference(entry.value.connectedAt) > _nodeTimeout) {
        toRemove.add(entry.key);
      }
    }

    for (final id in toRemove) {
      await disconnectFromDevice(id);
    }
  }

  /// Enable mesh network (start advertising and discovering)
  Future<void> enable() async {
    if (!_isInitialized) {
      throw Exception('Mesh network not initialized');
    }

    await startAdvertising();
    await startDiscovery();

    // Start periodic cleanup
    Timer.periodic(const Duration(minutes: 1), (_) {
      cleanupInactiveNodes();
    });

    if (kDebugMode) {
      print('Mesh network enabled');
    }
  }

  /// Disable mesh network
  Future<void> disable() async {
    await stopAdvertising();
    await stopDiscovery();

    // Disconnect all nodes
    final nodeIds = _connectedNodes.keys.toList();
    for (final id in nodeIds) {
      await disconnectFromDevice(id);
    }

    if (kDebugMode) {
      print('Mesh network disabled');
    }
  }

  /// Get mesh network statistics
  Map<String, dynamic> getStatistics() {
    return {
      'isActive': isActive,
      'connectedNodes': _connectedNodes.length,
      'messageHistory': _messageHistory.length,
      'isAdvertising': _isAdvertising,
      'isDiscovering': _isDiscovering,
    };
  }

  /// Dispose resources
  void dispose() {
    disable();
    _messageController.close();
    _nodeController.close();
  }
}
