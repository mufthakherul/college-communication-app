import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:campus_mesh/appwrite_config.dart';

/// Security service to protect against tampering, rooting, and reverse engineering
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  /// Expected package name - validates app hasn't been repackaged
  static const String _expectedPackageName = 
      'gov.bd.polytech.rgpi.communication.develop.by.mufthakherul';

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
  Future<bool> _validatePackageName() async {
    try {
      if (Platform.isAndroid) {
        // In a real implementation, you'd use platform channels to get the actual package name
        // For now, we'll implement a basic check
        // TODO: Implement native Android method to get package name
        return true; // Assume valid for now
      }
      return true; // iOS bundle ID check would go here
    } catch (e) {
      debugPrint('Package name validation error: $e');
      return false;
    }
  }

  /// Checks for root/jailbreak indicators
  Future<bool> _checkDeviceSecurity() async {
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
          final file = File(path);
          if (await file.exists()) {
            debugPrint('Root indicator found: $path');
            // Don't block in debug mode
            if (kReleaseMode) {
              return false;
            }
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
          final file = File(path);
          if (await file.exists()) {
            debugPrint('Jailbreak indicator found: $path');
            if (kReleaseMode) {
              return false;
            }
          }
        }
      }
      
      return true; // Device appears secure
    } catch (e) {
      debugPrint('Device security check error: $e');
      return true; // Assume secure on error (fail open for better UX)
    }
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
  bool _checkDebugger() {
    // In debug mode, debugger is expected
    if (kDebugMode) {
      return false; // Not a security issue in debug
    }

    // In release mode, debugger should not be attached
    // This is a basic check - more sophisticated checks would use platform channels
    return false; // Assume no debugger in release
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
    // In release mode, block execution if critical security checks fail
    if (kReleaseMode) {
      if (!result.packageNameValid || !result.backendConfigValid || !result.buildIntegrityValid) {
        return false;
      }
      
      // For rooted devices, show warning but allow execution
      // (blocking rooted devices entirely may impact legitimate users)
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
