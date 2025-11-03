# Appwrite Updated Configuration Guide

## Overview

This guide provides the latest information about Appwrite services and how to properly configure them for the RPI Communication App. This document addresses the differences between older documentation and the current Appwrite platform.

**Last Updated:** November 2025  
**Appwrite Cloud Version:** Latest  
**SDK Version:** 13.0.0+  
**Official Docs:** https://appwrite.io/docs

---

## 🆕 What's New in Latest Appwrite

Appwrite has significantly evolved with many new services and features:

### New Services Available

1. **Database Service** - NoSQL document database with collections
2. **Auth Service** - Complete authentication system with multiple providers
3. **Storage Service** - File storage with buckets and permissions
4. **Functions Service** - Serverless edge functions
5. **Realtime Service** - WebSocket-based real-time subscriptions
6. **Messaging Service** - 🆕 Push notifications, email, and SMS
7. **Locale Service** - Internationalization support
8. **Avatars Service** - Dynamic avatar generation
9. **Teams Service** - Team and organization management

### Key Improvements

- **Granular Permissions** - Document-level and collection-level permissions
- **Role-Based Access** - Built-in RBAC with custom roles
- **Real-time Subscriptions** - Subscribe to database changes, auth events, and more
- **Edge Functions** - Deploy serverless functions with multiple runtimes
- **Enhanced Security** - JWT sessions, API keys, OAuth2 providers
- **Better SDKs** - Improved client and server SDKs with TypeScript support

---

## 📦 Updated SDK Installation

### Step 1: Update Dependencies

Update your `pubspec.yaml`:

```yaml
dependencies:
  appwrite: ^13.0.0  # Latest stable version
```

Run:
```bash
cd apps/mobile
flutter pub get
```

### Step 2: Verify Installation

```bash
flutter pub outdated
```

---

## 🔐 Authentication Service (Updated)

### Available Auth Methods

Appwrite now supports multiple authentication methods:

1. **Email/Password** - Traditional authentication
2. **Magic URL** - Passwordless email authentication  
3. **Phone (SMS)** - Phone number verification
4. **OAuth2 Providers** - Google, GitHub, Facebook, Apple, etc. (30+ providers)
5. **Anonymous** - Guest sessions
6. **JWT** - Custom token authentication

### Email/Password Authentication (Current Implementation)

```dart
import 'package:appwrite/appwrite.dart';

class AuthService {
  final Account account;
  
  // Sign up
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    return await account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
  }
  
  // Sign in
  Future<Session> signIn({
    required String email,
    required String password,
  }) async {
    return await account.createEmailPasswordSession(
      email: email,
      password: password,
    );
  }
  
  // Get current user
  Future<User> getCurrentUser() async {
    return await account.get();
  }
  
  // Sign out
  Future<void> signOut() async {
    await account.deleteSession(sessionId: 'current');
  }
  
  // Update email
  Future<User> updateEmail({
    required String email,
    required String password,
  }) async {
    return await account.updateEmail(
      email: email,
      password: password,
    );
  }
  
  // Update password
  Future<User> updatePassword({
    required String password,
    String? oldPassword,
  }) async {
    return await account.updatePassword(
      password: password,
      oldPassword: oldPassword,
    );
  }
}
```

### OAuth2 Integration (New)

To add Google sign-in:

```dart
Future<void> signInWithGoogle() async {
  try {
    await account.createOAuth2Session(
      provider: OAuthProvider.google,
      // success: 'myapp://auth-success',
      // failure: 'myapp://auth-failure',
    );
  } catch (e) {
    print('OAuth error: $e');
  }
}
```

### Phone Authentication (New)

```dart
Future<void> signInWithPhone(String phone) async {
  // Create phone session
  final token = await account.createPhoneToken(
    userId: ID.unique(),
    phone: phone,
  );
  
  // After user enters OTP
  await account.createSession(
    userId: token.userId,
    secret: 'user-entered-otp',
  );
}
```

---

## 💾 Database Service (Updated)

### Key Concepts

