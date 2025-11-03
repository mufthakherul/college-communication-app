# Release Build Checklist

Use this checklist before deploying a new release version.

## Pre-Build Checklist

### Code Verification
- [ ] All code changes committed
- [ ] No uncommitted debug code
- [ ] Version number updated in `pubspec.yaml`
- [ ] Version code incremented in `pubspec.yaml`
- [ ] Change log updated

### Configuration
- [ ] Appwrite credentials configured
- [ ] Sentry DSN configured (optional but recommended)
- [ ] OneSignal App ID configured (optional but recommended)
- [ ] Backend endpoints verified
- [ ] API keys valid

### Security
- [ ] No hardcoded secrets
- [ ] ProGuard rules up to date
- [ ] Security checks tested
- [ ] Signing keys ready

## Build Process

### Step 1: Clean Build
```bash
cd apps/mobile
flutter clean
rm -rf build/
flutter pub get
```

### Step 2: Build APK
```bash
# Without monitoring (basic)
flutter build apk --release

# With monitoring (recommended)
flutter build apk --release \
  --dart-define=SENTRY_DSN=your_sentry_dsn \
  --dart-define=ONESIGNAL_APP_ID=your_onesignal_app_id
```

### Step 3: Verify Build
- [ ] Build completed without errors
- [ ] APK generated at `build/app/outputs/flutter-apk/app-release.apk`
- [ ] APK size is reasonable (< 50MB)

## Testing Checklist

### Installation Testing
- [ ] Install on Android 7.0 (API 24) device
- [ ] Install on Android 14 (API 35) device
- [ ] Install on rooted device (optional)
- [ ] Fresh install works
- [ ] Update from previous version works

### Launch Testing
- [ ] App launches successfully
- [ ] Splash screen appears
- [ ] Login screen shows (if not logged in)
- [ ] Home screen shows (if logged in)
- [ ] No crashes on startup

### Feature Testing
- [ ] Login with email/password works
- [ ] Registration works
- [ ] Email verification works
- [ ] Profile updates work
- [ ] Notifications work
- [ ] Messaging works
- [ ] QR code scanner works
- [ ] QR code generator works
- [ ] File uploads work
- [ ] Offline mode works

### Network Testing
- [ ] App works with Wi-Fi
- [ ] App works with mobile data
- [ ] App handles no connection gracefully
- [ ] Background sync works

### Performance Testing
- [ ] Startup time < 3 seconds
- [ ] Smooth scrolling
- [ ] No memory leaks
- [ ] Battery usage acceptable
- [ ] App size acceptable

### Edge Cases
- [ ] Works after force stop
- [ ] Works after clear data
- [ ] Works after airplane mode
- [ ] Works with low storage
- [ ] Works with low battery

## Common Issues & Solutions

### Build Fails
**Issue**: Build fails with compilation error  
**Solution**: Run `flutter clean` and try again

### App Crashes on Launch
**Issue**: App crashes immediately  
**Solution**: Check ProGuard rules, review error handling

### Features Don't Work
**Issue**: Some features broken in release  
**Solution**: Verify ProGuard keeps necessary classes

### Slow Performance
**Issue**: App is slow or laggy  
**Solution**: Profile the app, check for debug code

## Post-Deployment

### Monitoring
- [ ] Configure Sentry dashboard
- [ ] Set up OneSignal notifications
- [ ] Monitor crash reports
- [ ] Track user feedback
- [ ] Monitor performance metrics

### User Communication
- [ ] Update app store listing
- [ ] Announce new version
- [ ] Update documentation
- [ ] Notify users of changes

### Backup Plan
- [ ] Previous version APK backed up
- [ ] Rollback procedure documented
- [ ] Emergency contact list ready

## Sign-off

- [ ] Developer tested: _____________ Date: _______
- [ ] QA tested: _____________ Date: _______
- [ ] Product owner approved: _____________ Date: _______
- [ ] Ready for deployment: YES / NO

---

## Quick Reference

**Build Command:**
```bash
flutter build apk --release
```

**Build Location:**
```
build/app/outputs/flutter-apk/app-release.apk
```

**Version Update:**
```yaml
# pubspec.yaml
version: 2.0.0+2  # Format: MAJOR.MINOR.PATCH+BUILD
```

**Critical Files:**
- `apps/mobile/lib/main.dart` - App entry point
- `apps/mobile/android/app/proguard-rules.pro` - ProGuard config
- `apps/mobile/android/app/build.gradle` - Build config
- `apps/mobile/lib/appwrite_config.dart` - Backend config

---

**Note**: This checklist should be completed for every release build to ensure quality and stability.
