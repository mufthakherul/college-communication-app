# Testing Guide

## Overview

This guide covers manual testing, load testing, and user acceptance testing (UAT) for the RPI Communication App.

---

## Manual Testing Checklist

### 1. Authentication Testing

#### Sign Up
- [ ] New user can register with email and password
- [ ] User profile is created in database
- [ ] Email validation works
- [ ] Password strength requirements enforced
- [ ] User receives proper error messages for invalid inputs
- [ ] Sentry captures any errors during registration

#### Sign In
- [ ] User can log in with valid credentials
- [ ] Invalid credentials show appropriate error
- [ ] Session persists across app restarts
- [ ] OneSignal user ID is set after login

#### Password Reset
- [ ] User can request password reset
- [ ] Reset email is received
- [ ] Password can be successfully reset

#### Sign Out
- [ ] User can sign out
- [ ] Session is cleared
- [ ] OneSignal user is logged out

### 2. Notice Management Testing

#### Create Notice (Teacher/Admin)
- [ ] Teachers and admins can create notices
- [ ] Students cannot create notices (RLS enforcement)
- [ ] All required fields are validated
- [ ] Notice appears in real-time for other users
- [ ] Notifications are sent to target audience
- [ ] Analytics tracks notice creation

#### View Notices
- [ ] Users can view all active notices
- [ ] Real-time updates work correctly
- [ ] Notices are sorted by date
- [ ] Notice filtering by type works
- [ ] Performance monitoring tracks load time

#### Search Notices
- [ ] Full-text search returns relevant results
- [ ] Search results are ranked by relevance
- [ ] Search suggestions appear as user types
- [ ] Search is fast (<100ms)

#### Update Notice
- [ ] Authors can update their notices
- [ ] Admins can update any notice
- [ ] Non-authors cannot update (RLS enforcement)
- [ ] Updated timestamp is correct

#### Delete Notice
- [ ] Authors can delete (deactivate) notices
- [ ] Deleted notices don't appear in lists
- [ ] Data is not permanently deleted (soft delete)

### 3. Messaging Testing

#### Send Message
- [ ] Users can send text messages
- [ ] Messages appear in real-time
- [ ] Sender and recipient see message
- [ ] Performance monitoring tracks send time

#### View Messages
- [ ] Users can view conversation history
- [ ] Messages are sorted chronologically
- [ ] Real-time updates work
- [ ] Only sender and recipient can view (RLS)

#### Read Status
- [ ] Messages marked as read correctly
- [ ] Read status updates in real-time
- [ ] Read timestamp is recorded

#### Unread Count
- [ ] Unread message count is accurate
- [ ] Count updates in real-time

### 4. Notification Testing

#### Receive Notifications
- [ ] Users receive push notifications (if OneSignal configured)
- [ ] In-app notifications appear
- [ ] Notification content is correct
- [ ] Notification data includes relevant info

#### View Notifications
- [ ] Users can view notification list
- [ ] Notifications are sorted by date
- [ ] Unread count is accurate

#### Mark as Read
- [ ] Single notification can be marked as read
- [ ] All notifications can be marked as read
- [ ] Read status persists

### 5. Analytics Testing

#### Activity Tracking
- [ ] Screen views are tracked
- [ ] Notice views are tracked
- [ ] Feature usage is tracked
- [ ] Analytics data appears in database

#### Admin Reports (Admin Only)
- [ ] User activity report generates correctly
- [ ] Notice report shows accurate stats
- [ ] Message report shows accurate stats
- [ ] Reports are generated quickly (<5s)

#### Analytics Views
- [ ] Daily active users view works
- [ ] Notice engagement view works
- [ ] Message statistics view works
- [ ] User engagement summary works

### 6. Search Testing

#### Full-Text Search
- [ ] Search returns relevant notices
- [ ] Results are ranked by relevance
- [ ] Search handles special characters
- [ ] Search handles multiple words
- [ ] Search is fast (<100ms)

#### Search Suggestions
- [ ] Suggestions appear as user types
- [ ] Suggestions are relevant
- [ ] Clicking suggestion searches

### 7. Performance Monitoring Testing

#### Operation Tracking
- [ ] Slow operations are detected (>1000ms)
- [ ] Performance stats are collected
- [ ] Statistics can be viewed
- [ ] Analytics integration works

### 8. Error Tracking Testing (If Sentry Configured)

#### Error Capture
- [ ] Errors are sent to Sentry
- [ ] Stack traces are included
- [ ] User context is attached
- [ ] Breadcrumbs provide context

#### Performance Monitoring
- [ ] Transactions are tracked
- [ ] Slow operations are detected
- [ ] Performance data appears in Sentry

