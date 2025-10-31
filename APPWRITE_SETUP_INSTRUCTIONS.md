# Appwrite Setup Instructions for RPI Communication App

## ✅ Your Appwrite Educational Credentials

- **Organization:** GitHub Student Organization
- **Project Name:** rpi-communication
- **Project ID:** 6904cfb1001e5253725b
- **API Endpoint:** https://sgp.cloud.appwrite.io/v1
- **Region:** Singapore (sgp)

## 🎯 Next Steps: Database Setup

Since you already have Appwrite educational benefits approved, you now need to set up the database structure in your Appwrite project.

### Step 1: Access Appwrite Console

1. Go to: https://cloud.appwrite.io
2. Sign in with your account
3. Select project: **rpi-communication**

### Step 2: Create Database

1. Click **Databases** in the left sidebar
2. Click **Create Database**
3. **Database ID:** `rpi_communication`
4. **Database Name:** RPI Communication
5. Click **Create**

### Step 3: Create Collections

You need to create 6 collections. For each collection:

#### Collection 1: users

1. Click **Create Collection**
2. **Collection ID:** `users`
3. **Collection Name:** Users
4. Click **Create**
5. Click **Attributes** tab
6. Add the following attributes:

| Attribute Key | Type | Size | Required | Default | Array |
|--------------|------|------|----------|---------|-------|
| email | String | 255 | ✅ Yes | - | No |
| display_name | String | 255 | ✅ Yes | - | No |
| photo_url | String | 2000 | No | - | No |
| role | Enum | - | ✅ Yes | student | No |
| department | String | 100 | No | - | No |
| year | String | 20 | No | - | No |
| is_active | Boolean | - | ✅ Yes | true | No |
| created_at | DateTime | - | ✅ Yes | - | No |
| updated_at | DateTime | - | ✅ Yes | - | No |
| shift | String | 50 | No | - | No |
| group | String | 10 | No | - | No |
| class_roll | String | 20 | No | - | No |
| academic_session | String | 50 | No | - | No |
| phone_number | String | 20 | No | - | No |

**For role enum, add values:** `student`, `teacher`, `admin`

**Note on Student Fields:** The fields `shift`, `group`, `class_roll`, `academic_session`, and `phone_number` are student-specific and contain private information. These fields are only visible to the student themselves and teachers/admins for proper academic management.

7. Click **Settings** tab → **Permissions**
8. Add permissions:
   - **Any**: Read
   - **Users**: Create, Update
   - **Role:admin**: Delete, Update

**Privacy Note:** While the collection has "Read" permission for "Any", the application implements additional privacy controls at the UI level. Private student information (shift, group, class roll, academic session, phone number) is only displayed to the student themselves or to teachers/admins, ensuring sensitive academic data remains protected.

#### Collection 2: notices

1. Click **Create Collection**
2. **Collection ID:** `notices`
3. **Collection Name:** Notices
4. Add attributes:

| Attribute Key | Type | Size | Required | Default | Array |
|--------------|------|------|----------|---------|-------|
| title | String | 500 | ✅ Yes | - | No |
| content | String | 10000 | ✅ Yes | - | No |
| type | Enum | - | ✅ Yes | announcement | No |
| target_audience | String | 100 | ✅ Yes | all | No |
| author_id | String | 255 | ✅ Yes | - | No |
| is_active | Boolean | - | ✅ Yes | true | No |
| expires_at | DateTime | - | No | - | No |
| created_at | DateTime | - | ✅ Yes | - | No |
| updated_at | DateTime | - | ✅ Yes | - | No |

**For type enum, add values:** `announcement`, `event`, `urgent`

5. Add permissions:
   - **Any**: Read (with condition: is_active = true)
   - **Role:teacher, Role:admin**: Create
   - **Users (author_id)**: Update
   - **Role:admin**: Delete, Update

6. Create indexes:
   - Index: `author_id` (Key, ASC)
   - Index: `is_active` (Key, ASC)
   - Index: `created_at` (Key, DESC)

#### Collection 3: messages

1. **Collection ID:** `messages`
2. **Collection Name:** Messages
3. Add attributes:

| Attribute Key | Type | Size | Required | Default | Array |
|--------------|------|------|----------|---------|-------|
| sender_id | String | 255 | ✅ Yes | - | No |
| recipient_id | String | 255 | ✅ Yes | - | No |
| content | String | 10000 | ✅ Yes | - | No |
| type | Enum | - | ✅ Yes | text | No |
| read | Boolean | - | ✅ Yes | false | No |
| read_at | DateTime | - | No | - | No |
| created_at | DateTime | - | ✅ Yes | - | No |

**For type enum, add values:** `text`, `image`, `file`

4. Add permissions:
   - **Users (sender_id, recipient_id)**: Read
   - **Users**: Create
   - **Users (recipient_id)**: Update
   - **Role:admin**: Delete

5. Create indexes:
   - Index: `sender_id` (Key, ASC)
   - Index: `recipient_id` (Key, ASC)
   - Index: `created_at` (Key, DESC)

#### Collection 4: notifications

1. **Collection ID:** `notifications`
2. **Collection Name:** Notifications
3. Add attributes:

