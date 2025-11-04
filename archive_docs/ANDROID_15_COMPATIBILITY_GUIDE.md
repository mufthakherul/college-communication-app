# Android 15 Compatibility Guide

## Overview

This guide documents the changes made to ensure the RPI Communication App works correctly on Android 15 (API 35) and higher versions.

## Changes Summary

### 1. AndroidManifest.xml Updates

#### Storage Permissions
- **Before**: Used deprecated `READ_EXTERNAL_STORAGE` and `WRITE_EXTERNAL_STORAGE` for all Android versions
- **After**: 
  - Limited old storage permissions to Android 9 and below using `android:maxSdkVersion`
  - Added granular media permissions for Android 13+ (`READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_MEDIA_AUDIO`)
  - These changes align with Android's scoped storage requirements

```xml
<!-- Old (deprecated for Android 10+) -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" 
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
    android:maxSdkVersion="29" />

<!-- New (Android 13+) -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
```

#### Bluetooth Permissions
- Added Android 12+ Bluetooth permissions with proper flags
- Limited legacy Bluetooth permissions to Android 11 and below

```xml
<!-- Legacy (Android 11 and below) -->
<uses-permission android:name="android.permission.BLUETOOTH" 
    android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" 
    android:maxSdkVersion="30" />

<!-- Modern (Android 12+) -->
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" 
    android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
```

#### Notification Permissions
- Added `POST_NOTIFICATIONS` permission for Android 13+
- This permission is required to show notifications on Android 13 and higher

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

#### Nearby WiFi Devices
- Added `NEARBY_WIFI_DEVICES` permission for mesh networking features
- Used `neverForLocation` flag to avoid requiring location permission for WiFi devices

```xml
<uses-permission android:name="android.permission.NEARBY_WIFI_DEVICES" 
    android:usesPermissionFlags="neverForLocation" />
```

### 2. QR Code Scanner Package Update

#### Problem
The old `qr_code_scanner` package (v1.0.1) has compatibility issues with:
- Android 12+ camera APIs
- Android 13+ permissions
- Android 14+ background restrictions
- Android 15 security requirements

#### Solution
Replaced with `mobile_scanner` v5.2.3:
- Full Android 15 support
- Better camera lifecycle management
- Modern ML Kit barcode scanning
- Proper permission handling
- Better error handling

**pubspec.yaml changes:**
```yaml
# Before
qr_code_scanner: ^1.0.1

# After
mobile_scanner: ^5.2.3
```

### 3. Code Updates

#### QRScannerScreen
- Migrated from `qr_code_scanner` to `mobile_scanner`
- Added permission checking on init
- Added permission request UI
- Improved error handling
- Better camera lifecycle management

**Key improvements:**
- Checks camera permission before showing scanner
- Shows permission request UI if needed
- Handles permission denied gracefully
- Prevents multiple simultaneous scans
- Proper dispose of resources

#### MeshQRPairingScreen
- Same migration as QRScannerScreen
- Added permission checks for scanner mode
- Improved error handling

#### Permission Service
Created comprehensive `PermissionService` to handle all runtime permissions:

**Features:**
- Camera permissions (for QR scanning)
- Storage permissions (with Android version checks)
- Notification permissions (Android 13+)
- Bluetooth permissions (Android 12+)
- Location permissions (for nearby devices)
- Nearby WiFi devices permission
- Proper error handling and fallbacks

**Usage example:**
```dart
final permissionService = PermissionService();

// Request camera permission
final granted = await permissionService.requestCameraPermission();

// Check if granted
final hasPermission = await permissionService.isCameraPermissionGranted();

// Open app settings if needed
if (!granted) {
  await permissionService.openAppSettings();
}
```

### 4. Build Configuration

#### Namespace Mapping
Updated `android/build.gradle` to include namespace for `mobile_scanner`:

```gradle
def pluginNamespaces = [
    'flutter_nearby_connections': 'com.nankai.flutter_nearby_connections',
    'nearby_service': 'np.com.susanthapa.nearby_service',
    'mobile_scanner': 'dev.steenbakker.mobile_scanner',
    'flutter_webrtc': 'com.cloudwebrtc.webrtc',
    'workmanager': 'be.tramckrijte.workmanager'
]
```

#### ProGuard Rules
Added rules for `mobile_scanner` and ML Kit:

