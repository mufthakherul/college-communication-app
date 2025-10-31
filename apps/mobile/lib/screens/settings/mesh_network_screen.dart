import 'package:flutter/material.dart';
import 'package:campus_mesh/services/mesh_network_service.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/screens/settings/mesh_qr_pairing_screen.dart';

/// Screen for mesh network settings and controls
class MeshNetworkScreen extends StatefulWidget {
  const MeshNetworkScreen({super.key});

  @override
  State<MeshNetworkScreen> createState() => _MeshNetworkScreenState();
}

class _MeshNetworkScreenState extends State<MeshNetworkScreen> {
  final _meshService = MeshNetworkService();
  bool _isInitialized = false;
  bool _isEnabled = false;
  List<MeshNode> _connectedNodes = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _initializeMesh();
  }

  Future<void> _initializeMesh() async {
    try {
      final authService = AuthService();
      final user = await authService.currentUser;
      if (user != null) {
        await _meshService.initialize(
          deviceId: user.id,
          deviceName: user.displayName ?? user.email ?? 'Unknown',
        );

        setState(() {
          _isInitialized = true;
        });

        // Listen for node updates
        _meshService.nodesStream.listen((nodes) {
          if (mounted) {
            setState(() {
              _connectedNodes = nodes;
            });
          }
        });

        _updateStats();
      }
    } catch (e) {
      _showMessage('Failed to initialize mesh network: $e');
    }
  }

  void _updateStats() {
    setState(() {
      _stats = _meshService.getStatistics();
      _isEnabled = (_stats['isActive'] as bool?) ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mesh Network')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesh Network'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _updateStats),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildQRPairingCard(),
          const SizedBox(height: 16),
          _buildControlCard(),
          const SizedBox(height: 16),
          _buildStatisticsCard(),
          const SizedBox(height: 16),
          _buildConnectedNodesCard(),
        ],
      ),
    );
  }

  Widget _buildQRPairingCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.qr_code_2, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'QR Code Pairing',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Securely pair with nearby devices using QR codes. Only devices with the scanned QR code will be visible in your connection list.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openQRPairing,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Pair Device'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.hub,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Mesh Network',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Connect with nearby devices using Bluetooth and WiFi Direct. '
              'Share messages and notices even without internet connection.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Emergency mode: Works without SIM or internet',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Control',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(child: Text('Enable Mesh Network')),
                Switch(value: _isEnabled, onChanged: _toggleMeshNetwork),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(child: Text('Auto-Connect to Devices')),
                Switch(
                  value: _meshService.isActive,
                  onChanged: (value) {
                    _meshService.setAutoConnect(value);
                    _updateStats();
                  },
                ),
              ],
            ),
            if (_isEnabled) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Status: Active',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your device is discoverable and can connect to nearby devices.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final hiddenCount = (_stats['hiddenNodes'] as int?) ?? 0;
    final visibleCount = (_stats['visibleNodes'] as int?) ?? 0;
    final messageHistory = (_stats['messageHistory'] as int?) ?? 0;
    final isAdvertising = (_stats['isAdvertising'] as bool?) ?? false;
    final isDiscovering = (_stats['isDiscovering'] as bool?) ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              'Visible Devices',
              visibleCount.toString(),
              Icons.devices,
              visibleCount > 0 ? Colors.green : Colors.grey,
            ),
            _buildStatRow(
              'Hidden Devices',
              hiddenCount.toString(),
              Icons.visibility_off,
              hiddenCount > 0 ? Colors.orange : Colors.grey,
            ),
            _buildStatRow(
              'Messages Exchanged',
              messageHistory.toString(),
              Icons.message,
              Colors.blue,
            ),
            _buildStatRow(
              'Broadcasting',
              isAdvertising ? 'Yes' : 'No',
              Icons.broadcast_on_personal,
              isAdvertising ? Colors.green : Colors.grey,
            ),
            _buildStatRow(
              'Discovering',
              isDiscovering ? 'Yes' : 'No',
              Icons.radar,
              isDiscovering ? Colors.green : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildConnectedNodesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Connected Devices',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (_connectedNodes.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_connectedNodes.length}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_connectedNodes.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.devices_other,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No devices connected',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enable mesh network to connect',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._connectedNodes.map((node) => _buildNodeTile(node)),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeTile(MeshNode node) {
    final connectionAge = DateTime.now().difference(node.connectedAt);
    final ageText = _formatDuration(connectionAge);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: node.isActive ? Colors.green : Colors.grey,
        child: Icon(
          _getConnectionIcon(node.connectionType),
          color: Colors.white,
        ),
      ),
      title: Text(node.name),
      subtitle: Text(
        '${node.getConnectionTypeDisplay()} • Connected $ageText',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 20),
        onPressed: () => _disconnectNode(node.id),
      ),
    );
  }

  IconData _getConnectionIcon(MeshConnectionType type) {
    switch (type) {
      case MeshConnectionType.bluetooth:
        return Icons.bluetooth;
      case MeshConnectionType.wifiDirect:
        return Icons.wifi;
      case MeshConnectionType.wifiRouter:
        return Icons.router;
      case MeshConnectionType.wifiHotspot:
        return Icons.wifi_tethering;
      case MeshConnectionType.lan:
        return Icons.cable;
      case MeshConnectionType.usb:
        return Icons.usb;
      case MeshConnectionType.nfc:
        return Icons.nfc;
      case MeshConnectionType.ethernet:
        return Icons.settings_ethernet;
      case MeshConnectionType.auto:
        return Icons.phone_android;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 1) {
      return 'just now';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ago';
    } else {
      return '${duration.inDays}d ago';
    }
  }

  Future<void> _toggleMeshNetwork(bool value) async {
    try {
      if (value) {
        await _meshService.enable();
        _showMessage('Mesh network enabled');
      } else {
        await _meshService.disable();
        _showMessage('Mesh network disabled');
      }
      _updateStats();
    } catch (e) {
      _showMessage('Failed to toggle mesh network: $e');
    }
  }

  Future<void> _openQRPairing() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MeshQRPairingScreen()),
    );

    if (result == true) {
      _updateStats();
    }
  }

  Future<void> _disconnectNode(String nodeId) async {
    try {
      await _meshService.disconnectFromDevice(nodeId);
      _showMessage('Device disconnected');
    } catch (e) {
      _showMessage('Failed to disconnect: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
