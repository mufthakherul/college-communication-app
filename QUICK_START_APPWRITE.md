# 🚀 Quick Start: Appwrite Configuration

## Welcome! 👋

This guide will help you get your Appwrite database configured in **under 1 hour**.

---

## ⚠️ Important: Documentation Has Been Updated!

The Appwrite documentation has been completely updated to address the differences between the old project docs and the official Appwrite documentation.

**What was the problem?**
- Old documentation used Appwrite SDK v12.0.1
- Missing information about new services (Realtime, Functions, etc.)
- Database permissions not fully explained
- Real-time subscriptions not documented

**What's been fixed?**
- ✅ SDK updated to v12.0.4 (latest compatible with Flutter SDK)
- ✅ Comprehensive guides for all Appwrite features
- ✅ Complete permission system documentation
- ✅ Real-time subscriptions guide
- ✅ Functions service documentation
- ✅ Step-by-step setup guides

**Note:** Using v12.0.4 instead of v13+ due to Flutter SDK dependency constraints. All features documented work perfectly with v12.0.4.

---

## 📚 New Documentation Structure

### 1. **START HERE** → [APPWRITE_UPDATED_GUIDE.md](APPWRITE_UPDATED_GUIDE.md)
**Read this first!** (30-45 minutes)

Complete guide covering:
- ✅ All Appwrite services (Database, Auth, Storage, Realtime, Functions)
- ✅ Permission system (document-level and collection-level)
- ✅ Real-time subscriptions
- ✅ Advanced queries
- ✅ Security best practices
- ✅ Complete code examples

### 2. **SETUP GUIDE** → [APPWRITE_DATABASE_QUICKSTART.md](APPWRITE_DATABASE_QUICKSTART.md)
**Follow this for database setup!** (45-55 minutes)

Quick reference for:
- ✅ Database creation
- ✅ Collections with permissions
- ✅ Storage buckets
- ✅ Testing procedures

### 3. **CHECKLIST** → [APPWRITE_CONFIGURATION_CHECKLIST.md](APPWRITE_CONFIGURATION_CHECKLIST.md)
**Use this to track progress!** (ongoing)

Complete checklist with:
- ✅ Phase-by-phase setup
- ✅ Verification steps
- ✅ Troubleshooting guide
- ✅ Success criteria

### 4. **SUMMARY** → [APPWRITE_DOCUMENTATION_UPDATE_SUMMARY.md](APPWRITE_DOCUMENTATION_UPDATE_SUMMARY.md)
**Review what changed!** (10 minutes)

Details about:
- ✅ What was updated
- ✅ Why it was updated
- ✅ What you need to do
- ✅ What's already done

---

## 🎯 Your Action Plan (Choose One)

### Option A: Quick Setup (1-2 hours)

**If you want to get started quickly:**

1. **Read the updated guide** (30 min)
   ```bash
   Read: APPWRITE_UPDATED_GUIDE.md
   ```

2. **Update your project** (5 min)
   ```bash
   cd apps/mobile
   flutter pub get
   ```

3. **Follow the quickstart** (45 min)
   ```bash
   Read: APPWRITE_DATABASE_QUICKSTART.md
   # Follow step-by-step
   ```

4. **Test everything** (15 min)
   ```bash
   # Test authentication
   # Test database CRUD
   # Test file upload
   ```

### Option B: Thorough Setup (3-4 hours)

**If you want to understand everything:**

1. **Understand the changes** (15 min)
   ```bash
   Read: APPWRITE_DOCUMENTATION_UPDATE_SUMMARY.md
   ```

2. **Learn Appwrite features** (60 min)
   ```bash
   Read: APPWRITE_UPDATED_GUIDE.md
   # Take notes on important sections
   ```

3. **Update your project** (5 min)
   ```bash
   cd apps/mobile
   flutter pub get
   ```

4. **Follow the complete checklist** (2-3 hours)
   ```bash
   Read: APPWRITE_CONFIGURATION_CHECKLIST.md
   # Check off each item as you complete it
   ```

---

## ⚡ What's Already Done For You

You don't need to worry about these:

- ✅ **SDK Updated**: Appwrite SDK updated to v13.0.0
- ✅ **Documentation Created**: All guides are ready
- ✅ **Code Examples**: Complete examples provided
- ✅ **Troubleshooting**: Common issues documented
- ✅ **Checklists**: Step-by-step guides created
- ✅ **Security**: Best practices documented

---

## 🎯 What You Need to Do

### Step 1: Update Dependencies (5 minutes)

```bash
# Navigate to mobile app directory
cd apps/mobile

# Update dependencies
flutter pub get

# Verify no errors
flutter doctor
```

### Step 2: Configure Database (45-55 minutes)

1. **Go to Appwrite Console**
   - URL: https://cloud.appwrite.io
   - Project: rpi-communication
   - Project ID: 6904cfb1001e5253725b

