# Appwrite Migration Guide for RPI Communication App

## 🎓 Overview

Appwrite has offered educational benefits to host this project! This guide will help you migrate from Supabase to Appwrite to take advantage of these benefits while maintaining all functionality.

## 🌟 Why Appwrite?

### Educational Benefits Offered
- **Free Pro Plan**: Full access to Pro features for educational institutions
- **Increased Quotas**: Higher limits for students and educational projects
- **Dedicated Support**: Priority support for educational use cases
- **Learning Resources**: Educational materials and workshops
- **Community Access**: Connect with other students and educators

### Technical Advantages
- **Self-Hosted Option**: Complete control over your data and infrastructure
- **Built-in APIs**: REST, GraphQL, and Realtime APIs out of the box
- **SDKs Available**: Official Flutter SDK with great documentation
- **Authentication**: 30+ OAuth providers, email/password, phone auth
- **Database**: Document-based NoSQL with powerful queries
- **Storage**: File storage with image optimization and preview generation
- **Functions**: Serverless functions with multiple runtimes (Node.js, Python, etc.)
- **Realtime**: WebSocket subscriptions for live updates

## 📊 Comparison: Supabase vs Appwrite (Educational)

| Feature | Supabase (Current) | Appwrite (Educational) |
|---------|-------------------|------------------------|
| **Pricing** | Free tier limits | Pro plan for free (educational) |
| **Database** | PostgreSQL (relational) | NoSQL (document-based) |
| **Auth Users** | 50,000/month (free) | Unlimited (educational) |
| **Storage** | 1 GB (free) | 100 GB+ (educational) |
| **Functions** | 500K invocations (free) | 1M+ invocations (educational) |
| **Bandwidth** | Limited on free tier | Higher limits (educational) |
| **Self-Hosting** | Possible but complex | Easy self-hosting option |
| **Dashboard** | Web-based | Web-based with better UX |
| **Real-time** | PostgreSQL LISTEN/NOTIFY | Native WebSocket support |

## 🚀 Migration Steps

### Phase 1: Setup Appwrite (1-2 hours)

#### Option A: Appwrite Cloud (Recommended for Quick Start)

1. **Sign up for Appwrite**
   - Visit: https://cloud.appwrite.io
   - Sign up with your institutional email
   - Apply for educational benefits: https://appwrite.io/education

2. **Create Project**
   - Click "Create Project"
   - Project Name: `RPI Communication App`
   - Project ID: `rpi-comm-app` (or auto-generated)
   - Region: Choose closest to your users

3. **Get API Credentials**
   - Go to Project Settings
   - Copy Project ID
   - Create API Key with appropriate scopes
   - Copy Endpoint URL

#### Option B: Self-Hosted Appwrite (Full Control)

```bash
# Install Docker and Docker Compose first

# Install Appwrite
docker run -it --rm \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    --volume "$(pwd)"/appwrite:/usr/src/code/appwrite:rw \
    --entrypoint="install" \
    appwrite/appwrite:1.4.13

# Start Appwrite
cd appwrite
docker-compose up -d

# Access Appwrite Console
# Open: http://localhost
```

### Phase 2: Database Migration (2-3 hours)

#### 1. Create Database Structure

In Appwrite Console:

1. **Go to Databases → Create Database**
   - Database Name: `rpi_communication`
   - Database ID: `rpi_communication`

2. **Create Collections** (equivalent to Supabase tables)

**Users Collection:**
```json
Collection ID: users
Attributes:
- email (string, 255, required, unique)
- displayName (string, 255, required)
- photoUrl (string, 2000)
- role (enum: student, teacher, admin, required, default: student)
- department (string, 100)
- year (string, 20)
- isActive (boolean, default: true)
- createdAt (datetime)
- updatedAt (datetime)

Indexes:
- email (unique)
- role (key)
```

**Notices Collection:**
```json
Collection ID: notices
Attributes:
- title (string, 500, required)
- content (string, 10000, required)
- type (enum: announcement, event, urgent, required)
- targetAudience (string, 100, default: all)
- authorId (string, 255, required)
- isActive (boolean, default: true)
- expiresAt (datetime)
- createdAt (datetime)
- updatedAt (datetime)

Indexes:
- authorId (key)
- isActive (key)
- createdAt (key)
```

**Messages Collection:**
```json
Collection ID: messages
Attributes:
- senderId (string, 255, required)
- recipientId (string, 255, required)
- content (string, 10000, required)
- type (enum: text, image, file, default: text)
- read (boolean, default: false)
- readAt (datetime)
- createdAt (datetime)

Indexes:
- senderId (key)
- recipientId (key)
- createdAt (key)
```

**Notifications Collection:**
```json
Collection ID: notifications
Attributes:
- userId (string, 255, required)
- type (string, 50, required)
- title (string, 255, required)
- body (string, 1000, required)
- data (string, 5000) // JSON as string
- read (boolean, default: false)
- createdAt (datetime)

Indexes:
- userId (key)
- read (key)
```

#### 2. Set up Permissions

For each collection, configure permissions:

**Users Collection Permissions:**
- Read: `user` (any authenticated user)
- Create: `users` (authenticated)
- Update: `user:{userId}` or `role:admin`
- Delete: `role:admin`

**Notices Collection Permissions:**
- Read: `user` (all authenticated users)
- Create: `role:teacher`, `role:admin`
- Update: `user:{authorId}`, `role:admin`
- Delete: `role:admin`

**Messages Collection Permissions:**
- Read: `user:{senderId}`, `user:{recipientId}`
- Create: `user` (authenticated)
- Update: `user:{recipientId}` (for read status)
- Delete: `role:admin`

**Notifications Collection Permissions:**
- Read: `user:{userId}`
- Create: `role:admin`, `role:teacher`
- Update: `user:{userId}`
- Delete: `user:{userId}`, `role:admin`

### Phase 3: Code Changes (3-4 hours)

#### 1. Update Dependencies

**pubspec.yaml changes:**

Remove Supabase:
```yaml
# REMOVE:
# supabase_flutter: ^2.0.0
```

Add Appwrite:
```yaml
dependencies:
  appwrite: ^11.0.0
```

Run:
```bash
cd apps/mobile
flutter pub get
```

#### 2. Create Appwrite Configuration

Create `lib/config/appwrite_config.dart`:

```dart
class AppwriteConfig {
  static const String endpoint = 'https://cloud.appwrite.io/v1'; // or your self-hosted URL
  static const String projectId = 'YOUR_PROJECT_ID';
  static const String databaseId = 'rpi_communication';
  
  // Collection IDs
  static const String usersCollectionId = 'users';
  static const String noticesCollectionId = 'notices';
  static const String messagesCollectionId = 'messages';
  static const String notificationsCollectionId = 'notifications';
  
  // Storage
  static const String storageBucketId = 'files';
}
```

#### 3. Initialize Appwrite Client

Create `lib/services/appwrite_service.dart`:

```dart
import 'package:appwrite/appwrite.dart';
import '../config/appwrite_config.dart';

class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;
  AppwriteService._internal();

  late Client client;
  late Account account;
  late Databases databases;
  late Storage storage;
  late Realtime realtime;

  void init() {
    client = Client()
        .setEndpoint(AppwriteConfig.endpoint)
        .setProject(AppwriteConfig.projectId);

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
    realtime = Realtime(client);
  }

  // Get current user session
  Future<bool> isAuthenticated() async {
    try {
      await account.get();
      return true;
    } catch (e) {
      return false;
    }
  }
}
```

#### 4. Update Authentication Service

Update `lib/services/auth_service.dart`:

```dart
import 'package:appwrite/appwrite.dart';
import 'appwrite_service.dart';
import '../config/appwrite_config.dart';

class AuthService {
  final _appwrite = AppwriteService();
  
  // Sign up with email and password
  Future<String?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create account
      final user = await _appwrite.account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: displayName,
      );

      // Create session
      await _appwrite.account.createEmailSession(
        email: email,
        password: password,
      );

      // Create user document
      await _appwrite.databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: user.$id,
        data: {
          'email': email,
          'displayName': displayName,
          'role': 'student',
          'isActive': true,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      return user.$id;
    } on AppwriteException catch (e) {
      throw Exception('Sign up failed: ${e.message}');
    }
  }

  // Sign in with email and password
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _appwrite.account.createEmailSession(
        email: email,
        password: password,
      );
      return session.userId;
    } on AppwriteException catch (e) {
      throw Exception('Sign in failed: ${e.message}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _appwrite.account.deleteSession(sessionId: 'current');
    } on AppwriteException catch (e) {
      throw Exception('Sign out failed: ${e.message}');
    }
  }

  // Get current user
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final user = await _appwrite.account.get();
      
      // Get user document with additional data
      final userDoc = await _appwrite.databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: user.$id,
      );

      return userDoc.data;
    } on AppwriteException catch (e) {
      return null;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _appwrite.account.createRecovery(
        email: email,
        url: 'https://yourapp.com/reset-password', // Update with your app URL
      );
    } on AppwriteException catch (e) {
      throw Exception('Password reset failed: ${e.message}');
    }
  }
}
```

