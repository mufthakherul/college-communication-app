# Appwrite Database Setup Complete Guide

**Date:** November 8, 2025  
**Status:** ✅ READY TO EXECUTE  
**Script:** `scripts/setup-appwrite-database.js`

---

## 📋 Overview

This guide provides a fully automated solution to create and configure all Appwrite database collections, attributes, indexes, and storage buckets for the RPI Communication App.

### What Gets Created

**📦 Collections (14 total):**

1. **users** - User profiles with roles (student/teacher/admin)
2. **notices** - Announcements and notifications
3. **messages** - Direct messages + group chat support
4. **groups** - Group chat definitions
5. **group_members** - Group membership tracking
6. **notifications** - User notifications
7. **books** - Library book catalog
8. **book_borrows** - Book borrowing records
9. **events** - Campus events and activities
10. **assignments** - Teacher assignments
11. **timetables** - Class schedules
12. **study_groups** - Student collaboration groups
13. **approval_requests** - Workflow approvals
14. **user_activity** - Activity logging

**🗂️ Storage Buckets (6 total):**

1. **profile-images** (5 MB max, jpg/png/gif)
2. **notice-attachments** (10 MB max, pdf/doc/docx/images)
3. **message-attachments** (25 MB max, multiple formats)
4. **book-covers** (2 MB max, images only)
5. **book-files** (100 MB max, PDF only)
6. **assignment-files** (50 MB max, pdf/doc/zip)

---

## 🚀 Quick Start (3 Steps)

### Step 1: Install Dependencies

```bash
cd /workspaces/college-communication-app/scripts
npm install
```

This installs:

- `node-appwrite` - Official Appwrite SDK for Node.js
- `dotenv` - Environment variable loader

### Step 2: Verify Credentials

Check that your Appwrite credentials are set:

```bash
cat ../tools/mcp/appwrite.mcp.env
```

Should show:

```
APPWRITE_ENDPOINT=https://sgp.cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=6904cfb1001e5253725b
APPWRITE_API_KEY=standard_9d897d6a5ca9...
```

✅ Already configured!

### Step 3: Run Setup Script

```bash
npm run setup
```

Or directly:

```bash
node setup-appwrite-database.js
```

**Expected Output:**

```
╔══════════════════════════════════════════════════════════════╗
║   Appwrite Database Setup - RPI Communication App           ║
╚══════════════════════════════════════════════════════════════╝

📍 Endpoint: https://sgp.cloud.appwrite.io/v1
🗄️  Database: rpi_communication
🔑 Project: 6904cfb1001e5253725b

✓ Database exists

═══════════════════════════════════════════════════════════════
COLLECTIONS
═══════════════════════════════════════════════════════════════

📦 Collection: Users (users)
   ✓ Collection exists
   📝 Attributes (14):
      → email (string, size: 255, required)
         ✓ Already exists
      → display_name (string, size: 255, required)
         ✓ Already exists
      ...

   🔍 Indexes (3):
      → Index: email_unique (unique) on [email]
         ✓ Created
      ...

[... continues for all 14 collections ...]

═══════════════════════════════════════════════════════════════
STORAGE BUCKETS
═══════════════════════════════════════════════════════════════

🗂️  Bucket: Profile Images (profile-images)
   ✓ Bucket created
      Max size: 5 MB
      Extensions: jpg, jpeg, png, gif

[... continues for all 6 buckets ...]

╔══════════════════════════════════════════════════════════════╗
║                    SETUP COMPLETE! ✅                         ║
╚══════════════════════════════════════════════════════════════╝

📊 Summary:
   - Collections: 14
   - Storage Buckets: 6

✨ Your Appwrite database is ready for production!
```

---

## 🔍 What the Script Does

### Idempotent Design

✅ **Safe to run multiple times** - Script checks for existing resources before creating  
✅ **Non-destructive** - Never deletes or overwrites existing data  
✅ **Additive** - Only adds missing attributes, indexes, and buckets

### Collection Creation Process

For each collection:

1. **Check if collection exists**

   - If not exists → Create with permissions
   - If exists → Skip to attributes

2. **Create attributes**

   - Check each attribute individually
   - Only create if missing
   - Supports: string, email, url, integer, float, boolean, datetime, enum
   - Handles: required, optional, arrays, default values

3. **Create indexes**

   - Check each index individually
   - Only create if missing
   - Types: key, unique, fulltext

4. **Rate limiting protection**
   - Sleeps 500ms between attribute creations
   - Sleeps 2000ms before index creation
   - Prevents API throttling

### Storage Bucket Creation

For each bucket:

1. Check if bucket exists
2. Create with configuration:
   - File size limits
   - Allowed extensions
   - Encryption settings
   - Antivirus scanning
   - Permissions

---

## 📊 Collection Details

### Core Collections (Required)

#### 1. Users Collection

