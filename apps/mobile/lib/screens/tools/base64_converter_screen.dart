import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class Base64ConverterScreen extends StatefulWidget {
  const Base64ConverterScreen({super.key});

  @override
  State<Base64ConverterScreen> createState() => _Base64ConverterScreenState();
}

class _Base64ConverterScreenState extends State<Base64ConverterScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  
  bool _isEncoding = true;
  String _error = '';

  void _convert() {
    setState(() => _error = '');
    
    if (_inputController.text.isEmpty) {
      setState(() {
        _outputController.clear();
        _error = 'Please enter some text';
      });
      return;
    }

    try {
      if (_isEncoding) {
        // Encode to Base64
        final bytes = utf8.encode(_inputController.text);
        final base64 = base64Encode(bytes);
        setState(() => _outputController.text = base64);
      } else {
        // Decode from Base64
        final decoded = base64Decode(_inputController.text);
        final text = utf8.decode(decoded);
        setState(() => _outputController.text = text);
      }
    } catch (e) {
      setState(() {
        _error = _isEncoding 
            ? 'Encoding failed: ${e.toString()}'
            : 'Invalid Base64 string: ${e.toString()}';
        _outputController.clear();
      });
    }
  }

  void _swapMode() {
    setState(() {
      _isEncoding = !_isEncoding;
      // Swap input and output
      final temp = _inputController.text;
      _inputController.text = _outputController.text;
      _outputController.text = temp;
      _error = '';
    });
  }

  void _copyOutput() {
    if (_outputController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _outputController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Output copied to clipboard')),
      );
    }
  }

  void _clear() {
    setState(() {
      _inputController.clear();
      _outputController.clear();
      _error = '';
    });
  }

  void _loadExample() {
    setState(() {
      if (_isEncoding) {
        _inputController.text = 'Hello, World! This is a test message for Base64 encoding.';
      } else {
        _inputController.text = 'SGVsbG8sIFdvcmxkISBUaGlzIGlzIGEgdGVzdCBtZXNzYWdlIGZvciBCYXNlNjQgZW5jb2Rpbmcu';
      }
      _convert();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Base64 Converter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelp,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildModeSelector(),
            const SizedBox(height: 16),
            _buildInputSection(),
            const SizedBox(height: 16),
            _buildActionButtons(),
            const SizedBox(height: 16),
            if (_error.isNotEmpty) _buildError(),
            if (_outputController.text.isNotEmpty) _buildOutputSection(),
            const SizedBox(height: 24),
            _buildUseCases(),
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
                Icon(Icons.transform, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Base64 Encoder/Decoder',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Convert text to Base64 and back. Used for encoding binary data in text format for transmission over text-based protocols.',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isEncoding ? Colors.blue[100] : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Encode',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isEncoding ? Colors.blue[700] : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _swapMode,
              icon: const Icon(Icons.swap_horiz),
              color: Colors.blue[700],
              iconSize: 32,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isEncoding ? Colors.blue[100] : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Decode',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: !_isEncoding ? Colors.blue[700] : Colors.grey,
                    ),
                  ),
                ),
              ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isEncoding ? 'Plain Text' : 'Base64 String',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _loadExample,
              icon: const Icon(Icons.article, size: 16),
              label: const Text('Example'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _inputController,
          decoration: InputDecoration(
            hintText: _isEncoding 
                ? 'Enter text to encode...'
                : 'Enter Base64 string to decode...',
            border: const OutlineInputBorder(),
            prefixIcon: Icon(_isEncoding ? Icons.text_fields : Icons.code),
            suffixIcon: _inputController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clear,
                  )
                : null,
          ),
          maxLines: _isEncoding ? 5 : 8,
          style: TextStyle(
            fontFamily: _isEncoding ? null : 'Courier',
            fontSize: 12,
          ),
          onChanged: (_) => _convert(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _convert,
            icon: Icon(_isEncoding ? Icons.lock : Icons.lock_open),
            label: Text(_isEncoding ? 'Encode' : 'Decode'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _clear,
            icon: const Icon(Icons.clear),
            label: const Text('Clear'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _error,
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isEncoding ? 'Base64 Output' : 'Decoded Text',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _copyOutput,
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Output (${_outputController.text.length} characters)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SelectableText(
                _outputController.text,
                style: TextStyle(
                  fontFamily: _isEncoding ? 'Courier' : null,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUseCases() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Common Use Cases',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _buildUseCase(
              Icons.image,
              'Image Embedding',
              'Embed images in HTML/CSS using data URLs',
            ),
            _buildUseCase(
              Icons.api,
              'API Authentication',
              'Basic authentication in HTTP headers',
            ),
            _buildUseCase(
              Icons.email,
              'Email Attachments',
              'MIME encoding for email attachments',
            ),
            _buildUseCase(
              Icons.storage,
              'Data Storage',
              'Store binary data in text-only databases',
            ),
            _buildUseCase(
              Icons.vpn_key,
              'Tokens & Keys',
              'Encode API keys and tokens for transmission',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUseCase(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Base64'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Base64 is a binary-to-text encoding scheme that represents binary data in ASCII string format.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              const Text(
                'How it works:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Converts 3 bytes (24 bits) into 4 ASCII characters\n'
                '• Uses 64 characters: A-Z, a-z, 0-9, +, /\n'
                '• Pads output with "=" if needed\n'
                '• Increases data size by ~33%',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              const Text(
                'Note:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Base64 is encoding, not encryption. It does not provide security!',
                style: TextStyle(fontSize: 12, color: Colors.red[700]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }
}
