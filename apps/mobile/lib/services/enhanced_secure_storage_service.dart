import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Enhanced secure storage service using hardware-backed encryption
///
/// Uses platform-specific secure storage:
/// - Android: Uses KeyStore (hardware-backed encryption)
/// - iOS: Uses Keychain (hardware-backed encryption)
/// - Linux: Uses libsecret
/// - Windows: Uses Windows Credentials Store
/// - macOS: Uses macOS Keychain
///
/// This provides cryptographically secure storage suitable for:
/// - Authentication tokens
/// - API keys
/// - User credentials
/// - Personal information
/// - Payment information
class EnhancedSecureStorageService {
  factory EnhancedSecureStorageService() => _instance;
  EnhancedSecureStorageService._internal();
  static final EnhancedSecureStorageService _instance =
      EnhancedSecureStorageService._internal();

  // Configure secure storage with appropriate options
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      // Use biometric authentication for access (optional)
      // Requires user authentication for each access
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    lOptions: LinuxOptions(),
    wOptions: WindowsOptions(),
    mOptions: MacOsOptions(),
  );

  // Storage keys
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _sessionDataKey = 'session_data';
  static const String _apiKeyKey = 'api_key';
  static const String _geminiApiKeyKey = 'gemini_api_key';
  static const String _lastLoginKey = 'last_login';
  static const String _biometricSettingsKey = 'biometric_settings';

  /// Write a value to secure storage
  Future<bool> write(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      debugPrint('Secure storage: Wrote key $key');
      return true;
    } catch (e) {
      debugPrint('Secure storage write error for key $key: $e');
      return false;
    }
  }

  /// Read a value from secure storage
  Future<String?> read(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      debugPrint(
        'Secure storage: Read key $key ${value != null ? '(found)' : '(not found)'}',
      );
      return value;
    } catch (e) {
      debugPrint('Secure storage read error for key $key: $e');
      return null;
    }
  }

  /// Delete a value from secure storage
  Future<bool> delete(String key) async {
    try {
      await _secureStorage.delete(key: key);
      debugPrint('Secure storage: Deleted key $key');
      return true;
    } catch (e) {
      debugPrint('Secure storage delete error for key $key: $e');
      return false;
    }
  }

  /// Check if a key exists in secure storage
  Future<bool> containsKey(String key) async {
    try {
      return await _secureStorage.containsKey(key: key);
    } catch (e) {
      debugPrint('Secure storage containsKey error for key $key: $e');
      return false;
    }
  }

  /// Read all keys and values from secure storage
  Future<Map<String, String>> readAll() async {
    try {
      return await _secureStorage.readAll();
    } catch (e) {
      debugPrint('Secure storage readAll error: $e');
      return {};
    }
  }

  /// Delete all values from secure storage
  Future<bool> deleteAll() async {
    try {
      await _secureStorage.deleteAll();
      debugPrint('Secure storage: Deleted all keys');
      return true;
    } catch (e) {
      debugPrint('Secure storage deleteAll error: $e');
      return false;
    }
  }

  // ========== Authentication Methods ==========

  /// Store authentication token
  Future<bool> setAuthToken(String token) async {
    return write(_authTokenKey, token);
  }

  /// Get authentication token
  Future<String?> getAuthToken() async {
    return read(_authTokenKey);
  }

  /// Remove authentication token
  Future<bool> removeAuthToken() async {
    return delete(_authTokenKey);
  }

  // ========== User ID Methods ==========

  /// Store user ID
  Future<bool> setUserId(String userId) async {
    return write(_userIdKey, userId);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return read(_userIdKey);
  }

  /// Remove user ID
  Future<bool> removeUserId() async {
    return delete(_userIdKey);
  }

  // ========== Session Methods ==========

  /// Store session data as JSON
  Future<bool> setSessionData(Map<String, dynamic> sessionData) async {
    try {
      final jsonString = jsonEncode(sessionData);
      return await write(_sessionDataKey, jsonString);
    } catch (e) {
      debugPrint('Error encoding session data: $e');
      return false;
    }
  }

  /// Get session data from JSON
  Future<Map<String, dynamic>?> getSessionData() async {
    try {
      final jsonString = await read(_sessionDataKey);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error decoding session data: $e');
      return null;
    }
  }

  /// Remove session data
  Future<bool> removeSessionData() async {
    return delete(_sessionDataKey);
  }

  // ========== API Key Methods ==========

  /// Store API key
  Future<bool> setApiKey(String apiKey) async {
    return write(_apiKeyKey, apiKey);
  }

  /// Get API key
  Future<String?> getApiKey() async {
    return read(_apiKeyKey);
  }

  /// Remove API key
  Future<bool> removeApiKey() async {
    return delete(_apiKeyKey);
  }

  /// Store Gemini API key
  Future<bool> setGeminiApiKey(String apiKey) async {
    return write(_geminiApiKeyKey, apiKey);
  }

  /// Get Gemini API key
  Future<String?> getGeminiApiKey() async {
    return read(_geminiApiKeyKey);
  }

  /// Remove Gemini API key
  Future<bool> removeGeminiApiKey() async {
    return delete(_geminiApiKeyKey);
  }

  // ========== Login Tracking Methods ==========

  /// Store last login timestamp
  Future<bool> setLastLogin(DateTime timestamp) async {
    return write(_lastLoginKey, timestamp.toIso8601String());
  }

  /// Get last login timestamp
  Future<DateTime?> getLastLogin() async {
    try {
      final timestampString = await read(_lastLoginKey);
      if (timestampString == null) return null;
      return DateTime.parse(timestampString);
    } catch (e) {
      debugPrint('Error parsing last login timestamp: $e');
      return null;
    }
  }

  /// Remove last login timestamp
  Future<bool> removeLastLogin() async {
    return delete(_lastLoginKey);
  }

  // ========== Biometric Settings Methods ==========

  /// Store biometric settings
  Future<bool> setBiometricSettings(Map<String, dynamic> settings) async {
    try {
      final jsonString = jsonEncode(settings);
      return await write(_biometricSettingsKey, jsonString);
    } catch (e) {
      debugPrint('Error encoding biometric settings: $e');
      return false;
    }
  }

  /// Get biometric settings
  Future<Map<String, dynamic>?> getBiometricSettings() async {
    try {
      final jsonString = await read(_biometricSettingsKey);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error decoding biometric settings: $e');
      return null;
    }
  }

  /// Remove biometric settings
  Future<bool> removeBiometricSettings() async {
    return delete(_biometricSettingsKey);
  }

  // ========== Utility Methods ==========

  /// Clear all authentication-related data
  Future<bool> clearAuthData() async {
    try {
      await removeAuthToken();
      await removeUserId();
      await removeSessionData();
      await removeLastLogin();
      debugPrint('Secure storage: Cleared all auth data');
      return true;
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
      return false;
    }
  }

  /// Migrate data from old secure storage service
  Future<bool> migrateFromLegacyStorage({
    String? oldToken,
    String? oldUserId,
    Map<String, dynamic>? oldSessionData,
  }) async {
    try {
      var success = true;

      if (oldToken != null) {
        success = success && await setAuthToken(oldToken);
      }

      if (oldUserId != null) {
        success = success && await setUserId(oldUserId);
      }

      if (oldSessionData != null) {
        success = success && await setSessionData(oldSessionData);
      }

      debugPrint(
        'Secure storage: Migration ${success ? 'successful' : 'failed'}',
      );
      return success;
    } catch (e) {
      debugPrint('Error during migration: $e');
      return false;
    }
  }

  /// Get storage info for debugging (doesn't reveal actual values)
  Future<Map<String, bool>> getStorageInfo() async {
    return {
      'hasAuthToken': await containsKey(_authTokenKey),
      'hasUserId': await containsKey(_userIdKey),
      'hasSessionData': await containsKey(_sessionDataKey),
      'hasApiKey': await containsKey(_apiKeyKey),
      'hasGeminiApiKey': await containsKey(_geminiApiKeyKey),
      'hasLastLogin': await containsKey(_lastLoginKey),
      'hasBiometricSettings': await containsKey(_biometricSettingsKey),
    };
  }
}
