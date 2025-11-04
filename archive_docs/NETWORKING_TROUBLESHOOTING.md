# Networking Troubleshooting Guide

**Version:** 2.0  
**Last Updated:** October 31, 2024

## Quick Diagnostics

Run this diagnostic check first:

```dart
// Check all networking services status
void diagnoseNetworking() {
  print('=== Networking Diagnostics ===\n');
  
  // 1. Connectivity
  final connectivity = ConnectivityService();
  print('Connectivity:');
  print('  Online: ${connectivity.isOnline}');
  print('  Quality: ${connectivity.getNetworkQualityText()}');
  print('  Last Sync: ${connectivity.getLastSyncTimeText()}\n');
  
  // 2. Offline Queue
  final queue = OfflineQueueService();
  final queueStats = queue.getAnalytics();
  print('Offline Queue:');
  print('  Pending: ${queue.pendingActionsCount}');
  print('  Total Synced: ${queueStats['totalSynced']}');
  print('  Total Failed: ${queueStats['totalFailed']}\n');
  
  // 3. Cache
  final cache = CacheService();
  cache.getStatistics().then((stats) {
    print('Cache:');
    print('  Size: ${stats['totalSizeMB'].toStringAsFixed(2)} MB');
    print('  Items: ${stats['diskCacheSize']}');
    print('  Usage: ${stats['usagePercent'].toStringAsFixed(1)}%\n');
  });
  
  // 4. Mesh Network
  final mesh = MeshNetworkService();
  final meshStats = mesh.getStatistics();
  print('Mesh Network:');
  print('  Active: ${meshStats['isActive']}');
  print('  Connected: ${meshStats['connectedNodes']}');
  print('  Hidden: ${meshStats['hiddenNodes']}');
  print('  Visible: ${meshStats['visibleNodes']}\n');
  
  // 5. WebRTC
  final webrtc = WebRTCSignalingService();
  final webrtcStats = webrtc.getStatistics();
  print('WebRTC:');
  print('  Connections: ${webrtcStats['totalConnections']}');
  print('  Connected Peers: ${webrtcStats['connectedPeers']}');
  print('  Bytes Sent: ${webrtcStats['totalBytesSent']}');
  print('  Bytes Received: ${webrtcStats['totalBytesReceived']}\n');
  
  // 6. Message Delivery
  final delivery = MessageDeliveryService();
  final deliveryStats = delivery.getStatistics();
  print('Message Delivery:');
  print('  Tracked: ${deliveryStats['totalTracked']}');
  print('  Sending: ${deliveryStats['sending']}');
  print('  Delivered: ${deliveryStats['delivered']}');
  print('  Read: ${deliveryStats['read']}');
  print('  Failed: ${deliveryStats['failed']}\n');
  
  print('=== End Diagnostics ===');
}
```

---

## Issue Categories

### 1. Connectivity Issues

#### Issue: App shows offline but device has internet

**Symptoms:**
- Orange "No connection" banner
- Messages queuing instead of sending
- Data not loading

**Diagnosis:**
```dart
// Check actual connectivity
final results = await Connectivity().checkConnectivity();
print('Connection types: $results');

// Check if service is detecting correctly
final service = ConnectivityService();
print('Service says online: ${service.isOnline}');
```

**Solutions:**

1. **Restart connectivity service:**
```dart
// Force connectivity check
final connectivity = Connectivity();
final result = await connectivity.checkConnectivity();
ConnectivityService().setConnectivity(result.isNotEmpty);
```

2. **Check permissions:**
   - Android: Location permission required for WiFi/Bluetooth detection
   - iOS: Network permission required

3. **Verify network access:**
```dart
// Test actual internet connectivity
try {
  final response = await http.get(Uri.parse('https://www.google.com'));
  print('Internet accessible: ${response.statusCode == 200}');
} catch (e) {
  print('No internet access: $e');
}
```

#### Issue: Network quality always shows "poor"

**Symptoms:**
- Quality indicator stuck on poor
- Performance seems fine

**Diagnosis:**
```dart
final quality = ConnectivityService().networkQuality;
final connectionType = await Connectivity().checkConnectivity();
print('Quality: $quality, Type: $connectionType');
```

