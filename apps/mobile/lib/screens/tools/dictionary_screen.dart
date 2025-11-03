import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchHistory = [];
  String? _selectedWord;
  Map<String, dynamic>? _definition;
  bool _isSearching = false;

  // Built-in dictionary with common words (expandable)
  final Map<String, Map<String, dynamic>> _dictionary = {
    'algorithm': {
      'definition': 'A step-by-step procedure for solving a problem or accomplishing a task, especially in computing.',
      'partOfSpeech': 'noun',
      'example': 'The sorting algorithm efficiently organized the data.',
      'synonyms': ['procedure', 'process', 'method'],
    },
    'programming': {
      'definition': 'The process of creating a set of instructions that tell a computer how to perform a task.',
      'partOfSpeech': 'noun',
      'example': 'She is learning programming to develop mobile apps.',
      'synonyms': ['coding', 'software development'],
    },
    'variable': {
      'definition': 'A storage location identified by a name that holds a value which can be changed during program execution.',
      'partOfSpeech': 'noun',
      'example': 'The variable x stores the user input.',
      'synonyms': ['placeholder', 'container'],
    },
    'function': {
      'definition': 'A reusable block of code that performs a specific task.',
      'partOfSpeech': 'noun',
      'example': 'The function calculates the sum of two numbers.',
      'synonyms': ['method', 'procedure', 'subroutine'],
    },
    'database': {
      'definition': 'An organized collection of structured information or data stored electronically.',
      'partOfSpeech': 'noun',
      'example': 'The database stores all student records.',
      'synonyms': ['data store', 'repository'],
    },
    'network': {
      'definition': 'A group of interconnected computers and devices that can share resources and communicate.',
      'partOfSpeech': 'noun',
      'example': 'The college network connects all campus computers.',
      'synonyms': ['system', 'grid', 'web'],
    },
    'technology': {
      'definition': 'The application of scientific knowledge for practical purposes, especially in industry.',
      'partOfSpeech': 'noun',
      'example': 'Technology has transformed education.',
      'synonyms': ['innovation', 'engineering', 'science'],
    },
    'education': {
      'definition': 'The process of receiving or giving systematic instruction, especially at a school or university.',
      'partOfSpeech': 'noun',
      'example': 'Education is the key to success.',
      'synonyms': ['learning', 'teaching', 'schooling'],
    },
    'study': {
      'definition': 'The devotion of time and attention to gaining knowledge of an academic subject.',
      'partOfSpeech': 'noun/verb',
      'example': 'I need to study for my exams.',
      'synonyms': ['learn', 'research', 'review'],
    },
    'knowledge': {
      'definition': 'Facts, information, and skills acquired through experience or education.',
      'partOfSpeech': 'noun',
      'example': 'Knowledge is power.',
      'synonyms': ['information', 'understanding', 'wisdom'],
    },
  };

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('dictionary_history') ?? [];
    setState(() => _searchHistory = history);
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('dictionary_history', _searchHistory);
  }

  void _searchWord(String word) {
    if (word.isEmpty) return;

    setState(() {
      _isSearching = true;
      _selectedWord = word.toLowerCase();
    });

    // Add to search history
    if (!_searchHistory.contains(word)) {
      _searchHistory.insert(0, word);
      if (_searchHistory.length > 20) {
        _searchHistory = _searchHistory.sublist(0, 20);
      }
      _saveSearchHistory();
    }

    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_dictionary.containsKey(_selectedWord)) {
        setState(() {
          _definition = _dictionary[_selectedWord];
          _isSearching = false;
        });
      } else {
        setState(() {
          _definition = null;
          _isSearching = false;
        });
      }
    });
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear search history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _searchHistory.clear());
              _saveSearchHistory();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dictionary'),
        actions: [
          if (_searchHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a word...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _selectedWord = null;
                            _definition = null;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: _searchWord,
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Content Area
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _selectedWord == null
                    ? _buildSearchHistory()
                    : _definition != null
                        ? _buildDefinitionView()
                        : _buildNotFoundView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory() {
    if (_searchHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Search for words',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Available: ${_dictionary.keys.length} words',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Recent Searches',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        ..._searchHistory.map((word) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.history),
                title: Text(word),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _searchController.text = word;
                  _searchWord(word);
                },
              ),
            )),
        const SizedBox(height: 16),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Available Words (${_dictionary.keys.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _dictionary.keys.map((word) {
            return ActionChip(
              label: Text(word),
              onPressed: () {
                _searchController.text = word;
                _searchWord(word);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDefinitionView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Word Header
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectedWord!.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Audio not available')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Part of Speech
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _definition!['partOfSpeech'],
              style: TextStyle(
                color: Colors.blue[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Definition
          const Text(
            'Definition',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _definition!['definition'],
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),

          // Example
          if (_definition!['example'] != null) ...[
            const Text(
              'Example',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                '"${_definition!['example']}"',
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Synonyms
          if (_definition!['synonyms'] != null &&
              (_definition!['synonyms'] as List).isNotEmpty) ...[
            const Text(
              'Synonyms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (_definition!['synonyms'] as List).map((syn) {
                return Chip(
                  label: Text(syn),
                  backgroundColor: Colors.green[50],
                  side: BorderSide(color: Colors.green[200]!),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotFoundView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Word not found',
              style: TextStyle(fontSize: 20, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              '"$_selectedWord" is not in the dictionary',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Available words:',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _dictionary.keys.take(5).map((word) {
                return ActionChip(
                  label: Text(word),
                  onPressed: () {
                    _searchController.text = word;
                    _searchWord(word);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