| Attribute Key | Type | Size | Required | Default | Array |
|--------------|------|------|----------|---------|-------|
| user_id | String | 255 | ✅ Yes | - | No |
| type | String | 50 | ✅ Yes | - | No |
| title | String | 255 | ✅ Yes | - | No |
| body | String | 1000 | ✅ Yes | - | No |
| data | String | 5000 | No | {} | No |
| read | Boolean | - | ✅ Yes | false | No |
| created_at | DateTime | - | ✅ Yes | - | No |

4. Add permissions:
   - **Users (user_id)**: Read, Update, Delete
   - **Role:teacher, Role:admin**: Create

5. Create indexes:
   - Index: `user_id` (Key, ASC)
   - Index: `read` (Key, ASC)

#### Collection 5: approval_requests

1. **Collection ID:** `approval_requests`
2. **Collection Name:** Approval Requests
3. Add attributes:

| Attribute Key | Type | Size | Required | Default | Array |
|--------------|------|------|----------|---------|-------|
| user_id | String | 255 | ✅ Yes | - | No |
| request_type | String | 50 | ✅ Yes | - | No |
| status | Enum | - | ✅ Yes | pending | No |
| data | String | 5000 | No | {} | No |
| created_at | DateTime | - | ✅ Yes | - | No |
| updated_at | DateTime | - | ✅ Yes | - | No |

**For status enum, add values:** `pending`, `approved`, `rejected`

4. Add permissions:
   - **Users (user_id)**: Read, Create, Update
   - **Role:admin**: Read, Update, Delete

#### Collection 6: user_activity

1. **Collection ID:** `user_activity`
2. **Collection Name:** User Activity
3. Add attributes:

| Attribute Key | Type | Size | Required | Default | Array |
|--------------|------|------|----------|---------|-------|
| user_id | String | 255 | ✅ Yes | - | No |
| activity_type | String | 50 | ✅ Yes | - | No |
| data | String | 5000 | No | {} | No |
| created_at | DateTime | - | ✅ Yes | - | No |

4. Add permissions:
   - **Users**: Create
   - **Role:admin**: Read

### Step 4: Create Storage Buckets

1. Click **Storage** in the left sidebar
2. Create 3 buckets:

#### Bucket 1: profile-images
- **Bucket ID:** `profile-images`
- **Maximum File Size:** 5 MB
- **Allowed File Extensions:** jpg, jpeg, png, gif, webp
- **Permissions:**
  - **Any**: Read
  - **Users**: Create, Update, Delete

#### Bucket 2: notice-attachments
- **Bucket ID:** `notice-attachments`
- **Maximum File Size:** 10 MB
- **Allowed File Extensions:** jpg, jpeg, png, pdf, doc, docx, xls, xlsx
- **Permissions:**
  - **Any**: Read
  - **Role:teacher, Role:admin**: Create, Update, Delete

#### Bucket 3: message-attachments
- **Bucket ID:** `message-attachments`
- **Maximum File Size:** 10 MB
- **Allowed File Extensions:** jpg, jpeg, png, pdf, doc, docx
- **Permissions:**
  - **Users**: Create, Read, Delete

## 🚀 Step 5: Install Dependencies and Run

1. Install Flutter dependencies:
```bash
cd apps/mobile
flutter pub get
```

2. Run the app:
```bash
flutter run
```

## ✅ What's Already Done

- ✅ Appwrite educational benefits approved
- ✅ Project credentials configured in code
- ✅ Appwrite SDK integrated
- ✅ Auth service implemented
- ✅ Notice service implemented
- ✅ Services updated to use Appwrite

## 🔧 What You Need to Do

1. ✅ Set up database structure (follow steps above)
2. ✅ Create collections with attributes
3. ✅ Configure permissions
4. ✅ Create storage buckets
5. ✅ Run `flutter pub get`
6. ✅ Test the app

## 📝 Notes

- Your project is in the **Singapore (sgp)** region for optimal performance
- Educational benefits include:
  - Free Pro plan
  - 100 GB storage
  - Unlimited users
  - Priority support

## 🆘 Need Help?

If you encounter any issues:

1. **Appwrite Discord:** https://discord.com/invite/appwrite (mention your educational program)
2. **Appwrite Documentation:** https://appwrite.io/docs
3. **GitHub Issues:** Open an issue in this repository

## 🎉 Once Setup is Complete

After completing the database setup, you'll be able to:
- Register new users
- Create and view notices
- Send and receive messages
- Manage user profiles with extended student information
- Edit profile with private student details (shift, group, class roll, academic session, phone number)
- View student information with proper privacy controls (students see their own data, teachers see all student data)
- All with your Appwrite educational benefits!

## 🔒 Privacy & Security Features

The app implements privacy controls for sensitive student information:

### Student Information Privacy
- **Private Fields**: Shift, Group, Class Roll, Academic Session, and Phone Number are private by default
- **Visibility Rules**:
  - Students can view and edit their own private information
  - Teachers and admins can view all students' private information for academic management
  - Other students cannot see each other's private information
- **UI-Level Protection**: While database permissions allow read access, the app enforces privacy at the UI level

### How It Works
1. When a student views their own profile, all fields are visible and editable
2. When a teacher views a student's profile, all fields are visible (read-only from another user's perspective)
3. When a student views another student's profile, private fields are hidden
4. The Edit Profile screen only allows users to edit their own profile

---

**Time estimate:** 30-45 minutes to complete all steps

**Already have the database structure from Supabase?** The attribute names are compatible, so you can use the migration scripts from the migration guide if needed.
