# Networking System - Visual Overview

**Version:** 2.0  
**Last Updated:** October 31, 2024

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        APPLICATION LAYER                              │
│                                                                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐│
│  │   Notices   │  │  Messages   │  │   Profile   │  │  Settings   ││
│  │   Screen    │  │   Screen    │  │   Screen    │  │   Screen    ││
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘│
└─────────┼─────────────────┼─────────────────┼─────────────────┼──────┘
          │                 │                 │                 │
┌─────────┴─────────────────┴─────────────────┴─────────────────┴──────┐
│                         SERVICE LAYER                                 │
│                                                                       │
│  ┌──────────────────────┐  ┌──────────────────────┐                │
│  │ ConnectivityService  │  │  MessageDelivery     │                │
│  │                      │  │  Service             │                │
│  │ • Network monitoring │  │ • Delivery tracking  │                │
│  │ • Quality detection  │  │ • Typing indicators  │                │
│  │ • Auto reconnection  │  │ • Read receipts      │                │
│  └──────────────────────┘  └──────────────────────┘                │
│                                                                       │
│  ┌──────────────────────┐  ┌──────────────────────┐                │
│  │ OfflineQueueService  │  │  CacheService        │                │
│  │                      │  │                      │                │
│  │ • Action queuing     │  │ • Memory cache       │                │
│  │ • Auto retry         │  │ • Disk cache         │                │
│  │ • Priority handling  │  │ • Compression        │                │
│  └──────────────────────┘  └──────────────────────┘                │
│                                                                       │
│  ┌──────────────────────┐  ┌──────────────────────┐                │
│  │ MeshNetworkService   │  │  WebRTCSignaling     │                │
│  │                      │  │  Service             │                │
│  │ • P2P via BT/WiFi   │  │ • High-speed P2P     │                │
│  │ • QR pairing         │  │ • Data channels      │                │
│  │ • Multi-hop routing  │  │ • NAT traversal      │                │
│  └──────────────────────┘  └──────────────────────┘                │
│                                                                       │
│  ┌──────────────────────┐  ┌──────────────────────┐                │
│  │ BackgroundSync       │  │  ConflictResolution  │                │
│  │ Service              │  │  Service             │                │
│  │                      │  │                      │                │
│  │ • Periodic sync      │  │ • Version tracking   │                │
│  │ • Battery aware      │  │ • Strategy selection │                │
│  │ • Network aware      │  │ • Auto merging       │                │
│  └──────────────────────┘  └──────────────────────┘                │
└───────────────────────────────────────────────────────────────────────┘
          │                                                     │
┌─────────┴─────────────────────────────────────────────────────┴───────┐
│                        TRANSPORT LAYER                                 │
│                                                                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐            │
│  │ Supabase │  │  WebRTC  │  │Bluetooth │  │   WiFi   │            │
│  │  (HTTP)  │  │  (P2P)   │  │  (Mesh)  │  │  Direct  │            │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘            │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 📊 Service Dependency Map

```
NetworkConfig (Configuration)
    ↓
    ├── ConnectivityService (Network Monitoring)
    │       ↓
    │       ├── OfflineQueueService (Queue Management)
    │       │       ↓
    │       │       └── BackgroundSyncService (Sync Worker)
    │       │
    │       └── MessageDeliveryService (Delivery Tracking)
    │
    ├── CacheService (Data Caching)
    │       ↓
    │       └── All Services (Cache consumers)
    │
    ├── MeshNetworkService (P2P Communication)
    │       ↓
    │       └── WebRTCSignalingService (High-speed P2P)
    │
    └── ConflictResolutionService (Conflict Handling)
```

---

## 🔄 Message Flow Diagrams

### Online Message Flow

