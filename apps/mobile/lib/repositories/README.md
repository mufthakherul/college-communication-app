# Repository Pattern for Database Abstraction

This directory contains repository interfaces and implementations that abstract the data layer, making it easy to migrate to alternative databases in the future.

## Architecture

```
┌─────────────────┐
│   UI Screens    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    Services     │  (Business Logic)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Repositories   │  (Data Access Abstraction)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Data Source   │  (Firebase, Supabase, etc.)
└─────────────────┘
```

## Repository Pattern Benefits

1. **Separation of Concerns**: UI logic separated from data access
2. **Easy Testing**: Mock repositories for unit tests
3. **Database Migration**: Switch backends without changing UI code
4. **Single Source of Truth**: Centralized data access logic
5. **Caching Strategy**: Implement caching in repositories

## Example: User Repository

### Interface Definition

```dart
// repositories/user_repository.dart
abstract class UserRepository {
  Future<User?> getUser(String userId);
  Future<List<User>> getAllUsers();
  Future<void> createUser(User user);
  Future<void> updateUser(User user);
  Future<void> deleteUser(String userId);
  Stream<User?> watchUser(String userId);
}
```

### Firebase Implementation

```dart
// repositories/firebase_user_repository.dart
class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Future<User?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return User.fromFirestore(doc);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }
  
  @override
  Stream<User?> watchUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? User.fromFirestore(doc) : null);
  }
  
  // ... other implementations
}
```

### Alternative Implementation (Supabase)

```dart
// repositories/supabase_user_repository.dart
class SupabaseUserRepository implements UserRepository {
  final SupabaseClient _client = Supabase.instance.client;
  
  @override
  Future<User?> getUser(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return User.fromJson(response);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }
  
  // ... other implementations
}
```

## Migration Path

### Step 1: Create Repository Interfaces

Define interfaces for all data entities:
- `UserRepository`
- `NoticeRepository`
- `MessageRepository`
- `NotificationRepository`

### Step 2: Implement Firebase Repositories

Create Firebase implementations:
- `FirebaseUserRepository`
- `FirebaseNoticeRepository`
- `FirebaseMessageRepository`
- `FirebaseNotificationRepository`

### Step 3: Use Dependency Injection

```dart
// main.dart
void main() {
  // Configure repository implementations
  final userRepository = FirebaseUserRepository();
  final noticeRepository = FirebaseNoticeRepository();
  
  runApp(MyApp(
    userRepository: userRepository,
    noticeRepository: noticeRepository,
  ));
}
```

### Step 4: Update Services

```dart
// services/auth_service.dart
class AuthService {
  final UserRepository _userRepository;
  
  AuthService(this._userRepository);
  
  Future<void> updateUserProfile(User user) async {
    await _userRepository.updateUser(user);
  }
}
```

### Step 5: Migrate to New Backend

When ready to migrate:

1. Implement new repository (e.g., `SupabaseUserRepository`)
2. Update dependency injection in `main.dart`
3. Test thoroughly
4. Deploy

No UI code changes needed! 🎉

## Testing with Mock Repositories

```dart
// test/mocks/mock_user_repository.dart
class MockUserRepository implements UserRepository {
  final Map<String, User> _users = {};
  
  @override
  Future<User?> getUser(String userId) async {
    return _users[userId];
  }
  
  @override
  Future<void> createUser(User user) async {
    _users[user.id] = user;
  }
  
  // ... other mock implementations
}
```

```dart
// test/services/auth_service_test.dart
void main() {
  test('updates user profile', () async {
    final mockRepo = MockUserRepository();
    final authService = AuthService(mockRepo);
    
    await authService.updateUserProfile(testUser);
    
    expect(mockRepo.getUser(testUser.id), equals(testUser));
  });
}
```

## Current Status

- [x] Repository pattern documented
- [ ] User repository interface created
- [ ] Notice repository interface created
- [ ] Message repository interface created
- [ ] Firebase implementations created
- [ ] Services updated to use repositories
- [ ] Unit tests added

## Next Steps

To fully implement the repository pattern:

1. Create `user_repository.dart` with interface
2. Create `firebase_user_repository.dart` with implementation
3. Update `AuthService` to use `UserRepository`
4. Repeat for other entities
5. Add comprehensive tests

This makes the app truly scalable and migration-ready! 🚀
