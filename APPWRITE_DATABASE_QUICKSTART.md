# Appwrite Database Quick Start Guide

## 🎯 Quick Reference for Database Configuration

This guide provides a quick reference for configuring the Appwrite database. For complete details, see [APPWRITE_UPDATED_GUIDE.md](APPWRITE_UPDATED_GUIDE.md).

---

## Step-by-Step Database Setup

### 1. Access Appwrite Console

1. Go to https://cloud.appwrite.io
2. Sign in with your account
3. Select your project: **rpi-communication**
4. Project ID: `6904cfb1001e5253725b`

### 2. Create Database

1. Click **Databases** in left sidebar
2. Click **Create Database**
3. Database ID: `rpi_communication`
4. Database Name: `RPI Communication`
5. Click **Create**

### 3. Understanding Permissions

Before creating collections, understand Appwrite's permission system:

**Permission Levels:**
- Collection-level: Default permissions for all documents
- Document-level: Specific permissions per document

**Permission Types:**
- `read` - View documents
- `create` - Create new documents
- `update` - Modify documents
- `delete` - Remove documents

**Permission Roles:**
- `any` - Everyone (including non-authenticated users)
- `users` - Any authenticated user
- `user:[USER_ID]` - Specific user by ID
- `label:[LABEL]` - Custom role (e.g., `label:admin`, `label:teacher`)

**Example:**
```
Permission.read(Role.any())           // Anyone can read
Permission.create(Role.users())       // Authenticated users can create
Permission.update(Role.user(userId))  // Only document owner can update
Permission.delete(Role.label('admin')) // Only admins can delete
```

### 4. Create Collections with Permissions

#### Collection 1: Users

```
Collection ID: users
Name: Users

Permissions (Collection-level):
- Read: any
- Create: users
- Update: user:{$userId} (match document creator)
- Delete: label:admin

Attributes:
1. email (string, 255, required)
2. display_name (string, 255, required)
3. photo_url (string, 2000, optional)
4. role (enum: [student, teacher, admin], required, default: student)
5. department (string, 100, optional)
6. year (string, 20, optional)
7. shift (string, 50, optional)
8. group (string, 10, optional)
9. class_roll (string, 20, optional)
10. academic_session (string, 50, optional)
11. phone_number (string, 20, optional)
12. is_active (boolean, required, default: true)
13. created_at (datetime, required)
14. updated_at (datetime, required)

Indexes:
- email (unique, asc)
- role (key, asc)
- department (key, asc)
```

#### Collection 2: Notices

```
Collection ID: notices
Name: Notices

Permissions (Collection-level):
- Read: any
- Create: label:teacher, label:admin
- Update: user:{$userId}, label:admin
- Delete: label:admin

Attributes:
1. title (string, 500, required)
2. content (string, 10000, required)
3. type (enum: [announcement, event, urgent], required, default: announcement)
4. author_id (string, 255, required)
5. author_name (string, 255, required)
6. target_audience (string, 100, array: yes, optional, default: ["all"])
7. is_active (boolean, required, default: true)
8. expires_at (datetime, optional)
9. created_at (datetime, required)
10. updated_at (datetime, required)

Indexes:
- type (key, asc)
- is_active (key, asc)
- created_at (key, desc)
- author_id (key, asc)
```

#### Collection 3: Messages

```
Collection ID: messages
Name: Messages

Permissions (Collection-level):
- Read: user:{$userId} (will need document-level permissions)
- Create: users
- Update: user:{$userId}
- Delete: user:{$userId}, label:admin

Note: For messages, use document-level permissions in code:
  Permission.read(Role.user(senderId))
  Permission.read(Role.user(recipientId))

Attributes:
1. sender_id (string, 255, required)
2. sender_name (string, 255, required)
3. recipient_id (string, 255, required)
4. recipient_name (string, 255, required)
5. content (string, 10000, required)
6. type (enum: [text, image, file], required, default: text)
7. attachment_url (string, 2000, optional)
8. is_read (boolean, required, default: false)
9. read_at (datetime, optional)
10. created_at (datetime, required)

Indexes:
- sender_id (key, asc)
- recipient_id (key, asc)
- is_read (key, asc)
- created_at (key, desc)
```

