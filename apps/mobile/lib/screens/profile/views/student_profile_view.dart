import 'package:campus_mesh/models/user_model.dart';
import 'package:campus_mesh/models/user_profile_model.dart';
import 'package:flutter/material.dart';

class StudentProfileView extends StatelessWidget {
  const StudentProfileView({
    super.key,
    required this.user,
    required this.profile,
    required this.canViewPrivate,
  });

  final UserModel user;
  final UserProfile profile;
  final bool canViewPrivate;

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
        if (user.year.isNotEmpty)
          _tile(context, Icons.calendar_today, 'Year', user.year),
        _tile(context, Icons.check_circle, 'Status', user.isActive ? 'Active' : 'Inactive'),
        if (canViewPrivate) ...[
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.lock, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Student Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  'Private',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
            if (profile.shift != null && profile.shift!.isNotEmpty)
              _tile(context, Icons.schedule, 'Shift', profile.shift!),
            if (profile.group != null && profile.group!.isNotEmpty)
              _tile(context, Icons.groups, 'Group', profile.group!),
            if (profile.classRoll != null && profile.classRoll!.isNotEmpty)
              _tile(context, Icons.confirmation_number, 'Class Roll', profile.classRoll!),
            if (profile.academicSession != null && profile.academicSession!.isNotEmpty)
              _tile(context, Icons.event, 'Academic Session', profile.academicSession!),
            if (profile.registrationNo != null && profile.registrationNo!.isNotEmpty)
              _tile(context, Icons.badge, 'Registration No', profile.registrationNo!),
            if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty)
              _tile(context, Icons.phone, 'Phone Number', profile.phoneNumber!),
            if (profile.guardianName != null && profile.guardianName!.isNotEmpty)
              _tile(context, Icons.person, 'Guardian Name', profile.guardianName!),
            if (profile.guardianPhone != null && profile.guardianPhone!.isNotEmpty)
              _tile(context, Icons.phone_in_talk, 'Guardian Phone', profile.guardianPhone!),
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
      ],
    );
  }
}
