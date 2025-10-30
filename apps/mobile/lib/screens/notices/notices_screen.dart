import 'package:flutter/material.dart';
import '../../models/notice_model.dart';
import '../../models/user_model.dart';
import '../../services/notice_service.dart';
import '../../services/auth_service.dart';
import 'notice_detail_screen.dart';
import 'create_notice_screen.dart';

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  final _noticeService = NoticeService();
  final _authService = AuthService();
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = _authService.currentUser;
    if (user != null) {
      final profile = await _authService.getUserProfile(user.uid);
      if (mounted) {
        setState(() => _currentUser = profile);
      }
    }
  }

  bool get _canCreateNotice {
    return _currentUser?.role == UserRole.admin ||
        _currentUser?.role == UserRole.teacher;
  }

  Color _getNoticeColor(NoticeType type) {
    switch (type) {
      case NoticeType.urgent:
        return Colors.red;
      case NoticeType.event:
        return Colors.blue;
      case NoticeType.announcement:
      default:
        return Colors.green;
    }
  }

  IconData _getNoticeIcon(NoticeType type) {
    switch (type) {
      case NoticeType.urgent:
        return Icons.warning;
      case NoticeType.event:
        return Icons.event;
      case NoticeType.announcement:
      default:
        return Icons.announcement;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notices'),
        actions: [
          if (_canCreateNotice)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateNoticeScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: StreamBuilder<List<NoticeModel>>(
        stream: _noticeService.getNotices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final notices = snapshot.data ?? [];

          if (notices.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No notices yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final notice = notices[index];
              final color = _getNoticeColor(notice.type);
              final icon = _getNoticeIcon(notice.type);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.2),
                    child: Icon(icon, color: color),
                  ),
                  title: Text(
                    notice.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        notice.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (notice.createdAt != null)
                        Text(
                          _formatDate(notice.createdAt!),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            NoticeDetailScreen(noticeId: notice.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
