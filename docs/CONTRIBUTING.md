# Contributing to Campus Mesh

Thank you for your interest in contributing to Campus Mesh! This document provides guidelines for contributing to the project and helps ensure a smooth collaboration process.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Workflow](#development-workflow)
4. [Coding Standards](#coding-standards)
5. [Testing Guidelines](#testing-guidelines)
6. [Pull Request Process](#pull-request-process)
7. [Issue Reporting](#issue-reporting)
8. [Community Support](#community-support)

## Code of Conduct

Campus Mesh is committed to providing a welcoming and inclusive environment for all contributors. By participating in this project, you agree to abide by our Code of Conduct:

### Our Standards

- **Be respectful**: Treat all community members with respect and kindness
- **Be inclusive**: Welcome newcomers and help them get started
- **Be constructive**: Provide helpful feedback and suggestions
- **Be professional**: Maintain professionalism in all interactions

### Unacceptable Behavior

- Harassment, discrimination, or offensive comments
- Personal attacks or insults
- Spam or promotional content
- Sharing private information without permission

## Getting Started

### Prerequisites

Before contributing, ensure you have the following installed:

- **Flutter SDK** (>= 3.0.0)
- **Node.js** (>= 18.0.0)
- **Firebase CLI**
- **Git**
- **Your preferred IDE** (VS Code, IntelliJ, etc.)

### Development Setup

1. **Fork the repository**
   ```bash
   # Fork the repo on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/campus-mesh.git
   cd campus-mesh
   ```

2. **Set up the development environment**
   ```bash
   ./scripts/setup-dev.sh
   ```

3. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Workflow

### Branch Naming Convention

Use descriptive branch names following this pattern:
- `feature/add-messaging-ui` - New features
- `fix/login-error-handling` - Bug fixes
- `docs/update-api-documentation` - Documentation updates
- `refactor/user-service-cleanup` - Code refactoring

### Commit Message Guidelines

Follow the conventional commit format:

```
type(scope): description

body (optional)

footer (optional)
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or modifying tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(messaging): add real-time message notifications

fix(auth): resolve login error for new users

docs(api): update authentication endpoints documentation
```

### Code Organization

```
├── apps/mobile/           # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart     # App entry point
│   │   ├── models/       # Data models
│   │   ├── services/     # API services
│   │   ├── screens/      # UI screens
│   │   ├── widgets/      # Reusable widgets
│   │   └── utils/        # Utility functions
│   └── test/             # Flutter tests
├── functions/            # Firebase Cloud Functions
│   ├── src/
│   │   ├── index.ts      # Functions entry point
│   │   ├── services/     # Business logic
│   │   └── utils/        # Utility functions
│   └── test/             # Function tests
├── infra/                # Infrastructure configuration
├── scripts/              # Build and deployment scripts
└── docs/                 # Documentation
```

## Coding Standards

### TypeScript/JavaScript (Cloud Functions)

#### Style Guide
- Use **TypeScript** for all new code
- Follow **ESLint** configuration
- Use **Prettier** for code formatting
- Prefer `const` over `let` and `var`
- Use arrow functions for callbacks
- Use async/await over Promises

#### Example:
```typescript
// Good
export const getUserProfile = async (userId: string): Promise<UserProfile> => {
  try {
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(userId)
      .get();
    
    if (!userDoc.exists) {
      throw new Error('User not found');
    }
    
    return userDoc.data() as UserProfile;
  } catch (error) {
    console.error('Error fetching user profile:', error);
    throw error;
  }
};

// Avoid
function getUserProfile(userId, callback) {
  admin.firestore()
    .collection('users')
    .doc(userId)
    .get()
    .then(function(userDoc) {
      if (!userDoc.exists) {
        callback(new Error('User not found'));
        return;
      }
      callback(null, userDoc.data());
    })
    .catch(function(error) {
      callback(error);
    });
}
```

### Dart/Flutter (Mobile App)

#### Style Guide
- Follow **Dart style guide**
- Use **flutter_lints** package
- Prefer `const` constructors when possible
- Use meaningful widget and variable names
- Organize imports (dart: first, package:, relative)

#### Example:
```dart
// Good
class MessageScreen extends StatefulWidget {
  const MessageScreen({
    super.key,
    required this.recipientId,
  });

  final String recipientId;

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }
}
```

### Documentation Standards

#### Code Comments
```typescript
/**
 * Sends a message between users with notification support
 * @param senderId - ID of the user sending the message
 * @param recipientId - ID of the user receiving the message
 * @param content - Message content (max 1000 characters)
 * @param type - Message type (text, image, file)
 * @returns Promise resolving to the created message ID
 * @throws HttpsError if validation fails or user is unauthorized
 */
export const sendMessage = async (
  senderId: string,
  recipientId: string,
  content: string,
  type: MessageType = 'text'
): Promise<string> => {
  // Implementation...
};
```

#### README Updates
- Update relevant documentation when adding features
- Include code examples for new APIs
- Update setup instructions if needed

## Testing Guidelines

### Unit Testing

#### Cloud Functions
```typescript
// functions/test/messaging.test.ts
import * as test from 'firebase-functions-test';
import { sendMessage } from '../src/messaging';

const testEnv = test();

describe('sendMessage', () => {
  beforeEach(() => {
    // Setup test data
  });

  afterEach(() => {
    // Cleanup
  });

  it('should send a message successfully', async () => {
    const data = {
      recipientId: 'user123',
      content: 'Hello, world!',
      type: 'text'
    };
    
    const context = {
      auth: { uid: 'sender123' }
    };
    
    const result = await sendMessage(data, context);
    
    expect(result.success).toBe(true);
    expect(result.messageId).toBeDefined();
  });
  
  it('should reject unauthenticated requests', async () => {
    const data = {
      recipientId: 'user123',
      content: 'Hello, world!',
      type: 'text'
    };
    
    const context = {};
    
    await expect(sendMessage(data, context))
      .rejects.toThrow('unauthenticated');
  });
});
```

#### Flutter Tests
```dart
// apps/mobile/test/services/message_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_mesh/services/message_service.dart';

void main() {
  group('MessageService', () {
    late MessageService messageService;
    
    setUp(() {
      messageService = MessageService();
    });
    
    test('should send message successfully', () async {
      final message = Message(
        recipientId: 'user123',
        content: 'Test message',
        type: MessageType.text,
      );
      
      final result = await messageService.sendMessage(message);
      
      expect(result.isSuccess, true);
      expect(result.messageId, isNotNull);
    });
  });
}
```

### Integration Testing

```dart
// apps/mobile/integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:campus_mesh/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Campus Mesh App', () {
    testWidgets('should navigate to login screen', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      expect(find.text('Welcome to Campus Mesh'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsWidgets);
    });
  });
}
```

### Test Coverage

Maintain minimum test coverage:
- **Cloud Functions**: 80% code coverage
- **Flutter App**: 70% code coverage
- **Critical paths**: 95% coverage

## Pull Request Process

### Before Submitting

1. **Run tests locally**
   ```bash
   # Flutter tests
   cd apps/mobile
   flutter test
   
   # Functions tests
   cd functions
   npm test
   ```

2. **Run linting**
   ```bash
   # Flutter
   flutter analyze
   
   # Functions
   npm run lint
   ```

3. **Update documentation** if needed

### PR Template

```markdown
## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests pass locally
- [ ] No new warnings introduced

## Screenshots (if applicable)
Add screenshots of UI changes.
```

### Review Process

1. **Automated checks** must pass
2. **At least one reviewer** approval required
3. **Maintainer approval** for breaking changes
4. **All conversations resolved** before merge

## Issue Reporting

### Bug Reports

Use the bug report template:

```markdown
**Describe the bug**
A clear description of the bug.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
Add screenshots if applicable.

**Environment:**
- Device: [e.g. iPhone 12, Android Pixel 5]
- OS: [e.g. iOS 15.0, Android 12]
- App version: [e.g. 1.0.0]

**Additional context**
Any other context about the problem.
```

### Feature Requests

Use the feature request template:

```markdown
**Is your feature request related to a problem?**
A clear description of the problem.

**Describe the solution you'd like**
A clear description of what you want to happen.

**Describe alternatives you've considered**
Alternative solutions or features you've considered.

**Additional context**
Any other context or screenshots about the feature request.
```

## Community Support

### Communication Channels

- **GitHub Discussions**: General questions and discussions
- **Issues**: Bug reports and feature requests
- **Email**: security@campus-mesh.edu for security issues

### Getting Help

1. **Check existing documentation** first
2. **Search existing issues** for similar problems
3. **Ask in discussions** for general questions
4. **Create an issue** for bugs or features

### Recognition

Contributors will be recognized in:
- **CONTRIBUTORS.md** file
- **Release notes** for significant contributions
- **GitHub contributor insights**

## Development Resources

### Useful Links

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Material Design Guidelines](https://material.io/design)

### Development Tools

- **VS Code Extensions**:
  - Flutter
  - Dart
  - Firebase
  - TypeScript
  - ESLint
  - Prettier

- **Debugging Tools**:
  - Flutter Inspector
  - Firebase Emulator UI
  - Chrome DevTools
  - Flipper (for React Native debugging)

Thank you for contributing to Campus Mesh! 🚀