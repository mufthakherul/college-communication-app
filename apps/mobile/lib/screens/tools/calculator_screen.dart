import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  final List<String> _history = [];

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _display = '0';
        _expression = '';
      } else if (value == '⌫') {
        if (_display.length > 1) {
          _display = _display.substring(0, _display.length - 1);
        } else {
          _display = '0';
        }
      } else if (value == '=') {
        try {
          final result = _evaluateExpression(_display);
          _history.insert(0, '$_display = $result');
          if (_history.length > 20) _history.removeLast();
          _display = result.toString();
          _expression = '';
        } catch (e) {
          _display = 'Error';
        }
      } else {
        if (_display == '0' && value != '.') {
          _display = value;
        } else {
          _display += value;
        }
      }
    });
  }

  double _evaluateExpression(String expr) {
    // Handle scientific functions
    final normalized = expr.replaceAll('×', '*').replaceAll('÷', '/');

    // Handle basic operators using a simple parser
    try {
      return _parseExpression(normalized);
    } catch (e) {
      throw Exception('Invalid expression');
    }
  }

  double _parseExpression(String expr) {
    // Remove whitespace
    final cleaned = expr.replaceAll(' ', '');

    // Simple evaluation for basic operations
    // This is a simplified version - in production, use a proper expression parser
    final tokens = <String>[];
    var currentNumber = '';

    for (var i = 0; i < cleaned.length; i++) {
      final char = cleaned[i];
      if ('0123456789.'.contains(char)) {
        currentNumber += char;
      } else if ('+-*/'.contains(char)) {
        if (currentNumber.isNotEmpty) {
          tokens.add(currentNumber);
          currentNumber = '';
        }
        tokens.add(char);
      }
    }
    if (currentNumber.isNotEmpty) {
      tokens.add(currentNumber);
    }

    // Handle multiplication and division first
    for (var i = 1; i < tokens.length - 1; i++) {
      if (tokens[i] == '*' || tokens[i] == '/') {
        final left = double.parse(tokens[i - 1]);
        final right = double.parse(tokens[i + 1]);
        final result = tokens[i] == '*' ? left * right : left / right;
        tokens[i - 1] = result.toString();
        tokens
          ..removeAt(i)
          ..removeAt(i);
        i--;
      }
    }

    // Handle addition and subtraction
    var result = double.parse(tokens[0]);
    for (var i = 1; i < tokens.length - 1; i += 2) {
      final operator = tokens[i];
      final operand = double.parse(tokens[i + 1]);
      if (operator == '+') {
        result += operand;
      } else if (operator == '-') {
        result -= operand;
      }
    }

    return result;
  }

  void _showHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('History'),
        content: SizedBox(
          width: double.maxFinite,
          child: _history.isEmpty
              ? const Center(child: Text('No history yet'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _history.length,
                  itemBuilder: (context, index) => ListTile(
                    dense: true,
                    title: Text(_history[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.content_copy, size: 18),
                      onPressed: () {
                        final result = _history[index].split('=')[1].trim();
                        setState(() => _display = result);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
        ),
        actions: [
          if (_history.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(_history.clear);
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, {Color? color, Color? textColor}) {
    return ElevatedButton(
      onPressed: () => _onButtonPressed(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.grey[200],
        foregroundColor: textColor ?? Colors.black,
        padding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 20)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: _showHistory),
        ],
      ),
      body: Column(
        children: [
          // Display
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_expression.isNotEmpty)
                    Text(
                      _expression,
                      style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                    ),
                  Text(
                    _display,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Buttons
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: _buildBasicLayout(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicLayout() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildButton('C', color: Colors.red[300])),
              const SizedBox(width: 8),
              Expanded(child: _buildButton('⌫', color: Colors.orange[200])),
              const SizedBox(width: 8),
              Expanded(child: _buildButton('÷', color: Colors.blue[200])),
              const SizedBox(width: 8),
              Expanded(child: _buildButton('×', color: Colors.blue[200])),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildButton('7')),
              const SizedBox(width: 8),
              Expanded(child: _buildButton('8')),
              const SizedBox(width: 8),
              Expanded(child: _buildButton('9')),
              const SizedBox(width: 8),
              Expanded(child: _buildButton('-', color: Colors.blue[200])),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildButton('4')),
              const SizedBox(width: 8),
              Expanded(child: _buildButton('5')),
              const SizedBox(width: 8),
              Expanded(child: _buildButton('6')),
              const SizedBox(width: 8),
              Expanded(child: _buildButton('+', color: Colors.blue[200])),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildButton('1')),
              const SizedBox(width: 8),
              Expanded(child: _buildButton('2')),
              const SizedBox(width: 8),
              Expanded(child: _buildButton('3')),
              const SizedBox(width: 8),
              Expanded(
                child: _buildButton(
                  '=',
                  color: Colors.green[400],
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Row(
            children: [
              Expanded(flex: 2, child: _buildButton('0')),
              const SizedBox(width: 8),
              Expanded(child: _buildButton('.')),
              const SizedBox(width: 8),
              Expanded(
                child: _buildButton(
                  '=',
                  color: Colors.green[400],
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
