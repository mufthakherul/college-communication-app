# Deployment Guide

## Overview

This guide covers the deployment process for Campus Mesh across different environments. The deployment strategy follows DevOps best practices with automated CI/CD pipelines and infrastructure as code.

## Environments

### Development
- **Purpose**: Local development and testing
- **Firebase Project**: `campus-mesh-dev`
- **Emulators**: All services run locally
- **Data**: Test data only

### Staging
- **Purpose**: Pre-production testing and validation
- **Firebase Project**: `campus-mesh-staging`
- **URL**: https://staging.campus-mesh.edu
- **Data**: Sanitized production-like data

### Production
- **Purpose**: Live application serving users
- **Firebase Project**: `campus-mesh-prod`
- **URL**: https://campus-mesh.edu
- **Data**: Live user data with full security

## Prerequisites

### Required Tools
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Install Flutter
# Follow official Flutter installation guide

# Install Node.js (v18+)
# Download from nodejs.org

# Login to Firebase
firebase login
```

### Environment Setup
```bash
# Clone repository
git clone https://github.com/mufthakherul/college-communication-app.git
cd college-communication-app

# Install dependencies
npm install -g firebase-tools
cd functions && npm install
cd ../apps/mobile && flutter pub get
```

## Local Development Deployment

### 1. Start Emulators
```bash
# Start all Firebase emulators
firebase emulators:start

# Or use the setup script
./scripts/setup-dev.sh
```

### 2. Emulator Ports
- **Firebase UI**: http://localhost:4000
- **Authentication**: http://localhost:9099
- **Firestore**: http://localhost:8080
- **Functions**: http://localhost:5001
- **Storage**: http://localhost:9199

### 3. Mobile App Development
```bash
cd apps/mobile

# Run on emulator
flutter run

# Run on connected device
flutter run -d <device_id>

# Run on web
flutter run -d chrome
```

## Staging Deployment

### 1. Pre-deployment Checks
```bash
# Run tests
cd functions
npm test

# Run linting
npm run lint

# Build functions
npm run build

# Flutter tests
cd ../apps/mobile
flutter test
flutter analyze
```

### 2. Deploy to Staging
```bash
# Use deployment script
./scripts/deploy.sh staging

# Or manual deployment
firebase use staging
firebase deploy --only firestore,storage,functions
```

### 3. Validation
- **Smoke Tests**: Basic functionality verification
- **Integration Tests**: End-to-end testing
- **Performance Tests**: Load and stress testing
- **Security Tests**: Vulnerability scanning

## Production Deployment

### 1. Pre-production Checklist
- [ ] All staging tests passed
- [ ] Security review completed
- [ ] Performance benchmarks met
- [ ] Rollback plan prepared
- [ ] Monitoring alerts configured
- [ ] Team notification sent

### 2. Production Deployment
```bash
# Deploy to production
./scripts/deploy.sh production

# Monitor deployment
firebase functions:log --follow
```

### 3. Post-deployment Validation
```bash
# Health check
curl https://us-central1-campus-mesh-prod.cloudfunctions.net/healthCheck

# Smoke tests
npm run test:smoke

# Monitor metrics
firebase projects:describe campus-mesh-prod
```

## Mobile App Deployment

### Android Deployment

#### 1. Build Release APK
```bash
cd apps/mobile

# Build release APK
flutter build apk --release

# Build App Bundle (recommended)
flutter build appbundle --release
```

#### 2. Code Signing
```bash
# Generate keystore (first time only)
keytool -genkey -v -keystore campus-mesh-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias campus-mesh

# Configure signing in android/app/build.gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
```

#### 3. Play Store Upload
1. Create release in Google Play Console
2. Upload App Bundle
3. Set up release tracks (internal, alpha, beta, production)
4. Configure store listing and screenshots

### iOS Deployment

#### 1. Build Release IPA
```bash
cd apps/mobile

# Build iOS release
flutter build ios --release

# Archive in Xcode
open ios/Runner.xcworkspace
```

#### 2. Code Signing
1. Configure provisioning profiles in Xcode
2. Set up App Store Connect certificates
3. Configure build settings for release

#### 3. App Store Upload
1. Archive app in Xcode
2. Upload to App Store Connect
3. Configure app information and screenshots
4. Submit for review

## CI/CD Pipeline

### GitHub Actions Workflow
```yaml
# .github/workflows/deploy.yml
name: Deploy Campus Mesh

on:
  push:
    branches: [main, staging]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Install dependencies
        run: cd functions && npm install
      - name: Run tests
        run: cd functions && npm test
      - name: Lint code
        run: cd functions && npm run lint

  deploy-staging:
    if: github.ref == 'refs/heads/staging'
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Staging
        run: |
          npm install -g firebase-tools
          firebase use staging --token ${{ secrets.FIREBASE_TOKEN }}
          ./scripts/deploy.sh staging

  deploy-production:
    if: github.ref == 'refs/heads/main'
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Production
        run: |
          npm install -g firebase-tools
          firebase use production --token ${{ secrets.FIREBASE_TOKEN }}
          ./scripts/deploy.sh production
