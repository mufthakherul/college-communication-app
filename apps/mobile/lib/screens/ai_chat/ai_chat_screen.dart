import 'package:flutter/material.dart';
import 'package:campus_mesh/services/ai_chatbot_service.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/models/ai_chat_message_model.dart';
import 'package:campus_mesh/models/ai_chat_session_model.dart';
import 'package:campus_mesh/screens/ai_chat/api_key_input_screen.dart';

class AIChatScreen extends StatefulWidget {
  final String? sessionId;

  const AIChatScreen({super.key, this.sessionId});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final _aiService = AIChatbotService();
  final _authService = AuthService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  List<AIChatMessage> _messages = [];
  AIChatSession? _session;
  bool _isLoading = false;
  bool _isSending = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);

    try {
      // Check if API key is configured
      final hasKey = await _aiService.hasApiKey();
      if (!hasKey) {
        // Show API key input screen
        if (mounted) {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const ApiKeyInputScreen(),
            ),
          );

          if (result != true) {
            // User didn't provide API key, go back
            if (mounted) Navigator.pop(context);
            return;
          }
        }
      }

      // Get current user ID
      await _authService.initialize();
      _currentUserId = _authService.currentUserId;

      if (_currentUserId == null) {
        throw Exception('User not logged in');
      }

      // Load or create session
      if (widget.sessionId != null) {
        _session = await _aiService.getSession(widget.sessionId!);
        if (_session != null) {
          _messages = await _aiService.getMessages(widget.sessionId!);
        }
      }

      if (_session == null) {
        _session = await _aiService.createSession(_currentUserId!);
      }

      setState(() => _isLoading = false);

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending || _session == null) return;

    setState(() => _isSending = true);
    _messageController.clear();

    // Create user message
    final userMessage = AIChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: _session!.id,
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Add to UI immediately
    setState(() {
      _messages.add(userMessage);
    });

    // Save to database
    await _aiService.saveMessage(userMessage);

    // Update session title if this is the first message
    if (_messages.length == 1) {
      final title = await _aiService.generateSessionTitle(text);
      await _aiService.updateSessionTitle(_session!.id, title);
      // Update local session object instead of re-fetching from database
      setState(() {
        _session = _session!.copyWith(title: title);
      });
    }

    // Scroll to bottom
    _scrollToBottom();

    try {
      // Get AI response
      final responseText = await _aiService.sendMessage(text, _session!.id);

      // Create AI message
      final aiMessage = AIChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: _session!.id,
        content: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      // Add to UI
      setState(() {
        _messages.add(aiMessage);
      });

      // Save to database
      await _aiService.saveMessage(aiMessage);

      // Scroll to bottom
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_session?.title ?? 'AI Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showDeleteConfirmation,
            tooltip: 'Delete Chat',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Messages list
                Expanded(
                  child: _messages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return _buildMessageBubble(_messages[index]);
                          },
                        ),
                ),

                // Sending indicator
                if (_isSending)
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'AI is thinking...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Input area
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Type your message...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            enabled: !_isSending,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _isSending ? null : _sendMessage,
                          color: Theme.of(context).primaryColor,
                          iconSize: 28,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
            'Start a conversation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AIChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).primaryColor
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: message.isUser
                    ? Colors.white.withOpacity(0.7)
                    : Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text(
          'Are you sure you want to delete this chat? This action cannot be undone.',
        ),
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

    if (result == true && _session != null) {
      await _aiService.deleteSession(_session!.id);
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate deletion
      }
    }
  }
}
