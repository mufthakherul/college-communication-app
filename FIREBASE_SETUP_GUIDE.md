# Firebase Setup Guide for RPI Communication App

## 🔥 Connecting Your App to Firebase

The app code is complete, but it needs to be connected to a Firebase project to work. This guide will walk you through the setup process.

## Why Firebase Connection is Needed

Your app uses Firebase for:
- **Authentication** - User login/registration
- **Firestore Database** - Storing notices, messages, user profiles
- **Cloud Storage** - Storing uploaded files and images
- **Cloud Functions** - Backend business logic
- **Cloud Messaging** - Push notifications

Currently, the app has placeholder configuration values that need to be replaced with your actual Firebase project details.

## 📋 Prerequisites

Before starting, you'll need:
- A Google account
- Node.js and npm installed
- Firebase CLI installed: `npm install -g firebase-tools`
- Flutter installed (for running `flutterfire configure`)

## 🚀 Step-by-Step Setup

### Step 1: Create Firebase Project

1. **Go to Firebase Console:**
   - Visit: https://console.firebase.google.com
   - Sign in with your Google account

2. **Create a New Project:**
   - Click "Add project"
   - Project name: `rpi-communication` (or your preferred name)
   - Click "Continue"
   - Disable Google Analytics (optional, can enable later)
   - Click "Create project"
   - Wait for project creation (takes ~1 minute)

### Step 2: Enable Firebase Services

Once your project is created:

#### 2.1 Enable Authentication

1. In Firebase Console, click "Authentication" in left menu
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" provider
5. Click "Save"

#### 2.2 Create Firestore Database

