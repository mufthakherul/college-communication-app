# Dart SDK Upgrade Guide

## ⚠️ Dart SDK 3.3.0+ Required

This project now requires **Dart SDK 3.3.0 or higher** due to Appwrite v12.0.4 dependencies.

### Check Your Current Dart Version

```bash
dart --version
```

Expected output should show `Dart SDK version: 3.3.0` or higher.

---

## 🚀 Upgrading Your Dart SDK

### Option 1: Update Flutter (Recommended)

The easiest way to get the latest Dart SDK is to update Flutter:

```bash
# Update Flutter to the latest stable version
flutter upgrade

# Verify Dart version
dart --version
flutter --version
```

**Expected Result:**
- Flutter 3.16.0+ includes Dart 3.2.x
- Flutter 3.19.0+ includes Dart 3.3.x
- Flutter 3.22.0+ includes Dart 3.4.x

### Option 2: Switch Flutter Channel

If you're on an older Flutter stable channel, switch to beta or master for newer Dart versions:

```bash
# Switch to beta channel (more stable than master)
flutter channel beta
flutter upgrade

# Or switch to stable and upgrade
flutter channel stable
flutter upgrade

# Verify versions
flutter --version
dart --version
```

### Option 3: Manual Dart SDK Installation

If you need to manage Dart SDK separately:

**macOS (using Homebrew):**
```bash
brew tap dart-lang/dart
brew install dart
```

**Windows (using Chocolatey):**
```bash
choco upgrade dart-sdk
```

**Linux:**
```bash
# Using apt
sudo apt-get update
sudo apt-get install dart

# Or download from https://dart.dev/get-dart
```

---

## 🔄 Alternative: Use Appwrite v12.0.2

If you **cannot upgrade** to Dart 3.3.0, you can use Appwrite v12.0.2 instead:

### Step 1: Update pubspec.yaml

Edit `/apps/mobile/pubspec.yaml`:

```yaml
environment:
  sdk: '>=3.0.0 <4.0.0'  # Keep at 3.0.0

dependencies:
  # Appwrite dependencies
  appwrite: ^12.0.2  # Downgrade from 12.0.4
  
  # Also update these dependencies
  package_info_plus: ^5.0.1  # Downgrade from 8.0.0
  device_info_plus: ^9.1.2   # Downgrade from 10.0.0
```

### Step 2: Run pub get

```bash
cd apps/mobile
flutter pub get
```

### Differences in v12.0.2 vs v12.0.4

**v12.0.2 (Dart 3.0+):**
- ✅ All core features work (Database, Auth, Storage, Realtime, Functions)
- ✅ Full compatibility with Appwrite Cloud 1.5.x
- ⚠️ Uses slightly older dependency versions
- ⚠️ Minor bug fixes from 12.0.3 and 12.0.4 not included

**v12.0.4 (Dart 3.3+):**
- ✅ Latest bug fixes and improvements
- ✅ Newer dependency versions
- ✅ Better performance

**Recommendation:** Use v12.0.4 if possible. Only use v12.0.2 if you're stuck on Dart 3.0-3.2.

---

## ✅ Verification

After upgrading, verify everything works:

```bash
# Check versions
dart --version
flutter --version

# Clean and get dependencies
cd apps/mobile
flutter clean
flutter pub get

# Run the app
flutter run
```

---

## 🐛 Troubleshooting

### Issue: "Dart SDK version X.X.X is too old"

**Solution:** Upgrade Flutter to get the latest Dart SDK:
```bash
flutter upgrade
```

### Issue: "Flutter upgrade doesn't update Dart"

**Solution:** You might be on an older Flutter channel:
```bash
flutter channel stable
flutter upgrade
```

### Issue: "Still getting version conflicts"

**Solution:** Clear caches and reinstall:
```bash
cd apps/mobile
flutter clean
rm pubspec.lock
flutter pub cache repair
flutter pub get
```

### Issue: "Cannot upgrade Flutter/Dart in CI/CD"

**Solution:** 
- Update your CI/CD Flutter version in workflow files
- Or use Appwrite v12.0.2 as documented above

---

## 📋 Quick Reference

| Flutter Version | Dart Version | Appwrite Version | Status |
|----------------|--------------|------------------|--------|
| 3.16.x | 3.2.x | v12.0.2 | ✅ Compatible |
| 3.19.x | 3.3.x | v12.0.4 | ✅ Compatible |
| 3.22.x+ | 3.4.x+ | v12.0.4 | ✅ Compatible |

---

## 📚 Additional Resources

- [Dart SDK Download](https://dart.dev/get-dart)
- [Flutter Installation](https://docs.flutter.dev/get-started/install)
- [Flutter Upgrade Guide](https://docs.flutter.dev/release/upgrade)
- [Appwrite Flutter SDK](https://pub.dev/packages/appwrite)

---

**Last Updated:** November 2025

For more information, see:
- [APPWRITE_UPDATED_GUIDE.md](APPWRITE_UPDATED_GUIDE.md) - Complete Appwrite setup guide
- [APPWRITE_DOCUMENTATION_UPDATE_SUMMARY.md](APPWRITE_DOCUMENTATION_UPDATE_SUMMARY.md) - Summary of changes
