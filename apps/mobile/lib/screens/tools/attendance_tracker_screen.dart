import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AttendanceTrackerScreen extends StatefulWidget {
  const AttendanceTrackerScreen({super.key});

  @override
  State<AttendanceTrackerScreen> createState() => _AttendanceTrackerScreenState();
}

class _AttendanceTrackerScreenState extends State<AttendanceTrackerScreen> {
  List<Subject> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final subjectsJson = prefs.getString('attendance_subjects');
    
    if (subjectsJson != null) {
      final List<dynamic> decoded = json.decode(subjectsJson);
      setState(() {
        _subjects = decoded.map((s) => Subject.fromJson(s)).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final subjectsJson = json.encode(_subjects.map((s) => s.toJson()).toList());
    await prefs.setString('attendance_subjects', subjectsJson);
  }

  void _addSubject() {
    final nameController = TextEditingController();
    final totalController = TextEditingController(text: '60');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subject'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Subject Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: totalController,
              decoration: const InputDecoration(
                labelText: 'Total Classes (optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _subjects.add(Subject(
                    name: nameController.text,
                    attended: 0,
                    total: int.tryParse(totalController.text) ?? 0,
                  ));
                });
                _saveSubjects();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _markAttendance(Subject subject, bool present) {
    setState(() {
      if (present) {
        subject.attended++;
      }
      subject.total++;
    });
    _saveSubjects();
  }

  void _editSubject(Subject subject) {
    final nameController = TextEditingController(text: subject.name);
    final attendedController = TextEditingController(text: subject.attended.toString());
    final totalController = TextEditingController(text: subject.total.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Subject'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Subject Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: attendedController,
              decoration: const InputDecoration(
                labelText: 'Classes Attended',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: totalController,
              decoration: const InputDecoration(
                labelText: 'Total Classes',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                subject.name = nameController.text;
                subject.attended = int.tryParse(attendedController.text) ?? 0;
                subject.total = int.tryParse(totalController.text) ?? 0;
              });
              _saveSubjects();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteSubject(Subject subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete ${subject.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _subjects.remove(subject));
              _saveSubjects();
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 75) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Tracker'),
        actions: [
          if (_subjects.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                final overall = _calculateOverallAttendance();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Overall Attendance'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${overall.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: _getPercentageColor(overall),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Total Classes: ${_subjects.fold(0, (sum, s) => sum + s.total)}',
                        ),
                        Text(
                          'Attended: ${_subjects.fold(0, (sum, s) => sum + s.attended)}',
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subjects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_available, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'No subjects added yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap + to add a subject',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) {
                    final subject = _subjects[index];
                    final percentage = subject.total > 0
                        ? (subject.attended / subject.total * 100)
                        : 0.0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    subject.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: _getPercentageColor(percentage),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Attended: ${subject.attended} / ${subject.total}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: subject.total > 0 ? subject.attended / subject.total : 0,
                              backgroundColor: Colors.grey[200],
                              color: _getPercentageColor(percentage),
                              minHeight: 8,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _markAttendance(subject, true),
                                    icon: const Icon(Icons.check, color: Colors.green),
                                    label: const Text('Present'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.green,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _markAttendance(subject, false),
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    label: const Text('Absent'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _editSubject(subject),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit'),
                                ),
                                TextButton.icon(
                                  onPressed: () => _deleteSubject(subject),
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('Delete'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSubject,
        child: const Icon(Icons.add),
      ),
    );
  }

  double _calculateOverallAttendance() {
    if (_subjects.isEmpty) return 0;
    final totalClasses = _subjects.fold(0, (sum, s) => sum + s.total);
    final attendedClasses = _subjects.fold(0, (sum, s) => sum + s.attended);
    return totalClasses > 0 ? (attendedClasses / totalClasses * 100) : 0;
  }
}

class Subject {
  String name;
  int attended;
  int total;

  Subject({
    required this.name,
    required this.attended,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'attended': attended,
        'total': total,
      };

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        name: json['name'],
        attended: json['attended'],
        total: json['total'],
      );
}
