# Configuration Guide

## Overview

This guide covers how to configure Sentry crash reporting, OneSignal push notifications, automated backups, and scheduled cleanup jobs.

---

## 1. Sentry Configuration (Crash Reporting)

### Step 1: Create Sentry Account

1. Go to [sentry.io](https://sentry.io)
2. Sign up for free account (10,000 errors/month free)
3. Create new project:
   - Platform: Flutter
   - Project name: `rpi-communication-app`

### Step 2: Get DSN

1. Go to **Settings** → **Projects** → **rpi-communication-app**
2. Click **Client Keys (DSN)**
3. Copy the DSN (looks like: `https://xxxxx@xxxxx.ingest.sentry.io/xxxxx`)

### Step 3: Configure in App

**Option A: Using Environment Variables (Recommended)**

Run the app with:
```bash
flutter run --dart-define=SENTRY_DSN=https://your-dsn@sentry.io/project-id
```

Build APK with:
```bash
flutter build apk --dart-define=SENTRY_DSN=https://your-dsn@sentry.io/project-id
```

**Option B: Update supabase_config.dart**

Add to `apps/mobile/lib/supabase_config.dart`:
```dart
class SupabaseConfig {
  // Existing config...
  
  // Sentry configuration
  static const String sentryDsn = 'https://your-dsn@sentry.io/project-id';
}
```

Then update `main.dart`:
```dart
if (SupabaseConfig.sentryDsn.isNotEmpty) {
  await SentryService.initialize(
    dsn: SupabaseConfig.sentryDsn,
    // ...
  );
}
```

### Step 4: Test Sentry Integration

Add test code to trigger an error:
```dart
// In any screen, add a test button
ElevatedButton(
  onPressed: () {
    throw Exception('Test error for Sentry');
  },
  child: Text('Test Sentry'),
)
```

Run the app, press the button, and check Sentry dashboard for the error.

### Step 5: Configure User Context

Update auth service to set user context:
```dart
// In auth_service.dart, after successful login
import 'package:campus_mesh/services/sentry_service.dart';

final sentryService = SentryService();
sentryService.setUser(
  id: user.id,
  email: user.email,
  username: user.displayName,
  data: {
    'role': user.role,
  },
);

// After logout
sentryService.clearUser();
```

### Step 6: Configure Performance Monitoring

Wrap critical operations:
```dart
final sentryService = SentryService();

// Measure database query
final notices = await sentryService.measurePerformance(
  'database_query',
  'Load notices',
  () async => await noticeService.getNotices(),
);

// Measure screen load
final transaction = sentryService.startTransaction(
  'screen_load',
  'Load notices screen',
);
try {
  await loadData();
  transaction.status = SpanStatus.ok();
} catch (e) {
  transaction.status = SpanStatus.internalError();
  rethrow;
} finally {
  await transaction.finish();
}
```

### Sentry Best Practices

1. **Filter sensitive data**: Use `beforeSend` to remove sensitive info
2. **Set proper environments**: Use 'production', 'staging', 'development'
3. **Add breadcrumbs**: Track user actions before errors
4. **Set release versions**: Track errors by app version
5. **Monitor performance**: Use transactions for critical operations

---

## 2. OneSignal Configuration (Push Notifications)

### Step 1: Create OneSignal Account

1. Go to [onesignal.com](https://onesignal.com)
2. Sign up for free account (10,000 subscribers free)
3. Create new app:
   - Name: RPI Communication App
   - Platform: Flutter (configure Android & iOS)

### Step 2: Configure Android

1. In OneSignal dashboard, select your app
2. Go to **Settings** → **Platforms** → **Google Android (FCM)**
3. Follow instructions to:
   - Create Firebase project (if not exists)
   - Add Firebase configuration to Android app
   - Get Server Key and Sender ID
   - Enter in OneSignal

### Step 3: Configure iOS (Optional)

1. Follow OneSignal's iOS setup guide
2. Configure APNs certificates
3. Update iOS project settings

### Step 4: Get App ID

1. Go to **Settings** → **Keys & IDs**
2. Copy the OneSignal App ID

### Step 5: Configure in App

**Option A: Using Environment Variables (Recommended)**

```bash
flutter run --dart-define=ONESIGNAL_APP_ID=your-app-id
```

**Option B: Update supabase_config.dart**

Add to `apps/mobile/lib/supabase_config.dart`:
```dart
class SupabaseConfig {
  // Existing config...
  
  // OneSignal configuration
  static const String oneSignalAppId = 'your-onesignal-app-id';
}
```

Update `main.dart`:
```dart
if (SupabaseConfig.oneSignalAppId.isNotEmpty) {
  await OneSignalService().initialize(SupabaseConfig.oneSignalAppId);
}
```

### Step 6: Test Push Notifications

**Send test notification from OneSignal dashboard:**

1. Go to **Messages** → **New Push**
2. Select **Send to Test Users**
3. Enter your device's Player ID
4. Send notification

**Get Player ID:**
```dart
final playerId = OneSignalService().getPlayerId();
print('Player ID: $playerId');
```

### Step 7: Integrate with Auth

```dart
// In auth_service.dart, after login
import 'package:campus_mesh/services/onesignal_service.dart';

final oneSignalService = OneSignalService();
await oneSignalService.loginUser(
  user.id,
  email: user.email,
);

// Set user tags
await oneSignalService.setUserTags({
  'role': user.role,
  'department': user.department ?? '',
});

// After logout
await oneSignalService.logoutUser();
```

### Step 8: Send Notifications from Edge Function

Create Edge Function to send notifications:

```typescript
// supabase/functions/send-push-notification/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const ONESIGNAL_APP_ID = Deno.env.get('ONESIGNAL_APP_ID')
const ONESIGNAL_REST_API_KEY = Deno.env.get('ONESIGNAL_REST_API_KEY')

serve(async (req) => {
  const { userIds, title, message, data } = await req.json()
  
  const response = await fetch('https://onesignal.com/api/v1/notifications', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Basic ${ONESIGNAL_REST_API_KEY}`,
    },
    body: JSON.stringify({
      app_id: ONESIGNAL_APP_ID,
      include_external_user_ids: userIds,
      headings: { en: title },
      contents: { en: message },
      data: data,
    }),
  })
  
  return new Response(JSON.stringify(await response.json()))
})
```

Deploy and set secrets:
```bash
supabase functions deploy send-push-notification
supabase secrets set ONESIGNAL_APP_ID=your-app-id
supabase secrets set ONESIGNAL_REST_API_KEY=your-rest-api-key
```

### OneSignal Best Practices

1. **Segment users**: Use tags for targeted notifications
2. **Schedule wisely**: Don't send late at night
3. **Keep it brief**: Short, actionable messages
4. **Deep linking**: Navigate to relevant content
5. **Test thoroughly**: Always test before mass sending

---

## 3. Automated Backups

### Step 1: Setup Prerequisites

1. **Get Supabase credentials:**
   - Project reference (from URL)
   - Database password (from project settings)

2. **Install PostgreSQL client:**
   ```bash
   # Ubuntu/Debian
   sudo apt-get install postgresql-client
   
   # macOS
   brew install postgresql
   ```

### Step 2: Configure GitHub Secrets

Go to **Settings** → **Secrets and variables** → **Actions**

Add these secrets:
- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_SERVICE_KEY`: Service role key (from API settings)
- `SUPABASE_PROJECT_REF`: Project reference ID
- `SUPABASE_DB_PASSWORD`: Database password

