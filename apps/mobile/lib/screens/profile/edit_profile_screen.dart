import 'package:campus_mesh/models/user_model.dart';
import 'package:campus_mesh/models/user_profile_model.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/services/user_profile_service.dart';
import 'package:appwrite/appwrite.dart';
import 'package:campus_mesh/appwrite_config.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.user,
    required this.profile,
  });

  final UserModel user;
  final UserProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  late final UserProfileService _profileService;
  bool _isLoading = false;

  // Common fields
  late TextEditingController _displayNameController;
  late TextEditingController _departmentController;
  late TextEditingController _yearController;
  late TextEditingController _bioController;
  late TextEditingController _phoneNumberController;

  // Student fields
  late TextEditingController _shiftController;
  late TextEditingController _groupController;
  late TextEditingController _classRollController;
  late TextEditingController _academicSessionController;
  late TextEditingController _registrationNoController;
  late TextEditingController _guardianNameController;
  late TextEditingController _guardianPhoneController;

  // Teacher fields
  late TextEditingController _designationController;
  late TextEditingController _officeRoomController;
  late TextEditingController _qualificationController;
  late TextEditingController _officeHoursController;
  late TextEditingController _subjectsController;

  // Admin fields
  late TextEditingController _adminTitleController;
  late TextEditingController _adminScopesController;

  String? _selectedShift;
  final List<String> _shifts = ['Morning', 'Day', 'Evening'];

  @override
  void initState() {
    super.initState();
    final client = Client()
        .setEndpoint(AppwriteConfig.endpoint)
        .setProject(AppwriteConfig.projectId);
    _profileService = UserProfileService(client);

    // Initialize common fields
    _displayNameController = TextEditingController(text: widget.user.displayName);
    _departmentController = TextEditingController(text: widget.user.department);
    _yearController = TextEditingController(text: widget.user.year);
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _phoneNumberController = TextEditingController(text: widget.profile.phoneNumber ?? '');

    // Initialize student fields
    _shiftController = TextEditingController(text: widget.profile.shift ?? '');
    _groupController = TextEditingController(text: widget.profile.group ?? '');
    _classRollController = TextEditingController(text: widget.profile.classRoll ?? '');
    _academicSessionController = TextEditingController(text: widget.profile.academicSession ?? '');
    _registrationNoController = TextEditingController(text: widget.profile.registrationNo ?? '');
    _guardianNameController = TextEditingController(text: widget.profile.guardianName ?? '');
    _guardianPhoneController = TextEditingController(text: widget.profile.guardianPhone ?? '');
    _selectedShift = widget.profile.shift?.isEmpty ?? true ? null : widget.profile.shift;

    // Initialize teacher fields
    _designationController = TextEditingController(text: widget.profile.designation ?? '');
    _officeRoomController = TextEditingController(text: widget.profile.officeRoom ?? '');
    _qualificationController = TextEditingController(text: widget.profile.qualification ?? '');
    _officeHoursController = TextEditingController(text: widget.profile.officeHours ?? '');
    _subjectsController = TextEditingController(
      text: widget.profile.subjects?.join(', ') ?? '',
    );

    // Initialize admin fields
    _adminTitleController = TextEditingController(text: widget.profile.adminTitle ?? '');
    _adminScopesController = TextEditingController(
      text: widget.profile.adminScopes?.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    // Common fields
    _displayNameController.dispose();
    _departmentController.dispose();
    _yearController.dispose();
    _bioController.dispose();
    _phoneNumberController.dispose();

    // Student fields
    _shiftController.dispose();
    _groupController.dispose();
    _classRollController.dispose();
    _academicSessionController.dispose();
    _registrationNoController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();

    // Teacher fields
    _designationController.dispose();
    _officeRoomController.dispose();
    _qualificationController.dispose();
    _officeHoursController.dispose();
    _subjectsController.dispose();

    // Admin fields
    _adminTitleController.dispose();
    _adminScopesController.dispose();

    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Update common user fields
      await _authService.updateUserProfile({
        'display_name': _displayNameController.text.trim(),
        'department': _departmentController.text.trim(),
        'year': _yearController.text.trim(),
      });

      // Build profile updates based on role
      final profileUpdates = <String, dynamic>{
        'bio': _bioController.text.trim(),
        'phone_number': _phoneNumberController.text.trim(),
      };

      // Add role-specific fields
      switch (widget.user.role) {
        case UserRole.student:
          profileUpdates.addAll({
            'shift': _selectedShift ?? '',
            'group': _groupController.text.trim(),
            'class_roll': _classRollController.text.trim(),
            'academic_session': _academicSessionController.text.trim(),
            'registration_no': _registrationNoController.text.trim(),
            'guardian_name': _guardianNameController.text.trim(),
            'guardian_phone': _guardianPhoneController.text.trim(),
          });
          break;

        case UserRole.teacher:
          profileUpdates.addAll({
            'designation': _designationController.text.trim(),
            'office_room': _officeRoomController.text.trim(),
            'qualification': _qualificationController.text.trim(),
            'office_hours': _officeHoursController.text.trim(),
            'subjects': _subjectsController.text
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
          });
          break;

        case UserRole.admin:
          profileUpdates.addAll({
            'admin_title': _adminTitleController.text.trim(),
            'admin_scopes': _adminScopesController.text
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
          });
          break;
      }

      // Update profile
      await _profileService.updateUserProfile(widget.user.uid, profileUpdates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
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
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Common fields section
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your display name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _departmentController,
              decoration: const InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Year',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info),
                hintText: 'Tell us about yourself',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),

            // Role-specific fields
            const SizedBox(height: 32),
            Text(
              _getRoleSectionTitle(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Student fields
            if (widget.user.role == UserRole.student) ...[
              DropdownButtonFormField<String>(
                value: _selectedShift,
                decoration: const InputDecoration(
                  labelText: 'Shift',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.schedule),
                ),
                items: _shifts.map((shift) {
                  return DropdownMenuItem(
                    value: shift,
                    child: Text(shift),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedShift = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _groupController,
                decoration: const InputDecoration(
                  labelText: 'Group',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.groups),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _classRollController,
                decoration: const InputDecoration(
                  labelText: 'Class Roll',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _academicSessionController,
                decoration: const InputDecoration(
                  labelText: 'Academic Session',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _registrationNoController,
                decoration: const InputDecoration(
                  labelText: 'Registration Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _guardianNameController,
                decoration: const InputDecoration(
                  labelText: 'Guardian Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _guardianPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Guardian Phone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_in_talk),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],

            // Teacher fields
            if (widget.user.role == UserRole.teacher) ...[
              TextFormField(
                controller: _designationController,
                decoration: const InputDecoration(
                  labelText: 'Designation',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _officeRoomController,
                decoration: const InputDecoration(
                  labelText: 'Office Room',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.room),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _qualificationController,
                decoration: const InputDecoration(
                  labelText: 'Qualification',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _officeHoursController,
                decoration: const InputDecoration(
                  labelText: 'Office Hours',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                  hintText: 'e.g., Mon-Fri 9AM-5PM',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectsController,
                decoration: const InputDecoration(
                  labelText: 'Subjects',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book_outlined),
                  hintText: 'Comma-separated (e.g., Math, Physics)',
                ),
                maxLines: 2,
              ),
            ],

            // Admin fields
            if (widget.user.role == UserRole.admin) ...[
              TextFormField(
                controller: _adminTitleController,
                decoration: const InputDecoration(
                  labelText: 'Admin Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _adminScopesController,
                decoration: const InputDecoration(
                  labelText: 'Admin Permissions',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.security),
                  hintText: 'Comma-separated (e.g., notices, users, groups)',
                ),
                maxLines: 2,
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getRoleSectionTitle() {
    switch (widget.user.role) {
      case UserRole.student:
        return 'Student Information';
      case UserRole.teacher:
        return 'Teaching Information';
      case UserRole.admin:
        return 'Admin Information';
    }
  }
}
