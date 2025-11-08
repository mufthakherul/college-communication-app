# Group Chat Appwrite Implementation Guide

**Date:** November 8, 2025  
**Status:** ✅ Complete Implementation Ready  
**Architecture:** Dedicated Collections for Scalability

---

## 📋 Overview

This implementation guide provides step-by-step instructions for setting up group chat functionality in the RPI Communication App using Appwrite as the backend. The architecture uses dedicated collections for groups and group members, providing scalability, proper permission management, and efficient queries.

---

## 🏗️ Architecture

### Collections Structure

```
┌─────────────────────────────────────────────┐
│         Database: rpi_communication          │
├─────────────────────────────────────────────┤
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │   groups                            │   │
│  │ ├─ id (string)                      │   │
│  │ ├─ name (string)                    │   │
│  │ ├─ description (string)             │   │
│  │ ├─ owner_id (foreign key → users)   │   │
│  │ ├─ group_type (string)              │   │
│  │ ├─ member_count (integer)           │   │
│  │ ├─ is_active (boolean)              │   │
│  │ ├─ created_at (datetime)            │   │
│  │ ├─ updated_at (datetime)            │   │
│  │ └─ metadata (object)                │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │   group_members                     │   │
│  │ ├─ id (string)                      │   │
│  │ ├─ group_id (foreign key)           │   │
│  │ ├─ user_id (foreign key)            │   │
│  │ ├─ role (string: admin/moderator)   │   │
│  │ ├─ status (string)                  │   │
│  │ ├─ joined_at (datetime)             │   │
│  │ ├─ unread_count (integer)           │   │
│  │ └─ metadata (object)                │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │   messages (enhanced)               │   │
│  │ ├─ existing fields...               │   │
│  │ ├─ group_id (nullable)              │   │
│  │ ├─ is_group_message (boolean)       │   │
│  │ ├─ sender_display_name (string)     │   │
│  │ ├─ mention_ids (array)              │   │
│  │ ├─ reply_to_message_id (string)     │   │
│  │ └─ reactions (object)               │   │
│  └─────────────────────────────────────┘   │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 🚀 Implementation Steps

### Phase 1: Create Collections in Appwrite Console

#### Step 1.1: Create "groups" Collection

1. Go to **Appwrite Console** → **Databases** → **rpi_communication**
2. Click **"Create Collection"**
3. Set **Collection ID**: `groups`
4. Click **Create**

#### Step 1.2: Add Fields to "groups"

| Field          | Type     | Required | Notes                                      |
| -------------- | -------- | -------- | ------------------------------------------ |
| `name`         | String   | ✅       | Max 255 chars                              |
| `description`  | String   | -        | Max 1000 chars                             |
| `owner_id`     | String   | ✅       | Reference to users.$id                     |
| `group_type`   | String   | ✅       | Enum: class, department, project, interest |
| `avatar_url`   | URL      | -        | Profile picture                            |
| `member_count` | Integer  | ✅       | Default: 1                                 |
| `is_active`    | Boolean  | ✅       | Default: true                              |
| `created_at`   | DateTime | ✅       | Auto-set                                   |
| `updated_at`   | DateTime | ✅       | Auto-set                                   |
| `metadata`     | JSON     | -        | Custom fields                              |

#### Step 1.3: Add Indexes to "groups"

Go to **Attributes** tab, scroll to **Indexes**, add:

1. **Index Name**: `owner_id`

   - **Attribute**: owner_id
   - **Type**: Ascending

2. **Index Name**: `group_type`

   - **Attribute**: group_type
   - **Type**: Ascending

3. **Index Name**: `is_active`

   - **Attribute**: is_active
   - **Type**: Ascending

4. **Index Name**: `created_at_desc`
   - **Attribute**: created_at
   - **Type**: Descending

#### Step 1.4: Set Permissions for "groups"

Go to **Settings** tab, set:

```
Read:
  ☑ team:group_{groupId}_members
  ☑ role:authenticated

Create:
  ☑ role:authenticated

Update:
  ☑ user:{$ownerId}

Delete:
  ☑ user:{$ownerId}
