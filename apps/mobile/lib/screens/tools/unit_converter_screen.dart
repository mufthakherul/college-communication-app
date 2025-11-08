import 'package:flutter/material.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  String _category = 'Length';
  String _fromUnit = 'Meters';
  String _toUnit = 'Feet';
  double _inputValue = 0;
  double _outputValue = 0;

  final Map<String, Map<String, double>> _conversionFactors = {
    'Length': {
      'Meters': 1.0,
      'Kilometers': 0.001,
      'Centimeters': 100.0,
      'Millimeters': 1000.0,
      'Miles': 0.000621371,
      'Yards': 1.09361,
      'Feet': 3.28084,
      'Inches': 39.3701,
    },
    'Weight': {
      'Kilograms': 1.0,
      'Grams': 1000.0,
      'Milligrams': 1000000.0,
      'Pounds': 2.20462,
      'Ounces': 35.274,
      'Tons': 0.001,
    },
    'Temperature': {'Celsius': 1.0, 'Fahrenheit': 1.0, 'Kelvin': 1.0},
    'Area': {
      'Square Meters': 1.0,
      'Square Kilometers': 0.000001,
      'Square Feet': 10.7639,
      'Square Yards': 1.19599,
      'Acres': 0.000247105,
      'Hectares': 0.0001,
    },
    'Volume': {
      'Liters': 1.0,
      'Milliliters': 1000.0,
      'Cubic Meters': 0.001,
      'Gallons': 0.264172,
      'Cubic Feet': 0.0353147,
    },
  };

  void _convert() {
    if (_category == 'Temperature') {
      _convertTemperature();
    } else {
      final fromFactor = _conversionFactors[_category]![_fromUnit]!;
      final toFactor = _conversionFactors[_category]![_toUnit]!;
      setState(() {
        _outputValue = _inputValue * toFactor / fromFactor;
      });
    }
  }

  void _convertTemperature() {
    double celsius;

    // Convert input to Celsius first
    if (_fromUnit == 'Celsius') {
      celsius = _inputValue;
    } else if (_fromUnit == 'Fahrenheit') {
      celsius = (_inputValue - 32) * 5 / 9;
    } else {
      // Kelvin
      celsius = _inputValue - 273.15;
    }

    // Convert from Celsius to output
    double result;
    if (_toUnit == 'Celsius') {
      result = celsius;
    } else if (_toUnit == 'Fahrenheit') {
      result = celsius * 9 / 5 + 32;
    } else {
      // Kelvin
      result = celsius + 273.15;
    }

    setState(() {
      _outputValue = result;
    });
  }

  void _updateCategory(String category) {
    setState(() {
      _category = category;
      _fromUnit = _conversionFactors[category]!.keys.first;
      _toUnit = _conversionFactors[category]!.keys.toList()[1];
      _inputValue = 0;
      _outputValue = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unit Converter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category selector
            const Text(
              'Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: _conversionFactors.keys
                  .map((cat) => ButtonSegment(value: cat, label: Text(cat)))
                  .toList(),
              selected: {_category},
              onSelectionChanged: (Set<String> selection) {
                _updateCategory(selection.first);
              },
            ),
            const SizedBox(height: 32),

            // Input section
            const Text(
              'From',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _fromUnit,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: _conversionFactors[_category]!
                  .keys
                  .map(
                    (unit) => DropdownMenuItem(value: unit, child: Text(unit)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _fromUnit = value!);
                _convert();
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Value',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _inputValue = double.tryParse(value) ?? 0;
                });
                _convert();
              },
            ),
            const SizedBox(height: 32),

            // Convert button
            const Icon(Icons.sync_alt, size: 32, color: Colors.blue),
            const SizedBox(height: 32),

            // Output section
            const Text(
              'To',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _toUnit,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: _conversionFactors[_category]!
                  .keys
                  .map(
                    (unit) => DropdownMenuItem(value: unit, child: Text(unit)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _toUnit = value!);
                _convert();
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Text(
                _outputValue.toStringAsFixed(4),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