1. **Database** - Container for collections
2. **Collections** - Like tables, hold documents
3. **Documents** - Individual records (JSON-like)
4. **Attributes** - Fields in documents (typed)
5. **Indexes** - Speed up queries
6. **Permissions** - Control access at document/collection level

### Database Permissions (Updated)

Appwrite uses a powerful permission system:

#### Permission Types

- `read` - Read documents
- `create` - Create documents
- `update` - Update documents
- `delete` - Delete documents

#### Permission Roles

- `any` - Anyone (including guests)
- `users` - Any authenticated user
- `user:[USER_ID]` - Specific user
- `team:[TEAM_ID]` - Team members
- `member:[MEMBER_ID]` - Specific team member
- `label:[LABEL]` - Custom label

#### Setting Permissions

**Method 1: Collection-Level Permissions (in Appwrite Console)**

1. Go to Database → Collections → Your Collection
2. Click Settings → Permissions
3. Add permissions for each role

**Method 2: Document-Level Permissions (in Code)**

```dart
// Create document with specific permissions
await databases.createDocument(
  databaseId: databaseId,
  collectionId: collectionId,
  documentId: ID.unique(),
  data: {
    'title': 'My Notice',
    'content': 'Important announcement',
  },
  permissions: [
    Permission.read(Role.any()),
    Permission.update(Role.user(userId)),
    Permission.delete(Role.user(userId)),
  ],
);
```

### CRUD Operations (Updated)

```dart
import 'package:appwrite/appwrite.dart';

class DatabaseService {
  final Databases databases;
  final String databaseId;
  final String collectionId;
  
  // Create document
  Future<Document> createDocument(Map<String, dynamic> data) async {
    return await databases.createDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: ID.unique(),
      data: data,
      permissions: [
        Permission.read(Role.any()),
        Permission.write(Role.users()),
      ],
    );
  }
  
  // List documents with queries
  Future<DocumentList> listDocuments({
    List<String>? queries,
  }) async {
    return await databases.listDocuments(
      databaseId: databaseId,
      collectionId: collectionId,
      queries: queries ?? [],
    );
  }
  
  // Get single document
  Future<Document> getDocument(String documentId) async {
    return await databases.getDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: documentId,
    );
  }
  
  // Update document
  Future<Document> updateDocument(
    String documentId,
    Map<String, dynamic> data,
  ) async {
    return await databases.updateDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: documentId,
      data: data,
    );
  }
  
  // Delete document
  Future<void> deleteDocument(String documentId) async {
    await databases.deleteDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: documentId,
    );
  }
}
```

### Queries (Updated)

Appwrite provides powerful query methods:

```dart
import 'package:appwrite/appwrite.dart';

// Simple queries
final documents = await databases.listDocuments(
  databaseId: databaseId,
  collectionId: collectionId,
  queries: [
    Query.equal('status', 'active'),
    Query.greaterThan('created_at', '2024-01-01'),
    Query.orderDesc('created_at'),
    Query.limit(20),
  ],
);

// Available query methods:
// Query.equal(attribute, value)
// Query.notEqual(attribute, value)
// Query.lessThan(attribute, value)
// Query.lessThanEqual(attribute, value)
// Query.greaterThan(attribute, value)
// Query.greaterThanEqual(attribute, value)
// Query.search(attribute, value)
// Query.isNull(attribute)
// Query.isNotNull(attribute)
// Query.between(attribute, start, end)
// Query.startsWith(attribute, value)
// Query.endsWith(attribute, value)
// Query.select([attributes])
// Query.orderAsc(attribute)
// Query.orderDesc(attribute)
// Query.limit(limit)
// Query.offset(offset)
// Query.cursorAfter(documentId)
// Query.cursorBefore(documentId)
// Query.contains(attribute, value)
// Query.or([queries])
// Query.and([queries])
```

---

## 📁 Storage Service (Updated)

### Bucket Configuration

Buckets are containers for files with specific configurations:

```dart
// File upload
Future<File> uploadFile({
  required String bucketId,
  required InputFile file,
  List<String>? permissions,
}) async {
  return await storage.createFile(
    bucketId: bucketId,
    fileId: ID.unique(),
    file: file,
    permissions: permissions,
  );
}

// Get file view URL
String getFileView(String bucketId, String fileId) {
  return '${endpoint}/storage/buckets/${bucketId}/files/${fileId}/view?project=${projectId}';
}

// Get file download URL
String getFileDownload(String bucketId, String fileId) {
  return '${endpoint}/storage/buckets/${bucketId}/files/${fileId}/download?project=${projectId}';
}

// Delete file
Future<void> deleteFile(String bucketId, String fileId) async {
  await storage.deleteFile(
    bucketId: bucketId,
    fileId: fileId,
  );
}

// List files
Future<FileList> listFiles(String bucketId) async {
  return await storage.listFiles(
    bucketId: bucketId,
    queries: [
      Query.limit(25),
      Query.orderDesc('\$createdAt'),
    ],
  );
}
```

### File Permissions

```dart
// Upload file with permissions
await storage.createFile(
  bucketId: bucketId,
  fileId: ID.unique(),
  file: InputFile.fromPath(path: filePath),
  permissions: [
    Permission.read(Role.any()),
    Permission.update(Role.user(userId)),
    Permission.delete(Role.user(userId)),
  ],
);
```

---

## 🔄 Realtime Service (Updated)

### Real-time Subscriptions

Subscribe to database changes, auth events, and more:

```dart
class RealtimeService {
  final Realtime realtime;
  late RealtimeSubscription subscription;
  
  // Subscribe to collection changes
  void subscribeToCollection({
    required String databaseId,
    required String collectionId,
    required Function(RealtimeMessage) onMessage,
  }) {
    subscription = realtime.subscribe([
      'databases.$databaseId.collections.$collectionId.documents'
    ]);
    
    subscription.stream.listen((response) {
      onMessage(response);
    });
  }
  
  // Subscribe to specific document
  void subscribeToDocument({
    required String databaseId,
    required String collectionId,
    required String documentId,
    required Function(RealtimeMessage) onMessage,
  }) {
    subscription = realtime.subscribe([
      'databases.$databaseId.collections.$collectionId.documents.$documentId'
    ]);
    
    subscription.stream.listen((response) {
      onMessage(response);
    });
  }
  
  // Subscribe to auth events
  void subscribeToAuth({
    required Function(RealtimeMessage) onMessage,
  }) {
    subscription = realtime.subscribe(['account']);
    
    subscription.stream.listen((response) {
      onMessage(response);
    });
  }
  
  // Close subscription
  void close() {
    subscription.close();
  }
}
```

### Realtime Events

```dart
subscription.stream.listen((response) {
  print('Event: ${response.events}');
  print('Payload: ${response.payload}');
  
  // Handle different events
  for (var event in response.events) {
    if (event.contains('create')) {
      print('New document created');
    } else if (event.contains('update')) {
      print('Document updated');
    } else if (event.contains('delete')) {
      print('Document deleted');
    }
  }
});
```

### Realtime Channels

Available channel patterns:

- `account` - Auth events for current user
- `databases.[DATABASE_ID].collections.[COLLECTION_ID].documents` - All documents in collection
- `databases.[DATABASE_ID].collections.[COLLECTION_ID].documents.[DOCUMENT_ID]` - Specific document
- `files` - All file events
- `files.[FILE_ID]` - Specific file
- `buckets.[BUCKET_ID].files` - All files in bucket
- `teams` - Team events
- `teams.[TEAM_ID]` - Specific team events

---

## ⚡ Functions Service (New)

### What are Functions?

Appwrite Functions are serverless functions that run on the server:

- Execute backend logic
- Handle webhooks
- Process scheduled tasks
- Send emails/notifications
- Data transformations

### Creating a Function

**Via Appwrite Console:**

1. Go to Functions in sidebar
2. Click "Add Function"
3. Configure:
   - Name: `send-notification`
   - Runtime: `node-18.0` or `dart-3.0`
   - Events: Trigger on database events
   - Schedule: Cron expression (optional)

**Example Function (Node.js):**

