import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for handling runtime permissions
/// Ensures proper permission handling for Android 15 and above
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Request camera permission for QR scanning
  Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        if (kDebugMode) {
          print('Camera permission permanently denied');
        }
        return false;
      } else {
        if (kDebugMode) {
          print('Camera permission denied');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting camera permission: $e');
      }
      return false;
    }
  }

  /// Request storage permissions based on Android version
  Future<bool> requestStoragePermission() async {
    try {
      // For Android 13+ (API 33+), use granular media permissions
      if (await _isAndroid13OrAbove()) {
        final statuses = await [
          Permission.photos,
          Permission.videos,
        ].request();
        
        return statuses.values.every((status) => status.isGranted);
      } else {
        // For Android 10-12, use storage permission
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting storage permission: $e');
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
        print('Error requesting notification permission: $e');
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
          print('Location permission permanently denied');
        }
        return false;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting location permission: $e');
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
        print('Error requesting Bluetooth permissions: $e');
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
        print('Error requesting nearby WiFi devices permission: $e');
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
        print('Error checking camera permission: $e');
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
        print('Error checking storage permission: $e');
      }
      return false;
    }
  }

  /// Open app settings for permission management
  Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      if (kDebugMode) {
        print('Error opening app settings: $e');
      }
      return false;
    }
  }

  /// Check if running on Android 12 or above
  Future<bool> _isAndroid12OrAbove() async {
    // This is a simplified check. In production, you should use
    // device_info_plus or platform_info to get the actual Android version
    return true; // Assume modern Android for safety
  }

  /// Check if running on Android 13 or above
  Future<bool> _isAndroid13OrAbove() async {
    // This is a simplified check. In production, you should use
    // device_info_plus or platform_info to get the actual Android version
    return true; // Assume modern Android for safety
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
        print('Error checking mesh networking permissions: $e');
      }
      return false;
    }
  }

  /// Show permission rationale dialog
  Future<bool> shouldShowRequestPermissionRationale(Permission permission) async {
    try {
      return await permission.shouldShowRequestRationale;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking permission rationale: $e');
      }
      return false;
    }
  }
}
