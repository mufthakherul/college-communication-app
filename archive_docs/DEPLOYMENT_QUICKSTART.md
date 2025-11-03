# Production Deployment - Quick Start Guide

**TL;DR**: One-page guide to deploy RPI Communication App to production.

## Prerequisites ✓

- Flutter SDK 3.0+
- Android Studio with SDK
- Appwrite account (free educational benefits)
- 30-45 minutes setup time

---

## Step 1: Appwrite Setup (15 min)

### 1.1 Create Project

```bash
1. Go to https://cloud.appwrite.io
2. Create account (use .edu email for benefits)
3. Create project: "rpi-communication"
4. Note: Project ID and Endpoint
```

### 1.2 Quick Database Setup

**Create Database**: `rpi_communication`

**Create 6 Collections** (copy IDs exactly):
- `users` - User profiles
- `notices` - Announcements
- `messages` - Direct messages
- `notifications` - Push notifications
- `approval_requests` - Admin approvals
- `user_activity` - Activity logs

**Create 3 Storage Buckets**:
- `profile-images` (5MB, images only)
- `notice-attachments` (10MB, docs/images)
- `message-attachments` (25MB, all files)

> 📖 **Detailed schema**: See [PRODUCTION_DEPLOYMENT_GUIDE.md](PRODUCTION_DEPLOYMENT_GUIDE.md) Step 2

### 1.3 Enable Authentication

```bash
Auth → Settings → Email/Password: ON
Min password length: 8 characters
```

---

## Step 2: Configure App (5 min)

### 2.1 Update Appwrite Config

Edit `apps/mobile/lib/appwrite_config.dart`:

```dart
class AppwriteConfig {
  static const String endpoint = 'https://[YOUR-REGION].cloud.appwrite.io/v1';
  static const String projectId = '[YOUR-PROJECT-ID]';
  // ... rest stays same
}
```

### 2.2 Verify Security (Production Only)

Check `apps/mobile/lib/services/demo_mode_service.dart`:

```dart
static const bool _allowDemoMode = false; // ✓ Already disabled
```

---

## Step 3: Build Release APK (10 min)

### 3.1 Generate Signing Key

```bash
keytool -genkey -v -keystore ~/rpi-release-key.keystore \
  -alias rpi-key -keyalg RSA -keysize 2048 -validity 10000
  
# Save password securely!
```

### 3.2 Configure Signing

Create `apps/mobile/android/key.properties`:

```properties
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=rpi-key
storeFile=/path/to/rpi-release-key.keystore
```

### 3.3 Build APK

```bash
cd apps/mobile
flutter clean
flutter pub get
flutter build apk --release
```

**Output**: `build/app/outputs/flutter-apk/app-release.apk`

---

## Step 4: Test (5 min)

### 4.1 Install APK

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 4.2 Quick Test Checklist

- [ ] App opens without errors
- [ ] Register new user works
- [ ] Login works
- [ ] Create notice works (if admin/teacher)
- [ ] Send message works
- [ ] Offline mode works

---

## Step 5: Create First Admin User (5 min)

### Option A: Via App

```bash
1. Register user in app
2. Go to Appwrite Console → Databases → users
3. Find user → Edit → Set role to "admin"
```

### Option B: Via Console

```bash
1. Appwrite Console → Auth → Create User
2. Fill: email, password, name
3. Databases → users → Create Document:
   {
     "name": "Admin User",
     "email": "admin@rangpur.polytech.gov.bd",
     "role": "admin",
     "department": "Administration"
   }
```

---

## Step 6: Distribute (2 min)

### Quick Distribution

**Upload APK to**:
- GitHub Releases (recommended)
- Google Drive with link sharing
- Internal file server

**Share with users**:
```
1. Download: [APK LINK]
2. Enable: Settings → Security → Unknown Sources
3. Install: Open downloaded APK
4. Login: Use college email
```

---

## Done! 🎉

**Your app is now live!**

### Next Steps

- [ ] Monitor Appwrite dashboard
- [ ] Set up Sentry (optional): crash reporting
- [ ] Set up OneSignal (optional): push notifications
- [ ] Distribute to all users
- [ ] Collect feedback

---

## Quick Troubleshooting

**Build fails?**
```bash
flutter clean && flutter pub get && flutter build apk --release
```

**Appwrite connection fails?**
- Check Project ID in `appwrite_config.dart`
- Verify internet connection
- Check Appwrite status: https://status.appwrite.io

**Login fails?**
- Verify Auth is enabled in Appwrite
- Check email/password format
- Review Appwrite Auth logs

**Security error on startup?**
- Normal for first build
- Verify Appwrite config is correct
- Check package name hasn't changed

---

## Support

📖 **Full Guide**: [PRODUCTION_DEPLOYMENT_GUIDE.md](PRODUCTION_DEPLOYMENT_GUIDE.md)  
🔒 **Security**: [SECURITY.md](SECURITY.md)  
🐛 **Issues**: [GitHub Issues](https://github.com/mufthakherul/college-communication-app/issues)

---

## Educational Benefits 🎓

Apply for **Appwrite for Education**:
- ✅ Free Pro plan ($15/month value)
- ✅ 100GB storage (10x more)
- ✅ Unlimited users
- ✅ Priority support
- 📝 Apply: https://appwrite.io/education

---

**Estimated Total Time**: 30-45 minutes  
**Cost**: $0 (completely free with Appwrite)  
**Difficulty**: Beginner-friendly

Good luck with your deployment! 🚀
