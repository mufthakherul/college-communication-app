import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

/// Secure storage service for sensitive data
/// Provides basic obfuscation for stored data
///
/// ⚠️ SECURITY NOTE: This implementation uses XOR encryption which provides
/// only basic obfuscation, NOT strong encryption. For production applications
/// handling highly sensitive data, use flutter_secure_storage package instead,
/// which uses:
/// - Android: KeyStore (hardware-backed encryption)
/// - iOS: Keychain (hardware-backed encryption)
///
/// Current implementation is suitable for:
/// - Non-critical data obfuscation
/// - Development/testing
/// - Low-security requirements
///
/// NOT suitable for:
/// - Payment information
/// - Personal identification numbers
/// - Highly sensitive credentials
///
/// To upgrade to flutter_secure_storage:
/// 1. Add dependency: flutter_secure_storage: ^9.0.0
/// 2. Replace this service with FlutterSecureStorage
/// 3. Use await secureStorage.write(key: key, value: value)
class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  // Simple obfuscation key - in production, derive this from device-specific data
  // This is a basic implementation; for production, use flutter_secure_storage
  static const String _obfuscationSeed = 'rpi_communication_secure_2024';

  /// Stores a secure value
  Future<bool> setSecureValue(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final obfuscatedKey = _obfuscateKey(key);
      final encryptedValue = _encryptValue(value);
      return await prefs.setString(obfuscatedKey, encryptedValue);
    } catch (e) {
      debugPrint('Secure storage write error: $e');
      return false;
    }
  }

  /// Retrieves a secure value
  Future<String?> getSecureValue(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final obfuscatedKey = _obfuscateKey(key);
      final encryptedValue = prefs.getString(obfuscatedKey);

      if (encryptedValue == null) return null;

      return _decryptValue(encryptedValue);
    } catch (e) {
      debugPrint('Secure storage read error: $e');
      return null;
    }
  }

  /// Removes a secure value
  Future<bool> removeSecureValue(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final obfuscatedKey = _obfuscateKey(key);
      return await prefs.remove(obfuscatedKey);
    } catch (e) {
      debugPrint('Secure storage remove error: $e');
      return false;
    }
  }

  /// Clears all secure storage
  Future<bool> clearSecureStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Only remove keys that were obfuscated by this service
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_getObfuscationPrefix())) {
          await prefs.remove(key);
        }
      }
      return true;
    } catch (e) {
      debugPrint('Secure storage clear error: $e');
      return false;
    }
  }

  /// Obfuscates the storage key to make it harder to identify sensitive data
  String _obfuscateKey(String key) {
    final bytes = utf8.encode(key + _obfuscationSeed);
    final hash = sha256.convert(bytes);
    return '${_getObfuscationPrefix()}_${hash.toString().substring(0, 16)}';
  }

  /// Gets the prefix used for obfuscated keys
  String _getObfuscationPrefix() {
    return 'sec';
  }

  /// Basic obfuscation using XOR with derived key
  ///
  /// ⚠️ WARNING: This is NOT cryptographically secure encryption!
  /// XOR encryption is easily reversible and provides only obfuscation.
  ///
  /// For production with sensitive data, use:
  /// - flutter_secure_storage package (hardware-backed encryption)
  /// - or implement AES-256-GCM with proper key derivation (PBKDF2/Argon2)
  ///
  /// Current implementation prevents casual inspection but not determined attacks.
  String _encryptValue(String value) {
    try {
      // Generate a derived key from the seed
      final keyBytes = _getDerivedKey();
      final valueBytes = utf8.encode(value);

      // XOR encryption (basic obfuscation)
      final encryptedBytes = List<int>.generate(
        valueBytes.length,
        (i) => valueBytes[i] ^ keyBytes[i % keyBytes.length],
      );

      // Base64 encode the result
      return base64Encode(encryptedBytes);
    } catch (e) {
      debugPrint('Encryption error: $e');
      return base64Encode(utf8.encode(value)); // Fallback to just encoding
    }
  }

  /// Basic decryption using XOR with derived key
  String _decryptValue(String encryptedValue) {
    try {
      // Generate the same derived key
      final keyBytes = _getDerivedKey();

      // Base64 decode
      final encryptedBytes = base64Decode(encryptedValue);

      // XOR decryption (reverse of encryption)
      final decryptedBytes = List<int>.generate(
        encryptedBytes.length,
        (i) => encryptedBytes[i] ^ keyBytes[i % keyBytes.length],
      );

      return utf8.decode(decryptedBytes);
    } catch (e) {
      debugPrint('Decryption error: $e');
      try {
        // Try fallback decoding
        return utf8.decode(base64Decode(encryptedValue));
      } catch (e2) {
        return '';
      }
    }
  }

  /// Derives a key from the seed for encryption
  Uint8List _getDerivedKey() {
    // Use SHA-256 to derive a key from the seed
    final hash = sha256.convert(utf8.encode(_obfuscationSeed));
    return Uint8List.fromList(hash.bytes);
  }

  /// Stores authentication token securely
  Future<bool> storeAuthToken(String token) async {
    return await setSecureValue('auth_token', token);
  }

  /// Retrieves authentication token
  Future<String?> getAuthToken() async {
    return await getSecureValue('auth_token');
  }

  /// Removes authentication token
  Future<bool> removeAuthToken() async {
    return await removeSecureValue('auth_token');
  }

  /// Stores user session data securely
  Future<bool> storeSessionData(Map<String, dynamic> sessionData) async {
    try {
      final jsonString = jsonEncode(sessionData);
      return await setSecureValue('session_data', jsonString);
    } catch (e) {
      debugPrint('Store session data error: $e');
      return false;
    }
  }

  /// Retrieves user session data
  Future<Map<String, dynamic>?> getSessionData() async {
    try {
      final jsonString = await getSecureValue('session_data');
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Get session data error: $e');
      return null;
    }
  }

  /// Removes user session data
  Future<bool> removeSessionData() async {
    return await removeSecureValue('session_data');
  }

  /// Generic write method for compatibility
  Future<void> write(String key, String value) async {
    await setSecureValue(key, value);
  }

  /// Generic read method for compatibility
  Future<String?> read(String key) async {
    return await getSecureValue(key);
  }

  /// Generic delete method for compatibility
  Future<void> delete(String key) async {
    await removeSecureValue(key);
  }
}
