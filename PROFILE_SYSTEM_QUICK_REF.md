# Role-Based Profile System - Quick Reference

## 🚀 Quick Start

### For Developers

The profile system is fully implemented and ready to use. Profiles are **automatically created** when users first view their profile screen.

### What Changed?

1. **users** collection now only stores common data (9 fields)
2. **user_profiles** collection stores role-specific data (20 fields)
3. UI dynamically switches based on user role (student/teacher/admin)

---

## 📱 User Experience

### Student View

- **Common Info:** Department, Year, Status
- **Student Details:** Shift, Group, Class Roll, Academic Session, Registration No, Guardian Info
- **Privacy:** Private fields only visible to self or teachers/admins

### Teacher View

- **Common Info:** Department, Status
- **Teaching Profile:** Designation, Office Room, Subjects, Qualification, Office Hours

### Admin View

- **Common Info:** Department, Status
- **Admin Info:** Admin Title, Permission Scopes (displayed as chips)
- **Admin Tools:** Quick links to manage notices and groups

---

## 🔧 For Developers

### Using UserProfileService

```dart
import 'package:campus_mesh/services/user_profile_service.dart';
import 'package:appwrite/appwrite.dart';

final client = Client()
    .setEndpoint(AppwriteConfig.endpoint)
    .setProject(AppwriteConfig.projectId);

final profileService = UserProfileService(client);
```

### Get or Create Profile (Recommended)

```dart
// Automatically creates profile if it doesn't exist
final profile = await profileService.getOrCreateUserProfile(
  userId,
  'student', // role
);
```

### Get Existing Profile

```dart
// Returns null if profile doesn't exist
final profile = await profileService.getUserProfile(userId);
```

### Update Profile

```dart
await profileService.updateUserProfile(userId, {
  'bio': 'Updated bio',
  'shift': 'Morning',
  'subjects': ['Math', 'Physics'], // Arrays work too
});
```

### Query by Role

```dart
final allTeachers = await profileService.getProfilesByRole(UserRole.teacher);
```

---

## 🗂️ Database Structure

### users Collection (9 fields)

Common identity data for all roles:

- email, display_name, photo_url, role, department, year, is_active, created_at, updated_at

### user_profiles Collection (20 fields)

Role-specific extended data:

- **Core:** user_id, role
- **Common:** bio, phone_number
- **Student:** shift, group, class_roll, academic_session, registration_no, guardian_name, guardian_phone
- **Teacher:** designation, office_room, subjects[], qualification, office_hours
- **Admin:** admin_title, admin_scopes[]
- **Audit:** created_at, updated_at

---

## 🛠️ Maintenance Scripts

### Test Profiles

```bash
cd scripts
node test-user-profiles.js
```

Runs 6 tests to verify CRUD operations for all roles.

### Migrate Existing Users

```bash
cd scripts
node migrate-existing-user-data.js
```

Creates profiles for users who don't have one (requires admin API key).

**Note:** Not strictly necessary - profiles are auto-created on first access.

---

## ✅ Validation Checklist

### Before Deployment

- [x] Database migrations executed
- [x] All Flutter files compile without errors
- [x] UserProfileService created and tested
- [x] Profile views display role-specific data
- [x] Edit screen saves to correct collections
- [ ] Manual testing for all 3 roles (student, teacher, admin)

### After Deployment

- [ ] Monitor Appwrite logs for profile creation
- [ ] Verify profile updates work correctly
- [ ] Check that privacy controls work (student data)
- [ ] Test role switching (change role in DB, verify UI updates)

---

## 🐛 Troubleshooting

### Profile Not Loading

**Symptom:** Spinner shows indefinitely  
**Solution:** Check Appwrite permissions on user_profiles collection

### Edit Fails

**Symptom:** "Profile not found" error  
**Solution:** Profile should auto-create. Check UserProfileService.getOrCreateUserProfile logic

### Arrays Not Saving (Subjects/Scopes)