#### 5. Update Notice Service

Update `lib/services/notice_service.dart`:

```dart
import 'package:appwrite/appwrite.dart';
import 'appwrite_service.dart';
import '../config/appwrite_config.dart';

class NoticeService {
  final _appwrite = AppwriteService();

  // Create notice
  Future<String> createNotice({
    required String title,
    required String content,
    required String type,
    String targetAudience = 'all',
    DateTime? expiresAt,
  }) async {
    try {
      final user = await _appwrite.account.get();
      
      final document = await _appwrite.databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.noticesCollectionId,
        documentId: ID.unique(),
        data: {
          'title': title,
          'content': content,
          'type': type,
          'targetAudience': targetAudience,
          'authorId': user.$id,
          'isActive': true,
          'expiresAt': expiresAt?.toIso8601String(),
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      return document.$id;
    } on AppwriteException catch (e) {
      throw Exception('Create notice failed: ${e.message}');
    }
  }

  // Get all active notices
  Future<List<Map<String, dynamic>>> getNotices({
    int limit = 50,
    String? lastId,
  }) async {
    try {
      final queries = [
        Query.equal('isActive', true),
        Query.orderDesc('createdAt'),
        Query.limit(limit),
      ];

      if (lastId != null) {
        queries.add(Query.cursorAfter(lastId));
      }

      final documents = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.noticesCollectionId,
        queries: queries,
      );

      return documents.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Get notices failed: ${e.message}');
    }
  }

  // Subscribe to notice updates (real-time)
  Stream<Map<String, dynamic>> subscribeToNotices() {
    final subscription = _appwrite.realtime.subscribe([
      'databases.${AppwriteConfig.databaseId}.collections.${AppwriteConfig.noticesCollectionId}.documents'
    ]);

    return subscription.stream.map((response) {
      return response.payload;
    });
  }

  // Update notice
  Future<void> updateNotice({
    required String noticeId,
    String? title,
    String? content,
    bool? isActive,
  }) async {
    try {
      final data = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (title != null) data['title'] = title;
      if (content != null) data['content'] = content;
      if (isActive != null) data['isActive'] = isActive;

      await _appwrite.databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.noticesCollectionId,
        documentId: noticeId,
        data: data,
      );
    } on AppwriteException catch (e) {
      throw Exception('Update notice failed: ${e.message}');
    }
  }

  // Delete notice
  Future<void> deleteNotice(String noticeId) async {
    try {
      await _appwrite.databases.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.noticesCollectionId,
        documentId: noticeId,
      );
    } on AppwriteException catch (e) {
      throw Exception('Delete notice failed: ${e.message}');
    }
  }
}
```

#### 6. Update Message Service

Update `lib/services/message_service.dart`:

