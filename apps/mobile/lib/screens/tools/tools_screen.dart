import 'package:campus_mesh/screens/ai_chat/ai_chat_history_screen.dart';
import 'package:campus_mesh/screens/tools/algorithm_complexity_screen.dart';
import 'package:campus_mesh/screens/tools/ascii_table_screen.dart';
import 'package:campus_mesh/screens/tools/assignment_tracker_screen.dart';
import 'package:campus_mesh/screens/tools/attendance_tracker_screen.dart';
import 'package:campus_mesh/screens/tools/base64_converter_screen.dart';
import 'package:campus_mesh/screens/tools/binary_converter_screen.dart';
import 'package:campus_mesh/screens/tools/calculator_screen.dart';
import 'package:campus_mesh/screens/tools/code_snippet_manager_screen.dart';
import 'package:campus_mesh/screens/tools/color_picker_screen.dart';
import 'package:campus_mesh/screens/tools/dictionary_screen.dart';
import 'package:campus_mesh/screens/tools/events_screen.dart';
import 'package:campus_mesh/screens/tools/exam_countdown_screen.dart';
import 'package:campus_mesh/screens/tools/expense_tracker_screen.dart';
import 'package:campus_mesh/screens/tools/formula_sheet_screen.dart';
import 'package:campus_mesh/screens/tools/gpa_calculator_screen.dart';
import 'package:campus_mesh/screens/tools/hash_generator_screen.dart';
import 'package:campus_mesh/screens/tools/ip_calculator_screen.dart';
import 'package:campus_mesh/screens/tools/json_formatter_screen.dart';
import 'package:campus_mesh/screens/tools/notes_screen.dart';
import 'package:campus_mesh/screens/tools/periodic_table_screen.dart';
import 'package:campus_mesh/screens/tools/regex_tester_screen.dart';
import 'package:campus_mesh/screens/tools/study_timer_screen.dart';
import 'package:campus_mesh/screens/tools/timetable_screen.dart';
import 'package:campus_mesh/screens/tools/unit_converter_screen.dart';
import 'package:campus_mesh/screens/tools/world_clock_screen.dart';
import 'package:flutter/material.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
        title: const Text('Student Tools'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.star), text: 'All'),
            Tab(icon: Icon(Icons.computer), text: 'CST'),
            Tab(icon: Icon(Icons.school), text: 'Academic'),
            Tab(icon: Icon(Icons.access_time), text: 'Productivity'),
            Tab(icon: Icon(Icons.apps), text: 'Utilities'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllToolsGrid(),
          _buildCSTToolsGrid(),
          _buildAcademicToolsGrid(),
          _buildProductivityToolsGrid(),
          _buildUtilitiesGrid(),
        ],
      ),
    );
  }

  Widget _buildAllToolsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        // CST Tools
        _buildToolCard(
          context,
          'Binary Converter',
          Icons.transform,
          Colors.teal,
          const BinaryConverterScreen(),
          'CST',
        ),
        _buildToolCard(
          context,
          'ASCII Table',
          Icons.grid_on,
          Colors.indigo,
          const ASCIITableScreen(),
          'CST',
        ),
        _buildToolCard(
          context,
          'Code Snippets',
          Icons.code,
          Colors.deepPurple,
          const CodeSnippetManagerScreen(),
          'CST',
        ),
        _buildToolCard(
          context,
          'IP Calculator',
          Icons.router,
          Colors.blueGrey,
          const IPCalculatorScreen(),
          'CST',
        ),
        _buildToolCard(
          context,
          'Regex Tester',
          Icons.find_in_page,
          Colors.green,
          const RegexTesterScreen(),
          'CST',
        ),
        _buildToolCard(
          context,
          'JSON Formatter',
          Icons.data_object,
          Colors.amber,
          const JSONFormatterScreen(),
          'CST',
        ),
        _buildToolCard(
          context,
          'Hash Generator',
          Icons.fingerprint,
          Colors.red,
          const HashGeneratorScreen(),
          'CST',
        ),
        _buildToolCard(
          context,
          'Base64 Encoder',
          Icons.transform,
          Colors.cyan,
          const Base64ConverterScreen(),
          'CST',
        ),
        _buildToolCard(
          context,
          'Color Picker',
          Icons.palette,
          Colors.pink,
          const ColorPickerScreen(),
          'CST',
        ),
        _buildToolCard(
          context,
          'Algorithm Complexity',
          Icons.analytics,
          Colors.purple,
          const AlgorithmComplexityScreen(),
          'CST',
        ),
        // Academic Tools
        _buildToolCard(
          context,
          'Calculator',
          Icons.calculate,
          Colors.blue,
          const CalculatorScreen(),
          'Academic',
        ),
        _buildToolCard(
          context,
          'Dictionary',
          Icons.book,
          Colors.brown,
          const DictionaryScreen(),
          'Academic',
        ),
        _buildToolCard(
          context,
          'Periodic Table',
          Icons.science,
          Colors.deepOrange,
          const PeriodicTableScreen(),
          'Academic',
        ),
        _buildToolCard(
          context,
          'Formula Sheet',
          Icons.functions,
          Colors.purple,
          const FormulaSheetScreen(),
          'Academic',
        ),
        _buildToolCard(
          context,
          'GPA Calculator',
          Icons.school,
          Colors.indigo,
          const GPACalculatorScreen(),
          'Academic',
        ),
        // Productivity Tools
        _buildToolCard(
          context,
          'Attendance',
          Icons.event_available,
          Colors.cyan,
          const AttendanceTrackerScreen(),
          'Productivity',
        ),
        _buildToolCard(
          context,
          'Exam Countdown',
          Icons.event_note,
          Colors.redAccent,
          const ExamCountdownScreen(),
          'Productivity',
        ),
        _buildToolCard(
          context,
          'Assignments',
          Icons.assignment,
          Colors.blueAccent,
          const AssignmentTrackerScreen(),
          'Productivity',
        ),
        _buildToolCard(
          context,
          'Timetable',
          Icons.schedule,
          Colors.green,
          const TimetableScreen(),
          'Productivity',
        ),
        _buildToolCard(
          context,
          'Events',
          Icons.event,
          Colors.orange,
          const EventsScreen(),
          'Productivity',
        ),
        _buildToolCard(
          context,
          'Study Timer',
          Icons.timer,
          Colors.teal,
          const StudyTimerScreen(),
          'Productivity',
        ),
        _buildToolCard(
          context,
          'Quick Notes',
          Icons.note,
          Colors.amber,
          const NotesScreen(),
          'Productivity',
        ),
        // Utility Tools
        _buildToolCard(
          context,
          'AI Chatbot',
          Icons.smart_toy,
          Colors.blue,
          const AIChatHistoryScreen(),
          'Utilities',
        ),
        _buildToolCard(
          context,
          'Expense Tracker',
          Icons.account_balance_wallet,
          Colors.lightGreen,
          const ExpenseTrackerScreen(),
          'Utilities',
        ),
        _buildToolCard(
          context,
          'Unit Converter',
          Icons.swap_horiz,
          Colors.pink,
          const UnitConverterScreen(),
          'Utilities',
        ),
        _buildToolCard(
          context,
          'World Clock',
          Icons.public,
          Colors.blueGrey,
          const WorldClockScreen(),
          'Utilities',
        ),
        _buildToolCard(
          context,
          'Important Links',
          Icons.link,
          Colors.indigo,
          const ImportantLinksScreen(),
          'Utilities',
        ),
      ],
    );
  }

  Widget _buildCSTToolsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildToolCard(
          context,
          'Binary Converter',
          Icons.transform,
          Colors.teal,
          const BinaryConverterScreen(),
          'CST',
        ),
        _buildToolCard(
          context,
          'ASCII Table',
          Icons.grid_on,
          Colors.indigo,
          const ASCIITableScreen(),
          'CST',
        ),
        _buildToolCard(
          context,
          'Code Snippets',
          Icons.code,
          Colors.deepPurple,
          const CodeSnippetManagerScreen(),
          'CST',
        ),
        _buildToolCard(
          context,
          'IP Calculator',
          Icons.router,
          Colors.blueGrey,
          const IPCalculatorScreen(),
          'CST',
        ),
        _buildToolCard(
          context,
          'Regex Tester',
          Icons.find_in_page,
          Colors.green,
          const RegexTesterScreen(),
          'CST',
        ),
        _buildToolCard(
          context,
          'JSON Formatter',
          Icons.data_object,
          Colors.amber,
          const JSONFormatterScreen(),
          'CST',
        ),
        _buildToolCard(
          context,
          'Hash Generator',
          Icons.fingerprint,
          Colors.red,
          const HashGeneratorScreen(),
          'CST',
        ),
        _buildToolCard(
          context,
          'Base64 Encoder',
          Icons.transform,
          Colors.cyan,
          const Base64ConverterScreen(),
          'CST',
        ),
        _buildToolCard(
          context,
          'Color Picker',
          Icons.palette,
          Colors.pink,
          const ColorPickerScreen(),
          'CST',
        ),
        _buildToolCard(
          context,
          'Calculator',
          Icons.calculate,
          Colors.blue,
          const CalculatorScreen(),
          'CST',
        ),
        _buildToolCard(
          context,
          'Unit Converter',
          Icons.swap_horiz,
          Colors.pink,
          const UnitConverterScreen(),
          'CST',
        ),
        _buildToolCard(
          context,
          'Algorithm Complexity',
          Icons.analytics,
          Colors.purple,
          const AlgorithmComplexityScreen(),
          'CST',
        ),
      ],
    );
  }

  Widget _buildAcademicToolsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildToolCard(
          context,
          'Calculator',
          Icons.calculate,
          Colors.blue,
          const CalculatorScreen(),
          'Academic',
        ),
        _buildToolCard(
          context,
          'Dictionary',
          Icons.book,
          Colors.brown,
          const DictionaryScreen(),
          'Academic',
        ),
        _buildToolCard(
          context,
          'Periodic Table',
          Icons.science,
          Colors.deepOrange,
          const PeriodicTableScreen(),
          'Academic',
        ),
        _buildToolCard(
          context,
          'Formula Sheet',
          Icons.functions,
          Colors.purple,
          const FormulaSheetScreen(),
          'Academic',
        ),
        _buildToolCard(
          context,
          'GPA Calculator',
          Icons.school,
          Colors.indigo,
          const GPACalculatorScreen(),
          'Academic',
        ),
      ],
    );
  }

  Widget _buildProductivityToolsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildToolCard(
          context,
          'Attendance',
          Icons.event_available,
          Colors.cyan,
          const AttendanceTrackerScreen(),
          'Productivity',
        ),
        _buildToolCard(
          context,
          'Exam Countdown',
          Icons.event_note,
          Colors.redAccent,
          const ExamCountdownScreen(),
          'Productivity',
        ),
        _buildToolCard(
          context,
          'Assignments',
          Icons.assignment,
          Colors.blueAccent,
          const AssignmentTrackerScreen(),
          'Productivity',
        ),
        _buildToolCard(
          context,
          'Timetable',
          Icons.schedule,
          Colors.green,
          const TimetableScreen(),
          'Productivity',
        ),
        _buildToolCard(
          context,
          'Events',
          Icons.event,
          Colors.orange,
          const EventsScreen(),
          'Productivity',
        ),
        _buildToolCard(
          context,
          'Study Timer',
          Icons.timer,
          Colors.teal,
          const StudyTimerScreen(),
          'Productivity',
        ),
        _buildToolCard(
          context,
          'Quick Notes',
          Icons.note,
          Colors.amber,
          const NotesScreen(),
          'Productivity',
        ),
      ],
    );
  }

  Widget _buildUtilitiesGrid() {
    return GridView.count(
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
          'Utilities',
        ),
        _buildToolCard(
          context,
          'Expense Tracker',
          Icons.account_balance_wallet,
          Colors.lightGreen,
          const ExpenseTrackerScreen(),
          'Utilities',
        ),
        _buildToolCard(
          context,
          'Unit Converter',
          Icons.swap_horiz,
          Colors.pink,
          const UnitConverterScreen(),
          'Utilities',
        ),
        _buildToolCard(
          context,
          'World Clock',
          Icons.public,
          Colors.blueGrey,
          const WorldClockScreen(),
          'Utilities',
        ),
        _buildToolCard(
          context,
          'Important Links',
          Icons.link,
          Colors.indigo,
          const ImportantLinksScreen(),
          'Utilities',
        ),
      ],
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget destination,
    String category,
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
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (category.isNotEmpty) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
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
              leading: CircleAvatar(child: Icon(link['icon']! as IconData)),
              title: Text(link['title']! as String),
              subtitle: Text(link['url']! as String),
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