#### Collection 4: Notifications

```
Collection ID: notifications
Name: Notifications

Permissions (Collection-level):
- Read: user:{$userId}
- Create: label:teacher, label:admin, users
- Update: user:{$userId}
- Delete: user:{$userId}

Attributes:
1. user_id (string, 255, required)
2. title (string, 255, required)
3. body (string, 1000, required)
4. type (string, 50, required)
5. data (string, 5000, optional)
6. is_read (boolean, required, default: false)
7. created_at (datetime, required)

Indexes:
- user_id (key, asc)
- is_read (key, asc)
- created_at (key, desc)
```

#### Collection 5: Books

```
Collection ID: books
Name: Books

Permissions (Collection-level):
- Read: any
- Create: label:teacher, label:admin
- Update: label:teacher, label:admin
- Delete: label:admin

Attributes:
1. title (string, 500, required)
2. author (string, 255, required)
3. isbn (string, 50, optional)
4. category (enum: [textbook, reference, fiction, technical, research, magazine, journal, other], required, default: textbook)
5. description (string, 2000, optional)
6. cover_url (string, 2000, optional)
7. file_url (string, 2000, optional)
8. status (enum: [available, borrowed, reserved, maintenance], required, default: available)
9. publisher (string, 255, optional)
10. edition (string, 50, optional)
11. publication_year (integer, optional, default: 0)
12. total_copies (integer, required, default: 1)
13. available_copies (integer, required, default: 1)
14. department (string, 100, optional)
15. tags (string, 500, optional)
16. created_at (datetime, required)
17. updated_at (datetime, optional)
18. added_by (string, 255, required)

Indexes:
- category (key, asc)
- status (key, asc)
- department (key, asc)
- title (fulltext)
- author (fulltext)
```

#### Collection 6: Book Borrows

```
Collection ID: book_borrows
Name: Book Borrows

Permissions (Collection-level):
- Read: user:{$userId}, label:teacher, label:admin
- Create: users
- Update: user:{$userId}, label:teacher, label:admin
- Delete: label:admin

Attributes:
1. book_id (string, 255, required)
2. user_id (string, 255, required)
3. user_name (string, 255, required)
4. user_email (string, 255, required)
5. borrow_date (datetime, required)
6. due_date (datetime, required)
7. return_date (datetime, optional)
8. status (enum: [borrowed, returned, overdue], required, default: borrowed)
9. notes (string, 1000, optional)

Indexes:
- book_id (key, asc)
- user_id (key, asc)
- status (key, asc)
- due_date (key, asc)
```

### 5. Create Storage Buckets

#### Bucket 1: profile-images

```
Bucket ID: profile-images
Name: Profile Images

Settings:
- Maximum file size: 5 MB (5242880 bytes)
- Allowed file extensions: jpg, jpeg, png, gif, webp
- Compression: Enabled
- Encryption: Enabled

Permissions:
- Read: any
- Create: users
- Update: user:{$userId}
- Delete: user:{$userId}
```

#### Bucket 2: notice-attachments

```
Bucket ID: notice-attachments
Name: Notice Attachments

Settings:
- Maximum file size: 10 MB (10485760 bytes)
- Allowed file extensions: jpg, jpeg, png, pdf, doc, docx, xls, xlsx
- Encryption: Enabled

Permissions:
- Read: any
- Create: label:teacher, label:admin
- Update: label:teacher, label:admin
- Delete: label:admin
```

#### Bucket 3: message-attachments

```
Bucket ID: message-attachments
Name: Message Attachments

Settings:
- Maximum file size: 25 MB (26214400 bytes)
- Allowed file extensions: jpg, jpeg, png, pdf, doc, docx, zip
- Encryption: Enabled

Permissions:
- Read: user:{$userId} (use document-level permissions)
- Create: users
- Update: user:{$userId}
- Delete: user:{$userId}
```

#### Bucket 4: book-covers

```
Bucket ID: book-covers
Name: Book Covers

Settings:
- Maximum file size: 2 MB (2097152 bytes)
- Allowed file extensions: jpg, jpeg, png, webp
- Compression: Enabled
- Encryption: Enabled

Permissions:
- Read: any
- Create: label:teacher, label:admin
- Update: label:teacher, label:admin
- Delete: label:admin
```

