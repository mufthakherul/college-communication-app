import 'package:flutter/material.dart';

class IPCalculatorScreen extends StatefulWidget {
  const IPCalculatorScreen({super.key});

  @override
  State<IPCalculatorScreen> createState() => _IPCalculatorScreenState();
}

class _IPCalculatorScreenState extends State<IPCalculatorScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _cidrController = TextEditingController(text: '24');
  
  String? _networkAddress;
  String? _broadcastAddress;
  String? _subnetMask;
  String? _wildcardMask;
  int? _totalHosts;
  int? _usableHosts;
  String? _ipClass;
  String? _ipType;
  String? _firstHost;
  String? _lastHost;

  void _calculate() {
    final ip = _ipController.text.trim();
    final cidr = int.tryParse(_cidrController.text.trim()) ?? 24;

    if (!_isValidIP(ip)) {
      _showError('Invalid IP address');
      return;
    }

    if (cidr < 0 || cidr > 32) {
      _showError('CIDR must be between 0 and 32');
      return;
    }

    setState(() {
      final parts = ip.split('.').map(int.parse).toList();
      final ipInt = (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8) | parts[3];
      
      // Calculate subnet mask
      final maskInt = (0xFFFFFFFF << (32 - cidr)) & 0xFFFFFFFF;
      _subnetMask = _intToIP(maskInt);
      
      // Calculate wildcard mask
      final wildcardInt = ~maskInt & 0xFFFFFFFF;
      _wildcardMask = _intToIP(wildcardInt);
      
      // Calculate network address
      final networkInt = ipInt & maskInt;
      _networkAddress = _intToIP(networkInt);
      
      // Calculate broadcast address
      final broadcastInt = networkInt | wildcardInt;
      _broadcastAddress = _intToIP(broadcastInt);
      
      // Calculate hosts
      _totalHosts = 1 << (32 - cidr);
      _usableHosts = _totalHosts! - 2;
      
      // First and last usable host
      _firstHost = _intToIP(networkInt + 1);
      _lastHost = _intToIP(broadcastInt - 1);
      
      // Determine IP class and type
      _ipClass = _getIPClass(parts[0]);
      _ipType = _getIPType(parts);
    });
  }

  bool _isValidIP(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    
    for (final part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }
    return true;
  }

  String _intToIP(int ip) {
    return '${(ip >> 24) & 0xFF}.${(ip >> 16) & 0xFF}.${(ip >> 8) & 0xFF}.${ip & 0xFF}';
  }

  String _getIPClass(int firstOctet) {
    if (firstOctet >= 1 && firstOctet <= 126) return 'A';
    if (firstOctet >= 128 && firstOctet <= 191) return 'B';
    if (firstOctet >= 192 && firstOctet <= 223) return 'C';
    if (firstOctet >= 224 && firstOctet <= 239) return 'D (Multicast)';
    return 'E (Reserved)';
  }

  String _getIPType(List<int> parts) {
    // Private IP ranges
    if (parts[0] == 10) return 'Private';
    if (parts[0] == 172 && parts[1] >= 16 && parts[1] <= 31) return 'Private';
    if (parts[0] == 192 && parts[1] == 168) return 'Private';
    if (parts[0] == 127) return 'Loopback';
    return 'Public';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IP/Subnet Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Calculate network details from IP address and CIDR notation',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Input Fields
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'IP Address',
                hintText: '192.168.1.1',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.computer),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cidrController,
              decoration: const InputDecoration(
                labelText: 'CIDR (0-32)',
                hintText: '24',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.network_check),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Calculate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text('Calculate'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Results
            if (_networkAddress != null) ...[
              const Text(
                'Network Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildResultCard('Network Address', _networkAddress!, Icons.router),
              _buildResultCard('Broadcast Address', _broadcastAddress!, Icons.broadcast_on_personal),
              _buildResultCard('Subnet Mask', _subnetMask!, Icons.filter_list),
              _buildResultCard('Wildcard Mask', _wildcardMask!, Icons.filter_none),
              const SizedBox(height: 16),
              const Text(
                'Host Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildResultCard('First Usable Host', _firstHost!, Icons.play_arrow),
              _buildResultCard('Last Usable Host', _lastHost!, Icons.stop),
              _buildResultCard('Total Hosts', _totalHosts!.toString(), Icons.devices),
              _buildResultCard('Usable Hosts', _usableHosts!.toString(), Icons.computer),
              const SizedBox(height: 16),
              const Text(
                'IP Classification',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildResultCard('IP Class', _ipClass!, Icons.category),
              _buildResultCard('IP Type', _ipType!, Icons.security),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(icon, color: Colors.blue[700]),
        ),
        title: Text(label),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    _cidrController.dispose();
    super.dispose();
  }
}
