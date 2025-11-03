# Mesh Network Guide

## Overview

The RPI Communication App now includes a **Mesh Network** feature that enables peer-to-peer communication between devices using Bluetooth and WiFi Direct, even without an internet connection or cellular service.

## What is Mesh Networking?

Mesh networking allows devices to connect directly to each other and relay messages, creating a decentralized network. This is particularly useful in scenarios where:

- Internet connectivity is unavailable or unreliable
- Cellular networks are down
- Emergency situations require communication without infrastructure
- You want to reduce reliance on centralized servers

## Features

### 1. Peer-to-Peer Communication
- Direct device-to-device messaging via multiple connection types
- No internet or cellular connection required
- Works even when Firebase is unavailable
- Supports: Bluetooth, WiFi Direct, WiFi Router, LAN, USB

### 2. QR Code Pairing
- Secure device pairing using QR codes
- App-specific QR format (cannot be read by standard QR apps)
- Time-limited pairing codes (5-minute expiry)
- One-tap pairing process

### 3. Auto-Connect with Hidden Nodes
- Automatically connect to all available devices
- Connections remain hidden until authenticated
- QR pairing reveals and trusts connections
- Privacy-focused design

### 4. Message Routing
- Automatic message forwarding through connected devices
- Loop prevention to avoid message duplication
- Multi-hop routing to reach distant devices

### 5. Multiple Connection Types
- **Bluetooth**: Close-range (~30ft), low power
- **WiFi Direct**: Medium-range (~200ft), faster
- **WiFi Router**: Same network, very fast
- **LAN**: Wired connection, fastest and most stable
- **USB**: Direct wired connection (future)

### 6. Hybrid Mode
- Seamlessly switches between mesh network and traditional internet
- Fallback to Firebase when available
- Sync messages when internet is restored

## How to Use

### Enable Mesh Network

1. Open the app and go to your **Profile**
2. Tap on **Mesh Network** in the Settings section
3. Toggle **Enable Mesh Network** to ON
4. The app will start:
   - **Broadcasting**: Making your device discoverable
   - **Discovering**: Searching for nearby devices

### Connect to Devices Using QR Codes

The recommended way to pair devices is using QR codes:

1. On **Device A**:
   - Go to Mesh Network settings
   - Tap **"Pair Device"**
   - A unique QR code will be displayed

2. On **Device B**:
   - Go to Mesh Network settings
   - Tap **"Pair Device"**
   - Tap the scanner icon (top-right)
   - Point camera at Device A's QR code

3. **Connection Established**:
   - Devices automatically connect using best available method
   - Connection becomes visible in device list
   - Both devices can now communicate

### Auto-Connect Mode

When auto-connect is enabled:
- Devices automatically connect using all available methods
- Connections remain **hidden** until authenticated via QR
- Provides background connectivity without cluttering UI
- Hidden devices don't appear in your device list
- QR pairing makes connections visible and trusted

To toggle auto-connect:
1. Go to Mesh Network settings
2. Toggle **"Auto-Connect to Devices"**

### Send Messages via Mesh

When mesh network is enabled and you have connected devices:
1. Messages are automatically routed through available connections
2. If internet is unavailable, messages use mesh network
3. When internet is restored, messages sync to Firebase

### Monitor Connections

In the Mesh Network screen, you can see:
- **Visible Devices**: Number of authenticated (QR-paired) connections
- **Hidden Devices**: Number of auto-connected but unauthenticated devices
- **Messages Exchanged**: Total mesh messages sent/received
- **Broadcasting**: Whether your device is discoverable
- **Discovering**: Whether searching for peers
- **Device List**: Details of each visible connection with connection type icons

## Technical Details

### Supported Connection Types

The app automatically uses the best available connection:

1. **LAN (Ethernet)**: 
   - Range: Network-dependent
   - Speed: Fastest (1Gbps+)
   - Stability: Highest
   - Best for: Office/lab environments

2. **WiFi Router**:
   - Range: Router coverage area
   - Speed: Very fast (100-1000Mbps)
   - Stability: High
   - Best for: Same network connections

