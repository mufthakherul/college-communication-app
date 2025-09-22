# Campus Mesh API Reference

## Overview

Campus Mesh provides a comprehensive API built on Firebase Cloud Functions. All endpoints are secured with Firebase Authentication and follow RESTful principles.

## Authentication

All API calls require a valid Firebase ID token in the request headers:

```javascript
{
  "Authorization": "Bearer <firebase_id_token>"
}
```

## Base URL

- **Development**: `http://localhost:5001/campus-mesh-dev/us-central1`
- **Staging**: `https://us-central1-campus-mesh-staging.cloudfunctions.net`
- **Production**: `https://us-central1-campus-mesh-prod.cloudfunctions.net`

## User Management

### Create User Profile
**Triggered automatically on user registration**

### Update User Profile
```javascript
// Function: updateUserProfile
{
  "updates": {
    "displayName": "John Doe",
    "department": "Computer Science",
    "year": "2024"
  }
}
```

**Response:**
```javascript
{
  "success": true
}
```

### Update User Role (Admin Only)
```javascript
// Function: updateUserRole
{
  "userId": "user123",
  "newRole": "teacher"
}
```

**Response:**
```javascript
{
  "success": true
}
```

## Messaging

### Send Message
```javascript
// Function: sendMessage
{
  "recipientId": "user456",
  "content": "Hello, how are you?",
  "type": "text"
}
```

**Response:**
```javascript
{
  "success": true,
  "messageId": "msg789"
}
```

### Mark Message as Read
```javascript
// Function: markMessageAsRead
{
  "messageId": "msg789"
}
```

**Response:**
```javascript
{
  "success": true
}
```

## Notice Management

### Create Notice
```javascript
// Function: createNotice
{
  "title": "Important Announcement",
  "content": "This is an important announcement for all students.",
  "type": "announcement",
  "targetAudience": "students",
  "expiresAt": "2024-12-31T23:59:59Z"
}
```

**Response:**
```javascript
{
  "success": true,
  "noticeId": "notice123"
}
```

### Update Notice
```javascript
// Function: updateNotice
{
  "noticeId": "notice123",
  "updates": {
    "title": "Updated Announcement",
    "content": "This is the updated content."
  }
}
```

**Response:**
```javascript
{
  "success": true
}
```

## Admin Approval

### Request Admin Approval
```javascript
// Function: requestAdminApproval
{
  "type": "role_change",
  "data": {
    "requestedRole": "teacher",
    "reason": "I am a faculty member"
  }
}
```

**Response:**
```javascript
{
  "success": true,
  "requestId": "req456"
}
```

### Process Approval Request (Admin Only)
```javascript
// Function: processApprovalRequest
{
  "requestId": "req456",
  "action": "approved",
  "reason": "Verified credentials"
}
```

**Response:**
```javascript
{
  "success": true
}
```

## Analytics

### Track User Activity
```javascript
// Function: trackUserActivity
{
  "action": "view_notice",
  "metadata": {
    "noticeId": "notice123",
    "duration": 30000
  }
}
```

**Response:**
```javascript
{
  "success": true
}
```

### Generate Analytics Report (Admin Only)
```javascript
// Function: generateAnalyticsReport
{
  "reportType": "user_activity",
  "startDate": "2024-01-01T00:00:00Z",
  "endDate": "2024-01-31T23:59:59Z"
}
```

**Response:**
```javascript
{
  "success": true,
  "report": {
    "totalActivities": 1500,
    "uniqueUsers": 250,
    "topActions": [
      ["view_notice", 500],
      ["send_message", 300],
      ["login", 250]
    ],
    "dailyBreakdown": {
      "2024-01-01": 50,
      "2024-01-02": 75
    }
  }
}
```

## Health Check

### System Health
```javascript
// Function: healthCheck
// GET request to /healthCheck
```

**Response:**
```javascript
{
  "status": "ok",
  "timestamp": "2024-01-15T10:30:00Z",
  "service": "campus-mesh-functions"
}
```

## Error Handling

All API functions return standardized error responses:

### Authentication Error
```javascript
{
  "error": {
    "code": "unauthenticated",
    "message": "User must be authenticated"
  }
}
```

### Permission Error
```javascript
{
  "error": {
    "code": "permission-denied",
    "message": "Insufficient permissions"
  }
}
```

### Validation Error
```javascript
{
  "error": {
    "code": "invalid-argument",
    "message": "Invalid input parameters"
  }
}
```

### Internal Error
```javascript
{
  "error": {
    "code": "internal",
    "message": "Internal server error"
  }
}
```

## Rate Limiting

API endpoints are rate-limited to prevent abuse:

- **General endpoints**: 100 requests per minute per user
- **Messaging endpoints**: 50 requests per minute per user
- **Admin endpoints**: 200 requests per minute per admin
- **Analytics endpoints**: 10 requests per minute per user

## Data Models

### User
```javascript
{
  "uid": "string",
  "email": "string",
  "displayName": "string",
  "photoURL": "string",
  "role": "student|teacher|admin",
  "department": "string",
  "year": "string",
  "isActive": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Notice
```javascript
{
  "id": "string",
  "title": "string",
  "content": "string",
  "type": "announcement|event|urgent",
  "targetAudience": "all|students|teachers|admin",
  "authorId": "string",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "expiresAt": "timestamp",
  "isActive": "boolean"
}
```

### Message
```javascript
{
  "id": "string",
  "senderId": "string",
  "recipientId": "string",
  "content": "string",
  "type": "text|image|file",
  "createdAt": "timestamp",
  "read": "boolean",
  "readAt": "timestamp"
}
```

### Approval Request
```javascript
{
  "id": "string",
  "userId": "string",
  "type": "role_change|account_recovery",
  "data": "object",
  "status": "pending|approved|rejected",
  "createdAt": "timestamp",
  "processedAt": "timestamp",
  "processedBy": "string",
  "reason": "string"
}
```

## SDK Usage Examples

### JavaScript/TypeScript
```javascript
import { getFunctions, httpsCallable } from 'firebase/functions';

const functions = getFunctions();

// Send a message
const sendMessage = httpsCallable(functions, 'sendMessage');
const result = await sendMessage({
  recipientId: 'user456',
  content: 'Hello!',
  type: 'text'
});

console.log(result.data);
```

### Flutter/Dart
```dart
import 'package:cloud_functions/cloud_functions.dart';

// Send a message
final functions = FirebaseFunctions.instance;
final callable = functions.httpsCallable('sendMessage');

try {
  final result = await callable.call({
    'recipientId': 'user456',
    'content': 'Hello!',
    'type': 'text',
  });
  print(result.data);
} catch (e) {
  print('Error: $e');
}
```

## Testing

### Emulator Usage
```bash
# Start emulators
firebase emulators:start

# Test endpoint
curl -X POST \
  http://localhost:5001/campus-mesh-dev/us-central1/sendMessage \
  -H "Authorization: Bearer <test_token>" \
  -H "Content-Type: application/json" \
  -d '{"recipientId": "test", "content": "Hello", "type": "text"}'
```

### Unit Testing
```javascript
// Example test for sendMessage function
const test = require('firebase-functions-test')();
const { sendMessage } = require('../src/messaging');

describe('sendMessage', () => {
  it('should send a message successfully', async () => {
    const data = {
      recipientId: 'user456',
      content: 'Test message',
      type: 'text'
    };
    
    const context = {
      auth: { uid: 'user123' }
    };
    
    const result = await sendMessage(data, context);
    expect(result.success).toBe(true);
  });
});
```