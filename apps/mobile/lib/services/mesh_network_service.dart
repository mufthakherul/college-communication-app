import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Connection type for mesh network
enum MeshConnectionType {
  bluetooth,
  wifiDirect,
  wifiRouter,
  wifiHotspot, // Mobile hotspot
  lan,
  usb,
  nfc, // Near Field Communication
  ethernet, // Wired ethernet
  auto, // Automatically detected
}

/// Mesh network node information
class MeshNode {
  final String id;
  final String name;
  final DateTime connectedAt;
  final MeshConnectionType connectionType;
  bool isActive;
  bool isVisible; // Whether connection is visible to user

  MeshNode({
    required this.id,
    required this.name,
    required this.connectedAt,
    required this.connectionType,
    this.isActive = true,
    this.isVisible = false, // Hidden by default until authenticated
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'connectedAt': connectedAt.toIso8601String(),
        'connectionType': connectionType.name,
        'isActive': isActive,
        'isVisible': isVisible,
      };

  factory MeshNode.fromJson(Map<String, dynamic> json) => MeshNode(
        id: json['id'] as String,
        name: json['name'] as String,
        connectedAt: DateTime.parse(json['connectedAt'] as String),
        connectionType: MeshConnectionType.values.firstWhere(
          (t) => t.name == json['connectionType'],
          orElse: () => MeshConnectionType.auto,
        ),
        isActive: json['isActive'] ?? true,
        isVisible: json['isVisible'] ?? false,
      );

  String getConnectionTypeDisplay() {
    switch (connectionType) {
      case MeshConnectionType.bluetooth:
        return 'Bluetooth';
      case MeshConnectionType.wifiDirect:
        return 'WiFi Direct';
      case MeshConnectionType.wifiRouter:
        return 'WiFi Router';
      case MeshConnectionType.wifiHotspot:
        return 'WiFi Hotspot';
      case MeshConnectionType.lan:
        return 'LAN';
      case MeshConnectionType.usb:
        return 'USB';
      case MeshConnectionType.nfc:
        return 'NFC';
      case MeshConnectionType.ethernet:
        return 'Ethernet';
      case MeshConnectionType.auto:
        return 'Auto';
    }
  }
}

/// QR code purpose/permission types
enum QRPairingPurpose {
  privateChat, // Start a private chat
  internetSharing, // Share cellular internet
  infoSharing, // Share information/files
  autoSync, // Auto sync messages (invisible connection)
  fullAccess, // All permissions
}

/// QR code pairing data with enhanced permissions
class MeshPairingData {
  final String deviceId;
  final String deviceName;
  final String pairingToken; // Unique token for this pairing session
  final DateTime? expiresAt; // Null means no expiry
  final List<String> supportedConnections; // Connection types supported
  final List<QRPairingPurpose> purposes; // What this QR code allows
  final Map<String, dynamic>? sharedInfo; // Optional info to share

  MeshPairingData({
    required this.deviceId,
    required this.deviceName,
    required this.pairingToken,
    this.expiresAt,
    required this.supportedConnections,
    this.purposes = const [QRPairingPurpose.privateChat],
    this.sharedInfo,
  });

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'pairingToken': pairingToken,
        'expiresAt': expiresAt?.toIso8601String(),
        'supportedConnections': supportedConnections,
        'purposes': purposes.map((p) => p.name).toList(),
        'sharedInfo': sharedInfo,
      };

  factory MeshPairingData.fromJson(Map<String, dynamic> json) =>
      MeshPairingData(
        deviceId: json['deviceId'] as String,
        deviceName: json['deviceName'] as String,
        pairingToken: json['pairingToken'] as String,
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'] as String)
            : null,
        supportedConnections:
            (json['supportedConnections'] as List).cast<String>(),
        purposes: json['purposes'] != null
            ? (json['purposes'] as List)
                .map(
                  (p) => QRPairingPurpose.values.firstWhere(
                    (purpose) => purpose.name == p,
                    orElse: () => QRPairingPurpose.privateChat,
                  ),
                )
                .toList()
            : [QRPairingPurpose.privateChat],
        sharedInfo: json['sharedInfo'] as Map<String, dynamic>?,
      );

  String toQRString() => jsonEncode(toJson());