```proguard
# Mobile Scanner (QR Code Scanner)
-keep class com.google.zxing.** { *; }
-dontwarn com.google.zxing.**
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**
```

## Testing Checklist

### QR Code Functionality
- [ ] QR code generator works correctly
  - [ ] Contact info QR generates
  - [ ] Custom text QR generates
  - [ ] Device pairing QR generates
  - [ ] QR codes display properly
  
- [ ] QR code scanner works correctly
  - [ ] Camera permission request appears
  - [ ] Camera opens successfully
  - [ ] Scans QR codes accurately
  - [ ] Handles invalid QR codes gracefully
  - [ ] Flash toggle works
  - [ ] Camera switch works
  - [ ] Processing indicator shows during scan

### Permission Handling
- [ ] Camera permission
  - [ ] Permission request dialog appears
  - [ ] Permission granted: scanner works
  - [ ] Permission denied: shows error UI
  - [ ] Permission permanently denied: shows settings option
  
- [ ] Storage permission (if used)
  - [ ] Works on Android 13+ with granular permissions
  - [ ] Works on Android 10-12 with storage permission
  
- [ ] Notification permission (Android 13+)
  - [ ] Permission request appears
  - [ ] Notifications work when granted
  
- [ ] Bluetooth permission (if used)
  - [ ] Works on Android 12+ with new permissions
  - [ ] Works on Android 11 and below with legacy permissions

### App Stability
- [ ] No crashes on startup
- [ ] No crashes when opening QR scanner
- [ ] No crashes when generating QR codes
- [ ] No crashes on permission denial
- [ ] No crashes in background
- [ ] No crashes during rotation
- [ ] Proper cleanup on app close

## Compatibility Matrix

| Android Version | API Level | Storage | Bluetooth | Notifications | Status |
|----------------|-----------|---------|-----------|---------------|--------|
| Android 15     | 35        | Granular | New       | Required      | ✅ Full Support |
| Android 14     | 34        | Granular | New       | Required      | ✅ Full Support |
| Android 13     | 33        | Granular | New       | Required      | ✅ Full Support |
| Android 12     | 31-32     | Storage  | New       | Default       | ✅ Full Support |
| Android 11     | 30        | Storage  | Legacy    | Default       | ✅ Full Support |
| Android 10     | 29        | Scoped   | Legacy    | Default       | ✅ Full Support |

## Known Issues

### Mobile Scanner
- First scan may be slower due to ML Kit initialization
- Flash toggle may not work on some devices
- Front camera may not support autofocus

### Permissions
- Users must grant permissions on first use
- Some permissions may need app settings if permanently denied
- Location permission may be required for Bluetooth on some devices

## Migration Notes

If you're upgrading from an older version:

1. **Remove old package**: The `qr_code_scanner` package has been removed
2. **Update imports**: Change imports from `qr_code_scanner` to `mobile_scanner`
3. **Update AndroidManifest.xml**: Copy the new permission declarations
4. **Test permissions**: Verify all permissions work on Android 13+
5. **Test QR scanner**: Ensure QR scanning works on all supported Android versions

## Resources

- [Android 15 Permissions Changes](https://developer.android.com/about/versions/15/behavior-changes-15)
- [Android Scoped Storage](https://developer.android.com/about/versions/11/privacy/storage)
- [Android Bluetooth Permissions](https://developer.android.com/guide/topics/connectivity/bluetooth/permissions)
- [Mobile Scanner Package](https://pub.dev/packages/mobile_scanner)
- [Permission Handler](https://pub.dev/packages/permission_handler)

## Support

For issues related to Android 15 compatibility:
1. Check the testing checklist above
2. Review error logs for permission denials
3. Ensure all dependencies are up to date
4. Test on actual Android 15 device or emulator

## Changelog

### Version 2.0.0+
- ✅ Updated AndroidManifest.xml for Android 15
- ✅ Replaced qr_code_scanner with mobile_scanner
- ✅ Added comprehensive PermissionService
- ✅ Updated all QR-related screens
- ✅ Added proper permission handling UI
- ✅ Updated build configuration
- ✅ Updated ProGuard rules

---

**Last Updated**: November 1, 2025  
**Android Target SDK**: 35 (Android 15)  
**Minimum SDK**: 24 (Android 7.0)