```

### Deployment Scripts

#### Main Deployment Script
```bash
#!/bin/bash
# scripts/deploy.sh

set -e

ENVIRONMENT=${1:-staging}
echo "Deploying to $ENVIRONMENT..."

# Set Firebase project
firebase use $ENVIRONMENT

# Deploy infrastructure
echo "Deploying Firestore rules..."
firebase deploy --only firestore

echo "Deploying Storage rules..."
firebase deploy --only storage

# Deploy functions
echo "Building and deploying functions..."
cd functions
npm run build
cd ..
firebase deploy --only functions

# Deploy hosting (if applicable)
if [ "$ENVIRONMENT" = "production" ]; then
    echo "Deploying web app..."
    firebase deploy --only hosting
fi

echo "Deployment completed successfully!"
```

## Database Migrations

### Firestore Data Migration
```typescript
// scripts/migrate-data.ts
import * as admin from 'firebase-admin';

admin.initializeApp();

async function migrateUserData() {
  const batch = admin.firestore().batch();
  const usersRef = admin.firestore().collection('users');
  const snapshot = await usersRef.get();
  
  snapshot.docs.forEach(doc => {
    const data = doc.data();
    // Add new field with default value
    if (!data.hasOwnProperty('newField')) {
      batch.update(doc.ref, { newField: 'defaultValue' });
    }
  });
  
  await batch.commit();
  console.log('Migration completed');
}

migrateUserData().catch(console.error);
```

### Running Migrations
```bash
# Run migration script
cd scripts
npx ts-node migrate-data.ts

# Or deploy as a Cloud Function
firebase deploy --only functions:migrateData
```

## Configuration Management

### Environment Variables
```bash
# Set Firebase Functions config
firebase functions:config:set app.environment="production"
firebase functions:config:set app.version="1.0.0"
firebase functions:config:set notification.vapid_key="your-vapid-key"

# Deploy config
firebase deploy --only functions
```

### Remote Config
```json
// infra/remoteconfig.template.json
{
  "parameters": {
    "maintenance_mode": {
      "defaultValue": {
        "value": "false"
      }
    },
    "max_file_size_mb": {
      "defaultValue": {
        "value": "25"
      }
    }
  }
}
```

## Monitoring & Rollback

### Deployment Monitoring
```bash
# Monitor function logs
firebase functions:log --follow

# Check function performance
firebase functions:list

# Monitor Firestore metrics
gcloud logging read "resource.type=cloud_function"
```

### Rollback Procedures

#### Functions Rollback
```bash
# List function versions
gcloud functions list

# Rollback to previous version
firebase functions:delete functionName
firebase deploy --only functions:functionName
```

#### Database Rollback
```bash
# Restore from backup (if available)
gcloud firestore databases restore \
  --source-backup=projects/PROJECT_ID/databases/(default)/backups/BACKUP_ID \
  --destination-database='(default)'
```

## Backup & Disaster Recovery

### Automated Backups
```bash
# Schedule Firestore backups
gcloud firestore operations list
gcloud firestore export gs://backup-bucket-name
```

### Recovery Testing
```bash
# Test backup restoration
firebase emulators:start --import=./backup-data

# Validate data integrity
npm run test:integration
```

## Security Considerations

### Deployment Security
- Use service accounts with minimal permissions
- Encrypt sensitive configuration data
- Audit deployment access logs
- Implement approval workflows for production

### Runtime Security
- Monitor for security vulnerabilities
- Keep dependencies updated
- Use security headers and CORS policies
- Implement rate limiting

## Performance Optimization

### Bundle Size Optimization
```bash
# Analyze Flutter bundle
flutter build apk --analyze-size

# Optimize images and assets
flutter build apk --tree-shake-icons
```

### Function Performance
- Monitor function execution time
- Optimize cold start performance
- Use connection pooling for databases
- Implement proper caching strategies

## Troubleshooting

### Common Deployment Issues

#### Function Deployment Failures
```bash
# Check function logs
firebase functions:log

# Validate TypeScript compilation
cd functions && npm run build

# Check dependencies
npm audit
```

#### Mobile App Build Issues
```bash
# Clean Flutter cache
flutter clean
flutter pub get

# Check for platform-specific issues
flutter doctor
```

### Support Resources
- **Documentation**: https://firebase.google.com/docs
- **Community**: https://stackoverflow.com/questions/tagged/firebase
- **Support**: https://firebase.google.com/support