**Solutions:**

1. **Recalibrate quality detection:**
```dart
// Manually set quality based on speed test
ConnectivityService()._updateNetworkQuality(results);
```

2. **Check interference:**
   - Move away from other devices
   - Switch WiFi channel
   - Test on mobile data

---

### 2. Offline Queue Issues

#### Issue: Queue not processing when back online

**Symptoms:**
- Actions stuck in queue
- "Syncing" message never clears
- Queue count not decreasing

**Diagnosis:**
```dart
final queue = OfflineQueueService();
print('Queue size: ${queue.pendingActionsCount}');
print('Is online: ${ConnectivityService().isOnline}');

// Check for stuck actions
for (final action in queue.pendingActions) {
  print('Action: ${action.type}, Retries: ${action.retryCount}, Error: ${action.lastError}');
}
```

**Solutions:**

1. **Force queue processing:**
```dart
await OfflineQueueService().processQueue();
```

2. **Clear failed actions:**
```dart
// Get analytics first to see what failed
final analytics = queue.getAnalytics();
print('Failed actions: ${analytics['totalFailed']}');

// Clear if necessary (WARNING: data loss)
await queue.clearQueue();
```

3. **Check action errors:**
```dart
// Review failed actions
final failedActions = queue.pendingActions
    .where((a) => a.lastError != null)
    .toList();

for (final action in failedActions) {
  print('Failed: ${action.type}');
  print('Error: ${action.lastError}');
  print('Retry count: ${action.retryCount}/${NetworkConfig.maxRetries}');
}
```

4. **Increase retry limit temporarily:**
```dart
// For stuck critical actions, create new action with higher priority
await queue.addAction(OfflineAction(
  type: oldAction.type,
  data: oldAction.data,
  priority: 10, // Max priority
  retryCount: 0, // Reset retries
));
```

#### Issue: Queue fills up too quickly

**Symptoms:**
- Queue at max capacity (100)
- Old actions being dropped
- "Queue full" messages

**Diagnosis:**
```dart
print('Queue size: ${queue.pendingActionsCount}/${NetworkConfig.maxQueueSize}');
print('Queue contents:');
queue.pendingActions.forEach((action) {
  print('  ${action.type} - Priority: ${action.priority} - Age: ${DateTime.now().difference(action.timestamp).inMinutes}min');
});
```

**Solutions:**

1. **Process queue more frequently:**
```dart
// Reduce background sync interval
await BackgroundSyncService().registerOfflineQueueSync(
  frequency: Duration(minutes: 5), // Instead of 15
);
```

2. **Increase queue size:**
```dart
// In network_config.dart
static const int maxQueueSize = 200; // Increase from 100
```

3. **Prioritize actions:**
```dart
// Mark critical actions with higher priority
await queue.addAction(OfflineAction(
  type: 'important_action',
  data: data,
  priority: 9, // High priority
));
```

4. **Clean old actions:**
```dart
// Remove actions older than 3 days instead of 7
final cutoff = DateTime.now().subtract(Duration(days: 3));
queue.pendingActions.removeWhere((action) => 
  action.timestamp.isBefore(cutoff)
);
```

---

### 3. Cache Issues

#### Issue: Cache not saving data

**Symptoms:**
- Data always fetched from network
- Cache statistics show 0 items
- No performance improvement

**Diagnosis:**
```dart
final stats = await CacheService().getStatistics();
print('Memory cache: ${stats['memoryCacheSize']}');
print('Disk cache: ${stats['diskCacheSize']}');
print('Total size: ${stats['totalSizeMB']} MB');

// Test cache write
await CacheService().set('test_key', {'data': 'test'});
final retrieved = await CacheService().get<Map>('test_key');
print('Cache working: ${retrieved != null}');
```

**Solutions:**

1. **Reinitialize cache:**
```dart
final cache = CacheService();
await cache.clear(); // Clear corrupted cache
await cache.initialize(); // Reinitialize
```

2. **Check storage permissions:**
   - Ensure app has storage permission
   - Check available disk space

3. **Verify cache directory:**
```dart
final cacheDir = await getApplicationDocumentsDirectory();
print('Cache dir exists: ${Directory('${cacheDir.path}/cache').existsSync()}');
```

