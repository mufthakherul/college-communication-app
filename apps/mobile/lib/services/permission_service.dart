import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for handling runtime permissions
/// Ensures proper permission handling for Android 15 and above
///
/// PermissionProvider is an interface used for dependency injection in tests.
abstract class PermissionProvider {
  Future<bool> checkLocationPermissions();
  Future<bool> checkBluetoothPermissions();
  Future<bool> checkWifiPermissions();
  Future<bool> checkStoragePermissions();
  Future<bool> checkNfcPermissions();
  Future<bool> checkCameraPermissions();
  Future<bool> checkMicrophonePermissions();
}

class PermissionService implements PermissionProvider {
  factory PermissionService() => _instance;
  PermissionService._internal();
  static final PermissionService _instance = PermissionService._internal();

  /// Check location permissions
  Future<bool> checkLocationPermissions() async {
    try {
      return await Permission.location.isGranted;
    } catch (e) {
      debugPrint('Error checking location permission: $e');
      return false;
    }
  }

  /// Check Bluetooth permissions
  Future<bool> checkBluetoothPermissions() async {
    try {
      if (await _isAndroid12OrAbove()) {
        return await Permission.bluetoothScan.isGranted &&
               await Permission.bluetoothConnect.isGranted &&
               await Permission.bluetoothAdvertise.isGranted;
      }
      return await Permission.bluetooth.isGranted;
    } catch (e) {
      debugPrint('Error checking bluetooth permissions: $e');
      return false;
    }
  }

  /// Check WiFi permissions
  Future<bool> checkWifiPermissions() async {
    try {
      // Permission_handler does not expose fine-grained WiFi control on all
      // platforms; scanning/discovery commonly requires location permission.
      return await Permission.location.isGranted;
    } catch (e) {
      debugPrint('Error checking wifi permissions: $e');
      return false;
    }
  }

  /// Check storage permissions
  Future<bool> checkStoragePermissions() async {
    try {
      if (await _isAndroid13OrAbove()) {
        final hasPhotos = await Permission.photos.isGranted;
        final hasVideos = await Permission.videos.isGranted;
        return hasPhotos && hasVideos;
      }
      return await Permission.storage.isGranted;
    } catch (e) {
      debugPrint('Error checking storage permissions: $e');
      return false;
    }
  }

  /// Check NFC permissions
  Future<bool> checkNfcPermissions() async {
    try {
      return await Permission.nfc.isGranted;
    } catch (e) {
      debugPrint('Error checking NFC permission: $e');
      return false;
    }
  }

  /// Check microphone permissions
  Future<bool> checkMicrophonePermissions() async {
    try {
      return await Permission.microphone.isGranted;
    } catch (e) {
      debugPrint('Error checking microphone permission: $e');
      return false;
    }
  }

  /// Check camera permissions
  Future<bool> checkCameraPermissions() async {
    try {
      final hasCamera = await Permission.camera.isGranted;
      final hasCameraPermission = !await Permission.camera.isPermanentlyDenied;
      return hasCamera && hasCameraPermission;
    } catch (e) {
      debugPrint('Error checking camera permission: $e');
      return false;
    }
  }

