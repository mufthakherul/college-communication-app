# Appwrite Configuration Checklist

## 📋 Complete Setup & Configuration Checklist

This checklist helps you set up and configure Appwrite for the RPI Communication App using the latest Appwrite features.

**Before you start:**
- [ ] Read [APPWRITE_UPDATED_GUIDE.md](APPWRITE_UPDATED_GUIDE.md) for comprehensive information
- [ ] Have your Appwrite account ready
- [ ] Have educational benefits approved (optional but recommended)

---

## Phase 1: Account & Project Setup

### Appwrite Account
- [ ] Create account at https://cloud.appwrite.io
- [ ] Apply for educational benefits at https://appwrite.io/education (optional)
- [ ] Wait for educational benefits approval (3-7 days)
- [ ] Verify your email address

### Project Creation
- [ ] Create new project in Appwrite Console
- [ ] Note your Project ID: `[YOUR_PROJECT_ID]` (e.g., 6904cfb1001e5253725b)
- [ ] Note your API Endpoint: `[YOUR_ENDPOINT]` (e.g., https://sgp.cloud.appwrite.io/v1)
- [ ] Select appropriate region (e.g., Singapore for Asia)
- [ ] Enable required services:
  - [ ] Authentication
  - [ ] Databases
  - [ ] Storage
  - [ ] Functions (if needed)
  - [ ] Realtime

---

## Phase 2: Database Configuration

### Database Creation
- [ ] Create database: `rpi_communication`
- [ ] Verify database ID is correct
- [ ] Check database settings

### Collections Setup

#### Users Collection
- [ ] Create collection: `users`
- [ ] Add all 14 attributes (see [APPWRITE_DATABASE_QUICKSTART.md](APPWRITE_DATABASE_QUICKSTART.md))
  - **Critical attributes** (registration will fail if missing):
    - [ ] email (string, 255, required)
    - [ ] display_name (string, 255, required)
    - [ ] phone_number (string, 20, optional)
    - [ ] role (enum, required, default: student)
    - [ ] is_active (boolean, required, default: true)
    - [ ] created_at (datetime, required)
    - [ ] updated_at (datetime, required)
- [ ] Set `role` enum values: `student`, `teacher`, `admin`
- [ ] Create indexes:
  - [ ] `email` (unique, asc)
  - [ ] `role` (key, asc)
  - [ ] `department` (key, asc)
- [ ] Configure permissions:
  - [ ] Read: `any`
  - [ ] Create: `users`
  - [ ] Update: `user:{$userId}`
  - [ ] Delete: `label:admin`
- [ ] **Verify attributes created**: Go to Attributes tab and count - should have 14 attributes total

#### Notices Collection
- [ ] Create collection: `notices`
- [ ] Add all 10 attributes
- [ ] Set `type` enum values: `announcement`, `event`, `urgent`
- [ ] Create indexes:
  - [ ] `type` (key, asc)
  - [ ] `is_active` (key, asc)
  - [ ] `created_at` (key, desc)
  - [ ] `author_id` (key, asc)
- [ ] Configure permissions:
  - [ ] Read: `any`
  - [ ] Create: `label:teacher`, `label:admin`
  - [ ] Update: `user:{$userId}`, `label:admin`
  - [ ] Delete: `label:admin`

#### Messages Collection
- [ ] Create collection: `messages`
- [ ] Add all 10 attributes
- [ ] Set `type` enum values: `text`, `image`, `file`
- [ ] Create indexes:
  - [ ] `sender_id` (key, asc)
  - [ ] `recipient_id` (key, asc)
  - [ ] `is_read` (key, asc)
  - [ ] `created_at` (key, desc)
- [ ] Configure permissions:
  - [ ] Read: `user:{$userId}` (use document-level in code)
  - [ ] Create: `users`
  - [ ] Update: `user:{$userId}`
  - [ ] Delete: `user:{$userId}`, `label:admin`

#### Notifications Collection
- [ ] Create collection: `notifications`
- [ ] Add all 7 attributes
- [ ] Create indexes:
  - [ ] `user_id` (key, asc)
  - [ ] `is_read` (key, asc)
  - [ ] `created_at` (key, desc)
- [ ] Configure permissions:
  - [ ] Read: `user:{$userId}`
  - [ ] Create: `label:teacher`, `label:admin`, `users`
  - [ ] Update: `user:{$userId}`
  - [ ] Delete: `user:{$userId}`

#### Books Collection
- [ ] Create collection: `books`
- [ ] Add all 18 attributes
- [ ] Set `category` enum values: `textbook`, `reference`, `fiction`, `technical`, `research`, `magazine`, `journal`, `other`
- [ ] Set `status` enum values: `available`, `borrowed`, `reserved`, `maintenance`
- [ ] Create indexes:
  - [ ] `category` (key, asc)
  - [ ] `status` (key, asc)
  - [ ] `department` (key, asc)
  - [ ] `title` (fulltext)
  - [ ] `author` (fulltext)
- [ ] Configure permissions:
  - [ ] Read: `any`
  - [ ] Create: `label:teacher`, `label:admin`
  - [ ] Update: `label:teacher`, `label:admin`
  - [ ] Delete: `label:admin`

#### Book Borrows Collection
- [ ] Create collection: `book_borrows`
- [ ] Add all 9 attributes
- [ ] Set `status` enum values: `borrowed`, `returned`, `overdue`
- [ ] Create indexes:
  - [ ] `book_id` (key, asc)
  - [ ] `user_id` (key, asc)
  - [ ] `status` (key, asc)
  - [ ] `due_date` (key, asc)
- [ ] Configure permissions:
  - [ ] Read: `user:{$userId}`, `label:teacher`, `label:admin`
  - [ ] Create: `users`
  - [ ] Update: `user:{$userId}`, `label:teacher`, `label:admin`
  - [ ] Delete: `label:admin`

### Additional Collections (Optional)
- [ ] `assignments` collection (if needed)
- [ ] `assignment_submissions` collection (if needed)
- [ ] `timetables` collection (if needed)
- [ ] `study_groups` collection (if needed)
- [ ] `events` collection (if needed)

---

## Phase 3: Storage Configuration

### Bucket 1: Profile Images
- [ ] Create bucket: `profile-images`
- [ ] Set max file size: 5 MB (5,242,880 bytes)
- [ ] Set allowed extensions: `jpg`, `jpeg`, `png`, `gif`, `webp`
- [ ] Enable compression
- [ ] Enable encryption
- [ ] Configure permissions:
  - [ ] Read: `any`
  - [ ] Create: `users`
  - [ ] Update: `user:{$userId}`
  - [ ] Delete: `user:{$userId}`

### Bucket 2: Notice Attachments
- [ ] Create bucket: `notice-attachments`
- [ ] Set max file size: 10 MB (10,485,760 bytes)
- [ ] Set allowed extensions: `jpg`, `jpeg`, `png`, `pdf`, `doc`, `docx`, `xls`, `xlsx`
- [ ] Enable encryption
- [ ] Configure permissions:
  - [ ] Read: `any`
  - [ ] Create: `label:teacher`, `label:admin`
  - [ ] Update: `label:teacher`, `label:admin`
  - [ ] Delete: `label:admin`

### Bucket 3: Message Attachments
- [ ] Create bucket: `message-attachments`
- [ ] Set max file size: 25 MB (26,214,400 bytes)
- [ ] Set allowed extensions: `jpg`, `jpeg`, `png`, `pdf`, `doc`, `docx`, `zip`
- [ ] Enable encryption
- [ ] Configure permissions (use document-level in code):
  - [ ] Read: `user:{$userId}`
  - [ ] Create: `users`
  - [ ] Update: `user:{$userId}`
  - [ ] Delete: `user:{$userId}`

### Bucket 4: Book Covers
- [ ] Create bucket: `book-covers`
- [ ] Set max file size: 2 MB (2,097,152 bytes)
- [ ] Set allowed extensions: `jpg`, `jpeg`, `png`, `webp`
- [ ] Enable compression
- [ ] Enable encryption
- [ ] Configure permissions:
  - [ ] Read: `any`
  - [ ] Create: `label:teacher`, `label:admin`
  - [ ] Update: `label:teacher`, `label:admin`
  - [ ] Delete: `label:admin`

### Bucket 5: Book Files
- [ ] Create bucket: `book-files`
- [ ] Set max file size: 100 MB (104,857,600 bytes)
- [ ] Set allowed extensions: `pdf`
- [ ] Enable encryption
- [ ] Configure permissions:
  - [ ] Read: `users` (authenticated only)
  - [ ] Create: `label:teacher`, `label:admin`
  - [ ] Update: `label:teacher`, `label:admin`
  - [ ] Delete: `label:admin`

### Additional Buckets (Optional)
- [ ] `assignment-files` bucket (if needed)

---

## Phase 4: Application Configuration

### Update SDK
- [ ] Open `apps/mobile/pubspec.yaml`
- [ ] Update Appwrite SDK: `appwrite: ^13.0.0`
- [ ] Run `flutter pub get`
- [ ] Verify no dependency conflicts

### Update Configuration File
- [ ] Open `apps/mobile/lib/appwrite_config.dart`
- [ ] Update `endpoint` with your API endpoint
- [ ] Update `projectId` with your project ID
- [ ] Verify `databaseId` is `rpi_communication`
- [ ] Verify all collection IDs match
- [ ] Verify all bucket IDs match

### Initialize Appwrite Service
- [ ] Verify `AppwriteService` is properly initialized
- [ ] Check initialization happens in `main.dart`
- [ ] Ensure initialization before any Appwrite calls

---

## Phase 5: Authentication Setup

### Email/Password Auth
- [ ] Verify auth is enabled in Appwrite Console
- [ ] Test user registration
- [ ] Test user login
- [ ] Test user logout
- [ ] Test session persistence
- [ ] Test password reset (if implemented)

### OAuth Providers (Optional)
- [ ] Enable Google OAuth in Appwrite Console
- [ ] Configure OAuth credentials
- [ ] Test Google sign-in
- [ ] Configure additional providers as needed

---

## Phase 6: Testing

### Database Operations
- [ ] Test creating documents in each collection
- [ ] Test reading documents
- [ ] Test updating documents
- [ ] Test deleting documents
- [ ] Test queries with filters
- [ ] Test pagination
- [ ] Verify permissions work correctly

### Storage Operations
- [ ] Test file upload to each bucket
- [ ] Test file download
- [ ] Test file deletion
- [ ] Test file preview/view URLs
- [ ] Verify file size limits work
- [ ] Verify file type restrictions work
- [ ] Verify permissions work correctly

### Real-time Subscriptions
- [ ] Test subscribing to collection changes
- [ ] Test receiving create events
- [ ] Test receiving update events
- [ ] Test receiving delete events
- [ ] Test unsubscribing
- [ ] Verify no memory leaks

### Authentication Flow
- [ ] Test complete registration flow
- [ ] Test login flow
- [ ] Test session persistence across app restarts
- [ ] Test logout flow
- [ ] Test error handling for invalid credentials

---

## Phase 7: Production Readiness

### Security
- [ ] Review all collection permissions
- [ ] Review all bucket permissions
- [ ] Ensure sensitive data is protected
- [ ] Enable HTTPS only
- [ ] Configure CORS properly
- [ ] Set up API key management
- [ ] Review security best practices in [APPWRITE_UPDATED_GUIDE.md](APPWRITE_UPDATED_GUIDE.md)

### Performance
- [ ] Verify indexes are created for frequently queried fields
- [ ] Test with realistic data volumes
- [ ] Monitor response times
- [ ] Optimize queries if needed
- [ ] Enable caching where appropriate

### Monitoring
- [ ] Set up error tracking
- [ ] Monitor API usage
- [ ] Monitor storage usage
- [ ] Set up alerts for quota limits
- [ ] Monitor database performance

### Documentation
- [ ] Document any custom configurations
- [ ] Document environment variables
- [ ] Document deployment process
- [ ] Update team on changes
- [ ] Create user guides if needed

---

## Phase 8: Deployment

### Pre-Deployment
- [ ] All tests passing
- [ ] Security review completed
- [ ] Performance testing completed
- [ ] Documentation updated
- [ ] Team notified

### Deployment
- [ ] Deploy to staging environment
- [ ] Test in staging
- [ ] Deploy to production
- [ ] Verify production works
- [ ] Monitor for issues

### Post-Deployment
- [ ] Monitor error rates
- [ ] Monitor performance metrics
- [ ] Monitor user feedback
- [ ] Address any issues quickly
- [ ] Document lessons learned

---

## Troubleshooting Checklist

If things aren't working:

### Authentication Issues
- [ ] Verify user is actually signed in
- [ ] Check session hasn't expired
- [ ] Verify credentials are correct
- [ ] Check network connectivity
- [ ] Review error messages carefully

### Permission Issues
- [ ] Verify collection permissions are set
- [ ] Check document-level permissions in code
- [ ] Ensure user has correct role/label
- [ ] Test with different users/roles
- [ ] Review permission documentation

### Database Issues
- [ ] Verify database ID is correct
- [ ] Verify collection IDs are correct
- [ ] Check attribute names match
- [ ] Verify indexes are created
- [ ] Check query syntax
- [ ] Review error messages

### Storage Issues
- [ ] Verify bucket IDs are correct
- [ ] Check file size limits
- [ ] Verify file extensions allowed
- [ ] Check permissions
- [ ] Verify network connectivity

### Real-time Issues
- [ ] Verify correct channel syntax
- [ ] Check subscription is active
- [ ] Verify WebSocket connection
- [ ] Check for connection drops
- [ ] Review network logs

---

## Resources

- **Comprehensive Guide:** [APPWRITE_UPDATED_GUIDE.md](APPWRITE_UPDATED_GUIDE.md)
- **Quick Start:** [APPWRITE_DATABASE_QUICKSTART.md](APPWRITE_DATABASE_QUICKSTART.md)
- **Schema Reference:** [APPWRITE_COLLECTIONS_SCHEMA.md](APPWRITE_COLLECTIONS_SCHEMA.md)
- **Official Docs:** https://appwrite.io/docs
- **Community Discord:** https://discord.com/invite/appwrite
- **GitHub Discussions:** https://github.com/appwrite/appwrite/discussions

---

## Estimated Time

- Phase 1 (Account): 30 minutes (or 3-7 days with educational benefits)
- Phase 2 (Database): 45-60 minutes
- Phase 3 (Storage): 15-20 minutes
- Phase 4 (App Config): 10 minutes
- Phase 5 (Auth): 15 minutes
- Phase 6 (Testing): 60-90 minutes
- Phase 7 (Production): 30-60 minutes
- Phase 8 (Deployment): 30-60 minutes

**Total Active Time: 4-6 hours** (excluding educational benefits approval wait time)

---

## Success Criteria

Your Appwrite setup is complete when:

- ✅ All collections created with correct attributes
- ✅ All indexes created
- ✅ All permissions configured
- ✅ All buckets created with correct settings
- ✅ SDK updated and configured
- ✅ Authentication working
- ✅ Database operations working
- ✅ Storage operations working
- ✅ Real-time subscriptions working
- ✅ All tests passing
- ✅ No permission errors
- ✅ Production deployed successfully

---

**Last Updated:** November 2025

**Need Help?**
- Check [APPWRITE_UPDATED_GUIDE.md](APPWRITE_UPDATED_GUIDE.md) for detailed information
- Visit Appwrite Discord for community support
- Review official documentation at https://appwrite.io/docs
- Open an issue on GitHub if you find problems