```javascript
module.exports = async ({ req, res, log, error }) => {
  try {
    const { userId, message } = JSON.parse(req.body);
    
    log(`Sending notification to user ${userId}`);
    
    // Your logic here
    // Send email, push notification, etc.
    
    return res.json({
      success: true,
      message: 'Notification sent',
    });
  } catch (err) {
    error(err.message);
    return res.json({
      success: false,
      error: err.message,
    }, 500);
  }
};
```

### Triggering Functions from Flutter

```dart
import 'package:appwrite/appwrite.dart';

class FunctionsService {
  final Functions functions;
  
  Future<Execution> executeFunction({
    required String functionId,
    String? data,
  }) async {
    return await functions.createExecution(
      functionId: functionId,
      data: data,
      async: false, // Wait for response
    );
  }
}

// Usage
final result = await functionsService.executeFunction(
  functionId: 'send-notification',
  data: json.encode({
    'userId': userId,
    'message': 'Hello!',
  }),
);

print('Response: ${result.response}');
```

---

## 🔒 Security & Permissions Best Practices

### 1. Use Appropriate Roles

```dart
// Public read, authenticated write
Permission.read(Role.any()),
Permission.create(Role.users()),

// Only creator can update/delete
Permission.update(Role.user(userId)),
Permission.delete(Role.user(userId)),

// Admin-only access
Permission.write(Role.label('admin')),
```

### 2. Validate Input

```dart
// Always validate before creating documents
if (title.isEmpty || title.length > 500) {
  throw Exception('Invalid title');
}
```

### 3. Use Environment Variables

```dart
// In production, never hardcode credentials
static const String projectId = String.fromEnvironment(
  'APPWRITE_PROJECT_ID',
  defaultValue: 'default-project-id',
);
```

### 4. Handle Sessions Properly

```dart
// Always check session validity
try {
  final user = await account.get();
  // User is authenticated
} catch (e) {
  // Session expired or invalid
  // Redirect to login
}
```

---

## 📊 Collection Setup for RPI Communication App

### Required Collections

Based on the latest Appwrite capabilities, here's the updated schema:

#### 1. Users Collection

```
Collection ID: users
Permissions: 
  - Read: any
  - Create: users
  - Update: user:[USER_ID]
  - Delete: label:admin

Attributes:
  - email (string, 255, required)
  - display_name (string, 255, required)
  - photo_url (string, 2000, optional)
  - role (enum: student|teacher|admin, required, default: student)
  - department (string, 100, optional)
  - year (string, 20, optional)
  - shift (string, 50, optional)
  - group (string, 10, optional)
  - class_roll (string, 20, optional)
  - academic_session (string, 50, optional)
  - phone_number (string, 20, optional)
  - is_active (boolean, required, default: true)
  - created_at (datetime, required)
  - updated_at (datetime, required)

Indexes:
  - email (unique, asc)
  - role (key, asc)
  - department (key, asc)
```

#### 2. Notices Collection

```
Collection ID: notices
Permissions:
  - Read: any (with is_active = true)
  - Create: label:teacher, label:admin
  - Update: user:[AUTHOR_ID], label:admin
  - Delete: label:admin

Attributes:
  - title (string, 500, required)
  - content (string, 10000, required)
  - type (enum: announcement|event|urgent, required, default: announcement)
  - author_id (string, 255, required)
  - author_name (string, 255, required)
  - target_audience (string[], optional, default: ["all"])
  - is_active (boolean, required, default: true)
  - expires_at (datetime, optional)
  - created_at (datetime, required)
  - updated_at (datetime, required)

Indexes:
  - type (key, asc)
  - is_active (key, asc)
  - created_at (key, desc)
  - author_id (key, asc)
```

#### 3. Messages Collection

```
Collection ID: messages
Permissions:
  - Read: user:[SENDER_ID], user:[RECIPIENT_ID]
  - Create: users
  - Update: user:[RECIPIENT_ID] (for read status)
  - Delete: user:[SENDER_ID], label:admin

Attributes:
  - sender_id (string, 255, required)
  - sender_name (string, 255, required)
  - recipient_id (string, 255, required)
  - recipient_name (string, 255, required)
  - content (string, 10000, required)
  - type (enum: text|image|file, required, default: text)
  - attachment_url (string, 2000, optional)
  - is_read (boolean, required, default: false)
  - read_at (datetime, optional)
  - created_at (datetime, required)

Indexes:
  - sender_id (key, asc)
  - recipient_id (key, asc)
  - is_read (key, asc)
  - created_at (key, desc)
```

