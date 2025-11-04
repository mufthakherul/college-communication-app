import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CodeSnippetManagerScreen extends StatefulWidget {
  const CodeSnippetManagerScreen({super.key});

  @override
  State<CodeSnippetManagerScreen> createState() =>
      _CodeSnippetManagerScreenState();
}

class _CodeSnippetManagerScreenState extends State<CodeSnippetManagerScreen> {
  List<CodeSnippet> _snippets = [];
  String _selectedLanguage = 'All';
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _languages = [
    'All',
    'C',
    'C++',
    'Java',
    'Python',
    'JavaScript',
    'Dart',
    'PHP',
    'SQL',
    'HTML/CSS',
    'Kotlin',
    'Swift',
    'Go',
    'Rust',
  ];

  @override
  void initState() {
    super.initState();
    _loadSnippets();
  }

  Future<void> _loadSnippets() async {
    final prefs = await SharedPreferences.getInstance();
    final snippetsJson = prefs.getString('code_snippets');

    if (snippetsJson != null) {
      final List<dynamic> decoded = json.decode(snippetsJson);
      setState(() {
        _snippets = decoded.map((s) => CodeSnippet.fromJson(s)).toList();
        _isLoading = false;
      });
    } else {
      _loadDefaultSnippets();
    }
  }

  void _loadDefaultSnippets() {
    _snippets = [
      CodeSnippet(
        title: 'Hello World',
        language: 'C',
        code: '''#include <stdio.h>

int main() {
    printf("Hello, World!");
    return 0;
}''',
        description: 'Basic C program',
        tags: ['basic', 'beginner'],
      ),
      CodeSnippet(
        title: 'Bubble Sort',
        language: 'C',
        code: '''void bubbleSort(int arr[], int n) {
    for (int i = 0; i < n-1; i++) {
        for (int j = 0; j < n-i-1; j++) {
            if (arr[j] > arr[j+1]) {
                int temp = arr[j];
                arr[j] = arr[j+1];
                arr[j+1] = temp;
            }
        }
    }
}''',
        description: 'Bubble sort algorithm',
        tags: ['algorithm', 'sorting'],
      ),
      CodeSnippet(
        title: 'Linked List Node',
        language: 'C',
        code: '''struct Node {
    int data;
    struct Node* next;
};

struct Node* createNode(int data) {
    struct Node* newNode = (struct Node*)malloc(sizeof(struct Node));
    newNode->data = data;
    newNode->next = NULL;
    return newNode;
}''',
        description: 'Linked list node structure',
        tags: ['data-structure', 'linked-list'],
      ),
    ];
    setState(() => _isLoading = false);
    _saveSnippets();
  }

  Future<void> _saveSnippets() async {
    final prefs = await SharedPreferences.getInstance();
    final snippetsJson = json.encode(_snippets.map((s) => s.toJson()).toList());
    await prefs.setString('code_snippets', snippetsJson);
  }

  List<CodeSnippet> get _filteredSnippets {
    var filtered = _selectedLanguage == 'All'
        ? _snippets
        : _snippets.where((s) => s.language == _selectedLanguage).toList();

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (s) =>
                s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                s.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                s.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                s.tags.any(
                  (tag) =>
                      tag.toLowerCase().contains(_searchQuery.toLowerCase()),
                ),
          )
          .toList();
    }

    return filtered;
  }

  void _addSnippet() {
    showDialog(
      context: context,
      builder: (context) => _SnippetDialog(
        onSave: (snippet) {
          setState(() => _snippets.insert(0, snippet));
          _saveSnippets();
        },
        languages: _languages.where((l) => l != 'All').toList(),
      ),
    );
  }

  void _editSnippet(CodeSnippet snippet) {
    showDialog(
      context: context,
      builder: (context) => _SnippetDialog(
        snippet: snippet,
        languages: _languages.where((l) => l != 'All').toList(),
        onSave: (updated) {
          setState(() {
            final index = _snippets.indexOf(snippet);
            _snippets[index] = updated;
          });
          _saveSnippets();
        },
      ),
    );
  }

  void _deleteSnippet(CodeSnippet snippet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Snippet'),
        content: Text('Delete "${snippet.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _snippets.remove(snippet));
              _saveSnippets();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Code Snippets')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by title, description, or tags...',
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

                // Language Filter
                Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _languages.length,
                    itemBuilder: (context, index) {
                      final lang = _languages[index];
                      final isSelected = lang == _selectedLanguage;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(lang),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedLanguage = lang);
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Snippets List
                Expanded(
                  child: _filteredSnippets.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.code,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No snippets yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Tap + to add a code snippet',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredSnippets.length,
                          itemBuilder: (context, index) {
                            final snippet = _filteredSnippets[index];
                            return _buildSnippetCard(snippet);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSnippet,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSnippetCard(CodeSnippet snippet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            snippet.language.substring(0, 1),
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          snippet.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(snippet.description),
            if (snippet.tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: snippet.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 10)),
                        backgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.all(2),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editSnippet(snippet),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _deleteSnippet(snippet),
            ),
          ],
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[900],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Chip(
                      label: Text(
                        snippet.language,
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: Colors.blue[700],
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.white70),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: snippet.code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Code copied to clipboard'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SelectableText(
                  snippet.code,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CodeSnippet {
  String title;
  String language;
  String code;
  String description;
  List<String> tags;

  CodeSnippet({
    required this.title,
    required this.language,
    required this.code,
    required this.description,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'language': language,
    'code': code,
    'description': description,
    'tags': tags,
  };

  factory CodeSnippet.fromJson(Map<String, dynamic> json) => CodeSnippet(
    title: json['title'],
    language: json['language'],
    code: json['code'],
    description: json['description'],
    tags: List<String>.from(json['tags'] ?? []),
  );
}

class _SnippetDialog extends StatefulWidget {
  final CodeSnippet? snippet;
  final List<String> languages;
  final Function(CodeSnippet) onSave;

  const _SnippetDialog({
    this.snippet,
    required this.languages,
    required this.onSave,
  });

  @override
  State<_SnippetDialog> createState() => _SnippetDialogState();
}

class _SnippetDialogState extends State<_SnippetDialog> {
  late TextEditingController _titleController;
  late TextEditingController _codeController;
  late TextEditingController _descController;
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.snippet?.title ?? '');
    _codeController = TextEditingController(text: widget.snippet?.code ?? '');
    _descController = TextEditingController(
      text: widget.snippet?.description ?? '',
    );
    _selectedLanguage = widget.snippet?.language ?? widget.languages[0];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.snippet == null ? 'New Snippet' : 'Edit Snippet'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: const InputDecoration(
                labelText: 'Language',
                border: OutlineInputBorder(),
              ),
              items: widget.languages.map((lang) {
                return DropdownMenuItem(value: lang, child: Text(lang));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Code',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 10,
              style: const TextStyle(fontFamily: 'Courier'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty &&
                _codeController.text.isNotEmpty) {
              widget.onSave(
                CodeSnippet(
                  title: _titleController.text,
                  language: _selectedLanguage,
                  code: _codeController.text,
                  description: _descController.text,
                ),
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    _descController.dispose();
    super.dispose();
  }
}
