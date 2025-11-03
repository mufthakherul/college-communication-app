# Bug Fixes - November 2025

## Issues Resolved

This document describes the bugs that were identified and fixed in this update.

### 1. Message Sending Error: "Invalid Recipient ID Format"

**Problem:**
- Users could create chats but couldn't send messages
- Error: "Failed to send message: Invalid recipient ID format"
- Root cause: Validator was checking for UUID format only, but Appwrite generates document IDs that may not be UUIDs

**Solution:**
- Modified `message_service.dart` to accept both UUID and Appwrite document ID formats
- Changed validation from `isValidUuid()` to accept both `isValidUuid()` OR `isValidDocumentId()`
- Added additional validation in `_fetchMessages()` to prevent crashes
- Added early validation in chat screen before attempting to send

**Files Changed:**
- `apps/mobile/lib/services/message_service.dart`
- `apps/mobile/lib/screens/messages/chat_screen.dart`

**Testing:**
- Added unit tests for document ID validation
- Test file: `apps/mobile/test/utils/input_validator_test.dart`

### 2. Notice Scraping from Website Not Working

**Problem:**
- Website scraping service was only using API endpoint
- API endpoint may have changed or requires specific headers
- No fallback mechanism if API fails

**Solution:**
- Added HTML scraping fallback when API fails
- Improved request headers for better API compatibility
- Added multiple fallback layers: API → HTML Scraping → Cached Data
- Added timeout handling with custom messages
- Improved error logging for debugging

**Files Changed:**
- `apps/mobile/lib/services/website_scraper_service.dart`

**New Features:**
- `_fetchNoticesFromHtml()` - Direct HTML parsing fallback
- `_parseNoticesFromHtml()` - Parse notices from HTML table
- Better error handling in `dispose()` method

### 3. App Crashing After Some Time

**Problem:**
- App would crash after extended use
- Potential causes:
  - Unhandled null pointer exceptions
  - Memory leaks from undisposed resources
  - Errors in stream controllers
  - Sorting operations on null values

**Solution:**
- Added comprehensive try-catch blocks in critical areas
- Added null safety checks in message sorting
- Improved error handling in dispose methods
- Added defensive checks in UI components
- Fixed null pointer exceptions in messages screen

**Files Changed:**
- `apps/mobile/lib/services/message_service.dart`
- `apps/mobile/lib/services/website_scraper_service.dart`
- `apps/mobile/lib/screens/messages/messages_screen.dart`
- `apps/mobile/lib/screens/messages/chat_screen.dart`

**Improvements:**
- Safe message sorting with null checks
- Safe disposal of stream controllers
- Error handling in filter operations
- Better error messages for users

## Technical Details

### Message Validation Changes

**Before:**
```dart
if (!InputValidator.isValidUuid(recipientId)) {
  throw Exception('Invalid recipient ID format');
}
```

**After:**
```dart
if (!InputValidator.isValidDocumentId(recipientId) && 
    !InputValidator.isValidUuid(recipientId)) {
  throw Exception('Invalid recipient ID format');
}
```

### Website Scraper Fallback Chain

1. **Try API Endpoint**: POST to DataTables API with proper headers
2. **If API fails**: Try HTML scraping from main page
3. **If HTML fails**: Return cached data
4. **If no cache**: Return empty list

### Null Safety Pattern

**Before:**
```dart
allMessages.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
```

**After:**
```dart
allMessages.sort((a, b) {
  if (a.createdAt == null && b.createdAt == null) return 0;
  if (a.createdAt == null) return 1;
  if (b.createdAt == null) return -1;
  return b.createdAt!.compareTo(a.createdAt!);
});
```

## Testing

### Manual Testing Checklist

- [ ] Send message to a user with Appwrite document ID
- [ ] Send message to a user with UUID
- [ ] Test message sending when offline
- [ ] Test notice scraping with working website
- [ ] Test notice scraping when website is down
- [ ] Test app stability over 30+ minutes of use
- [ ] Test switching between online/offline states
- [ ] Test creating and joining group chats

### Automated Tests

- [x] Input validator tests for document IDs
- [x] Input validator tests for UUIDs
- [x] Message sanitization tests
- [x] Search query sanitization tests

Run tests with:
```bash
cd apps/mobile
flutter test
```

## Deployment Notes

These fixes are backward compatible and do not require database migrations or configuration changes.

### Breaking Changes
None

### Required Actions
None - All changes are internal improvements

## Monitoring

After deployment, monitor for:
1. Error rates in message sending
2. Success rates of notice scraping
3. App crash reports via Sentry
4. User feedback on messaging reliability

## Related Issues

- Message sending validation
- Notice board reliability
- App stability and memory management

## Future Improvements

1. Consider using more robust ID validation that auto-detects format
2. Add metrics for notice scraping success/failure rates
3. Implement automated crash reporting with stack traces
4. Add health check endpoint for website scraping
5. Consider caching strategy for frequently accessed data
