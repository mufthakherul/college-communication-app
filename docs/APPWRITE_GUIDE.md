# Appwrite Complete Guide

## Overview

This comprehensive guide covers everything you need to set up and configure Appwrite for the RPI Communication App. This consolidates information from multiple sources into a single reference document.

**Last Updated:** November 2025  
**Appwrite Cloud Version:** 1.5.x  
**SDK Version:** 12.0.4  
**Official Docs:** https://appwrite.io/docs

---

## Table of Contents

1. [What's New in Appwrite](#whats-new-in-appwrite)
2. [Quick Start](#quick-start)
3. [Account Setup & Educational Benefits](#account-setup-educational-benefits)
4. [Project Configuration](#project-configuration)
5. [Database Schema](#database-schema)
6. [Authentication Setup](#authentication-setup)
7. [Storage Configuration](#storage-configuration)
8. [Configuration Checklist](#configuration-checklist)

---

## What's New in Appwrite

Appwrite has significantly evolved with many new services and features:

### Available Services

1. **Database Service** - NoSQL document database with collections
2. **Auth Service** - Complete authentication system with multiple providers
3. **Storage Service** - File storage with buckets and permissions
4. **Functions Service** - Serverless edge functions
5. **Realtime Service** - WebSocket-based real-time subscriptions
6. **Messaging Service** - Push notifications, email, and SMS
7. **Locale Service** - Internationalization support
8. **Avatars Service** - Dynamic avatar generation
9. **Teams Service** - Team and organization management

### Key Features

- **Granular Permissions** - Document-level and collection-level permissions
- **Role-Based Access** - Built-in RBAC with custom roles
- **Real-time Subscriptions** - Subscribe to database changes and auth events
- **Edge Functions** - Deploy serverless functions with multiple runtimes
- **Enhanced Security** - JWT sessions, API keys, OAuth2 providers
- **Better SDKs** - Improved client and server SDKs with TypeScript support

---

## Quick Start

### SDK Installation

Update your `pubspec.yaml`:

```yaml
dependencies:
  appwrite: ^12.0.4
```

Run:
```bash
flutter pub get
```

### Basic Configuration

```dart
import 'package:appwrite/appwrite.dart';

final client = Client()
    .setEndpoint('YOUR_ENDPOINT')
    .setProject('YOUR_PROJECT_ID');

final account = Account(client);
final databases = Databases(client);
final storage = Storage(client);
```

---

## Account Setup & Educational Benefits

### Creating Your Account

1. Go to https://cloud.appwrite.io
2. Sign up with your educational email
3. Verify your email address
4. Create your first project

### Educational Benefits

Appwrite offers free educational benefits for students and educators:

#### Benefits Include:
- **Free Tier**: Generous free tier for development
- **Educational Support**: Priority support for educational institutions
- **Learning Resources**: Access to tutorials and documentation
- **Community Access**: Join the educational community

#### How to Apply:
1. Visit https://appwrite.io/education
2. Submit application with:
   - Educational email address
   - Student/Faculty ID
   - Brief project description
3. Wait for approval (typically 3-7 days)
4. Receive confirmation email

---

## Project Configuration

### Step 1: Create Project

1. Log in to Appwrite Console
2. Click "Create Project"
3. Enter project details:
   - **Name**: RPI Communication App
   - **Region**: Select closest region (e.g., Singapore for Asia)
4. Note your credentials:
   - **Project ID**: Save this
   - **API Endpoint**: Save this

### Step 2: Enable Services

Enable these services in your project:
- ✅ Authentication
- ✅ Databases
- ✅ Storage
- ✅ Functions (optional)
- ✅ Realtime

### Step 3: Configure Platforms

Add your Flutter app platform:

1. Go to Project Settings > Platforms
2. Click "Add Platform" > "Flutter App"
3. Enter details:
   - **Application Name**: RPI Communication App
   - **Package/Bundle ID**: Your app bundle ID
   - **iOS Bundle ID**: Your iOS bundle ID (if applicable)

---

## Database Schema

### Database Structure

**Database Name**: `rpi_communication`  
**Database ID**: `rpi_communication`

### Collections

#### 1. Users Collection
- **Collection ID**: `users`
- **Purpose**: Store user profile information

**Attributes:**
- `userId` (string, required) - User's auth ID
- `email` (string, required) - User's email
- `name` (string, required) - Full name
- `role` (string, required) - admin/teacher/student
- `department` (string) - Academic department
- `enrollmentYear` (integer) - Year of enrollment
- `phone` (string) - Contact number
- `profileImageUrl` (string) - Profile picture URL
- `createdAt` (datetime) - Account creation date
- `updatedAt` (datetime) - Last update date

**Permissions:**
- Read: `user:[USER_ID]`, `role:admin`
- Create: `role:admin`
- Update: `user:[USER_ID]`, `role:admin`
- Delete: `role:admin`

#### 2. Messages Collection
- **Collection ID**: `messages`
- **Purpose**: Store chat messages

**Attributes:**
- `senderId` (string, required) - Sender's user ID
- `receiverId` (string, required) - Receiver's user ID
- `message` (string, required) - Message content
- `timestamp` (datetime, required) - Message time
- `isRead` (boolean) - Read status
- `attachments` (string[]) - File attachment IDs

**Permissions:**
- Read: `user:[SENDER_ID]`, `user:[RECEIVER_ID]`, `role:admin`
- Create: `users`
- Update: `user:[SENDER_ID]`, `user:[RECEIVER_ID]`
- Delete: `user:[SENDER_ID]`, `role:admin`

#### 3. Notices Collection
- **Collection ID**: `notices`
- **Purpose**: Store announcements and notices

**Attributes:**
- `title` (string, required) - Notice title
- `content` (string, required) - Notice content
- `authorId` (string, required) - Author's user ID
- `authorName` (string, required) - Author's name
- `department` (string) - Target department
- `priority` (string) - high/medium/low
- `createdAt` (datetime, required) - Creation time
- `expiresAt` (datetime) - Expiration date
- `attachments` (string[]) - File attachment IDs
- `isActive` (boolean) - Active status

**Permissions:**
- Read: `users`
- Create: `role:teacher`, `role:admin`
- Update: `user:[AUTHOR_ID]`, `role:admin`
- Delete: `user:[AUTHOR_ID]`, `role:admin`

### Creating Collections

Use the Appwrite Console:

1. Navigate to Databases > Create Database
2. Set Database ID: `rpi_communication`
3. Create each collection using the schema above
4. Add attributes one by one
5. Configure permissions for each collection
6. Create indexes for frequently queried fields

### Recommended Indexes

For better performance, create these indexes:

**Users Collection:**
- Index on `userId`
- Index on `email`
- Index on `role`

**Messages Collection:**
- Index on `senderId`
- Index on `receiverId`
- Index on `timestamp`

**Notices Collection:**
- Index on `authorId`
- Index on `department`
- Index on `createdAt`

---

## Authentication Setup

### Enable Authentication Providers

1. Go to Auth section in Appwrite Console
2. Enable these methods:
   - ✅ Email/Password
   - ✅ Email OTP (optional)
   - ✅ Phone (optional)

### Configure Email Settings

1. Go to Settings > SMTP
2. Configure email provider (or use Appwrite's default)
3. Test email delivery

### Authentication in Code

```dart
// Register new user
try {
  final user = await account.create(
    userId: ID.unique(),
    email: email,
    password: password,
    name: name,
  );
  print('User created: ${user.$id}');
} catch (e) {
  print('Error creating user: $e');
}

// Login
try {
  final session = await account.createEmailPasswordSession(
    email: email,
    password: password,
  );
  print('Session created: ${session.$id}');
} catch (e) {
  print('Error logging in: $e');
}

// Get current user
try {
  final user = await account.get();
  print('Current user: ${user.email}');
} catch (e) {
  print('Error getting user: $e');
}

// Logout
try {
  await account.deleteSession(sessionId: 'current');
  print('Logged out successfully');
} catch (e) {
  print('Error logging out: $e');
}
```

---

## Storage Configuration

### Create Storage Buckets

1. Go to Storage section in Appwrite Console
2. Create buckets:
   - **profile_images** - User profile pictures
   - **message_attachments** - Chat attachments
   - **notice_attachments** - Notice documents

### Configure Bucket Settings

For each bucket:

**Permissions:**
- Read: `users`
- Create: `users`
- Update: `user:[USER_ID]`
- Delete: `user:[USER_ID]`, `role:admin`

**Settings:**
- Maximum file size: 10 MB (adjust as needed)
- Allowed file extensions: jpg, jpeg, png, pdf, doc, docx
- Enable compression: Yes (for images)

### File Upload Example

```dart
try {
  final file = await storage.createFile(
    bucketId: 'profile_images',
    fileId: ID.unique(),
    file: InputFile.fromPath(
      path: filePath,
      filename: fileName,
    ),
  );
  
  // Get file URL
  final fileUrl = storage.getFileView(
    bucketId: 'profile_images',
    fileId: file.$id,
  );
  
  print('File uploaded: $fileUrl');
} catch (e) {
  print('Error uploading file: $e');
}
```

---

## Configuration Checklist

Use this checklist to ensure complete setup:

### Phase 1: Account & Project
- [ ] Create Appwrite account
- [ ] Apply for educational benefits (optional)
- [ ] Create project
- [ ] Note Project ID and Endpoint
- [ ] Add Flutter platform

### Phase 2: Authentication
- [ ] Enable Email/Password authentication
- [ ] Configure SMTP settings
- [ ] Test user registration
- [ ] Test user login
- [ ] Configure password policies

### Phase 3: Database
- [ ] Create database: `rpi_communication`
- [ ] Create Users collection
- [ ] Create Messages collection
- [ ] Create Notices collection
- [ ] Set up collection permissions
- [ ] Create indexes
- [ ] Test CRUD operations

### Phase 4: Storage
- [ ] Create profile_images bucket
- [ ] Create message_attachments bucket
- [ ] Create notice_attachments bucket
- [ ] Configure bucket permissions
- [ ] Set file size limits
- [ ] Test file uploads

### Phase 5: App Integration
- [ ] Add Appwrite SDK to pubspec.yaml
- [ ] Configure Client in app
- [ ] Test authentication flow
- [ ] Test database operations
- [ ] Test file uploads
- [ ] Enable real-time subscriptions

### Phase 6: Production Readiness
- [ ] Review all permissions
- [ ] Set up API keys (if needed)
- [ ] Configure rate limits
- [ ] Set up monitoring
- [ ] Test production endpoints
- [ ] Document API credentials securely

---

## Real-time Subscriptions

Enable real-time updates for better user experience:

```dart
// Subscribe to new messages
final realtime = Realtime(client);
final subscription = realtime.subscribe([
  'databases.rpi_communication.collections.messages.documents'
]);

subscription.stream.listen((response) {
  if (response.events.contains('databases.*.collections.*.documents.*.create')) {
    print('New message received!');
    // Handle new message
  }
});
```

---

## Troubleshooting

### Common Issues

**Issue: "Project not found"**
- Solution: Verify Project ID is correct
- Check endpoint URL

**Issue: "Permission denied"**
- Solution: Review collection/bucket permissions
- Ensure user is authenticated
- Check role-based permissions

**Issue: "File upload fails"**
- Solution: Check file size limits
- Verify file extension is allowed
- Ensure bucket permissions are correct

**Issue: "Cannot connect to Appwrite"**
- Solution: Check internet connection
- Verify endpoint URL
- Check API status at https://status.appwrite.io

---

## Additional Resources

- **Official Docs**: https://appwrite.io/docs
- **Community Discord**: https://appwrite.io/discord
- **GitHub**: https://github.com/appwrite/appwrite
- **Examples**: https://github.com/appwrite/demos-for-flutter

---

**For more specific information:**
- See [DEPLOYMENT.md](DEPLOYMENT.md) for production deployment
- See [SECURITY.md](SECURITY.md) for security best practices
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues

