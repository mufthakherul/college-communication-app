# Android Project Setup Guide

## 📱 Android Project Structure with Firebase Integration

This guide covers the Android project setup for the RPI Communication App, including Firebase SDK integration and configuration.

## 🏗️ Project Architecture

### Technology Stack

- **Framework**: Flutter (Dart)
- **Android Native Layer**: Kotlin
- **Build System**: Gradle 8.1.0
- **Kotlin Version**: 1.9.22
- **Minimum SDK**: 21 (Android 5.0 Lollipop)
- **Target SDK**: 34 (Android 14)
- **Compile SDK**: 34

### Firebase Services Integration

The app integrates the following Firebase services:

1. **Firebase Authentication** - User authentication and management
2. **Cloud Firestore** - Real-time NoSQL database
3. **Cloud Storage** - File storage for images and documents
4. **Firebase Cloud Messaging (FCM)** - Push notifications
5. **Firebase Analytics** - App usage analytics (optional)

## 📂 Android Project Structure

```
apps/mobile/android/
├── app/
│   ├── src/
│   │   └── main/
│   │       ├── kotlin/
│   │       │   └── gov/bd/polytech/rgpi/communication/develop/by/mufthakherul/
│   │       │       └── MainActivity.kt
│   │       ├── res/
│   │       │   ├── values/
│   │       │   ├── drawable/
│   │       │   └── mipmap/
│   │       └── AndroidManifest.xml
│   ├── build.gradle (app-level)
│   ├── proguard-rules.pro
│   └── google-services.json (after Firebase setup)
├── build.gradle (project-level)
├── gradle.properties
├── settings.gradle
└── local.properties (generated)
```

## 🔧 Gradle Configuration

### Project-Level build.gradle

```gradle
buildscript {
    ext.kotlin_version = '1.9.22'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.4.0'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

### App-Level build.gradle

```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

// Apply Google Services plugin for Firebase
apply plugin: 'com.google.gms.google-services'

android {
    namespace "gov.bd.polytech.rgpi.communication.develop.by.mufthakherul"
    compileSdk 34

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    defaultConfig {
        applicationId "gov.bd.polytech.rgpi.communication.develop.by.mufthakherul"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0.0"
        multiDexEnabled true
    }

    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics-ktx'
}
```

## 📋 AndroidManifest.xml Configuration

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="gov.bd.polytech.rgpi.communication.develop.by.mufthakherul">
    
    <!-- Required Permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    
    <!-- URL Scheme Support -->
    <queries>
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="https" />
        </intent>
    </queries>
    
    <application
        android:label="RPI Communication"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="false">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />
                
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

## 🔥 Firebase Setup Steps

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Enter project name: `rpi-communication` (or your choice)
4. **Disable Google Analytics** (optional, keeps it simpler)
5. Click "Create project"

### 2. Add Android App to Firebase

1. In Firebase Console, click "Add app" → Android icon
2. Enter Android package name: `gov.bd.polytech.rgpi.communication.develop.by.mufthakherul`
3. App nickname: `RPI Communication Android`
4. Leave SHA-1 blank (for now)
5. Click "Register app"

### 3. Download google-services.json

1. Download the `google-services.json` file
2. Place it in: `apps/mobile/android/app/google-services.json`
3. **IMPORTANT**: This file is in `.gitignore` - never commit it to Git!

### 4. Enable Firebase Services

#### Enable Authentication:
```bash
1. In Firebase Console → Authentication → Get started
2. Enable "Email/Password" sign-in method
3. Click "Save"
```

#### Enable Firestore:
```bash
1. In Firebase Console → Firestore Database → Create database
2. Select "Start in production mode"
3. Choose location: asia-south1 (closest to Bangladesh)
4. Click "Enable"
```

#### Enable Storage:
```bash
1. In Firebase Console → Storage → Get started
2. Start in production mode
3. Use same location as Firestore
4. Click "Done"
```

### 5. Deploy Security Rules

```bash
# From project root
cd /path/to/college-communication-app

# Login to Firebase
firebase login

