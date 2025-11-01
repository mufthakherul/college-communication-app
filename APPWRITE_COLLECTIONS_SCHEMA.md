# Appwrite Database Collections Schema

This document describes all the collections required for the RPI Communication App.

## Database ID
- **Database Name**: `rpi_communication`
- **Database ID**: `rpi_communication`

## Collections

### 1. Users Collection
**Collection ID**: `users`

| Attribute | Type | Required | Array | Default | Description |
|-----------|------|----------|-------|---------|-------------|
| id | string | Yes | No | - | User ID (from Appwrite Auth) |
| email | email | Yes | No | - | User email |
| display_name | string | Yes | No | - | Full name |
| photo_url | url | No | No | - | Profile picture URL |
| role | enum | Yes | No | student | Role: student, teacher, admin |
| department | string | No | No | - | Department name |
| year | string | No | No | - | Year/Semester |
| shift | string | No | No | - | Morning/Day/Evening |
| group | string | No | No | - | Academic group (A, B, C, etc.) |
| class_roll | string | No | No | - | Roll number |
| academic_session | string | No | No | - | Academic year/session |
| phone_number | string | No | No | - | Contact phone |
| is_active | boolean | Yes | No | true | Account status |
| created_at | datetime | Yes | No | now() | Creation timestamp |
| updated_at | datetime | No | No | - | Last update timestamp |

**Indexes**:
- `email` (unique)
- `role`
- `department`

---

### 2. Notices Collection
**Collection ID**: `notices`

| Attribute | Type | Required | Array | Default | Description |
|-----------|------|----------|-------|---------|-------------|
| id | string | Yes | No | - | Notice ID |
| title | string | Yes | No | - | Notice title |
| content | string | Yes | No | - | Notice content |
| type | enum | Yes | No | announcement | Type: announcement, event, urgent |
| author_id | string | Yes | No | - | Author user ID |
| author_name | string | Yes | No | - | Author name |
| target_audience | string | No | Yes | ["all"] | Target: all, students, teachers, admin, or specific departments |
| is_active | boolean | Yes | No | true | Visibility status |
| expires_at | datetime | No | No | - | Expiration date |
| created_at | datetime | Yes | No | now() | Creation timestamp |
| updated_at | datetime | No | No | - | Last update timestamp |

**Indexes**:
- `type`
- `is_active`
- `created_at` (desc)

---

### 3. Messages Collection
**Collection ID**: `messages`

| Attribute | Type | Required | Array | Default | Description |
|-----------|------|----------|-------|---------|-------------|
| id | string | Yes | No | - | Message ID |
| sender_id | string | Yes | No | - | Sender user ID |
| sender_name | string | Yes | No | - | Sender name |
| recipient_id | string | Yes | No | - | Recipient user ID |
| recipient_name | string | Yes | No | - | Recipient name |
| content | string | Yes | No | - | Message content |
| type | enum | Yes | No | text | Type: text, image, file |
| attachment_url | url | No | No | - | Attachment URL |
| is_read | boolean | Yes | No | false | Read status |
| created_at | datetime | Yes | No | now() | Creation timestamp |

**Indexes**:
- `sender_id`
- `recipient_id`
- `is_read`
- `created_at` (desc)

---

### 4. Books Collection
**Collection ID**: `books`

| Attribute | Type | Required | Array | Default | Description |
|-----------|------|----------|-------|---------|-------------|
| id | string | Yes | No | - | Book ID |
| title | string | Yes | No | - | Book title |
| author | string | Yes | No | - | Author name |
| isbn | string | No | No | - | ISBN number |
| category | enum | Yes | No | textbook | Category: textbook, reference, fiction, technical, research, magazine, journal, other |
| description | string | No | No | - | Book description |
| cover_url | url | No | No | - | Cover image URL |
| file_url | url | No | No | - | PDF file URL |
| status | enum | Yes | No | available | Status: available, borrowed, reserved, maintenance |
| publisher | string | No | No | - | Publisher name |
| edition | string | No | No | - | Edition |
| publication_year | integer | No | No | 0 | Publication year |
| total_copies | integer | Yes | No | 1 | Total number of copies |
| available_copies | integer | Yes | No | 1 | Available copies |
| department | string | No | No | - | Department |
| tags | string | No | No | - | Comma-separated tags |
| created_at | datetime | Yes | No | now() | Creation timestamp |
| updated_at | datetime | No | No | - | Last update timestamp |
| added_by | string | Yes | No | - | User ID who added |

**Indexes**:
- `category`
- `status`
- `department`
- Full-text search on `title`, `author`

---

### 5. Book Borrows Collection
**Collection ID**: `book_borrows`

| Attribute | Type | Required | Array | Default | Description |
|-----------|------|----------|-------|---------|-------------|
| id | string | Yes | No | - | Borrow record ID |
| book_id | string | Yes | No | - | Book ID |
| user_id | string | Yes | No | - | User ID |
| user_name | string | Yes | No | - | User name |
| user_email | email | Yes | No | - | User email |
| borrow_date | datetime | Yes | No | now() | Borrow date |
| due_date | datetime | Yes | No | - | Due date |
| return_date | datetime | No | No | - | Actual return date |
| status | enum | Yes | No | borrowed | Status: borrowed, returned, overdue |
| notes | string | No | No | - | Additional notes |

**Indexes**:
- `book_id`
- `user_id`
- `status`
- `due_date`

---

### 6. Assignments Collection
**Collection ID**: `assignments`

