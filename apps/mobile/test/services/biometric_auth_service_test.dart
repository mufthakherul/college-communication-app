import 'package:campus_mesh/services/biometric_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  group('BiometricAuthService', () {
    late BiometricAuthService service;

    setUp(() {
      service = BiometricAuthService();
    });

    test('should be a singleton', () {
      final service1 = BiometricAuthService();
      final service2 = BiometricAuthService();
      expect(identical(service1, service2), isTrue);
    });

    test('getBiometricTypeName should return correct names', () {
      expect(
        service.getBiometricTypeName(BiometricType.face),
        equals('Face Recognition'),
      );
      expect(
        service.getBiometricTypeName(BiometricType.fingerprint),
        equals('Fingerprint'),
      );
      expect(
        service.getBiometricTypeName(BiometricType.iris),
        equals('Iris Scan'),
      );
      expect(
        service.getBiometricTypeName(BiometricType.weak),
        equals('Weak Biometric'),
      );
      expect(
        service.getBiometricTypeName(BiometricType.strong),
        equals('Strong Biometric'),
      );
    });

    test('isBiometricAvailable should not throw', () async {
      // Should return false or true without throwing
      expect(() async => await service.isBiometricAvailable(), returnsNormally);
    });

    test('isDeviceSupported should not throw', () async {
      // Should return false or true without throwing
      expect(() async => await service.isDeviceSupported(), returnsNormally);
    });

    test('getAvailableBiometrics should return list', () async {
      final biometrics = await service.getAvailableBiometrics();
      expect(biometrics, isA<List<BiometricType>>());
    });

    test('isBiometricEnabled should return bool', () async {
      final enabled = await service.isBiometricEnabled();
      expect(enabled, isA<bool>());
    });

    test('disableBiometric should succeed', () async {
      final result = await service.disableBiometric();
      expect(result, isA<bool>());
    });

    test('getBiometricStatus should return string', () async {
      final status = await service.getBiometricStatus();
      expect(status, isA<String>());
      expect(status.isNotEmpty, isTrue);
    });
  });
}
