import 'package:flutter/material.dart';
import 'package:campus_mesh/models/notice_model.dart';
import 'package:campus_mesh/models/user_model.dart';
import 'package:campus_mesh/services/notice_service.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/screens/notices/notice_detail_screen.dart';
import 'package:campus_mesh/screens/notices/create_notice_screen.dart';

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  final _noticeService = NoticeService();
  final _authService = AuthService();
  final _searchController = TextEditingController();
  UserModel? _currentUser;
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.currentUser;
    if (mounted) {
      setState(() => _currentUser = user);
    }
  }

  Future<void> _handleRefresh() async {
    // Wait for the stream to update (simulate refresh)
    await Future.delayed(const Duration(milliseconds: 500));
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

  List<NoticeModel> _filterNotices(List<NoticeModel> notices) {
    if (_searchQuery.isEmpty) {
      return notices;
    }

    return notices.where((notice) {
      final titleMatch = notice.title.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      final contentMatch = notice.content.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      return titleMatch || contentMatch;
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
                  hintText: 'Search notices...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              )
            : const Text('Notices'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            tooltip: _isSearching ? 'Close search' : 'Search notices',
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
          if (_canCreateNotice && !_isSearching)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Create new notice',
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
            return _buildLoadingSkeleton();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final allNotices = snapshot.data ?? [];
          final notices = _filterNotices(allNotices);

          if (notices.isEmpty) {
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
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No notices yet',
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

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: notices.length,
              itemBuilder: (context, index) {
                final notice = notices[index];
                final color = _getNoticeColor(notice.type);
                final icon = _getNoticeIcon(notice.type);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 12,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
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
                  'Failed to load notices',
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
