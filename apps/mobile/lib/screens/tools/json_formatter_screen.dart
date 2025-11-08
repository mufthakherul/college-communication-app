import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JSONFormatterScreen extends StatefulWidget {
  const JSONFormatterScreen({super.key});

  @override
  State<JSONFormatterScreen> createState() => _JSONFormatterScreenState();
}

class _JSONFormatterScreenState extends State<JSONFormatterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  late TabController _tabController;
  String _error = '';
  int _indentSpaces = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _formatJSON() {
    setState(() => _error = '');

    if (_inputController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter JSON data');
      return;
    }

    try {
      final jsonObject = json.decode(_inputController.text);
      final encoder = JsonEncoder.withIndent(' ' * _indentSpaces);
      final formatted = encoder.convert(jsonObject);

      setState(() {
        _outputController.text = formatted;
      });
    } catch (e) {
      setState(() => _error = 'Invalid JSON: ${e.toString()}');
    }
  }

  void _minifyJSON() {
    setState(() => _error = '');

    if (_inputController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter JSON data');
      return;
    }

    try {
      final jsonObject = json.decode(_inputController.text);
      final minified = json.encode(jsonObject);

      setState(() {
        _outputController.text = minified;
      });
    } catch (e) {
      setState(() => _error = 'Invalid JSON: ${e.toString()}');
    }
  }

  void _validateJSON() {
    setState(() => _error = '');

    if (_inputController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter JSON data');
      return;
    }

    try {
      json.decode(_inputController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Valid JSON'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _error = 'Invalid JSON: ${e.toString()}');
    }
  }

  void _escapeJSON() {
    if (_inputController.text.trim().isEmpty) return;

    final escaped = _inputController.text
        .replaceAll(r'\', r'\\')
        .replaceAll('"', r'\"')
        .replaceAll('\n', r'\n')
        .replaceAll('\r', r'\r')
        .replaceAll('\t', r'\t');

    setState(() {
      _outputController.text = escaped;
    });
  }

  void _unescapeJSON() {
    if (_inputController.text.trim().isEmpty) return;

    final unescaped = _inputController.text
        .replaceAll(r'\\', r'\')
        .replaceAll(r'\"', '"')
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\r', '\r')
        .replaceAll(r'\t', '\t');

    setState(() {
      _outputController.text = unescaped;
    });
  }

  void _copyOutput() {
    Clipboard.setData(ClipboardData(text: _outputController.text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Output copied to clipboard')));
  }

  void _clear() {
    setState(() {
      _inputController.clear();
      _outputController.clear();
      _error = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON/XML Formatter'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.data_object), text: 'JSON'),
            Tab(icon: Icon(Icons.code), text: 'XML'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildJSONTab(), _buildXMLTab()],
      ),
    );
  }

  Widget _buildJSONTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildIndentSelector(),
          const SizedBox(height: 16),
          _buildInputSection(),
          const SizedBox(height: 16),
          _buildActionButtons(),
          const SizedBox(height: 16),
          if (_error.isNotEmpty) _buildError(),
          if (_outputController.text.isNotEmpty) _buildOutputSection(),
        ],
      ),
    );
  }

  Widget _buildXMLTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'XML formatting coming soon! Use JSON tab for now.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildXMLExample(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Format, minify, validate and escape JSON data',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndentSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Text(
              'Indent Spaces:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            ...List.generate(4, (index) {
              final spaces = (index + 1) * 2;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('$spaces'),
                  selected: _indentSpaces == spaces,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _indentSpaces = spaces);
                    }
                  },
                ),
              );
            }),
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
            const Text(
              'Input',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _clear,
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _inputController,
          decoration: const InputDecoration(
            hintText: 'Paste your JSON here...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
          maxLines: 10,
          style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _formatJSON,
                icon: const Icon(Icons.format_align_left),
                label: const Text('Format'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _minifyJSON,
                icon: const Icon(Icons.compress),
                label: const Text('Minify'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _validateJSON,
                icon: const Icon(Icons.check_circle),
                label: const Text('Validate'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _escapeJSON,
                icon: const Icon(Icons.forward),
                label: const Text('Escape'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _unescapeJSON,
                icon: const Icon(Icons.replay),
                label: const Text('Unescape'),
              ),
            ),
          ],
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: Colors.red[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_error, style: TextStyle(color: Colors.red[700])),
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
            const Text(
              'Output',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: SelectableText(
            _outputController.text,
            style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildXMLExample() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'XML Example',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const SelectableText('''
<?xml version="1.0" encoding="UTF-8"?>
<student>
  <name>John Doe</name>
  <id>12345</id>
  <department>CST</department>
  <courses>
    <course>
      <code>CST101</code>
      <name>Programming Fundamentals</name>
    </course>
    <course>
      <code>CST102</code>
      <name>Data Structures</name>
    </course>
  </courses>
</student>''', style: TextStyle(fontFamily: 'Courier', fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