#### Bucket 5: book-files

```
Bucket ID: book-files
Name: Book Files (PDFs)

Settings:
- Maximum file size: 100 MB (104857600 bytes)
- Allowed file extensions: pdf
- Encryption: Enabled

Permissions:
- Read: users (authenticated users only)
- Create: label:teacher, label:admin
- Update: label:teacher, label:admin
- Delete: label:admin
```

---

## 🔍 Testing Your Setup

### 1. Test Authentication

```dart
// In your Flutter app
try {
  final session = await account.createEmailPasswordSession(
    email: 'test@example.com',
    password: 'password123',
  );
  print('✅ Authentication works!');
} catch (e) {
  print('❌ Authentication failed: $e');
}
```

### 2. Test Database

```dart
// Create a test document
try {
  final document = await databases.createDocument(
    databaseId: 'rpi_communication',
    collectionId: 'users',
    documentId: ID.unique(),
    data: {
      'email': 'test@example.com',
      'display_name': 'Test User',
      'role': 'student',
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    },
  );
  print('✅ Database works!');
} catch (e) {
  print('❌ Database failed: $e');
}
```

### 3. Test Storage

```dart
// Upload a test file
try {
  final file = await storage.createFile(
    bucketId: 'profile-images',
    fileId: ID.unique(),
    file: InputFile.fromPath(path: '/path/to/image.jpg'),
  );
  print('✅ Storage works!');
} catch (e) {
  print('❌ Storage failed: $e');
}
```

---

## 🐛 Common Issues and Solutions

### Issue: "User (role: guests) missing scope (account)"

**Cause:** User is not authenticated  
**Solution:** Ensure user is signed in before accessing protected resources

```dart
// Always check authentication first
final user = await account.get();
if (user != null) {
  // User is authenticated
}
```

### Issue: "Document missing read/write permissions"

**Cause:** Permissions not set correctly  
**Solution:** Add proper permissions when creating documents

```dart
await databases.createDocument(
  // ...
  permissions: [
    Permission.read(Role.any()),
    Permission.write(Role.user(userId)),
  ],
);
```

### Issue: "Invalid query"

**Cause:** Incorrect query syntax  
**Solution:** Use correct query methods

```dart
// Correct
Query.equal('status', 'active')
Query.greaterThan('created_at', '2024-01-01')

// Wrong
Query.equal('status', ['active']) // Don't wrap single values in array
```

### Issue: "Attribute already exists"

**Cause:** Trying to create duplicate attribute  
**Solution:** Check existing attributes before creating new ones

### Issue: "Index creation failed"

**Cause:** Index with same key already exists or invalid attribute  
**Solution:** Use unique index names and verify attributes exist

---

## 📚 Next Steps

After completing database setup:

1. ✅ Update your Flutter app configuration
2. ✅ Test authentication flow
3. ✅ Test CRUD operations
4. ✅ Set up real-time subscriptions (see [APPWRITE_UPDATED_GUIDE.md](APPWRITE_UPDATED_GUIDE.md))
5. ✅ Deploy functions if needed
6. ✅ Configure production environment

---

## 📖 Additional Resources

- **Comprehensive Guide:** [APPWRITE_UPDATED_GUIDE.md](APPWRITE_UPDATED_GUIDE.md)
- **Collections Schema:** [APPWRITE_COLLECTIONS_SCHEMA.md](APPWRITE_COLLECTIONS_SCHEMA.md)
- **Setup Instructions:** [APPWRITE_SETUP_INSTRUCTIONS.md](APPWRITE_SETUP_INSTRUCTIONS.md)
- **Official Docs:** https://appwrite.io/docs
- **Database Docs:** https://appwrite.io/docs/products/databases
- **Permissions Guide:** https://appwrite.io/docs/advanced/platform/permissions

---

## ⏱️ Estimated Time

- Database creation: 5 minutes
- Collections setup: 20-30 minutes
- Storage buckets: 10 minutes
- Testing: 10 minutes

**Total: 45-55 minutes**

---

**Last Updated:** November 2025