4. **Adjust TTL:**
```dart
// Use longer TTL for persistent data
await cache.set(key, data, ttl: CacheService.longTTL, persistToDisk: true);
```

#### Issue: Cache growing too large

**Symptoms:**
- Cache size near 50MB limit
- Old data not clearing
- App storage issues

**Diagnosis:**
```dart
final stats = await CacheService().getStatistics();
print('Cache size: ${stats['totalSizeMB']} MB / ${NetworkConfig.maxCacheSizeMB} MB');
print('Usage: ${stats['usagePercent']}%');
```

**Solutions:**

1. **Clean expired cache:**
```dart
await CacheService().cleanExpiredCache();
```

2. **Clear all cache:**
```dart
await CacheService().clear();
```

3. **Reduce TTL:**
```dart
// Use shorter TTL for non-critical data
await cache.set(key, data, ttl: CacheService.shortTTL);
```

4. **Increase compression:**
```dart
// Compress large data
await cache.compressCache(key, jsonEncode(largeData));
```

---

### 4. Mesh Network Issues

#### Issue: Devices not discovering each other

**Symptoms:**
- No devices in mesh list
- "0 connected devices"
- Scanning animation not working

**Diagnosis:**
```dart
final mesh = MeshNetworkService();
final stats = mesh.getStatistics();
print('Is active: ${stats['isActive']}');
print('Is advertising: ${stats['isAdvertising']}');
print('Is discovering: ${stats['isDiscovering']}');
print('Connected nodes: ${stats['connectedNodes']}');
print('Hidden nodes: ${stats['hiddenNodes']}');
```

**Solutions:**

1. **Check basic requirements:**
   - Bluetooth enabled on both devices
   - WiFi enabled on both devices
   - Location permission granted (Android)
   - Devices within range (30ft for Bluetooth, 200ft for WiFi Direct)

2. **Restart mesh networking:**
```dart
await mesh.disable();
await Future.delayed(Duration(seconds: 2));
await mesh.enable();
```

3. **Check permissions:**
```dart
// Request required permissions
await Permission.bluetooth.request();
await Permission.bluetoothScan.request();
await Permission.bluetoothConnect.request();
await Permission.location.request();
await Permission.nearbyWifiDevices.request();
```

4. **Use QR pairing:**
```dart
// Generate QR on device A
final pairingData = mesh.generatePairingQRCode();

// Scan QR on device B
final success = await mesh.pairWithQRCode(qrString);
if (!success) {
  print('Pairing failed - check QR not expired');
}
```

5. **Check hidden nodes:**
```dart
// Devices might be hidden (auto-connected but not authenticated)
print('Hidden nodes: ${mesh.hiddenNodes.length}');
// Use QR pairing to make them visible
```

#### Issue: QR pairing fails

**Symptoms:**
- QR code scans but pairing fails
- "Pairing failed" message
- Devices don't appear in list

**Diagnosis:**
```dart
// Check QR code validity
final pairingData = mesh.generatePairingQRCode();
print('Expires at: ${pairingData.expiresAt}');
print('Is expired: ${pairingData.isExpired}');
print('Supported connections: ${pairingData.supportedConnections}');
```

**Solutions:**

1. **Generate new QR code:**
```dart
// QR codes expire after 5 minutes
final newPairingData = mesh.generatePairingQRCode();
// Display new QR code
```

2. **Check connection compatibility:**
```dart
// Verify both devices support same connection types
final device1Connections = pairingData1.supportedConnections;
final device2Connections = pairingData2.supportedConnections;
final commonConnections = device1Connections
    .toSet()
    .intersection(device2Connections.toSet());
print('Common connections: $commonConnections');
```

3. **Verify mesh is enabled:**
```dart
if (!mesh.isActive) {
  await mesh.enable();
}
```

4. **Check auto-connect:**
```dart
// Enable auto-connect for better pairing
mesh.setAutoConnect(true);
```

#### Issue: Mesh connections drop frequently

**Symptoms:**
- Devices connect then disconnect
- "Connection lost" messages
- Unreliable messaging