| Attribute | Type | Required | Array | Default | Description |
|-----------|------|----------|-------|---------|-------------|
| id | string | Yes | No | - | Assignment ID |
| title | string | Yes | No | - | Assignment title |
| description | string | Yes | No | - | Assignment description |
| subject | string | Yes | No | - | Subject name |
| teacher_id | string | Yes | No | - | Teacher user ID |
| teacher_name | string | Yes | No | - | Teacher name |
| due_date | datetime | Yes | No | - | Due date |
| max_marks | integer | Yes | No | 100 | Maximum marks |
| attachment_url | url | No | No | - | Attachment URL |
| target_groups | string | No | Yes | [] | Target classes/groups |
| department | string | No | No | - | Department |
| created_at | datetime | Yes | No | now() | Creation timestamp |
| updated_at | datetime | No | No | - | Last update timestamp |

**Indexes**:
- `teacher_id`
- `due_date`
- `department`

---

### 7. Timetables Collection
**Collection ID**: `timetables`

| Attribute | Type | Required | Array | Default | Description |
|-----------|------|----------|-------|---------|-------------|
| id | string | Yes | No | - | Timetable ID |
| class_name | string | Yes | No | - | Class name |
| department | string | Yes | No | - | Department |
| shift | string | Yes | No | - | Shift |
| periods | string | Yes | No | - | JSON array of class periods |
| created_at | datetime | Yes | No | now() | Creation timestamp |
| updated_at | datetime | No | No | - | Last update timestamp |

**Note**: `periods` should be a JSON string containing array of period objects.

**Indexes**:
- `department`
- `shift`

---

### 8. Events Collection
**Collection ID**: `events`

| Attribute | Type | Required | Array | Default | Description |
|-----------|------|----------|-------|---------|-------------|
| id | string | Yes | No | - | Event ID |
| title | string | Yes | No | - | Event title |
| description | string | Yes | No | - | Event description |
| type | enum | Yes | No | seminar | Type: seminar, workshop, exam, sports, cultural, other |
| start_date | datetime | Yes | No | - | Start date/time |
| end_date | datetime | Yes | No | - | End date/time |
| venue | string | Yes | No | - | Event venue |
| organizer | string | Yes | No | - | Organizer name |
| image_url | url | No | No | - | Event image URL |
| is_registration_required | boolean | Yes | No | false | Registration required |
| max_participants | integer | No | No | - | Max participants |
| current_participants | integer | Yes | No | 0 | Current participants |
| registration_link | url | No | No | - | Registration link |
| target_audience | string | No | Yes | ["all"] | Target audience |
| created_at | datetime | Yes | No | now() | Creation timestamp |
| updated_at | datetime | No | No | - | Last update timestamp |

**Indexes**:
- `type`
- `start_date`

---

### 9. Notifications Collection
**Collection ID**: `notifications`

| Attribute | Type | Required | Array | Default | Description |
|-----------|------|----------|-------|---------|-------------|
| id | string | Yes | No | - | Notification ID |
| user_id | string | Yes | No | - | User ID |
| title | string | Yes | No | - | Notification title |
| body | string | Yes | No | - | Notification body |
| type | string | Yes | No | - | Notification type |
| data | string | No | No | - | JSON metadata |
| is_read | boolean | Yes | No | false | Read status |
| created_at | datetime | Yes | No | now() | Creation timestamp |

**Indexes**:
- `user_id`
- `is_read`
- `created_at` (desc)

---

### 10. Study Groups Collection
**Collection ID**: `study_groups`

| Attribute | Type | Required | Array | Default | Description |
|-----------|------|----------|-------|---------|-------------|
| id | string | Yes | No | - | Group ID |
| name | string | Yes | No | - | Group name |
| description | string | No | No | - | Group description |
| subject | string | Yes | No | - | Subject/topic |
| creator_id | string | Yes | No | - | Creator user ID |
| members | string | Yes | Yes | [] | Array of member user IDs |
| max_members | integer | No | No | - | Max members |
| is_public | boolean | Yes | No | true | Public/private |
| created_at | datetime | Yes | No | now() | Creation timestamp |
| updated_at | datetime | No | No | - | Last update timestamp |

**Indexes**:
- `subject`
- `is_public`

---

## Storage Buckets

### 1. Profile Images
**Bucket ID**: `profile-images`
- File size limit: 5 MB
- Allowed file types: jpg, jpeg, png, gif

### 2. Notice Attachments
**Bucket ID**: `notice-attachments`
- File size limit: 10 MB
- Allowed file types: jpg, jpeg, png, pdf, doc, docx

### 3. Message Attachments
**Bucket ID**: `message-attachments`
- File size limit: 25 MB
- Allowed file types: jpg, jpeg, png, pdf, doc, docx, xls, xlsx

### 4. Book Covers
**Bucket ID**: `book-covers`
- File size limit: 2 MB
- Allowed file types: jpg, jpeg, png

### 5. Book Files
**Bucket ID**: `book-files`
- File size limit: 100 MB
- Allowed file types: pdf

### 6. Assignment Files
**Bucket ID**: `assignment-files`
- File size limit: 50 MB
- Allowed file types: pdf, doc, docx, zip

---

## Setup Instructions

1. Create database `rpi_communication` in Appwrite console
2. Create all collections listed above with specified attributes
3. Set up indexes for better query performance
4. Create storage buckets with appropriate permissions
5. Configure security rules for each collection (see SECURITY.md)

## Permissions

For each collection, configure the following permissions:

- **Read**: 
  - Users with matching role/department can read
  - Public for notices and events
  
- **Create**:
  - Students: messages, book borrows
  - Teachers: notices, assignments, books
  - Admins: all collections
  
- **Update**:
  - Own documents only (creator_id/author_id match)
  - Admins: all documents
  
- **Delete**:
  - Own documents only
  - Admins: all documents

For detailed permission rules, refer to the Appwrite Security documentation.
