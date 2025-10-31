# Networking Integration Guide

**Version:** 1.0  
**Last Updated:** October 31, 2024

This guide shows how to integrate all networking services together in your application.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Complete Setup](#complete-setup)
3. [Usage Examples](#usage-examples)
4. [Best Practices](#best-practices)
5. [Common Patterns](#common-patterns)

---

## Quick Start

### Minimal Setup (5 minutes)

Add this to your `main.dart`:

```dart
import 'package:campus_mesh/services/connectivity_service.dart';
import 'package:campus_mesh/services/offline_queue_service.dart';
import 'package:campus_mesh/services/cache_service.dart';
import 'package:campus_mesh/services/background_sync_service.dart';
import 'package:campus_mesh/config/network_config.dart';

Future<void> initializeNetworking() async {
  // Validate configuration
  NetworkConfig.validate();
  
  // Initialize cache
  await CacheService().initialize();
  
  // Load offline queue
  final queueService = OfflineQueueService();
  await queueService.loadQueue();
  await queueService.loadAnalytics();
  
  // Setup background sync
  final backgroundSync = BackgroundSyncService();
  await backgroundSync.initialize();
  await backgroundSync.registerOfflineQueueSync();
  await backgroundSync.registerCacheCleanup();
  
  print('✅ Basic networking initialized');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase first
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_KEY',
  );
  
  // Initialize networking
  await initializeNetworking();
  
  runApp(MyApp());
}
```

---

## Complete Setup

### Full Setup with All Features (10 minutes)

```dart
import 'package:campus_mesh/services/connectivity_service.dart';
import 'package:campus_mesh/services/offline_queue_service.dart';
import 'package:campus_mesh/services/cache_service.dart';
import 'package:campus_mesh/services/background_sync_service.dart';
import 'package:campus_mesh/services/mesh_network_service.dart';
import 'package:campus_mesh/services/webrtc_signaling_service.dart';
import 'package:campus_mesh/services/message_delivery_service.dart';
import 'package:campus_mesh/config/network_config.dart';

Future<void> initializeCompleteNetworking(String userId) async {
  print('🚀 Initializing complete networking system...');
  
  try {
    // 1. Validate configuration
    if (!NetworkConfig.validate()) {
      throw Exception('Invalid network configuration');
    }
    print('✅ Configuration validated');
    
    // 2. Initialize cache service
    await CacheService().initialize();
    print('✅ Cache initialized');
    
    // 3. Load offline queue
    final queueService = OfflineQueueService();
    await queueService.loadQueue();
    await queueService.loadAnalytics();
    print('✅ Offline queue loaded (${queueService.pendingActionsCount} pending)');
    
    // 4. Setup background sync
    final backgroundSync = BackgroundSyncService();
    await backgroundSync.initialize();
    await backgroundSync.registerOfflineQueueSync(
      frequency: NetworkConfig.backgroundSyncInterval,
    );
    await backgroundSync.registerCacheCleanup(
      frequency: NetworkConfig.cacheCleanupInterval,
    );
    print('✅ Background sync registered');
    
    // 5. Initialize message delivery tracking
    if (NetworkConfig.isFeatureEnabled('messageDelivery')) {
      final deliveryService = MessageDeliveryService();
      await deliveryService.initialize(userId);
      print('✅ Message delivery tracking initialized');
    }
    
    // 6. Initialize mesh network (if enabled)
    if (NetworkConfig.isFeatureEnabled('meshNetwork')) {
      final meshService = MeshNetworkService();
      await meshService.initialize(
        deviceId: userId,
        deviceName: await _getDeviceName(),
      );
      print('✅ Mesh network initialized');
    }
    
    // 7. Initialize WebRTC signaling (if enabled)
    if (NetworkConfig.isFeatureEnabled('webrtcSignaling')) {
      final webrtcService = WebRTCSignalingService();
      await webrtcService.initialize(userId);
      print('✅ WebRTC signaling initialized');
    }
    
    // 8. Setup connectivity monitoring
    _setupConnectivityMonitoring(queueService);
    print('✅ Connectivity monitoring active');
    
    print('🎉 Complete networking system initialized successfully!');
    
  } catch (e, stackTrace) {
    print('❌ Networking initialization failed: $e');
    print(stackTrace);
    rethrow;
  }
}

// Helper to get device name
Future<String> _getDeviceName() async {
  // Implement device name retrieval
  return 'User Device';
}

// Setup connectivity monitoring
void _setupConnectivityMonitoring(OfflineQueueService queueService) {
  final connectivity = ConnectivityService();
  
  // Monitor connectivity changes
  connectivity.connectivityStream.listen((isOnline) {
    if (isOnline) {
      print('📶 Connection restored - processing queue');
      queueService.processQueue();
    } else {
      print('📵 Connection lost - offline mode active');
    }
  });
  
  // Monitor network quality
  connectivity.networkQualityStream.listen((quality) {
    print('📊 Network quality: ${quality.name}');
    // Adapt behavior based on quality
    _adaptToNetworkQuality(quality);
  });
}

// Adapt behavior based on network quality
void _adaptToNetworkQuality(NetworkQuality quality) {
  switch (quality) {
    case NetworkQuality.excellent:
      // Enable all features
      break;
    case NetworkQuality.good:
      // Normal operation
      break;
    case NetworkQuality.poor:
      // Reduce background operations
      // Increase cache usage
      break;
    case NetworkQuality.offline:
      // Full offline mode
      // Use mesh if available
      break;
  }
}
```

---

## Usage Examples

### 1. Sending Messages with Full Tracking

```dart
Future<void> sendMessageWithTracking({
  required String recipientId,
  required String content,
}) async {
  final connectivity = ConnectivityService();
  final messageService = MessageService();
  final deliveryService = MessageDeliveryService();
  final queueService = OfflineQueueService();
  
  try {
    // Generate message ID
    final messageId = const Uuid().v4();
    
    // Start tracking
    await deliveryService.trackMessageDelivery(
      messageId,
      status: MessageDeliveryStatus.sending,
    );
    
    if (connectivity.isOnline && connectivity.isNetworkQualitySufficient) {
      // Send online
      await messageService.sendMessage(
        recipientId: recipientId,
        content: content,
        type: MessageType.text,
      );
      
      // Update status
      await deliveryService.updateDeliveryStatus(
        messageId,
        MessageDeliveryStatus.sent,
      );
    } else {
      // Queue for offline
      await queueService.addAction(OfflineAction(
        type: 'send_message',
        data: {
          'messageId': messageId,
          'recipientId': recipientId,
          'content': content,
          'type': 'text',
        },
        priority: 8, // High priority for messages
      ));
      
      print('Message queued for sending when online');
    }
  } catch (e) {
    // Update status to failed
    await deliveryService.updateDeliveryStatus(
      messageId,
      MessageDeliveryStatus.failed,
      errorMessage: e.toString(),
    );
    rethrow;
  }
}
```

### 2. Using Typing Indicators

```dart
class ChatScreen extends StatefulWidget {
  final String conversationId;
  
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _deliveryService = MessageDeliveryService();
  Timer? _typingTimer;
  List<String> _typingUsers = [];
  
  @override
  void initState() {
    super.initState();
    
    // Listen for typing indicators
    _deliveryService.typingStream.listen((indicator) {
      if (indicator.conversationId == widget.conversationId) {
        setState(() {
          _typingUsers = _deliveryService.getTypingUsers(widget.conversationId);
        });
      }
    });
    
    // Setup text field listener
    _controller.addListener(_onTextChanged);
  }
  
  void _onTextChanged() {
    // Cancel previous timer
    _typingTimer?.cancel();
    
    // Send typing indicator
    _deliveryService.sendTypingIndicator(
      widget.conversationId,
      TypingStatus.typing,
    );
    
    // Set timer to send "stopped" after 3 seconds of no typing
    _typingTimer = Timer(Duration(seconds: 3), () {
      _deliveryService.sendTypingIndicator(
        widget.conversationId,
        TypingStatus.stopped,
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Messages list
        Expanded(child: MessagesList()),
        
        // Typing indicator
        if (_typingUsers.isNotEmpty)
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              '${_typingUsers.join(", ")} ${_typingUsers.length == 1 ? "is" : "are"} typing...',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        
        // Message input
        TextField(
          controller: _controller,
          decoration: InputDecoration(hintText: 'Type a message...'),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _typingTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}
```

### 3. Using Mesh Network

```dart
Future<void> setupMeshNetwork(String userId) async {
  final meshService = MeshNetworkService();
  
  // Initialize
  await meshService.initialize(
    deviceId: userId,
    deviceName: await _getDeviceName(),
  );
  
  // Enable mesh network
  await meshService.enable();
  
  // Listen for incoming messages
  meshService.messageStream.listen((message) {
    print('Mesh message received: ${message.type}');
    _handleMeshMessage(message);
  });
  
  // Listen for node connections
  meshService.nodesStream.listen((nodes) {
    print('Mesh nodes updated: ${nodes.length} connected');
  });
  
  // Enable auto-connect
  meshService.setAutoConnect(true);
}

Future<void> pairDeviceWithQR() async {
  final meshService = MeshNetworkService();
  
  // Option 1: Generate QR code
  final pairingData = meshService.generatePairingQRCode();
  // Display QR code using qr_flutter
  
  // Option 2: Scan QR code
  final qrString = await scanQRCode(); // Implement QR scanning
  final success = await meshService.pairWithQRCode(qrString);
  
  if (success) {
    print('Device paired successfully!');
  }
}

Future<void> sendViaMesh(String recipientId, Map<String, dynamic> data) async {
  final meshService = MeshNetworkService();
  
  if (!meshService.isActive) {
    throw Exception('Mesh network not active');
  }
  
  final message = MeshMessage(
    id: const Uuid().v4(),
    senderId: await _getCurrentUserId(),
    type: 'chat',
    payload: data,
  );
  
  // Send to specific device
  await meshService.sendMessage(recipientId, message);
  
  // Or broadcast to all
  // await meshService.broadcastMessage(message);
}
```

### 4. Using WebRTC for P2P

```dart
Future<void> setupWebRTC(String localPeerId) async {
  final webrtcService = WebRTCSignalingService();
  
  // Initialize
  await webrtcService.initialize(localPeerId);
  
  // Listen for signaling messages (send via your transport)
  webrtcService.signalingStream.listen((signalingMessage) {
    // Send via mesh, server, or other transport
    _sendSignalingMessage(signalingMessage);
  });
  
  // Listen for incoming data
  webrtcService.messageStream.listen((message) {
    print('WebRTC message: ${message['type']}');
    _handleWebRTCMessage(message);
  });
  
  // Monitor connection state
  webrtcService.connectionStateStream.listen((state) {
    print('WebRTC peer ${state['peerId']}: ${state['state']}');
  });
}

Future<void> connectToPeer(String peerId) async {
  final webrtcService = WebRTCSignalingService();
  
  // Create offer
  final offer = await webrtcService.createOffer(peerId);
  if (offer != null) {
    print('WebRTC offer created for $peerId');
  }
}

Future<void> sendDataViaPeer(String peerId, Map<String, dynamic> data) async {
  final webrtcService = WebRTCSignalingService();
  
  final success = await webrtcService.sendMessage(peerId, data);
  if (success) {
    print('Data sent via WebRTC');
  } else {
    print('Failed to send - fallback to mesh');
    // Fallback to mesh network
    await sendViaMesh(peerId, data);
  }
}
```

### 5. Smart Caching

```dart
Future<T> fetchWithCache<T>({
  required String key,
  required Future<T> Function() fetchFn,
  required T Function(Map<String, dynamic>) fromJson,
  Duration? ttl,
}) async {
  final cache = CacheService();
  
  // Try cache first
  final cached = await cache.get<T>(key, fromJson: fromJson);
  if (cached != null) {
    print('Cache hit: $key');
    return cached;
  }
  
  print('Cache miss: $key - fetching...');
  
  // Fetch fresh data
  final data = await fetchFn();
  
  // Cache it
  await cache.set(
    key,
    data,
    ttl: ttl ?? CacheService.defaultTTL,
    persistToDisk: true,
  );
  
  return data;
}

// Usage example
Future<List<NoticeModel>> getNotices() async {
  return fetchWithCache<List<NoticeModel>>(
    key: 'notices_list',
    fetchFn: () => _noticeService.fetchNotices(),
    fromJson: (json) => (json['items'] as List)
        .map((item) => NoticeModel.fromJson(item))
        .toList(),
    ttl: CacheService.shortTTL, // 5 minutes
  );
}
```

---

## Best Practices

### 1. Initialize in Correct Order

```dart
// ✅ Correct order
await CacheService().initialize();
await OfflineQueueService().loadQueue();
await BackgroundSyncService().initialize();
await MeshNetworkService().initialize(...);
await WebRTCSignalingService().initialize(...);
await MessageDeliveryService().initialize(...);

// ❌ Wrong - services depend on each other
await MeshNetworkService().initialize(...);
await CacheService().initialize(); // Cache should be first
```

### 2. Handle Errors Gracefully

```dart
try {
  await sendMessage(...);
} catch (e) {
  // Log error
  print('Send failed: $e');
  
  // Queue for retry
  await queueService.addAction(...);
  
  // Show user-friendly message
  showSnackBar('Message will send when online');
}
```

### 3. Monitor Resource Usage

```dart
// Periodically check resource usage
Timer.periodic(Duration(minutes: 5), (_) async {
  final cacheSize = await CacheService().getCacheSizeMB();
  if (cacheSize > NetworkConfig.maxCacheSizeMB * 0.9) {
    print('⚠️ Cache nearly full - cleaning...');
    await CacheService().cleanExpiredCache();
  }
  
  final queueSize = OfflineQueueService().pendingActionsCount;
  if (queueSize > NetworkConfig.maxQueueSize * 0.9) {
    print('⚠️ Queue nearly full - processing...');
    await OfflineQueueService().processQueue();
  }
});
```

### 4. Use Network Profiles

```dart
void applyNetworkProfile(String profileName) {
  final profile = NetworkProfiles.getProfile(profileName);
  
  // Apply settings
  // This is a simplified example - adapt to your needs
  print('Applying $profileName profile');
  print('Settings: $profile');
}

// Apply based on battery level
void adaptToBattery(int batteryLevel) {
  if (batteryLevel < 20) {
    applyNetworkProfile('batterySaver');
  } else if (batteryLevel > 80) {
    applyNetworkProfile('highPerformance');
  } else {
    applyNetworkProfile('balanced');
  }
}
```

### 5. Clean Up Properly

```dart
@override
void dispose() {
  // Dispose all services
  ConnectivityService().dispose();
  MessageDeliveryService().dispose();
  MeshNetworkService().dispose();
  WebRTCSignalingService().dispose();
  
  super.dispose();
}
```

---

## Common Patterns

### Pattern 1: Hybrid Online/Offline Messaging

```dart
Future<void> sendHybridMessage({
  required String recipientId,
  required String content,
}) async {
  final connectivity = ConnectivityService();
  final messageService = MessageService();
  final meshService = MeshNetworkService();
  final webrtcService = WebRTCSignalingService();
  final queueService = OfflineQueueService();
  
  try {
    if (connectivity.isOnline) {
      // Try online first
      await messageService.sendMessage(
        recipientId: recipientId,
        content: content,
      );
    } else if (webrtcService.connectedPeers.contains(recipientId)) {
      // Try WebRTC if connected
      await webrtcService.sendMessage(recipientId, {
        'type': 'message',
        'content': content,
      });
    } else if (meshService.connectedNodes.any((n) => n.id == recipientId)) {
      // Try mesh if connected
      await meshService.sendMessage(recipientId, MeshMessage(
        id: const Uuid().v4(),
        senderId: await _getCurrentUserId(),
        type: 'message',
        payload: {'content': content},
      ));
    } else {
      // Queue for later
      await queueService.addAction(OfflineAction(
        type: 'send_message',
        data: {
          'recipientId': recipientId,
          'content': content,
        },
        priority: 8,
      ));
    }
  } catch (e) {
    print('Send failed, queuing: $e');
    await queueService.addAction(OfflineAction(
      type: 'send_message',
      data: {
        'recipientId': recipientId,
        'content': content,
      },
      priority: 8,
    ));
  }
}
```

### Pattern 2: Progressive Enhancement

```dart
// Start with basic features, add advanced as available
class NetworkingManager {
  bool _meshEnabled = false;
  bool _webrtcEnabled = false;
  bool _deliveryTrackingEnabled = false;
  
  Future<void> initialize(String userId) async {
    // Basic features (always available)
    await CacheService().initialize();
    await OfflineQueueService().loadQueue();
    
    // Try to enable advanced features
    try {
      await MeshNetworkService().initialize(
        deviceId: userId,
        deviceName: await _getDeviceName(),
      );
      _meshEnabled = true;
      print('✅ Mesh network enabled');
    } catch (e) {
      print('⚠️ Mesh network unavailable: $e');
    }
    
    try {
      await WebRTCSignalingService().initialize(userId);
      _webrtcEnabled = true;
      print('✅ WebRTC enabled');
    } catch (e) {
      print('⚠️ WebRTC unavailable: $e');
    }
    
    try {
      await MessageDeliveryService().initialize(userId);
      _deliveryTrackingEnabled = true;
      print('✅ Delivery tracking enabled');
    } catch (e) {
      print('⚠️ Delivery tracking unavailable: $e');
    }
  }
  
  bool get hasMesh => _meshEnabled;
  bool get hasWebRTC => _webrtcEnabled;
  bool get hasDeliveryTracking => _deliveryTrackingEnabled;
}
```

### Pattern 3: Automatic Fallback

```dart
Future<bool> sendWithFallback(String recipientId, dynamic data) async {
  final strategies = [
    // 1. Try WebRTC (fastest)
    () async {
      if (NetworkConfig.isFeatureEnabled('webrtcSignaling')) {
        return await WebRTCSignalingService().sendMessage(recipientId, data);
      }
      return false;
    },
    
    // 2. Try online (reliable)
    () async {
      if (ConnectivityService().isOnline) {
        await MessageService().sendMessage(
          recipientId: recipientId,
          content: data.toString(),
        );
        return true;
      }
      return false;
    },
    
    // 3. Try mesh (offline)
    () async {
      if (NetworkConfig.isFeatureEnabled('meshNetwork')) {
        await MeshNetworkService().sendMessage(recipientId, MeshMessage(
          id: const Uuid().v4(),
          senderId: await _getCurrentUserId(),
          type: 'data',
          payload: data,
        ));
        return true;
      }
      return false;
    },
    
    // 4. Queue for later
    () async {
      await OfflineQueueService().addAction(OfflineAction(
        type: 'send_data',
        data: {'recipientId': recipientId, 'data': data},
        priority: 7,
      ));
      return true;
    },
  ];
  
  for (final strategy in strategies) {
    try {
      if (await strategy()) {
        return true;
      }
    } catch (e) {
      print('Strategy failed: $e');
      continue;
    }
  }
  
  return false;
}
```

---

## Testing Your Integration

### 1. Basic Connectivity Test

```dart
Future<void> testConnectivity() async {
  print('Testing connectivity...');
  
  final service = ConnectivityService();
  print('Online: ${service.isOnline}');
  print('Quality: ${service.getNetworkQualityText()}');
  print('Last sync: ${service.getLastSyncTimeText()}');
}
```

### 2. Queue Test

```dart
Future<void> testQueue() async {
  print('Testing offline queue...');
  
  final queue = OfflineQueueService();
  
  // Add test action
  await queue.addAction(OfflineAction(
    type: 'test',
    data: {'timestamp': DateTime.now().toIso8601String()},
    priority: 5,
  ));
  
  print('Queue size: ${queue.pendingActionsCount}');
  
  // Process
  await queue.processQueue();
  
  print('After processing: ${queue.pendingActionsCount}');
}
```

### 3. Mesh Test

```dart
Future<void> testMesh() async {
  print('Testing mesh network...');
  
  final mesh = MeshNetworkService();
  final stats = mesh.getStatistics();
  
  print('Active: ${stats['isActive']}');
  print('Connected: ${stats['connectedNodes']}');
  print('Visible: ${stats['visibleNodes']}');
  print('Hidden: ${stats['hiddenNodes']}');
}
```

---

## Conclusion

This integration guide provides everything you need to implement comprehensive networking in your app. Start with the quick setup, then add advanced features as needed.

**Key Takeaways:**
- Initialize services in the correct order
- Handle errors gracefully with fallbacks
- Monitor resource usage
- Use appropriate network profiles
- Test thoroughly

For more details, see:
- [Complete Networking Guide](NETWORKING_COMPLETE_GUIDE.md)
- [Troubleshooting Guide](NETWORKING_TROUBLESHOOTING.md)
- [Network Configuration](apps/mobile/lib/config/network_config.dart)

**Version:** 1.0  
**Last Updated:** October 31, 2024
