import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_mesh/models/notice_model.dart';
import 'package:campus_mesh/services/notice_service.dart';
import 'package:campus_mesh/services/qr_data_service.dart';
import 'package:campus_mesh/screens/qr/qr_share_screen.dart';

class NoticeDetailScreen extends StatelessWidget {
  final String noticeId;

  const NoticeDetailScreen({super.key, required this.noticeId});

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
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () async {
              final notice = await noticeService.getNotice(noticeId);
              if (notice != null && context.mounted) {
                _shareNoticeViaQR(context, notice);
              }
            },
            tooltip: 'Share via QR Code',
          ),
        ],
      ),
      body: FutureBuilder<NoticeModel?>(
        future: noticeService.getNotice(noticeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingSkeleton(context);
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load notice',
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
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final notice = snapshot.data;
          if (notice == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Notice not found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This notice may have been removed or expired.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
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
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
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
                      // Check if content contains markdown syntax
                      _containsMarkdown(notice.content)
                          ? MarkdownBody(
                              data: notice.content,
                              styleSheet: MarkdownStyleSheet.fromTheme(
                                Theme.of(context),
                              ),
                            )
                          : Text(
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

  Widget _buildLoadingSkeleton(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 32,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 24,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _containsMarkdown(String text) {
    // Simple check for common markdown patterns
    return text.contains('**') ||
        text.contains('*') ||
        text.contains('[') && text.contains('](') ||
        text.contains('- ') ||
        text.contains('1. ') ||
        text.contains('`');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _shareNoticeViaQR(BuildContext context, NoticeModel notice) {
    final qrDataService = QRDataService();
    final currentUser = FirebaseAuth.instance.currentUser;

    final qrData = qrDataService.generateNoticeQR(
      noticeId: notice.id,
      title: notice.title,
      content: notice.content,
      type: notice.type.name,
      senderId: currentUser?.uid,
      senderName: currentUser?.email?.split('@').first ?? 'Unknown',
      expiry: const Duration(hours: 24), // QR code valid for 24 hours
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRShareScreen(qrData: qrData)),
    );
  }
}
