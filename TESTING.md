# Testing Guide

This document provides comprehensive testing guidelines for the RPI Communication App.

## Table of Contents
- [Test Structure](#test-structure)
- [Running Tests](#running-tests)
- [Test Coverage](#test-coverage)
- [Writing Tests](#writing-tests)
- [Continuous Integration](#continuous-integration)

## Test Structure

The project follows standard Flutter testing practices:

```
apps/mobile/
├── lib/                    # Application code
│   ├── models/            # Data models
│   ├── services/          # Business logic
│   ├── screens/           # UI screens
│   └── main.dart          # Entry point
└── test/                  # Test files
    ├── models/            # Model tests
    ├── services/          # Service tests (mocked)
    ├── widgets/           # Widget tests
    └── integration/       # Integration tests (future)
```

## Running Tests

### Run All Tests
```bash
cd apps/mobile
flutter test
```

### Run Specific Test File
```bash
flutter test test/models/user_model_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### View Coverage Report
```bash
# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html

# Open in browser (macOS)
open coverage/html/index.html

# Open in browser (Linux)
xdg-open coverage/html/index.html
```

## Test Coverage

### Current Coverage
- ✅ **Models**: Unit tests for all data models
  - UserModel
  - NoticeModel
  - MessageModel
  - NotificationModel
- ⚠️ **Services**: Mocked tests needed
- ✅ **Widgets**: Basic widget tests
- ⚠️ **Integration**: End-to-end tests needed

### Coverage Goals
- Models: 100% coverage
- Services: 80% coverage (excluding Firebase calls)
- Widgets: 70% coverage
- Overall: 80% coverage

## Writing Tests

### Model Tests

Model tests verify data serialization and validation:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_mesh/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('should create UserModel from valid data', () {
      final user = UserModel(
        uid: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        role: UserRole.student,
        // ... other fields
      );

      expect(user.uid, 'user123');
      expect(user.email, 'test@example.com');
    });

    test('should convert UserModel to Map', () {
      final user = UserModel(/* ... */);
      final map = user.toMap();
      
      expect(map['uid'], 'user123');
      expect(map['email'], 'test@example.com');
    });
  });
}
```

### Widget Tests

Widget tests verify UI behavior:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Login screen shows email field', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
  });
}
```

### Service Tests (with Mocks)

For future implementation:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:campus_mesh/services/auth_service.dart';

void main() {
  group('AuthService', () {
    test('should sign in user successfully', () async {
      // Create mocks
      final mockAuth = MockFirebaseAuth();
      final service = AuthService(auth: mockAuth);
      
      // Setup mock behavior
      when(mockAuth.signInWithEmailAndPassword(any, any))
          .thenAnswer((_) async => MockUserCredential());
      
      // Test the service
      final result = await service.signInWithEmailAndPassword(
        'test@example.com',
        'password',
      );
      
      expect(result, isNotNull);
    });
  });
}
```

## Integration Tests

Integration tests verify end-to-end workflows:

### Future Integration Test Example
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:campus_mesh/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('complete login flow', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusMeshApp());
    
    // Enter credentials
    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    
    // Tap login button
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    
    // Verify home screen appears
    expect(find.text('Notices'), findsOneWidget);
  });
}
```

## Test Best Practices

### 1. Test Organization
- Group related tests using `group()`
- Use descriptive test names
- Follow AAA pattern: Arrange, Act, Assert

### 2. Test Isolation
- Each test should be independent
- Clean up after tests
- Use setUp() and tearDown() when needed

### 3. Mock External Dependencies
- Mock Firebase services
- Mock HTTP requests
- Use dependency injection for testability

### 4. Test Coverage
- Aim for meaningful coverage, not just high numbers
- Focus on business logic and critical paths
- Don't test trivial code

### 5. Performance
- Keep tests fast (<1 second each)
- Use `pumpAndSettle()` sparingly
- Mock expensive operations

## Continuous Integration

### GitHub Actions Workflow

Tests run automatically on:
- Push to main/develop branches
- Pull requests
- Manual workflow dispatch

### Test Workflow Steps
1. Checkout code
2. Setup Flutter
3. Get dependencies
4. Run Flutter analyzer
5. Run unit tests
6. Run widget tests
7. Generate coverage report
8. Upload coverage to Codecov (optional)

### Example Workflow (to be added to `.github/workflows/test.yml`):
```yaml
name: Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          
      - name: Get dependencies
        working-directory: apps/mobile
        run: flutter pub get
        
      - name: Analyze code
        working-directory: apps/mobile
        run: flutter analyze
        
      - name: Run tests
        working-directory: apps/mobile
        run: flutter test --coverage
        
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: apps/mobile/coverage/lcov.info
```

## Testing Checklist

Before pushing code, ensure:

- [ ] All existing tests pass
- [ ] New features have tests
- [ ] Code coverage doesn't decrease
- [ ] Tests are meaningful and test actual behavior
- [ ] No flaky tests (tests that sometimes pass/fail)
- [ ] Tests run quickly (<5 minutes total)

## Troubleshooting

### Common Issues

**Test fails with Firebase initialization error:**
```bash
# Solution: Mock Firebase or use Firebase emulators
```

**Coverage report not generating:**
```bash
# Ensure you run with --coverage flag
flutter test --coverage
```

**Tests timeout:**
```bash
# Increase timeout in test
test('my test', () async {
  // test code
}, timeout: Timeout(Duration(seconds: 30)));
```

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Widget Testing Best Practices](https://docs.flutter.dev/cookbook/testing/widget/introduction)

## Next Steps

### Immediate Priorities
1. Add service layer tests with mocks
2. Increase widget test coverage
3. Set up integration tests
4. Add CI/CD test workflow

### Future Enhancements
1. Screenshot testing
2. Performance benchmarks
3. Accessibility testing
4. End-to-end test automation

---

**Last Updated:** 2024-10-30  
**Maintainer:** Mufthakherul
