import 'package:campus_mesh/models/user_model.dart';
import 'package:campus_mesh/models/user_profile_model.dart';
import 'package:flutter/material.dart';

class TeacherProfileView extends StatelessWidget {
  const TeacherProfileView({
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
        const Divider(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.school, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                'Teaching Profile',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        // Placeholder for future teacher-specific extension fields
          if (profile.designation != null && profile.designation!.isNotEmpty)
            _tile(context, Icons.work_outline, 'Designation', profile.designation!),
          if (profile.officeRoom != null && profile.officeRoom!.isNotEmpty)
            _tile(context, Icons.room, 'Office Room', profile.officeRoom!),
          if (profile.qualification != null && profile.qualification!.isNotEmpty)
            _tile(context, Icons.school, 'Qualification', profile.qualification!),
          if (profile.officeHours != null && profile.officeHours!.isNotEmpty)
            _tile(context, Icons.access_time, 'Office Hours', profile.officeHours!),
          if (profile.subjects != null && profile.subjects!.isNotEmpty) ...[
            ListTile(
              leading: const Icon(Icons.book_outlined),
              title: const Text('Subjects'),
              subtitle: Text(profile.subjects!.join(', ')),
            ),
          ],
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
      ],
    );
  }
}
