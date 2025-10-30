# Cloud Functions (Optional)

⚠️ **Note**: Cloud Functions are **NOT required** to run this application.

## Why are Cloud Functions optional?

This college communication app is designed to run entirely on **Firebase's free tier (Spark plan)**. Cloud Functions require a paid Blaze plan, so the mobile app has been refactored to:

- Use **direct Firestore operations** for all CRUD operations
- Implement **security via Firestore Security Rules** (free)
- Handle all business logic client-side with server-side validation

## What's in this directory?

This directory contains Cloud Functions that were originally used for:

1. **Admin Approval Workflow** (`adminApproval.ts`)
2. **Messaging** (`messaging.ts`) - Including push notifications
3. **Notice Management** (`notices.ts`)
4. **User Management** (`userManagement.ts`)
5. **Analytics** (`analytics.ts`)

## When would you need Cloud Functions?

Cloud Functions are useful if you need:

- **Scheduled tasks** (e.g., automatically expire old notices)
- **Complex server-side logic** that shouldn't be exposed to clients
- **Integration with external APIs** (e.g., payment processing, SMS)
- **Advanced push notifications** with complex targeting
- **Data aggregation** and background processing
- **Email sending** through SendGrid or similar services

## How to enable Cloud Functions (Optional)

If you want to use Cloud Functions and have a Firebase Blaze plan:

### 1. Upgrade Firebase Plan
```bash
# In Firebase Console
# Go to: Project Settings > Usage and Billing > Upgrade to Blaze
```

### 2. Install Dependencies
```bash
cd functions
npm install
```

### 3. Deploy Functions
```bash
firebase deploy --only functions
```

### 4. Update Mobile App
To use Cloud Functions instead of direct Firestore writes:

1. Add `cloud_functions` to `pubspec.yaml`:
   ```yaml
   dependencies:
     cloud_functions: ^4.3.3
   ```

2. Modify services to use `httpsCallable`:
   ```dart
   final callable = FirebaseFunctions.instance.httpsCallable('createNotice');
   final result = await callable.call(data);
   ```

## Current Architecture (Free Tier)

```
Mobile App → Firestore (direct read/write)
           ↓
    Security Rules (validation)
```

## With Cloud Functions (Paid Tier)

```
Mobile App → Cloud Functions → Firestore
                    ↓
           Additional logic, validation
           Push notifications
           External integrations
```

## Cost Comparison

### Free Tier (Current)
- **Cost**: $0/month
- **Firestore**: 50K reads, 20K writes per day (free)
- **Authentication**: Unlimited (free)
- **FCM**: Unlimited notifications (free)
- **Limitations**: No scheduled tasks, no complex server-side logic

### Blaze Plan (With Functions)
- **Cost**: Pay as you go (typically $5-20/month for small projects)
- **Firestore**: Same free tier, then $0.18 per 100K reads
- **Cloud Functions**: 2M invocations free, then $0.40 per million
- **Benefits**: Advanced features, scheduled tasks, external integrations

## Recommendation for College Projects

**Stay on Free Tier** unless you specifically need:
- Scheduled tasks (cron jobs)
- Complex business logic that must be hidden from clients
- Integration with paid external services

The current architecture is sufficient for:
- ✅ User authentication and profiles
- ✅ Real-time messaging
- ✅ Notice board / announcements
- ✅ Push notifications (with some manual setup)
- ✅ File uploads and downloads
- ✅ Role-based access control

## More Information

See [FREE_TIER_ARCHITECTURE.md](../FREE_TIER_ARCHITECTURE.md) for a complete guide on running this app without Cloud Functions.

## Support

If you need help deciding whether to use Cloud Functions:
- Open an issue: https://github.com/mufthakherul/college-communication-app/issues
- Check Firebase pricing: https://firebase.google.com/pricing
