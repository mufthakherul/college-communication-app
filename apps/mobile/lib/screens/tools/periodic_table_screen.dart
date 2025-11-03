import 'package:flutter/material.dart';

class PeriodicTableScreen extends StatefulWidget {
  const PeriodicTableScreen({super.key});

  @override
  State<PeriodicTableScreen> createState() => _PeriodicTableScreenState();
}

class _PeriodicTableScreenState extends State<PeriodicTableScreen> {
  Element? _selectedElement;

  final List<Element> _elements = [
    Element(1, 'H', 'Hydrogen', 1.008, 'Nonmetal', 1, 1),
    Element(2, 'He', 'Helium', 4.003, 'Noble Gas', 1, 18),
    Element(3, 'Li', 'Lithium', 6.941, 'Alkali Metal', 2, 1),
    Element(4, 'Be', 'Beryllium', 9.012, 'Alkaline Earth', 2, 2),
    Element(5, 'B', 'Boron', 10.81, 'Metalloid', 2, 13),
    Element(6, 'C', 'Carbon', 12.01, 'Nonmetal', 2, 14),
    Element(7, 'N', 'Nitrogen', 14.01, 'Nonmetal', 2, 15),
    Element(8, 'O', 'Oxygen', 16.00, 'Nonmetal', 2, 16),
    Element(9, 'F', 'Fluorine', 19.00, 'Halogen', 2, 17),
    Element(10, 'Ne', 'Neon', 20.18, 'Noble Gas', 2, 18),
    Element(11, 'Na', 'Sodium', 22.99, 'Alkali Metal', 3, 1),
    Element(12, 'Mg', 'Magnesium', 24.31, 'Alkaline Earth', 3, 2),
    Element(13, 'Al', 'Aluminum', 26.98, 'Post-transition', 3, 13),
    Element(14, 'Si', 'Silicon', 28.09, 'Metalloid', 3, 14),
    Element(15, 'P', 'Phosphorus', 30.97, 'Nonmetal', 3, 15),
    Element(16, 'S', 'Sulfur', 32.07, 'Nonmetal', 3, 16),
    Element(17, 'Cl', 'Chlorine', 35.45, 'Halogen', 3, 17),
    Element(18, 'Ar', 'Argon', 39.95, 'Noble Gas', 3, 18),
    Element(19, 'K', 'Potassium', 39.10, 'Alkali Metal', 4, 1),
    Element(20, 'Ca', 'Calcium', 40.08, 'Alkaline Earth', 4, 2),
    // Add more elements as needed
  ];

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Alkali Metal':
        return Colors.red[300]!;
      case 'Alkaline Earth':
        return Colors.orange[300]!;
      case 'Transition Metal':
        return Colors.pink[200]!;
      case 'Post-transition':
        return Colors.blue[200]!;
      case 'Metalloid':
        return Colors.teal[200]!;
      case 'Nonmetal':
        return Colors.green[300]!;
      case 'Halogen':
        return Colors.yellow[300]!;
      case 'Noble Gas':
        return Colors.purple[200]!;
      default:
        return Colors.grey[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Periodic Table'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showLegend,
          ),
        ],
      ),
      body: Column(
        children: [
          // Periodic Table Grid
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: 900,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 18,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                      childAspectRatio: 1,
                    ),
                    itemCount: 18 * 7, // 7 periods, 18 groups
                    itemBuilder: (context, index) {
                      final period = (index ~/ 18) + 1;
                      final group = (index % 18) + 1;

                      final element = _elements.firstWhere(
                        (e) => e.period == period && e.group == group,
                        orElse: () => Element(0, '', '', 0, '', 0, 0),
                      );

                      if (element.atomicNumber == 0) {
                        return const SizedBox.shrink();
                      }

                      return _buildElementCell(element);
                    },
                  ),
                ),
              ),
            ),
          ),

          // Selected Element Details
          if (_selectedElement != null) _buildElementDetails(),
        ],
      ),
    );
  }

  Widget _buildElementCell(Element element) {
    return InkWell(
      onTap: () {
        setState(() => _selectedElement = element);
      },
      child: Container(
        decoration: BoxDecoration(
          color: _getCategoryColor(element.category),
          border: Border.all(
            color: _selectedElement == element ? Colors.blue : Colors.grey,
            width: _selectedElement == element ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              element.atomicNumber.toString(),
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
            ),
            Text(
              element.symbol,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              element.name,
              style: const TextStyle(fontSize: 6),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElementDetails() {
    final element = _selectedElement!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getCategoryColor(element.category),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    element.symbol,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      element.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      element.category,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() => _selectedElement = null);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip('Atomic #', element.atomicNumber.toString()),
              const SizedBox(width: 8),
              _buildInfoChip('Mass', element.atomicMass.toStringAsFixed(3)),
              const SizedBox(width: 8),
              _buildInfoChip('Period', element.period.toString()),
              const SizedBox(width: 8),
              _buildInfoChip('Group', element.group.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLegend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Element Categories'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLegendItem('Alkali Metal', Colors.red[300]!),
              _buildLegendItem('Alkaline Earth', Colors.orange[300]!),
              _buildLegendItem('Transition Metal', Colors.pink[200]!),
              _buildLegendItem('Post-transition', Colors.blue[200]!),
              _buildLegendItem('Metalloid', Colors.teal[200]!),
              _buildLegendItem('Nonmetal', Colors.green[300]!),
              _buildLegendItem('Halogen', Colors.yellow[300]!),
              _buildLegendItem('Noble Gas', Colors.purple[200]!),
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

  Widget _buildLegendItem(String category, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(category),
        ],
      ),
    );
  }
}

class Element {
  final int atomicNumber;
  final String symbol;
  final String name;
  final double atomicMass;
  final String category;
  final int period;
  final int group;

  Element(
    this.atomicNumber,
    this.symbol,
    this.name,
    this.atomicMass,
    this.category,
    this.period,
    this.group,
  );
}
