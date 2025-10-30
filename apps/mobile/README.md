# Campus Mesh Mobile App

Flutter mobile application for the Campus Mesh college communication platform.

## Features

- **Authentication**: Email/password login and registration with Firebase Auth
- **Notice Board**: View, create, and manage college announcements
- **Messaging**: Real-time messaging between students, teachers, and admins
- **User Profiles**: Manage user information and roles
- **Push Notifications**: Real-time alerts for messages and notices
- **Role-Based Access**: Different features for students, teachers, and admins

## Prerequisites

- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 2.19.0)
- Android Studio / Xcode for mobile development
- Firebase project configured

## Setup

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Configure Firebase:**
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) from Firebase Console
   - Place Android file in `android/app/`
   - Place iOS file in `ios/Runner/`
   - Run FlutterFire CLI to generate config:
     ```bash
     flutterfire configure
     ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── models/           # Data models
│   ├── user_model.dart
│   ├── notice_model.dart
│   ├── message_model.dart
│   └── notification_model.dart
├── services/         # API services
│   ├── auth_service.dart
│   ├── notice_service.dart
│   ├── message_service.dart
│   └── notification_service.dart
├── screens/          # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── notices/
│   │   ├── notices_screen.dart
│   │   ├── notice_detail_screen.dart
│   │   └── create_notice_screen.dart
│   ├── messages/
│   │   └── messages_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   └── home_screen.dart
├── widgets/          # Reusable widgets
└── main.dart         # App entry point
```

## Building for Release

### Android
```bash
flutter build apk --release
# Or for App Bundle
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/services/auth_service_test.dart
```

## Environment Configuration

The app uses Firebase for backend services. Configure the following in Firebase Console:

- Authentication (Email/Password provider)
- Cloud Firestore database
- Cloud Storage for file uploads
- Cloud Functions for business logic
- Cloud Messaging for push notifications

## State Management

The app uses:
- **StreamBuilder** for real-time data from Firestore
- **StatefulWidget** for local state management
- **Provider** (optional) can be added for global state

## Dependencies

Main dependencies:
- `firebase_core` - Firebase SDK initialization
- `firebase_auth` - Authentication
- `cloud_firestore` - Database
- `firebase_storage` - File storage
- `firebase_messaging` - Push notifications
- `cloud_functions` - Cloud Functions integration

## Troubleshooting

### Common Issues

1. **Firebase not initialized**
   - Ensure `firebase_options.dart` is generated
   - Run `flutterfire configure`

2. **Build errors**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Check Android/iOS native dependencies

3. **Auth errors**
   - Verify Firebase Authentication is enabled
   - Check email/password provider is configured

## Contributing

See the main project [CONTRIBUTING.md](../../docs/CONTRIBUTING.md) for contribution guidelines.

## License

MIT License - see [LICENSE](../../LICENSE) file for details.
