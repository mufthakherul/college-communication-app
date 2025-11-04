import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class HashGeneratorScreen extends StatefulWidget {
  const HashGeneratorScreen({super.key});

  @override
  State<HashGeneratorScreen> createState() => _HashGeneratorScreenState();
}

class _HashGeneratorScreenState extends State<HashGeneratorScreen> {
  final TextEditingController _inputController = TextEditingController();

  String _md5Hash = '';
  String _sha1Hash = '';
  String _sha256Hash = '';
  String _sha512Hash = '';

  bool _uppercase = false;

  void _generateHashes() {
    if (_inputController.text.isEmpty) {
      setState(() {
        _md5Hash = '';
        _sha1Hash = '';
        _sha256Hash = '';
        _sha512Hash = '';
      });
      return;
    }

    final bytes = utf8.encode(_inputController.text);

    setState(() {
      _md5Hash = md5.convert(bytes).toString();
      _sha1Hash = sha1.convert(bytes).toString();
      _sha256Hash = sha256.convert(bytes).toString();
      _sha512Hash = sha512.convert(bytes).toString();

      if (_uppercase) {
        _md5Hash = _md5Hash.toUpperCase();
        _sha1Hash = _sha1Hash.toUpperCase();
        _sha256Hash = _sha256Hash.toUpperCase();
        _sha512Hash = _sha512Hash.toUpperCase();
      }
    });
  }

  void _copyHash(String hash, String type) {
    Clipboard.setData(ClipboardData(text: hash));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$type hash copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hash Generator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildInputSection(),
            const SizedBox(height: 16),
            _buildOptionsSection(),
            const SizedBox(height: 16),
            _buildGenerateButton(),
            const SizedBox(height: 24),
            if (_md5Hash.isNotEmpty) ...[
              _buildHashCard(
                'MD5',
                _md5Hash,
                Colors.blue,
                'Fast but not secure. Used for checksums.',
              ),
              const SizedBox(height: 12),
              _buildHashCard(
                'SHA-1',
                _sha1Hash,
                Colors.orange,
                'Legacy hash. Not recommended for security.',
              ),
              const SizedBox(height: 12),
              _buildHashCard(
                'SHA-256',
                _sha256Hash,
                Colors.green,
                'Secure. Commonly used in blockchain and certificates.',
              ),
              const SizedBox(height: 12),
              _buildHashCard(
                'SHA-512',
                _sha512Hash,
                Colors.purple,
                'Most secure. Longer hash length.',
              ),
              const SizedBox(height: 24),
              _buildComparisonSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Cryptographic Hash Generator',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Generate MD5, SHA-1, SHA-256, and SHA-512 hashes from text. Used in password storage, data integrity verification, and digital signatures.',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Input Text',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _inputController,
          decoration: InputDecoration(
            hintText: 'Enter text to hash...',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.text_fields),
            suffixIcon: _inputController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _inputController.clear();
                        _md5Hash = '';
                        _sha1Hash = '';
                        _sha256Hash = '';
                        _sha512Hash = '';
                      });
                    },
                  )
                : null,
          ),
          maxLines: 5,
          onChanged: (_) => _generateHashes(),
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Card(
      child: SwitchListTile(
        title: const Text('Uppercase Output'),
        subtitle: const Text('Display hashes in uppercase'),
        value: _uppercase,
        onChanged: (value) {
          setState(() => _uppercase = value);
          _generateHashes();
        },
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _generateHashes,
        icon: const Icon(Icons.fingerprint),
        label: const Text('Generate Hashes'),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
      ),
    );
  }

  Widget _buildHashCard(
    String title,
    String hash,
    Color color,
    String description,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${hash.length} chars',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: SelectableText(
                hash,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _copyHash(hash, title),
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Algorithm Comparison',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Table(
              border: TableBorder.all(color: Colors.grey[300]!),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Algorithm',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Length',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Security',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                _buildComparisonRow('MD5', '128-bit', 'Weak', Colors.red),
                _buildComparisonRow('SHA-1', '160-bit', 'Weak', Colors.orange),
                _buildComparisonRow(
                  'SHA-256',
                  '256-bit',
                  'Strong',
                  Colors.green,
                ),
                _buildComparisonRow(
                  'SHA-512',
                  '512-bit',
                  'Strongest',
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Colors.amber[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: Use SHA-256 or SHA-512 for password hashing and security applications.',
                      style: TextStyle(fontSize: 11, color: Colors.amber[900]),
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

  TableRow _buildComparisonRow(
    String algo,
    String length,
    String security,
    Color color,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(algo, style: const TextStyle(fontSize: 12)),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(length, style: const TextStyle(fontSize: 12)),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text(security, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}
