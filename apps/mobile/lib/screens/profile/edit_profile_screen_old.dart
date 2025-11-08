import 'package:campus_mesh/models/user_model.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.user});
  final UserModel user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoading = false;

  late TextEditingController _displayNameController;
  late TextEditingController _departmentController;
  late TextEditingController _yearController;
  late TextEditingController _shiftController;
  late TextEditingController _groupController;
  late TextEditingController _classRollController;
  late TextEditingController _academicSessionController;
  late TextEditingController _phoneNumberController;

  String? _selectedShift;
  final List<String> _shifts = ['Morning', 'Day', 'Evening'];

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.user.displayName,
    );
    _departmentController = TextEditingController(text: widget.user.department);
    _yearController = TextEditingController(text: widget.user.year);
    _shiftController = TextEditingController(text: widget.user.shift);
    _groupController = TextEditingController(text: widget.user.group);
    _classRollController = TextEditingController(text: widget.user.classRoll);
    _academicSessionController = TextEditingController(
      text: widget.user.academicSession,
    );
    _phoneNumberController = TextEditingController(
      text: widget.user.phoneNumber,
    );

    _selectedShift = widget.user.shift.isEmpty ? null : widget.user.shift;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _departmentController.dispose();
    _yearController.dispose();
    _shiftController.dispose();
    _groupController.dispose();
    _classRollController.dispose();
    _academicSessionController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.updateUserProfile({
        'display_name': _displayNameController.text.trim(),
        'department': _departmentController.text.trim(),
        'year': _yearController.text.trim(),
        'shift': _selectedShift ?? '',
        'group': _groupController.text.trim(),
        'class_roll': _classRollController.text.trim(),
        'academic_session': _academicSessionController.text.trim(),
        'phone_number': _phoneNumberController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
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
    final isStudent = widget.user.role == UserRole.student;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
              tooltip: 'Save changes',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Information Section
            Text(
              'Basic Information',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _departmentController,
              decoration: const InputDecoration(
                labelText: 'Department',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
                hintText: 'e.g., Computer Technology',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Year',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
                hintText: 'e.g., 3rd',
              ),
            ),

            // Student-Specific Information Section
            if (isStudent) ...[
              const SizedBox(height: 32),
              Text(
                'Student Information',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'These details are only visible to you and teachers',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedShift,
                decoration: const InputDecoration(
                  labelText: 'Shift',
                  prefixIcon: Icon(Icons.schedule),
                  border: OutlineInputBorder(),
                ),
                items: _shifts.map((shift) {
                  return DropdownMenuItem(value: shift, child: Text(shift));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedShift = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _groupController,
                decoration: const InputDecoration(
                  labelText: 'Group',
                  prefixIcon: Icon(Icons.groups),
                  border: OutlineInputBorder(),
                  hintText: 'e.g., A, B, C',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _classRollController,
                decoration: const InputDecoration(
                  labelText: 'Class Roll',
                  prefixIcon: Icon(Icons.confirmation_number),
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 12345',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _academicSessionController,
                decoration: const InputDecoration(
                  labelText: 'Academic Session',
                  prefixIcon: Icon(Icons.event),
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 2023-2024',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                  hintText: 'e.g., +8801712345678',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    // Basic validation for phone number format
                    // Accepts formats: +8801234567890, 01234567890, or 8801234567890
                    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
                    if (!phoneRegex.hasMatch(
                      value.replaceAll(RegExp(r'[\s-]'), ''),
                    )) {
                      return 'Please enter a valid phone number (10-15 digits)';
                    }
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveProfile,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
