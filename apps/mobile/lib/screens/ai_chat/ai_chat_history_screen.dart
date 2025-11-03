import 'package:flutter/material.dart';
import 'package:campus_mesh/services/ai_chatbot_service.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/models/ai_chat_session_model.dart';
import 'package:campus_mesh/screens/ai_chat/ai_chat_screen.dart';
import 'package:campus_mesh/screens/ai_chat/api_key_input_screen.dart';

class AIChatHistoryScreen extends StatefulWidget {
  const AIChatHistoryScreen({super.key});

  @override
  State<AIChatHistoryScreen> createState() => _AIChatHistoryScreenState();
}

class _AIChatHistoryScreenState extends State<AIChatHistoryScreen> {
  final _aiService = AIChatbotService();
  final _authService = AuthService();

  List<AIChatSession> _sessions = [];
  bool _isLoading = true;
  bool _hasApiKey = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);

    try {
      // Check if API key is configured
      _hasApiKey = await _aiService.hasApiKey();

      // Get current user ID
      await _authService.initialize();
      _currentUserId = _authService.currentUserId;

      if (_currentUserId != null) {
        // Load chat sessions
        _sessions = await _aiService.getSessions(_currentUserId!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading chats: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startNewChat() async {
    if (!_hasApiKey) {
      // Show API key input screen
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const ApiKeyInputScreen(),
        ),
      );

      if (result != true) return;
      
      setState(() => _hasApiKey = true);
    }

    // Navigate to new chat
    if (mounted) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AIChatScreen(),
        ),
      );

      if (result != null) {
        // Refresh list
        _initialize();
      }
    }
  }

  Future<void> _openChat(AIChatSession session) async {
    if (!_hasApiKey) {
      // Show API key input screen
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const ApiKeyInputScreen(),
        ),
      );

      if (result != true) return;
      
      setState(() => _hasApiKey = true);
    }

    // Navigate to existing chat
    if (mounted) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AIChatScreen(sessionId: session.id),
        ),
      );

      if (result != null) {
        // Refresh list
        _initialize();
      }
    }
  }

  Future<void> _deleteSession(AIChatSession session) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: Text('Delete "${session.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _aiService.deleteSession(session.id);
      _initialize();
    }
  }

  Future<void> _manageApiKey() async {
    if (_hasApiKey) {
      // Show option to change or remove API key
      final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('API Key Settings'),
          content: const Text('What would you like to do?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'change'),
              child: const Text('Change Key'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'remove'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove Key'),
            ),
          ],
        ),
      );

      if (result == 'change') {
        final success = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => const ApiKeyInputScreen(),
          ),
        );
        if (success == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('API key updated')),
          );
        }
      } else if (result == 'remove') {
        await _aiService.clearApiKey();
        setState(() => _hasApiKey = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API key removed')),
        );
      }
    } else {
      // Add API key
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const ApiKeyInputScreen(),
        ),
      );

      if (result == true) {
        setState(() => _hasApiKey = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API key added')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chatbot'),
        actions: [
          IconButton(
            icon: Icon(_hasApiKey ? Icons.vpn_key : Icons.vpn_key_off),
            onPressed: _manageApiKey,
            tooltip: _hasApiKey ? 'Manage API Key' : 'Add API Key',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startNewChat,
        icon: const Icon(Icons.add),
        label: const Text('New Chat'),
      ),
    );
  }

  Widget _buildBody() {
    if (!_hasApiKey) {
      return _buildNoApiKeyState();
    }

    if (_sessions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _initialize,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sessions.length,
        itemBuilder: (context, index) {
          return _buildSessionCard(_sessions[index]);
        },
      ),
    );
  }

  Widget _buildNoApiKeyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.vpn_key_off,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'API Key Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'You need to provide your Gemini API key to use the AI chatbot.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _manageApiKey,
              icon: const Icon(Icons.vpn_key),
              label: const Text('Add API Key'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.smart_toy,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Chats Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a new conversation with AI',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(AIChatSession session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
          child: Icon(
            Icons.smart_toy,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          session.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${session.messageCount} messages • ${_formatDate(session.lastMessageAt)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _deleteSession(session),
          color: Colors.red,
        ),
        onTap: () => _openChat(session),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
