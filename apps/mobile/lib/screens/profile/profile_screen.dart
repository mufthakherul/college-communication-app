import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:campus_mesh/models/user_model.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/services/theme_service.dart';
import 'package:campus_mesh/screens/auth/login_screen.dart';
import 'package:campus_mesh/screens/developer/developer_info_screen.dart';
import 'package:campus_mesh/screens/developer/debug_console_screen.dart';
import 'package:campus_mesh/screens/settings/sync_settings_screen.dart';
import 'package:campus_mesh/screens/settings/mesh_network_screen.dart';
import 'package:campus_mesh/screens/profile/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel? user;
  final UserModel? currentUser; // Current logged-in user to check permissions

  const ProfileScreen({super.key, this.user, this.currentUser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isTeacherOrAdmin(UserRole role) {
    return role == UserRole.teacher || role == UserRole.admin;
  }

  bool _canViewPrivateInfo() {
    // User can view their own private info or teachers can view student info
    if (widget.currentUser == null || widget.user == null) return false;
    if (widget.currentUser!.uid == widget.user!.uid) return true; // Own profile
    if (_isTeacherOrAdmin(widget.currentUser!.role)) {
      return true; // Teacher/Admin viewing
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final themeService = ThemeService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: widget.user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SizedBox(height: 32),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.2),
                  child: widget.user!.photoURL.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            widget.user!.photoURL,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Text(
                          widget.user!.displayName.isNotEmpty
                              ? widget.user!.displayName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.user!.displayName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.user!.email,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(
                    widget.user!.role.name.toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getRoleColor(widget.user!.role),
                ),
                const Divider(height: 32),
                _buildInfoTile(
                  context,
                  Icons.business,
                  'Department',
                  widget.user!.department.isEmpty
                      ? 'Not specified'
                      : widget.user!.department,
                ),
                if (widget.user!.year.isNotEmpty)
                  _buildInfoTile(
                    context,
                    Icons.calendar_today,
                    'Year',
                    widget.user!.year,
                  ),
                _buildInfoTile(
                  context,
                  Icons.check_circle,
                  'Status',
                  widget.user!.isActive ? 'Active' : 'Inactive',
                ),
                // Student-specific information (private - only visible to self and teachers)
                if (widget.user!.role == UserRole.student &&
                    _canViewPrivateInfo()) ...[
                  const Divider(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Student Details',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          'Private',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.user!.shift.isNotEmpty)
                    _buildInfoTile(
                      context,
                      Icons.schedule,
                      'Shift',
                      widget.user!.shift,
                    ),
                  if (widget.user!.group.isNotEmpty)
                    _buildInfoTile(
                      context,
                      Icons.groups,
                      'Group',
                      widget.user!.group,
                    ),
                  if (widget.user!.classRoll.isNotEmpty)
                    _buildInfoTile(
                      context,
                      Icons.confirmation_number,
                      'Class Roll',
                      widget.user!.classRoll,
                    ),
                  if (widget.user!.academicSession.isNotEmpty)
                    _buildInfoTile(
                      context,
                      Icons.event,
                      'Academic Session',
                      widget.user!.academicSession,
                    ),
                  if (widget.user!.phoneNumber.isNotEmpty)
                    _buildInfoTile(
                      context,
                      Icons.phone,
                      'Phone Number',
                      widget.user!.phoneNumber,
                    ),
                ],
                const Divider(height: 32),
                // Theme Settings Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Settings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  secondary: Icon(
                    themeService.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text('Dark Mode'),
                  subtitle: Text(
                    themeService.isDarkMode
                        ? 'Dark theme enabled'
                        : 'Light theme enabled',
                  ),
                  value: themeService.isDarkMode,
                  onChanged: (value) {
                    themeService.toggleTheme();
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.sync,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text('Sync Settings'),
                  subtitle: const Text('Manage offline queue and cache'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SyncSettingsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.hub,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text('Mesh Network'),
                  subtitle: const Text('Peer-to-peer communication'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MeshNetworkScreen(),
                      ),
                    );
                  },
                ),
                if (kDebugMode)
                  ListTile(
                    leading: Icon(
                      Icons.bug_report,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: const Text('Debug Console'),
                    subtitle: const Text('Detailed debugging information'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DebugConsoleScreen(),
                        ),
                      );
                    },
                  ),
                const Divider(height: 32),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditProfileScreen(user: widget.user!),
                            ),
                          );
                          // Refresh profile if updated
                          if (result == true && mounted) {
                            setState(() {});
                          }
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Sign Out'),
                              content: const Text(
                                'Are you sure you want to sign out?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Sign Out'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true && context.mounted) {
                            await authService.signOut();
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign Out'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 32),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rangpur Government Polytechnic Institute',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'A comprehensive college communication platform for connecting students, teachers, and administration.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () async {
                                  final url = Uri.parse(
                                    'https://rangpur.polytech.gov.bd',
                                  );
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.language,
                                      size: 20,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'rangpur.polytech.gov.bd',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.blue,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      _showPrivacyPolicy(context);
                                    },
                                    child: Text(
                                      'Privacy Policy',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.blue,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                    ),
                                  ),
                                  Text(
                                    'Version: 1.0.0',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        color: Colors.purple.shade50,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DeveloperInfoScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.code,
                                  color: Colors.purple[700],
                                  size: 32,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Developer Info',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.purple[900],
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'View portfolio & connect with developer',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.purple[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.purple[700],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(label),
      subtitle: Text(value),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.teacher:
        return Colors.blue;
      case UserRole.student:
      default:
        return Colors.green;
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'RPI Communication App Privacy Policy',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                'Data Collection',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'We collect and store the following information:\n'
                '• Your name, email, and department\n'
                '• Messages and notices you create\n'
                '• Profile information you provide\n'
                '• Student details: shift, group, class roll, academic session, phone number (for students only)',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Text('Data Usage', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                'Your data is used to:\n'
                '• Facilitate communication within the institution\n'
                '• Provide notices and announcements\n'
                '• Enable messaging between users',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                'Data Security',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'We implement security measures to protect your data:\n'
                '• Encrypted data transmission\n'
                '• Secure authentication\n'
                '• Role-based access control\n'
                '• Private student information (shift, group, roll, session, phone) is only visible to the student and teachers',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                'Your Rights',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'You have the right to:\n'
                '• Access your personal data\n'
                '• Request data correction\n'
                '• Request account deletion',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 12),
              Text('Contact', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                'For privacy concerns, contact the system administrator at Rangpur Polytechnic Institute.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
