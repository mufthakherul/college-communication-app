import 'package:flutter/material.dart';
import 'package:campus_mesh/screens/tools/gpa_calculator_screen.dart';
import 'package:campus_mesh/screens/tools/study_timer_screen.dart';
import 'package:campus_mesh/screens/tools/assignment_tracker_screen.dart';
import 'package:campus_mesh/screens/tools/timetable_screen.dart';
import 'package:campus_mesh/screens/tools/events_screen.dart';
import 'package:campus_mesh/screens/tools/unit_converter_screen.dart';
import 'package:campus_mesh/screens/tools/notes_screen.dart';
import 'package:campus_mesh/screens/ai_chat/ai_chat_history_screen.dart';
import 'package:campus_mesh/screens/tools/calculator_screen.dart';
import 'package:campus_mesh/screens/tools/attendance_tracker_screen.dart';
import 'package:campus_mesh/screens/tools/exam_countdown_screen.dart';
import 'package:campus_mesh/screens/tools/expense_tracker_screen.dart';
import 'package:campus_mesh/screens/tools/dictionary_screen.dart';
import 'package:campus_mesh/screens/tools/periodic_table_screen.dart';
import 'package:campus_mesh/screens/tools/formula_sheet_screen.dart';
import 'package:campus_mesh/screens/tools/world_clock_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Tools')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildToolCard(
            context,
            'AI Chatbot',
            Icons.smart_toy,
            Colors.blue,
            const AIChatHistoryScreen(),
          ),
          _buildToolCard(
            context,
            'Calculator',
            Icons.calculate,
            Colors.deepPurple,
            const CalculatorScreen(),
          ),
          _buildToolCard(
            context,
            'Attendance',
            Icons.event_available,
            Colors.cyan,
            const AttendanceTrackerScreen(),
          ),
          _buildToolCard(
            context,
            'Exam Countdown',
            Icons.event_note,
            Colors.redAccent,
            const ExamCountdownScreen(),
          ),
          _buildToolCard(
            context,
            'Expense Tracker',
            Icons.account_balance_wallet,
            Colors.lightGreen,
            const ExpenseTrackerScreen(),
          ),
          _buildToolCard(
            context,
            'Dictionary',
            Icons.book,
            Colors.brown,
            const DictionaryScreen(),
          ),
          _buildToolCard(
            context,
            'Periodic Table',
            Icons.science,
            Colors.deepOrange,
            const PeriodicTableScreen(),
          ),
          _buildToolCard(
            context,
            'Assignments',
            Icons.assignment,
            Colors.blueAccent,
            const AssignmentTrackerScreen(),
          ),
          _buildToolCard(
            context,
            'Timetable',
            Icons.schedule,
            Colors.green,
            const TimetableScreen(),
          ),
          _buildToolCard(
            context,
            'Events',
            Icons.event,
            Colors.orange,
            const EventsScreen(),
          ),
          _buildToolCard(
            context,
            'GPA Calculator',
            Icons.school,
            Colors.purple,
            const GPACalculatorScreen(),
          ),
          _buildToolCard(
            context,
            'Study Timer',
            Icons.timer,
            Colors.teal,
            const StudyTimerScreen(),
          ),
          _buildToolCard(
            context,
            'Unit Converter',
            Icons.swap_horiz,
            Colors.pink,
            const UnitConverterScreen(),
          ),
          _buildToolCard(
            context,
            'Quick Notes',
            Icons.note,
            Colors.amber,
            const NotesScreen(),
          ),
          _buildToolCard(
            context,
            'Important Links',
            Icons.link,
            Colors.indigo,
            const ImportantLinksScreen(),
          ),
          _buildToolCard(
            context,
            'Formula Sheet',
            Icons.functions,
            Colors.teal,
            const FormulaSheetScreen(),
          ),
          _buildToolCard(
            context,
            'World Clock',
            Icons.public,
            Colors.blueGrey,
            const WorldClockScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget destination,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for Important Links screen
class ImportantLinksScreen extends StatelessWidget {
  const ImportantLinksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final links = [
      {
        'title': 'College Website',
        'url': 'https://rangpur.polytech.gov.bd',
        'icon': Icons.school,
      },
      {
        'title': 'BTEB Website',
        'url': 'https://www.bteb.gov.bd',
        'icon': Icons.business,
      },
      {'title': 'Library Portal', 'url': '#', 'icon': Icons.library_books},
      {'title': 'Student Portal', 'url': '#', 'icon': Icons.person},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Important Links')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: links.length,
        itemBuilder: (context, index) {
          final link = links[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(child: Icon(link['icon'] as IconData)),
              title: Text(link['title'] as String),
              subtitle: Text(link['url'] as String),
              trailing: const Icon(Icons.open_in_new),
              onTap: () {
                // Open URL
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening ${link['title']}...')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
