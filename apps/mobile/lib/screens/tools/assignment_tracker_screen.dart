import 'package:campus_mesh/models/assignment_model.dart';
import 'package:campus_mesh/models/user_model.dart';
import 'package:campus_mesh/services/assignment_service.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:flutter/material.dart';

class AssignmentTrackerScreen extends StatefulWidget {
  const AssignmentTrackerScreen({super.key});

  @override
  State<AssignmentTrackerScreen> createState() =>
      _AssignmentTrackerScreenState();
}

class _AssignmentTrackerScreenState extends State<AssignmentTrackerScreen> {
  final _assignmentService = AssignmentService();
  final _authService = AuthService();

  UserModel? _currentUser;
  String _filterStatus = 'all'; // all, pending, upcoming, overdue

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    await _authService.initialize();
    final userId = _authService.currentUserId;
    if (userId != null) {
      final profile = await _authService.getUserProfile(userId);
      if (mounted) {
        setState(() => _currentUser = profile);
      }
    }
  }

  bool get _canCreateAssignments {
    return _currentUser?.role == UserRole.admin ||
        _currentUser?.role == UserRole.teacher;
  }

  List<AssignmentModel> _filterAssignments(List<AssignmentModel> assignments) {
    switch (_filterStatus) {
      case 'pending':
        return assignments.where((a) => !a.isOverdue).toList();
      case 'upcoming':
        return assignments
            .where((a) => a.daysUntilDue > 0 && a.daysUntilDue <= 7)
            .toList();
      case 'overdue':
        return assignments.where((a) => a.isOverdue).toList();
      default:
        return assignments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _filterStatus,
            onSelected: (value) {
              setState(() => _filterStatus = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'upcoming', child: Text('Due Soon')),
              const PopupMenuItem(value: 'overdue', child: Text('Overdue')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<AssignmentModel>>(
        stream: _assignmentService.getAssignments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: SelectableText('Error: ${snapshot.error}'));
          }

          final allAssignments = snapshot.data ?? [];
          final assignments = _filterAssignments(allAssignments);

          if (assignments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _filterStatus == 'all'
                        ? 'No assignments yet'
                        : 'No $_filterStatus assignments',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              return _buildAssignmentCard(assignments[index]);
            },
          );
        },
      ),
      floatingActionButton: _canCreateAssignments
          ? FloatingActionButton.extended(
              onPressed: () {
                // TODO: Navigate to create assignment screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Create assignment feature coming soon'),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create'),
            )
          : null,
    );
  }

  Widget _buildAssignmentCard(AssignmentModel assignment) {
    final isOverdue = assignment.isOverdue;
    final isDueSoon = assignment.daysUntilDue <= 3 && !isOverdue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isOverdue
          ? Colors.red[50]
          : isDueSoon
              ? Colors.orange[50]
              : null,
      child: InkWell(
        onTap: () {
          _showAssignmentDetails(assignment);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      assignment.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getSubjectColor(assignment.subject),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      assignment.subject,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                assignment.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    assignment.teacherName,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Icon(
                    isOverdue
                        ? Icons.error
                        : isDueSoon
                            ? Icons.warning
                            : Icons.schedule,
                    size: 16,
                    color: isOverdue
                        ? Colors.red
                        : isDueSoon
                            ? Colors.orange
                            : Colors.blue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isOverdue
                        ? 'Overdue'
                        : 'Due in ${assignment.daysUntilDue} days',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isOverdue
                          ? Colors.red
                          : isDueSoon
                              ? Colors.orange
                              : Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Due: ${_formatDate(assignment.dueDate)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Text(
                    'Max: ${assignment.maxMarks} marks',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssignmentDetails(AssignmentModel assignment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                assignment.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getSubjectColor(assignment.subject),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  assignment.subject,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                assignment.description,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Teacher', assignment.teacherName),
              _buildDetailRow('Due Date', _formatDate(assignment.dueDate)),
              _buildDetailRow('Max Marks', '${assignment.maxMarks}'),
              _buildDetailRow('Department', assignment.department),
              if (assignment.targetGroups.isNotEmpty)
                _buildDetailRow(
                  'Target Groups',
                  assignment.targetGroups.join(', '),
                ),
              const SizedBox(height: 24),
              if (_currentUser?.role == UserRole.student)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to submission screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Submit assignment feature coming soon',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.upload),
                    label: const Text('Submit Assignment'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];

    final hash = subject.hashCode;
    return colors[hash % colors.length];
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _assignmentService.dispose();
    super.dispose();
  }
}
