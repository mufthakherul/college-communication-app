# Authentication Repository Pattern

This directory contains the repository pattern implementation for authentication.

## Files

- **auth_repository.dart** - Abstract interface defining authentication operations
- **firebase_auth_repository.dart** - Firebase implementation (default)
- **mock_auth_repository.dart** - Mock implementation for testing/demo

## Quick Start

### Using Firebase (Production)

```dart
import 'package:campus_mesh/services/auth_service.dart';

final authService = AuthService(); // Uses FirebaseAuthRepository by default

// Sign in
await authService.signInWithEmailAndPassword(
  'user@example.com',
  'password',
);
```

### Using Mock (Testing/Demo)

```dart
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/repositories/mock_auth_repository.dart';

final authService = AuthService(
  repository: MockAuthRepository(),
);

// Use demo account
await authService.signInWithEmailAndPassword(
  'student@demo.com',
  'demo123',
);
```

## Adding New Implementations

To add support for a new authentication provider:

1. Create a new file (e.g., `supabase_auth_repository.dart`)
2. Implement the `AuthRepository` interface
3. Pass it to `AuthService`:

```dart
class SupabaseAuthRepository implements AuthRepository {
  @override
  String? get currentUserId => // ...
  
  @override
  Stream<String?> get authStateChanges => // ...
  
  @override
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Your implementation
  }
  
  // Implement other methods...
}

// Usage
final authService = AuthService(
  repository: SupabaseAuthRepository(),
);
```

## Benefits

✅ **Easy Testing** - Use mock repository for unit tests  
✅ **Easy Migration** - Switch providers without changing UI code  
✅ **Decoupled** - UI doesn't depend on Firebase directly  
✅ **Flexible** - Support multiple auth providers simultaneously  

See [AUTHENTICATION.md](../AUTHENTICATION.md) for complete documentation.
