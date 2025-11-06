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

  // Bitwise operation controllers
  final TextEditingController _num1Controller = TextEditingController();
  final TextEditingController _num2Controller = TextEditingController();
  String _bitwiseResult = '';
  String _selectedOperation = 'AND';

  final List<String> _operations = [
    'AND',
    'OR',
    'XOR',
    'NOT',
    'Left Shift',
    'Right Shift',
  ];

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$type copied to clipboard')));
  }

  void _performBitwiseOperation() {
    final num1 = int.tryParse(_num1Controller.text);
    final num2 = int.tryParse(_num2Controller.text);

    if (num1 == null) {
      setState(() => _bitwiseResult = 'Invalid first number');
      return;
    }

    if (_selectedOperation != 'NOT' && num2 == null) {
      setState(() => _bitwiseResult = 'Invalid second number');
      return;
    }

    int result;
    String operation;

    switch (_selectedOperation) {
      case 'AND':
        result = num1 & num2!;
        operation = '$num1 & $num2';
        break;
      case 'OR':
        result = num1 | num2!;
        operation = '$num1 | $num2';
        break;
      case 'XOR':
        result = num1 ^ num2!;
        operation = '$num1 ^ $num2';
        break;
      case 'NOT':
        result = ~num1;
        operation = '~$num1';
        break;
      case 'Left Shift':
        result = num1 << (num2 ?? 1);
        operation = '$num1 << ${num2 ?? 1}';
        break;
      case 'Right Shift':
        result = num1 >> (num2 ?? 1);
        operation = '$num1 >> ${num2 ?? 1}';
        break;
      default:
        result = 0;
        operation = '';
    }

    setState(() {
      _bitwiseResult =
          '$operation = $result\nBinary: ${result.toRadixString(2)}\nHex: 0x${result.toRadixString(16).toUpperCase()}';
    });
  }

  String _toTwosComplement(String binary, int bits) {
    if (binary.isEmpty) return '';
    try {
      final value = int.parse(binary, radix: 2);
      // Check if value requires more than 'bits' to represent
      if (value >= (1 << bits)) {
        return 'Overflow for $bits-bit';
      }
      // Invert and add 1
      final inverted = (~value) & ((1 << bits) - 1);
      final twosComp = (inverted + 1) & ((1 << bits) - 1);
      return twosComp.toRadixString(2).padLeft(bits, '0');
    } catch (e) {
      return 'Invalid';
    }
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
              setState(_clearAll);
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
            _buildBitwiseOperations(),
            const SizedBox(height: 24),
            _buildTwosComplementSection(),
            const SizedBox(height: 24),
            _buildReferenceTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildBitwiseOperations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.settings, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  'Bitwise Operations',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _num1Controller,
                    decoration: const InputDecoration(
                      labelText: 'Number 1',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                if (_selectedOperation != 'NOT')
                  Expanded(
                    child: TextField(
                      controller: _num2Controller,
                      decoration: const InputDecoration(
                        labelText: 'Number 2',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedOperation,
              decoration: const InputDecoration(
                labelText: 'Operation',
                border: OutlineInputBorder(),
              ),
              items: _operations.map((op) {
                return DropdownMenuItem(value: op, child: Text(op));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedOperation = value!);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _performBitwiseOperation,
                icon: const Icon(Icons.calculate),
                label: const Text('Calculate'),
              ),
            ),
            if (_bitwiseResult.isNotEmpty) ...[
              const SizedBox(height: 16),
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
                    const Text(
                      'Result:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _bitwiseResult,
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTwosComplementSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.flip, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Two\'s Complement',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_binaryController.text.isNotEmpty) ...[
              _buildComplementRow('8-bit', 8),
              _buildComplementRow('16-bit', 16),
              _buildComplementRow('32-bit', 32),
            ] else
              Text(
                'Enter a binary number above to see two\'s complement',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplementRow(String label, int bits) {
    final complement = _toTwosComplement(_binaryController.text, bits);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              complement,
              style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
            ),
          ),
          if (complement != 'Invalid' && complement != 'Overflow for $bits-bit')
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () =>
                  _copyToClipboard(complement, 'Two\'s Complement'),
            ),
        ],
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
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                      child: Text(
                        'Decimal',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Binary',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Hex',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
