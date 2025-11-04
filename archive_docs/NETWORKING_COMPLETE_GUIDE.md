# Complete Networking Guide - RPI Communication App

**Version:** 2.0  
**Last Updated:** October 31, 2024  
**Status:** Production Ready

## Table of Contents

1. [Overview](#overview)
2. [Online Messaging](#online-messaging)
3. [Offline Networking](#offline-networking)
4. [Mesh Networking](#mesh-networking)
5. [WebRTC P2P Connections](#webrtc-p2p-connections)
6. [Configuration](#configuration)
7. [Troubleshooting](#troubleshooting)
8. [API Reference](#api-reference)

---

## Overview

The RPI Communication App features a comprehensive networking system that provides:

- ✅ **Online Messaging** - Real-time messaging with delivery tracking
- ✅ **Offline Mode** - Queue-based sync with smart retry logic
- ✅ **Mesh Networking** - P2P communication via Bluetooth/WiFi
- ✅ **WebRTC** - High-performance P2P data channels
- ✅ **Smart Caching** - Intelligent data caching with compression
- ✅ **Background Sync** - Automatic sync when back online

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Application Layer                        │
│              (UI, Business Logic, State Management)         │
└───────────────────────┬─────────────────────────────────────┘
                        │
┌───────────────────────┴─────────────────────────────────────┐
│                   Networking Services                        │
├─────────────────────────────────────────────────────────────┤
│  • ConnectivityService      • MessageDeliveryService        │
│  • OfflineQueueService      • WebRTCSignalingService        │
│  • MeshNetworkService       • CacheService                   │
│  • BackgroundSyncService    • ConflictResolutionService     │
└───────────────────────┬─────────────────────────────────────┘
                        │
┌───────────────────────┴─────────────────────────────────────┐
│                 Transport Layer                              │
├─────────────────────────────────────────────────────────────┤
│  • Supabase (Online)     • WebRTC (P2P)                     │
│  • Bluetooth (Mesh)      • WiFi Direct (Mesh)               │
│  • Local Storage         • Background Workers               │
└─────────────────────────────────────────────────────────────┘
```

---

## Online Messaging

### Features

#### 1. Message Delivery Tracking

Track message delivery status in real-time:

```dart
// Initialize service
final deliveryService = MessageDeliveryService();
await deliveryService.initialize(currentUserId);

// Track message
await deliveryService.trackMessageDelivery(
  messageId,
  status: MessageDeliveryStatus.sending,
);

// Listen for status updates
deliveryService.deliveryStatusStream.listen((tracking) {
  print('Message ${tracking.messageId}: ${tracking.status.name}');
});
```

**Delivery Statuses:**
- `sending` - Message is being sent
- `sent` - Message sent to server
- `delivered` - Message delivered to recipient's device
- `read` - Message read by recipient

#### 2. Typing Indicators

Show when users are typing:

```dart
// Send typing indicator
await deliveryService.sendTypingIndicator(
  conversationId,
  TypingStatus.typing,
);

// Listen for typing indicators
deliveryService.typingStream.listen((indicator) {
  if (indicator.status == TypingStatus.typing) {
    print('${indicator.userId} is typing...');
  }
});

// Get typing users
final typingUsers = deliveryService.getTypingUsers(conversationId);
```

#### 3. Read Receipts

Track when messages are read:

```dart
// Mark as read
await deliveryService.markAsRead(messageId);

// Mark multiple as read
await deliveryService.markMultipleAsRead([id1, id2, id3]);

// Get delivery status
final status = deliveryService.getDeliveryStatus(messageId);
if (status?.readAt != null) {
  print('Read at: ${status!.readAt}');
}
```

### Real-time Synchronization

Messages sync automatically using Supabase real-time subscriptions:

- Instant message delivery
- Automatic status updates
- No polling required
- Battery efficient

---

## Offline Networking

### Features

#### 1. Automatic Queue Management

Actions are automatically queued when offline:

```dart
final queueService = OfflineQueueService();

// Add action to queue
await queueService.addAction(OfflineAction(
  type: 'send_message',
  data: {
    'recipientId': userId,
    'content': message,
  },
  priority: 8, // High priority
));

// Queue is automatically processed when back online
```

#### 2. Smart Retry Logic

Failed actions retry with exponential backoff:

- **Retry delays**: 1s, 2s, 4s
- **Max retries**: 3 attempts
- **Auto re-queue**: Temporary failures re-queued
- **Persistent storage**: Queue survives app restarts

#### 3. Priority-Based Processing

Actions processed by priority:

- **Priority 10**: Critical (user-initiated)
- **Priority 8**: High (messages, urgent updates)
- **Priority 5**: Normal (default)
- **Priority 3**: Low (background updates)
- **Priority 1**: Deferred (non-essential)

#### 4. Queue Analytics

Track sync performance:

```dart
final analytics = queueService.getAnalytics();
print('Total synced: ${analytics['totalSynced']}');
print('Failed: ${analytics['totalFailed']}');
print('Queue size: ${analytics['queueSize']}');
```

### Smart Caching

#### Cache Tiers

1. **Memory Cache** - Fast access, limited size
2. **Disk Cache** - Persistent, compressed

#### Cache TTL Presets

```dart
// Short-lived data (5 minutes)
await cacheService.set(key, data, ttl: CacheService.shortTTL);

// Standard data (1 hour)
await cacheService.set(key, data, ttl: CacheService.defaultTTL);

// Long-lived data (1 day)
await cacheService.set(key, data, ttl: CacheService.longTTL);
```

#### Cache Management

```dart
// Get cached data
final data = await cacheService.get<MyData>(key);

// Clear expired cache
await cacheService.cleanExpiredCache();

// Get cache statistics
final stats = await cacheService.getStatistics();
print('Cache size: ${stats['totalSizeMB']} MB');
print('Usage: ${stats['usagePercent']}%');
```

---

## Mesh Networking

### Overview

Mesh networking enables device-to-device communication without internet:

- **Bluetooth** - 30 ft range, low power
- **WiFi Direct** - 200 ft range, faster
- **WiFi Router** - Same network, very fast
- **LAN** - Wired connection, fastest

### QR Code Pairing

Secure device pairing using QR codes:

```dart
final meshService = MeshNetworkService();

// Generate QR code
final pairingData = meshService.generatePairingQRCode();
// Display QR code to user

// Scan and pair
final success = await meshService.pairWithQRCode(qrString);
if (success) {
  print('Devices paired successfully!');
}
```

**QR Code Security:**
- Time-limited (5 minutes)
- Unique per session
- Cannot be reused
- App-specific format

### Message Routing

Messages automatically route through connected devices:

```dart
// Send to specific device
await meshService.sendMessage(deviceId, message);

// Broadcast to all devices
await meshService.broadcastMessage(message);
```

**Routing Features:**
- Multi-hop forwarding
- Loop prevention
- Route tracking
- Duplicate filtering

### Auto-Connect Mode

Devices auto-connect to available peers:

```dart
// Enable auto-connect
meshService.setAutoConnect(true);

// Connections remain hidden until authenticated
// QR pairing makes connections visible
```

**Benefits:**
- Background connectivity
- No UI clutter
- Privacy-focused
- Seamless experience

---

## WebRTC P2P Connections

### Overview

WebRTC provides high-performance P2P data channels:

- **Low latency** - Direct peer connections
- **High bandwidth** - Up to 16KB packets
- **Reliable** - Ordered delivery with retransmission
- **Secure** - DTLS encryption

### Setup

```dart
final webrtcService = WebRTCSignalingService();
await webrtcService.initialize(localPeerId);

// Create offer for peer
final offer = await webrtcService.createOffer(peerId);

// Handle signaling messages
webrtcService.signalingStream.listen((message) {
  // Send via transport (mesh, server, etc.)
  transport.send(message);
});

// Receive signaling messages
await webrtcService.handleSignalingMessage(message);
```

### Sending Messages

```dart
// Send to peer
await webrtcService.sendMessage(peerId, {
  'type': 'chat',
  'content': 'Hello!',
});

// Broadcast to all
await webrtcService.broadcastMessage({
  'type': 'announcement',
  'data': noticeData,
});
```

### Connection Management

```dart
// Monitor connection state
webrtcService.connectionStateStream.listen((state) {
  print('Peer ${state['peerId']}: ${state['state']}');
});

// Disconnect peer
await webrtcService.disconnectPeer(peerId);

// Get statistics
final stats = webrtcService.getStatistics();
print('Connected peers: ${stats['connectedPeers']}');
print('Total sent: ${stats['totalBytesSent']} bytes');
```

---

## Configuration

### Network Configuration

Centralized configuration in `lib/config/network_config.dart`:

```dart
// Offline queue
NetworkConfig.maxQueueSize         // 100 actions
NetworkConfig.maxRetries           // 3 attempts
NetworkConfig.queueExpiry          // 7 days

// Cache
NetworkConfig.maxCacheSizeMB       // 50 MB
NetworkConfig.enableCompression    // true

// Mesh network
NetworkConfig.maxMeshConnections   // 10 devices
NetworkConfig.meshNodeTimeout      // 5 minutes
NetworkConfig.enableAutoConnect    // true

// WebRTC
NetworkConfig.enableWebRTC         // true
NetworkConfig.iceServers           // STUN servers
NetworkConfig.webrtcMaxPacketSize  // 16KB

// Message delivery
NetworkConfig.enableDeliveryTracking    // true
NetworkConfig.enableTypingIndicators    // true
NetworkConfig.enableReadReceipts        // true
```

### Feature Flags

Enable/disable features:

```dart
NetworkConfig.isFeatureEnabled('meshNetwork')       // true
NetworkConfig.isFeatureEnabled('offlineMode')       // true
NetworkConfig.isFeatureEnabled('webrtcSignaling')   // true
```

### Network Profiles

Optimize for different scenarios:

```dart
// High performance
NetworkProfiles.highPerformance

// Balanced (default)
NetworkProfiles.balanced

// Battery saver
NetworkProfiles.batterySaver

// Offline first
NetworkProfiles.offlineFirst
```

### Environment Configuration

```dart
// Get environment-specific config
final config = NetworkConfig.getEnvironmentConfig('production');
// or 'staging', 'development'
```

---

## Troubleshooting

### Common Issues

#### 1. Messages Not Sending

**Symptoms**: Messages stuck in "sending" state

**Solutions**:
- Check internet connection
- Verify queue processing: `queueService.processQueue()`
- Check queue analytics for errors
- Clear old queue if corrupted

```dart
// Force queue processing
await queueService.processQueue();

// Check for errors
final analytics = queueService.getAnalytics();
print('Failed: ${analytics['totalFailed']}');

// Clear if needed (caution: data loss)
await queueService.clearQueue();
```

#### 2. Mesh Devices Not Connecting

**Symptoms**: Devices not appearing in mesh list

**Solutions**:
- Enable Bluetooth and WiFi
- Grant location permissions (Android)
- Check if mesh enabled on both devices
- Try QR pairing instead of auto-connect
- Verify devices are in range

```dart
// Check mesh status
final stats = meshService.getStatistics();
print('Is active: ${stats['isActive']}');
print('Hidden nodes: ${stats['hiddenNodes']}');

// Restart mesh
await meshService.disable();
await meshService.enable();
```

#### 3. Cache Not Working

**Symptoms**: Data always fetched from server

**Solutions**:
- Initialize cache service
- Check cache size limits
- Verify TTL not expired
- Clean corrupted cache

```dart
// Initialize
await CacheService().initialize();

// Check stats
final stats = await cacheService.getStatistics();
print('Cache size: ${stats['totalSizeMB']} MB');

// Clean cache
await cacheService.cleanExpiredCache();

// Reset if needed
await cacheService.clear();
```

#### 4. WebRTC Connection Fails

**Symptoms**: WebRTC peers not connecting

**Solutions**:
- Check signaling transport working
- Verify STUN servers accessible
- Check firewall/NAT settings
- Use mesh fallback if needed

```dart
// Check connection stats
final info = webrtcService.getConnectionInfo(peerId);
print('State: ${info?['state']}');

// Disconnect and retry
await webrtcService.disconnectPeer(peerId);
await webrtcService.createOffer(peerId);
```

### Debug Mode

Enable debug logging:

```dart
// In main.dart
if (kDebugMode) {
  NetworkConfig.enableDebugLogging = true;
  NetworkConfig.verboseLogging = true;
}
```

### Network Quality Issues

Check and adapt to network quality:

```dart
final quality = connectivityService.networkQuality;
final action = NetworkConfig.getRecommendedAction(quality.name);

if (quality == NetworkQuality.poor) {
  // Enable offline mode
  // Reduce background sync frequency
  // Use mesh network if available
}
```

---

## API Reference

### Core Services

#### ConnectivityService

```dart
// Singleton instance
final service = ConnectivityService();

// Properties
bool isOnline
NetworkQuality networkQuality
DateTime? lastSyncTime

// Methods
Stream<bool> get connectivityStream
Stream<NetworkQuality> get networkQualityStream
void setConnectivity(bool isOnline)
void updateLastSyncTime()
String getLastSyncTimeText()
String getNetworkQualityText()
bool get isNetworkQualitySufficient
```

#### OfflineQueueService

```dart
// Singleton instance
final service = OfflineQueueService();

// Methods
Future<void> addAction(OfflineAction action)
Future<void> loadQueue()
Future<void> processQueue()
int get pendingActionsCount
List<OfflineAction> get pendingActions
Future<void> clearQueue()
Map<String, dynamic> getAnalytics()
Future<void> loadAnalytics()
```

#### MeshNetworkService

```dart
// Singleton instance
final service = MeshNetworkService();

// Methods
Future<void> initialize({String deviceId, String deviceName})
Future<void> enable()
Future<void> disable()
MeshPairingData generatePairingQRCode()
Future<bool> pairWithQRCode(String qrString)
Future<void> sendMessage(String recipientId, MeshMessage message)
Future<void> broadcastMessage(MeshMessage message)
void setAutoConnect(bool enabled)
List<MeshNode> get connectedNodes
List<MeshNode> get visibleNodes
List<MeshNode> get hiddenNodes
Map<String, dynamic> getStatistics()
```

#### WebRTCSignalingService

```dart
// Singleton instance
final service = WebRTCSignalingService();

// Methods
Future<void> initialize(String localPeerId)
Future<RTCSessionDescription?> createOffer(String peerId)
Future<void> handleSignalingMessage(SignalingMessage message)
Future<bool> sendMessage(String peerId, Map<String, dynamic> message)
Future<int> broadcastMessage(Map<String, dynamic> message)
Future<void> disconnectPeer(String peerId)
Future<void> disconnectAll()
List<String> get connectedPeers
Map<String, dynamic> getStatistics()
Map<String, dynamic>? getConnectionInfo(String peerId)
```

#### MessageDeliveryService

```dart
// Singleton instance
final service = MessageDeliveryService();

// Methods
Future<void> initialize(String currentUserId)
Future<void> trackMessageDelivery(String messageId, {MessageDeliveryStatus status})
Future<void> updateDeliveryStatus(String messageId, MessageDeliveryStatus status)
MessageDeliveryTracking? getDeliveryStatus(String messageId)
Future<void> markAsDelivered(String messageId)
Future<void> markAsRead(String messageId)
Future<void> sendTypingIndicator(String conversationId, TypingStatus status)
List<String> getTypingUsers(String conversationId)
Map<String, dynamic> getStatistics()
```

#### CacheService

```dart
// Singleton instance
final service = CacheService();

// Methods
Future<void> initialize()
Future<T?> get<T>(String key, {T Function(Map<String, dynamic>)? fromJson})
Future<void> set<T>(String key, T data, {Duration? ttl, bool persistToDisk})
Future<void> remove(String key)
Future<void> clear()
Future<void> cleanExpiredCache()
Future<double> getCacheSizeMB()
Future<Map<String, dynamic>> getStatistics()

// TTL presets
static Duration get shortTTL
static Duration get defaultTTL
static Duration get longTTL
```

### Data Models

#### OfflineAction

```dart
class OfflineAction {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;
  final int priority;
  final String? lastError;
}
```

#### MeshNode

```dart
class MeshNode {
  final String id;
  final String name;
  final DateTime connectedAt;
  final MeshConnectionType connectionType;
  bool isActive;
  bool isVisible;
}
```

#### MessageDeliveryTracking

```dart
class MessageDeliveryTracking {
  final String messageId;
  MessageDeliveryStatus status;
  DateTime? sentAt;
  DateTime? deliveredAt;
  DateTime? readAt;
  String? errorMessage;
}
```

### Enums

```dart
enum NetworkQuality { excellent, good, poor, offline }
enum MessageDeliveryStatus { sending, sent, delivered, read, failed }
enum TypingStatus { typing, stopped }
enum MeshConnectionType { bluetooth, wifiDirect, wifiRouter, lan, usb, auto }
enum ConflictStrategy { serverWins, clientWins, newerWins, merge, manual }
```

---

## Best Practices

### 1. Initialization Order

```dart
// Correct initialization order
await CacheService().initialize();
await ConnectivityService()._initConnectivityListener();
await OfflineQueueService().loadQueue();
await BackgroundSyncService().initialize();
await MeshNetworkService().initialize(deviceId, deviceName);
await WebRTCSignalingService().initialize(localPeerId);
await MessageDeliveryService().initialize(currentUserId);
```

### 2. Error Handling

Always handle errors gracefully:

```dart
try {
  await queueService.processQueue();
} catch (e) {
  // Log error
  // Show user-friendly message
  // Retry with backoff
}
```

### 3. Resource Management

Dispose services properly:

```dart
@override
void dispose() {
  ConnectivityService().dispose();
  MeshNetworkService().dispose();
  WebRTCSignalingService().dispose();
  MessageDeliveryService().dispose();
  super.dispose();
}
```

### 4. Performance Optimization

- Use caching aggressively
- Batch operations when possible
- Limit concurrent requests
- Monitor network quality
- Adapt behavior to conditions

### 5. Security

- Always use QR pairing for mesh
- Validate all messages
- Encrypt sensitive data
- Implement rate limiting
- Monitor for abuse

---

## Support & Feedback

For issues, questions, or feedback:

1. Check this guide
2. Review troubleshooting section
3. Check GitHub issues
4. Contact development team

**Version**: 2.0  
**Last Updated**: October 31, 2024  
**Status**: Production Ready
