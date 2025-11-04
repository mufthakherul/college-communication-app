import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ASCIITableScreen extends StatefulWidget {
  const ASCIITableScreen({super.key});

  @override
  State<ASCIITableScreen> createState() => _ASCIITableScreenState();
}

class _ASCIITableScreenState extends State<ASCIITableScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool _showExtended = false;

  List<ASCIIChar> get _asciiChars => List.generate(
    _showExtended ? 256 : 128,
    (index) => ASCIIChar(
      decimal: index,
      hex: index.toRadixString(16).toUpperCase(),
      binary: index.toRadixString(2).padLeft(8, '0'),
      char: _getDisplayChar(index),
      description: _getDescription(index),
    ),
  );

  static String _getDisplayChar(int code) {
    if (code < 32) return ''; // Control characters
    if (code == 32) return 'SPACE';
    if (code == 127) return 'DEL';
    return String.fromCharCode(code);
  }

  static String _getDescription(int code) {
    const controlChars = {
      0: 'NULL',
      1: 'SOH (Start of Heading)',
      2: 'STX (Start of Text)',
      3: 'ETX (End of Text)',
      4: 'EOT (End of Transmission)',
      5: 'ENQ (Enquiry)',
      6: 'ACK (Acknowledge)',
      7: 'BEL (Bell)',
      8: 'BS (Backspace)',
      9: 'TAB (Horizontal Tab)',
      10: 'LF (Line Feed)',
      11: 'VT (Vertical Tab)',
      12: 'FF (Form Feed)',
      13: 'CR (Carriage Return)',
      14: 'SO (Shift Out)',
      15: 'SI (Shift In)',
      16: 'DLE (Data Link Escape)',
      17: 'DC1 (Device Control 1)',
      18: 'DC2 (Device Control 2)',
      19: 'DC3 (Device Control 3)',
      20: 'DC4 (Device Control 4)',
      21: 'NAK (Negative Acknowledge)',
      22: 'SYN (Synchronous Idle)',
      23: 'ETB (End of Trans. Block)',
      24: 'CAN (Cancel)',
      25: 'EM (End of Medium)',
      26: 'SUB (Substitute)',
      27: 'ESC (Escape)',
      28: 'FS (File Separator)',
      29: 'GS (Group Separator)',
      30: 'RS (Record Separator)',
      31: 'US (Unit Separator)',
      32: 'Space',
      127: 'Delete',
    };

    if (controlChars.containsKey(code)) {
      return controlChars[code]!;
    }

    if (code >= 48 && code <= 57) return 'Digit';
    if (code >= 65 && code <= 90) return 'Uppercase Letter';
    if (code >= 97 && code <= 122) return 'Lowercase Letter';
    if ([
      33,
      34,
      35,
      36,
      37,
      38,
      39,
      40,
      41,
      42,
      43,
      44,
      45,
      46,
      47,
    ].contains(code)) {
      return 'Punctuation';
    }
    if ([58, 59, 60, 61, 62, 63, 64].contains(code)) return 'Special Character';
    if ([91, 92, 93, 94, 95, 96].contains(code)) return 'Symbol';
    if ([123, 124, 125, 126].contains(code)) return 'Symbol';

    // Extended ASCII (128-255)
    if (code >= 128 && code <= 159) return 'Extended Control';
    if (code >= 160 && code <= 191) return 'Extended Latin';
    if (code >= 192 && code <= 255) return 'Extended Latin';

    return 'Printable';
  }

  List<ASCIIChar> get _filteredChars {
    if (_searchQuery.isEmpty) return _asciiChars;

    return _asciiChars.where((char) {
      final query = _searchQuery.toLowerCase();
      return char.decimal.toString().contains(query) ||
          char.hex.toLowerCase().contains(query) ||
          char.char.toLowerCase().contains(query) ||
          char.description.toLowerCase().contains(query);
    }).toList();
  }

  void _copyToClipboard(String value, String type) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$type copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ASCII Table')),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by code, char, or description...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Info Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _showExtended
                        ? 'Extended ASCII - 256 characters (0-255)'
                        : 'ASCII - 128 characters (0-127)',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Toggle Extended ASCII
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SwitchListTile(
              title: const Text(
                'Show Extended ASCII',
                style: TextStyle(fontSize: 14),
              ),
              subtitle: const Text(
                'Characters 128-255',
                style: TextStyle(fontSize: 11),
              ),
              value: _showExtended,
              dense: true,
              onChanged: (value) {
                setState(() => _showExtended = value);
              },
            ),
          ),

          const SizedBox(height: 8),

          // ASCII Table
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredChars.length,
              itemBuilder: (context, index) {
                final char = _filteredChars[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: char.decimal < 32 || char.decimal == 127
                          ? Colors.red[100]
                          : Colors.blue[100],
                      child: Text(
                        char.decimal.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: char.decimal < 32 || char.decimal == 127
                              ? Colors.red[700]
                              : Colors.blue[700],
                        ),
                      ),
                    ),
                    title: Text(
                      char.char.isEmpty ? char.description : char.char,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      char.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              'Decimal',
                              char.decimal.toString(),
                              Icons.looks_one,
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              'Hexadecimal',
                              '0x${char.hex}',
                              Icons.code,
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              'Binary',
                              char.binary,
                              Icons.memory,
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              'Character',
                              char.char.isEmpty ? '(Control)' : char.char,
                              Icons.text_fields,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text('$label: $value', style: const TextStyle(fontSize: 14)),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 18),
          onPressed: () => _copyToClipboard(value, label),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class ASCIIChar {
  final int decimal;
  final String hex;
  final String binary;
  final String char;
  final String description;

  ASCIIChar({
    required this.decimal,
    required this.hex,
    required this.binary,
    required this.char,
    required this.description,
  });
}