1. Click "Firestore Database" in left menu
2. Click "Create database"
3. Select "Start in production mode" (we'll deploy security rules later)
4. Choose a location (select closest to Bangladesh, e.g., asia-south1)
5. Click "Enable"

#### 2.3 Enable Cloud Storage

1. Click "Storage" in left menu
2. Click "Get started"
3. Start in production mode
4. Use same location as Firestore
5. Click "Done"

#### 2.4 Enable Cloud Functions

1. Click "Functions" in left menu
2. Click "Get started"
3. Upgrade to Blaze plan (pay-as-you-go, has free tier)
   - Note: Free tier includes 2M function invocations/month
   - You won't be charged unless you exceed free limits

### Step 3: Configure Your App

#### Option A: Using FlutterFire CLI (Recommended)

1. **Install FlutterFire CLI:**
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   ```

2. **Login to Firebase:**
   ```bash
   firebase login
   ```

3. **Configure your Flutter app:**
   ```bash
   cd apps/mobile
   flutterfire configure
   ```

4. **Follow the prompts:**
   - Select your Firebase project
   - Select platforms: Android (and iOS if needed)
   - Choose the package name: `gov.bd.polytech.rgpi.communication.develop.by.mufthakherul`
   
5. **This will:**
   - Generate `lib/firebase_options.dart` with real values
   - Download `google-services.json` for Android
   - Download `GoogleService-Info.plist` for iOS

#### Option B: Manual Configuration

If FlutterFire CLI doesn't work, you can configure manually:

##### For Android:

1. **In Firebase Console:**
   - Click gear icon (⚙️) → Project settings
   - Scroll to "Your apps" section
   - Click Android icon to add Android app
   
2. **Register app:**
   - Package name: `gov.bd.polytech.rgpi.communication.develop.by.mufthakherul`
   - App nickname: "RPI Communication Android"
   - Click "Register app"

3. **Download config file:**
   - Download `google-services.json`
   - Place it in: `apps/mobile/android/app/google-services.json`

4. **Update firebase_options.dart:**
   - Get values from Firebase Console → Project Settings → General
   - Update the `android` configuration in `firebase_options.dart`

### Step 4: Deploy Backend

1. **Set Firebase project:**
   ```bash
   cd /path/to/college-communication-app
   firebase use --add
   # Select your project and give it an alias (e.g., 'default')
   ```

2. **Update .firebaserc:**
   ```json
   {
     "projects": {
       "default": "your-project-id"
     }
   }
   ```

3. **Install dependencies:**
   ```bash
   cd functions
   npm install
   ```

4. **Build TypeScript:**
   ```bash
   npm run build
   ```

5. **Deploy Firestore Rules:**
   ```bash
   firebase deploy --only firestore:rules
   ```

6. **Deploy Storage Rules:**
   ```bash
   firebase deploy --only storage:rules
   ```

7. **Deploy Cloud Functions:**
   ```bash
   firebase deploy --only functions
   ```

### Step 5: Test Your Connection

1. **Build and run the app:**
   ```bash
   cd apps/mobile
   flutter run
   ```

2. **Test user registration:**
   - Open the app
   - Click "Register"
   - Enter name, email, password
   - Click "Create Account"
   - If successful, you'll be logged in!

3. **Verify in Firebase Console:**
   - Go to Authentication → Users
   - You should see your new user listed

## 🎯 Quick Setup Script

For faster setup, you can use this script:

```bash
#!/bin/bash

# Quick Firebase Setup Script
echo "🔥 Firebase Setup for RPI Communication"

# 1. Login to Firebase
firebase login

# 2. Set project (you'll need to select your project)
firebase use --add

# 3. Configure Flutter app
cd apps/mobile
flutterfire configure
cd ../..

# 4. Install and build functions
cd functions
npm install
npm run build
cd ..

# 5. Deploy everything
firebase deploy --only firestore:rules,storage:rules,functions

echo "✅ Setup complete!"
echo "📱 You can now run: cd apps/mobile && flutter run"
```

Save this as `setup-firebase.sh` and run:
```bash
chmod +x setup-firebase.sh
./setup-firebase.sh
```

## 🔍 Verification Checklist

After setup, verify:

- [ ] `apps/mobile/android/app/google-services.json` exists
- [ ] `apps/mobile/lib/firebase_options.dart` has real values (not 'YOUR_API_KEY')
- [ ] Firebase Console shows your project
- [ ] Authentication is enabled in Firebase Console
- [ ] Firestore database is created
- [ ] Storage bucket is created
- [ ] Functions are deployed (check Firebase Console → Functions)
- [ ] Security rules are deployed

## 📱 Testing the App

Once Firebase is connected:

1. **Build APK:**
   ```bash
   cd apps/mobile
   flutter build apk --release
   ```

2. **Install on device:**
   - APK will be at: `build/app/outputs/flutter-apk/app-release.apk`
   - Transfer to Android device and install

3. **Test features:**
   - Register a new user
   - Login with credentials
   - Create a notice (if you're admin/teacher)
   - Send a message
   - View profile

## 🆘 Troubleshooting

### Error: "Firebase not initialized"
- Make sure `google-services.json` is in the correct location
- Rebuild the app after adding config files

### Error: "Permission denied" in Firestore
- Deploy security rules: `firebase deploy --only firestore:rules`
- Check rules in Firebase Console

### Error: "Function not found"
- Deploy functions: `firebase deploy --only functions`
- Check function status in Firebase Console

### App crashes on startup
- Check `firebase_options.dart` has correct values
- Verify package name matches in all places
- Clear app data and reinstall

## 💰 Cost Considerations

Firebase offers a generous free tier:

**Free Tier Includes:**
- Authentication: Unlimited users
- Firestore: 50K reads/day, 20K writes/day
- Storage: 5GB storage, 1GB/day download
- Functions: 2M invocations/month
- Hosting: 10GB storage, 360MB/day bandwidth

For a small college (100-500 users), you'll likely stay within free limits.

**Estimated Costs if Exceeding Free Tier:**
- Light usage (500 students): $0-5/month
- Medium usage (1000 students): $5-20/month
- Heavy usage (2000+ students): $20-50/month

## 🔐 Security Best Practices

1. **Never commit these files to git:**
   - `google-services.json`
   - `GoogleService-Info.plist`
   - Firebase private keys
   
   (These are already in `.gitignore`)

2. **Enable App Check** (recommended for production):
   - Prevents abuse and unauthorized access
   - Setup in Firebase Console → App Check

3. **Review Security Rules:**
   - Check `infra/firestore.rules`
   - Check `infra/storage.rules`
   - Customize as needed for your use case

## 📞 Need Help?

If you encounter issues during setup:

1. Check Firebase documentation: https://firebase.google.com/docs
2. Check Flutter Firebase docs: https://firebase.flutter.dev
3. Review error logs in Firebase Console
4. Create an issue in the GitHub repository

## 🎉 What's Next?

After Firebase is connected:

1. ✅ App will work fully with real database
2. ✅ Users can register and login
3. ✅ Notices and messages will be stored
4. ✅ Push notifications will work
5. ✅ File uploads will function

Then you can:
- Distribute APK to students and teachers
- Create admin accounts
- Add sample data
- Monitor usage in Firebase Console

---

**Note:** Firebase connection is a one-time setup that takes about 30-60 minutes. Once configured, the app will work seamlessly!
