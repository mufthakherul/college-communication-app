import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../services/message_service.dart';
import '../../services/auth_service.dart';
import '../chat/chat_screen.dart';
import '../chat/new_chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _messageService = MessageService();
  final _authService = AuthService();
  final Map<String, UserModel> _userCache = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewChatScreen(),
            ),
          );
        },
        child: const Icon(Icons.edit),
      ),
      body: StreamBuilder<List<MessageModel>>(
        stream: _messageService.getRecentConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final messages = snapshot.data ?? [];

          if (messages.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.message, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Group messages by conversation
          final Map<String, MessageModel> conversations = {};
          for (final message in messages) {
            final otherUserId = message.recipientId;
            if (!conversations.containsKey(otherUserId) ||
                (conversations[otherUserId]!.createdAt!
                    .isBefore(message.createdAt!))) {
              conversations[otherUserId] = message;
            }
          }

          final conversationList = conversations.values.toList()
            ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

          return ListView.builder(
            itemCount: conversationList.length,
            itemBuilder: (context, index) {
              final message = conversationList[index];
              final currentUserId = FirebaseAuth.instance.currentUser?.uid;
              final otherUserId = message.senderId == currentUserId
                  ? message.recipientId
                  : message.senderId;
              final isUnread = message.recipientId == currentUserId && !message.read;

              return FutureBuilder<UserModel?>(
                future: _getUserInfo(otherUserId),
                builder: (context, userSnapshot) {
                  final userName = userSnapshot.data?.displayName ?? 'User';
                  final userInitials = userName.length >= 2
                      ? userName.substring(0, 2).toUpperCase()
                      : userName.substring(0, 1).toUpperCase();

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        userInitials,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      userName,
                      style: TextStyle(
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        if (message.senderId == currentUserId) ...[
                          Icon(
                            message.read ? Icons.done_all : Icons.done,
                            size: 14,
                            color: message.read ? Colors.blue : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            message.content,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (message.createdAt != null)
                          Text(
                            _formatTime(message.createdAt!),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                                ),
                          ),
                        if (isUnread) ...[
                          const SizedBox(height: 4),
                          StreamBuilder<int>(
                            stream: _messageService.getConversationUnreadCount(otherUserId),
                            builder: (context, unreadSnapshot) {
                              final unreadCount = unreadSnapshot.data ?? 0;
                              if (unreadCount == 0) return const SizedBox.shrink();
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  unreadCount > 99 ? '99+' : '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            recipientId: otherUserId,
                            recipientName: userName,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<UserModel?> _getUserInfo(String userId) async {
    if (_userCache.containsKey(userId)) {
      return _userCache[userId];
    }

    try {
      final user = await _authService.getUserProfile(userId);
      if (user != null) {
        _userCache[userId] = user;
      }
      return user;
    } catch (e) {
      return null;
    }
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
