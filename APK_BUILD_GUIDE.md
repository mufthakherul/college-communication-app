# APK Build Guide for RGPI Communication App

This guide explains how to build and download APK files for the Rangpur Government Polytechnic Institute Communication App.

## 🚀 Automated APK Builds

The project uses GitHub Actions to automatically build APK files on every push to the main branch.

### Download Pre-built APKs

1. **From GitHub Actions:**
   - Go to the [Actions tab](../../actions/workflows/build-apk.yml)
   - Click on the latest successful workflow run
   - Scroll down to "Artifacts" section
   - Download either:
     - `rgpi-communication-debug-apk` (for testing)
     - `rgpi-communication-release-apk` (for production use)

2. **From Releases (for tagged versions):**
   - Go to the [Releases page](../../releases)
   - Download the APK from the latest release

## 📱 Installing the APK

### On Your Android Device:

1. **Enable Installation from Unknown Sources:**
   - Go to Settings → Security → Unknown Sources
   - Enable "Allow installation of apps from unknown sources"
   - Or on newer Android: Settings → Apps → Special app access → Install unknown apps

2. **Install the APK:**
   - Transfer the downloaded APK to your Android device
   - Open the APK file using a file manager
   - Tap "Install" and follow the prompts

3. **Open the App:**
   - Find "RGPI Communication" in your app drawer
   - Open and log in with your credentials

## 🛠️ Building APK Locally

If you want to build the APK on your local machine:

### Prerequisites:

- Flutter SDK (3.16.0 or higher)
- Android SDK
- Java JDK (17 or higher)
- Git

### Build Steps:

```bash
# 1. Clone the repository
git clone https://github.com/mufthakherul/college-communication-app.git
cd college-communication-app/apps/mobile

# 2. Get Flutter dependencies
flutter pub get

# 3. Build Debug APK (for testing)
flutter build apk --debug

# 4. Build Release APK (for production)
flutter build apk --release

# APKs will be located at:
# Debug: build/app/outputs/flutter-apk/app-debug.apk
# Release: build/app/outputs/flutter-apk/app-release.apk
```

## 📦 APK Types

### Debug APK
- **Size:** Larger (~50-80 MB)
- **Use:** Testing and development
- **Performance:** Slower, includes debugging symbols
- **Signing:** Debug certificate (auto-generated)

### Release APK
- **Size:** Smaller (~20-40 MB)
- **Use:** Production deployment
- **Performance:** Optimized, minified code
- **Signing:** Currently using debug certificate (should be updated for production)

## 🔐 App Signing for Production

For production release on Google Play Store or official distribution:

1. **Generate a keystore:**
```bash
keytool -genkey -v -keystore rgpi-release-key.keystore \
  -alias rgpi-key -keyalg RSA -keysize 2048 -validity 10000
```

2. **Update signing configuration:**
   - Edit `apps/mobile/android/app/build.gradle`
   - Uncomment the release signing configuration
   - Store keystore securely (never commit to git)

3. **For GitHub Actions:**
   - Add secrets to your repository:
     - `ANDROID_KEYSTORE_FILE` (base64 encoded keystore)
     - `ANDROID_KEYSTORE_PASSWORD`
     - `ANDROID_KEY_ALIAS`
     - `ANDROID_KEY_PASSWORD`

## 🔄 Continuous Deployment

The GitHub Actions workflow automatically:
- ✅ Builds APK on every push to main/develop branches
- ✅ Runs Flutter analyzer to check code quality
- ✅ Uploads APK artifacts (retained for 30-90 days)
- ✅ Creates GitHub releases when you push a version tag

### Creating a Release:

```bash
# Tag a release version
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# GitHub Actions will automatically:
# - Build the APK
# - Create a GitHub release
# - Attach APK files to the release
```

## 📱 Sharing APK with Your Teacher

### Option 1: GitHub Artifacts (Recommended)
1. Push your latest changes to GitHub
2. Wait for GitHub Actions to complete (usually 5-10 minutes)
3. Share this link with your teacher:
   ```
   https://github.com/mufthakherul/college-communication-app/actions
   ```
4. They can download the APK from the latest workflow run

### Option 2: Direct Download Link
1. Create a release tag as shown above
2. Share the release page link:
   ```
   https://github.com/mufthakherul/college-communication-app/releases/latest
   ```

### Option 3: Manual Transfer
1. Build the APK locally
2. Find the file at: `apps/mobile/build/app/outputs/flutter-apk/app-release.apk`
3. Share via email, Google Drive, or USB transfer

## 🐛 Troubleshooting

### Build Fails in GitHub Actions
- Check the Actions log for error messages
- Ensure all Flutter dependencies are correctly specified
- Verify Android configuration files are present

### APK Won't Install on Device
- Enable "Install from Unknown Sources"
- Check if Android version is 5.0 (API 21) or higher
- Ensure enough storage space on device

### App Crashes on Launch
- Check if you're using the correct APK (Debug vs Release)
- Verify Firebase configuration is set up
- Check Android device logs using `adb logcat`

## 📊 APK Size Optimization

The release APK is optimized with:
- ✅ Code minification (ProGuard/R8)
- ✅ Resource shrinking
- ✅ Compression
- ✅ Native library optimization

Expected sizes:
- Debug APK: ~50-80 MB
- Release APK: ~20-40 MB (depending on dependencies)

## 🔗 Useful Links

- [Flutter Documentation](https://flutter.dev/docs)
- [Android App Bundle Documentation](https://developer.android.com/guide/app-bundle)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 📞 Support

For issues or questions:
- Create an issue in the GitHub repository
- Contact the development team
- Refer to the main [README.md](README.md) and [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)
