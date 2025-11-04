import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:campus_mesh/services/chat_service.dart';
import 'package:campus_mesh/services/local_chat_database.dart';
import 'package:campus_mesh/services/auth_service.dart';

/// Screen for admins/teachers to manage chats
class ChatManagementScreen extends StatefulWidget {
  const ChatManagementScreen({super.key});

  @override
  State<ChatManagementScreen> createState() => _ChatManagementScreenState();
}

class _ChatManagementScreenState extends State<ChatManagementScreen> {
  final _chatService = ChatService();
  final _localDb = LocalChatDatabase();
  final _authService = AuthService();

  List<Map<String, dynamic>> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() => _isLoading = true);

    try {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        throw Exception('Not authenticated');
      }

      final chats = await _localDb.getUserChats(currentUserId);
      setState(() {
        _chats = chats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load chats: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleRestriction(Map<String, dynamic> chat) async {
    final chatId = chat['id'] as String;
    final isRestricted = (chat['is_restricted'] as int) == 1;

    // Show reason dialog if restricting
    String? reason;
    if (!isRestricted) {
      reason = await showDialog<String>(
        context: context,
        builder: (context) => _RestrictionReasonDialog(),
      );
      if (reason == null) return; // User cancelled
    }

    try {
      await _chatService.updateChatRestriction(
        chatId: chatId,
        isRestricted: !isRestricted,
        reason: reason,
      );

      await _loadChats();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isRestricted ? 'Chat unrestricted' : 'Chat restricted',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update restriction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showInviteCode(String inviteCode) {
    final url = _chatService.getChatInviteUrl(inviteCode);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              inviteCode,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Share this code or URL:',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            SelectableText(
              url,
              style: TextStyle(fontSize: 12, color: Colors.blue[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: inviteCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invite code copied to clipboard'),
                ),
              );
            },
            child: const Text('Copy Code'),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invite URL copied to clipboard')),
              );
            },
            child: const Text('Copy URL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Chats')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadChats,
              child: _chats.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No chats found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _chats.length,
                      itemBuilder: (context, index) {
                        final chat = _chats[index];
                        final isRestricted =
                            (chat['is_restricted'] as int) == 1;
                        final type = chat['type'] as String;
                        final name = chat['name'] as String?;
                        final inviteCode = chat['invite_code'] as String?;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  isRestricted ? Colors.red : Colors.blue,
                              child: Icon(
                                type == 'p2p' ? Icons.person : Icons.group,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              name ?? 'P2P Chat',
                              style: TextStyle(
                                decoration: isRestricted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  type == 'p2p'
                                      ? 'Direct Message'
                                      : 'Group Chat',
                                ),
                                if (isRestricted)
                                  Text(
                                    'Restricted: ${chat['restriction_reason'] ?? 'No reason'}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                if (inviteCode != null)
                                  Text(
                                    'Code: $inviteCode',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (inviteCode != null)
                                  IconButton(
                                    icon: const Icon(Icons.share),
                                    onPressed: () =>
                                        _showInviteCode(inviteCode),
                                    tooltip: 'Share invite',
                                  ),
                                IconButton(
                                  icon: Icon(
                                    isRestricted ? Icons.lock_open : Icons.lock,
                                  ),
                                  onPressed: () => _toggleRestriction(chat),
                                  tooltip:
                                      isRestricted ? 'Unrestrict' : 'Restrict',
                                ),
                              ],
                            ),
                            isThreeLine: isRestricted || inviteCode != null,
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

class _RestrictionReasonDialog extends StatefulWidget {
  @override
  State<_RestrictionReasonDialog> createState() =>
      _RestrictionReasonDialogState();
}

class _RestrictionReasonDialogState extends State<_RestrictionReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Restriction Reason'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Enter reason for restriction',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Restrict'),
        ),
      ],
    );
  }
}
