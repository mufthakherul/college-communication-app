import 'package:campus_mesh/services/enhanced_secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock the FlutterSecureStorage by using a fake implementation
  FlutterSecureStorage.setMockInitialValues({});

  group('EnhancedSecureStorageService', () {
    late EnhancedSecureStorageService service;

    setUp(() {
      // Reset the mock storage before each test
      FlutterSecureStorage.setMockInitialValues({});
      service = EnhancedSecureStorageService();
    });

    test('should be a singleton', () {
      final service1 = EnhancedSecureStorageService();
      final service2 = EnhancedSecureStorageService();
      expect(identical(service1, service2), isTrue);
    });

    test('write and read should work for simple values', () async {
      const testKey = 'test_key';
      const testValue = 'test_value';

      // Write
      final writeResult = await service.write(testKey, testValue);
      expect(writeResult, isTrue);

      // Read
      final readValue = await service.read(testKey);
      expect(readValue, equals(testValue));

      // Clean up
      await service.delete(testKey);
    });

    test('containsKey should return correct values', () async {
      const testKey = 'test_contains_key';
      const testValue = 'value';

      // Should not exist initially
      var contains = await service.containsKey(testKey);
      expect(contains, isFalse);

      // Write value
      await service.write(testKey, testValue);

      // Should exist now
      contains = await service.containsKey(testKey);
      expect(contains, isTrue);

      // Clean up
      await service.delete(testKey);
    });

    test('delete should remove value', () async {
      const testKey = 'test_delete';
      const testValue = 'value';

      // Write value
      await service.write(testKey, testValue);

      // Verify it exists
      var value = await service.read(testKey);
      expect(value, equals(testValue));

      // Delete
      final deleteResult = await service.delete(testKey);
      expect(deleteResult, isTrue);

      // Verify it's gone
      value = await service.read(testKey);
      expect(value, isNull);
    });

    test('setAuthToken and getAuthToken should work', () async {
      const testToken = 'test_auth_token_123';

      // Set token
      final setResult = await service.setAuthToken(testToken);
      expect(setResult, isTrue);

      // Get token
      final retrievedToken = await service.getAuthToken();
      expect(retrievedToken, equals(testToken));

      // Clean up
      await service.removeAuthToken();
    });

    test('setUserId and getUserId should work', () async {
      const testUserId = 'user_123';

      // Set user ID
      final setResult = await service.setUserId(testUserId);
      expect(setResult, isTrue);

      // Get user ID
      final retrievedUserId = await service.getUserId();
      expect(retrievedUserId, equals(testUserId));

      // Clean up
      await service.removeUserId();
    });

    test('setSessionData and getSessionData should work with JSON', () async {
      final testSession = {
        'userId': 'user_123',
        'email': 'test@example.com',
        'role': 'student',
      };

      // Set session data
      final setResult = await service.setSessionData(testSession);
      expect(setResult, isTrue);

      // Get session data
      final retrievedSession = await service.getSessionData();
      expect(retrievedSession, isNotNull);
      expect(retrievedSession!['userId'], equals('user_123'));
      expect(retrievedSession['email'], equals('test@example.com'));
      expect(retrievedSession['role'], equals('student'));

      // Clean up
      await service.removeSessionData();
    });

    test('clearAuthData should remove all auth-related data', () async {
      // Set multiple auth-related values
      await service.setAuthToken('token_123');
      await service.setUserId('user_123');
      await service.setSessionData({'key': 'value'});

      // Verify they exist
      expect(await service.getAuthToken(), isNotNull);
      expect(await service.getUserId(), isNotNull);
      expect(await service.getSessionData(), isNotNull);

      // Clear auth data
      final clearResult = await service.clearAuthData();
      expect(clearResult, isTrue);

      // Verify they're gone
      expect(await service.getAuthToken(), isNull);
      expect(await service.getUserId(), isNull);
      expect(await service.getSessionData(), isNull);
    });

    test('getStorageInfo should return correct status', () async {
      // Initially should have no data
      var info = await service.getStorageInfo();
      expect(info['hasAuthToken'], isFalse);
      expect(info['hasUserId'], isFalse);

      // Add some data
      await service.setAuthToken('token_123');
      await service.setUserId('user_123');

      // Check info again
      info = await service.getStorageInfo();
      expect(info['hasAuthToken'], isTrue);
      expect(info['hasUserId'], isTrue);

      // Clean up
      await service.clearAuthData();
    });

    test('migrateFromLegacyStorage should transfer data', () async {
      const oldToken = 'old_token';
      const oldUserId = 'old_user_id';
      final oldSessionData = {'key': 'value'};

      // Perform migration
      final migrateResult = await service.migrateFromLegacyStorage(
        oldToken: oldToken,
        oldUserId: oldUserId,
        oldSessionData: oldSessionData,
      );
      expect(migrateResult, isTrue);

      // Verify data was migrated
      expect(await service.getAuthToken(), equals(oldToken));
      expect(await service.getUserId(), equals(oldUserId));
      final sessionData = await service.getSessionData();
      expect(sessionData!['key'], equals('value'));

      // Clean up
      await service.clearAuthData();
    });

    test('setGeminiApiKey and getGeminiApiKey should work', () async {
      const testApiKey = 'gemini_api_key_123';

      // Set API key
      final setResult = await service.setGeminiApiKey(testApiKey);
      expect(setResult, isTrue);

      // Get API key
      final retrievedKey = await service.getGeminiApiKey();
      expect(retrievedKey, equals(testApiKey));

      // Clean up
      await service.removeGeminiApiKey();
    });

    test('setBiometricSettings and getBiometricSettings should work', () async {
      final settings = {'enabled': true, 'type': 'fingerprint'};

      // Set settings
      final setResult = await service.setBiometricSettings(settings);
      expect(setResult, isTrue);

      // Get settings
      final retrievedSettings = await service.getBiometricSettings();
      expect(retrievedSettings, isNotNull);
      expect(retrievedSettings!['enabled'], isTrue);
      expect(retrievedSettings['type'], equals('fingerprint'));

      // Clean up
      await service.removeBiometricSettings();
    });
  });
}
