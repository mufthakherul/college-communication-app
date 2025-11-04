import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormulaSheetScreen extends StatefulWidget {
  const FormulaSheetScreen({super.key});

  @override
  State<FormulaSheetScreen> createState() => _FormulaSheetScreenState();
}

class _FormulaSheetScreenState extends State<FormulaSheetScreen> {
  String _selectedSubject = 'Mathematics';

  final Map<String, List<Formula>> _formulas = {
    'Mathematics': [
      Formula('Quadratic Formula', 'x = (-b ± √(b² - 4ac)) / 2a',
          'For equation ax² + bx + c = 0'),
      Formula(
          'Pythagorean Theorem', 'a² + b² = c²', 'For right-angled triangles'),
      Formula('Area of Circle', 'A = πr²', 'r is radius'),
      Formula('Circumference of Circle', 'C = 2πr', 'r is radius'),
      Formula('Area of Triangle', 'A = ½bh', 'b is base, h is height'),
      Formula('Volume of Sphere', 'V = (4/3)πr³', 'r is radius'),
      Formula('Surface Area of Sphere', 'A = 4πr²', 'r is radius'),
      Formula('Distance Formula', 'd = √[(x₂-x₁)² + (y₂-y₁)²]',
          'Distance between two points'),
      Formula(
          'Slope of Line', 'm = (y₂-y₁)/(x₂-x₁)', 'Slope between two points'),
      Formula(
          'Sum of n terms', 'Sₙ = n(a + l)/2', 'For arithmetic progression'),
      Formula('Compound Interest', 'A = P(1 + r/n)^(nt)',
          'P: principal, r: rate, n: times per year, t: years'),
    ],
    'Physics': [
      Formula('Newton\'s Second Law', 'F = ma', 'Force = mass × acceleration'),
      Formula('Kinetic Energy', 'KE = ½mv²', 'm is mass, v is velocity'),
      Formula('Potential Energy', 'PE = mgh',
          'm is mass, g is gravity, h is height'),
      Formula('Work', 'W = F × d × cos(θ)', 'Force × displacement × angle'),
      Formula('Power', 'P = W/t', 'Work per unit time'),
      Formula('Ohm\'s Law', 'V = IR', 'Voltage = Current × Resistance'),
      Formula('Density', 'ρ = m/V', 'Density = mass / volume'),
      Formula('Pressure', 'P = F/A', 'Pressure = Force / Area'),
      Formula('Speed', 'v = d/t', 'Speed = distance / time'),
      Formula('Acceleration', 'a = (v-u)/t', 'Change in velocity / time'),
      Formula('Momentum', 'p = mv', 'mass × velocity'),
      Formula('Gravitational Force', 'F = G(m₁m₂)/r²',
          'Newton\'s law of gravitation'),
    ],
    'Chemistry': [
      Formula('Ideal Gas Law', 'PV = nRT',
          'Pressure × Volume = moles × gas constant × Temperature'),
      Formula('Density', 'D = m/V', 'Density = mass / volume'),
      Formula('Molarity', 'M = n/V', 'Moles of solute / liters of solution'),
      Formula('Moles', 'n = m/M', 'Moles = mass / molar mass'),
      Formula('pH', 'pH = -log[H⁺]', 'Measure of acidity'),
      Formula(
          'Dilution', 'M₁V₁ = M₂V₂', 'Concentration and volume relationship'),
      Formula('Percent Composition', '% = (mass of element / total mass) × 100',
          'Percentage by mass'),
      Formula('Avogadro\'s Number', 'N = 6.022 × 10²³',
          'Number of particles in a mole'),
      Formula('Heat Capacity', 'Q = mcΔT',
          'Heat = mass × specific heat × temperature change'),
      Formula('Kinetic Molecular Theory', 'KE_avg = (3/2)kT',
          'Average kinetic energy of gas molecules'),
    ],
    'Electronics': [
      Formula('Ohm\'s Law', 'V = IR', 'Voltage = Current × Resistance'),
      Formula('Power', 'P = VI = I²R = V²/R', 'Electrical power formulas'),
      Formula('Series Resistance', 'R_total = R₁ + R₂ + R₃...',
          'Sum of all resistances'),
      Formula('Parallel Resistance', '1/R_total = 1/R₁ + 1/R₂ + 1/R₃...',
          'Reciprocal sum'),
      Formula('Capacitance', 'C = Q/V', 'Capacitance = Charge / Voltage'),
      Formula('RC Time Constant', 'τ = RC', 'Time constant for RC circuit'),
      Formula('Inductive Reactance', 'X_L = 2πfL', 'Reactance of inductor'),
      Formula(
          'Capacitive Reactance', 'X_C = 1/(2πfC)', 'Reactance of capacitor'),
      Formula(
          'Impedance', 'Z = √(R² + (X_L - X_C)²)', 'Total opposition to AC'),
      Formula('Frequency', 'f = 1/T', 'Frequency = 1 / Period'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formula Sheet'),
      ),
      body: Column(
        children: [
          // Subject Selector
          Container(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<String>(
              segments: _formulas.keys
                  .map((subject) => ButtonSegment(
                        value: subject,
                        label: Text(subject),
                      ))
                  .toList(),
              selected: {_selectedSubject},
              onSelectionChanged: (Set<String> selection) {
                setState(() => _selectedSubject = selection.first);
              },
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all(
                  const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),

          // Formulas List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _formulas[_selectedSubject]!.length,
              itemBuilder: (context, index) {
                final formula = _formulas[_selectedSubject]![index];
                return _buildFormulaCard(formula);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaCard(Formula formula) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          formula.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: SelectableText(
              formula.formula,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blue[900],
                fontFamily: 'Courier',
              ),
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formula.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: formula.formula));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Formula copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copy'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Formula {
  final String name;
  final String formula;
  final String description;

  Formula(this.name, this.formula, this.description);
}
