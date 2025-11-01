# Release Notes - v2.0.0

## 🎉 RPI Communication App v2.0.0 - Major Update

**Release Date**: November 2024  
**Status**: Production Ready ✅

This is a major release that addresses all critical issues from v0.0.1 and introduces significant new features to improve campus communication.

---

## 🚨 Critical Fixes

### Release Build Crash - FIXED ✅
- **Issue**: App crashed immediately on startup in release mode
- **Fix**: Updated ProGuard rules, reduced optimization, fixed library configurations
- **Result**: Release builds now work perfectly on all devices

### Auto Logout - FIXED ✅  
- **Issue**: Users logged out every time they closed the app
- **Fix**: Verified Appwrite session persistence, added proper initialization
- **Result**: Users stay logged in until they explicitly log out

---

## ✨ New Features

### 1. Phone Number Requirement
- Phone number now required during signup
- Validation supports international formats
- Better contact information for all users

### 2. Email Verification
- Automatic verification email sent after registration
- Complete verification flow implemented
- Improves account security

### 3. Chat Creation
- **NEW**: Start conversations with any user
- Search users by name, email, or department  
- Real-time messaging with auto-scroll
- User role indicators (Student/Teacher/Admin)

### 4. Dual Notification System
- **Source 1**: Notifications from teachers/admin
- **Source 2**: Automated notices from school website
- Filter by source or view all together
- Auto-check website every 30 minutes

### 5. QR Code Generator
- **NEW**: Generate QR codes, not just scan them
- Share contact information
- Create custom text QR codes
- Generate device pairing codes for mesh networking

### 6. Improved Home Screen
- New QR options menu (scan or generate)
- Better navigation to all features

---

## 🔧 Technical Improvements

- Better error handling throughout
- Smart auto-scrolling in chats
- Batch operations for better performance
- Comprehensive documentation added
- All dependencies security-checked ✅

---

## 📱 How to Update

### For Users:
1. Download the new v2.0.0 APK
2. Uninstall the old version (v0.0.1)
3. Install v2.0.0
4. Log in (you may need to log in again after first install)

### For Developers:
```bash
git pull origin main
cd apps/mobile
flutter pub get
flutter build apk --release
```

---

## ⚠️ Known Limitations

1. **Mesh Networking**: Framework ready but needs full integration (coming in v2.1.0)
2. **Website Notices**: Basic implementation, will be enhanced with HTML parser
3. **Notifications**: Uses polling (realtime updates coming in v2.1.0)

---

## 🎯 What's Next (v2.1.0)

- Full mesh networking implementation
- Real-time notification updates
- Enhanced website notice parsing
- Push notifications via OneSignal
- Performance optimizations

---

## 📝 Upgrade Notes

### Breaking Changes:
- **None** - This is a backward-compatible update

### New Permissions Required:
- Phone number (required for new registrations)
- Email verification (automatic, no action needed)

### Data Migration:
- No migration needed
- Existing users can continue using the app
- New users must provide phone number

---

## 🐛 Bug Reports

Found a bug? Please report it:
- GitHub Issues: [github.com/mufthakherul/college-communication-app/issues](https://github.com/mufthakherul/college-communication-app/issues)

---

## 🙏 Credits

**Developed by**: Mufthakherul  
**For**: Rangpur Polytechnic Institute  
**Website**: [rangpur.polytech.gov.bd](https://rangpur.polytech.gov.bd)

---

## 📥 Download

Get v2.0.0:
- [GitHub Releases](https://github.com/mufthakherul/college-communication-app/releases/tag/v2.0.0)
- [Direct APK Download](https://github.com/mufthakherul/college-communication-app/releases/download/v2.0.0/app-release.apk)

---

**Thank you for using RPI Communication App!** 🎓

Your feedback helps us improve. Please rate the app and share your thoughts.