### Step 3: Test Backup Script Locally

```bash
# Set environment variables
export SUPABASE_PROJECT_REF=your-project-ref
export SUPABASE_DB_PASSWORD=your-password
export BACKUP_DIR=./backups

# Run backup
./scripts/backup/backup_database.sh
```

### Step 4: Enable Automated Backups

The GitHub Action workflow `automated-backup.yml` runs daily at 3 AM UTC.

**To run manually:**
1. Go to **Actions** tab
2. Select **Automated Database Backup**
3. Click **Run workflow**

**To change schedule:**
Edit `.github/workflows/automated-backup.yml`:
```yaml
on:
  schedule:
    - cron: '0 3 * * *'  # Daily at 3 AM UTC
    # Change to: '0 */6 * * *' for every 6 hours
    # Or: '0 0 * * 0' for weekly on Sunday
```

### Step 5: Access Backups

Backups are stored as GitHub Actions artifacts:
1. Go to **Actions** tab
2. Click on a successful backup run
3. Download **database-backup-N** artifact
4. Extract the `.gz` file

Backups are retained for 30 days.

### Step 6: Restore from Backup

```bash
# Extract backup
gunzip supabase_backup_YYYYMMDD_HHMMSS.sql.gz

# Restore to Supabase
psql -h db.your-project.supabase.co \
     -p 5432 \
     -U postgres \
     -d postgres \
     -f supabase_backup_YYYYMMDD_HHMMSS.sql
```

---

## 4. Scheduled Cleanup Jobs

### Step 1: Configure GitHub Secrets

