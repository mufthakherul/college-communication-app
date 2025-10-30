import 'package:flutter/material.dart';
import '../../models/message_model.dart';
import '../../services/message_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _messageService = MessageService();

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

              return ListTile(
                leading: CircleAvatar(
                  child: Text(message.recipientId.substring(0, 2).toUpperCase()),
                ),
                title: Text(
                  message.recipientId,
                  style: TextStyle(
                    fontWeight: message.read ? FontWeight.normal : FontWeight.bold,
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
                onTap: () {
                  // Navigate to chat screen
                  // TODO: Implement chat screen navigation
                },
              );
            },
          );
        },
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