```

---

#### Step 2.1: Create "group_members" Collection

1. Click **"Create Collection"** again
2. Set **Collection ID**: `group_members`
3. Click **Create**

#### Step 2.2: Add Fields to "group_members"

| Field          | Type     | Required | Notes                                  |
| -------------- | -------- | -------- | -------------------------------------- |
| `group_id`     | String   | ✅       | Reference to groups.$id                |
| `user_id`      | String   | ✅       | Reference to users.$id                 |
| `role`         | String   | ✅       | Enum: admin, moderator, member         |
| `nickname`     | String   | -        | Display name in group                  |
| `status`       | String   | ✅       | Enum: active, muted, blocked, inactive |
| `joined_at`    | DateTime | ✅       | Auto-set                               |
| `last_seen_at` | DateTime | -        | Last activity                          |
| `unread_count` | Integer  | ✅       | Default: 0                             |
| `metadata`     | JSON     | -        | Custom settings                        |

#### Step 2.3: Add Indexes to "group_members"

Add these indexes:

1. **Index Name**: `group_id`

   - **Attributes**: group_id (Ascending)

2. **Index Name**: `user_id`

   - **Attributes**: user_id (Ascending)

3. **Index Name**: `role`

   - **Attributes**: role (Ascending)

4. **Index Name**: `status`

   - **Attributes**: status (Ascending)

5. **Index Name**: `joined_at_desc`
   - **Attributes**: joined_at (Descending)

#### Step 2.4: Set Permissions for "group_members"

```
Read:
  ☑ user:{$userId}
  ☑ team:group_{groupId}_admins

Create:
  ☑ user:{$userId}
  ☑ team:group_{groupId}_admins

Update:
  ☑ user:{$userId}
  ☑ team:group_{groupId}_admins

Delete:
  ☑ team:group_{groupId}_admins
```

---

#### Step 3.1: Update "messages" Collection

Go to existing **messages** collection

#### Step 3.2: Add New Fields

Add these fields to messages:

| Field                 | Type    | Notes                                 |
| --------------------- | ------- | ------------------------------------- |
| `group_id`            | String  | Reference to groups.$id (nullable)    |
| `is_group_message`    | Boolean | Default: false                        |
| `sender_display_name` | String  | Denormalized sender name              |
| `sender_photo_url`    | URL     | Denormalized sender avatar            |
| `mention_ids`         | Array   | User IDs mentioned                    |
| `reply_to_message_id` | String  | Message being replied to              |
| `reactions`           | JSON    | Emoji reactions: `{emoji: [userIds]}` |

#### Step 3.3: Add New Indexes

Add to messages indexes:

1. **Index Name**: `group_id`

   - **Attributes**: group_id (Ascending)

2. **Index Name**: `is_group_message`

   - **Attributes**: is_group_message (Ascending)

3. **Index Name**: `created_at_group`
   - **Attributes**: group_id, created_at (Descending)

#### Step 3.4: Update Permissions

Update messages permissions to:

```
Read:
  ☑ user:{$recipientId}
  ☑ user:{$senderId}
  ☑ team:group_{groupId}_members

Create:
  ☑ role:authenticated

Update:
  ☑ user:{$senderId}

Delete:
  ☑ user:{$senderId}
  ☑ team:group_{groupId}_admins
```

---

### Phase 2: Flutter Implementation

#### Step 4.1: Create Models (Already Done ✅)

- `apps/mobile/lib/models/group_model.dart` ✅
- `apps/mobile/lib/models/group_member_model.dart` ✅

#### Step 4.2: Create GroupService (Already Done ✅)

- `apps/mobile/lib/services/group_service.dart` ✅

**Features:**

- Create groups
- Add/remove members
- Manage member roles
- Update group info
- Delete groups
- Track unread messages

#### Step 4.3: Update MessageService (Already Done ✅)

- Enhanced `apps/mobile/lib/services/message_service.dart` ✅

**New Methods:**

- `sendGroupMessage()` - Send message to group
- `getGroupMessages()` - Fetch group message history
- `markGroupMessagesAsRead()` - Mark messages as read
- `searchGroupMessages()` - Search within group
- `getGroupMessageById()` - Fetch specific message
- `addReaction()` - Add emoji reaction
- `deleteMessage()` - Delete message

#### Step 4.4: Initialize GroupService in main.dart

Update `apps/mobile/lib/main.dart`:

```dart
import 'package:campus_mesh/services/group_service.dart';