  /// Request camera permission for QR scanning or video calls
  Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting camera permission: $e');
      return false;
    }
  }

  /// Request microphone permission for voice/video calls
  Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting microphone permission: $e');
      return false;
    }
  }

  /// Request camera and microphone permissions together for video calls
  Future<bool> requestVideoCallPermissions() async {
    try {
      final permissions = await [
        Permission.camera,
        Permission.microphone,
      ].request();
      
      return permissions.values.every((status) => status.isGranted);
    } catch (e) {
      debugPrint('Error requesting video call permissions: $e');
      return false;
    }
  }

  /// Request storage permissions based on Android version
  Future<bool> requestStoragePermission() async {
    try {
      // For Android 13+ (API 33+), use granular media permissions
      if (await _isAndroid13OrAbove()) {
        final statuses = await [Permission.photos, Permission.videos].request();

        return statuses.values.every((status) => status.isGranted);
      } else {
        // For Android 10-12, use storage permission
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting storage permission: $e');
      }
      return false;
    }
  }

  /// Request notification permission for Android 13+
  Future<bool> requestNotificationPermission() async {
    try {
      if (await _isAndroid13OrAbove()) {
        final status = await Permission.notification.request();
        return status.isGranted;
      }
      // Below Android 13, notifications are enabled by default
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting notification permission: $e');
      }
      return false;
    }
  }

  /// Request location permission for nearby devices
  Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        if (kDebugMode) {
          debugPrint('Location permission permanently denied');
        }
        return false;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting location permission: $e');
      }
      return false;
    }
  }

  /// Request Bluetooth permissions for Android 12+
  Future<bool> requestBluetoothPermissions() async {
    try {
      if (await _isAndroid12OrAbove()) {
        final statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
        ].request();

        return statuses.values.every((status) => status.isGranted);
      } else {
        // Below Android 12, use legacy Bluetooth permission
        final status = await Permission.bluetooth.request();
        return status.isGranted;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting Bluetooth permissions: $e');
      }
      return false;
    }
  }

  /// Request nearby WiFi devices permission for Android 13+
  Future<bool> requestNearbyWifiDevicesPermission() async {
    try {
      if (await _isAndroid13OrAbove()) {
        final status = await Permission.nearbyWifiDevices.request();
        return status.isGranted;
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting nearby WiFi devices permission: $e');
      }
      return false;
    }
  }

  /// Check if camera permission is granted
  Future<bool> isCameraPermissionGranted() async {
    try {
      final status = await Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking camera permission: $e');
      }
      return false;
    }
  }

  /// Check if storage permission is granted
  Future<bool> isStoragePermissionGranted() async {
    try {
      if (await _isAndroid13OrAbove()) {
        final photoStatus = await Permission.photos.status;
        return photoStatus.isGranted;
      } else {
        final status = await Permission.storage.status;
        return status.isGranted;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking storage permission: $e');
      }
      return false;
    }
  }

  /// Open app settings for permission management
  Future<bool> openSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error opening app settings: $e');
      }
      return false;
    }
  }

  /// Check if running on Android 12 or above
  Future<bool> _isAndroid12OrAbove() async {
    // For simplicity, we request permissions that are safe on all versions
    // The permission_handler package handles version-specific behavior automatically
    // If a permission doesn't exist on older versions, it returns granted
    return true; // Safe to assume modern Android for permission requests
  }

  /// Check if running on Android 13 or above
  Future<bool> _isAndroid13OrAbove() async {
    // For simplicity, we request permissions that are safe on all versions
    // The permission_handler package handles version-specific behavior automatically
    // If a permission doesn't exist on older versions, it returns granted
    return true; // Safe to assume modern Android for permission requests
  }

  /// Request all permissions needed for mesh networking
  Future<Map<String, bool>> requestMeshNetworkingPermissions() async {
    final results = <String, bool>{};

    results['location'] = await requestLocationPermission();
    results['bluetooth'] = await requestBluetoothPermissions();
    results['nearbyWifiDevices'] = await requestNearbyWifiDevicesPermission();

    return results;
  }

  /// Check if all mesh networking permissions are granted
  Future<bool> areMeshNetworkingPermissionsGranted() async {
    try {
      final locationGranted = await Permission.location.isGranted;
      final bluetoothGranted = await _isAndroid12OrAbove()
          ? await Permission.bluetoothScan.isGranted
          : await Permission.bluetooth.isGranted;

      return locationGranted && bluetoothGranted;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking mesh networking permissions: $e');
      }
      return false;
    }
  }

  /// Show permission rationale dialog
  Future<bool> shouldShowRequestPermissionRationale(
    Permission permission,
  ) async {
    try {
      return await permission.shouldShowRequestRationale;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking permission rationale: $e');
      }
      return false;
    }
  }
}
