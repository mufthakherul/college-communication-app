# Database Seeding Script

This document describes how to use the database seeding script to populate your Firebase Firestore database with sample data for development and testing purposes.

## Overview

The seeding script automatically:
- Clears all existing data from the database collections
- Populates the database with comprehensive sample data including users, notices, messages, and notifications
- Uses proper Firestore timestamps and data structures
- Provides detailed logging and error handling

## Usage

### Prerequisites

Before running the seeding script, ensure you have:

1. **Firebase Project Setup**: A Firebase project configured with Firestore database
2. **Authentication**: Firebase service account credentials or authenticated Firebase CLI
3. **Dependencies**: Node.js dependencies installed (`cd functions && npm install`)

### Running the Script

There are several ways to run the seeding script:

#### Option 1: Using npm script (Recommended)

```bash
# Navigate to functions directory
cd functions

# Run the seeding script
npm run seed
```

#### Option 2: Using backend directory (Requirement-compatible)

```bash
# Navigate to backend directory
cd backend

# Run via npm script
npm run seed

# Or run directly
node scripts/seed.js
```

#### Option 3: Direct execution

```bash
# From functions directory
cd functions
node scripts/seed.js
```

### Environment Setup

For local development, you can use Firebase emulators:

```bash
# Start Firebase emulators (requires Firebase CLI)
firebase emulators:start --only firestore

# In another terminal, run the seed script
cd functions
npm run seed
```

For production/staging environments, ensure you have proper Firebase authentication configured.

## Sample Data Overview

The script creates the following sample data:

### Users (6 total)
- **1 Admin**: John Admin (admin@campus.edu)
- **2 Teachers**: 
  - Dr. Sarah Smith (Computer Science)
  - Prof. Michael Johnson (Mathematics)
- **3 Students**:
  - Alice Wilson (3rd Year Computer Science)
  - Bob Brown (2nd Year Mathematics)
  - Emma Davis (1st Year Computer Science)

### Notices (4 total)
- Welcome message for new academic year
- Computer Science department meeting
- Library system maintenance alert
- Faculty meeting announcement

### Messages (5 total)
- Teacher-student communications
- Admin notifications
- Assignment discussions

### Notifications (4 total)
- Notice notifications
- Message notifications
- Read/unread status examples

## Data Structure

The script follows the existing Firestore collections structure:

- `users/` - User profiles with roles, departments, and metadata
- `notices/` - Announcements, events, and urgent notices
- `messages/` - Direct messages between users
- `notifications/` - Push notification records

## Customization

To customize the sample data:

1. Edit the `SAMPLE_DATA` object in `functions/scripts/seed.js`
2. Add or modify users, notices, messages, or notifications
3. Ensure proper Firestore timestamp usage: `admin.firestore.Timestamp.now()`

## Error Handling

The script includes comprehensive error handling:
- Validates Firebase connection before proceeding
- Uses batch operations for efficiency
- Provides detailed logging for each step
- Gracefully handles and reports errors

## Security Considerations

- **Development Only**: This script is intended for development and testing environments
- **Data Loss**: The script completely clears existing data before seeding
- **Authentication**: Ensure proper Firebase authentication is configured
- **Permissions**: The script requires Firestore read/write permissions

## Troubleshooting

### Common Issues

1. **Firebase Project ID Not Found**
   ```
   Error: Unable to detect a Project Id in the current environment
   ```
   - Ensure Firebase project is configured
   - Check Firebase authentication credentials
   - Use Firebase emulators for local development

2. **Permission Denied**
   ```
   Error: Permission denied on Firestore operations
   ```
   - Verify Firebase service account permissions
   - Check Firestore security rules
   - Ensure authenticated Firebase CLI

3. **Module Not Found**
   ```
   Error: Cannot find module 'firebase-admin'
   ```
   - Run `npm install` in the functions directory
   - Ensure all dependencies are installed

### Getting Help

If you encounter issues:
1. Check the Firebase console for project configuration
2. Verify Firestore security rules allow read/write operations
3. Review Firebase authentication setup
4. Check the Firebase documentation for troubleshooting

## Development Workflow

Typical workflow for using the seeding script:

1. Start Firebase emulators for local development
2. Run the seeding script to populate with sample data
3. Develop and test your application features
4. Re-run the seeding script as needed to reset data state
5. Use different sample data for different testing scenarios

This approach ensures consistent, reproducible data for development and testing while maintaining separation from production data.