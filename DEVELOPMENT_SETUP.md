# Development Environment Setup

Complete guide for setting up the RPI Communication App development environment.

## ✅ What's Installed

### 1. Flutter SDK 3.35.7
- **Location**: `/workspaces/flutter/`
- **Added to PATH**: Yes (in `~/.bashrc`)
- **Dart**: 3.9.2
- **DevTools**: 2.48.0

### 2. Project Dependencies
- All Flutter packages installed via `flutter pub get`
- **Total packages**: 128+ packages
- **Core packages**:
  - `appwrite: 12.0.4` - Backend SDK
  - `flutter_secure_storage: 9.2.4` - Secure data storage
  - `local_auth: 2.3.0` - Biometric authentication
  - `sentry_flutter: 7.20.2` - Crash reporting
  - `google_generative_ai: 0.2.3` - AI chatbot

### 3. Development Tools
- ✅ Git 2.50.1
- ✅ Node.js 22.17.0  
- ✅ Java 11
- ✅ Flutter analyzer configured

## 🚀 Quick Start

### Option 1: Use Setup Script
```bash
cd /workspaces/college-communication-app
./setup-dev-env.sh
```

### Option 2: Manual Setup
```bash
# Ensure Flutter is in PATH
export PATH="$PATH:/workspaces/flutter/bin"

# Navigate to project
cd /workspaces/college-communication-app/apps/mobile

# Install dependencies
flutter pub get

# Check everything is working
flutter doctor
flutter analyze
```

## 📁 Project Structure

```
/workspaces/college-communication-app/
├── apps/mobile/              # Flutter mobile app
│   ├── lib/
│   │   ├── appwrite_config.dart  # Appwrite configuration
│   │   ├── main.dart             # App entry point
│   │   ├── models/               # Data models
│   │   ├── screens/              # UI screens
│   │   ├── services/             # Business logic (42 services)
│   │   ├── utils/                # Helper functions
│   │   └── widgets/              # Reusable components
│   ├── android/              # Android native code
│   ├── ios/                  # iOS native code (if needed)
│   ├── test/                 # Unit tests
│   └── pubspec.yaml          # Dependencies
├── backend/                  # Backend utilities
├── docs/                     # Documentation
├── infra/                    # Infrastructure configs
└── scripts/                  # Build & deployment scripts
```

## 🔧 Configuration

### Appwrite Backend (Already Configured)
- **Endpoint**: `https://sgp.cloud.appwrite.io/v1`
- **Project ID**: `6904cfb1001e5253725b`
- **Region**: Singapore (sgp)

### Optional Services (Configure if needed)

#### 1. Sentry (Crash Reporting)
```bash
# Build with Sentry DSN
flutter build apk --dart-define=SENTRY_DSN=your_dsn_here
```

Get DSN from: https://sentry.io/settings/[ORG]/projects/[PROJECT]/keys/

#### 2. OneSignal (Push Notifications)
```bash
# Build with OneSignal App ID
flutter build apk --dart-define=ONESIGNAL_APP_ID=your_app_id_here
```

Get App ID from: https://app.onesignal.com/apps/[APP_ID]/settings

#### 3. Google Gemini AI (Chatbot)
- API key stored securely via the app UI
- No build-time configuration needed
- Users add their key in Settings > AI Chatbot

## ��️ Building the App

### Debug Build (For Testing)
```bash
cd /workspaces/college-communication-app/apps/mobile
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release Build (For Production)
```bash
# Basic release build (using debug signing)
flutter build apk --release

# With all configurations
flutter build apk --release \
  --dart-define=SENTRY_DSN=your_sentry_dsn \
  --dart-define=ONESIGNAL_APP_ID=your_onesignal_id
```

⚠️ **Note**: Production releases need proper signing. See [PRODUCTION_DEPLOYMENT_GUIDE.md](PRODUCTION_DEPLOYMENT_GUIDE.md)

## 🧪 Testing

### Run All Tests
```bash
cd /workspaces/college-communication-app/apps/mobile
flutter test
```

### Run Specific Test
```bash
flutter test test/services/security_service_test.dart
```

### Code Coverage
```bash
flutter test --coverage
```

## 🔍 Code Quality

### Analyze Code
```bash
flutter analyze
```

### Fix Auto-fixable Issues
```bash
dart fix --apply
```

### Format Code
```bash
dart format lib/ test/
```

## 🐛 Troubleshooting

### Flutter Command Not Found
```bash
export PATH="$PATH:/workspaces/flutter/bin"
# Or restart terminal to load ~/.bashrc
```

### Dependencies Issues
```bash
flutter clean
flutter pub get
```

### Build Errors
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter build apk --debug
```

### Appwrite Connection Issues
- Check internet connection
- Verify Appwrite project ID in `lib/appwrite_config.dart`
- Check Appwrite console: https://cloud.appwrite.io

## 📚 Additional Resources

- **Quick Start**: [docs/QUICK_START.md](docs/QUICK_START.md)
- **Appwrite Setup**: [docs/APPWRITE_GUIDE.md](docs/APPWRITE_GUIDE.md)
- **Production Deployment**: [PRODUCTION_DEPLOYMENT_GUIDE.md](PRODUCTION_DEPLOYMENT_GUIDE.md)
- **Security Guide**: [SECURITY.md](SECURITY.md)
- **Flutter Docs**: https://docs.flutter.dev

## ✅ Environment Checklist

- [x] Flutter SDK installed
- [x] Flutter added to PATH
- [x] Project dependencies installed
- [x] Code analysis errors fixed
- [x] Appwrite configuration verified
- [ ] Optional: Sentry DSN configured
- [ ] Optional: OneSignal App ID configured
- [ ] Optional: Android SDK for building (not required for code development)

## 🔐 Security Notes

1. **Never commit secrets** to Git
2. Use environment variables for sensitive data
3. Keep Appwrite project ID as-is (safe to commit)
4. Store API keys in secure storage (handled by app)
5. Release builds use ProGuard obfuscation

## 📞 Support

- **Issues**: GitHub Issues
- **Documentation**: `docs/` folder
- **College Website**: https://rangpur.polytech.gov.bd

---

**Last Updated**: November 5, 2025
**Environment**: Codespaces (Ubuntu 24.04.2 LTS)
**Flutter Version**: 3.35.7
**Dart Version**: 3.9.2
