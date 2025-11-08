# Test Scripts Update Documentation

## Overview

This document describes the updates made to the test scripts to align with the new database structure that separates user data into two collections.

## Problem

The test scripts were failing because they were trying to create user documents with fields that no longer exist in the `users` collection. The database structure was refactored to separate concerns:

- **Old Structure**: Single `users` collection with all fields (common + role-specific)
- **New Structure**: 
  - `users` collection: Common user identity data
  - `user_profiles` collection: Role-specific extended data

## Database Schema Changes

### Before (Old Structure)

**users Collection** - Mixed all user data together:
```javascript
{
  email: "student@test.com",
  display_name: "Test Student",
  role: "student",
  department: "CSE",
  year: "2024",
  // ❌ Student-specific fields mixed with common data
  shift: "Day",
  group: "A",
  class_roll: "101",
  academic_session: "2024-2025",
  phone_number: "+1234567890",
  // etc.
}
```

### After (New Structure)

**users Collection** - Common identity data only (9 attributes):
```javascript
{
  email: "student@test.com",
  display_name: "Test Student",
  role: "student",          // Identifies the type of user
  department: "CSE",
  year: "2024",
  is_active: true,
  created_at: "2024-11-08T...",
  updated_at: "2024-11-08T..."
}
```

**user_profiles Collection** - Role-specific data (20 attributes):
```javascript
{
  user_id: "user_abc123",   // References users.$id
  role: "student",
  // ✅ Student-specific fields
  shift: "Day",
  group: "A",
  class_roll: "101",
  academic_session: "2024-2025",
  registration_no: "REG2024001",
  guardian_name: "Test Guardian",
  guardian_phone: "+1234567890",
  bio: "Test student bio",
  phone_number: "+0987654321",
  created_at: "2024-11-08T..."
}
```

## Updated Test Scripts

### 1. test-user-profiles.js

**Purpose**: Tests CRUD operations for user profiles (student, teacher, admin)

**Changes Made**:

#### Test 1: Create Student Profile
```javascript
// STEP 1: Create user in 'users' collection
const testUser = await databases.createDocument(
  DATABASE_ID,
  'users',
  sdk.ID.unique(),
  {
    email: `test-student-${Date.now()}@test.com`,
    display_name: 'Test Student',
    role: 'student',
    department: 'Computer Science',
    year: '2024',
    is_active: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  }
);

// STEP 2: Create profile in 'user_profiles' collection
const studentProfile = await databases.createDocument(
  DATABASE_ID,
  'user_profiles',
  sdk.ID.unique(),
  {
    user_id: testUser.$id,  // Link to user
    role: 'student',
    shift: 'Day',
    group: 'A',
    class_roll: '101',
    // ... other student-specific fields
  }
);
```

#### Test 2: Create Teacher Profile
```javascript
// STEP 1: Create user in 'users' collection
const testUser = await databases.createDocument(
  DATABASE_ID,
  'users',
  sdk.ID.unique(),
  {
    email: `test-teacher-${Date.now()}@test.com`,
    display_name: 'Test Teacher',
    role: 'teacher',
    department: 'Mathematics',
    is_active: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  }
);

// STEP 2: Create profile in 'user_profiles' collection
const teacherProfile = await databases.createDocument(
  DATABASE_ID,
  'user_profiles',
  sdk.ID.unique(),
  {
    user_id: testUser.$id,  // Link to user
    role: 'teacher',
    designation: 'Associate Professor',
    office_room: 'Room 301',
    subjects: ['Calculus', 'Linear Algebra', 'Statistics'],
    // ... other teacher-specific fields
  }
);
```

#### Test 3: Create Admin Profile
Similar two-step process for admin users with admin-specific fields (admin_title, admin_scopes).

### 2. test-appwrite-features.js

**Purpose**: Tests group chat functionality and storage buckets

**Changes Made**:

#### testCreateUsers() Function
Now creates BOTH authentication users AND database user entries:

```javascript
// Create authentication user (Appwrite Auth)
const user1 = await users.create(
  sdk.ID.unique(),
  'testuser1@rpi.edu.bd',
  undefined,
  'Test User 1',
  'testpass123'
);

// Also create database user entry in 'users' collection
await databases.createDocument(
  DATABASE_ID,
  'users',
  sdk.ID.unique(),
  {
    email: 'testuser1@rpi.edu.bd',
    display_name: 'Test User 1',
    role: 'student',
    department: 'Computer Science',
    is_active: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  }
);
```

