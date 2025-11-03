# Offline Chat Feature Guide

## Overview

The RPI Communication App now supports offline chat functionality, allowing users to send messages even when they don't have an internet connection. Messages are stored locally and automatically synchronized when the connection is restored.

## Key Features

### 1. **Offline Message Storage**
- Messages are automatically saved to a local SQLite database when offline
- No data loss even if the app is closed or device is restarted
- Messages are queued for synchronization once connection is available

### 2. **Automatic Synchronization**
- Periodic sync every 5 minutes when online
- Immediate sync when connection is restored
- Retry mechanism with up to 3 attempts for failed messages
- Old synced messages are automatically cleaned up after 7 days

### 3. **Message Types & Approval**

#### P2P (Direct Messages)
- **No approval needed** - Messages sync directly to the recipient
- Fastest delivery when connection is restored
- Use for student-to-student, student-to-teacher, or teacher-to-teacher communication

#### Group Messages
- **Approval required** - Messages are submitted for admin/teacher approval
- Messages wait in a pending state until approved
- Use for class groups, department groups, or public announcements
- Approved messages appear in the group chat for all members

### 4. **Message Status Indicators**

Messages show different status icons:

| Status | Icon | Description |
|--------|------|-------------|
| **Pending** | ⏰ Clock | Message is queued for sync |
| **Pending Approval** | ⏳ Hourglass | Group message awaiting approval |
| **Failed** | ⚠️ Error | Message failed to sync after 3 attempts |
| **Synced** | ✓✓ Double check | Message successfully delivered |

### 5. **Offline Indicator**
- Orange banner appears at top of chat when offline
- Shows: "Offline - Messages will sync when online"
- Helps users understand their connectivity status

## How It Works

### Sending Messages Offline

1. **User sends a message** while offline or in poor network
2. **Message saved locally** to SQLite database with status "pending"
3. **Message appears** in chat with clock icon (⏰)
4. **User can continue** chatting, all messages are queued

### Automatic Sync Process

1. **Connection restored** - App detects network connectivity
2. **Sync initiated** - Service processes all pending messages
3. **P2P messages** sync directly to recipient
4. **Group messages** upload to pending collection for approval
5. **Status updated** - Icons change to show current state

### Group Message Approval Flow

1. **Student sends** group message while offline
2. **Message synced** to pending collection when online
3. **Admin/Teacher reviews** message in approval dashboard
4. **Approval granted** - Message appears in group chat
5. **Approval denied** - Message marked as rejected
6. **User notified** of approval status

## Database Schema

### Local Messages Table

```sql
CREATE TABLE local_messages (
  id TEXT PRIMARY KEY,
  sender_id TEXT NOT NULL,
  recipient_id TEXT NOT NULL,
  content TEXT NOT NULL,
  type TEXT NOT NULL,
  is_group_message INTEGER NOT NULL DEFAULT 0,
  group_id TEXT,
  created_at TEXT NOT NULL,
  sync_status TEXT NOT NULL DEFAULT 'pending',
  approval_status TEXT DEFAULT 'pending',
  approved_by TEXT,
  approved_at TEXT,
  synced_at TEXT,
  retry_count INTEGER NOT NULL DEFAULT 0,
  last_error TEXT,
  local_file_path TEXT,
  attachment_type TEXT
)
```

### Sync Status Values

- `pending` - Waiting to sync
- `synced` - Successfully synchronized
- `failed` - Failed after retries
- `permanently_failed` - Exceeded max retries
- `pending_approval` - Waiting for approval (group messages)
- `rejected` - Approval denied

## API Integration

### Appwrite Collections

#### Messages Collection
- Standard P2P messages
- Direct synchronization
- No approval process

#### Messages Pending Collection
- Group messages awaiting approval
- Contains approval metadata
- Linked to original local message

### Required Permissions

