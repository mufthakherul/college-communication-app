import 'package:flutter/material.dart';
import 'package:campus_mesh/models/message_model.dart';
import 'package:campus_mesh/models/user_model.dart';
import 'package:campus_mesh/services/message_service.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/screens/messages/new_conversation_screen.dart';
import 'package:campus_mesh/screens/messages/chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _messageService = MessageService();
  final _authService = AuthService();
  final _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  final Map<String, UserModel> _userCache = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    // Wait for the stream to update (simulate refresh)
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _startNewConversation() async {
    final selectedUser = await Navigator.of(context).push<UserModel>(
      MaterialPageRoute(builder: (context) => const NewConversationScreen()),
    );

    if (selectedUser != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatScreen(otherUser: selectedUser),
        ),
      );
    }
  }

  List<MessageModel> _filterMessages(List<MessageModel> messages) {
    if (_searchQuery.isEmpty) {
      return messages;
    }

    return messages.where((message) {
      final contentMatch = message.content.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      final recipientMatch = message.recipientId.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      return contentMatch || recipientMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search messages...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              )
            : const Text('Messages'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            tooltip: _isSearching ? 'Close search' : 'Search messages',
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          if (!_isSearching)
            StreamBuilder<int>(
              stream: _messageService.getUnreadCount(),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data ?? 0;
                if (unreadCount == 0) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Badge(
                      label: Text('$unreadCount'),
                      child: const Icon(Icons.mail),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewConversation,
        tooltip: 'Start new conversation',
        child: const Icon(Icons.add_comment),
      ),
      body: StreamBuilder<List<MessageModel>>(
        stream: _messageService.getRecentConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingSkeleton();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final allMessages = snapshot.data ?? [];
          final messages = _filterMessages(allMessages);

          if (messages.isEmpty) {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.message, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Pull down to refresh',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          // Group messages by conversation
          final Map<String, MessageModel> conversations = {};
          for (final message in messages) {
            final otherUserId = message.recipientId;
            if (!conversations.containsKey(otherUserId) ||
                (conversations[otherUserId]!.createdAt!.isBefore(
                      message.createdAt!,
                    ))) {
              conversations[otherUserId] = message;
            }
          }

          final conversationList = conversations.values.toList()
            ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.builder(
              itemCount: conversationList.length,
              itemBuilder: (context, index) {
                final message = conversationList[index];

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      message.recipientId.substring(0, 2).toUpperCase(),
                    ),
                  ),
                  title: Text(
                    message.recipientId,
                    style: TextStyle(
                      fontWeight:
                          message.read ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    message.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (message.createdAt != null)
                        Text(
                          _formatTime(message.createdAt!),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      if (!message.read)
                        const Icon(Icons.circle, size: 8, color: Colors.blue),
                    ],
                  ),
                  onTap: () async {
                    // Navigate to chat screen
                    final userId =
                        message.senderId == _authService.currentUserId
                            ? message.recipientId
                            : message.senderId;

                    // Get or fetch user info
                    UserModel? otherUser;
                    if (_userCache.containsKey(userId)) {
                      otherUser = _userCache[userId];
                    } else {
                      try {
                        otherUser = await _authService.getUserProfile(userId);
                        if (otherUser != null) {
                          _userCache[userId] = otherUser;
                        }
                      } catch (e) {
                        // Create a placeholder user if fetch fails
                        otherUser = UserModel(
                          uid: userId,
                          email: '',
                          displayName: userId.substring(0, 8),
                          role: UserRole.student,
                        );
                      }
                    }

                    if (otherUser != null && mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatScreen(otherUser: otherUser!),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: const SizedBox(),
          ),
          title: Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          subtitle: Container(
            margin: const EdgeInsets.only(top: 4),
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          trailing: Container(
            height: 12,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load messages',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Please check your internet connection and try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _handleRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Error Details'),
                        content: Text(error),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('View Details'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
