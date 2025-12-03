import 'package:campus_mesh/screens/ai_chat/ai_chat_history_screen.dart';
import 'package:campus_mesh/screens/tools/calculator_screen.dart';
import 'package:campus_mesh/screens/tools/notes_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    _tabController = TabController(length: 2, vsync: this);
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
          isScrollable: false,
          tabs: const [
            Tab(icon: Icon(Icons.star), text: 'All'),
            Tab(icon: Icon(Icons.apps), text: 'Utilities'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllToolsGrid(),
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
          'Calculator',
          Icons.calculate,
          Colors.blue,
          const CalculatorScreen(),
          'Utilities',
        ),
        _buildToolCard(
          context,
          'Quick Notes',
          Icons.note,
          Colors.amber,
          const NotesScreen(),
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
          'Calculator',
          Icons.calculate,
          Colors.blue,
          const CalculatorScreen(),
          'Utilities',
        ),
        _buildToolCard(
          context,
          'Quick Notes',
          Icons.note,
          Colors.amber,
          const NotesScreen(),
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

// Important Links screen
class ImportantLinksScreen extends StatelessWidget {
  const ImportantLinksScreen({super.key});

  Future<void> _launchURL(BuildContext context, String url) async {
    if (url == '#') {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This link is not yet configured'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

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
          final url = link['url']! as String;
          final isActive = url != '#';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(
                  link['icon']! as IconData,
                  color: isActive ? null : Colors.grey,
                ),
              ),
              title: Text(
                link['title']! as String,
                style: TextStyle(color: isActive ? null : Colors.grey),
              ),
              subtitle: Text(
                isActive ? url : 'Not available yet',
                style: TextStyle(
                  color: isActive ? Colors.grey : Colors.grey.shade400,
                ),
              ),
              trailing: Icon(
                Icons.open_in_new,
                color: isActive ? Colors.blue : Colors.grey,
              ),
              onTap: isActive ? () => _launchURL(context, url) : null,
            ),
          );
        },
      ),
    );
  }
}
