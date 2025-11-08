import 'package:campus_mesh/models/user_model.dart';
import 'package:campus_mesh/models/user_profile_model.dart';
import 'package:flutter/material.dart';

class AdminProfileView extends StatelessWidget {
  const AdminProfileView({
    super.key,
    required this.user,
    required this.profile,
  });

  final UserModel user;
  final UserProfile profile;

  Widget _tile(BuildContext context, IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value.isEmpty ? 'Not specified' : value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        _tile(context, Icons.business, 'Department', user.department),
        _tile(context, Icons.check_circle, 'Status', user.isActive ? 'Active' : 'Inactive'),
          if (profile.adminTitle != null && profile.adminTitle!.isNotEmpty)
            _tile(context, Icons.badge, 'Admin Title', profile.adminTitle!),
          if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty)
            _tile(context, Icons.phone, 'Phone Number', profile.phoneNumber!),
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bio',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(profile.bio!),
                ],
              ),
            ),
          ],
        const Divider(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.admin_panel_settings, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                'Admin Tools',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
          if (profile.adminScopes != null && profile.adminScopes!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Permissions',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.adminScopes!
                        .map((scope) => Chip(
                              label: Text(scope),
                              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),
          ],
        ListTile(
          leading: const Icon(Icons.campaign_outlined),
          title: const Text('Manage Notices'),
          subtitle: const Text('Create, update, and delete notices'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Navigate to admin notices screen when available
          },
        ),
        ListTile(
          leading: const Icon(Icons.group_outlined),
          title: const Text('Manage Groups'),
          subtitle: const Text('Create and moderate groups'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
      ],
    );
  }
}