3. **WiFi Direct**:
   - Range: ~200 feet (60 meters)
   - Speed: Fast (100-300Mbps)
   - Stability: Medium
   - Best for: Direct peer connections

4. **Bluetooth**:
   - Range: ~30 feet (10 meters)
   - Speed: Moderate (1-3Mbps)
   - Stability: Medium
   - Best for: Close-proximity, low power

5. **USB** (Future):
   - Range: Cable length
   - Speed: Very fast
   - Stability: Highest
   - Best for: Direct wired connection

### Message Types

The mesh network can transmit:
- **Notice broadcasts**: Share notices with connected peers
- **Direct messages**: Send messages to specific users
- **Sync requests**: Request data from peers
- **Sync responses**: Share data with requesting peers

### Security Considerations

1. **QR Code Security**:
   - Time-limited tokens (5-minute expiry)
   - Unique pairing code per session
   - App-specific format (cannot be read by standard QR apps)
   - Cannot be reused or replicated
   - Automatic cleanup of expired codes

2. **Device Authentication**:
   - Only authenticated app users can join mesh
   - Firebase user ID used as device identifier
   - QR pairing required for visible connections
   - Hidden nodes cannot send/receive until authenticated

3. **Message Integrity**:
   - Messages include sender verification
   - Timestamps prevent replay attacks
   - Route tracking prevents loops
   - End-to-end authentication

4. **Privacy**:
   - Auto-connected devices remain hidden
   - Only QR-paired devices are visible
   - Only share data with explicitly trusted peers
   - Messages are not stored on intermediate devices
   - Disconnect removes all cached data

## Best Practices

### For Optimal Performance

1. **Use QR Pairing**:
   - Always pair devices using QR codes
   - More secure than manual connection
   - Faster and more reliable
   - Automatic best-connection selection

2. **Keep Connectivity Enabled**:
   - Keep Bluetooth/WiFi enabled for best results
   - WiFi provides faster speeds
   - Multiple connection types increase reliability
   - Disable airplane mode

3. **Battery Management**:
   - Mesh networking uses more battery
   - Auto-connect mode is efficient (hidden nodes use less power)
   - Disable when not needed
   - LAN/WiFi router connections use less battery than Bluetooth

4. **Network Hygiene**:
   - QR codes expire after 5 minutes (automatic cleanup)
   - Disconnect from inactive devices
   - Hidden nodes auto-timeout after inactivity
   - Clear old connections periodically

### For Emergency Use

1. **Pre-enable Mesh Network**:
   - Enable before emergencies
   - Test connections with colleagues

2. **Stay Within Range**:
   - Keep devices within Bluetooth/WiFi range
   - Use relay devices for extended coverage

3. **Conserve Battery**:
   - Reduce screen brightness
   - Close unnecessary apps
   - Use power-saving mode

## Limitations

### Technical Limitations

1. **Range**: Limited by Bluetooth/WiFi Direct range
2. **Speed**: Slower than internet connection
3. **Battery**: Higher power consumption
4. **Discovery Time**: May take 10-30 seconds to find devices

### What Mesh Network Cannot Do

1. **Radio Transmission**: 
   - Cannot use cellular radio without SIM
   - Not a replacement for emergency broadcast systems
   - Cannot transmit on emergency frequencies

2. **Long-Range Communication**:
   - Limited to nearby devices
   - Not suitable for city-wide communication
   - Requires intermediate devices for extended range

## Troubleshooting

### QR Code Won't Scan

**Problem**: Cannot scan QR code for pairing

**Solutions**:
1. Ensure camera permissions are granted
2. Keep QR code steady and well-lit
3. QR code expires after 5 minutes - generate new one
4. Make sure both devices have mesh network enabled
5. Try adjusting distance from QR code (6-12 inches ideal)
6. Clean camera lens

### QR Code Pairing Failed

**Problem**: QR code scanned but pairing failed

**Solutions**:
1. Check if QR code is expired (shows timer on screen)
2. Ensure both devices are on same WiFi network (if using WiFi Router mode)
3. Try generating a new QR code
4. Restart mesh networking on both devices
5. Check that auto-connect is enabled

### Devices Not Appearing

**Problem**: Paired device not showing in list