```
User Types Message
        ↓
[Check Connectivity]
        ↓
   [Is Online?] ──NO──→ [Queue Action] → [Wait for Online]
        ↓ YES
        ↓
[Track Delivery: SENDING]
        ↓
[Send via Supabase]
        ↓
[Track Delivery: SENT]
        ↓
[Real-time to Recipient]
        ↓
[Track Delivery: DELIVERED]
        ↓
[Recipient Opens]
        ↓
[Track Delivery: READ]
        ↓
[Update UI with ✓✓]
```

### Offline Message Flow

```
User Types Message
        ↓
[Check Connectivity]
        ↓
   [Is Offline]
        ↓
[Create OfflineAction]
   priority: 8
        ↓
[Add to Queue]
        ↓
[Save to Storage]
        ↓
[Show "Queued" UI]
        ↓
[Wait for Connection]
        ↓
[Connection Restored]
        ↓
[Process Queue]
        ↓
  [Retry Logic]
  1s → 2s → 4s
        ↓
   [Success?] ──NO──→ [Re-queue] → [Retry Again]
        ↓ YES
        ↓
[Remove from Queue]
        ↓
[Update UI]
```

### Mesh Message Flow

```
User Types Message
        ↓
[Check Connection Types]
        ↓
        ├── [Online?] ──YES──→ [Send via Supabase]
        │
        ├── [WebRTC?] ──YES──→ [Send via WebRTC]
        │       ↓
        │   [Direct P2P]
        │   Low latency
        │
        └── [Mesh?] ──YES──→ [Send via Mesh]
                ↓
           [Check Route]
                ↓
          [Find Best Path]
                ↓
          [Multi-hop Forward]
                ↓
             [Deliver]
```

---

## 📈 Performance Characteristics

### Latency Comparison

```
Online (Supabase):     200-500ms  ████████░░
WebRTC P2P:           < 100ms     ██░░░░░░░░
Mesh (1-hop):          50-150ms   ███░░░░░░░
Mesh (2-hop):         100-300ms   ████████░░
Mesh (3-hop):         150-450ms   ████████████

Legend: █ = 50ms
```

### Throughput Comparison

```
Online (Supabase):     1-10 Mbps   ████████
WebRTC:               10-100 Mbps  ████████████████████
Bluetooth Mesh:        1-3 Mbps    ██
WiFi Direct Mesh:     10-300 Mbps  ████████████████████
LAN Mesh:            100-1000 Mbps ████████████████████████████

Legend: █ = 50 Mbps
```

### Range Comparison

```
Online (Supabase):     Unlimited   ████████████████████████████████
WebRTC:               Unlimited*   ████████████████████████████████
Bluetooth:            30 ft        ████
WiFi Direct:          200 ft       ████████████████
WiFi Router:          300 ft       ████████████████████████
LAN:                  Network      ████████████████████████████

* Requires signaling server
Legend: █ = 10 feet
```

---

## 🎯 Feature Matrix

```
┌────────────────────┬─────────┬─────────┬────────┬─────────┬─────────┐
│ Feature            │ Online  │ WebRTC  │ Mesh   │ Offline │ Cache   │
├────────────────────┼─────────┼─────────┼────────┼─────────┼─────────┤
│ Message Send       │   ✓     │   ✓     │   ✓    │  Queue  │   -     │
│ Message Receive    │   ✓     │   ✓     │   ✓    │   -     │   ✓     │
│ Delivery Tracking  │   ✓     │   ✓     │   ✓    │   ✓     │   -     │
│ Typing Indicators  │   ✓     │   ✓     │   ✓    │   -     │   -     │
│ Read Receipts      │   ✓     │   ✓     │   ✓    │   ✓     │   -     │
│ File Attachments   │   ✓     │   ✓     │  Plan  │   ✓     │   ✓     │
│ Voice Messages     │   ✓     │   ✓     │  Plan  │   ✓     │   ✓     │
│ Group Chat         │   ✓     │  Plan   │  Plan  │   ✓     │   ✓     │
│ Search             │   ✓     │   -     │   -    │   -     │   ✓     │
│ Sync              │  Auto   │  Auto   │  Auto  │  Manual │  Auto   │
│ Battery Impact     │  Low    │  Medium │  High  │  Low    │  Low    │
│ Data Usage        │  High   │  Low    │  None  │  None   │  None   │
│ Reliability       │  High   │  Medium │  Low   │  High   │  High   │
└────────────────────┴─────────┴─────────┴────────┴─────────┴─────────┘

Legend: ✓ = Supported, Plan = Planned, - = Not Applicable
```

