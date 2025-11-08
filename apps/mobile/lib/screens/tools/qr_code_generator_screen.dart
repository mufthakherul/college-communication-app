import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QRCodeGeneratorScreen extends StatefulWidget {
  const QRCodeGeneratorScreen({super.key});

  @override
  State<QRCodeGeneratorScreen> createState() => _QRCodeGeneratorScreenState();
}

class _QRCodeGeneratorScreenState extends State<QRCodeGeneratorScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _qrData;
  String _errorMessage = '';

  void _generateQR() {
    if (_controller.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter text or URL';
        _qrData = null;
      });
      return;
    }

    setState(() {
      _qrData = _controller.text.trim();
      _errorMessage = '';
    });
  }

  void _copyText() {
    if (_controller.text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _controller.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _clearAll() {
    _controller.clear();
    setState(() {
      _qrData = null;
      _errorMessage = '';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Enter text, URLs, phone numbers, or emails to generate QR codes',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Input section
            Text(
              'Text Input',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter text, URL, or data...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.edit),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearAll,
                      )
                    : null,
              ),
              maxLines: 4,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Quick templates
            Text(
              'Quick Templates',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildTemplateButton('Phone', 'tel:', '9876543210'),
                _buildTemplateButton('Email', 'mailto:', 'student@example.com'),
                _buildTemplateButton('WiFi', 'WIFI:', 'Example123'),
                _buildTemplateButton('URL', 'https://', 'example.com'),
              ],
            ),
            const SizedBox(height: 24),

            // Generate button
            ElevatedButton.icon(
              onPressed: _generateQR,
              icon: const Icon(Icons.qr_code_2),
              label: const Text('Generate QR Code'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            ],

            // QR display
            if (_qrData != null) ...[
              const SizedBox(height: 32),
              Text(
                'QR Code',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildQRCodeWidget(_qrData!),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Data: $_qrData',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _copyText,
                icon: const Icon(Icons.copy),
                label: const Text('Copy Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateButton(
    String label,
    String prefix,
    String example,
  ) {
    return ActionChip(
      onPressed: () {
        setState(() {
          _controller.text = '$prefix$example';
        });
      },
      label: Text(label),
      avatar: const Icon(Icons.add, size: 18),
    );
  }

  Widget _buildQRCodeWidget(String data) {
    // Simple QR code visualization (ASCII-like representation)
    // In production, use qr_flutter package
    return Container(
      width: 300,
      height: 300,
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_2,
              size: 200,
              color: Colors.black,
            ),
            const SizedBox(height: 16),
            Text(
              'QR Code Ready',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use a QR code library to render',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