- **Purpose:** User profiles and authentication
- **Attributes:** 14 (email, name, role, department, etc.)
- **Indexes:** email (unique), role, department
- **Permissions:** Public read, user update, admin delete

#### 2. Messages Collection (Enhanced for Group Chat)

- **Purpose:** Direct messages + group conversations
- **New Fields:**
  - `group_id` - Reference to group (null for P2P)
  - `is_group_message` - Boolean flag
  - `sender_display_name` - Denormalized for performance
  - `sender_photo_url` - Denormalized avatar
  - `mention_ids` - Array of mentioned user IDs
  - `reply_to_message_id` - Thread support
  - `reactions` - Emoji reactions (JSON string)
- **Indexes:** sender, recipient, group, created_at, is_group

#### 3. Groups Collection (NEW)

- **Purpose:** Group definitions and metadata
- **Attributes:** name, description, owner, type, avatar, member_count
- **Types:** class, department, project, interest
- **Indexes:** owner, type, active, created_at

#### 4. GroupMembers Collection (NEW)

- **Purpose:** Track user membership in groups
- **Attributes:** group_id, user_id, role, status, joined_at, unread_count
- **Roles:** admin, moderator, member
- **Status:** active, muted, blocked, inactive
- **Indexes:** group, user, role, status, joined_at

### Feature Collections (Optional but Recommended)

#### 5. Events Collection

- **Purpose:** Campus events, seminars, workshops
- **Types:** seminar, workshop, exam, sports, cultural, other
- **Features:** Registration tracking, participant limits

#### 6. Assignments Collection

- **Purpose:** Teacher assignments with deadlines
- **Features:** Target groups, attachments, max marks

#### 7. Timetables Collection

- **Purpose:** Class schedules
- **Format:** Periods stored as JSON string

#### 8. StudyGroups Collection

- **Purpose:** Student collaboration groups
- **Features:** Public/private, member limits

---

## 🔒 Security & Permissions

### Permission Patterns

**Collection-Level Permissions:**

```javascript
// Public read (notices, events, books)
permissions: ['read("any")', 'create("label:teacher")', ...]

// User-specific (messages, notifications)
permissions: ['read("user:{userId}")', 'create("users")', ...]

// Document-level security enabled
documentSecurity: true
```

**Document-Level Permissions:**

- Applied per document when `documentSecurity: true`
- Overrides collection permissions
- More granular control

### Role-Based Access

**Student:**

- Read: public content (notices, books, events)
- Create: messages, study groups, approval requests
- Update: own profile, own messages

**Teacher:**

- All student permissions +
- Create: notices, books, assignments, events
- Update: books, timetables
- Read: all messages (for moderation)

**Admin:**

- All permissions
- Delete: any content
- Access: analytics, user activity logs

---

## 🧪 Testing & Verification

### Verify Setup

```bash
npm run verify
```

Or manually:

```bash
bash verify-appwrite-db.sh
```

**Checks:**

- All 14 collections created
- Correct attribute counts
- Index coverage
- No missing fields

### Manual Verification via Appwrite Console

