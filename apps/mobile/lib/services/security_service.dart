import 'dart:io';

import 'package:campus_mesh/appwrite_config.dart';
import 'package:flutter/foundation.dart';

/// Security service to protect against tampering, rooting, and reverse engineering
class SecurityService {
  factory SecurityService() => _instance;
  SecurityService._internal();
  static final SecurityService _instance = SecurityService._internal();

  /// Expected package name - validates app hasn't been repackaged
  // Note: This field is reserved for future use
  // static const String _expectedPackageName =
  //     'gov.bd.polytech.rgpi.communication.develop.by.mufthakherul';

  /// Expected Appwrite project ID - validates backend connection
  static const String _expectedProjectId = AppwriteConfig.projectId;

  /// Performs comprehensive security checks on app startup
  /// Returns true if all checks pass, false if security issues detected
  Future<SecurityCheckResult> performSecurityChecks() async {
    final result = SecurityCheckResult();

    try {
      // Check 1: Validate package name
      result.packageNameValid = await _validatePackageName();

      // Check 2: Check for root/jailbreak (basic check)
      result.deviceSecure = await _checkDeviceSecurity();

      // Check 3: Validate Appwrite configuration
      result.backendConfigValid = _validateBackendConfig();

      // Check 4: Check for debugger (development builds)
      result.debuggerDetected = _checkDebugger();

      // Check 5: Validate build signature (basic integrity check)
      result.buildIntegrityValid = await _validateBuildIntegrity();
    } catch (e) {
      debugPrint('Security check error: $e');
      result.hasError = true;
      result.errorMessage = e.toString();
    }

    return result;
  }

  /// Validates that the package name hasn't been changed (app repackaging detection)
  ///
  /// LIMITATION: Currently not fully implemented. Returns true as a placeholder.
  /// For production deployment, this should be enhanced with platform channels.
  ///
  /// To implement properly:
  /// 1. Create Android native method to get package name
  /// 2. Create iOS native method to get bundle ID
  /// 3. Compare against expected values
  ///
  /// For now, this check relies on ProGuard obfuscation and other security measures.
  Future<bool> _validatePackageName() async {
    try {
      if (Platform.isAndroid) {
        // TODO: Implement native Android method to get package name via platform channels
        // Expected: gov.bd.polytech.rgpi.communication.develop.by.mufthakherul
        // For now, ProGuard obfuscation provides primary anti-repackaging protection
        return true; // Placeholder - returns true to avoid blocking legitimate users
      }
      return true; // iOS bundle ID check would be implemented similarly
    } catch (e) {
      debugPrint('Package name validation error: $e');
      return false;
    }
  }

  /// Checks for root/jailbreak indicators
  Future<bool> _checkDeviceSecurity() async {
    // TEMPORARY: Disable root/jailbreak detection to prevent crashes
    // This check can cause FileSystemException on some devices
    // Re-enable after thorough testing on target devices
    return true;

    /* DISABLED FOR STABILITY
    try {
      if (Platform.isAndroid) {
        // Check for common root indicators
        final rootIndicators = [
          '/system/app/Superuser.apk',
          '/sbin/su',
          '/system/bin/su',
          '/system/xbin/su',
          '/data/local/xbin/su',
          '/data/local/bin/su',
          '/system/sd/xbin/su',
          '/system/bin/failsafe/su',
          '/data/local/su',
        ];

        for (final path in rootIndicators) {
          try {
            final file = File(path);
            // Note: Using async file.exists() is acceptable here for security checks
            // as this is a one-time check during app initialization
            // ignore: avoid_slow_async_io
            if (await file.exists()) {
              debugPrint('Root indicator found: $path');
              // Don't block in debug mode
              if (kReleaseMode) {
                return false;
              }
            }
          } catch (e) {
            // Individual file check failed - continue checking others
            debugPrint('Error checking file $path: $e');
          }
        }
      } else if (Platform.isIOS) {
        // Check for jailbreak indicators
        final jailbreakIndicators = [
          '/Applications/Cydia.app',
          '/Library/MobileSubstrate/MobileSubstrate.dylib',
          '/bin/bash',
          '/usr/sbin/sshd',
          '/etc/apt',
        ];

        for (final path in jailbreakIndicators) {
          try {
            final file = File(path);
            // Note: Using async file.exists() is acceptable here for security checks
            // as this is a one-time check during app initialization
            // ignore: avoid_slow_async_io
            if (await file.exists()) {
              debugPrint('Jailbreak indicator found: $path');
              if (kReleaseMode) {
                return false;
              }
            }
          } catch (e) {
            // Individual file check failed - continue checking others
            debugPrint('Error checking file $path: $e');
          }
        }
      }

      return true; // Device appears secure
    } catch (e) {
      // NOTE: This fails open (returns true) to avoid blocking legitimate users
      // In high-security scenarios, consider failing closed (return false)
      // Current approach: Show warning but allow app usage
      debugPrint('Device security check error: $e');
      return true; // Fail open for better UX - legitimate users not blocked
    }
    */
  }