**Why Both?**
- Authentication users: For login/authentication (Appwrite Auth)
- Database users: For application data and relationships (users collection)

## Benefits of New Structure

### 1. Clean Separation of Concerns
- ✅ Common auth/identity data stays in `users`
- ✅ Role-specific data isolated in `user_profiles`
- ✅ No breaking changes to existing services (messaging, notifications, etc.)

### 2. Performance Improvements
- ✅ Reduced `users` collection size (14 → 9 attributes)
- ✅ Faster user authentication queries
- ✅ Lazy loading of extended profile data

### 3. Scalability
- ✅ Easy to add new role-specific fields without touching `users`
- ✅ Support for future roles (e.g., parent, staff)
- ✅ Extensible permission model

### 4. Data Integrity
- ✅ No more null/unused fields for different roles
- ✅ Type-safe field definitions per role
- ✅ Better validation and constraints

## Testing the Changes

### Prerequisites
```bash
cd scripts
npm install
```

### Environment Setup
Create `tools/mcp/appwrite.mcp.env` with:
```
APPWRITE_ENDPOINT=https://sgp.cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=your_project_id
APPWRITE_API_KEY=your_api_key
```

### Run Tests

#### Test User Profiles
```bash
node scripts/test-user-profiles.js
```

Expected output:
```
🧪 Testing User Profiles Functionality

📝 Test 1: Create student profile
  ✓ User created: abc123
✅ Student profile created: xyz789

📝 Test 2: Create teacher profile
  ✓ User created: def456
✅ Teacher profile created: uvw012

...

📊 TEST SUMMARY
Total Tests: 6
✅ Passed: 6
❌ Failed: 0
Success Rate: 100.0%
```

#### Test Appwrite Features
```bash
node scripts/test-appwrite-features.js
```

Expected output includes:
```
╔════════════════════════════════════════════════════════════╗
║     Appwrite Database Functionality Test Suite            ║
╚════════════════════════════════════════════════════════════╝

═══ Test 1: Creating Test Users ═══

✓ Created auth user 1: user123
✓ Created database user 1
...
```

## Troubleshooting

### Error: "fetch failed"
**Cause**: Missing or incorrect Appwrite credentials
**Solution**: Ensure environment variables are set correctly in `tools/mcp/appwrite.mcp.env`

### Error: "Attribute not found"
**Cause**: Trying to use fields that don't exist in the collection
**Solution**: Verify the collection schema in Appwrite console matches the expected structure

### Error: "Document not found"
**Cause**: Referenced user_id doesn't exist
**Solution**: Ensure user is created in `users` collection before creating profile

## Migration Path

If you have existing tests or code using the old structure:

### 1. Identify affected code
Look for:
- Direct document creation in `users` with student/teacher/admin specific fields
- Queries that expect role-specific fields in `users` collection

### 2. Update to two-step process
```javascript
// OLD (doesn't work)
await databases.createDocument(DATABASE_ID, 'users', id, {
  email: "user@test.com",
  role: "student",
  shift: "Day",  // ❌ No longer in users collection
});

// NEW (works)
// Step 1: Create user
const user = await databases.createDocument(DATABASE_ID, 'users', id, {
  email: "user@test.com",
  role: "student",
});

// Step 2: Create profile
await databases.createDocument(DATABASE_ID, 'user_profiles', id2, {
  user_id: user.$id,
  role: "student",
  shift: "Day",  // ✅ Now in user_profiles
});
```

### 3. Update queries
```javascript
// OLD (still works for common fields)
await databases.listDocuments(DATABASE_ID, 'users', [
  Query.equal('role', 'student')
]);

// NEW (for role-specific fields)
await databases.listDocuments(DATABASE_ID, 'user_profiles', [
  Query.equal('role', 'student'),
  Query.equal('shift', 'Day')
]);
```

## Related Documentation

- [ROLE_BASED_PROFILES_COMPLETE.md](./ROLE_BASED_PROFILES_COMPLETE.md) - Full implementation details
- [PROFILE_SYSTEM_QUICK_REF.md](./PROFILE_SYSTEM_QUICK_REF.md) - Quick reference guide
- [docs/TEACHERS_COLLECTION_DESIGN.md](./docs/TEACHERS_COLLECTION_DESIGN.md) - Teachers collection design

## Summary

The test scripts have been successfully updated to work with the new database structure. The key change is the separation of common user data and role-specific profile data into two collections, providing better organization, performance, and scalability.

**Status**: ✅ Complete and Ready for Testing

**Date**: November 8, 2025