---

## 🚀 Quick Setup Checklist

### Pre-requisites
- [ ] Appwrite account created
- [ ] Educational benefits approved (if applicable)
- [ ] Project created in Appwrite Console

### Database Setup
- [ ] Database created: `rpi_communication`
- [ ] Collections created with attributes
- [ ] Indexes configured
- [ ] Permissions set for each collection

### Storage Setup
- [ ] Bucket created: `profile-images` (5MB limit)
- [ ] Bucket created: `notice-attachments` (10MB limit)
- [ ] Bucket created: `message-attachments` (25MB limit)
- [ ] Bucket created: `book-covers` (2MB limit)
- [ ] Bucket created: `book-files` (100MB limit)
- [ ] Permissions set for each bucket

### App Configuration
- [ ] SDK updated to latest version
- [ ] `appwrite_config.dart` updated with correct credentials
- [ ] Permissions tested
- [ ] Authentication tested
- [ ] Real-time subscriptions working

---

## 🐛 Troubleshooting Common Issues

### Issue: "User (role: guests) missing scope (account)"

**Solution:** User is not authenticated. Ensure user is signed in:

```dart
final session = await account.createEmailPasswordSession(
  email: email,
  password: password,
);
```

### Issue: "Document missing write permissions"

**Solution:** Add proper permissions when creating document:

```dart
await databases.createDocument(
  // ...
  permissions: [
    Permission.read(Role.any()),
    Permission.write(Role.user(userId)),
  ],
);
```

### Issue: "Invalid query"

**Solution:** Use correct query syntax:

```dart
// Correct
Query.equal('status', 'active')

// Wrong
Query.equal('status', ['active']) // Don't use array for single value
```

### Issue: "Realtime not working"

**Solution:** Ensure correct channel pattern:

```dart
// Correct
'databases.$databaseId.collections.$collectionId.documents'

// Wrong
'collection.$collectionId' // Missing database prefix
```

---

## 📚 Additional Resources

### Official Documentation
- **Main Docs:** https://appwrite.io/docs
- **Database:** https://appwrite.io/docs/products/databases
- **Auth:** https://appwrite.io/docs/products/auth
- **Storage:** https://appwrite.io/docs/products/storage
- **Functions:** https://appwrite.io/docs/products/functions
- **Realtime:** https://appwrite.io/docs/apis/realtime

### Community
- **Discord:** https://discord.com/invite/appwrite
- **GitHub:** https://github.com/appwrite/appwrite
- **Forum:** https://github.com/appwrite/appwrite/discussions

### Tutorials
- **YouTube Channel:** https://www.youtube.com/@appwrite
- **Blog:** https://appwrite.io/blog
- **Educational Program:** https://appwrite.io/education

---

## 📝 Next Steps

1. **Update SDK** - Run `flutter pub get` after updating `pubspec.yaml`
2. **Review Permissions** - Ensure all collections have correct permissions
3. **Test Authentication** - Verify sign up/sign in works
4. **Test Database** - Create, read, update, delete documents
5. **Test Storage** - Upload and download files
6. **Setup Realtime** - Subscribe to collection changes
7. **Deploy Functions** - If needed for backend logic

---

## 🎯 Summary

This guide covers the latest Appwrite features and how to properly configure them:

- ✅ **Updated SDK** to v13.0.0
- ✅ **Authentication** with multiple providers
- ✅ **Database** with proper permissions and queries
- ✅ **Storage** with buckets and file permissions
- ✅ **Realtime** subscriptions for live updates
- ✅ **Functions** for serverless backend logic
- ✅ **Security** best practices

For any issues or questions, refer to:
- This guide
- Official Appwrite documentation
- Appwrite Discord community
- GitHub issues in this repository

**Last Updated:** November 2025
