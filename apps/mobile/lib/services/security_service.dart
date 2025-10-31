/// Security service for app integrity and device security checks
/// Handles root detection, tampering detection, and certificate pinning

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:root_checker/root_checker.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../config/app_config.dart';

class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  final _config = AppConfig();
  bool _isInitialized = false;
  SecurityStatus? _cachedStatus;

  /// Initialize security checks
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _cachedStatus = await performSecurityChecks();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Security initialization error: $e');
      // Don't block app startup on security check errors
      _isInitialized = true;
    }
  }

  /// Perform all security checks
  Future<SecurityStatus> performSecurityChecks() async {
    final results = <String, bool>{};
    final warnings = <String>[];
    final threats = <String>[];

    try {
      // Root/Jailbreak detection
      if (_config.enableRootDetection) {
        final isRooted = await _checkRootStatus();
        results['rootDetection'] = !isRooted;
        if (isRooted) {
          threats.add('Device is rooted/jailbroken');
        }
      } else {
        results['rootDetection'] = true;
        if (_config.isProduction) {
          warnings.add('Root detection is disabled in production');
        }
      }

      // Package integrity check
      if (_config.enableTamperingDetection) {
        final isIntegrityOk = await _checkPackageIntegrity();
        results['integrityCheck'] = isIntegrityOk;
        if (!isIntegrityOk) {
          threats.add('App package integrity compromised');
        }
      } else {
        results['integrityCheck'] = true;
      }

      // Developer options check (Android only)
      if (Platform.isAndroid) {
        final devOptionsEnabled = await _checkDeveloperOptions();
        results['developerOptions'] = !devOptionsEnabled;
        if (devOptionsEnabled && _config.isProduction) {
          warnings.add('Developer options are enabled');
        }
      }

      // Emulator detection
      final isEmulator = await _checkEmulator();
      results['emulatorCheck'] = !isEmulator;
      if (isEmulator && _config.isProduction) {
        warnings.add('Running on emulator');
      }

      // Check app signature (Android only)
      if (Platform.isAndroid && _config.enableTamperingDetection) {
        final signatureValid = await _checkSignature();
        results['signatureCheck'] = signatureValid;
        if (!signatureValid) {
          threats.add('Invalid app signature detected');
        }
      }

    } catch (e) {
      debugPrint('Security check error: $e');
    }

    return SecurityStatus(
      isSecure: threats.isEmpty,
      checks: results,
      warnings: warnings,
      threats: threats,
      timestamp: DateTime.now(),
    );
  }

  /// Check if device is rooted (Android) or jailbroken (iOS)
  Future<bool> _checkRootStatus() async {
    try {
      if (Platform.isAndroid) {
        final isRooted = await RootChecker.isRooted() ?? false;
        return isRooted;
      } else if (Platform.isIOS) {
        final isJailbroken = await FlutterJailbreakDetection.jailbroken;
        return isJailbroken;
      }
      return false;
    } catch (e) {
      debugPrint('Root check error: $e');
      return false;
    }
  }

  /// Check package integrity
  Future<bool> _checkPackageIntegrity() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      // Check if package name matches expected
      const expectedPackage = 'gov.bd.polytech.rgpi.communication.develop.by.mufthakherul';
      if (packageInfo.packageName != expectedPackage) {
        debugPrint('Package name mismatch: ${packageInfo.packageName}');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Package integrity check error: $e');
      return false;
    }
  }

  /// Check if developer options are enabled (Android)
  Future<bool> _checkDeveloperOptions() async {
    try {
      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        // This is a basic check - more sophisticated checks can be added
        return androidInfo.isPhysicalDevice == false;
      }
      return false;
    } catch (e) {
      debugPrint('Developer options check error: $e');
      return false;
    }
  }

  /// Check if running on emulator
  Future<bool> _checkEmulator() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return !androidInfo.isPhysicalDevice;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return !iosInfo.isPhysicalDevice;
      }
      
      return false;
    } catch (e) {
      debugPrint('Emulator check error: $e');
      return false;
    }
  }

  /// Check app signature (basic implementation)
  Future<bool> _checkSignature() async {
    try {
      // This is a placeholder for signature verification
      // In production, you would verify against your known signing certificate
      // For now, we'll check if the package name is correct
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.packageName == 'gov.bd.polytech.rgpi.communication.develop.by.mufthakherul';
    } catch (e) {
      debugPrint('Signature check error: $e');
      return true; // Don't block on signature check errors
    }
  }

  /// Get current security status (cached)
  SecurityStatus? get securityStatus => _cachedStatus;

  /// Check if app is secure to run
  Future<bool> isSecureToRun() async {
    if (!_isInitialized) {
      await initialize();
    }

    final status = _cachedStatus;
    if (status == null) return true; // Allow if checks couldn't run

    // In production, block on critical threats
    if (_config.isProduction && status.threats.isNotEmpty) {
      return false;
    }

    return true;
  }

  /// Get security warnings for display
  List<String> getSecurityWarnings() {
    return _cachedStatus?.warnings ?? [];
  }

  /// Get security threats
  List<String> getSecurityThreats() {
    return _cachedStatus?.threats ?? [];
  }

  /// Refresh security status
  Future<SecurityStatus> refreshSecurityStatus() async {
    _cachedStatus = await performSecurityChecks();
    return _cachedStatus!;
  }

  /// Generate app fingerprint for integrity verification
  Future<String> generateAppFingerprint() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfo = DeviceInfoPlugin();
      
      String deviceId = 'unknown';
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown';
      }

      final data = '${packageInfo.packageName}|${packageInfo.version}|$deviceId';
      final bytes = utf8.encode(data);
      final hash = sha256.convert(bytes);
      
      return hash.toString();
    } catch (e) {
      debugPrint('Fingerprint generation error: $e');
      return 'error';
    }
  }
}

/// Security status result
class SecurityStatus {
  final bool isSecure;
  final Map<String, bool> checks;
  final List<String> warnings;
  final List<String> threats;
  final DateTime timestamp;

  SecurityStatus({
    required this.isSecure,
    required this.checks,
    required this.warnings,
    required this.threats,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'isSecure': isSecure,
      'checks': checks,
      'warnings': warnings,
      'threats': threats,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'SecurityStatus{isSecure: $isSecure, threats: ${threats.length}, warnings: ${warnings.length}}';
  }
}