  factory MeshPairingData.fromQRString(String qrString) {
    final json = jsonDecode(qrString) as Map<String, dynamic>;
    return MeshPairingData.fromJson(json);
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  bool get hasNoExpiry => expiresAt == null;

  bool hasPurpose(QRPairingPurpose purpose) => purposes.contains(purpose);
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

  final Map<String, MeshNode> _connectedNodes = {};
  final Map<String, MeshNode> _hiddenNodes =
      {}; // Auto-connected but not authenticated
  final List<MeshMessage> _messageHistory = [];
  final Map<String, MeshPairingData> _activePairings =
      {}; // Active pairing sessions
  final _messageController = StreamController<MeshMessage>.broadcast();
  final _nodeController = StreamController<List<MeshNode>>.broadcast();

  bool _isInitialized = false;
  bool _isAdvertising = false;
  bool _isDiscovering = false;
  bool _autoConnectEnabled = true; // Auto-connect to all available connections
  String? _deviceId;
  String? _deviceName;

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

      // Initialize the nearby connections
      // Note: Actual initialization is handled by the flutter_nearby_connections plugin

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
      // Start advertising using flutter_nearby_connections
      // Note: This is a placeholder - actual implementation depends on platform-specific requirements
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
      // Stop advertising using flutter_nearby_connections
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

  /// Generate QR code pairing data with custom purposes and optional expiry
  MeshPairingData generatePairingQRCode({
    List<QRPairingPurpose>? purposes,
    Duration? expiryDuration,
    Map<String, dynamic>? sharedInfo,
  }) {
    if (!_isInitialized || _deviceId == null) {
      throw Exception('Mesh network not initialized');
    }

    final pairingToken = _generatePairingToken();
    final DateTime? expiresAt = expiryDuration != null
        ? DateTime.now().add(expiryDuration)
        : null; // No expiry if duration not provided

    final pairingData = MeshPairingData(
      deviceId: _deviceId!,
      deviceName: _deviceName!,
      pairingToken: pairingToken,
      expiresAt: expiresAt,
      supportedConnections: _getSupportedConnectionTypes(),
      purposes: purposes ?? [QRPairingPurpose.privateChat],
      sharedInfo: sharedInfo,
    );

    _activePairings[pairingToken] = pairingData;

    // Auto-cleanup expired pairings only if they have expiry
    if (expiryDuration != null) {
      Future.delayed(expiryDuration, () {
        _activePairings.remove(pairingToken);
      });
    }

    if (kDebugMode) {
      print('Generated pairing QR code with token: $pairingToken');
      print('Purposes: ${purposes?.map((p) => p.name).join(", ")}');
      print('Expires: ${expiresAt ?? "Never"}');
    }

    return pairingData;
  }

  /// Pair with device using scanned QR code data
  Future<bool> pairWithQRCode(String qrString) async {
    try {
      final pairingData = MeshPairingData.fromQRString(qrString);

      if (pairingData.isExpired) {
        if (kDebugMode) {
          print('Pairing QR code expired');
        }
        return false;
      }

      // Check if already connected
      if (_connectedNodes.containsKey(pairingData.deviceId)) {
        if (kDebugMode) {
          print('Already connected to device: ${pairingData.deviceName}');
        }
        return true;
      }

      // Try to establish connection using best available method
      await _connectToDeviceWithPairing(pairingData);

      if (kDebugMode) {
        print('Successfully paired with device: ${pairingData.deviceName}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error pairing with QR code: $e');
      }
      return false;
    }
  }

  /// Connect to device using pairing data
  Future<void> _connectToDeviceWithPairing(MeshPairingData pairingData) async {
    // Try connection types in order of preference
    final connectionTypes = _determineConnectionPriority(
      pairingData.supportedConnections,
    );

    for (final connectionType in connectionTypes) {
      try {
        await _establishConnection(
          pairingData.deviceId,
          pairingData.deviceName,
          connectionType,
        );

        // If successful, make the node visible
        final node = _connectedNodes[pairingData.deviceId] ??
            _hiddenNodes[pairingData.deviceId];
        if (node != null) {
          node.isVisible = true;
          if (_hiddenNodes.containsKey(pairingData.deviceId)) {
            _hiddenNodes.remove(pairingData.deviceId);
            _connectedNodes[pairingData.deviceId] = node;
          }
          _nodeController.add(connectedNodes);
        }

        return;
      } catch (e) {
        if (kDebugMode) {
          print('Failed to connect via ${connectionType.name}: $e');
        }
        continue;
      }
    }

    throw Exception('Failed to establish connection with any available method');
  }

  /// Establish connection using specific type
  Future<void> _establishConnection(
    String deviceId,
    String deviceName,
    MeshConnectionType connectionType,
  ) async {
    // Create node (initially hidden if auto-connected)
    final node = MeshNode(
      id: deviceId,
      name: deviceName,
      connectedAt: DateTime.now(),
      connectionType: connectionType,
      isVisible: false, // Will be made visible after QR pairing
    );

    // For now, add to hidden nodes if auto-connect is enabled
    if (_autoConnectEnabled) {
      _hiddenNodes[deviceId] = node;
    } else {
      _connectedNodes[deviceId] = node;
      node.isVisible = true;
    }

    if (kDebugMode) {
      print('Established ${connectionType.name} connection with $deviceName');
    }
  }

  /// Generate unique pairing token
  String _generatePairingToken() {
    return '${_deviceId}_${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(8)}';
  }

  /// Generate random string
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
      length,
      (index) => chars[(random + index) % chars.length],
    ).join();
  }

  /// Get supported connection types for this device
  List<String> _getSupportedConnectionTypes() {
    return [
      MeshConnectionType.bluetooth.name,
      MeshConnectionType.wifiDirect.name,
      MeshConnectionType.wifiRouter.name,
      MeshConnectionType.wifiHotspot.name,
      MeshConnectionType.lan.name,
      MeshConnectionType.ethernet.name,
      MeshConnectionType.nfc.name,
      MeshConnectionType.usb.name,
      // All connection types are listed - platform-specific detection happens at runtime
    ];
  }

  /// Determine connection priority based on available types
  List<MeshConnectionType> _determineConnectionPriority(
    List<String> supported,
  ) {
    final priority = <MeshConnectionType>[];

    // Prefer faster, more stable connections (ordered by speed and stability)
    if (supported.contains(MeshConnectionType.ethernet.name)) {
      priority.add(MeshConnectionType.ethernet);
    }
    if (supported.contains(MeshConnectionType.lan.name)) {
      priority.add(MeshConnectionType.lan);
    }
    if (supported.contains(MeshConnectionType.usb.name)) {
      priority.add(MeshConnectionType.usb);
    }
    if (supported.contains(MeshConnectionType.wifiRouter.name)) {
      priority.add(MeshConnectionType.wifiRouter);
    }
    if (supported.contains(MeshConnectionType.wifiHotspot.name)) {
      priority.add(MeshConnectionType.wifiHotspot);
    }
    if (supported.contains(MeshConnectionType.wifiDirect.name)) {
      priority.add(MeshConnectionType.wifiDirect);
    }
    if (supported.contains(MeshConnectionType.nfc.name)) {
      priority.add(MeshConnectionType.nfc);
    }
    if (supported.contains(MeshConnectionType.bluetooth.name)) {
      priority.add(MeshConnectionType.bluetooth);
    }

    return priority;
  }

  /// Enable/disable auto-connect mode
  void setAutoConnect(bool enabled) {
    _autoConnectEnabled = enabled;
    if (kDebugMode) {
      print('Auto-connect ${enabled ? "enabled" : "disabled"}');
    }
  }

  /// Get list of visible nodes only
  List<MeshNode> get visibleNodes =>
      _connectedNodes.values.where((node) => node.isVisible).toList();

  /// Get list of hidden (auto-connected) nodes
  List<MeshNode> get hiddenNodes => _hiddenNodes.values.toList();

  /// Make a hidden node visible (after authentication)
  void makeNodeVisible(String deviceId) {
    final node = _hiddenNodes.remove(deviceId);
    if (node != null) {
      node.isVisible = true;
      _connectedNodes[deviceId] = node;
      _nodeController.add(connectedNodes);

      if (kDebugMode) {
        print('Node made visible: ${node.name}');
      }
    }
  }

  /// Start discovering nearby devices
  Future<void> startDiscovery() async {
    if (!_isInitialized || _isDiscovering) return;

    try {
      // Start browsing/discovering using flutter_nearby_connections
      // Note: This is a placeholder - actual implementation depends on platform-specific requirements
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
      // Stop browsing/discovering using flutter_nearby_connections
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

      // Send message using flutter_nearby_connections
      // Note: This is a placeholder - actual implementation depends on platform-specific requirements
      // await _nearbyConnections?.sendMessage(recipientId, jsonEncode(message.toJson()));

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
      'hiddenNodes': _hiddenNodes.length,
      'visibleNodes': visibleNodes.length,
      'messageHistory': _messageHistory.length,
      'isAdvertising': _isAdvertising,
      'isDiscovering': _isDiscovering,
      'autoConnectEnabled': _autoConnectEnabled,
      'activePairings': _activePairings.length,
    };
  }

  /// Dispose resources
  void dispose() {
    disable();
    _messageController.close();
    _nodeController.close();
  }
}
