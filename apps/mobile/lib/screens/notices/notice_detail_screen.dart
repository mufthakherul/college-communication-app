import 'package:flutter/material.dart';
import '../../models/notice_model.dart';
import '../../services/notice_service.dart';

class NoticeDetailScreen extends StatelessWidget {
  final String noticeId;

  const NoticeDetailScreen({
    super.key,
    required this.noticeId,
  });

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

  @override
  Widget build(BuildContext context) {
    final noticeService = NoticeService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice Details'),
      ),
      body: FutureBuilder<NoticeModel?>(
        future: noticeService.getNotice(noticeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final notice = snapshot.data;
          if (notice == null) {
            return const Center(
              child: Text('Notice not found'),
            );
          }

          final color = _getNoticeColor(notice.type);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: color.withOpacity(0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Chip(
                        label: Text(
                          notice.type.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: color,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notice.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      if (notice.createdAt != null)
                        Text(
                          _formatDate(notice.createdAt!),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notice.content,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      if (notice.expiresAt != null) ...[
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.schedule),
                          title: const Text('Expires At'),
                          subtitle: Text(_formatDate(notice.expiresAt!)),
                        ),
                      ],
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.group),
                        title: const Text('Target Audience'),
                        subtitle: Text(notice.targetAudience),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
