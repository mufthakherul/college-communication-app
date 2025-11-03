# Quick Start Guide

Get the RPI Communication App up and running in under 30 minutes!

## Prerequisites

- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher
- Android Studio / VS Code
- Git
- An Appwrite account (free)

---

## Step 1: Clone Repository

```bash
git clone https://github.com/mufthakherul/college-communication-app.git
cd college-communication-app
```

---

## Step 2: Install Dependencies

```bash
flutter pub get
```

---

## Step 3: Setup Appwrite Backend

### Create Appwrite Account

1. Go to [Appwrite Cloud](https://cloud.appwrite.io)
2. Sign up with your email
3. Verify your email
4. Create a new project

### Get Your Credentials

After creating your project, note these:
- **Project ID**: Found in project settings
- **API Endpoint**: Usually `https://cloud.appwrite.io/v1` or region-specific

### Configure in App

Create or update `lib/config/appwrite_config.dart`:

```dart
class AppwriteConfig {
  static const String endpoint = 'YOUR_APPWRITE_ENDPOINT';
  static const String projectId = 'YOUR_PROJECT_ID';
  static const String databaseId = 'rpi_communication';
}
```

### Setup Database

1. In Appwrite Console, go to **Databases**
2. Create a new database named `rpi_communication`
3. Create collections (see [APPWRITE_GUIDE.md](APPWRITE_GUIDE.md) for detailed schema):
   - `users` - User profiles
   - `messages` - Chat messages
   - `notices` - Announcements

Quick collection setup:
- Go to each collection
- Add attributes as per schema
- Configure permissions:
  - Users: Read by any user, write by admin
  - Messages: Read/write by sender and receiver
  - Notices: Read by all, write by teacher/admin

### Setup Authentication

1. In Appwrite Console, go to **Auth**
2. Enable **Email/Password** authentication
3. (Optional) Enable **Email OTP** for passwordless login

### Setup Storage

1. In Appwrite Console, go to **Storage**
2. Create buckets:
   - `profile_images`
   - `message_attachments`
   - `notice_attachments`
3. Configure permissions for each bucket

**Detailed setup**: See [APPWRITE_GUIDE.md](APPWRITE_GUIDE.md) for complete database schema and configuration.

---

## Step 4: Configure Firebase (Optional)

If you want to use Firebase features:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project or use existing
3. Add Android/iOS apps
4. Download configuration files:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`

**Note**: Firebase is optional. The app primarily uses Appwrite.

---

## Step 5: Run the App

### On Android Emulator/Device

```bash
flutter run
```

### On iOS Simulator/Device

```bash
flutter run
```

### Build APK (Android)

```bash
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

---

## Step 6: First Time Setup

### Create Admin Account

1. Launch the app
2. Tap "Sign Up"
3. Create first account with your email
4. Go to Appwrite Console → Database → Users collection
5. Find your user and change `role` to `admin`
6. Restart the app

### Test Features

As an admin, you can:
- ✅ Create notices
- ✅ Send messages
- ✅ Manage users
- ✅ View analytics

### Create Test Users

Create additional test accounts:
- Teacher account (set role to `teacher`)
- Student account (set role to `student`)

Test communication between accounts!

---

## Common Setup Issues

### Issue: "Unable to connect to Appwrite"

**Solution:**
- Verify your endpoint URL is correct
- Check your internet connection
- Ensure project ID is correct
- Check Appwrite status at https://status.appwrite.io

### Issue: "Permission denied"

**Solution:**
- Review collection permissions in Appwrite Console
- Ensure user is authenticated
- Check if user has correct role assigned

### Issue: "Build failed"

**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: "Cannot find google-services.json"

**Solution:**
- If not using Firebase, remove Firebase dependencies from `pubspec.yaml`
- Or download the file from Firebase Console

---

## Next Steps

Now that your app is running:

1. **Customize the app**:
   - Update app name and logo
   - Customize theme colors
   - Add your institution's branding

2. **Configure features**:
   - Enable mesh networking (see [NETWORKING_GUIDE.md](NETWORKING_GUIDE.md))
   - Setup push notifications
   - Configure offline mode

3. **Prepare for production**:
   - Review [DEPLOYMENT.md](DEPLOYMENT.md) for deployment guide
   - Check [SECURITY.md](SECURITY.md) for security best practices
   - Read [PRODUCTION_DEPLOYMENT_GUIDE.md](../PRODUCTION_DEPLOYMENT_GUIDE.md) for production checklist

4. **Learn more**:
   - Read [ARCHITECTURE.md](ARCHITECTURE.md) to understand the code structure
   - See [CONTRIBUTING.md](CONTRIBUTING.md) to contribute
   - Check [API.md](API.md) for API documentation

---

## Development Tips

### Hot Reload

While app is running, press:
- `r` - Hot reload
- `R` - Hot restart
- `q` - Quit

### Debug Mode

Run with debug flags:
```bash
flutter run --debug
```

### View Logs

```bash
flutter logs
```

### Check for Issues

```bash
flutter doctor
```

---

## Need Help?

- **Documentation**: See the `docs/` folder for detailed guides
- **Issues**: Report at [GitHub Issues](https://github.com/mufthakherul/college-communication-app/issues)
- **Appwrite Support**: https://appwrite.io/discord
- **Flutter Help**: https://flutter.dev/community

---

**Ready to build?** 🚀

Start developing by exploring:
- `lib/` - Application code
- `lib/screens/` - UI screens
- `lib/services/` - Backend services
- `lib/models/` - Data models

**Happy coding!** 💙

