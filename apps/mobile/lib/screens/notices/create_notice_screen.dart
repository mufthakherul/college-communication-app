import 'package:flutter/material.dart';
import 'package:campus_mesh/models/notice_model.dart';
import 'package:campus_mesh/models/user_model.dart';
import 'package:campus_mesh/services/notice_service.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/widgets/markdown_editor.dart';

class CreateNoticeScreen extends StatefulWidget {
  const CreateNoticeScreen({super.key});

  @override
  State<CreateNoticeScreen> createState() => _CreateNoticeScreenState();
}

class _CreateNoticeScreenState extends State<CreateNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _noticeService = NoticeService();

  NoticeType _selectedType = NoticeType.announcement;
  String _selectedAudience = 'all';
  bool _isLoading = false;
  bool _useMarkdown = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Optional: Pre-check user permissions
    // This helps provide early feedback if user doesn't have permission
    try {
      final authService = AuthService();
      final currentUser = await authService.currentUser;

      if (currentUser == null) {
        if (mounted) {
          _showPermissionError('You must be logged in to create notices');
        }
        return;
      }

      // Check if user has appropriate role
      if (currentUser.role != UserRole.admin &&
          currentUser.role != UserRole.teacher) {
        if (mounted) {
          _showPermissionError(
            'Only admins and teachers can create notices.\n'
            'Your current role: ${currentUser.role.name}',
          );
        }
      }
    } catch (e) {
      // Silently fail - user can still try to create notice
      // and get a proper error from the backend
    }
  }

  void _showPermissionError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Text('Permission Required'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close create screen
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createNotice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _noticeService.createNotice(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        type: _selectedType,
        targetAudience: _selectedAudience,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notice created successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString();
        final isPermissionError =
            errorMessage.toLowerCase().contains('permission') ||
            errorMessage.toLowerCase().contains('authenticated') ||
            errorMessage.toLowerCase().contains('unauthorized');

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  isPermissionError ? Icons.lock : Icons.error,
                  color: isPermissionError ? Colors.orange : Colors.red,
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('Failed to Create Notice')),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPermissionError) ...[
                  const Text(
                    'Permission Denied',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You need to have admin or teacher role to create notices.',
                  ),
                  const SizedBox(height: 12),
                  const Text('To create notices:'),
                  const SizedBox(height: 8),
                  const Text('• Contact your administrator'),
                  const Text('• Request teacher or admin role'),
                  const Text('• Ensure your account is properly configured'),
                ] else ...[
                  const Text(
                    'Unable to create the notice. Please try the following:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text('• Check your internet connection'),
                  const Text('• Verify you have permission to create notices'),
                  const Text('• Ensure backend is configured correctly'),
                  const Text('• Try again in a few moments'),
                ],
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SelectableText(
                    'Error: ${e.toString()}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Notice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Help',
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Only admins and teachers can create notices',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            Semantics(
              label: 'Notice title input field',
              hint: 'Enter a title for the notice',
              textField: true,
              child: TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Content',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    Text(
                      'Rich text',
                      style: TextStyle(
                        fontSize: 14,
                        color: _useMarkdown ? Colors.blue : Colors.grey,
                      ),
                    ),
                    Switch(
                      value: _useMarkdown,
                      onChanged: (value) {
                        setState(() => _useMarkdown = value);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: _useMarkdown
                  ? MarkdownEditor(
                      controller: _contentController,
                      hintText: 'Enter notice content with formatting...',
                    )
                  : TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        hintText: 'Enter notice content...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter content';
                        }
                        return null;
                      },
                    ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<NoticeType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: NoticeType.values.map((type) {
                return DropdownMenuItem(value: type, child: Text(type.name));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedAudience,
              decoration: const InputDecoration(
                labelText: 'Target Audience',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(value: 'students', child: Text('Students')),
                DropdownMenuItem(value: 'teachers', child: Text('Teachers')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedAudience = value);
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _createNotice,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Notice', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue),
            SizedBox(width: 12),
            Text('Creating Notices'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Who can create notices?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text('• Admins'),
              const Text('• Teachers'),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Notice Types',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildNoticeTypeInfo(
                Icons.announcement,
                'Announcement',
                'General information and updates',
                Colors.green,
              ),
              const SizedBox(height: 8),
              _buildNoticeTypeInfo(
                Icons.event,
                'Event',
                'Upcoming events and activities',
                Colors.blue,
              ),
              const SizedBox(height: 8),
              _buildNoticeTypeInfo(
                Icons.warning,
                'Urgent',
                'Important and time-sensitive notices',
                Colors.red,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Tips',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text('• Use clear and concise titles'),
              const Text('• Enable rich text for better formatting'),
              const Text('• Select appropriate target audience'),
              const Text('• Choose the right notice type'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeTypeInfo(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
