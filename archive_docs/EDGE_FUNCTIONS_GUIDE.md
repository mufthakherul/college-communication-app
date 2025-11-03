# Supabase Edge Functions Guide

## Overview

This guide explains how to deploy and use Supabase Edge Functions that replace Firebase Cloud Functions in the RPI Communication App.

## Available Edge Functions

### 1. track-activity
Tracks user activity for analytics purposes.

**Endpoint:** `POST /functions/v1/track-activity`

**Request Body:**
```json
{
  "action": "view_notice",
  "metadata": {
    "noticeId": "uuid",
    "duration": 5000
  }
}
```

### 2. generate-analytics
Generates analytics reports (admin only).

**Endpoint:** `POST /functions/v1/generate-analytics`

**Request Body:**
```json
{
  "reportType": "user_activity",
  "startDate": "2024-01-01",
  "endDate": "2024-01-31"
}
```

**Report Types:**
- `user_activity` - User activity statistics
- `notices` - Notice creation and engagement stats
- `messages` - Messaging statistics

### 3. send-notification
Sends notifications to users (internal use).

**Endpoint:** `POST /functions/v1/send-notification`

## Deployment

### Prerequisites

1. Install Supabase CLI:
```bash
npm install -g supabase
```

2. Login to Supabase:
```bash
supabase login
```

3. Link your project:
```bash
supabase link --project-ref YOUR_PROJECT_REF
```

### Deploy Functions

Deploy all functions:
```bash
cd /path/to/college-communication-app
supabase functions deploy
```

Deploy a specific function:
```bash
supabase functions deploy track-activity
supabase functions deploy generate-analytics
supabase functions deploy send-notification
```

### Set Environment Variables

Edge Functions need environment secrets:

```bash
# Set Supabase URL
supabase secrets set SUPABASE_URL=https://your-project.supabase.co

# Set service role key (for admin operations)
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

## Testing Functions

### Using curl

Test track-activity:
```bash
curl -X POST https://your-project.supabase.co/functions/v1/track-activity \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"action": "view_notice", "metadata": {"noticeId": "123"}}'
```

Test generate-analytics:
```bash
curl -X POST https://your-project.supabase.co/functions/v1/generate-analytics \
  -H "Authorization: Bearer YOUR_USER_JWT" \
  -H "Content-Type: application/json" \
  -d '{"reportType": "user_activity", "startDate": "2024-01-01", "endDate": "2024-01-31"}'
```

### Using Supabase Client (Flutter)

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

// Track activity
Future<void> trackActivity(String action, Map<String, dynamic> metadata) async {
  final response = await Supabase.instance.client.functions.invoke(
    'track-activity',
    body: {
      'action': action,
      'metadata': metadata,
    },
  );
  
  if (response.status != 200) {
    throw Exception('Failed to track activity');
  }
}

// Generate analytics report
Future<Map<String, dynamic>> generateAnalytics(
  String reportType,
  String startDate,
  String endDate,
) async {
  final response = await Supabase.instance.client.functions.invoke(
    'generate-analytics',
    body: {
      'reportType': reportType,
      'startDate': startDate,
      'endDate': endDate,
    },
  );
  
  if (response.status != 200) {
    throw Exception('Failed to generate analytics');
  }
  
  return response.data as Map<String, dynamic>;
}
```

## Monitoring

### View Logs

Check function logs in real-time:
```bash
supabase functions logs track-activity
```

View all function logs:
```bash
supabase functions logs
```

### Dashboard Monitoring

Monitor function invocations, errors, and performance in the Supabase Dashboard:
1. Go to `Edge Functions` section
2. Select a function
3. View metrics and logs

## Cost Considerations

**Free Tier:**
- 500,000 invocations per month
- 2 million function execution seconds
- No cold start charges

**Beyond Free Tier:**
- $2 per 1 million additional invocations
- Very generous for college use case

## Security

### Authentication

All functions check for authenticated users:
```typescript
const { data: { user } } = await supabaseClient.auth.getUser()
if (!user) {
  return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 })
}
```

### Authorization

Admin-only functions verify user role:
```typescript
const { data: userData } = await supabaseClient
  .from('users')
  .select('role')
  .eq('id', user.id)
  .single()

if (userData.role !== 'admin') {
  return new Response(JSON.stringify({ error: 'Forbidden' }), { status: 403 })
}
```

### CORS

Functions include CORS headers for web access:
```typescript
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}
```

## Troubleshooting

### Function Not Found
- Ensure function is deployed: `supabase functions list`
- Check project reference is correct
- Verify you're using correct URL

### Authentication Errors
- Verify JWT token is valid
- Check Authorization header format: `Bearer <token>`
- Ensure user session hasn't expired

### Permission Denied
- Verify user has correct role (admin for analytics)
- Check RLS policies on database tables
- Ensure service role key is set for admin operations

### Timeout Errors
- Edge Functions have 150-second timeout
- Optimize queries for large datasets
- Consider pagination for large reports

## Best Practices

1. **Error Handling:** Always wrap operations in try-catch blocks
2. **Logging:** Use `console.log()` for debugging (visible in logs)
3. **Performance:** Minimize database queries, use batch operations
4. **Security:** Never expose service role key, use RLS policies
5. **Testing:** Test locally before deploying to production

## Local Development

Run functions locally for development:

```bash
# Start local Supabase
supabase start

# Serve functions locally
supabase functions serve track-activity --no-verify-jwt

# Test locally
curl -X POST http://localhost:54321/functions/v1/track-activity \
  -H "Content-Type: application/json" \
  -d '{"action": "test", "metadata": {}}'
```

## Migration from Firebase

### Key Differences

| Firebase Cloud Functions | Supabase Edge Functions |
|--------------------------|-------------------------|
| Node.js/TypeScript | Deno/TypeScript |
| `functions.https.onCall` | HTTP endpoints |
| Firebase Admin SDK | Supabase Client |
| Complex deployment | Simple CLI deployment |

### Code Comparison

**Before (Firebase):**
```typescript
export const trackActivity = functions.https.onCall(async (data, context) => {
  if (!context.auth) throw new HttpsError('unauthenticated', 'Not authenticated')
  await admin.firestore().collection('activity').add({...})
})
```

**After (Supabase):**
```typescript
serve(async (req) => {
  const { data: { user } } = await client.auth.getUser()
  if (!user) return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 })
  await client.from('activity').insert({...})
})
```

## Support

- [Supabase Edge Functions Documentation](https://supabase.com/docs/guides/functions)
- [Deno Documentation](https://deno.land/manual)
- [GitHub Issues](https://github.com/mufthakherul/college-communication-app/issues)
