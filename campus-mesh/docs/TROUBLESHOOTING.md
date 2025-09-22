# Troubleshooting Guide

This guide helps resolve common issues encountered while developing, deploying, or using Campus Mesh.

## Table of Contents

1. [Development Issues](#development-issues)
2. [Firebase Setup Issues](#firebase-setup-issues)
3. [Flutter Issues](#flutter-issues)
4. [Cloud Functions Issues](#cloud-functions-issues)
5. [Authentication Issues](#authentication-issues)
6. [Database Issues](#database-issues)
7. [Storage Issues](#storage-issues)
8. [Deployment Issues](#deployment-issues)
9. [Performance Issues](#performance-issues)
10. [Network Issues](#network-issues)

## Development Issues

### Environment Setup Problems

#### Issue: Firebase CLI not recognized
```bash
Error: 'firebase' is not recognized as an internal or external command
```

**Solution:**
```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Verify installation
firebase --version

# If still not working, add to PATH or use npx
npx firebase-tools --version
```

#### Issue: Flutter command not found
```bash
Error: flutter: command not found
```

**Solution:**
```bash
# Add Flutter to PATH in your shell profile
echo 'export PATH="$PATH:/path/to/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Verify Flutter installation
flutter doctor
```

#### Issue: Node.js version compatibility
```bash
Error: The engine "node" is incompatible with this module
```

**Solution:**
```bash
# Check Node.js version
node --version

# Install Node.js 18+
# Use nvm for version management
nvm install 18
nvm use 18
```

## Firebase Setup Issues

### Authentication Configuration

#### Issue: Firebase config not found
```javascript
Error: Firebase app named '[DEFAULT]' already exists
```

**Solution:**
```javascript
// Check if Firebase is already initialized
if (firebase.apps.length === 0) {
  firebase.initializeApp(firebaseConfig);
}

// Or use a try-catch block
try {
  firebase.initializeApp(firebaseConfig);
} catch (error) {
  if (error.code === 'app/duplicate-app') {
    console.log('Firebase already initialized');
  } else {
    throw error;
  }
}
```

#### Issue: Invalid Firebase credentials
```javascript
Error: The provided Firebase credentials are invalid
```

**Solution:**
```bash
# Re-login to Firebase
firebase logout
firebase login

# Verify project access
firebase projects:list

# Check .firebaserc configuration
cat .firebaserc
```

### Emulator Issues

#### Issue: Emulator ports already in use
```bash
Error: Port 8080 is already in use
```

**Solution:**
```bash
# Kill processes using the ports
lsof -ti:8080 | xargs kill -9

# Or use different ports
firebase emulators:start --port=9000
```

#### Issue: Emulator data not persisting
```bash
Warning: No emulator data found
```

**Solution:**
```bash
# Start emulators with import/export
firebase emulators:start --import=./emulator-data --export-on-exit

# Or manually export data
firebase emulators:export ./backup-data
```

## Flutter Issues

### Build Problems

#### Issue: Flutter build fails
```bash
Error: Could not resolve all files for configuration ':app:debugRuntimeClasspath'
```

**Solution:**
```bash
# Clean Flutter cache
flutter clean
flutter pub get

# Clean Android cache
cd android
./gradlew clean
cd ..

# Rebuild
flutter build apk
```

#### Issue: iOS build fails
```bash
Error: CocoaPods not installed
```

**Solution:**
```bash
# Install CocoaPods
sudo gem install cocoapods

# Install iOS dependencies
cd ios
pod install
cd ..

# Build iOS
flutter build ios
```

### Dependency Issues

#### Issue: Package version conflicts
```yaml
Error: Version solving failed
```

**Solution:**
```yaml
# In pubspec.yaml, use dependency overrides
dependency_overrides:
  meta: ^1.8.0
  
# Or update all dependencies
flutter pub upgrade
```

#### Issue: Firebase plugin errors
```dart
Error: MissingPluginException(No implementation found for method)
```

**Solution:**
```bash
# Reinstall Flutter plugins
flutter packages get
flutter clean
flutter run

# For iOS, reinstall pods
cd ios && pod install && cd ..
```

## Cloud Functions Issues

### Deployment Problems

#### Issue: Function deployment timeout
```bash
Error: Functions deployment timed out
```

**Solution:**
```bash
# Increase timeout
firebase deploy --only functions --timeout 600

# Deploy functions individually
firebase deploy --only functions:functionName
```

#### Issue: TypeScript compilation errors
```bash
Error: TS2345: Argument of type 'string' is not assignable
```

**Solution:**
```bash
# Check TypeScript configuration
cat functions/tsconfig.json

# Build locally to see errors
cd functions
npm run build

# Fix type errors and redeploy
```

### Runtime Issues

#### Issue: Function cold starts
```javascript
Error: Function execution timeout
```

**Solution:**
```typescript
// Optimize function for cold starts
import * as functions from 'firebase-functions';

// Keep connections warm
let db: admin.firestore.Firestore;

export const optimizedFunction = functions.https.onCall(async (data) => {
  // Initialize once
  if (!db) {
    db = admin.firestore();
  }
  
  // Your function logic
});
```

#### Issue: Memory limit exceeded
```bash
Error: Function memory limit exceeded
```

**Solution:**
```typescript
// Increase memory allocation
export const memoryIntensiveFunction = functions
  .runWith({ memory: '1GB' })
  .https.onCall(async (data) => {
    // Function logic
  });
```

## Authentication Issues

### Login Problems

#### Issue: Users can't sign in
```javascript
Error: auth/user-not-found
```

**Solution:**
```javascript
// Check authentication configuration
firebase.auth().onAuthStateChanged((user) => {
  if (user) {
    console.log('User signed in:', user.uid);
  } else {
    console.log('User not signed in');
  }
});

// Enable sign-in methods in Firebase Console
// Authentication > Sign-in method
```

#### Issue: Token validation failures
```javascript
Error: auth/id-token-expired
```

**Solution:**
```javascript
// Refresh user token
firebase.auth().currentUser?.getIdToken(true)
  .then((token) => {
    // Use fresh token
    console.log('Fresh token:', token);
  })
  .catch((error) => {
    console.error('Token refresh failed:', error);
  });
```

### Permission Issues

#### Issue: Insufficient permissions
```javascript
Error: auth/insufficient-permission
```

**Solution:**
```javascript
// Check user claims
firebase.auth().currentUser?.getIdTokenResult()
  .then((idTokenResult) => {
    console.log('User claims:', idTokenResult.claims);
  });

// Update user custom claims (admin function)
admin.auth().setCustomUserClaims(uid, { admin: true });
```

## Database Issues

### Firestore Problems

#### Issue: Permission denied
```javascript
Error: FirebaseError: Missing or insufficient permissions
```

**Solution:**
```javascript
// Check Firestore rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

#### Issue: Query performance issues
```javascript
Error: The query requires an index
```

**Solution:**
```bash
# Create composite indexes
# Go to Firebase Console > Firestore > Indexes
# Or use the provided URL in the error message

# For programmatic index creation
firebase deploy --only firestore:indexes
```

### Data Inconsistency

#### Issue: Stale data displayed
```javascript
Warning: Using cached data that might be stale
```

**Solution:**
```javascript
// Force fresh data fetch
const docRef = firebase.firestore().collection('users').doc(userId);
docRef.get({ source: 'server' })  // Force server fetch
  .then((doc) => {
    console.log('Fresh data:', doc.data());
  });
```

## Storage Issues

### Upload Problems

#### Issue: File upload fails
```javascript
Error: storage/unauthorized
```

**Solution:**
```javascript
// Check storage rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /uploads/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

#### Issue: Large file uploads timeout
```javascript
Error: storage/retry-limit-exceeded
```

**Solution:**
```javascript
// Implement resumable uploads
const uploadTask = firebase.storage()
  .ref(`uploads/${file.name}`)
  .put(file, {
    customMetadata: {
      'uploaded-by': userId
    }
  });

// Monitor upload progress
uploadTask.on('state_changed',
  (snapshot) => {
    const progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
    console.log('Upload is ' + progress + '% done');
  },
  (error) => {
    console.error('Upload failed:', error);
    // Retry upload
  },
  () => {
    console.log('Upload completed successfully');
  }
);
```

## Deployment Issues

### CI/CD Problems

#### Issue: GitHub Actions failing
```yaml
Error: Process completed with exit code 1
```

**Solution:**
```yaml
# Check GitHub Actions logs
# Ensure secrets are properly configured

# In GitHub repository settings > Secrets:
FIREBASE_TOKEN: <your-ci-token>

# Generate CI token
firebase login:ci
```

#### Issue: Production deployment fails
```bash
Error: HTTP Error: 403, The caller does not have permission
```

**Solution:**
```bash
# Check service account permissions
# Ensure the service account has the required roles:
# - Cloud Functions Developer
# - Firestore Service Agent
# - Storage Admin

# Re-authenticate
firebase login
firebase use production
```

## Performance Issues

### App Performance

#### Issue: Slow app startup
```dart
Warning: First frame took 2000ms to render
```

**Solution:**
```dart
// Optimize app startup
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize critical services first
  await Firebase.initializeApp();
  
  // Defer non-critical initializations
  runApp(MyApp());
  
  // Initialize other services after app starts
  WidgetsBinding.instance.addPostFrameCallback((_) {
    initializeNonCriticalServices();
  });
}
```

#### Issue: Large bundle size
```bash
Warning: App bundle size is larger than 100MB
```

**Solution:**
```bash
# Analyze bundle size
flutter build apk --analyze-size

# Enable tree shaking
flutter build apk --tree-shake-icons

# Split APKs by architecture
flutter build apk --split-per-abi
```

### Database Performance

#### Issue: Slow queries
```javascript
Warning: Query took 5000ms to execute
```

**Solution:**
```javascript
// Add appropriate indexes
// Limit query results
const query = firebase.firestore()
  .collection('messages')
  .where('userId', '==', userId)
  .orderBy('timestamp', 'desc')
  .limit(20);  // Limit results

// Use pagination
const firstBatch = await query.get();
const lastDoc = firstBatch.docs[firstBatch.docs.length - 1];

const nextBatch = await query
  .startAfter(lastDoc)
  .limit(20)
  .get();
```

## Network Issues

### Connectivity Problems

#### Issue: Network requests failing
```javascript
Error: NetworkError: Failed to fetch
```

**Solution:**
```javascript
// Implement retry logic
async function retryRequest(requestFn, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await requestFn();
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      
      // Exponential backoff
      const delay = Math.pow(2, i) * 1000;
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}
```

#### Issue: CORS errors
```javascript
Error: Access to fetch blocked by CORS policy
```

**Solution:**
```typescript
// In Cloud Functions, enable CORS
import * as cors from 'cors';

const corsHandler = cors({ origin: true });

export const myFunction = functions.https.onRequest((req, res) => {
  corsHandler(req, res, () => {
    // Your function logic
    res.json({ success: true });
  });
});
```

## Getting Additional Help

### Debug Information Collection

When reporting issues, include:

```bash
# Environment information
flutter doctor -v
firebase --version
node --version
npm --version

# Error logs
flutter logs
firebase functions:log

# Project configuration
cat pubspec.yaml
cat functions/package.json
cat .firebaserc
```

### Support Channels

1. **GitHub Issues**: For bug reports and feature requests
2. **GitHub Discussions**: For general questions
3. **Stack Overflow**: Use tags `firebase`, `flutter`, `campus-mesh`
4. **Firebase Support**: For Firebase-specific issues

### Emergency Procedures

For production emergencies:

1. **Check status pages**: Firebase Status, Google Cloud Status
2. **Review recent deployments**: Roll back if necessary
3. **Contact support**: Use priority support channels
4. **Communicate with users**: Status page updates

Remember: Most issues can be resolved by carefully reading error messages and following the suggested solutions. When in doubt, consult the official documentation for Flutter and Firebase.