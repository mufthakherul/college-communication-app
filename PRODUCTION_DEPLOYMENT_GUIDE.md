# Production Deployment Guide - RPI Communication App

Complete guide for deploying the RPI Communication App to production with Appwrite backend.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Appwrite Setup](#appwrite-setup)
3. [Security Configuration](#security-configuration)
4. [Backend Deployment](#backend-deployment)
5. [Mobile App Build](#mobile-app-build)
6. [Testing](#testing)
7. [Distribution](#distribution)
8. [Monitoring](#monitoring)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Tools

- **Flutter SDK**: 3.0.0 or higher
  ```bash
  flutter --version
  ```

- **Android Studio**: Latest version with Android SDK
  - Min SDK: 21 (Android 5.0)
  - Target SDK: 34 (Android 14)

- **Git**: For version control
  ```bash
  git --version
  ```

- **Java JDK**: 11 or higher
  ```bash
  java -version
  ```

### Accounts Needed

1. **Appwrite Account**: https://appwrite.io
   - Apply for educational benefits: https://appwrite.io/education
   - Free Pro plan for students (normally $15/month)

2. **Sentry Account** (Optional): https://sentry.io
   - For crash reporting
   - Free tier available

3. **OneSignal Account** (Optional): https://onesignal.com
   - For push notifications
   - Free tier available

---

## Appwrite Setup

### Step 1: Create Appwrite Project

1. **Sign up / Login to Appwrite**
   - Go to https://cloud.appwrite.io
   - Create account or log in

2. **Create New Project**
   - Click "Create Project"
   - Project Name: `rpi-communication`
   - Region: Choose closest to users (e.g., Singapore)
   - Click "Create"

3. **Note Your Project Credentials**
   ```
   Project ID: [Your Project ID]
   API Endpoint: https://[region].cloud.appwrite.io/v1
   ```

### Step 2: Configure Database

1. **Create Database**
   - Go to "Databases" in left sidebar
   - Click "Create Database"
   - Database Name: `rpi_communication`
   - Database ID: `rpi_communication` (use this exact ID)

2. **Create Collections**

   **Collection 1: users**
   - Collection ID: `users`
   - Attributes:
     ```
     - name (String, 100, required)
     - email (Email, required)
     - role (String, 20, required) [admin, teacher, student]
     - department (String, 50)
     - semester (String, 20)
     - profileImageUrl (URL)
     - createdAt (DateTime, required)
     - updatedAt (DateTime, required)
     ```
   - Indexes:
     ```
     - email (unique, asc)
     - role (asc)
     - department (asc)
     ```

   **Collection 2: notices**
   - Collection ID: `notices`
   - Attributes:
     ```
     - title (String, 200, required)
     - content (String, 5000, required)
     - authorId (String, 100, required)
     - authorName (String, 100, required)
     - type (String, 20, required) [general, urgent, academic, event]
     - priority (String, 20) [low, medium, high]
     - attachments (String, 2000) [JSON array]
     - targetAudience (String, 500) [JSON array]
     - expiresAt (DateTime)
     - createdAt (DateTime, required)
     - updatedAt (DateTime, required)
     ```
   - Indexes:
     ```
     - createdAt (desc)
     - type (asc)
     - priority (asc)
     - authorId (asc)
     ```

   **Collection 3: messages**
   - Collection ID: `messages`
   - Attributes:
     ```
     - senderId (String, 100, required)
     - senderName (String, 100, required)
     - recipientId (String, 100, required)
     - recipientName (String, 100, required)
     - content (String, 2000, required)
     - attachments (String, 2000) [JSON array]
     - isRead (Boolean, required, default: false)
     - readAt (DateTime)
     - createdAt (DateTime, required)
     ```
   - Indexes:
     ```
     - senderId (asc)
     - recipientId (asc)
     - createdAt (desc)
     - isRead (asc)
     ```

   **Collection 4: notifications**
   - Collection ID: `notifications`
   - Attributes:
     ```
     - userId (String, 100, required)
     - title (String, 200, required)
     - message (String, 500, required)
     - type (String, 20, required)
     - relatedId (String, 100)
     - isRead (Boolean, required, default: false)
     - readAt (DateTime)
     - createdAt (DateTime, required)
     ```
   - Indexes:
     ```
     - userId (asc)
     - createdAt (desc)
     - isRead (asc)
     ```

   **Collection 5: approval_requests**
   - Collection ID: `approval_requests`
   - Attributes:
     ```
     - requesterId (String, 100, required)
     - requesterName (String, 100, required)
     - type (String, 50, required)
     - content (String, 2000, required)
     - status (String, 20, required) [pending, approved, rejected]
     - reviewerId (String, 100)
     - reviewerName (String, 100)
     - reviewNotes (String, 1000)
     - createdAt (DateTime, required)
     - updatedAt (DateTime, required)
     ```
   - Indexes:
     ```
     - status (asc)
     - requesterId (asc)
     - createdAt (desc)
     ```

   **Collection 6: user_activity**
   - Collection ID: `user_activity`
   - Attributes:
     ```
     - userId (String, 100, required)
     - activityType (String, 50, required)
     - description (String, 500)
     - metadata (String, 2000) [JSON]
     - timestamp (DateTime, required)
     ```
   - Indexes:
     ```
     - userId (asc)
     - timestamp (desc)
     - activityType (asc)
     ```

### Step 3: Configure Permissions

For each collection, set permissions:

1. **users collection**:
   - Read: Any authenticated user
   - Create: Any authenticated user (registration)
   - Update: Document owner only
   - Delete: Admin only

2. **notices collection**:
   - Read: Any authenticated user
   - Create: Admin and Teacher roles
   - Update: Document owner only
   - Delete: Document owner or Admin

3. **messages collection**:
   - Read: Sender or Recipient only
   - Create: Any authenticated user
   - Update: Sender only (for read status)
   - Delete: Sender or Recipient

4. **notifications collection**:
   - Read: Document owner (userId match)
   - Create: System only (via functions)
   - Update: Document owner (read status)
   - Delete: Document owner

5. **approval_requests collection**:
   - Read: Requester or Admins
   - Create: Any authenticated user
   - Update: Admin only
   - Delete: Admin only

6. **user_activity collection**:
   - Read: Admin only
   - Create: Any authenticated user
   - Update: None
   - Delete: Admin only

### Step 4: Configure Storage

1. **Create Storage Buckets**

   **Bucket 1: profile-images**
   - Bucket ID: `profile-images`
   - Max File Size: 5 MB
   - Allowed File Types: `jpg, jpeg, png, gif`
   - Permissions:
     - Read: Any authenticated user
     - Create: Any authenticated user
     - Update: File owner only
     - Delete: File owner only

   **Bucket 2: notice-attachments**
   - Bucket ID: `notice-attachments`
   - Max File Size: 10 MB
   - Allowed File Types: `pdf, doc, docx, jpg, jpeg, png`
   - Permissions:
     - Read: Any authenticated user
     - Create: Admin and Teacher roles
     - Update: File owner only
     - Delete: File owner only

   **Bucket 3: message-attachments**
   - Bucket ID: `message-attachments`
   - Max File Size: 25 MB
   - Allowed File Types: `pdf, doc, docx, jpg, jpeg, png, zip`
   - Permissions:
     - Read: Sender or recipient only
     - Create: Any authenticated user
     - Update: None
     - Delete: File owner only

### Step 5: Configure Authentication

1. **Enable Email/Password Authentication**
   - Go to "Auth" → "Settings"
   - Enable "Email/Password"
   - Configure password settings:
     - Minimum length: 8 characters
     - Require uppercase: Yes
     - Require numbers: Yes
     - Require special characters: No (optional)

2. **Configure Session Settings**
   - Session length: 365 days
   - Enable "Remember me": Yes

3. **Email Verification** (Optional but recommended)
   - Enable email verification
   - Configure SMTP settings or use Appwrite's default

### Step 6: Update App Configuration

1. **Update Appwrite Config File**

   Edit `apps/mobile/lib/appwrite_config.dart`:

   ```dart
   class AppwriteConfig {
     // Your actual project credentials
     static const String endpoint = 'https://[YOUR-REGION].cloud.appwrite.io/v1';
     static const String projectId = '[YOUR-PROJECT-ID]';
     
     // Database configuration
     static const String databaseId = 'rpi_communication';
     
     // Collection IDs (should match what you created)
     static const String usersCollectionId = 'users';
     static const String noticesCollectionId = 'notices';
     static const String messagesCollectionId = 'messages';
     static const String notificationsCollectionId = 'notifications';
     static const String approvalRequestsCollectionId = 'approval_requests';
     static const String userActivityCollectionId = 'user_activity';
     
     // Storage bucket IDs (should match what you created)
     static const String profileImagesBucketId = 'profile-images';
     static const String noticeAttachmentsBucketId = 'notice-attachments';
     static const String messageAttachmentsBucketId = 'message-attachments';
   }
   ```

---

## Security Configuration

### Step 1: Generate Signing Key

For production APK signing:

```bash
# Navigate to Android app directory
cd apps/mobile/android/app

# Generate release keystore
keytool -genkey -v -keystore ~/rpi-release-key.keystore \
  -alias rpi-key \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000

# Follow prompts to set password and information
# IMPORTANT: Save password securely!
```

**Store Keystore Securely:**
- DO NOT commit to Git
- Store in secure location (password manager)
- Back up to secure cloud storage

### Step 2: Configure Signing in Build

Create `apps/mobile/android/key.properties`:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=rpi-key
storeFile=/path/to/rpi-release-key.keystore
```

**Add to .gitignore:**
```bash
echo "android/key.properties" >> .gitignore
```

### Step 3: Update Build Configuration

Edit `apps/mobile/android/app/build.gradle`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### Step 4: Security Checklist

- [x] Demo mode disabled for production (in `demo_mode_service.dart`)
- [x] ProGuard enabled with aggressive obfuscation
- [x] Security checks implemented (root detection, integrity checks)
- [x] Secure storage for sensitive data
- [ ] HTTPS only (enforced by Appwrite)
- [ ] Certificate pinning (optional, for advanced security)
- [ ] API rate limiting (configure in Appwrite)
- [ ] Regular security audits

---

## Backend Deployment

### Step 1: Verify Appwrite Configuration

```bash
# Test Appwrite connection
curl https://[YOUR-REGION].cloud.appwrite.io/v1/health
```

Should return: `{"status":"OK"}`

### Step 2: Create Initial Admin User

You have two options:

**Option A: Register Through App**
1. Build and install app
2. Register first user
3. Manually promote to admin in Appwrite console:
   - Go to Databases → users collection
   - Find user document
   - Edit `role` field to `admin`

**Option B: Create via Appwrite Console**
1. Go to "Auth" → "Users"
2. Click "Create User"
3. Fill in details
4. Then create user document in `users` collection with:
   ```json
   {
     "name": "Admin User",
     "email": "admin@rangpur.polytech.gov.bd",
     "role": "admin",
     "department": "Administration",
     "createdAt": "2024-01-01T00:00:00.000Z",
     "updatedAt": "2024-01-01T00:00:00.000Z"
   }
   ```

---

## Mobile App Build

### Step 1: Update Version

Edit `apps/mobile/pubspec.yaml`:

```yaml
version: 1.0.0+1  # Increment for each release
```

### Step 2: Build Release APK

```bash
# Navigate to mobile app directory
cd apps/mobile

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Or build app bundle for Google Play
flutter build appbundle --release
```

**Build Output Locations:**
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### Step 3: Build with Optional Features

**With Sentry (Crash Reporting):**
```bash
flutter build apk --release \
  --dart-define=SENTRY_DSN=https://your-sentry-dsn@sentry.io/project
```

**With OneSignal (Push Notifications):**
```bash
flutter build apk --release \
  --dart-define=ONESIGNAL_APP_ID=your-onesignal-app-id
```

**With Both:**
```bash
flutter build apk --release \
  --dart-define=SENTRY_DSN=https://your-sentry-dsn@sentry.io/project \
  --dart-define=ONESIGNAL_APP_ID=your-onesignal-app-id
```

### Step 4: Verify Build

```bash
# Check APK signature
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk

# Check APK size
du -h build/app/outputs/flutter-apk/app-release.apk

# Install and test on device
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## Testing

### Pre-Release Testing Checklist

**Authentication:**
- [ ] User registration works
- [ ] Email validation works
- [ ] Login/logout works
- [ ] Password reset works (if enabled)
- [ ] Session persistence works

**Notices:**
- [ ] Admin/Teacher can create notices
- [ ] Students can view notices
- [ ] Notice types work correctly
- [ ] Attachments upload/download
- [ ] Search functionality works

**Messages:**
- [ ] Send messages between users
- [ ] Receive notifications
- [ ] Mark as read works
- [ ] Attachments work
- [ ] Message search works

**Security:**
- [ ] Demo mode is disabled
- [ ] Security checks run on startup
- [ ] ProGuard obfuscation works
- [ ] No sensitive data in logs
- [ ] App works on rooted devices (with warning)

**Offline Mode:**
- [ ] Cached data accessible offline
- [ ] Actions queued when offline
- [ ] Auto-sync when back online
- [ ] Connectivity indicator works

**UI/UX:**
- [ ] Dark mode works
- [ ] Theme persistence works
- [ ] All screens responsive
- [ ] No UI glitches
- [ ] Proper error messages

---

## Distribution

### Method 1: Direct APK Distribution

**For Internal Testing:**

1. Upload APK to secure location:
   - Google Drive (with link sharing)
   - GitHub Releases
   - Internal file server

2. Share installation instructions:
   ```
   1. Download APK file
   2. Enable "Install from Unknown Sources" in Android settings
   3. Open APK file to install
   4. Grant necessary permissions
   ```

### Method 2: Google Play Store

**For Public Release:**

1. **Prepare Store Listing:**
   - App name: RPI Communication
   - Description: College communication app for Rangpur Polytechnic Institute
   - Screenshots (5-8 images)
   - Feature graphic (1024x500)
   - Icon (512x512)

2. **Upload to Play Console:**
   - Go to https://play.google.com/console
   - Create app
   - Upload AAB file (not APK)
   - Fill in store listing
   - Set up pricing (Free)
   - Submit for review

3. **Release Process:**
   - Internal testing → Closed testing → Open testing → Production
   - Each stage requires testing and approval

### Method 3: GitHub Actions (Automated)

Already configured! Just push code:

```bash
git add .
git commit -m "Release v1.0.0"
git tag v1.0.0
git push origin main --tags
```

APK will be available in:
- GitHub Actions → Latest workflow run → Artifacts
- GitHub Releases (if tag pushed)

---

## Monitoring

### Step 1: Set Up Sentry (Crash Reporting)

1. Create Sentry account: https://sentry.io
2. Create new project (Flutter)
3. Get DSN from project settings
4. Build app with Sentry DSN (see Build section)

### Step 2: Set Up OneSignal (Push Notifications)

1. Create OneSignal account: https://onesignal.com
2. Create new app
3. Configure Android platform:
   - Upload Firebase Cloud Messaging key
   - Get OneSignal App ID
4. Build app with OneSignal App ID

### Step 3: Monitor Appwrite

**In Appwrite Console:**
- Monitor usage in "Usage" tab
- Check logs in "Logs" tab
- Review active sessions in "Auth" tab

**Set Up Alerts:**
- Database storage usage
- API rate limits
- Error rates

---

## Troubleshooting

### Build Issues

**Issue: Flutter command not found**
```bash
# Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"

# Or install Flutter
git clone https://github.com/flutter/flutter.git
cd flutter
./bin/flutter doctor
```

**Issue: Gradle build fails**
```bash
# Clear gradle cache
cd android
./gradlew clean

# Update gradle wrapper
./gradlew wrapper --gradle-version=8.0
```

**Issue: Signing key not found**
```bash
# Verify key.properties path
cat android/key.properties

# Verify keystore exists
ls -la ~/rpi-release-key.keystore
```

### Runtime Issues

**Issue: Appwrite connection fails**
- Check Project ID in `appwrite_config.dart`
- Verify API endpoint URL
- Check internet connection
- Review Appwrite console logs

**Issue: Authentication fails**
- Verify Auth is enabled in Appwrite
- Check email/password validation rules
- Review Appwrite Auth logs
- Check user permissions

**Issue: Database operations fail**
- Verify collection IDs match config
- Check database permissions
- Review Appwrite database logs
- Verify indexes are created

**Issue: File upload fails**
- Check bucket permissions
- Verify file size limits
- Check allowed file types
- Review storage quota

### Security Issues

**Issue: Security check blocks app**
- Review security logs
- Verify package name is correct
- Check Appwrite project ID
- Disable strict checks if false positive

**Issue: App won't run on rooted device**
- Expected behavior in production
- Users will see warning but can proceed
- Don't block entirely to avoid UX issues

---

## Post-Deployment

### Regular Maintenance

**Daily:**
- Monitor crash reports (Sentry)
- Check user feedback
- Review Appwrite logs

**Weekly:**
- Review analytics
- Check database growth
- Monitor storage usage
- Update content as needed

**Monthly:**
- Security audit
- Dependency updates
- Performance review
- User surveys

### Updates and Releases

1. **Increment version** in `pubspec.yaml`
2. **Update changelog**
3. **Test thoroughly**
4. **Build new APK/AAB**
5. **Distribute to users**

---

## Support

**For Issues:**
- GitHub Issues: https://github.com/mufthakherul/college-communication-app/issues
- Appwrite Docs: https://appwrite.io/docs
- Flutter Docs: https://docs.flutter.dev

**Contact:**
- Developer: Mufthakherul
- Institution: Rangpur Polytechnic Institute
- Website: https://rangpur.polytech.gov.bd

---

## Summary Checklist

**Appwrite Setup:**
- [ ] Project created
- [ ] Database and collections configured
- [ ] Storage buckets configured
- [ ] Authentication enabled
- [ ] Permissions set correctly

**Security:**
- [ ] Signing key generated
- [ ] key.properties configured
- [ ] Demo mode disabled
- [ ] ProGuard enabled
- [ ] Security checks tested

**Build:**
- [ ] Version updated
- [ ] Dependencies updated
- [ ] Release APK built
- [ ] APK signed correctly
- [ ] APK tested on devices

**Distribution:**
- [ ] APK uploaded to distribution platform
- [ ] Installation instructions provided
- [ ] Users can access and install

**Monitoring:**
- [ ] Sentry configured (optional)
- [ ] OneSignal configured (optional)
- [ ] Appwrite monitoring set up
- [ ] Alerts configured

**You're ready for production! 🚀**
