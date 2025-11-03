# Free-Tier Architecture Guide

This document explains how the RPI Communication App is designed to run entirely on Firebase's free tier, making it suitable for college projects and small-scale deployments.

## Overview

The app has been refactored to **eliminate the need for Cloud Functions**, which require a paid Firebase plan (Blaze). Instead, all operations are performed using:

1. **Direct Firestore Operations** - Free for up to 50,000 reads and 20,000 writes per day
2. **Firebase Authentication** - Free for unlimited users
3. **Firebase Cloud Messaging (FCM)** - Free for unlimited push notifications
4. **Firebase Storage** - 5GB storage and 1GB/day transfer on free tier
5. **Firestore Security Rules** - Server-side validation and authorization (free)

## Changes Made

### 1. Removed Cloud Functions Dependency

**Before:**
- Used Cloud Functions for message sending, notice creation, admin approval workflows
- Required Blaze (pay-as-you-go) plan
- Additional complexity and deployment steps

**After:**
- Direct Firestore reads/writes from the mobile app
- All operations happen client-side with server-side validation via Security Rules
- No deployment or maintenance of Cloud Functions needed

### 2. Service Layer Refactoring

#### Message Service (`lib/services/message_service.dart`)
- **`sendMessage()`**: Now writes directly to `messages` collection
- **`markMessageAsRead()`**: Direct Firestore update operation
- No longer depends on `cloud_functions` package

#### Notice Service (`lib/services/notice_service.dart`)
- **`createNotice()`**: Direct write to `notices` collection with current user as author
- **`updateNotice()`**: Direct Firestore update with basic ownership verification
- Client-side validation before write

### 3. Security Implementation

Security is now enforced through **Firestore Security Rules** instead of Cloud Functions. Here's how to set them up:

#### Firestore Security Rules (firestore.rules)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isUser(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }
    
    function isAdmin() {
      return isSignedIn() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    function isTeacher() {
      return isSignedIn() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'teacher';
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create: if isUser(userId);
      allow update: if isUser(userId) || isAdmin();
      allow delete: if isAdmin();
    }
    
    // Messages collection
    match /messages/{messageId} {
      allow read: if isSignedIn() && 
                  (resource.data.senderId == request.auth.uid || 
                   resource.data.recipientId == request.auth.uid);
      allow create: if isSignedIn() && 
                    request.resource.data.senderId == request.auth.uid &&
                    request.resource.data.recipientId != request.auth.uid;
      allow update: if isSignedIn() && resource.data.recipientId == request.auth.uid;
      allow delete: if isAdmin();
    }
    
    // Notices collection
    match /notices/{noticeId} {
      allow read: if isSignedIn() && resource.data.isActive == true;
      allow create: if isTeacher() || isAdmin();
      allow update: if (isTeacher() || isAdmin()) && 
                    (resource.data.authorId == request.auth.uid || isAdmin());
      allow delete: if isAdmin();
    }
    
    // Notifications collection
    match /notifications/{notificationId} {
      allow read: if isSignedIn() && resource.data.userId == request.auth.uid;
      allow create: if isTeacher() || isAdmin();
      allow update: if isUser(resource.data.userId);
      allow delete: if isUser(resource.data.userId) || isAdmin();
    }
  }
}
```

#### Deploy Security Rules

```bash
cd /path/to/college-communication-app
firebase deploy --only firestore:rules
```

### 4. Push Notifications Without Cloud Functions

For push notifications, you have two options on the free tier:

#### Option A: Client-to-FCM-to-Client (Recommended)
1. Store FCM tokens in user documents
2. When sending a message/notice, fetch recipient's FCM token
3. Use FCM REST API or Admin SDK from a secure environment to send notifications
4. For development/testing, notifications can be sent manually from Firebase Console

#### Option B: Firestore Triggers (Alternative)
While Firebase doesn't offer Firestore triggers on free tier through Cloud Functions, you can:
1. Create a simple backend service (Node.js/Python) running on free hosting (Vercel, Railway, Render)
2. Use Firestore's `onChange` listeners to detect new messages/notices
3. Send FCM notifications via Firebase Admin SDK

This is still free as you're not using Firebase Cloud Functions.

## Free Tier Limits

### Firestore
- **Stored data**: 1 GiB
- **Document reads**: 50,000 per day
- **Document writes**: 20,000 per day
- **Document deletes**: 20,000 per day

### Firebase Authentication
- **Phone auth**: 10,000 verifications per month (free)
- **Email auth**: Unlimited (free)

### Cloud Storage
- **Stored data**: 5 GB
- **Downloaded data**: 1 GB per day

### Cloud Messaging (FCM)
- **Unlimited** push notifications

### Hosting
- **Stored data**: 10 GB
- **Downloaded data**: 360 MB per day

## Scaling Considerations

For a typical college with 500-1000 active users:

### Daily Usage Estimate
- **Reads**: ~15,000 (well within 50,000 limit)
  - Each user views ~15-30 notices/messages per day
- **Writes**: ~5,000 (well within 20,000 limit)
  - Each user sends ~5-10 messages/notices per day
- **Storage**: < 100 MB (well within 1 GiB limit)

### If You Exceed Free Limits

If your usage grows beyond free tier limits, you have options:

1. **Optimize queries**: Use pagination, limit results, cache data locally
2. **Implement rate limiting**: Prevent abuse and excessive writes
3. **Use Spark plan carefully**: Firebase won't charge you on the Spark plan; services just stop working when limits are hit
4. **Upgrade to Blaze**: Pay only for what you use beyond free quotas (very affordable for small projects)

## Migration Path

If you later want to add Cloud Functions for advanced features:

1. Keep the current direct Firestore approach for simple operations
2. Add Cloud Functions only for:
   - Complex business logic
   - Scheduled tasks (e.g., expiring old notices)
   - Integration with external services
   - Advanced analytics

The current architecture is designed to make this transition smooth.

## Development Tips

### Local Testing
```bash
cd apps/mobile
flutter pub get
flutter run
```

### Security Rules Testing
```bash
firebase emulators:start --only firestore
# Test your security rules locally
```

### Monitoring Usage
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to "Usage and Billing"
4. Monitor daily read/write operations

## Best Practices

1. **Use offline persistence** - Firestore has built-in offline support:
   ```dart
   FirebaseFirestore.instance.settings = const Settings(
     persistenceEnabled: true,
     cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
   );
   ```

2. **Implement pagination** - Don't load all data at once:
   ```dart
   .limit(20)
   .startAfterDocument(lastDocument)
   ```

3. **Use security rules** - Never trust client-side validation alone

4. **Cache aggressively** - Use `GetOptions(source: Source.cache)` when appropriate

5. **Batch operations** - Use `WriteBatch` to reduce write operations:
   ```dart
   final batch = FirebaseFirestore.instance.batch();
   batch.set(ref1, data1);
   batch.update(ref2, data2);
   await batch.commit(); // Counts as single write operation
   ```

## Support

For questions or issues:
- Check Firebase Free Tier Limits: https://firebase.google.com/pricing
- Firebase Documentation: https://firebase.google.com/docs
- Project Issues: https://github.com/mufthakherul/college-communication-app/issues

## Summary

This architecture allows the RPI Communication App to:
- ✅ Run completely free for small to medium usage
- ✅ Scale to hundreds or thousands of users on free tier
- ✅ Maintain security through Firestore Security Rules
- ✅ Provide real-time updates and push notifications
- ✅ Work offline with local data persistence
- ✅ Upgrade gracefully when needed

**No Cloud Functions = No paid plan required!**
