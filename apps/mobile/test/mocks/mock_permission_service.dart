import 'package:campus_mesh/services/permission_service.dart';

class MockPermissionService implements PermissionProvider {
  MockPermissionService({required this.allGranted});

  final bool allGranted;

  @override
  Future<bool> checkBluetoothPermissions() async => allGranted;

  @override
  Future<bool> checkLocationPermissions() async => allGranted;

  @override
  Future<bool> checkWifiPermissions() async => allGranted;

  @override
  Future<bool> checkStoragePermissions() async => allGranted;

  @override
  Future<bool> checkNfcPermissions() async => allGranted;

  @override
  Future<bool> checkCameraPermissions() async => allGranted;

  @override
  Future<bool> checkMicrophonePermissions() async => allGranted;
}
