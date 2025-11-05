# 🚀 Quick Reference Card

## Essential Commands

### Setup
```bash
# First time setup
./setup-dev-env.sh

# Or manually
export PATH="$PATH:/workspaces/flutter/bin"
cd apps/mobile && flutter pub get
```

### Development
```bash
# Check code quality
flutter analyze

# Run tests
flutter test

# Format code
dart format lib/

# Clean project
flutter clean
```

### Building
```bash
# Debug APK (fast, for testing)
flutter build apk --debug

# Release APK (optimized, production)
flutter build apk --release
```

### Debugging
```bash
# Check environment
flutter doctor

# View Flutter version
flutter --version

# Reinstall dependencies
flutter pub get

# Clear cache
flutter clean && flutter pub get
```

## Project Locations

- **App Source**: `apps/mobile/lib/`
- **Config**: `apps/mobile/lib/appwrite_config.dart`
- **Services**: `apps/mobile/lib/services/` (42 services)
- **Screens**: `apps/mobile/lib/screens/`
- **Tests**: `apps/mobile/test/`

## Key Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point |
| `lib/appwrite_config.dart` | Backend configuration |
| `pubspec.yaml` | Dependencies |
| `android/app/build.gradle` | Android build config |
| `android/app/proguard-rules.pro` | Code obfuscation |

## Appwrite Configuration

- **Endpoint**: `https://sgp.cloud.appwrite.io/v1`
- **Project ID**: `6904cfb1001e5253725b`
- **Console**: https://cloud.appwrite.io

## Common Issues

| Problem | Solution |
|---------|----------|
| `flutter: command not found` | Run: `export PATH="$PATH:/workspaces/flutter/bin"` |
| Build errors | Run: `flutter clean && flutter pub get` |
| Dependency conflicts | Check `pubspec.yaml` for version issues |
| Appwrite errors | Verify internet connection & project ID |

## Environment Variables

```bash
# Optional: Crash reporting
--dart-define=SENTRY_DSN=your_dsn

# Optional: Push notifications  
--dart-define=ONESIGNAL_APP_ID=your_id
```

## Testing Commands

```bash
# All tests
flutter test

# Specific test
flutter test test/services/security_service_test.dart

# With coverage
flutter test --coverage
```

## Code Quality Metrics

- **Total Files**: 50+ Dart files
- **Services**: 42 service classes
- **Lines**: ~15,000+ lines
- **Lint Rules**: 100+ active rules
- **Test Coverage**: Unit tests for critical services

## Support

- **Documentation**: `docs/` folder
- **Setup Guide**: `DEVELOPMENT_SETUP.md`
- **Production Guide**: `PRODUCTION_DEPLOYMENT_GUIDE.md`
- **Security**: `SECURITY.md`

---

**Tip**: Keep this file open for quick reference during development!
