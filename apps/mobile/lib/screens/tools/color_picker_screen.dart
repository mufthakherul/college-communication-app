import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorPickerScreen extends StatefulWidget {
  const ColorPickerScreen({super.key});

  @override
  State<ColorPickerScreen> createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  Color _selectedColor = Colors.blue;
  
  final TextEditingController _hexController = TextEditingController();
  final TextEditingController _rController = TextEditingController();
  final TextEditingController _gController = TextEditingController();
  final TextEditingController _bController = TextEditingController();
  
  double _hue = 211.0;
  double _saturation = 100.0;
  double _lightness = 50.0;
  
  final List<Color> _presetColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
  ];

  @override
  void initState() {
    super.initState();
    _updateFromColor(_selectedColor);
  }

  void _updateFromColor(Color color) {
    setState(() {
      _selectedColor = color;
      
      // Update HEX
      _hexController.text = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
      
      // Update RGB
      _rController.text = color.red.toString();
      _gController.text = color.green.toString();
      _bController.text = color.blue.toString();
      
      // Update HSL
      final hsl = HSLColor.fromColor(color);
      _hue = hsl.hue;
      _saturation = hsl.saturation * 100;
      _lightness = hsl.lightness * 100;
    });
  }

  void _updateFromHex(String hex) {
    if (hex.isEmpty) return;
    
    try {
      String hexColor = hex.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      final color = Color(int.parse(hexColor, radix: 16));
      _updateFromColor(color);
    } catch (e) {
      // Invalid hex
    }
  }

  void _updateFromRGB() {
    try {
      final r = int.parse(_rController.text);
      final g = int.parse(_gController.text);
      final b = int.parse(_bController.text);
      
      if (r >= 0 && r <= 255 && g >= 0 && g <= 255 && b >= 0 && b <= 255) {
        _updateFromColor(Color.fromARGB(255, r, g, b));
      }
    } catch (e) {
      // Invalid RGB
    }
  }

  void _updateFromHSL() {
    final hslColor = HSLColor.fromAHSL(
      1.0,
      _hue,
      _saturation / 100,
      _lightness / 100,
    );
    _updateFromColor(hslColor.toColor());
  }

  void _copyValue(String value, String type) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$type copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Picker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildColorPreview(),
            const SizedBox(height: 24),
            _buildHexInput(),
            const SizedBox(height: 24),
            _buildRGBSliders(),
            const SizedBox(height: 24),
            _buildHSLSliders(),
            const SizedBox(height: 24),
            _buildPresetColors(),
            const SizedBox(height: 24),
            _buildColorInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPreview() {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: _selectedColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _selectedColor.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: _isLightColor(_selectedColor) ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _hexController.text,
              style: TextStyle(
                color: _isLightColor(_selectedColor) ? Colors.white : Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Courier',
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isLightColor(Color color) {
    return color.computeLuminance() > 0.5;
  }

  Widget _buildHexInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tag, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'HEX Color',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _hexController,
              decoration: InputDecoration(
                prefixText: '# ',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyValue(_hexController.text, 'HEX'),
                ),
              ),
              style: const TextStyle(fontFamily: 'Courier', fontSize: 16),
              onChanged: _updateFromHex,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRGBSliders() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.palette, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text(
                      'RGB Color',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => _copyValue(
                    'rgb(${_rController.text}, ${_gController.text}, ${_bController.text})',
                    'RGB',
                  ),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRGBSlider('Red', _rController, Colors.red, (value) {
              setState(() {
                _rController.text = value.round().toString();
                _updateFromRGB();
              });
            }),
            _buildRGBSlider('Green', _gController, Colors.green, (value) {
              setState(() {
                _gController.text = value.round().toString();
                _updateFromRGB();
              });
            }),
            _buildRGBSlider('Blue', _bController, Colors.blue, (value) {
              setState(() {
                _bController.text = value.round().toString();
                _updateFromRGB();
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRGBSlider(String label, TextEditingController controller, Color color, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Slider(
              value: double.tryParse(controller.text) ?? 0,
              min: 0,
              max: 255,
              divisions: 255,
              activeColor: color,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 45,
            child: Text(
              controller.text,
              style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHSLSliders() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.gradient, color: Colors.purple),
                    const SizedBox(width: 8),
                    const Text(
                      'HSL Color',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => _copyValue(
                    'hsl(${_hue.round()}, ${_saturation.round()}%, ${_lightness.round()}%)',
                    'HSL',
                  ),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildHSLSlider('Hue', _hue, 0, 360, '°', (value) {
              setState(() {
                _hue = value;
                _updateFromHSL();
              });
            }),
            _buildHSLSlider('Saturation', _saturation, 0, 100, '%', (value) {
              setState(() {
                _saturation = value;
                _updateFromHSL();
              });
            }),
            _buildHSLSlider('Lightness', _lightness, 0, 100, '%', (value) {
              setState(() {
                _lightness = value;
                _updateFromHSL();
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHSLSlider(String label, double value, double min, double max, String unit, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              '${value.round()}$unit',
              style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetColors() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preset Colors',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _presetColors.length,
              itemBuilder: (context, index) {
                final color = _presetColors[index];
                return InkWell(
                  onTap: () => _updateFromColor(color),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedColor == color ? Colors.white : Colors.grey[300]!,
                        width: _selectedColor == color ? 3 : 1,
                      ),
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

  Widget _buildColorInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Color Information',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('HEX', _hexController.text),
            _buildInfoRow('RGB', 'rgb(${_rController.text}, ${_gController.text}, ${_bController.text})'),
            _buildInfoRow('HSL', 'hsl(${_hue.round()}, ${_saturation.round()}%, ${_lightness.round()}%)'),
            _buildInfoRow('Luminance', '${(_selectedColor.computeLuminance() * 100).toStringAsFixed(1)}%'),
            _buildInfoRow('Brightness', _isLightColor(_selectedColor) ? 'Light' : 'Dark'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Courier',
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _hexController.dispose();
    _rController.dispose();
    _gController.dispose();
    _bController.dispose();
    super.dispose();
  }
}
