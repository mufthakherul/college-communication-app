import 'package:flutter/material.dart';

class GPACalculatorScreen extends StatefulWidget {
  const GPACalculatorScreen({super.key});

  @override
  State<GPACalculatorScreen> createState() => _GPACalculatorScreenState();
}

class _GPACalculatorScreenState extends State<GPACalculatorScreen> {
  final List<CourseGrade> _courses = [];
  double? _calculatedGPA;

  void _addCourse() {
    setState(() {
      _courses.add(CourseGrade());
    });
  }

  void _removeCourse(int index) {
    setState(() {
      _courses.removeAt(index);
      _calculatedGPA = null;
    });
  }

  void _calculateGPA() {
    if (_courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one course')),
      );
      return;
    }

    double totalPoints = 0;
    double totalCredits = 0;

    for (final course in _courses) {
      if (course.credits > 0 && course.gradePoint != null) {
        totalPoints += course.credits * course.gradePoint!;
        totalCredits += course.credits;
      }
    }

    if (totalCredits > 0) {
      setState(() {
        _calculatedGPA = totalPoints / totalCredits;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GPA Calculator')),
      body: Column(
        children: [
          Expanded(
            child: _courses.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calculate, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Add courses to calculate GPA',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _courses.length,
                    itemBuilder: (context, index) {
                      return _buildCourseCard(index);
                    },
                  ),
          ),
          if (_calculatedGPA != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Your GPA',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _calculatedGPA!.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getGrade(_calculatedGPA!),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _addCourse,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Course'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _calculateGPA,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calculate'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(int index) {
    final course = _courses[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Course ${index + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeCourse(index),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Course Name',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                course.name = value;
                setState(() => _calculatedGPA = null);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Credits',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      course.credits = double.tryParse(value) ?? 0;
                      setState(() => _calculatedGPA = null);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<double>(
                    decoration: const InputDecoration(
                      labelText: 'Grade',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    initialValue: course.gradePoint,
                    items: const [
                      DropdownMenuItem(value: 4, child: Text('A+ (4.0)')),
                      DropdownMenuItem(value: 3.75, child: Text('A (3.75)')),
                      DropdownMenuItem(value: 3.5, child: Text('A- (3.5)')),
                      DropdownMenuItem(value: 3.25, child: Text('B+ (3.25)')),
                      DropdownMenuItem(value: 3, child: Text('B (3.0)')),
                      DropdownMenuItem(value: 2.75, child: Text('B- (2.75)')),
                      DropdownMenuItem(value: 2.5, child: Text('C+ (2.5)')),
                      DropdownMenuItem(value: 2.25, child: Text('C (2.25)')),
                      DropdownMenuItem(value: 2, child: Text('D (2.0)')),
                      DropdownMenuItem(value: 0, child: Text('F (0.0)')),
                    ],
                    onChanged: (value) {
                      course.gradePoint = value;
                      setState(() => _calculatedGPA = null);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getGrade(double gpa) {
    if (gpa >= 3.75) return 'Grade: A+';
    if (gpa >= 3.5) return 'Grade: A';
    if (gpa >= 3.25) return 'Grade: A-';
    if (gpa >= 3.0) return 'Grade: B+';
    if (gpa >= 2.75) return 'Grade: B';
    if (gpa >= 2.5) return 'Grade: B-';
    if (gpa >= 2.25) return 'Grade: C+';
    if (gpa >= 2.0) return 'Grade: C';
    return 'Grade: D';
  }
}

class CourseGrade {
  String name = '';
  double credits = 0;
  double? gradePoint;
}
