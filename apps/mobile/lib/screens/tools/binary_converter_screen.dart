import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BinaryConverterScreen extends StatefulWidget {
  const BinaryConverterScreen({super.key});

  @override
  State<BinaryConverterScreen> createState() => _BinaryConverterScreenState();
}

class _BinaryConverterScreenState extends State<BinaryConverterScreen> {
  final TextEditingController _decimalController = TextEditingController();
  final TextEditingController _binaryController = TextEditingController();
  final TextEditingController _hexController = TextEditingController();
  final TextEditingController _octalController = TextEditingController();

  void _convertFromDecimal(String value) {
    if (value.isEmpty) {
      _clearAll(except: 'decimal');
      return;
    }

    try {
      final decimal = int.parse(value);
      setState(() {
        _binaryController.text = decimal.toRadixString(2);
        _hexController.text = decimal.toRadixString(16).toUpperCase();
        _octalController.text = decimal.toRadixString(8);
      });
    } catch (e) {
      _clearAll(except: 'decimal');
    }
  }

  void _convertFromBinary(String value) {
    if (value.isEmpty) {
      _clearAll(except: 'binary');
      return;
    }

    try {
      final decimal = int.parse(value, radix: 2);
      setState(() {
        _decimalController.text = decimal.toString();
        _hexController.text = decimal.toRadixString(16).toUpperCase();
        _octalController.text = decimal.toRadixString(8);
      });
    } catch (e) {
      _clearAll(except: 'binary');
    }
  }

  void _convertFromHex(String value) {
    if (value.isEmpty) {
      _clearAll(except: 'hex');
      return;
    }

    try {
      final decimal = int.parse(value, radix: 16);
      setState(() {
        _decimalController.text = decimal.toString();
        _binaryController.text = decimal.toRadixString(2);
        _octalController.text = decimal.toRadixString(8);
      });
    } catch (e) {
      _clearAll(except: 'hex');
    }
  }

  void _convertFromOctal(String value) {
    if (value.isEmpty) {
      _clearAll(except: 'octal');
      return;
    }

    try {
      final decimal = int.parse(value, radix: 8);
      setState(() {
        _decimalController.text = decimal.toString();
        _binaryController.text = decimal.toRadixString(2);
        _hexController.text = decimal.toRadixString(16).toUpperCase();
      });
    } catch (e) {
      _clearAll(except: 'octal');
    }
  }

  void _clearAll({String? except}) {
    if (except != 'decimal') _decimalController.clear();
    if (except != 'binary') _binaryController.clear();
    if (except != 'hex') _hexController.clear();
    if (except != 'octal') _octalController.clear();
  }

  void _copyToClipboard(String value, String type) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$type copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Binary Converter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() => _clearAll());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildConverterField(
              'Decimal (Base 10)',
              _decimalController,
              Icons.looks_one,
              Colors.blue,
              _convertFromDecimal,
              '[0-9]',
            ),
            const SizedBox(height: 16),
            _buildConverterField(
              'Binary (Base 2)',
              _binaryController,
              Icons.code,
              Colors.green,
              _convertFromBinary,
              '[0-1]',
            ),
            const SizedBox(height: 16),
            _buildConverterField(
              'Hexadecimal (Base 16)',
              _hexController,
              Icons.numbers,
              Colors.orange,
              _convertFromHex,
              '[0-9A-Fa-f]',
            ),
            const SizedBox(height: 16),
            _buildConverterField(
              'Octal (Base 8)',
              _octalController,
              Icons.filter_8,
              Colors.purple,
              _convertFromOctal,
              '[0-7]',
            ),
            const SizedBox(height: 24),
            _buildReferenceTable(),
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
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Number System Converter',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a number in any base to convert to other bases. Used in programming and digital electronics.',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConverterField(
    String label,
    TextEditingController controller,
    IconData icon,
    Color color,
    Function(String) onChanged,
    String pattern,
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
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () =>
                            _copyToClipboard(controller.text, label),
                      )
                    : null,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(pattern)),
              ],
              onChanged: (value) {
                onChanged(value);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Reference',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Table(
              border: TableBorder.all(color: Colors.grey[300]!),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[100]),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Decimal',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Binary',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Hex',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                for (int i = 0; i <= 15; i++)
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(i.toString()),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(i.toRadixString(2).padLeft(4, '0')),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(i.toRadixString(16).toUpperCase()),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _decimalController.dispose();
    _binaryController.dispose();
    _hexController.dispose();
    _octalController.dispose();
    super.dispose();
  }
}