// Add to _initializeApp() after AppwriteService initialization
late GroupService _groupService;

try {
  _groupService = GroupService(
    database: AppwriteService().databases,
    authService: AuthService(),
  );
  debugPrint('✅ GroupService initialized');
} catch (e) {
  debugPrint('Failed to initialize GroupService: $e');
  // Continue without group chat
}
```

Or use Provider pattern if available in your app.

#### Step 4.5: Create GroupChatScreen UI

Create `apps/mobile/lib/screens/chat/group_chat_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campus_mesh/models/group_model.dart';
import 'package:campus_mesh/models/message_model.dart';
import 'package:campus_mesh/services/group_service.dart';
import 'package:campus_mesh/services/message_service.dart';

class GroupChatScreen extends StatefulWidget {
  final GroupModel group;
  final GroupService groupService;
  final MessageService messageService;

  const GroupChatScreen({
    required this.group,
    required this.groupService,
    required this.messageService,
    super.key,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();

    // Mark messages as read
    widget.groupService.markGroupAsRead(widget.group.id);

    // Scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    try {
      await widget.messageService.sendGroupMessage(
        groupId: widget.group.id,
        content: content,
        groupName: widget.group.name,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        subtitle: Text('${widget.group.memberCount} members'),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: widget.messageService.getGroupMessages(widget.group.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageTile(message);
                  },
                );
              },
            ),
          ),
          // Message input
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTile(MessageModel message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sender info
          if (message.isGroupMessage)
            Text(
              message.senderDisplayName ?? 'Unknown',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          // Message bubble
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(message.content),
          ),
          // Timestamp
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              message.createdAt?.toString() ?? '',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### Phase 3: Navigation & Integration

#### Step 5.1: Add to Home Screen

Update your home/main navigation to include:

```dart
// Add group chats section
ListTile(
  title: const Text('Groups'),
  leading: const Icon(Icons.group),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupsListScreen(
          groupService: _groupService,
          messageService: _messageService,
        ),
      ),
    );
  },
),
```

#### Step 5.2: Create Groups List Screen

Create `apps/mobile/lib/screens/chat/groups_list_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campus_mesh/services/group_service.dart';
import 'package:campus_mesh/services/message_service.dart';

class GroupsListScreen extends StatefulWidget {
  final GroupService groupService;
  final MessageService messageService;

  const GroupsListScreen({
    required this.groupService,
    required this.messageService,
    super.key,
  });

  @override
  State<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends State<GroupsListScreen> {
  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    // Load user's groups
    await widget.groupService.getUserGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Groups')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateGroupDialog();
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder(
        future: widget.groupService.getUserGroups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final groups = snapshot.data ?? [];
          if (groups.isEmpty) {
            return const Center(child: Text('No groups yet'));
          }

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return ListTile(
                title: Text(group.name),
                subtitle: Text('${group.memberCount} members'),
                onTap: () {
                  // Open group chat
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateGroupDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Group name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await widget.groupService.createGroup(
                name: nameController.text,
                description: descController.text,
                groupType: 'project',
              );
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
```

---

## 📊 Data Flow Diagram

```
┌─────────────────────────────────────────────┐
│        User Taps "Create Group"             │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │  GroupService        │
        │ .createGroup()       │
        └──────────────────────┘
                   │
        ┌──────────┴────────────┐
        │                       │
        ▼                       ▼
    ┌────────────┐        ┌──────────────┐
    │   Groups   │        │ GroupMembers │
    │ Collection │        │  Collection  │
    └────────────┘        └──────────────┘
        (insert)           (insert creator)

        Returns: GroupModel

┌─────────────────────────────────────────────┐
│   User Sends Message in Group Chat          │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
      ┌─────────────────────────┐
      │  MessageService         │
      │ .sendGroupMessage()     │
      └─────────────────────────┘
                   │
                   ▼
      ┌─────────────────────────┐
      │   Messages Collection   │
      │   (insert with group_id)│
      └─────────────────────────┘

┌─────────────────────────────────────────────┐
│  User Opens Group Chat Screen               │
└──────────────────┬──────────────────────────┘
                   │
       ┌───────────┴──────────────┐
       │                          │
       ▼                          ▼
  GroupService            MessageService
  .getGroupMembers()       .getGroupMessages()
  .getGroupDetails()       .getUnreadCount()
       │                          │
       └───────────┬──────────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │  Display in UI       │
        │  - Group info        │
        │  - Members list      │
        │  - Message history   │
        └──────────────────────┘
```

---

## 🔒 Security Considerations

### Role-Based Access Control

**Group Owner:**

- Create group
- Update group info
- Delete group
- Manage all members
- Promote/demote admins

**Group Admin:**

- Add/remove members
- Manage message approvals
- Mute/unmute members
- Moderate messages

**Group Moderator:**

- Moderate messages
- Mute members (temporary)
- Pin important messages

**Group Member:**

- Send messages
- Read group messages
- View members
- Leave group

### Permission Implementation

Use Appwrite Teams for per-group permissions:

```dart
// Create teams for each group
// team:group_{groupId}_members - all members
// team:group_{groupId}_admins - admins only
// team:group_{groupId}_moderators - moderators only

// Automatically manage team membership
// when roles change
```

---

## 📈 Performance Optimization

### Caching Strategy

```
Group Info:
  - Cache TTL: 1 hour
  - Invalidate on: update/delete

Members List:
  - Cache TTL: 15 minutes
  - Refresh on: member join/leave

Message History:
  - Cache TTL: Until new message
  - Batch size: 50 messages

Unread Count:
  - Cache TTL: 5 minutes
  - Update on: new message
```

### Query Optimization

```
Efficient Queries:
✅ Get user's groups: Query group_members by user_id
✅ Get members: Query group_members by group_id with role index
✅ Get messages: Query messages by group_id, created_at desc (LIMIT 50)
❌ Avoid: Filtering arrays, counting without aggregation
```

---

## 🧪 Testing Checklist

- [ ] Create group from mobile app
- [ ] Join group successfully
- [ ] Send message in group
- [ ] Receive message in real-time
- [ ] See sender's name and avatar
- [ ] Member list updates correctly
- [ ] Permissions work (non-members can't read)
- [ ] Admin can remove member
- [ ] Member unread count decreases on read
- [ ] Search messages in group
- [ ] Add emoji reaction to message
- [ ] Delete own message
- [ ] Admin can delete any message
- [ ] Offline message queuing works
- [ ] Group messages sync when online
- [ ] Performance with 100+ members

---

## 📱 Sample Usage

### Create a Group

```dart
final groupService = GroupService(
  database: AppwriteService().databases,
  authService: AuthService(),
);

final group = await groupService.createGroup(
  name: 'CS 101 - Spring 2025',
  description: 'Classroom group for Computer Science 101',
  groupType: 'class',
  metadata: {
    'semester': 'Spring 2025',
    'department': 'Computer Science',
  },
);

print('✅ Group created: ${group.id}');
```

### Send Group Message

```dart
final messageService = MessageService();

await messageService.sendGroupMessage(
  groupId: 'grp_001',
  content: 'Hello everyone!',
  groupName: 'CS 101 - Spring 2025',
);

print('✅ Message sent');
```

### Get Group Messages

```dart
final messages = messageService.getGroupMessages('grp_001');

messages.listen((list) {
  print('📬 Received ${list.length} messages');
  for (final msg in list) {
    print('${msg.senderDisplayName}: ${msg.content}');
  }
});
```

---

## 🔗 References

- [Appwrite Collections Documentation](https://appwrite.io/docs/databases)
- [Appwrite Permissions & Security](https://appwrite.io/docs/permissions)
- [Appwrite Teams Management](https://appwrite.io/docs/teams)
- [Appwrite Realtime Events](https://appwrite.io/docs/realtime)

---

## 📞 Support

For issues or questions:

1. Check the [Appwrite Documentation](https://appwrite.io/docs)
2. Review this guide's implementation examples
3. Check the code comments in services
4. Enable debug logging: `debugPrintBeginEndMessages = true`
