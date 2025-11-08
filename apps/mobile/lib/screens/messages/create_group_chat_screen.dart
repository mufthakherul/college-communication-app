// ignore_for_file: cascade_invocations
import 'package:appwrite/appwrite.dart';
import 'package:campus_mesh/appwrite_config.dart';
import 'package:campus_mesh/models/user_model.dart';
import 'package:campus_mesh/services/appwrite_service.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/services/chat_service.dart';
import 'package:campus_mesh/services/connectivity_service.dart';
import 'package:flutter/material.dart';

/// Screen for creating a new group chat
class CreateGroupChatScreen extends StatefulWidget {
  const CreateGroupChatScreen({super.key});

  @override
  State<CreateGroupChatScreen> createState() => _CreateGroupChatScreenState();
}

class _CreateGroupChatScreenState extends State<CreateGroupChatScreen> {
  final _chatService = ChatService();
  final _appwrite = AppwriteService();
  final _authService = AuthService();
  final _connectivityService = ConnectivityService();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();

  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  final List<UserModel> _selectedUsers = [];
  bool _isLoading = true;
  bool _isCreating = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) {
        throw Exception('Not authenticated');
      }

      // Fetch all active users except current user
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [Query.equal('is_active', true), Query.limit(100)],
      );

      final users = response.documents
          .map((doc) => UserModel.fromJson({...doc.data, 'id': doc.$id}))
          .where((user) => user.uid != currentUserId)
          .toList();

      users.sort((a, b) => a.displayName.compareTo(b.displayName));

      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load users: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers.where((user) {
          final nameLower = user.displayName.toLowerCase();
          final queryLower = query.toLowerCase();
          return nameLower.contains(queryLower);
        }).toList();
      }
    });
  }

  void _toggleUserSelection(UserModel user) {
    setState(() {
      if (_selectedUsers.contains(user)) {
        _selectedUsers.remove(user);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  Future<void> _createGroup() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a group name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one member'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final participantIds = _selectedUsers.map((u) => u.uid).toList();
      final chatId = await _chatService.createGroupChat(
        name: name,
        participantIds: participantIds,
      );

      if (mounted) {
        final isOnline = _connectivityService.isOnline;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isOnline
                  ? 'Group created successfully'
                  : 'Group created offline - will sync when online',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(chatId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create group: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group Chat'),
        actions: [
          if (!_isCreating)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _createGroup,
              tooltip: 'Create',
            ),
        ],
      ),
      body: Column(
        children: [
          // Offline indicator
          StreamBuilder<bool>(
            stream: _connectivityService.connectivityStream,
            builder: (context, snapshot) {
              final isOnline = snapshot.data ?? true;
              if (isOnline) return const SizedBox.shrink();

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.orange[700],
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, size: 16, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Offline - Group will sync when online',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Group name input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'Enter group name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.group),
              ),
            ),
          ),

          // Selected users chips
          if (_selectedUsers.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedUsers.length,
                itemBuilder: (context, index) {
                  final user = _selectedUsers[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(user.displayName),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _toggleUserSelection(user),
                    ),
                  );
                },
              ),
            ),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search users',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterUsers,
            ),
          ),

          // User list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      final isSelected = _selectedUsers.contains(user);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            user.displayName.isNotEmpty
                                ? user.displayName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(user.displayName),
                        subtitle: Text(user.email),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (_) => _toggleUserSelection(user),
                        ),
                        onTap: () => _toggleUserSelection(user),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
