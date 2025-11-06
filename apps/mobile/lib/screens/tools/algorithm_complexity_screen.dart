import 'package:flutter/material.dart';

class AlgorithmComplexityScreen extends StatefulWidget {
  const AlgorithmComplexityScreen({super.key});

  @override
  State<AlgorithmComplexityScreen> createState() =>
      _AlgorithmComplexityScreenState();
}

class _AlgorithmComplexityScreenState extends State<AlgorithmComplexityScreen> {
  String _selectedCategory = 'Sorting';

  final Map<String, List<AlgorithmInfo>> _algorithms = {
    'Sorting': [
      AlgorithmInfo(
        name: 'Bubble Sort',
        bestTime: 'O(n)',
        averageTime: 'O(n²)',
        worstTime: 'O(n²)',
        space: 'O(1)',
        description:
            'Simple comparison-based sorting. Repeatedly swaps adjacent elements.',
        stable: true,
      ),
      AlgorithmInfo(
        name: 'Quick Sort',
        bestTime: 'O(n log n)',
        averageTime: 'O(n log n)',
        worstTime: 'O(n²)',
        space: 'O(log n)',
        description:
            'Divide-and-conquer algorithm. Uses pivot for partitioning.',
        stable: false,
      ),
      AlgorithmInfo(
        name: 'Merge Sort',
        bestTime: 'O(n log n)',
        averageTime: 'O(n log n)',
        worstTime: 'O(n log n)',
        space: 'O(n)',
        description:
            'Divide-and-conquer algorithm. Always divides array in half.',
        stable: true,
      ),
      AlgorithmInfo(
        name: 'Heap Sort',
        bestTime: 'O(n log n)',
        averageTime: 'O(n log n)',
        worstTime: 'O(n log n)',
        space: 'O(1)',
        description: 'Uses binary heap data structure. In-place sorting.',
        stable: false,
      ),
      AlgorithmInfo(
        name: 'Insertion Sort',
        bestTime: 'O(n)',
        averageTime: 'O(n²)',
        worstTime: 'O(n²)',
        space: 'O(1)',
        description: 'Builds final sorted array one item at a time.',
        stable: true,
      ),
      AlgorithmInfo(
        name: 'Selection Sort',
        bestTime: 'O(n²)',
        averageTime: 'O(n²)',
        worstTime: 'O(n²)',
        space: 'O(1)',
        description:
            'Repeatedly finds minimum element and places it at beginning.',
        stable: false,
      ),
    ],
    'Searching': [
      AlgorithmInfo(
        name: 'Linear Search',
        bestTime: 'O(1)',
        averageTime: 'O(n)',
        worstTime: 'O(n)',
        space: 'O(1)',
        description: 'Sequential search through all elements.',
        stable: true,
      ),
      AlgorithmInfo(
        name: 'Binary Search',
        bestTime: 'O(1)',
        averageTime: 'O(log n)',
        worstTime: 'O(log n)',
        space: 'O(1)',
        description: 'Divide-and-conquer search on sorted array.',
        stable: true,
      ),
      AlgorithmInfo(
        name: 'Jump Search',
        bestTime: 'O(1)',
        averageTime: 'O(√n)',
        worstTime: 'O(√n)',
        space: 'O(1)',
        description: 'Jumps ahead by fixed steps in sorted array.',
        stable: true,
      ),
      AlgorithmInfo(
        name: 'Interpolation Search',
        bestTime: 'O(1)',
        averageTime: 'O(log log n)',
        worstTime: 'O(n)',
        space: 'O(1)',
        description: 'Improved binary search for uniformly distributed data.',
        stable: true,
      ),
    ],
    'Data Structures': [
      AlgorithmInfo(
        name: 'Array Access',
        bestTime: 'O(1)',
        averageTime: 'O(1)',
        worstTime: 'O(1)',
        space: 'O(n)',
        description: 'Direct index access to elements.',
        stable: true,
      ),
      AlgorithmInfo(
        name: 'Linked List Insert',
        bestTime: 'O(1)',
        averageTime: 'O(1)',
        worstTime: 'O(1)',
        space: 'O(n)',
        description: 'Insert at head/tail is constant time.',
        stable: true,
      ),
      AlgorithmInfo(
        name: 'Stack Push/Pop',
        bestTime: 'O(1)',
        averageTime: 'O(1)',
        worstTime: 'O(1)',
        space: 'O(n)',
        description: 'LIFO operations are constant time.',
        stable: true,
      ),
      AlgorithmInfo(
        name: 'Queue Enqueue/Dequeue',
        bestTime: 'O(1)',
        averageTime: 'O(1)',
        worstTime: 'O(1)',
        space: 'O(n)',
        description: 'FIFO operations are constant time.',
        stable: true,
      ),
      AlgorithmInfo(
        name: 'BST Search',
        bestTime: 'O(log n)',
        averageTime: 'O(log n)',
        worstTime: 'O(n)',
        space: 'O(n)',
        description: 'Binary Search Tree lookup.',
        stable: true,
      ),
      AlgorithmInfo(
        name: 'Hash Table Search',
        bestTime: 'O(1)',
        averageTime: 'O(1)',
        worstTime: 'O(n)',
        space: 'O(n)',
        description: 'Direct key-based access.',
        stable: true,
      ),
    ],
    'Graph Algorithms': [
      AlgorithmInfo(
        name: 'BFS',
        bestTime: 'O(V+E)',
        averageTime: 'O(V+E)',
        worstTime: 'O(V+E)',
        space: 'O(V)',
        description: 'Breadth-First Search explores level by level.',
        stable: true,
      ),
      AlgorithmInfo(
        name: 'DFS',
        bestTime: 'O(V+E)',
        averageTime: 'O(V+E)',
        worstTime: 'O(V+E)',
        space: 'O(V)',
        description: 'Depth-First Search explores as deep as possible.',
        stable: true,
      ),
      AlgorithmInfo(
        name: 'Dijkstra\'s',
        bestTime: 'O((V+E) log V)',
        averageTime: 'O((V+E) log V)',
        worstTime: 'O((V+E) log V)',
        space: 'O(V)',
        description: 'Shortest path algorithm for weighted graphs.',
        stable: true,
      ),
      AlgorithmInfo(
        name: 'Floyd-Warshall',
        bestTime: 'O(V³)',
        averageTime: 'O(V³)',
        worstTime: 'O(V³)',
        space: 'O(V²)',
        description: 'All-pairs shortest path algorithm.',
        stable: true,
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Algorithm Complexity')),
      body: Column(
        children: [
          _buildInfoCard(),
          _buildCategorySelector(),
          Expanded(child: _buildAlgorithmsList()),
          _buildComplexityGuide(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Time and space complexity reference for common algorithms',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _algorithms.keys.map((category) {
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAlgorithmsList() {
    final algorithms = _algorithms[_selectedCategory] ?? [];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: algorithms.length,
      itemBuilder: (context, index) {
        final algo = algorithms[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _getComplexityColor(algo.averageTime),
              child: Text(
                algo.name.substring(0, 1),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            title: Text(
              algo.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Avg: ${algo.averageTime}',
              style: TextStyle(
                color: _getComplexityColor(algo.averageTime),
                fontWeight: FontWeight.w500,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      algo.description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),
                    _buildComplexityRow(
                      'Best Case',
                      algo.bestTime,
                      Icons.trending_down,
                      Colors.green,
                    ),
                    _buildComplexityRow(
                      'Average Case',
                      algo.averageTime,
                      Icons.trending_flat,
                      Colors.orange,
                    ),
                    _buildComplexityRow(
                      'Worst Case',
                      algo.worstTime,
                      Icons.trending_up,
                      Colors.red,
                    ),
                    _buildComplexityRow(
                      'Space',
                      algo.space,
                      Icons.storage,
                      Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          algo.stable ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: algo.stable ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          algo.stable ? 'Stable' : 'Not Stable',
                          style: TextStyle(
                            fontSize: 12,
                            color: algo.stable ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComplexityRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getComplexityColor(value).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getComplexityColor(value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getComplexityColor(String complexity) {
    if (complexity.contains('O(1)')) return Colors.green;
    if (complexity.contains('O(log') || complexity.contains('O(√n)')) {
      return Colors.lightGreen;
    }
    if (complexity.contains('O(n)') &&
        !complexity.contains('²') &&
        !complexity.contains('³')) {
      return Colors.blue;
    }
    if (complexity.contains('O(n log n)')) return Colors.orange;
    if (complexity.contains('O(n²)')) return Colors.deepOrange;
    if (complexity.contains('O(n³)') || complexity.contains('O(2')) {
      return Colors.red;
    }
    return Colors.grey;
  }

  Widget _buildComplexityGuide() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: ExpansionTile(
        leading: const Icon(Icons.help_outline, color: Colors.purple),
        title: const Text(
          'Complexity Guide',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGuideRow(
                  'O(1)',
                  'Constant',
                  Colors.green,
                  'Best - Direct access',
                ),
                _buildGuideRow(
                  'O(log n)',
                  'Logarithmic',
                  Colors.lightGreen,
                  'Excellent - Binary search',
                ),
                _buildGuideRow(
                  'O(n)',
                  'Linear',
                  Colors.blue,
                  'Good - Single pass',
                ),
                _buildGuideRow(
                  'O(n log n)',
                  'Linearithmic',
                  Colors.orange,
                  'Fair - Efficient sorting',
                ),
                _buildGuideRow(
                  'O(n²)',
                  'Quadratic',
                  Colors.deepOrange,
                  'Bad - Nested loops',
                ),
                _buildGuideRow(
                  'O(2ⁿ)',
                  'Exponential',
                  Colors.red,
                  'Horrible - Avoid!',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideRow(
    String notation,
    String name,
    Color color,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              notation,
              style: TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AlgorithmInfo {

  AlgorithmInfo({
    required this.name,
    required this.bestTime,
    required this.averageTime,
    required this.worstTime,
    required this.space,
    required this.description,
    required this.stable,
  });
  final String name;
  final String bestTime;
  final String averageTime;
  final String worstTime;
  final String space;
  final String description;
  final bool stable;
}
