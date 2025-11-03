# Quick Setup Guide v2.0 - New Features

This guide will help you set up the new Books Library and Student Tools features in 30 minutes.

## Prerequisites

- Appwrite account with project created
- Flutter development environment
- Basic knowledge of Appwrite console

## Step 1: Database Setup (10 minutes)

### 1.1 Create Database Collections

Go to your Appwrite Console → Databases → Create the following collections:

#### Books Collection
```
Collection ID: books

Attributes:
- title (string, required)
- author (string, required)
- isbn (string)
- category (enum: textbook, reference, fiction, technical, research, magazine, journal, other, required)
- description (string, 5000 chars)
- cover_url (url)
- file_url (url)
- status (enum: available, borrowed, reserved, maintenance, required, default: available)
- publisher (string)
- edition (string)
- publication_year (integer)
- total_copies (integer, required, default: 1)
- available_copies (integer, required, default: 1)
- department (string)
- tags (string)
- created_at (datetime, required)
- updated_at (datetime)
- added_by (string, required)

Indexes:
- category (key)
- status (key)
- department (key)
- title (fulltext)
- author (fulltext)

Permissions:
- Read: Role: users
- Create: Role: teachers, Role: admins
- Update: Role: teachers, Role: admins
- Delete: Role: admins
```

#### Book Borrows Collection
```
Collection ID: book_borrows

Attributes:
- book_id (string, required)
- user_id (string, required)
- user_name (string, required)
- user_email (email, required)
- borrow_date (datetime, required)
- due_date (datetime, required)
- return_date (datetime)
- status (enum: borrowed, returned, overdue, required, default: borrowed)
- notes (string)

Indexes:
- book_id (key)
- user_id (key)
- status (key)
- due_date (key)

Permissions:
- Read: User: $userId (for own records), Role: teachers, Role: admins
- Create: Role: users
- Update: User: $userId (for own records), Role: admins
- Delete: Role: admins
```

#### Assignments Collection
```
Collection ID: assignments

Attributes:
- title (string, required)
- description (string, 5000 chars, required)
- subject (string, required)
- teacher_id (string, required)
- teacher_name (string, required)
- due_date (datetime, required)
- max_marks (integer, required, default: 100)
- attachment_url (url)
- target_groups (string, array)
- department (string)
- created_at (datetime, required)
- updated_at (datetime)

Indexes:
- teacher_id (key)
- due_date (key)
- department (key)

Permissions:
- Read: Role: users
- Create: Role: teachers, Role: admins
- Update: User: $userId (teacher_id), Role: admins
- Delete: User: $userId (teacher_id), Role: admins
```

#### Timetables Collection
```
Collection ID: timetables

Attributes:
- class_name (string, required)
- department (string, required)
- shift (string, required)
- periods (string, 10000 chars, required) // JSON array
- created_at (datetime, required)
- updated_at (datetime)

Indexes:
- department (key)
- shift (key)

Permissions:
- Read: Role: users
- Create: Role: admins
- Update: Role: admins
- Delete: Role: admins
```

#### Events Collection
```
Collection ID: events

Attributes:
- title (string, required)
- description (string, 5000 chars, required)
- type (enum: seminar, workshop, exam, sports, cultural, other, required)
- start_date (datetime, required)
- end_date (datetime, required)
- venue (string, required)
- organizer (string, required)
- image_url (url)
- is_registration_required (boolean, required, default: false)
- max_participants (integer)
- current_participants (integer, required, default: 0)
- registration_link (url)
- target_audience (string, array)
- created_at (datetime, required)
- updated_at (datetime)

Indexes:
- type (key)
- start_date (key)

Permissions:
- Read: Role: users
- Create: Role: teachers, Role: admins
- Update: Role: admins
- Delete: Role: admins
```

### 1.2 Create Storage Buckets

#### Book Covers Bucket
```
Bucket ID: book-covers
File size limit: 2 MB
Allowed file types: jpg, jpeg, png
Permissions:
- Read: Role: users
- Create: Role: teachers, Role: admins
- Update: Role: teachers, Role: admins
- Delete: Role: admins
```

#### Book Files Bucket
```
Bucket ID: book-files
File size limit: 100 MB
Allowed file types: pdf
Permissions:
- Read: Role: users
- Create: Role: teachers, Role: admins
- Update: Role: teachers, Role: admins
- Delete: Role: admins
```

#### Assignment Files Bucket
```
Bucket ID: assignment-files
File size limit: 50 MB
Allowed file types: pdf, doc, docx, zip
Permissions:
- Read: Role: users
- Create: Role: users
- Update: User: $userId
- Delete: User: $userId, Role: admins
```

## Step 2: App Configuration (5 minutes)

### 2.1 Verify Appwrite Config

Open `apps/mobile/lib/appwrite_config.dart` and verify:

```dart
class AppwriteConfig {
  static const String endpoint = 'https://sgp.cloud.appwrite.io/v1';
  static const String projectId = 'YOUR_PROJECT_ID'; // Update this
  
  static const String databaseId = 'rpi_communication';
  
  // Collection IDs (should match what you created)
  static const String booksCollectionId = 'books';
  static const String bookBorrowsCollectionId = 'book_borrows';
  static const String assignmentsCollectionId = 'assignments';
  static const String timetablesCollectionId = 'timetables';
  static const String eventsCollectionId = 'events';
  
  // Storage bucket IDs
  static const String bookCoversBucketId = 'book-covers';
  static const String bookFilesBucketId = 'book-files';
  static const String assignmentFilesBucketId = 'assignment-files';
}
```

## Step 3: Add Sample Data (10 minutes)

### 3.1 Add Sample Books

Using Appwrite Console or API, add some sample books:

```json
{
  "title": "Introduction to Programming",
  "author": "John Doe",
  "isbn": "978-0-123456-78-9",
  "category": "textbook",
  "description": "A comprehensive guide to programming fundamentals",
  "publisher": "Tech Publishers",
  "edition": "5th Edition",
  "publication_year": 2023,
  "total_copies": 5,
  "available_copies": 5,
  "department": "Computer",
  "status": "available",
  "created_at": "2024-11-01T00:00:00.000Z",
  "added_by": "YOUR_ADMIN_USER_ID"
}
```

Sample books to add:
1. Programming textbook
2. Mathematics reference
3. Physics textbook
4. English literature
5. Technical documentation

### 3.2 Test the Library

1. Open the app
2. Navigate to Library tab
3. Verify books are displayed
4. Try searching for a book
5. Try filtering by category
6. Click on a book to view details
7. Try borrowing a book (if student role)

## Step 4: Test Student Tools (5 minutes)

### 4.1 Test GPA Calculator

1. Navigate to Tools tab
2. Click on "GPA Calculator"
3. Add 3-4 courses with different grades
4. Verify GPA calculation is correct

Example:
- Course 1: 3 credits, A (3.75)
- Course 2: 4 credits, B+ (3.25)
- Course 3: 3 credits, A- (3.5)
- Expected GPA: (3×3.75 + 4×3.25 + 3×3.5) / 10 = 3.48

### 4.2 Test Study Timer

1. Click on "Study Timer"
2. Try Pomodoro mode (25 min work, 5 min break)
3. Start and pause timer
4. Try Stopwatch mode
5. Test reset functionality

## Step 5: User Roles Setup (Optional)

### 5.1 Assign Roles to Users

In Appwrite Console → Databases → Users collection:

Update users with appropriate roles:
- Students: `role: "student"`
- Teachers: `role: "teacher"`
- Admins: `role: "admin"`

### 5.2 Test Role-Based Features

**As Student:**
- Can browse and borrow books
- Can use all tools
- Cannot add/edit/delete books

**As Teacher:**
- All student features
- Can add/edit books
- Can create assignments (when implemented)

**As Admin:**
- All features
- Can delete books
- Full management access

## Troubleshooting

### Books not showing up?
1. Check collection ID in `appwrite_config.dart`
2. Verify permissions on books collection
3. Check if books exist in database
4. Look for errors in app console

### Cannot borrow books?
1. Check `book_borrows` collection exists
2. Verify permissions allow create for users
3. Check if user is authenticated
4. Verify book availability

### Search not working?
1. Ensure full-text indexes are created on title and author
2. Try exact match searches first
3. Check Appwrite console for search errors

### GPA Calculator issues?
1. Verify grade points are correct
2. Check credits are positive numbers
3. Ensure all fields are filled

## Next Steps

1. **Add More Books**: Populate your library with relevant books
2. **Configure Permissions**: Fine-tune access control
3. **Customize Categories**: Add department-specific categories
4. **Enable Notifications**: Set up due date reminders
5. **Implement Assignments**: Complete the assignment tracker feature
6. **Add Timetables**: Create class schedules
7. **Manage Events**: Add upcoming college events

## Production Checklist

Before deploying to production:

- [ ] All collections created with correct attributes
- [ ] Indexes created for performance
- [ ] Permissions configured securely
- [ ] Storage buckets created with size limits
- [ ] Sample data tested
- [ ] User roles assigned
- [ ] All features tested by each role
- [ ] Error handling verified
- [ ] Performance tested with 100+ books
- [ ] Backup strategy in place

## Support

For issues or questions:
- GitHub Issues: Report bugs
- Discussions: Feature requests
- Documentation: `FEATURES_UPDATE_V2.md`
- Schema Reference: `APPWRITE_COLLECTIONS_SCHEMA.md`

---

**Setup Time**: ~30 minutes  
**Last Updated**: November 1, 2024  
**Version**: 2.0.0
