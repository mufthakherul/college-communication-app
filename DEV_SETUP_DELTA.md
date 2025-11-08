# Dev Setup Delta (User/Profile Split)

This file documents changes needed after splitting the single `users` table into two collections: `users` (core identity) and `user_profiles` (extended attributes).

## ✅ Current State

- Core user fields now live in `UserModel` (`lib/models/user_model.dart`).
- Extended profile & role-specific fields (student, teacher, admin) moved to `UserProfile` (`lib/models/user_profile_model.dart`).
- Service layer: `AuthService.getUserProfile` still returns `UserModel` from `users` collection.
- New CRUD operations for extended profile handled by `UserProfileService`.

## 🧪 Test Adjustments

| Area                                       | Action                                                                        |
| ------------------------------------------ | ----------------------------------------------------------------------------- |
| `test/models/user_model_test.dart`         | Removed assertions for profile-only fields; added copyWith & id mapping tests |
| `test/models/user_profile_model_test.dart` | Added new tests for extended profile parsing & serialization                  |
| Pending Integration Tests                  | Add scenarios covering profile creation on first login                        |

## 🔄 Required Follow-ups

1. Add mock Appwrite client for `UserProfileService` to unit test CRUD logic without network.
2. Update any remaining test referencing user fields moved to `UserProfile` (search for: `shift`, `class_roll`, `academic_session`).
3. Add integration test: `profile_initialization_flow_test.dart` ensuring profile auto-creation.
4. Verify UI screens (`profile_screen.dart`, `edit_profile_screen.dart`) gracefully handle missing profile.

## 🔧 Seed / Migration Guidance

If migrating existing data:

1. Export old `users` documents.
2. Transform to two outputs:
   - `users`: keep id, email, display_name, role, department, year, is_active, timestamps.
   - `user_profiles`: map extended/student/teacher/admin fields; include `user_id` referencing original id.
3. Backfill profile timestamps if missing.
4. Run batch create in Appwrite (consider rate limits).

## 📌 Edge Cases

- User signs in but profile not yet created → `getOrCreateUserProfile` handles fallback.
- Role changes: ensure profile fields invalidated or updated (e.g. student -> teacher). Add logic if needed.
- Deleting a user should cascade delete corresponding `user_profile` (currently manual in `UserProfileService.deleteUserProfile`).

## 🚀 Next Test Enhancements (Suggested)

- Service mock tests for `UserProfileService.getOrCreateUserProfile`.
- Role-based conditional field serialization tests.
- Performance test for batch profile creation (100+ profiles).

## 🗃 Search References Used

- Model split validated via occurrences of `UserProfile` across services and screens.
- Deprecated field usage removed from user model tests.

## ✅ Status Summary

- Core model test: PASS (updated)
- Profile model test: PASS (new)
- Flutter service tests: PENDING (Flutter SDK not available in current container)

_Last updated: 2025-11-08_
