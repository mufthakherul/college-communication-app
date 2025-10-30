# RPI Communication App

A comprehensive college communication platform for **Rangpur Polytechnic Institute** built with Flutter and Firebase.

🌐 **College Website:** [rangpur.polytech.gov.bd](https://rangpur.polytech.gov.bd)  
👨‍💻 **Developed by:** Mufthakherul

> ⚠️ **IMPORTANT:** The app code is complete, but requires Firebase setup to work. See [FIREBASE_SETUP_GUIDE.md](FIREBASE_SETUP_GUIDE.md) for connection instructions.

> 💡 **NEW:** Try **Demo Mode** to explore the app without Firebase! See demo mode button on login screen.

> 🔒 **Security:** Demo mode is safe and isolated. See [DEMO_MODE_SECURITY.md](DEMO_MODE_SECURITY.md) for details.

> 📖 **For Teachers:** See [QUICK_START.md](QUICK_START.md) for immediate APK download and review  
> 📖 **For Details:** See [TEACHER_GUIDE.md](TEACHER_GUIDE.md) for complete instructions

## 🔥 Firebase Connection Required

The app needs to be connected to Firebase to function. **This project uses only FREE Firebase services** - no paid Cloud Functions required!

### Quick Setup Options:

**Option 1: Quick Setup (Recommended)**
```bash
./scripts/setup-firebase.sh
```

**Option 2: Manual Setup**
Follow the step-by-step guide: [FIREBASE_SETUP_GUIDE.md](FIREBASE_SETUP_GUIDE.md)

### 💰 100% Free Firebase Services:
- ✅ **Authentication** - User login/register (Unlimited users)
- ✅ **Firestore Database** - Real-time notices and messages (50K reads/day)
- ✅ **Cloud Storage** - File storage for images and documents (5GB free)
- ✅ **Push Notifications** - Firebase Cloud Messaging (Unlimited)
- ✅ **No Cloud Functions needed!** - See [CLOUD_FUNCTIONS_FREE_ALTERNATIVE.md](CLOUD_FUNCTIONS_FREE_ALTERNATIVE.md)

### 🎓 Perfect for College Projects:
This app stays within Firebase's free tier, supporting 100-500 active users with **zero cost**. No credit card required!

## 📱 Download APK

**For Teachers/Students:** Download the latest APK to install on your Android device:

1. Go to [Actions → Latest Build](../../actions/workflows/build-apk.yml)
2. Download the APK artifact from the latest successful run
3. Or check the [Releases Page](../../releases) for stable versions

See the complete [APK Build Guide](APK_BUILD_GUIDE.md) for detailed instructions.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/mufthakherul/college-communication-app.git
cd college-communication-app

# Set up development environment
./scripts/setup-dev.sh

# Run the mobile app
cd apps/mobile
flutter run
```

## 📖 Documentation

- [APK Build Guide](APK_BUILD_GUIDE.md) - **Download and install the app**
- [Full Documentation](docs/README.md)
- [Architecture Overview](docs/ARCHITECTURE.md)
- [API Reference](docs/API.md)
- [Deployment Guide](docs/DEPLOYMENT.md)
- [Database Seeding Guide](docs/SEEDING.md)
- [Contributing Guidelines](docs/CONTRIBUTING.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

## 🏗️ Project Structure

```
├── apps/mobile/          # Flutter mobile application
├── backend/             # Backend utilities and scripts
├── functions/           # Firebase Cloud Functions (TypeScript)
├── infra/              # Infrastructure configuration
├── scripts/            # Build and deployment scripts
├── docs/              # Documentation
├── firebase.json      # Firebase configuration
└── README.md         # This file
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](docs/CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License.