**Solutions**:
1. Device may be in hidden nodes (not QR-paired yet)
2. Check "Hidden Devices" count in statistics
3. QR pair the device to make it visible
4. Refresh the device list
5. Toggle auto-connect mode

### Device Not Discovering

**Problem**: Cannot find nearby devices

**Solutions**:
1. Check Bluetooth and WiFi are enabled
2. Grant location permissions (required for Bluetooth discovery on Android)
3. Ensure other devices have mesh networking enabled
4. Try toggling mesh network off and on
5. Move closer to other devices
6. Enable auto-connect mode

### Connection Drops

**Problem**: Devices disconnect frequently

**Solutions**:
1. Stay within range (30 ft for Bluetooth, 200 ft for WiFi Direct)
2. Reduce interference (move away from other devices)
3. Check battery level (low battery may disable features)
4. Restart mesh networking

### Messages Not Sending

**Problem**: Messages not reaching other devices

**Solutions**:
1. Verify at least one device is connected
2. Check network quality in Sync Settings
3. Try sending again after a few seconds
4. Switch to internet connection if available

### High Battery Drain

**Problem**: Battery depleting quickly

**Solutions**:
1. Disable mesh network when not needed
2. Reduce number of connected devices
3. Use only when necessary
4. Enable battery saver mode

## FAQ

### Q: How do I pair devices?
**A:** Use the QR code pairing feature. Go to Mesh Network → Pair Device. One device generates a QR code, the other scans it.

### Q: Why can't I see connected devices?
**A:** Devices auto-connect but remain hidden until you pair them with QR codes. This is a security feature. Check "Hidden Devices" count in statistics.

### Q: Can someone else scan my QR code?
**A:** QR codes are time-limited (5 minutes) and app-specific. Standard QR readers cannot decode them. They're designed for secure pairing.

### Q: Do I need internet to use mesh network?
**A:** No, mesh networking works completely offline using multiple connection types (Bluetooth, WiFi, LAN).

### Q: Can I use this without a SIM card?
**A:** Yes, mesh networking works without a SIM card or cellular service.

### Q: What connection types are supported?
**A:** Bluetooth, WiFi Direct, WiFi Router (same network), LAN (ethernet), and USB (future). The app automatically uses the best available.

### Q: How many devices can connect?
**A:** Theoretically unlimited through multi-hop routing, but performance degrades with many hops. Recommended: 5-10 direct connections per device.

### Q: Does it work on iOS?
**A:** iOS has limitations on background Bluetooth/WiFi Direct. Performance may vary.

### Q: Is it secure?
**A:** Yes, QR code authentication required, time-limited tokens, and only authenticated app users can join. Messages include sender verification.

### Q: Can authorities track mesh messages?
**A:** Mesh messages are peer-to-peer and not stored on servers, but device-to-device communication can still be detected.

### Q: What happens to messages when I go back online?
**A:** Messages automatically sync to Firebase when internet connection is restored.

### Q: Can I use this for large files?
**A:** Currently optimized for text messages and notices. Large files may be slow over mesh network. Speed depends on connection type (LAN is fastest).

## Emergency Communication Notice

⚠️ **Important**: While the mesh network enables communication without internet or cellular service, it is NOT a replacement for official emergency communication systems:

1. **Always use official emergency services (911, etc.) when available**
2. **Mesh network is for institutional communication only**
3. **Not designed for life-threatening emergencies**
4. **Cannot transmit on emergency radio frequencies**
5. **Range is limited to nearby devices**

In true emergencies, always prioritize:
1. Official emergency services
2. Emergency broadcast systems
3. Ham radio (if licensed)
4. Landline telephones
5. Mesh network (for coordination within institution)

## Support

For issues or questions:
1. Check this guide
2. Review Troubleshooting section
3. Contact system administrator
4. Report bugs through the app

## Future Enhancements

Planned improvements:
- [ ] File sharing over mesh
- [ ] Voice messages over mesh
- [ ] Automatic mesh-to-internet bridge
- [ ] Enhanced encryption
- [ ] Group mesh channels
- [ ] Mesh network analytics

---

**Version**: 1.0  
**Last Updated**: October 2024  
**Compatible with**: RPI Communication App v1.0.0+
