# Student Information Feature

## Overview

This document describes the new student information feature added to the RPI Communication App, which allows collection and management of detailed student data with proper privacy controls.

## New Fields

The following fields have been added to the user profile for students:

| Field | Type | Description | Privacy Level |
|-------|------|-------------|---------------|
| `shift` | String | Student's class shift (Morning/Day/Evening) | Private |
| `group` | String | Academic group (A, B, C, etc.) | Private |
| `classRoll` | String | Roll number in class | Private |
| `academicSession` | String | Academic year/session (e.g., 2023-2024) | Private |
| `phoneNumber` | String | Contact phone number | Private |

## Privacy Controls

### Visibility Rules

- **Students**: Can view and edit their own private information
- **Teachers & Admins**: Can view all students' private information for academic management
- **Other Students**: Cannot see other students' private information

### Implementation

Privacy is enforced at the UI level:
- `ProfileScreen._canViewPrivateInfo()` method checks permissions
- Private fields are only rendered when permission check passes
- Edit profile is only accessible to the profile owner

## User Experience

### Registration Flow

1. **Simple Registration**: Users register with just name, email, and password
2. **Profile Completion**: Users can add detailed information later via Edit Profile
3. **Progressive Disclosure**: Private fields are clearly marked as such

### Profile Editing

The new Edit Profile screen (`edit_profile_screen.dart`) provides:

- **Basic Information Section**: Name, Department, Year
- **Student Information Section**: 
  - Shift (dropdown with Morning/Day/Evening options)
  - Group (text field with auto-capitalization)
  - Class Roll (numeric input)
  - Academic Session (text field with hint format)
  - Phone Number (phone input with validation)
- **Privacy Notice**: Clear indication that student details are private

### Profile Viewing

The Profile screen shows:
- Public information to everyone
- Private student information section (when permitted):
  - Lock icon indicator
  - "Private" label
  - All student-specific fields

## Technical Implementation

### Database Schema

Updated the `users` collection in Appwrite with new attributes:

```yaml
shift:
  type: String
  size: 50
  required: false
  
group:
  type: String
  size: 10
  required: false
  
class_roll:
  type: String
  size: 20
  required: false
  
academic_session:
  type: String
  size: 50
  required: false
  
phone_number:
  type: String
  size: 20
  required: false
```

### Model Changes

Updated `UserModel` class:
- Added 5 new fields
- Updated `fromJson()` to parse new fields
- Updated `toJson()` to serialize new fields
- Updated `copyWith()` to support new fields
- All fields default to empty string if not provided

### Service Changes

- `AuthService`: Already supports updating user profiles via `updateUserProfile()`
- No changes needed - existing method handles new fields

### UI Changes

1. **ProfileScreen** (`profile_screen.dart`):
   - Added `currentUser` parameter for permission checking
   - Added `_canViewPrivateInfo()` method
   - Added private information section with conditional rendering
   - Updated privacy policy text

2. **EditProfileScreen** (`edit_profile_screen.dart`):
   - New screen for editing user profile
   - Separate sections for basic and student information
   - Privacy notice for student fields
   - Form validation for phone numbers
   - Dropdown for shift selection

3. **HomeScreen** (`home_screen.dart`):
   - Pass `currentUser` to ProfileScreen
   - Fixed user loading logic

## Testing

Added comprehensive tests in `user_model_test.dart`:
- Test new fields in model creation
- Test JSON serialization with new fields
- Test JSON deserialization with new fields
- Test handling of missing fields (backwards compatibility)

## Documentation Updates

1. **APPWRITE_SETUP_INSTRUCTIONS.md**:
   - Added new attributes to users collection table
   - Added privacy note about field visibility
   - Added privacy permissions documentation
   - Added "Privacy & Security Features" section

2. **Privacy Policy**:
   - Updated data collection section
   - Updated data security section
   - Mentioned new student-specific fields

## Future Enhancements

Potential improvements for future versions:

1. **Bulk Student Import**: Allow admins to import student data from CSV
2. **Field Validation**: Add more robust validation (e.g., phone format, session year range)
3. **Department-Specific Fields**: Add fields specific to certain departments
4. **Photo Uploads**: Allow students to upload profile photos
5. **QR Code ID Cards**: Generate QR codes with student information
6. **Export Functionality**: Allow teachers to export student lists

## Migration Notes

For existing installations:
- New fields are optional and default to empty strings
- Existing users will not have these fields populated
- Users can add information via Edit Profile at any time
- No data migration required

## Security Considerations

1. **UI-Level Privacy**: Privacy is enforced in the UI, not at database level
   - Database permissions allow read for performance
   - App ensures private data is not displayed inappropriately
   
2. **Phone Number Storage**: 
   - Stored as plain text (consider encryption for production)
   - Only visible to authorized users
   
3. **Audit Trail**: Consider adding audit log for sensitive data access

## Compliance

This feature helps the institution:
- Maintain proper student records
- Enable teacher-student communication
- Comply with academic record-keeping requirements
- Protect student privacy per institutional policies

## Support

For issues or questions:
- Check [APPWRITE_SETUP_INSTRUCTIONS.md](APPWRITE_SETUP_INSTRUCTIONS.md) for database setup
- Review this document for feature details
- Contact the developer via the app's Developer Info section