1. Go to [Appwrite Console](https://cloud.appwrite.io/console)
2. Navigate to: Databases → rpi_communication
3. Verify collections appear
4. Check each collection's attributes and indexes

### Test API Access

```javascript
// Test from Node.js
const sdk = require("node-appwrite");

const client = new sdk.Client()
  .setEndpoint("https://sgp.cloud.appwrite.io/v1")
  .setProject("6904cfb1001e5253725b")
  .setKey("your-api-key");

const databases = new sdk.Databases(client);

// List all collections
databases
  .listCollections("rpi_communication")
  .then((response) => console.log(response))
  .catch((error) => console.error(error));
```

---

## 🛠️ Troubleshooting

### Issue: "Missing environment variables"

**Solution:**

```bash
# Check if file exists
ls -la tools/mcp/appwrite.mcp.env

# If missing, copy from sample
cp tools/mcp/appwrite.mcp.env.sample tools/mcp/appwrite.mcp.env

# Edit with real values
nano tools/mcp/appwrite.mcp.env
```

### Issue: "Rate limit exceeded"

**Solution:**

- Script already includes delays (500ms between operations)
- If still hitting limits, increase delays in script:
  ```javascript
  await sleep(1000); // Increase from 500ms
  ```

### Issue: "Attribute already exists" error

**Solution:**

- This is expected! Script checks for existing attributes
- The error is caught and logged as "Already exists"
- Not a problem - script continues

### Issue: "Permission denied"

**Solution:**

1. Verify API key has correct scopes:

   - `databases.write`
   - `collections.write`
   - `attributes.write`
   - `indexes.write`
   - `buckets.write`

2. Generate new API key in Appwrite Console:
   - Settings → API Keys → Create API Key
   - Select all scopes
   - Copy and update `appwrite.mcp.env`

### Issue: "Collection not found" after creation

**Solution:**

- Wait 2-3 seconds for Appwrite to process
- Script includes automatic delays
- May need to increase delay for slow connections

---

## 📝 Script Features

### Smart Attribute Handling

```javascript
// Automatically detects attribute type
switch (type) {
  case 'string': createStringAttribute(...)
  case 'email': createEmailAttribute(...)
  case 'url': createUrlAttribute(...)
  case 'integer': createIntegerAttribute(...)
  case 'enum': createEnumAttribute(...)
  // ... etc
}
```

### Index Types Supported

- **key** - Standard index for filtering/sorting
- **unique** - Unique constraint (e.g., email)
- **fulltext** - Full-text search (e.g., title, author)

### Enum Support

```javascript
// Example: User roles
{
  key: 'role',
  type: 'enum',
  elements: ['student', 'teacher', 'admin'],
  required: true,
  defaultValue: 'student'
}
```

### Array Attributes

```javascript
// Example: Target audience
{
  key: 'target_audience',
  type: 'string',
  size: 100,
  array: true
}
```

---

## 🔄 Migration from Previous Schema

### Changes from Old to New

**Messages Collection:**

- ✅ Added: `group_id`, `is_group_message`
- ✅ Added: `sender_display_name`, `sender_photo_url` (denormalized)
- ✅ Added: `mention_ids`, `reply_to_message_id`, `reactions`

**New Collections:**

- ✅ `groups` - Group definitions
- ✅ `group_members` - Membership tracking

**New Indexes:**

- ✅ Users: `email_unique`, `role_idx`, `department_idx`
- ✅ Books: `title_fulltext`, `author_fulltext`
- ✅ All: `created_at_idx` for sorting

### Backwards Compatibility

✅ **100% Compatible** - All existing documents work as-is  
✅ **New fields optional** - Null values allowed for group fields  
✅ **No data migration needed** - Old messages still work

---

## 📈 Performance Optimizations

### Denormalization Strategy

**Why?**

- Avoids expensive JOINs (Appwrite doesn't support joins)
- Reduces API calls
- Improves read performance

**Examples:**

```javascript
// Messages collection
sender_display_name; // Instead of looking up user
sender_photo_url; // Display avatar without extra query

// Groups collection
member_count; // Count without aggregation query
```

### Index Strategy

**Priority:**

1. Foreign keys (user_id, group_id, sender_id)
2. Filter fields (role, status, type, is_active)
3. Sort fields (created_at DESC)
4. Search fields (fulltext on title, author)

**Avoid:**

- Indexing large text fields (description, content)
- Over-indexing (max 64 indexes per collection)

---

## 🎯 Next Steps After Setup

### 1. Update Flutter App Configuration

```dart
// lib/appwrite_config.dart
static const String groupsCollectionId = 'groups';
static const String groupMembersCollectionId = 'group_members';
```

### 2. Test Group Chat Features

```dart
// Create a test group
final groupService = GroupService();
final groupId = await groupService.createGroup(
  'Test Group',
  'This is a test group',
  'interest'
);

// Add a member
await groupService.addMember(groupId, userId, 'member');

// Send group message
await messageService.sendGroupMessage(groupId, 'Hello group!');
```

### 3. Configure Real-time Subscriptions

```dart
// Listen to group messages
realtime.subscribe([
  'databases.rpi_communication.collections.messages.documents'
]).stream.listen((response) {
  if (response.events.contains('databases.*.collections.*.documents.*.create')) {
    // New message received
  }
});
```

### 4. Test Storage Buckets

```dart
// Upload profile image
final file = await storage.createFile(
  bucketId: 'profile-images',
  fileId: ID.unique(),
  file: InputFile.fromPath(path: imagePath),
);
```

---

## 📚 Additional Resources

- **Appwrite Docs:** https://appwrite.io/docs/databases
- **Node SDK:** https://appwrite.io/docs/sdks/server/node
- **Flutter SDK:** https://appwrite.io/docs/sdks/flutter
- **Security Guide:** https://appwrite.io/docs/permissions

---

## ✅ Checklist

Before running in production:

- [ ] Environment variables verified
- [ ] Dependencies installed (`npm install`)
- [ ] Script executed successfully
- [ ] All 14 collections created
- [ ] All 6 storage buckets created
- [ ] Verification script passed
- [ ] Tested in Appwrite Console
- [ ] Flutter app config updated
- [ ] Real-time subscriptions configured
- [ ] Security permissions reviewed

---

**🎉 You're ready to deploy!**

The RPI Communication App database is now fully configured and production-ready with support for:

- ✅ User management
- ✅ Direct messaging
- ✅ Group chat
- ✅ Notices & events
- ✅ Library system
- ✅ Assignments & timetables
- ✅ File storage
- ✅ Real-time updates

---

_Generated: November 8, 2025_  
_Script Version: 1.0.0_  
_Author: Mufthakherul_