# Set Firebase project
firebase use --add
# Select your project and alias it as "default"

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage:rules
```

### 6. Configure Flutter

Run FlutterFire CLI to generate `firebase_options.dart`:

```bash
cd apps/mobile
dart pub global activate flutterfire_cli
flutterfire configure
```

This will update `lib/firebase_options.dart` with your actual Firebase configuration.

## 🔐 ProGuard Configuration

For release builds, configure ProGuard rules in `app/proguard-rules.pro`:

```proguard
# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Firestore
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
```

## 🏃 Building the App

### Debug Build

```bash
cd apps/mobile
flutter run
```

### Release Build

```bash
cd apps/mobile

# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

Output locations:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- Bundle: `build/app/outputs/bundle/release/app-release.aab`

## 🧪 Testing

### Run on Emulator

```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator_id>

# Run app
flutter run
```

### Run on Physical Device

1. Enable Developer Options on Android device
2. Enable USB Debugging
3. Connect device via USB
4. Run: `flutter run`

## 📱 App Signing (for Release)

### Generate Keystore

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

### Configure Signing

Create `android/key.properties`:

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

**IMPORTANT**: Add `key.properties` to `.gitignore`!

Update `app/build.gradle`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
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
        }
    }
}
```

## 🔄 Database Migration Strategy

For future migration away from Firebase:

### 1. Repository Pattern

Create abstraction layer:

```dart
// lib/repositories/user_repository.dart
abstract class UserRepository {
  Future<User> getUser(String id);
  Future<void> saveUser(User user);
  Future<List<User>> getAllUsers();
}

// Firebase implementation
class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Future<User> getUser(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    return User.fromMap(doc.data()!);
  }
  
  // ... other methods
}
```

### 2. Alternative Backend Options

- **Supabase**: Open-source Firebase alternative
- **Appwrite**: Self-hosted backend
- **AWS Amplify**: Amazon's mobile backend
- **Custom Backend**: Node.js + PostgreSQL/MongoDB

### 3. Migration Steps

1. Implement repository interfaces for new backend
2. Run dual-write mode (write to both Firebase and new backend)
3. Verify data consistency
4. Switch read operations to new backend
5. Migrate existing data
6. Decommission Firebase

## 📊 Performance Optimization

### 1. Enable R8 Shrinking

Already enabled in `build.gradle`:
```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
    }
}
```

### 2. Use App Bundles

Build with:
```bash
flutter build appbundle
```

Benefits:
- 15-30% smaller download size
- Device-specific APKs
- Automatic updates via Play Store

### 3. Optimize Images

- Use WebP format for images
- Compress images before upload
- Use Firebase Storage CDN

### 4. Implement Caching

```dart
// Enable offline persistence
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

## 🐛 Troubleshooting

### Common Issues

**Issue**: Build fails with "Could not find google-services.json"
**Solution**: 
1. Download `google-services.json` from Firebase Console
2. Place in `android/app/` directory
3. Rebuild

**Issue**: "Default FirebaseApp is not initialized"
**Solution**:
1. Ensure `google-services.json` is in correct location
2. Verify `apply plugin: 'com.google.gms.google-services'` in app/build.gradle
3. Run `flutter clean && flutter pub get`

**Issue**: Multidex error
**Solution**: Already configured in build.gradle with `multiDexEnabled true`

**Issue**: ProGuard strips Firebase classes
**Solution**: Rules already added to `proguard-rules.pro`

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase for Flutter](https://firebase.flutter.dev)
- [FlutterFire GitHub](https://github.com/firebase/flutterfire)
- [Android Developer Guide](https://developer.android.com)
- [Kotlin Documentation](https://kotlinlang.org/docs/home.html)

## ✅ Setup Checklist

- [ ] Firebase project created
- [ ] Android app registered in Firebase
- [ ] `google-services.json` downloaded and placed
- [ ] Firebase services enabled (Auth, Firestore, Storage)
- [ ] Security rules deployed
- [ ] `firebase_options.dart` generated
- [ ] App builds successfully
- [ ] App runs on emulator/device
- [ ] User can register and login
- [ ] Firestore operations work
- [ ] Storage uploads work

## 🎓 For College Students

This setup is designed for educational purposes and stays within Firebase's free tier:

- ✅ **No credit card required**
- ✅ **Zero monthly costs**
- ✅ **Supports 100-500 active users**
- ✅ **Perfect for college projects**

See [CLOUD_FUNCTIONS_FREE_ALTERNATIVE.md](CLOUD_FUNCTIONS_FREE_ALTERNATIVE.md) for details on avoiding paid Cloud Functions.

---

**Need Help?** Create an issue on GitHub or refer to the troubleshooting section above.
