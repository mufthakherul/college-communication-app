# Authentication Implementation Guide

## Overview

The Campus Mesh app uses a **repository pattern** for authentication, which provides a clean abstraction between the UI layer and the authentication backend. This architecture makes it easy to:

- Switch authentication providers (Firebase, Supabase, custom backend, etc.)
- Test authentication logic with mock implementations
- Maintain consistent authentication behavior across the app
- Migrate to different authentication solutions in the future

## Architecture

### Layers

```
┌─────────────────────────────────────┐
│         UI Layer (Screens)          │
│  - LoginScreen                      │
│  - RegisterScreen                   │
│  - ProfileScreen                    │
└─────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│      Service Layer (AuthService)    │
│  - Business logic wrapper           │
│  - Error handling                   │
└─────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│  Repository Layer (AuthRepository)  │
│  - Abstract interface               │
│  - Implementation-agnostic          │
└─────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│        Implementations              │
│  - FirebaseAuthRepository           │
│  - MockAuthRepository               │
│  - [Future implementations]         │
└─────────────────────────────────────┘
```

### Components

#### 1. AuthRepository (Interface)
Abstract interface defining all authentication operations.

**Location:** `lib/repositories/auth_repository.dart`

**Key Methods:**
- `signInWithEmailAndPassword()` - Sign in existing user
- `registerWithEmailAndPassword()` - Create new user account
- `signOut()` - Sign out current user
- `sendPasswordResetEmail()` - Send password reset email
- `getUserProfile()` - Get user profile data
- `updateUserProfile()` - Update user profile
- `deleteUserAccount()` - Delete user account

#### 2. FirebaseAuthRepository (Implementation)
Firebase Authentication implementation of the repository interface.

**Location:** `lib/repositories/firebase_auth_repository.dart`

**Features:**
- Uses Firebase Authentication for user auth
- Uses Cloud Firestore for user profile storage
- Automatic error mapping to user-friendly messages
- No Cloud Functions required - works entirely client-side

**Note:** Firebase Authentication is **free** and does not require Cloud Functions. Only the authentication SDK is used, which is included in Firebase's free tier.

#### 3. MockAuthRepository (Implementation)
In-memory mock implementation for testing and demo mode.

**Location:** `lib/repositories/mock_auth_repository.dart`

**Features:**
- In-memory user storage
- Pre-seeded demo users
- Simulated network delays
- No backend required

**Demo Users:**
- Student: `student@demo.com` / `demo123`
- Teacher: `teacher@demo.com` / `demo123`
- Admin: `admin@demo.com` / `demo123`

#### 4. AuthService
Service layer that wraps the repository and provides a clean API for the UI.

**Location:** `lib/services/auth_service.dart`

**Features:**
- Dependency injection support
- Consistent error handling
- Convenience methods for common operations

## Usage Examples

### Basic Usage (Default Firebase)

```dart
import 'package:campus_mesh/services/auth_service.dart';

final authService = AuthService();

// Sign in
try {
  final userId = await authService.signInWithEmailAndPassword(
    'user@example.com',
    'password123',
  );
  print('Signed in as: $userId');
} on AuthException catch (e) {
  print('Error: ${e.message}');
}

// Register
try {
  final userId = await authService.registerWithEmailAndPassword(
    'newuser@example.com',
    'password123',
    'John Doe',
  );
  print('Registered as: $userId');
} on AuthException catch (e) {
  print('Error: ${e.message}');
}

// Get current user
final userId = authService.currentUserId;
if (userId != null) {
  final profile = await authService.getUserProfile(userId);
  print('User: ${profile?.displayName}');
}

// Sign out
await authService.signOut();
```

### Using Mock Repository for Testing

```dart
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/repositories/mock_auth_repository.dart';

// Create service with mock repository
final authService = AuthService(
  repository: MockAuthRepository(),
);

// Use demo credentials
final userId = await authService.signInWithEmailAndPassword(
  'student@demo.com',
  'demo123',
);
```

### Custom Repository Implementation

To add a new authentication provider (e.g., Supabase, Auth0):

1. **Create a new repository class:**

```dart
import 'package:campus_mesh/repositories/auth_repository.dart';
import 'package:campus_mesh/models/user_model.dart';

class SupabaseAuthRepository implements AuthRepository {
  @override
  String? get currentUserId {
    // Implementation
  }

  @override
  Stream<String?> get authStateChanges {
    // Implementation
  }

  @override
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Implementation
  }

  // ... implement other methods
}
```

2. **Use the new repository:**

```dart
final authService = AuthService(
  repository: SupabaseAuthRepository(),
);
```

### Listening to Auth State Changes

```dart
authService.authStateChanges.listen((userId) {
  if (userId != null) {
    print('User signed in: $userId');
  } else {
    print('User signed out');
  }
});
```

## Integration with UI

### Login Screen

```dart
class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();

  Future<void> _signIn() async {
    try {
      await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // Navigate to home screen
    } on AuthException catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }
}
```

### Main App Auth State

```dart
class CampusMeshApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<String?>(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          }
          
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          
          return const LoginScreen();
        },
      ),
    );
  }
}
```

## Firebase Setup (No Cloud Functions Required)

The authentication implementation **does not use Cloud Functions** and works entirely with client-side Firebase SDKs. Cloud Functions are **NOT required** for authentication to work.

### What's Included in Firebase Free Tier:

✅ **Firebase Authentication** - Unlimited users
✅ **Cloud Firestore** - 1GB storage, 50K reads/day, 20K writes/day
✅ **Firebase Storage** - 5GB storage, 1GB/day download
✅ **Firebase Hosting** - 10GB storage, 360MB/day bandwidth

❌ **Cloud Functions** - Not used in authentication flow

### Setup Steps:

1. **Create Firebase Project:**
   - Visit https://console.firebase.google.com
   - Create a new project

2. **Enable Email/Password Authentication:**
   - Go to Authentication → Sign-in method
   - Enable "Email/Password" provider
   - No additional configuration needed

3. **Create Firestore Database:**
   - Go to Firestore Database
   - Create database in production mode
   - Deploy security rules from `infra/firestore.rules`

4. **Add Firebase to Flutter App:**
   ```bash
   cd apps/mobile
   flutterfire configure
   ```

5. **Run the app:**
   ```bash
   flutter run
   ```

That's it! No Cloud Functions setup required.

## Testing

### Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/repositories/mock_auth_repository.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService(
        repository: MockAuthRepository(),
      );
    });

    test('should sign in with valid credentials', () async {
      final userId = await authService.signInWithEmailAndPassword(
        'student@demo.com',
        'demo123',
      );
      
      expect(userId, isNotEmpty);
      expect(authService.currentUserId, equals(userId));
    });

    test('should throw AuthException with invalid credentials', () async {
      expect(
        () => authService.signInWithEmailAndPassword(
          'invalid@demo.com',
          'wrong',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('should register new user', () async {
      final userId = await authService.registerWithEmailAndPassword(
        'newuser@test.com',
        'password123',
        'New User',
      );
      
      expect(userId, isNotEmpty);
      expect(authService.currentUserId, equals(userId));
    });

    test('should sign out', () async {
      await authService.signInWithEmailAndPassword(
        'student@demo.com',
        'demo123',
      );
      
      expect(authService.currentUserId, isNotNull);
      
      await authService.signOut();
      
      expect(authService.currentUserId, isNull);
    });
  });
}
```

### Integration Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:campus_mesh/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete authentication flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Should show login screen
    expect(find.text('Sign In'), findsOneWidget);

    // Enter credentials
    await tester.enterText(
      find.byType(TextField).first,
      'student@demo.com',
    );
    await tester.enterText(
      find.byType(TextField).last,
      'demo123',
    );

    // Tap sign in button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pumpAndSettle();

    // Should navigate to home screen
    expect(find.text('Notices'), findsOneWidget);
  });
}
```

## Migration Guide

### Migrating from Firebase to Another Provider

1. **Create new repository implementation:**

```dart
class NewAuthRepository implements AuthRepository {
  // Implement all required methods
}
```

2. **Update AuthService initialization:**

```dart
// In main.dart or dependency injection setup
final authRepository = NewAuthRepository();
final authService = AuthService(repository: authRepository);
```

3. **Update data migration:**
   - Export user data from Firestore
   - Import to new database
   - Update profile schema if needed

4. **Test thoroughly:**
   - Test all authentication flows
   - Verify user profiles load correctly
   - Check auth state persistence

### Migrating Between Environments

**Development → Production:**
- No code changes needed
- Just update Firebase configuration
- Deploy security rules

**Add Multi-Provider Support:**
```dart
enum AuthProvider { firebase, supabase, custom }

class AuthServiceFactory {
  static AuthService create(AuthProvider provider) {
    switch (provider) {
      case AuthProvider.firebase:
        return AuthService(repository: FirebaseAuthRepository());
      case AuthProvider.supabase:
        return AuthService(repository: SupabaseAuthRepository());
      case AuthProvider.custom:
        return AuthService(repository: CustomAuthRepository());
    }
  }
}
```

## Security Considerations

### Client-Side Security

1. **Never store passwords in memory longer than necessary**
2. **Use HTTPS for all API calls** (Firebase handles this)
3. **Implement proper session management** (handled by Firebase SDK)
4. **Use secure storage for tokens** (handled by Firebase SDK)

### Firestore Security Rules

```javascript
// Ensure users can only read/write their own profile
match /users/{userId} {
  allow read: if request.auth != null && request.auth.uid == userId;
  allow write: if request.auth != null && request.auth.uid == userId;
}
```

### Best Practices

- ✅ Always validate user input
- ✅ Use strong password requirements (min 6 characters)
- ✅ Implement password reset functionality
- ✅ Handle authentication errors gracefully
- ✅ Log out users on security-sensitive actions
- ✅ Implement rate limiting (Firebase handles this)
- ❌ Never store passwords in plain text
- ❌ Never expose API keys in client code (use Firebase configuration)

## Troubleshooting

### Common Issues

**Issue:** "Firebase not initialized"
```dart
// Solution: Ensure Firebase is initialized in main()
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

**Issue:** "User profile not found"
```dart
// Solution: Create profile during registration
await repository.registerWithEmailAndPassword(...);
// Profile is automatically created in FirebaseAuthRepository
```

**Issue:** "Auth state not updating"
```dart
// Solution: Use StreamBuilder to listen to auth changes
StreamBuilder<String?>(
  stream: authService.authStateChanges,
  builder: (context, snapshot) {
    // Handle auth state
  },
)
```

## FAQ

### Q: Do I need Cloud Functions for authentication?
**A:** No! The authentication system works entirely with client-side Firebase SDKs. Cloud Functions are not required and are not used in the authentication flow.

### Q: Is Firebase Authentication free?
**A:** Yes! Firebase Authentication is completely free with unlimited users on both the Spark (free) and Blaze (pay-as-you-go) plans.

### Q: Can I use this with other backends?
**A:** Yes! That's the purpose of the repository pattern. Just create a new implementation of `AuthRepository` for your backend.

### Q: How do I add social login (Google, Facebook)?
**A:** Create methods in `AuthRepository` for social providers, then implement them in `FirebaseAuthRepository` using Firebase Auth's social login methods.

### Q: Can I use this for testing without Firebase?
**A:** Yes! Use `MockAuthRepository` which provides an in-memory implementation with demo users.

### Q: How do I handle password changes?
**A:** Firebase Auth handles password changes through email verification. Users can reset their password using `sendPasswordResetEmail()`.

### Q: Can I migrate to a different auth provider later?
**A:** Yes! The repository pattern makes it easy to swap implementations without changing UI code.

## Additional Resources

- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [Flutter Firebase Auth Package](https://pub.dev/packages/firebase_auth)
- [Repository Pattern in Flutter](https://codewithandrea.com/articles/flutter-repository-pattern/)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture-tdd/)

## Support

For issues or questions:
1. Check this documentation
2. Review the code examples
3. Check the troubleshooting section
4. Create an issue on GitHub

---

**Last Updated:** October 2025  
**Version:** 1.0.0