Same secrets as backups (already done if you configured backups).

### Step 2: Enable Database Maintenance

The GitHub Action workflow `database-maintenance.yml` runs daily at 2 AM UTC.

**What it does:**
- Cleans user activity older than 90 days
- Deactivates expired notices
- Removes read messages older than 30 days
- Refreshes materialized views

**To run manually:**
1. Go to **Actions** tab
2. Select **Database Maintenance**
3. Click **Run workflow**

**To change schedule:**
Edit `.github/workflows/database-maintenance.yml`:
```yaml
on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM UTC
```

### Step 3: Monitor Cleanup Jobs

Check the Actions tab for:
- ✅ Successful runs (green checkmark)
- ❌ Failed runs (red X)
- 📊 Execution logs

### Step 4: Customize Retention Periods

Edit `infra/supabase_advanced_features.sql`:

```sql
-- Change from 90 days to 60 days
DELETE FROM public.user_activity
WHERE created_at < NOW() - INTERVAL '60 days';

-- Change from 30 days to 14 days
DELETE FROM public.messages
WHERE read = true 
  AND read_at < NOW() - INTERVAL '14 days';
```

Re-run the SQL script in Supabase dashboard.

---

## 5. Environment Variables Summary

### Required for Production

```bash
# Supabase (always required)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# Sentry (optional but recommended)
SENTRY_DSN=https://xxxxx@xxxxx.ingest.sentry.io/xxxxx

# OneSignal (optional but recommended)
ONESIGNAL_APP_ID=your-onesignal-app-id

# GitHub Actions only
SUPABASE_SERVICE_KEY=your-service-role-key
SUPABASE_PROJECT_REF=your-project-ref
SUPABASE_DB_PASSWORD=your-db-password
ONESIGNAL_REST_API_KEY=your-rest-api-key
```

### Build Commands

**Development:**
```bash
flutter run \
  --dart-define=SENTRY_DSN=$SENTRY_DSN \
  --dart-define=ONESIGNAL_APP_ID=$ONESIGNAL_APP_ID
```

**Production APK:**
```bash
flutter build apk --release \
  --dart-define=SENTRY_DSN=$SENTRY_DSN \
  --dart-define=ONESIGNAL_APP_ID=$ONESIGNAL_APP_ID
```

---

## 6. Verification Checklist

### Sentry
- [ ] Account created
- [ ] Project configured
- [ ] DSN obtained
- [ ] App configured
- [ ] Test error sent
- [ ] Error appears in dashboard
- [ ] User context set
- [ ] Performance monitoring working

### OneSignal
- [ ] Account created
- [ ] App configured (Android/iOS)
- [ ] App ID obtained
- [ ] App configured
- [ ] Test notification sent
- [ ] Notification received
- [ ] User login/logout working
- [ ] Tags set correctly

### Automated Backups
- [ ] GitHub secrets configured
- [ ] Backup script tested locally
- [ ] GitHub Action enabled
- [ ] Manual run successful
- [ ] Backup artifact downloaded
- [ ] Restore process tested

### Cleanup Jobs
- [ ] GitHub secrets configured
- [ ] Cleanup functions exist in DB
- [ ] GitHub Action enabled
- [ ] Manual run successful
- [ ] Logs reviewed
- [ ] Data cleaned appropriately

---

## 7. Troubleshooting

### Sentry Not Working

**Issue**: Errors not appearing in Sentry
- Check DSN is correct
- Verify app is rebuilt with DSN
- Check internet connection
- Review beforeSend filter
- Check Sentry quota (10K errors/month free)

### OneSignal Not Working

**Issue**: Notifications not received
- Verify App ID is correct
- Check permissions granted
- Test with OneSignal dashboard
- Review device logs
- Confirm Firebase setup (Android)

### Backup Failing

**Issue**: GitHub Action fails
- Check all secrets are set
- Verify database password
- Review action logs
- Test script locally
- Check network/firewall

### Cleanup Not Running

**Issue**: Old data not being cleaned
- Verify secrets are set
- Check function exists in DB
- Review action logs
- Test function manually in Supabase
- Check service role key permissions

---

## Support

For configuration issues:
1. Review this guide
2. Check service dashboards
3. Review GitHub Action logs
4. Check Supabase logs
5. Open GitHub issue

---

## Resources

- [Sentry Flutter Setup](https://docs.sentry.io/platforms/flutter/)
- [OneSignal Flutter Setup](https://documentation.onesignal.com/docs/flutter-sdk-setup)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Supabase Database Backups](https://supabase.com/docs/guides/platform/backups)