---

## 🔒 Security Matrix

```
┌────────────────────┬─────────┬─────────┬────────┬─────────┬─────────┐
│ Security Feature   │ Online  │ WebRTC  │ Mesh   │ Offline │ Cache   │
├────────────────────┼─────────┼─────────┼────────┼─────────┼─────────┤
│ Encryption         │  HTTPS  │  DTLS   │ QR Auth│  Local  │  Local  │
│ Authentication     │   RLS   │ Signl   │   QR   │  User   │  User   │
│ Authorization      │   Yes   │   Yes   │  Yes   │   Yes   │   Yes   │
│ Data Isolation     │   Yes   │   Yes   │  Yes   │   Yes   │   Yes   │
│ Token Expiry       │   24h   │   -     │  5min  │   -     │  Varies │
│ Audit Trail        │   Yes   │   No    │  No    │   Yes   │   No    │
│ Rate Limiting      │   Yes   │   No    │  No    │   Yes   │   N/A   │
│ Input Validation   │   Yes   │   Yes   │  Yes   │   Yes   │   Yes   │
└────────────────────┴─────────┴─────────┴────────┴─────────┴─────────┘

Legend: RLS = Row Level Security, Signl = Signaling Auth
```

---

## 📊 Resource Usage

### Memory Usage

```
Service                Memory      Description
─────────────────────  ──────────  ─────────────────────────
ConnectivityService    < 1 MB      Event listeners only
OfflineQueueService    ~ 1-5 MB    Max 100 actions
CacheService           ~ 10-50 MB  Configurable limit
MeshNetworkService     ~ 5-10 MB   Node management
WebRTCSignalingService ~ 5-15 MB   Per connection
MessageDeliveryService ~ 1-3 MB    Tracking data
BackgroundSyncService  < 1 MB      Worker only
ConflictResolution     < 1 MB      Minimal state

Total Estimated:       25-85 MB    Typical: ~40 MB
```

### Storage Usage

```
Component              Storage     Description
─────────────────────  ──────────  ─────────────────────────
Offline Queue          ~ 100 KB    100 actions max
Cache (Disk)           ~ 50 MB     Configurable limit
Database (Local)       ~ 10 MB     SQLite storage
Total Estimated:       ~ 60 MB     Typical usage
```

### Battery Impact

```
Feature                Impact      Description
─────────────────────  ──────────  ─────────────────────────
Connectivity Monitor   Low         Event-based
Background Sync        Low         15-min intervals
Online Messaging       Low         Push-based
WebRTC                 Medium      Active connections
Mesh Network           High        Constant scanning
Cache                  Low         Disk I/O only
Delivery Tracking      Low         Real-time subs

Overall Impact:        Low-Medium  Depends on features used
```

---

## 🎨 UI States

### Connection Status Banner

```
┌─────────────────────────────────────────────────────────┐
│ 🔴 No Connection - 3 messages queued                    │
└─────────────────────────────────────────────────────────┘
    Offline mode - actions queued

┌─────────────────────────────────────────────────────────┐
│ 🟡 Poor Connection - Using offline mode                 │
└─────────────────────────────────────────────────────────┘
    Poor network quality detected

┌─────────────────────────────────────────────────────────┐
│ 🟢 Syncing... 2 of 5 completed                         │
└─────────────────────────────────────────────────────────┘
    Processing offline queue

[No banner shown when online with good quality]
```

### Message Delivery Status