2. **Follow the Quickstart Guide**
   - Open: [APPWRITE_DATABASE_QUICKSTART.md](APPWRITE_DATABASE_QUICKSTART.md)
   - Create database: `rpi_communication`
   - Create all 6 collections
   - Set up permissions
   - Create storage buckets

3. **Test Your Setup**
   - Test authentication
   - Test database operations
   - Test file upload

### Step 3: Deploy (optional)

Once everything works locally:
- Deploy to production
- Monitor for issues
- Celebrate! 🎉

---

## 🆘 Need Help?

### Common Issues

**Issue: "flutter: command not found"**
```bash
# Install Flutter: https://docs.flutter.dev/get-started/install
```

**Issue: "User (role: guests) missing scope"**
```
Solution: Make sure user is signed in
See: APPWRITE_UPDATED_GUIDE.md (Authentication section)
```

**Issue: "Document missing read/write permissions"**
```
Solution: Check permissions are set correctly
See: APPWRITE_DATABASE_QUICKSTART.md (Permissions section)
```

**Issue: "Invalid query"**
```
Solution: Use correct query syntax
See: APPWRITE_UPDATED_GUIDE.md (Queries section)
```

### Where to Get Help

1. **Documentation**
   - Check [APPWRITE_UPDATED_GUIDE.md](APPWRITE_UPDATED_GUIDE.md)
   - Review [APPWRITE_DATABASE_QUICKSTART.md](APPWRITE_DATABASE_QUICKSTART.md)
   - See troubleshooting in [APPWRITE_CONFIGURATION_CHECKLIST.md](APPWRITE_CONFIGURATION_CHECKLIST.md)

2. **Official Resources**
   - Appwrite Docs: https://appwrite.io/docs
   - Appwrite Discord: https://discord.com/invite/appwrite
   - Appwrite GitHub: https://github.com/appwrite/appwrite

3. **Project Support**
   - Open issue on GitHub
   - Check existing issues first

---

## 📊 Quick Reference

### Your Project Details

```
Project ID: 6904cfb1001e5253725b
API Endpoint: https://sgp.cloud.appwrite.io/v1
Region: Singapore (sgp)
Database ID: rpi_communication
```

### Required Collections

1. `users` - User profiles
2. `notices` - Announcements and notices
3. `messages` - Direct messages
4. `notifications` - User notifications
5. `books` - Library books
6. `book_borrows` - Borrow records

### Required Storage Buckets

1. `profile-images` - User profile pictures (5MB max)
2. `notice-attachments` - Notice files (10MB max)
3. `message-attachments` - Message files (25MB max)
4. `book-covers` - Book cover images (2MB max)
5. `book-files` - PDF books (100MB max)

---

## ✅ Success Checklist

Your setup is complete when:

- [ ] Dependencies updated (`flutter pub get` successful)
- [ ] Database created in Appwrite Console
- [ ] All 6 collections created with attributes
- [ ] All permissions configured
- [ ] All 5 storage buckets created
- [ ] Authentication tested and working
- [ ] Database CRUD tested and working
- [ ] File upload tested and working
- [ ] No permission errors
- [ ] App runs without errors

---

## 🎉 You're Ready!

Once you've completed the setup:

1. **Test thoroughly** - Make sure everything works
2. **Read about real-time** - Learn how to use subscriptions
3. **Explore functions** - Add serverless backend logic
4. **Deploy to production** - Share with users

**Remember:** The comprehensive guide ([APPWRITE_UPDATED_GUIDE.md](APPWRITE_UPDATED_GUIDE.md)) has everything you need. Refer to it whenever you're stuck!

---

## 📖 Documentation Index

| Document | Purpose | Time | When to Use |
|----------|---------|------|-------------|
| [APPWRITE_UPDATED_GUIDE.md](APPWRITE_UPDATED_GUIDE.md) | Comprehensive guide | 45 min | Learning features |
| [APPWRITE_DATABASE_QUICKSTART.md](APPWRITE_DATABASE_QUICKSTART.md) | Quick setup | 45 min | Setting up database |
| [APPWRITE_CONFIGURATION_CHECKLIST.md](APPWRITE_CONFIGURATION_CHECKLIST.md) | Complete checklist | Ongoing | Tracking progress |
| [APPWRITE_DOCUMENTATION_UPDATE_SUMMARY.md](APPWRITE_DOCUMENTATION_UPDATE_SUMMARY.md) | What changed | 10 min | Understanding updates |
| [APPWRITE_SETUP_INSTRUCTIONS.md](APPWRITE_SETUP_INSTRUCTIONS.md) | Project-specific | 30 min | Initial setup |
| [APPWRITE_COLLECTIONS_SCHEMA.md](APPWRITE_COLLECTIONS_SCHEMA.md) | Schema reference | Reference | Looking up schemas |

---

**Questions?** Check the documentation or open an issue!

**Ready to start?** → [APPWRITE_UPDATED_GUIDE.md](APPWRITE_UPDATED_GUIDE.md)

---

**Last Updated:** November 2025