**Symptom:** Comma-separated values not converting to array  
**Solution:** Check EditProfileScreen - should split by comma and trim whitespace

### Role Change Not Reflecting

**Symptom:** Changed role in DB but UI still shows old layout  
**Solution:** Users need to logout and login again to refresh UserModel

---

## 📊 Key Files Reference

### Models

- `apps/mobile/lib/models/user_model.dart` - Common user data (10 fields)
- `apps/mobile/lib/models/user_profile_model.dart` - Role-specific data (22 fields)

### Services

- `apps/mobile/lib/services/auth_service.dart` - Updates users collection
- `apps/mobile/lib/services/user_profile_service.dart` - Updates user_profiles collection

### Screens

- `apps/mobile/lib/screens/profile/profile_screen.dart` - Main profile display
- `apps/mobile/lib/screens/profile/edit_profile_screen.dart` - Role-aware editing

### Views

- `apps/mobile/lib/screens/profile/views/student_profile_view.dart` - Student layout
- `apps/mobile/lib/screens/profile/views/teacher_profile_view.dart` - Teacher layout
- `apps/mobile/lib/screens/profile/views/admin_profile_view.dart` - Admin layout

### Scripts

- `scripts/migrate-user-profiles.js` - Creates user_profiles collection ✅ EXECUTED
- `scripts/cleanup-users-collection.js` - Removes student fields from users ✅ EXECUTED
- `scripts/test-user-profiles.js` - Tests CRUD operations
- `scripts/migrate-existing-user-data.js` - Migrates existing user data (optional)

---

## 🎯 Common Tasks

### Add a New Field

#### For All Roles (e.g., "bio")

Already done! `bio` is in user_profiles as a common optional field.

#### For Specific Role (e.g., "research_interests" for teachers)

1. **Database:**

```bash
# Add attribute via Appwrite console or script
await databases.createStringAttribute(
  DATABASE_ID,
  'user_profiles',
  'research_interests',
  500,
  false
);
```

2. **Model:** Add to `UserProfile` class

```dart
final String? researchInterests;
```

3. **View:** Display in `TeacherProfileView`

```dart
if (profile.researchInterests != null)
  _tile(context, Icons.science, 'Research', profile.researchInterests!),
```

4. **Edit:** Add field in `EditProfileScreen`

```dart
TextFormField(
  controller: _researchInterestsController,
  decoration: InputDecoration(labelText: 'Research Interests'),
)
```

### Change Role for a User

1. **Via Appwrite Console:**

   - Navigate to rpi_communication > users collection
   - Find user document
   - Update `role` field (student/teacher/admin)

2. **User must logout and login** to see new role layout

3. **Profile will auto-adapt** to new role's fields

---

## 💡 Best Practices

### Always Use getOrCreateUserProfile

```dart
// ✅ Good - handles missing profiles gracefully
final profile = await profileService.getOrCreateUserProfile(userId, role);

// ❌ Bad - throws error if profile doesn't exist
final profile = await profileService.getUserProfile(userId);
```

### Update Only Changed Fields

```dart
// ✅ Good - partial update
await profileService.updateUserProfile(userId, {
  'bio': newBio,
});

// ❌ Bad - overwrites entire profile
await profileService.updateUserProfile(userId, profile.toJson());
```

### Handle Arrays Correctly

```dart
// ✅ Good - clean array
'subjects': ['Math', 'Physics', 'Chemistry']

// ❌ Bad - array with empty strings
'subjects': ['Math', '', 'Physics']
```

### Check Permissions

```dart
// ✅ Good - check before showing sensitive data
if (_canViewPrivateInfo()) {
  // Show private fields
}

// ❌ Bad - expose all data
```

---

## 📞 Support

For issues or questions:

1. Check this reference guide
2. Review `ROLE_BASED_PROFILES_COMPLETE.md` for detailed documentation
3. Run test script: `node scripts/test-user-profiles.js`
4. Check Appwrite logs for error details

---

**Last Updated:** November 8, 2025  
**Status:** ✅ Production Ready