```
Your message                                            9:42 AM
                                                          ✓

Your message                                            9:42 AM
                                                         ✓✓

Your message                                            9:42 AM
                                                         ✓✓ (blue)

Sending...                                              9:42 AM
                                                          ⏳

Failed to send - Tap to retry                           9:42 AM
                                                          ❌

Legend:
✓    = Sent to server
✓✓   = Delivered to device  
✓✓   = Read by recipient (blue checkmarks)
⏳   = Sending in progress
❌   = Failed to send
```

### Typing Indicators

```
┌─────────────────────────────────────────────────────────┐
│ Messages                                            [≡] │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  [Messages displayed here]                              │
│                                                         │
│  John is typing...                                      │
│  ●●●                                                    │
│                                                         │
├─────────────────────────────────────────────────────────┤
│  [Type a message...]                              [>]  │
└─────────────────────────────────────────────────────────┘
```

---

## 🔄 State Transitions

### Connection States

```
          ┌─────────────┐
          │  UNKNOWN    │ (Initial state)
          └──────┬──────┘
                 │ Check connectivity
                 ↓
          ┌─────────────┐
    ┌─────│   OFFLINE   │─────┐
    │     └──────┬──────┘     │
    │            │ Connected  │ Disconnected
    │            ↓            │
    │     ┌─────────────┐    │
    │     │  CHECKING   │    │
    │     └──────┬──────┘    │
    │            │ Quality OK │
    │            ↓            │
    │     ┌─────────────┐    │
    └────→│   ONLINE    │←───┘
          └─────────────┘
```

### Message States

```
          ┌─────────────┐
          │  COMPOSED   │ (User typed message)
          └──────┬──────┘
                 │ Send
                 ↓
          ┌─────────────┐
    ┌─────│   SENDING   │─────┐
    │     └──────┬──────┘     │
    │            │ Success    │ Failed
    │            ↓            │
    │     ┌─────────────┐    │
    │     │    SENT     │    │
    │     └──────┬──────┘    │
    │            │            │
    │            ↓            ↓
    │     ┌─────────────┐  ┌─────────────┐
    │     │ DELIVERED   │  │   FAILED    │←─┐
    │     └──────┬──────┘  └──────┬──────┘  │
    │            │                │ Retry   │
    │            ↓                └─────────┘
    │     ┌─────────────┐
    └────→│    READ     │
          └─────────────┘
```

---

## 📖 Quick Reference

### Service Initialization Order

```
1. NetworkConfig.validate()
2. CacheService().initialize()
3. OfflineQueueService().loadQueue()
4. BackgroundSyncService().initialize()
5. MessageDeliveryService().initialize(userId)
6. MeshNetworkService().initialize(userId, deviceName)
7. WebRTCSignalingService().initialize(userId)
```

### Common Operations

```dart
// Send message with full tracking
await sendMessageWithTracking(
  recipientId: 'user123',
  content: 'Hello!',
);

// Check connectivity
if (ConnectivityService().isOnline) {
  // Online operation
}

// Use cache
final data = await fetchWithCache(
  key: 'my_data',
  fetchFn: () => fetchFromServer(),
  fromJson: (json) => MyData.fromJson(json),
);

// Pair mesh devices
final pairingData = MeshNetworkService().generatePairingQRCode();
final success = await MeshNetworkService().pairWithQRCode(qrString);

// Connect WebRTC
await WebRTCSignalingService().createOffer(peerId);
await WebRTCSignalingService().sendMessage(peerId, data);
```

### Configuration Profiles

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

---

## 📚 Documentation Links

- [Complete Networking Guide](NETWORKING_COMPLETE_GUIDE.md) - Full API reference
- [Troubleshooting Guide](NETWORKING_TROUBLESHOOTING.md) - Problem solving
- [Integration Guide](NETWORKING_INTEGRATION_GUIDE.md) - Code examples
- [V2 Summary](NETWORKING_IMPROVEMENTS_V2_SUMMARY.md) - Complete overview

---

**Version:** 2.0  
**Last Updated:** October 31, 2024  
**Status:** ✅ Production Ready
