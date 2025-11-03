# Networking Complete Guide

## Overview

This comprehensive guide covers the networking architecture, implementation, and troubleshooting for the RPI Communication App. This consolidates multiple networking documents into a single reference.

**Version:** 2.0  
**Last Updated:** November 2025  
**Status:** Production Ready

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Mesh Networking](#mesh-networking)
3. [Offline Chat System](#offline-chat-system)
4. [Network Detection](#network-detection)
5. [Integration Guide](#integration-guide)
6. [Troubleshooting](#troubleshooting)
7. [Best Practices](#best-practices)

---

## Architecture Overview

The app implements a hybrid networking architecture that supports:
- **Cloud-first communication** via Appwrite
- **Offline mesh networking** for local campus communication
- **Automatic fallback** between modes
- **Data synchronization** when connectivity is restored

### Network Layers

```
┌─────────────────────────────────────┐
│        Application Layer            │
│   (Messages, Notices, Files)        │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Network Abstraction Layer      │
│  (Auto-detection & Mode Selection)  │
└──────────────┬──────────────────────┘
               │
        ┌──────┴──────┐
        │             │
┌───────▼──────┐ ┌───▼─────────┐
│ Cloud Mode   │ │ Mesh Mode   │
│ (Appwrite)   │ │ (P2P/WiFi)  │
└──────────────┘ └─────────────┘
```

### Key Components

1. **NetworkService** - Handles mode detection and switching
2. **MessageService** - Message routing across network modes
3. **SyncService** - Data synchronization service
4. **MeshNetworkManager** - Peer-to-peer communication
5. **OfflineStorageService** - Local data persistence

---

## Mesh Networking

### Overview

Mesh networking enables direct device-to-device communication when internet connectivity is unavailable.

### Technologies Used

- **WiFi Direct** (Android) - Peer-to-peer WiFi connections
- **Nearby Connections API** - Google's P2P communication API
- **WebRTC** - Real-time communication protocol

### Implementation

#### Enable Mesh Networking

```dart
import 'package:rpi_comm_app/services/mesh_network_manager.dart';

final meshManager = MeshNetworkManager();

// Initialize mesh networking
await meshManager.initialize();

// Start advertising (become discoverable)
await meshManager.startAdvertising(
  deviceName: 'Student_${userId}',
);

// Start discovery (find nearby peers)
await meshManager.startDiscovery();

// Listen for nearby devices
meshManager.onPeerDiscovered.listen((peer) {
  print('Found peer: ${peer.deviceName}');
});
```

#### Send Message via Mesh

```dart
// Send message to specific peer
await meshManager.sendMessage(
  peerId: targetPeerId,
  message: MessageModel(
    senderId: currentUserId,
    content: 'Hello!',
    timestamp: DateTime.now(),
  ),
);
```

### Mesh Network Features

- **Automatic peer discovery** - Find nearby devices automatically
- **Multi-hop routing** - Messages can hop through intermediate devices
- **Encryption** - All mesh messages are encrypted
- **Battery optimization** - Smart power management
- **Range extension** - Up to 100m with multiple hops

---

## Offline Chat System

### How It Works

1. **Message Creation**: User creates message
2. **Network Check**: System checks connectivity
3. **Local Storage**: If offline, store in local database
4. **Sync Queue**: Add to synchronization queue
5. **Upload**: When online, sync to cloud
6. **Notification**: Notify recipient

### Implementation

#### Send Message (Offline-aware)

```dart
import 'package:rpi_comm_app/services/message_service.dart';

final messageService = MessageService();

// Send message - automatically handles online/offline
await messageService.sendMessage(
  receiverId: receiverId,
  content: messageContent,
  attachments: files,
);

// The service will:
// - If online: Send via Appwrite
// - If offline: Store locally and queue for sync
// - Try mesh network if available
```

#### Monitor Sync Status

```dart
// Listen to sync status
messageService.syncStatus.listen((status) {
  switch (status) {
    case SyncStatus.syncing:
      print('Syncing messages...');
      break;
    case SyncStatus.synced:
      print('All messages synced');
      break;
    case SyncStatus.error:
      print('Sync error occurred');
      break;
  }
});
```

### Offline Storage

Messages are stored locally using:
- **Hive** - Fast NoSQL database
- **SQLite** - Relational data storage
- **Secure Storage** - Encrypted credentials

**Storage Schema:**

```dart
@HiveType(typeId: 1)
class OfflineMessage {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String senderId;
  
  @HiveField(2)
  String receiverId;
  
  @HiveField(3)
  String content;
  
  @HiveField(4)
  DateTime timestamp;
  
  @HiveField(5)
  bool isSynced;
  
  @HiveField(6)
  List<String> attachments;
}
```

---

## Network Detection

### Connectivity Monitoring

```dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rpi_comm_app/services/network_service.dart';

final networkService = NetworkService();

// Listen to network changes
networkService.connectionStatus.listen((status) {
  switch (status) {
    case NetworkStatus.online:
      print('Connected to internet');
      // Trigger sync
      break;
    case NetworkStatus.offline:
      print('No internet connection');
      // Switch to offline mode
      break;
    case NetworkStatus.meshOnly:
      print('Mesh network only');
      // Use mesh networking
      break;
  }
});
```

### Network Quality Check

```dart
// Check network quality
final quality = await networkService.checkNetworkQuality();

if (quality.isGood) {
  // Use cloud services
  await sendViaCloud();
} else if (quality.isPoor) {
  // Compress data or use mesh
  await sendViaMesh();
}
```

---

## Integration Guide

### Step 1: Add Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  connectivity_plus: ^5.0.0
  nearby_connections: ^3.0.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  web_socket_channel: ^2.4.0
```

### Step 2: Initialize Services

```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for offline storage
  await Hive.initFlutter();
  
  // Initialize network services
  final networkService = NetworkService();
  await networkService.initialize();
  
  // Initialize mesh networking
  final meshManager = MeshNetworkManager();
  await meshManager.initialize();
  
  runApp(MyApp());
}
```

### Step 3: Implement UI Indicators

```dart
// Show network status in UI
StreamBuilder<NetworkStatus>(
  stream: networkService.connectionStatus,
  builder: (context, snapshot) {
    final status = snapshot.data ?? NetworkStatus.online;
    
    return Container(
      color: _getStatusColor(status),
      child: Row(
        children: [
          Icon(_getStatusIcon(status)),
          Text(_getStatusText(status)),
        ],
      ),
    );
  },
)
```

---

## Troubleshooting

### Common Issues

#### Messages Not Syncing

**Symptoms:**
- Messages stuck in pending state
- Sync indicator spinning indefinitely

**Solutions:**
1. Check internet connectivity
2. Verify Appwrite credentials
3. Check sync queue: `await messageService.clearFailedMessages()`
4. Force sync: `await messageService.forceSyncAll()`

#### Mesh Network Not Discovering Peers

**Symptoms:**
- No nearby devices found
- Mesh indicator shows "Scanning..."

**Solutions:**
1. Verify WiFi and Bluetooth are enabled
2. Check location permissions (required for WiFi Direct)
3. Ensure both devices are on same WiFi network
4. Restart mesh service:
   ```dart
   await meshManager.stop();
   await meshManager.start();
   ```

#### Poor Network Performance

**Symptoms:**
- Slow message delivery
- Frequent timeouts
- High battery drain

**Solutions:**
1. Reduce mesh discovery frequency
2. Limit concurrent connections
3. Enable battery optimization
4. Use data compression:
   ```dart
   messageService.enableCompression = true;
   ```

#### Duplicate Messages

**Symptoms:**
- Messages appear multiple times
- Sync creates duplicates

**Solutions:**
1. Check message deduplication:
   ```dart
   await messageService.removeDuplicates();
   ```
2. Verify local database integrity
3. Clear cache and re-sync:
   ```dart
   await messageService.clearCache();
   await messageService.resyncAll();
   ```

---

## Best Practices

### Performance Optimization

1. **Batch Operations**
   ```dart
   // Instead of sending one by one
   await messageService.sendBatch(messages);
   ```

2. **Lazy Loading**
   ```dart
   // Load messages in chunks
   await messageService.getMessages(limit: 20, offset: 0);
   ```

3. **Smart Sync**
   ```dart
   // Only sync recent messages
   await messageService.syncSince(DateTime.now().subtract(Duration(days: 7)));
   ```

### Security

1. **Encrypt Mesh Messages**
   ```dart
   meshManager.enableEncryption = true;
   meshManager.setEncryptionKey(userSpecificKey);
   ```

2. **Validate Peers**
   ```dart
   meshManager.onPeerDiscovered.listen((peer) async {
     if (await validatePeer(peer)) {
       await meshManager.connect(peer);
     }
   });
   ```

3. **Secure Local Storage**
   ```dart
   // Use encrypted Hive boxes
   final box = await Hive.openBox(
     'messages',
     encryptionCipher: HiveAesCipher(encryptionKey),
   );
   ```

### Battery Optimization

1. **Reduce Scan Frequency**
   ```dart
   meshManager.scanInterval = Duration(seconds: 30);
   ```

2. **Smart Discovery**
   ```dart
   // Only discover when app is in foreground
   if (AppLifecycleState.resumed == state) {
     await meshManager.startDiscovery();
   } else {
     await meshManager.stopDiscovery();
   }
   ```

3. **Connection Pooling**
   ```dart
   meshManager.maxConnections = 5; // Limit concurrent connections
   ```

---

## Advanced Features

### Multi-hop Routing

Enable messages to reach devices beyond direct range:

```dart
meshManager.enableMultiHop = true;
meshManager.maxHops = 3; // Maximum 3 hops
```

### Broadcast Messages

Send message to all nearby peers:

```dart
await meshManager.broadcast(
  message: MessageModel(
    senderId: currentUserId,
    content: 'Emergency announcement',
    timestamp: DateTime.now(),
  ),
);
```

### Network Analytics

Track network performance:

```dart
final analytics = await networkService.getAnalytics();
print('Uptime: ${analytics.uptime}');
print('Messages sent: ${analytics.messagesSent}');
print('Sync failures: ${analytics.syncFailures}');
print('Mesh peers: ${analytics.activeMeshPeers}');
```

---

## Additional Resources

- **Appwrite Real-time**: https://appwrite.io/docs/realtime
- **WiFi Direct**: https://developer.android.com/guide/topics/connectivity/wifip2p
- **Nearby Connections**: https://developers.google.com/nearby/connections/overview
- **Flutter Connectivity**: https://pub.dev/packages/connectivity_plus

---

**For more information:**
- See [APPWRITE_GUIDE.md](APPWRITE_GUIDE.md) for backend setup
- See [DEPLOYMENT.md](DEPLOYMENT.md) for production deployment
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues

