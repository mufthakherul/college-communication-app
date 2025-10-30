# RPI Communication App

A comprehensive college communication platform for **Rangpur Polytechnic Institute** built with Flutter and Firebase.

🌐 **College Website:** [rangpur.polytech.gov.bd](https://rangpur.polytech.gov.bd)  
👨‍💻 **Developed by:** Mufthakherul

> ⚠️ **IMPORTANT:** The app code is complete, but requires Firebase setup to work. See [FIREBASE_SETUP_GUIDE.md](FIREBASE_SETUP_GUIDE.md) for connection instructions.

> 💡 **NEW:** Try **Demo Mode** to explore the app without Firebase! See demo mode button on login screen.

> 🌐 **NEW:** **Mesh Network** feature enables peer-to-peer communication via Bluetooth/WiFi Direct - works even without internet! See [MESH_NETWORK_GUIDE.md](MESH_NETWORK_GUIDE.md) for details.

> 🔒 **Security:** Demo mode is safe and isolated. See [DEMO_MODE_SECURITY.md](DEMO_MODE_SECURITY.md) for details.

> 📖 **For Teachers:** See [QUICK_START.md](QUICK_START.md) for immediate APK download and review  
> 📖 **For Details:** See [TEACHER_GUIDE.md](TEACHER_GUIDE.md) for complete instructions

## 🔥 Firebase Connection Required

The app needs to be connected to Firebase to function. You have two options:

**Option 1: Quick Setup (Recommended)**
```bash
./scripts/setup-firebase.sh
```

**Option 2: Manual Setup**
Follow the step-by-step guide: [FIREBASE_SETUP_GUIDE.md](FIREBASE_SETUP_GUIDE.md)

**What Firebase Provides:**
- User authentication (login/register)
- Real-time database for notices and messages
- File storage for images and documents
- Backend cloud functions
- Push notifications

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

## ✨ Key Features

### Core Features
- 📢 **Notices & Announcements** - Share important information with students and faculty
- 💬 **Direct Messaging** - Real-time communication between users
- 👤 **Role-Based Access** - Admin, Teacher, and Student roles
- 🔐 **Secure Authentication** - Firebase Authentication with email/password
- 🌙 **Dark Mode** - Eye-friendly theme support
- 🔍 **Search** - Find notices and messages quickly
- 📝 **Markdown Support** - Rich text formatting in notices

### Advanced Features (NEW!)
- 🌐 **Mesh Network** - Peer-to-peer communication via Bluetooth/WiFi Direct
  - Works without internet or cellular service
  - Automatic peer discovery and connection
  - Emergency communication mode
- 📡 **Smart Offline Mode** - Automatic queue and sync
  - Retry logic with exponential backoff
  - Priority-based action queue (max 100)
  - Background sync every 15 minutes
- 💾 **Intelligent Caching** - Fast and efficient data access
  - Time-based expiry (5min, 1hr, 1day)
  - 50MB cache limit with auto-cleanup
  - GZip compression support
- 🔄 **Conflict Resolution** - Handle simultaneous edits
  - Multiple resolution strategies
  - Optimistic locking
  - Version tracking
- 📊 **Network Monitoring** - Real-time connection status
  - Network quality detection
  - Connectivity indicators
  - Sync statistics

## 📖 Documentation

- [APK Build Guide](APK_BUILD_GUIDE.md) - **Download and install the app**
- [Mesh Network Guide](MESH_NETWORK_GUIDE.md) - **NEW: Peer-to-peer communication**
- [Network Improvements Summary](NETWORK_IMPROVEMENTS_SUMMARY.md) - **NEW: Technical details**
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