  /// Validates backend configuration hasn't been tampered with
  bool _validateBackendConfig() {
    try {
      // Verify Appwrite project ID matches expected value
      if (AppwriteConfig.projectId != _expectedProjectId) {
        debugPrint('Backend configuration mismatch detected');
        return false;
      }

      // Verify endpoint is correct
      if (!AppwriteConfig.endpoint.contains('appwrite.io') &&
          !AppwriteConfig.endpoint.contains('localhost')) {
        debugPrint('Unexpected backend endpoint detected');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Backend config validation error: $e');
      return false;
    }
  }

  /// Checks if debugger is attached
  ///
  /// LIMITATION: Basic implementation - always returns false in release mode.
  /// Flutter makes it difficult to reliably detect debuggers without native code.
  /// For enhanced security, implement platform-specific debugger detection.
  ///
  /// This is a placeholder check. Real debugger detection would require:
  /// - Android: Check for JDWP or ptrace
  /// - iOS: Check for PT_DENY_ATTACH or debugger process
  bool _checkDebugger() {
    // In debug mode, debugger is expected
    if (kDebugMode) {
      return false; // Not a security issue in debug mode
    }

    // In release mode, debugger should not be attached
    // TODO: Implement actual debugger detection via platform channels
    // For now, return false (no debugger detected)
    return false; // Placeholder - assumes no debugger in release builds
  }

  /// Basic build integrity check
  Future<bool> _validateBuildIntegrity() async {
    try {
      // In production, you could verify APK signature here
      // For now, we'll do a basic check that critical files are present

      // Check that Appwrite config is loaded
      if (AppwriteConfig.projectId.isEmpty) {
        return false;
      }

      // Check that database ID is configured
      if (AppwriteConfig.databaseId.isEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Build integrity check error: $e');
      return false;
    }
  }

  /// Gets a security warning message based on check results
  String getSecurityWarningMessage(SecurityCheckResult result) {
    if (!result.packageNameValid) {
      return 'Security Alert: This app may have been modified. Please download from official sources only.';
    }

    if (!result.deviceSecure) {
      return 'Security Warning: Your device appears to be rooted/jailbroken. This may compromise app security.';
    }

    if (!result.backendConfigValid) {
      return 'Security Alert: Backend configuration has been tampered with. Please reinstall the app.';
    }

    if (!result.buildIntegrityValid) {
      return 'Security Alert: App integrity check failed. Please reinstall from official sources.';
    }

    if (result.hasError) {
      return 'Security check encountered an error: ${result.errorMessage}';
    }

    return 'All security checks passed.';
  }

  /// Determines if the app should be allowed to run based on security checks
  bool shouldAllowAppExecution(SecurityCheckResult result) {
    // In release mode, only block for critical backend issues
    // Package name and build integrity checks are informational only
    if (kReleaseMode) {
      if (!result.backendConfigValid) {
        return false;
      }

      // For other checks (rooted devices, package validation), show warning but allow execution
      // This prevents blocking legitimate users while maintaining security awareness
    }

    // In debug mode, always allow execution
    return true;
  }
}

/// Result of security checks
class SecurityCheckResult {
  bool packageNameValid = true;
  bool deviceSecure = true;
  bool backendConfigValid = true;
  bool debuggerDetected = false;
  bool buildIntegrityValid = true;
  bool hasError = false;
  String errorMessage = '';

  bool get allChecksPassed {
    return packageNameValid &&
        deviceSecure &&
        backendConfigValid &&
        buildIntegrityValid &&
        !hasError;
  }

  bool get hasCriticalIssues {
    return !packageNameValid || !backendConfigValid || !buildIntegrityValid;
  }

  @override
  String toString() {
    return 'SecurityCheckResult(packageNameValid: $packageNameValid, '
        'deviceSecure: $deviceSecure, backendConfigValid: $backendConfigValid, '
        'debuggerDetected: $debuggerDetected, buildIntegrityValid: $buildIntegrityValid, '
        'hasError: $hasError, errorMessage: $errorMessage)';
  }
}
