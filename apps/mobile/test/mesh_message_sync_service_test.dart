import 'package:flutter_test/flutter_test.dart';
import 'package:campus_mesh/services/mesh_message_sync_service.dart';
import 'package:campus_mesh/services/mesh_network_service.dart';
import 'mocks/mock_permission_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final mesh = MeshNetworkService();
  final sync = MeshMessageSyncService();

  group('MeshNetworkService tests', () {
    test('Test helper adds node and count reflects', () async {
      mesh.addTestNode('peer1', 'Peer 1');
      expect(mesh.connectedNodeCount, greaterThanOrEqualTo(1));
    });

    test('Connection types are properly initialized', () async {
      // Mock permission service that grants all permissions
      final permissionService = MockPermissionService(allGranted: true);
      mesh.setPermissionService(permissionService);

      await mesh.initialize(deviceId: 'test1', deviceName: 'Test Device');

      expect(
        mesh.availableConnectionTypes,
        contains(MeshConnectionType.bluetooth),
      );
      expect(
        mesh.availableConnectionTypes,
        contains(MeshConnectionType.wifiDirect),
      );
      expect(
        mesh.availableConnectionTypes,
        contains(MeshConnectionType.ethernet),
      );
    });

    test('Connection types are limited when permissions denied', () async {
      // Mock permission service that denies all permissions
      final permissionService = MockPermissionService(allGranted: false);
      mesh.setPermissionService(permissionService);

      await mesh.initialize(deviceId: 'test2', deviceName: 'Test Device');

      // Only ethernet should be available (no permissions needed)
      expect(mesh.availableConnectionTypes.length, equals(1));
      expect(
        mesh.availableConnectionTypes,
        contains(MeshConnectionType.ethernet),
      );
    });
  });

  group('MeshMessageSyncService tests', () {
    test('Initialize/dispose mesh sync service', () async {
      await sync.initialize();
      await sync.dispose();
    });

    // TODO: Re-enable when syncMessages method is implemented
    // test('Message sync works across different connection types', () async {
    //   await sync.initialize();
    //
    //   // Test sync over different connection types
    //   for (final type in [
    //     MeshConnectionType.bluetooth,
    //     MeshConnectionType.wifiDirect,
    //     MeshConnectionType.ethernet
    //   ]) {
    //     final result = await sync.syncMessages(connectionType: type);
    //     expect(result.success, isTrue);
    //   }
    //
    //   await sync.dispose();
    // });
  });
}