**Diagnosis:**
```dart
// Monitor connection stability
for (final node in mesh.connectedNodes) {
  final age = DateTime.now().difference(node.connectedAt);
  print('Node ${node.name}: ${node.connectionType.name}, Age: ${age.inMinutes}min');
}
```

**Solutions:**

1. **Check range:**
   - Move devices closer
   - Remove obstacles between devices
   - Switch to WiFi Direct instead of Bluetooth

2. **Check interference:**
   - Move away from other Bluetooth/WiFi devices
   - Change WiFi channel
   - Disable other apps using Bluetooth

3. **Increase timeout:**
```dart
// In network_config.dart
static const Duration meshNodeTimeout = Duration(minutes: 10); // Increase from 5
```

4. **Monitor battery:**
   - Low battery disables mesh features
   - Connect to power if possible

---

### 5. WebRTC Issues

#### Issue: WebRTC peers not connecting

**Symptoms:**
- Peers stuck in "connecting" state
- No data channel established
- WebRTC stats show 0 connected peers

**Diagnosis:**
```dart
final webrtc = WebRTCSignalingService();
final stats = webrtc.getStatistics();
print('Total connections: ${stats['totalConnections']}');
print('Connected peers: ${stats['connectedPeers']}');
print('Connection states: ${stats['connectionStates']}');

// Check specific peer
final info = webrtc.getConnectionInfo(peerId);
print('Peer state: ${info?['state']}');
print('Bytes sent: ${info?['bytesSent']}');
```

**Solutions:**

1. **Check signaling transport:**
```dart
// Verify signaling messages are being exchanged
webrtc.signalingStream.listen((message) {
  print('Signaling: ${message.type.name} from ${message.from} to ${message.to}');
  // Make sure these are being sent via transport
});
```

2. **Verify STUN servers:**
```dart
// Test STUN server connectivity
// STUN servers must be accessible for NAT traversal
```

3. **Retry connection:**
```dart
await webrtc.disconnectPeer(peerId);
await Future.delayed(Duration(seconds: 2));
await webrtc.createOffer(peerId);
```

4. **Check firewall/NAT:**
   - Some networks block WebRTC
   - Try on different network
   - Use mesh fallback if WebRTC fails

5. **Enable TURN server (if available):**
```dart
// Add TURN server for better NAT traversal
final turnConfig = {
  'urls': 'turn:your-turn-server.com:3478',
  'username': 'username',
  'credential': 'password',
};
```

#### Issue: WebRTC data not transmitting

**Symptoms:**
- Connection established but no data
- Messages not arriving
- Data channel closed

**Diagnosis:**
```dart
final info = webrtc.getConnectionInfo(peerId);
print('Bytes sent: ${info?['bytesSent']}');
print('Bytes received: ${info?['bytesReceived']}');

// Try sending test message
final success = await webrtc.sendMessage(peerId, {'test': 'ping'});
print('Send successful: $success');
```

**Solutions:**

1. **Check data channel state:**
```dart
// Data channel must be open
// If closed, recreate connection
await webrtc.disconnectPeer(peerId);
await webrtc.createOffer(peerId);
```

2. **Verify message size:**
```dart
// Messages must be under 16KB
final messageSize = jsonEncode(message).length;
if (messageSize > NetworkConfig.webrtcMaxPacketSize) {
  // Split message or compress
}
```

3. **Check connection quality:**
```dart
// Poor connection may drop packets
// Use mesh fallback for critical messages
```

---

### 6. Message Delivery Issues

#### Issue: Delivery status not updating

**Symptoms:**
- Messages stuck in "sending"
- Read receipts not working
- Delivery timestamps missing

**Diagnosis:**
```dart
final delivery = MessageDeliveryService();
final status = delivery.getDeliveryStatus(messageId);
print('Status: ${status?.status.name}');
print('Sent at: ${status?.sentAt}');
print('Delivered at: ${status?.deliveredAt}');
print('Read at: ${status?.readAt}');
print('Error: ${status?.errorMessage}');
```

**Solutions:**

1. **Force status update:**
```dart
await delivery.updateDeliveryStatus(
  messageId,
  MessageDeliveryStatus.delivered,
);
```

