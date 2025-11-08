import 'package:flutter_test/flutter_test.dart';
import 'package:campus_mesh/services/mesh_message_sync_service.dart';
import 'package:campus_mesh/services/mesh_network_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final mesh = MeshNetworkService();
  final sync = MeshMessageSyncService();

  test('Test helper adds node and count reflects', () async {
    mesh.addTestNode('peer1', 'Peer 1');
    expect(mesh.connectedNodeCount, greaterThanOrEqualTo(1));
  });

  test('Initialize/dispose mesh sync service', () async {
    await sync.initialize();
    await sync.dispose();
  });
}
