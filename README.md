# RGPI Communication App

A comprehensive college communication platform for **Rangpur Government Polytechnic Institute** built with Flutter and Firebase.

🌐 **College Website:** [rangpur.polytech.gov.bd](https://rangpur.polytech.gov.bd)

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