2. **Check database connection:**
```dart
// Verify Supabase connection
final supabase = Supabase.instance.client;
final response = await supabase.from('message_delivery_status').select().limit(1);
print('DB accessible: ${response.isNotEmpty}');
```

3. **Re-initialize service:**
```dart
delivery.dispose();
await delivery.initialize(currentUserId);
```

4. **Check RLS policies:**
   - Verify user has permission to update delivery status
   - Check Supabase policies are correctly configured

#### Issue: Typing indicators not showing

**Symptoms:**
- "Typing..." doesn't appear
- Stale indicators
- Indicators never clear

**Diagnosis:**
```dart
final delivery = MessageDeliveryService();
final typingUsers = delivery.getTypingUsers(conversationId);
print('Typing users: $typingUsers');

// Check for stale indicators
// (Should auto-cleanup after 10 seconds)
```

**Solutions:**

1. **Send typing indicator:**
```dart
// When user starts typing
await delivery.sendTypingIndicator(
  conversationId,
  TypingStatus.typing,
);

// When user stops typing
await delivery.sendTypingIndicator(
  conversationId,
  TypingStatus.stopped,
);
```

2. **Clear stale indicators:**
```dart
// Indicators auto-cleanup, but can force:
await supabase
    .from('typing_indicators')
    .delete()
    .lt('timestamp', DateTime.now().subtract(Duration(seconds: 30)).toIso8601String());
```

3. **Check subscription:**
```dart
// Verify real-time subscription is active
delivery.typingStream.listen((indicator) {
  print('Typing update: ${indicator.userId} in ${indicator.conversationId}');
});
```

---

## Performance Issues

### Issue: App slow or laggy

**Diagnosis:**
```dart
// Check all service stats
diagnoseNetworking();

// Check for resource issues
print('Queue size: ${OfflineQueueService().pendingActionsCount}');
print('Cache size: ${await CacheService().getCacheSizeMB()} MB');
print('Mesh connections: ${MeshNetworkService().connectedNodes.length}');
print('WebRTC connections: ${WebRTCSignalingService().connectedPeers.length}');
```

**Solutions:**

1. **Reduce concurrent operations:**
```dart
// Use battery saver profile
final profile = NetworkProfiles.batterySaver;
// Apply profile settings
```

2. **Clear cache:**
```dart
await CacheService().clear();
await CacheService().initialize();
```

3. **Limit mesh connections:**
```dart
// Reduce max connections
// In network_config.dart
static const int maxMeshConnections = 5; // Reduce from 10
```

4. **Disable unused features:**
```dart
// Disable features you're not using
if (!needsMesh) await MeshNetworkService().disable();
if (!needsWebRTC) await WebRTCSignalingService().disconnectAll();
```

---

## Emergency Recovery

### Nuclear Option: Reset All Networking

**WARNING:** This will clear all queued data, cache, and connections.

```dart
Future<void> resetAllNetworking() async {
  print('🚨 Resetting all networking services...');
  
  try {
    // 1. Disconnect all
    await MeshNetworkService().disable();
    await WebRTCSignalingService().disconnectAll();
    
    // 2. Clear queue
    await OfflineQueueService().clearQueue();
    
    // 3. Clear cache
    await CacheService().clear();
    
    // 4. Dispose services
    ConnectivityService().dispose();
    MessageDeliveryService().dispose();
    MeshNetworkService().dispose();
    await WebRTCSignalingService().dispose();
    
    // 5. Wait a bit
    await Future.delayed(Duration(seconds: 2));
    
    // 6. Reinitialize
    await CacheService().initialize();
    // (Other services auto-initialize)
    
    print('✅ Reset complete. Please restart app.');
  } catch (e) {
    print('❌ Reset failed: $e');
  }
}
```

---

## Getting Help

If issues persist:

1. **Collect diagnostics:**
```dart
diagnoseNetworking();
```

2. **Check logs:**
   - Enable debug logging
   - Review error messages
   - Note exact steps to reproduce

3. **Report issue:**
   - Include diagnostic output
   - Describe expected vs actual behavior
   - Share relevant code snippets
   - Note device/OS version

4. **Community support:**
   - Check GitHub issues
   - Search documentation
   - Ask in discussions

---

**Last Updated:** October 31, 2024  
**Version:** 2.0
