import 'package:flutter/material.dart';

class NoteTakingScreen extends StatefulWidget {
  const NoteTakingScreen({super.key});

  @override
  State<NoteTakingScreen> createState() => _NoteTakingScreenState();
}

class _NoteTakingScreenState extends State<NoteTakingScreen>
    with SingleTickerProviderStateMixin {
  final List<Note> _notes = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _addNote() {
    showDialog(
      context: context,
      builder: (context) => const CreateNoteDialog(),
    ).then((note) {
      if (note != null && mounted) {
        setState(() => _notes.insert(0, note));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note created!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _editNote(int index) {
    showDialog(
      context: context,
      builder: (context) => EditNoteDialog(note: _notes[index]),
    ).then((updatedNote) {
      if (updatedNote != null && mounted) {
        setState(() => _notes[index] = updatedNote);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Note updated!')));
      }
    });
  }

  void _deleteNote(int index) {
    final note = _notes[index];
    setState(() => _notes.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => setState(() => _notes.insert(index, note)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Taking'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'All Notes (${_notes.length})',
              icon: const Icon(Icons.note),
            ),
            const Tab(text: 'Tips', icon: Icon(Icons.lightbulb)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All notes tab
          if (_notes.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_outlined,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notes yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first note to get started',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return _buildNoteCard(note, index);
              },
            ),

          // Tips tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTipCard(
                  'Use Keywords',
                  'Focus on main ideas and keywords. This helps with quick review and memorization.',
                  Icons.key,
                ),
                _buildTipCard(
                  'Organized Structure',
                  'Use headings, bullet points, and numbering to organize information logically.',
                  Icons.list,
                ),
                _buildTipCard(
                  'Add Examples',
                  'Include practical examples and case studies to make concepts clearer.',
                  Icons.lightbulb,
                ),
                _buildTipCard(
                  'Use Colors & Formatting',
                  'Highlight important points. This makes notes easier to scan and remember.',
                  Icons.format_color_fill,
                ),
                _buildTipCard(
                  'Review Regularly',
                  'Review your notes frequently to reinforce learning and identify gaps.',
                  Icons.refresh,
                ),
                _buildTipCard(
                  'Date Your Notes',
                  'Always include the date. This helps track your learning progress over time.',
                  Icons.calendar_today,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoteCard(Note note, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _editNote(index),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Edit'),
                        onTap: () => _editNote(index),
                      ),
                      PopupMenuItem(
                        child: const Text('Delete'),
                        onTap: () => _deleteNote(index),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: note.category.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      note.category.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: note.category.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(note.date),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(String title, String description, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Icon(icon, color: Colors.blue[700])),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    }

    return '${date.day}/${date.month}/${date.year}';
  }
}

class Note {
  Note({
    required this.title,
    required this.content,
    required this.category,
    required this.date,
  });
  final String title;
  final String content;
  final NoteCategory category;
  final DateTime date;
}

enum NoteCategory {
  lecture('Lecture', Color(0xFF6366F1)),
  todo('To-Do', Color(0xFFEC4899)),
  important('Important', Color(0xFFDC2626)),
  reference('Reference', Color(0xFF059669)),
  other('Other', Color(0xFF78716C));

  final String label;
  final Color color;

  const NoteCategory(this.label, this.color);
}

class CreateNoteDialog extends StatefulWidget {
  const CreateNoteDialog({super.key});

  @override
  State<CreateNoteDialog> createState() => _CreateNoteDialogState();
}

class _CreateNoteDialogState extends State<CreateNoteDialog> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  NoteCategory selectedCategory = NoteCategory.lecture;

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Note'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                hintText: 'Note title',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
                hintText: 'Write your note...',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<NoteCategory>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: NoteCategory.values
                  .map(
                    (cat) =>
                        DropdownMenuItem(value: cat, child: Text(cat.label)),
                  )
                  .toList(),
              onChanged: (cat) => setState(() => selectedCategory = cat!),
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
            if (titleController.text.isEmpty ||
                contentController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill all fields')),
              );
              return;
            }

            Navigator.pop(
              context,
              Note(
                title: titleController.text,
                content: contentController.text,
                category: selectedCategory,
                date: DateTime.now(),
              ),
            );
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class EditNoteDialog extends StatefulWidget {
  const EditNoteDialog({super.key, required this.note});
  final Note note;

  @override
  State<EditNoteDialog> createState() => _EditNoteDialogState();
}

class _EditNoteDialogState extends State<EditNoteDialog> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  late NoteCategory selectedCategory;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.title);
    contentController = TextEditingController(text: widget.note.content);
    selectedCategory = widget.note.category;
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Note'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<NoteCategory>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: NoteCategory.values
                  .map(
                    (cat) =>
                        DropdownMenuItem(value: cat, child: Text(cat.label)),
                  )
                  .toList(),
              onChanged: (cat) => setState(() => selectedCategory = cat!),
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
            if (titleController.text.isEmpty ||
                contentController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill all fields')),
              );
              return;
            }

            Navigator.pop(
              context,
              Note(
                title: titleController.text,
                content: contentController.text,
                category: selectedCategory,
                date: widget.note.date,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