```dart
import 'package:appwrite/appwrite.dart';
import 'appwrite_service.dart';
import '../config/appwrite_config.dart';

class MessageService {
  final _appwrite = AppwriteService();

  // Send message
  Future<String> sendMessage({
    required String recipientId,
    required String content,
    String type = 'text',
  }) async {
    try {
      final user = await _appwrite.account.get();

      final document = await _appwrite.databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        documentId: ID.unique(),
        data: {
          'senderId': user.$id,
          'recipientId': recipientId,
          'content': content,
          'type': type,
          'read': false,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      return document.$id;
    } on AppwriteException catch (e) {
      throw Exception('Send message failed: ${e.message}');
    }
  }

  // Get messages for current user
  Future<List<Map<String, dynamic>>> getMessages({
    String? otherUserId,
    int limit = 50,
  }) async {
    try {
      final user = await _appwrite.account.get();

      final queries = [
        Query.orderDesc('createdAt'),
        Query.limit(limit),
      ];

      if (otherUserId != null) {
        queries.addAll([
          Query.or([
            Query.and([
              Query.equal('senderId', user.$id),
              Query.equal('recipientId', otherUserId),
            ]),
            Query.and([
              Query.equal('senderId', otherUserId),
              Query.equal('recipientId', user.$id),
            ]),
          ]),
        ]);
      }

      final documents = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        queries: queries,
      );

      return documents.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception('Get messages failed: ${e.message}');
    }
  }

  // Mark message as read
  Future<void> markAsRead(String messageId) async {
    try {
      await _appwrite.databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        documentId: messageId,
        data: {
          'read': true,
          'readAt': DateTime.now().toIso8601String(),
        },
      );
    } on AppwriteException catch (e) {
      throw Exception('Mark as read failed: ${e.message}');
    }
  }

  // Subscribe to new messages (real-time)
  Stream<Map<String, dynamic>> subscribeToMessages() {
    final subscription = _appwrite.realtime.subscribe([
      'databases.${AppwriteConfig.databaseId}.collections.${AppwriteConfig.messagesCollectionId}.documents'
    ]);

    return subscription.stream.map((response) {
      return response.payload;
    });
  }
}
```

#### 7. Update Main App Initialization

Update `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'services/appwrite_service.dart';

void main() {
  // Initialize Appwrite
  AppwriteService().init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RPI Communication App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
```

### Phase 4: Storage Migration (1-2 hours)

#### 1. Create Storage Bucket in Appwrite

In Appwrite Console:
1. Go to Storage → Create Bucket
2. Bucket ID: `files`
3. Set permissions:
   - Read: `user` (any authenticated user)
   - Create: `user` (authenticated users)
   - Update: `user:{userId}` (file owner)
   - Delete: `user:{userId}`, `role:admin`

#### 2. Update Storage Service

Create `lib/services/storage_service.dart`:

```dart
import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'appwrite_service.dart';
import '../config/appwrite_config.dart';

class StorageService {
  final _appwrite = AppwriteService();

  // Upload file
  Future<String> uploadFile(File file, String fileName) async {
    try {
      final response = await _appwrite.storage.createFile(
        bucketId: AppwriteConfig.storageBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: file.path, filename: fileName),
      );

      return response.$id;
    } on AppwriteException catch (e) {
      throw Exception('Upload failed: ${e.message}');
    }
  }

  // Get file URL
  String getFileUrl(String fileId) {
    return '${AppwriteConfig.endpoint}/storage/buckets/${AppwriteConfig.storageBucketId}/files/$fileId/view?project=${AppwriteConfig.projectId}';
  }

  // Get file preview (for images)
  String getFilePreview(String fileId, {int width = 400, int height = 400}) {
    return '${AppwriteConfig.endpoint}/storage/buckets/${AppwriteConfig.storageBucketId}/files/$fileId/preview?project=${AppwriteConfig.projectId}&width=$width&height=$height';
  }

  // Delete file
  Future<void> deleteFile(String fileId) async {
    try {
      await _appwrite.storage.deleteFile(
        bucketId: AppwriteConfig.storageBucketId,
        fileId: fileId,
      );
    } on AppwriteException catch (e) {
      throw Exception('Delete failed: ${e.message}');
    }
  }

  // Download file
  Future<List<int>> downloadFile(String fileId) async {
    try {
      final bytes = await _appwrite.storage.getFileDownload(
        bucketId: AppwriteConfig.storageBucketId,
        fileId: fileId,
      );
      return bytes;
    } on AppwriteException catch (e) {
      throw Exception('Download failed: ${e.message}');
    }
  }
}
```

### Phase 5: Testing (2-3 hours)

#### 1. Manual Testing Checklist

- [ ] User registration with email/password
- [ ] User login/logout
- [ ] Password reset
- [ ] Create notice (teacher/admin)
- [ ] View notices (all users)
- [ ] Update notice
- [ ] Delete notice
- [ ] Send message
- [ ] Receive message
- [ ] Mark message as read
- [ ] Real-time updates for notices
- [ ] Real-time updates for messages
- [ ] Upload file/image
- [ ] View uploaded files
- [ ] Delete files
- [ ] Role-based access control

#### 2. Performance Testing

```dart
// Add to your test suite
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Performance Tests', () {
    test('Load 100 notices under 2 seconds', () async {
      final startTime = DateTime.now();
      // Load notices
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      expect(duration.inSeconds, lessThan(2));
    });
  });
}
```

### Phase 6: Data Migration (2-4 hours)

#### Option A: Manual Export/Import (Small Dataset)

1. **Export from Supabase:**
```sql
-- Export users
COPY (SELECT * FROM users) TO '/tmp/users.csv' WITH CSV HEADER;

-- Export notices
COPY (SELECT * FROM notices) TO '/tmp/notices.csv' WITH CSV HEADER;

-- Export messages
COPY (SELECT * FROM messages) TO '/tmp/messages.csv' WITH CSV HEADER;
```

2. **Import to Appwrite:**
   - Create a migration script using Appwrite SDK
   - Read CSV files and create documents

#### Option B: Automated Migration Script (Large Dataset)

Create `scripts/migrate_to_appwrite.dart`:

```dart
import 'dart:convert';
import 'dart:io';
import 'package:appwrite/appwrite.dart';

Future<void> main() async {
  // Initialize Appwrite client
  final client = Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('YOUR_PROJECT_ID')
      .setKey('YOUR_API_KEY'); // Server API key

  final databases = Databases(client);

  // Read Supabase export
  final usersJson = File('supabase_export/users.json').readAsStringSync();
  final users = jsonDecode(usersJson) as List;

  // Import to Appwrite
  for (final user in users) {
    try {
      await databases.createDocument(
        databaseId: 'rpi_communication',
        collectionId: 'users',
        documentId: user['id'],
        data: {
          'email': user['email'],
          'displayName': user['display_name'],
          'role': user['role'],
          'isActive': user['is_active'],
          'createdAt': user['created_at'],
        },
      );
      print('Migrated user: ${user['email']}');
    } catch (e) {
      print('Error migrating user ${user['email']}: $e');
    }
  }

  print('Migration complete!');
}
```

Run:
```bash
dart run scripts/migrate_to_appwrite.dart
```

## 🔄 Rollback Plan

If migration encounters issues:

1. **Keep Supabase Running**: Don't shut down Supabase immediately
2. **Parallel Testing**: Test Appwrite thoroughly before full migration
3. **Feature Flags**: Use feature flags to switch between backends
4. **Backup Data**: Always backup Supabase data before migration
5. **Version Control**: Keep all Supabase code in a separate branch

## 📈 Post-Migration Checklist

- [ ] All features working in Appwrite
- [ ] Performance meets or exceeds Supabase
- [ ] All users migrated successfully
- [ ] All data migrated successfully
- [ ] Real-time features working
- [ ] File storage working
- [ ] Authentication working
- [ ] Role-based access working
- [ ] Mobile app updated and tested
- [ ] Documentation updated
- [ ] Team trained on Appwrite

## 🎯 Next Steps

1. **Apply for Educational Benefits**: Visit https://appwrite.io/education
2. **Start with Test Project**: Create a test project to familiarize yourself
3. **Migrate in Phases**: Don't try to migrate everything at once
4. **Monitor Usage**: Track usage to ensure you're within educational limits
5. **Join Community**: https://discord.com/invite/appwrite

## 📚 Additional Resources

- **Appwrite Documentation**: https://appwrite.io/docs
- **Flutter SDK**: https://appwrite.io/docs/sdks#client
- **Educational Program**: https://appwrite.io/education
- **Discord Community**: https://discord.com/invite/appwrite
- **GitHub Issues**: https://github.com/appwrite/appwrite/issues

## 🤝 Support

For migration help:
- Appwrite Discord: https://discord.com/invite/appwrite
- GitHub Discussions: https://github.com/appwrite/appwrite/discussions
- Email: support@appwrite.io (mention educational program)

## 💡 Tips for Success

1. **Start Small**: Migrate auth first, then database, then storage
2. **Test Thoroughly**: Test each component before moving to the next
3. **Use Version Control**: Commit after each successful migration step
4. **Document Changes**: Keep notes of any issues and solutions
5. **Leverage Community**: Don't hesitate to ask for help
6. **Monitor Performance**: Track performance metrics during migration
7. **Keep Supabase Active**: Maintain Supabase as backup during transition

Good luck with your migration! 🚀
