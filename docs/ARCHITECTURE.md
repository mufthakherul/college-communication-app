# Campus Mesh Architecture

## Overview

Campus Mesh follows a modern, cloud-native architecture designed for scalability, security, and maintainability. The system is built on Firebase, leveraging its **FREE** managed services for authentication, database, storage, and messaging.

> 💰 **100% Free Architecture**: This app uses NO paid services - all operations use free Firebase services with client-side business logic!

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Client Layer                         │
│              (All Business Logic Here)                      │
├─────────────────────────────────────────────────────────────┤
│  Flutter Mobile App (iOS/Android)  │  Flutter Web App       │
└─────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│              Free Firebase Services                         │
├─────────────────────────────────────────────────────────────┤
│  Firebase Auth  │  Cloud Firestore  │  Firebase Storage     │
│  (Free)         │  (Free Tier)      │  (Free Tier)          │
│                 │                    │                       │
│  Firebase Messaging (Free)  │  Security Rules (Free)        │
└─────────────────────────────────────────────────────────────┘
```

**Key Architectural Decision:**
- **No Cloud Functions**: All business logic runs client-side to avoid paid services
- **Security Rules**: Firestore Security Rules enforce authorization and validation
- **Direct Operations**: Flutter app writes directly to Firestore
- **Free Forever**: Perfect for college/educational projects

## Core Components

### 1. Flutter Mobile App (`apps/mobile/`)

The frontend application built with Flutter, providing:

- **Cross-platform compatibility**: Single codebase for iOS and Android
- **Real-time updates**: Using Firebase SDK for live data synchronization
- **Offline capability**: Local caching with automatic sync when online
- **Responsive UI**: Adaptive design for different screen sizes

#### Key Features:
- User authentication and profile management
- Real-time messaging with typing indicators
- Rich notice board with media attachments
- Push notification handling
- File upload/download with progress tracking

### 2. Client-Side Business Logic

> **Note**: The `functions/` directory contains reference implementation of Cloud Functions for those who want to use them. However, **the app works completely without Cloud Functions** using client-side operations and Firestore Security Rules.

All business logic is implemented in Flutter services:

**User Management (`auth_service.dart`)**
- User profile creation on registration
- Profile updates with role validation
- Authentication and session management

**Messaging (`messaging.ts`)**
- Message sending and delivery
- Push notification triggers
- Message status tracking

**Notices (`notices.ts`)**
- Notice creation and management
- Approval workflows
- Notification distribution

**Admin Approval (`adminApproval.ts`)**
- Request approval workflows
- Admin notification system
- Status tracking and updates

**Analytics (`analytics.ts`)**
- Usage data collection
- Report generation
- Performance metrics

### 3. Data Layer

#### Cloud Firestore Collections:

```
users/
├── {userId}
│   ├── email
│   ├── displayName
│   ├── role (student|teacher|admin)
│   ├── department
│   └── metadata

notices/
├── {noticeId}
│   ├── title
│   ├── content
│   ├── authorId
│   ├── targetAudience
│   └── timestamps

messages/
├── {messageId}
│   ├── senderId
│   ├── recipientId
│   ├── content
│   ├── type
│   └── timestamps

notifications/
├── {notificationId}
│   ├── userId
│   ├── type
│   ├── title
│   ├── body
│   └── metadata
```

#### Firebase Storage Structure:

```
/users/{userId}/profile/    - Profile images
/notices/{noticeId}/attachments/    - Notice attachments
/messages/{messageId}/attachments/  - Message attachments
/public/    - Public assets
/temp/     - Temporary uploads
```

## Security Architecture

### Authentication Flow

1. **User Registration/Login**
   - Firebase Auth handles authentication
   - Custom claims for role-based access
   - JWT tokens for secure API calls

2. **Authorization**
   - Firestore security rules enforce data access
   - Cloud Function middleware for admin operations
   - Role-based permissions (RBAC)

### Data Security

- **Firestore Rules**: Field-level access control
- **Storage Rules**: File access and upload validation
- **Function Security**: Authentication middleware
- **Input Validation**: Sanitization and type checking

## Scalability Considerations

### Horizontal Scaling
- **Firebase Auto-scaling**: Automatic resource allocation
- **Cloud Functions**: Serverless scaling based on demand
- **CDN Integration**: Global content distribution

### Performance Optimization
- **Database Indexing**: Optimized queries
- **Caching Strategy**: Local and Firebase caching
- **Image Optimization**: Automatic resizing and compression
- **Bundle Size**: Code splitting and lazy loading

## Development Workflow

### Local Development
1. Firebase Emulators for local testing
2. Hot reload for Flutter development
3. TypeScript compilation and linting
4. Automated testing pipeline

### CI/CD Pipeline
1. **Code Quality**: ESLint, Flutter Analyze
2. **Testing**: Unit tests, Integration tests
3. **Build**: TypeScript compilation, Flutter build
4. **Deploy**: Automated deployment to staging/production

## Monitoring and Observability

### Application Monitoring
- Firebase Crashlytics for crash reporting
- Performance Monitoring for app performance
- Custom analytics for user behavior

### Infrastructure Monitoring
- Cloud Function metrics and logs
- Firestore usage and performance metrics
- Storage usage and access patterns

## Disaster Recovery

### Data Backup
- Automatic Firestore backups
- Storage file redundancy
- Configuration backup

### Recovery Procedures
- Database restore procedures
- Function rollback strategies
- Configuration recovery

## Future Enhancements

### Planned Features
- **Video Calling**: WebRTC integration
- **AI Chatbot**: Automated responses
- **Multi-language**: Internationalization
- **Advanced Analytics**: ML-powered insights

### Infrastructure Improvements
- **Microservices**: Service decomposition
- **API Gateway**: Centralized API management
- **Event Streaming**: Real-time event processing