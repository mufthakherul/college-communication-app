import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling biometric authentication
/// Supports fingerprint, face recognition, and iris scanning
class BiometricAuthService {
  factory BiometricAuthService() => _instance;
  BiometricAuthService._internal();
  static final BiometricAuthService _instance =
      BiometricAuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometric_enabled';

  /// Check if biometric authentication is available on this device
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Check if device has biometric hardware
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      debugPrint('Error checking device support: $e');
      return false;
    }
  }

  /// Get list of available biometric types
  /// Returns BiometricType enum values: face, fingerprint, iris, weak, strong
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate using biometrics
  /// Returns true if authentication successful
  Future<bool> authenticate({
    String localizedReason = 'Please authenticate to access the app',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
    bool biometricOnly = false,
  }) async {
    try {
      // Check if biometric is available
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        debugPrint('Biometric authentication not available');
        return false;
      }

      // Perform authentication
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: biometricOnly,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('Biometric authentication error: ${e.code} - ${e.message}');

      // Handle specific error codes
      if (e.code == auth_error.notAvailable) {
        debugPrint('Biometric authentication not available');
      } else if (e.code == auth_error.notEnrolled) {
        debugPrint('No biometrics enrolled on this device');
      } else if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        debugPrint('Biometric authentication locked out');
      }

      return false;
    } catch (e) {
      debugPrint('Unexpected error during biometric authentication: $e');
      return false;
    }
  }

  /// Stop authentication if in progress
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      debugPrint('Error stopping authentication: $e');
    }
  }

  /// Check if biometric authentication is enabled in app settings
  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? false;
    } catch (e) {
      debugPrint('Error checking biometric enabled status: $e');
      return false;
    }
  }

  /// Enable biometric authentication in app settings
  Future<bool> enableBiometric() async {
    try {
      // First verify that biometric works
      final canAuth = await authenticate(
        localizedReason: 'Enable biometric authentication for quick login',
      );

      if (!canAuth) {
        return false;
      }

      // Save setting
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_biometricEnabledKey, true);
    } catch (e) {
      debugPrint('Error enabling biometric: $e');
      return false;
    }
  }

  /// Disable biometric authentication in app settings
  Future<bool> disableBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_biometricEnabledKey, false);
    } catch (e) {
      debugPrint('Error disabling biometric: $e');
      return false;
    }
  }

  /// Get user-friendly name for available biometric types
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face Recognition';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris Scan';
      case BiometricType.weak:
        return 'Weak Biometric';
      case BiometricType.strong:
        return 'Strong Biometric';
    }
  }

  /// Get status message for biometric availability
  Future<String> getBiometricStatus() async {
    final isSupported = await isDeviceSupported();
    if (!isSupported) {
      return 'This device does not support biometric authentication';
    }

    final isAvailable = await isBiometricAvailable();
    if (!isAvailable) {
      return 'Biometric authentication is not set up on this device';
    }

    final biometrics = await getAvailableBiometrics();
    if (biometrics.isEmpty) {
      return 'No biometric methods are enrolled on this device';
    }

    final types = biometrics.map(getBiometricTypeName).join(', ');
    return 'Available: $types';
  }
}
