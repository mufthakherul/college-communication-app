import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegexTesterScreen extends StatefulWidget {
  const RegexTesterScreen({super.key});

  @override
  State<RegexTesterScreen> createState() => _RegexTesterScreenState();
}

class _RegexTesterScreenState extends State<RegexTesterScreen> {
  final TextEditingController _regexController = TextEditingController();
  final TextEditingController _testStringController = TextEditingController();
  final TextEditingController _replacementController = TextEditingController();

  bool _caseSensitive = true;
  bool _multiline = false;
  bool _dotAll = false;

  List<RegExpMatch> _matches = [];
  String _error = '';
  String _replacedText = '';

  final Map<String, String> _commonPatterns = {
    'Email': r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    'Phone (US)': r'^\+?1?\d{10}$',
    'URL':
        r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    'IPv4':
        r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    'Date (YYYY-MM-DD)': r'^\d{4}-\d{2}-\d{2}$',
    'Time (HH:MM)': r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$',
    'Hex Color': r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$',
    'Credit Card': r'^\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}$',
  };

  void _testRegex() {
    setState(() {
      _matches.clear();
      _error = '';
      _replacedText = '';
    });

    if (_regexController.text.isEmpty) {
      setState(() => _error = 'Please enter a regex pattern');
      return;
    }

    try {
      final regex = RegExp(
        _regexController.text,
        caseSensitive: _caseSensitive,
        multiLine: _multiline,
        dotAll: _dotAll,
      );

      setState(() {
        _matches = regex.allMatches(_testStringController.text).toList();

        // Perform replacement if replacement text is provided
        if (_replacementController.text.isNotEmpty) {
          _replacedText = _testStringController.text.replaceAll(
            regex,
            _replacementController.text,
          );
        }
      });
    } catch (e) {
      setState(() => _error = 'Invalid regex: ${e.toString()}');
    }
  }

  void _loadCommonPattern(String pattern) {
    setState(() {
      _regexController.text = pattern;
      _testRegex();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regex Tester'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showRegexHelp,
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
            _buildCommonPatterns(),
            const SizedBox(height: 16),
            _buildRegexInput(),
            const SizedBox(height: 16),
            _buildOptions(),
            const SizedBox(height: 16),
            _buildTestStringInput(),
            const SizedBox(height: 16),
            _buildReplacementInput(),
            const SizedBox(height: 16),
            _buildTestButton(),
            const SizedBox(height: 16),
            if (_error.isNotEmpty) _buildError(),
            if (_matches.isNotEmpty) _buildResults(),
            if (_replacedText.isNotEmpty) _buildReplacementResult(),
          ],
        ),
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
                'Test regular expressions and see matches in real-time',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonPatterns() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Common Patterns',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonPatterns.keys.map((name) {
                return ActionChip(
                  label: Text(name, style: const TextStyle(fontSize: 12)),
                  onPressed: () => _loadCommonPattern(_commonPatterns[name]!),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegexInput() {
    return TextField(
      controller: _regexController,
      decoration: InputDecoration(
        labelText: 'Regular Expression',
        hintText: r'e.g., \d{3}-\d{2}-\d{4}',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.code),
        suffixIcon: _regexController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _regexController.clear();
                    _matches.clear();
                    _error = '';
                  });
                },
              )
            : null,
      ),
      style: const TextStyle(fontFamily: 'Courier'),
      onChanged: (_) => _testRegex(),
    );
  }

  Widget _buildOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Options:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            CheckboxListTile(
              title: const Text(
                'Case Sensitive',
                style: TextStyle(fontSize: 14),
              ),
              value: _caseSensitive,
              dense: true,
              onChanged: (value) {
                setState(() => _caseSensitive = value ?? true);
                _testRegex();
              },
            ),
            CheckboxListTile(
              title: const Text('Multiline', style: TextStyle(fontSize: 14)),
              subtitle: const Text(
                r'^/$ match line starts/ends',
                style: TextStyle(fontSize: 11),
              ),
              value: _multiline,
              dense: true,
              onChanged: (value) {
                setState(() => _multiline = value ?? false);
                _testRegex();
              },
            ),
            CheckboxListTile(
              title: const Text('Dot All', style: TextStyle(fontSize: 14)),
              subtitle: const Text(
                '. matches newlines',
                style: TextStyle(fontSize: 11),
              ),
              value: _dotAll,
              dense: true,
              onChanged: (value) {
                setState(() => _dotAll = value ?? false);
                _testRegex();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestStringInput() {
    return TextField(
      controller: _testStringController,
      decoration: const InputDecoration(
        labelText: 'Test String',
        hintText: 'Enter text to test against the regex',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.text_fields),
      ),
      maxLines: 5,
      onChanged: (_) => _testRegex(),
    );
  }

  Widget _buildReplacementInput() {
    return TextField(
      controller: _replacementController,
      decoration: const InputDecoration(
        labelText: 'Replacement Text (Optional)',
        hintText: 'Text to replace matches with',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.find_replace),
      ),
      onChanged: (_) => _testRegex(),
    );
  }

  Widget _buildTestButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _testRegex,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Test Regex'),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
      ),
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
              child: Text(_error, style: TextStyle(color: Colors.red[700])),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  '${_matches.length} Match${_matches.length != 1 ? 'es' : ''} Found',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _matches.length,
              itemBuilder: (context, index) {
                final match = _matches[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.green[50],
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      match.group(0) ?? '',
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text('Position: ${match.start} - ${match.end}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: match.group(0) ?? ''),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Match copied')),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplacementResult() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.find_replace, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Replacement Result',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _replacedText,
                    style: const TextStyle(fontFamily: 'Courier'),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _replacedText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Result copied')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy'),
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

  void _showRegexHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regex Quick Reference'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Character Classes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(r'\d - Digit (0-9)'),
              Text(r'\w - Word character (a-z, A-Z, 0-9, _)'),
              Text(r'\s - Whitespace'),
              Text('. - Any character'),
              SizedBox(height: 12),
              Text(
                'Quantifiers:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('* - 0 or more'),
              Text('+ - 1 or more'),
              Text('? - 0 or 1'),
              Text('{n} - Exactly n'),
              Text('{n,m} - Between n and m'),
              SizedBox(height: 12),
              Text('Anchors:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('^ - Start of string'),
              Text(r'$ - End of string'),
              SizedBox(height: 12),
              Text('Groups:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('() - Capture group'),
              Text('| - Or'),
              Text('[] - Character set'),
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
    _regexController.dispose();
    _testStringController.dispose();
    _replacementController.dispose();
    super.dispose();
  }
}