### 9. Offline Mode Testing

#### Queue Actions
- [ ] Actions are queued when offline
- [ ] Queue persists across app restarts
- [ ] Actions execute when online
- [ ] Failed actions are retried

#### Cache
- [ ] Data is cached appropriately
- [ ] Cache serves data when offline
- [ ] Cache is refreshed when online

### 10. UI/UX Testing

#### Dark Mode
- [ ] Dark mode toggle works
- [ ] Preference is saved
- [ ] All screens support dark mode

#### Navigation
- [ ] All navigation flows work
- [ ] Back button behavior is correct
- [ ] Deep links work (if configured)

#### Responsiveness
- [ ] App works on various screen sizes
- [ ] UI elements are properly sized
- [ ] Text is readable

---

## Load Testing

### Prerequisites

- Install k6: https://k6.io/docs/getting-started/installation/
- Install Supabase CLI: `npm install -g supabase`

### 1. Database Load Test

Test PostgreSQL query performance under load.

```javascript
// load-test-db.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 20 },  // Ramp up to 20 users
    { duration: '1m', target: 20 },   // Stay at 20 users
    { duration: '30s', target: 50 },  // Ramp up to 50 users
    { duration: '1m', target: 50 },   // Stay at 50 users
    { duration: '30s', target: 0 },   // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests under 500ms
    http_req_failed: ['rate<0.01'],   // Less than 1% failure rate
  },
};

const SUPABASE_URL = __ENV.SUPABASE_URL;
const SUPABASE_ANON_KEY = __ENV.SUPABASE_ANON_KEY;

export default function () {
  // Test: Get notices
  const noticesRes = http.get(
    `${SUPABASE_URL}/rest/v1/notices?is_active=eq.true&order=created_at.desc&limit=20`,
    {
      headers: {
        apikey: SUPABASE_ANON_KEY,
        Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
      },
    }
  );

  check(noticesRes, {
    'notices loaded': (r) => r.status === 200,
    'response time OK': (r) => r.timings.duration < 500,
  });

  sleep(1);
}
```

Run the test:
```bash
SUPABASE_URL=https://your-project.supabase.co \
SUPABASE_ANON_KEY=your-anon-key \
k6 run load-test-db.js
```

### 2. Edge Function Load Test

Test Edge Functions under load.

```javascript
// load-test-functions.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 10 },
    { duration: '1m', target: 10 },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000'], // 95% under 2s
    http_req_failed: ['rate<0.05'],    // Less than 5% failure
  },
};

const SUPABASE_URL = __ENV.SUPABASE_URL;
const SUPABASE_ANON_KEY = __ENV.SUPABASE_ANON_KEY;
const USER_TOKEN = __ENV.USER_TOKEN; // Get from authenticated user

export default function () {
  // Test: Track activity
  const activityRes = http.post(
    `${SUPABASE_URL}/functions/v1/track-activity`,
    JSON.stringify({
      action: 'load_test',
      metadata: { test: true },
    }),
    {
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${USER_TOKEN}`,
      },
    }
  );

  check(activityRes, {
    'activity tracked': (r) => r.status === 200,
  });

  sleep(2);
}
```

### 3. Search Performance Test

Test full-text search performance.

```javascript
// load-test-search.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 30 },
    { duration: '1m', target: 30 },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<200'], // 95% under 200ms
  },
};

const SUPABASE_URL = __ENV.SUPABASE_URL;
const SUPABASE_ANON_KEY = __ENV.SUPABASE_ANON_KEY;

const searchTerms = ['exam', 'schedule', 'assignment', 'meeting', 'event'];

