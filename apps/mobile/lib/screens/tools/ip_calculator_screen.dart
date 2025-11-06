import 'package:flutter/material.dart';

class IPCalculatorScreen extends StatefulWidget {
  const IPCalculatorScreen({super.key});

  @override
  State<IPCalculatorScreen> createState() => _IPCalculatorScreenState();
}

class _IPCalculatorScreenState extends State<IPCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _ipController;
  late final TextEditingController _cidrController;

  late final TabController _tabController;

  // IPv4 results
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

  // IPv6 results
  String? _ipv6Expanded;
  String? _ipv6Compressed;
  String? _ipv6Network;
  String? _ipv6Type;

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController();
    _cidrController = TextEditingController(text: '24');
    _tabController = TabController(length: 2, vsync: this);
  }

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
      final ipInt =
          (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8) | parts[3];

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _calculateIPv6() {
    final ip = _ipController.text.trim();
    final prefix = int.tryParse(_cidrController.text.trim()) ?? 64;

    if (!_isValidIPv6(ip)) {
      _showError('Invalid IPv6 address');
      return;
    }

    setState(() {
      _ipv6Expanded = _expandIPv6(ip);
      _ipv6Compressed = _compressIPv6(_ipv6Expanded!);
      _ipv6Network = _calculateIPv6Network(_ipv6Expanded!, prefix);
      _ipv6Type = _getIPv6Type(_ipv6Expanded!);
    });
  }

  bool _isValidIPv6(String ip) {
    final ipv6Pattern = RegExp(
      r'^(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:))$',
    );
    return ipv6Pattern.hasMatch(ip);
  }

  String _expandIPv6(String ipAddress) {
    // Work on a local variable to avoid parameter reassignment
    var workingIp = ipAddress;

    // Expand :: notation
    if (workingIp.contains('::')) {
      final parts = workingIp.split('::');
      final left = parts[0].split(':').where((s) => s.isNotEmpty).toList();
      final right = parts.length > 1
          ? parts[1].split(':').where((s) => s.isNotEmpty).toList()
          : [];
      final missing = 8 - left.length - right.length;
      final expanded = [...left, ...List.filled(missing, '0'), ...right];
      workingIp = expanded.join(':');
    }

    // Pad each section to 4 digits
    final sections = workingIp.split(':');
    return sections.map((s) => s.padLeft(4, '0')).join(':');
  }

  String _compressIPv6(String ip) {
    // Find longest run of zeros
    final sections = ip.split(':');
    var maxZeroStart = -1;
    var maxZeroLen = 0;
    var currentZeroStart = -1;
    var currentZeroLen = 0;

    for (var i = 0; i < sections.length; i++) {
      if (sections[i] == '0000') {
        if (currentZeroStart == -1) currentZeroStart = i;
        currentZeroLen++;
      } else {
        if (currentZeroLen > maxZeroLen) {
          maxZeroStart = currentZeroStart;
          maxZeroLen = currentZeroLen;
        }
        currentZeroStart = -1;
        currentZeroLen = 0;
      }
    }

    if (currentZeroLen > maxZeroLen) {
      maxZeroStart = currentZeroStart;
      maxZeroLen = currentZeroLen;
    }

    // Compress
    if (maxZeroLen > 1) {
      final before = sections.sublist(0, maxZeroStart);
      final after = sections.sublist(maxZeroStart + maxZeroLen);
      return '${before.join(':')}::${after.join(':')}';
    }

    // Remove leading zeros
    return sections.map((s) {
      final trimmed = s.replaceFirst(RegExp('^0+'), '');
      return trimmed.isEmpty ? '0' : trimmed;
    }).join(':');
  }

  String _calculateIPv6Network(String ip, int prefix) {
    final sections = ip.split(':');
    final bits = sections.map((s) => int.parse(s, radix: 16)).toList();

    // Calculate network address
    for (var i = 0; i < 8; i++) {
      final bitsInSection = prefix - (i * 16);
      if (bitsInSection <= 0) {
        bits[i] = 0;
      } else if (bitsInSection < 16) {
        final mask = (0xFFFF << (16 - bitsInSection)) & 0xFFFF;
        bits[i] = bits[i] & mask;
      }
    }

    return bits.map((b) => b.toRadixString(16).padLeft(4, '0')).join(':');
  }

  String _getIPv6Type(String ip) {
    if (ip.startsWith('fe80:')) return 'Link-Local';
    if (ip.startsWith('fc00:') || ip.startsWith('fd00:')) return 'Unique Local';
    if (ip.startsWith('ff00:')) return 'Multicast';
    if (ip == '0000:0000:0000:0000:0000:0000:0000:0001') return 'Loopback';
    if (ip == '0000:0000:0000:0000:0000:0000:0000:0000') return 'Unspecified';
    return 'Global Unicast';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IP/Subnet Calculator'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'IPv4'),
            Tab(text: 'IPv6'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildIPv4Tab(), _buildIPv6Tab()],
      ),
    );
  }

  Widget _buildIPv4Tab() {
    return SingleChildScrollView(
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
            _buildResultCard(
              'Broadcast Address',
              _broadcastAddress!,
              Icons.broadcast_on_personal,
            ),
            _buildResultCard('Subnet Mask', _subnetMask!, Icons.filter_list),
            _buildResultCard(
              'Wildcard Mask',
              _wildcardMask!,
              Icons.filter_none,
            ),
            const SizedBox(height: 16),
            const Text(
              'Host Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildResultCard(
              'First Usable Host',
              _firstHost!,
              Icons.play_arrow,
            ),
            _buildResultCard('Last Usable Host', _lastHost!, Icons.stop),
            _buildResultCard(
              'Total Hosts',
              _totalHosts!.toString(),
              Icons.devices,
            ),
            _buildResultCard(
              'Usable Hosts',
              _usableHosts!.toString(),
              Icons.computer,
            ),
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildIPv6Tab() {
    return SingleChildScrollView(
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
                      'Calculate IPv6 network details and address format',
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
              labelText: 'IPv6 Address',
              hintText: '2001:db8::1',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.computer),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cidrController,
            decoration: const InputDecoration(
              labelText: 'Prefix Length (0-128)',
              hintText: '64',
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
              onPressed: _calculateIPv6,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Results
          if (_ipv6Expanded != null) ...[
            const Text(
              'IPv6 Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildResultCard('Expanded', _ipv6Expanded!, Icons.unfold_more),
            _buildResultCard('Compressed', _ipv6Compressed!, Icons.compress),
            _buildResultCard('Network', _ipv6Network!, Icons.router),
            _buildResultCard('Type', _ipv6Type!, Icons.category),
            const SizedBox(height: 16),
            _buildIPv6Examples(),
          ],
        ],
      ),
    );
  }

  Widget _buildIPv6Examples() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Common IPv6 Addresses',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildExampleRow('Loopback', '::1'),
            _buildExampleRow('Unspecified', '::'),
            _buildExampleRow('Link-Local', 'fe80::1'),
            _buildExampleRow('Global', '2001:db8::1'),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontFamily: 'Courier')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    _cidrController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
