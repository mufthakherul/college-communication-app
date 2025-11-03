# Notice Board Improvements

## Overview
This document describes the improvements made to the notice board system to support two layers of notices and fix various issues.

## Changes Made

### 1. Two-Layer Notice Board Structure

The notice board now displays notices in two separate tabs:

#### Tab 1: Admin/Teacher Notices
- Notices created by administrators and teachers
- Source: `NoticeSource.admin`
- Users with admin or teacher roles can create these notices
- These are manually created through the app

#### Tab 2: College Website Notices
- Notices scraped from the Rangpur Polytechnic Institute website
- Source: `NoticeSource.scraped`
- URL: https://rangpur.polytech.gov.bd/site/view/notices
- Automatically fetched and parsed from the college website
- Include a link icon to indicate external source

### 2. Notice Model Updates

Added new fields to `NoticeModel`:

```dart
enum NoticeSource { admin, scraped }

class NoticeModel {
  // ... existing fields ...
  final NoticeSource source;      // Distinguishes between admin and scraped
  final String? sourceUrl;        // URL for scraped notices
}
```

### 3. Website Scraper Implementation

The `WebsiteScraperService` now includes:

- **HTML Parsing**: Uses the `html` package to parse the college website
- **Multiple Fallback Strategies**: Tries different CSS selectors to find notices
- **Robust Date Parsing**: Handles various date formats
- **Absolute URL Conversion**: Converts relative URLs to absolute URLs
- **Caching**: Caches scraped notices locally for offline access
- **Manual Sync**: Users can manually trigger a sync from the UI

#### How it works:

1. Fetches HTML from the college website
2. Tries multiple CSS selectors to find notice elements:
   - `.notice-item`, `.notice`, `table.notice-table tr`, etc.
3. Extracts title, description, date, and URL from each notice
4. Falls back to finding notice-like links if structured parsing fails
5. Caches results locally
6. Syncs to Appwrite database for persistence

### 4. Manual Sync Button

In the "College Website" tab, there's a sync button (🔄) that:
- Fetches the latest notices from the college website
- Parses and extracts notice information
- Saves them to the database with `source: scraped`
- Shows a progress indicator while syncing
- Displays the number of notices synced

### 5. Debug Console Fix

Fixed the issue where user information (userId, email, role) showed as "N/A":

**Problem**: The debug console was calling `currentUser` before the auth service was fully initialized.

**Solution**: Added explicit auth service initialization before fetching user data:

```dart
await _authService.initialize();
final isAuthenticated = await _authService.isAuthenticated();
final currentUserId = _authService.currentUserId;
final currentUser = currentUserId != null
    ? await _authService.getUserProfile(currentUserId)
    : null;
```

### 6. Chat Button Verification

Verified that the chat button (FloatingActionButton) in the Messages screen:
- ✅ Is always visible to all users
- ✅ Has no role-based restrictions
- ✅ Students can create new conversations
- ✅ Works as expected for all user types

## Usage

### For Students

1. **View Notices**:
   - Navigate to the Notices screen
   - Switch between "Admin/Teacher" and "College Website" tabs
   - Tap on any notice to view full details

2. **Sync Website Notices**:
   - Go to the "College Website" tab
   - Tap the sync button (🔄) in the top right
   - Wait for notices to be fetched and synced

3. **Create Chats**:
   - Go to Messages screen
   - Tap the floating action button (+) to start a new conversation
   - Select a user from the list

### For Teachers/Admins

In addition to student features:

1. **Create Notices**:
   - Go to the Notices screen
   - Tap the (+) button in the top right
   - Fill in notice details
   - Select notice type (Announcement, Event, Urgent)
   - Submit to create

## Database Schema

The `notices` collection should include these attributes:

```
- id (string, unique)
- title (string, required)
- content (string, required)
- type (string, enum: announcement|event|urgent)
- target_audience (string)
- author_id (string)
- created_at (datetime)
- updated_at (datetime)
- expires_at (datetime, optional)
- is_active (boolean)
- source (string, enum: admin|scraped)  ← NEW
- source_url (string, optional)          ← NEW
```

### Setting up Appwrite Collection

1. Open Appwrite Console
2. Navigate to your database
3. Select the `notices` collection
4. Add these new attributes:
   - `source` (String, default: "admin")
   - `source_url` (String, optional)

## Technical Details

### Dependencies Added

```yaml
html: ^0.15.4  # For HTML parsing and web scraping
```

### Files Modified

1. `lib/models/notice_model.dart` - Added source and sourceUrl fields
2. `lib/services/notice_service.dart` - Added source parameter and filtering methods
3. `lib/services/website_scraper_service.dart` - Implemented HTML parsing
4. `lib/screens/notices/notices_screen.dart` - Added two-tab layout and sync button
5. `lib/screens/developer/debug_console_screen.dart` - Fixed auth initialization
6. `lib/services/background_sync_service.dart` - Added website notices sync task
7. `pubspec.yaml` - Added html package dependency

### Background Sync (Optional)

To enable automatic syncing of website notices in the background:

```dart
await BackgroundSyncService().registerWebsiteNoticesSync(
  frequency: Duration(hours: 6), // Sync every 6 hours
);
```

This is currently a placeholder and requires additional implementation for production use.

## Troubleshooting

### Issue: No notices appear in College Website tab

**Solutions**:
1. Tap the sync button (🔄) to manually fetch notices
2. Check internet connection
3. Verify the college website is accessible
4. Check debug logs for scraping errors

### Issue: Sync button doesn't work

**Possible causes**:
1. No internet connection
2. College website structure changed
3. Permission issues with database

**Debug steps**:
1. Check debug console for errors
2. Verify Appwrite database permissions
3. Test accessing the college website directly

### Issue: Debug console still shows N/A for user info

**Solutions**:
1. Log out and log back in
2. Ensure you have an active internet connection
3. Check if Appwrite session is valid
4. Verify user profile exists in database

## Future Enhancements

1. **Smart Diffing**: Only sync new notices, avoid duplicates
2. **Notification**: Notify users when new college website notices are available
3. **Rich Parsing**: Extract attachments, images from website notices
4. **Multiple Sources**: Support scraping from multiple college websites
5. **Scheduled Sync**: Automatic background syncing at configurable intervals
6. **Notice Categories**: Better categorization and filtering of notices

## Support

For issues or questions, please refer to:
- Project README.md
- QUICK_START.md
- Contact the developer: mufthakherul

---

**Version**: 2.0.0  
**Last Updated**: 2025-11-03  
**Author**: Mufthakherul