export default function () {
  const term = searchTerms[Math.floor(Math.random() * searchTerms.length)];

  const searchRes = http.post(
    `${SUPABASE_URL}/rest/v1/rpc/search_notices`,
    JSON.stringify({ search_query: term }),
    {
      headers: {
        'Content-Type': 'application/json',
        apikey: SUPABASE_ANON_KEY,
        Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
      },
    }
  );

  check(searchRes, {
    'search completed': (r) => r.status === 200,
    'search fast': (r) => r.timings.duration < 200,
  });

  sleep(1);
}
```

### Load Test Results Interpretation

- **Good Performance**: P95 < 500ms, <1% errors
- **Acceptable**: P95 < 1000ms, <5% errors
- **Needs Optimization**: P95 > 1000ms, >5% errors

---

## User Acceptance Testing (UAT)

### UAT Preparation

1. **Setup Test Environment**
   - Deploy to staging/test Supabase project
   - Configure test data
   - Create test user accounts

2. **Create Test Scenarios**
   - Write realistic user scenarios
   - Include edge cases
   - Document expected outcomes

3. **Recruit Testers**
   - 3-5 students
   - 2-3 teachers
   - 1-2 admins

### UAT Test Scenarios

#### Scenario 1: Student Views Notices
**As a student, I want to view course notices**

Steps:
1. Log in as student
2. Navigate to Notices screen
3. Browse available notices
4. Filter by notice type
5. Search for specific notice
6. View notice details

Expected:
- All steps complete without errors
- Notices load quickly (<2s)
- Search works intuitively
- UI is clear and easy to use

#### Scenario 2: Teacher Creates Notice
**As a teacher, I want to post an assignment notice**

Steps:
1. Log in as teacher
2. Navigate to Create Notice
3. Fill in notice details
4. Select target audience (students)
5. Submit notice
6. Verify notice appears

Expected:
- Form is intuitive
- Validation works correctly
- Notice created successfully
- Students receive notification

#### Scenario 3: Student Messages Teacher
**As a student, I want to ask a question via messaging**

Steps:
1. Log in as student
2. Navigate to Messages
3. Start new conversation with teacher
4. Send message
5. Wait for response

Expected:
- Easy to find teacher
- Message sends immediately
- Real-time updates work
- Read status shows

#### Scenario 4: Admin Views Analytics
**As an admin, I want to see usage statistics**

Steps:
1. Log in as admin
2. Navigate to Analytics
3. Generate user activity report
4. View notice engagement
5. Check message statistics

Expected:
- Reports generate quickly
- Data is accurate
- Visualizations are clear
- Can export data

### UAT Feedback Collection

Use this template:

```markdown
## UAT Feedback Form

**Tester Name:** _______________
**Role:** [ ] Student [ ] Teacher [ ] Admin
**Date:** _______________

### Scenario: _______________

**Completion Status:** [ ] Completed [ ] Partial [ ] Failed

**Ease of Use (1-5):** ___
**Performance (1-5):** ___
**UI/UX (1-5):** ___

**What worked well:**
- 
- 

**What needs improvement:**
- 
- 

**Bugs/Issues Found:**
- 
- 

**Additional Comments:**


**Would you use this app?** [ ] Yes [ ] No [ ] Maybe
```

### UAT Success Criteria

- [ ] 80%+ scenarios completed successfully
- [ ] Average satisfaction score >4/5
- [ ] No critical bugs found
- [ ] Performance acceptable (P95 <2s)
- [ ] 90%+ testers would use the app

---

## Automated Testing

### Unit Tests

Run unit tests:
```bash
cd apps/mobile
flutter test
```

### Widget Tests

Run widget tests:
```bash
flutter test test/widgets/
```

### Integration Tests

Run integration tests:
```bash
flutter test integration_test/
```

---

## Performance Benchmarks

### Target Metrics

| Operation | Target | Warning | Critical |
|-----------|--------|---------|----------|
| App Launch | <2s | <3s | >3s |
| Notice Load | <500ms | <1s | >1s |
| Search | <100ms | <200ms | >200ms |
| Message Send | <300ms | <500ms | >500ms |
| Analytics Report | <2s | <5s | >5s |

### Monitoring

1. **Real-Time Monitoring**
   - Use `PerformanceMonitoringService`
   - Check Supabase Dashboard
   - Monitor Sentry (if configured)

2. **Weekly Review**
   - Check slow query logs
   - Review error rates
   - Analyze user feedback

3. **Monthly Audit**
   - Full load testing
   - Security audit
   - Performance optimization

---

## Troubleshooting

### Common Issues

**Issue: Slow queries**
- Check database indexes
- Review RLS policies
- Optimize materialized views

**Issue: High error rate**
- Check Sentry dashboard
- Review recent deployments
- Check Supabase status

**Issue: Poor performance**
- Run performance profiling
- Check network latency
- Review caching strategy

**Issue: Test failures**
- Verify test data
- Check environment variables
- Review test isolation

---

## Continuous Testing

### CI/CD Integration

Tests run automatically on:
- Pull requests
- Commits to main branch
- Scheduled daily

### Test Coverage Goals

- Unit tests: >80% coverage
- Widget tests: Critical UI components
- Integration tests: Core user flows
- Load tests: Monthly

---

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [k6 Load Testing](https://k6.io/docs/)
- [Supabase Testing](https://supabase.com/docs/guides/getting-started/testing)
- [Sentry Testing](https://docs.sentry.io/platforms/flutter/usage/advanced-usage/#testing)

---

## Support

For testing issues or questions:
1. Check this guide
2. Review test logs
3. Check Supabase/Sentry dashboards
4. Open GitHub issue