```javascript
// Messages Collection
Read: [user($id)]
Write: [user($id)]

// Messages Pending Collection
Read: [role:admin, role:teacher, user($id)]
Write: [user($id)]
Update: [role:admin, role:teacher]
```

## Configuration

### Sync Settings

Located in `OfflineMessageSyncService`:

```dart
static const int _maxRetries = 3;  // Max retry attempts
static const Duration _syncInterval = Duration(minutes: 5);  // Sync frequency
```

### Cleanup Settings

Located in `LocalMessageDatabase`:

```dart
Future<int> cleanupSyncedMessages({int daysToKeep = 7})
```

## Usage Examples

### For Students

1. **In class** with poor WiFi:
   - Send messages to classmates
   - Messages queue automatically
   - Sync happens when WiFi improves

2. **On commute** without data:
   - Chat with study group
   - Messages saved locally
   - Sync when you reach WiFi zone

### For Teachers

1. **In remote areas**:
   - Post announcements to class
   - Messages queue for approval
   - Admin approves when you're online

2. **Emergency situations**:
   - Use P2P for urgent communication
   - No approval delay for direct messages

## Troubleshooting

### Messages Not Syncing

1. **Check connection** - Ensure device has internet
2. **Check sync status** - Look at message icons
3. **Manual sync** - Pull to refresh in messages screen
4. **View statistics** - Check sync analytics in settings

### Failed Messages

1. **Review error** - Tap failed message for details
2. **Check retry count** - Max 3 attempts before permanent failure
3. **Resend manually** - Copy text and send again if needed

### Group Messages Stuck

1. **Check approval status** - Message may be pending approval
2. **Contact admin** - Ask about approval process
3. **Check permissions** - Ensure you can send to group

## Best Practices

### For Users

1. ✅ Send P2P messages for urgent communication
2. ✅ Use group messages for announcements
3. ✅ Check offline indicator before sending
4. ✅ Monitor message status icons
5. ❌ Don't send sensitive data without encryption
6. ❌ Don't spam if messages are pending

### For Administrators

1. ✅ Review pending messages regularly
2. ✅ Approve/reject within 24 hours
3. ✅ Set clear guidelines for group messages
4. ✅ Monitor sync statistics
5. ❌ Don't ignore pending approvals
6. ❌ Don't approve inappropriate content

## Technical Details

### Services

- `LocalMessageDatabase` - SQLite storage management
- `OfflineMessageSyncService` - Sync orchestration
- `MessageService` - Unified messaging API
- `ConnectivityService` - Network monitoring

### Dependencies

```yaml
dependencies:
  sqflite: ^2.3.0  # Local database
  connectivity_plus: ^6.0.0  # Network monitoring
  shared_preferences: ^2.2.2  # Session storage
```

### Performance

- **Local storage**: Up to 10,000 messages
- **Sync speed**: ~100 messages per minute
- **Database size**: ~1MB per 1,000 messages
- **Memory usage**: Minimal (uses streaming)

## Security Considerations

1. **Local encryption** - Consider encrypting sensitive messages
2. **Session validation** - Auth tokens checked before sync
3. **Permission checks** - Server validates user permissions
4. **Content moderation** - Group messages reviewed before approval
5. **Rate limiting** - Prevents message spam

## Future Enhancements

Planned features for future versions:

- [ ] End-to-end encryption for offline messages
- [ ] Rich media attachments in offline mode
- [ ] Voice messages with offline support
- [ ] Conflict resolution for simultaneous edits
- [ ] Export/import of local message database
- [ ] Advanced filtering in approval dashboard

## Support

For issues or questions:

1. Check logs in debug mode
2. Review sync statistics in settings
3. Contact app administrator
4. Submit issue on GitHub

## Version History

- **v2.0.0** - Initial offline chat implementation
  - Local SQLite storage
  - Automatic sync service
  - Approval workflow for groups
  - Status indicators in UI

---

**Developed by**: Mufthakherul  
**Institution**: Rangpur Polytechnic Institute
