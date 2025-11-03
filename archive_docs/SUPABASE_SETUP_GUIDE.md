# Supabase Setup Guide for RPI Communication App

## 🚀 Connecting Your App to Supabase

The app has been migrated from Firebase to Supabase to eliminate costs. This guide will walk you through the setup process.

## Why Supabase?

Supabase provides similar features to Firebase but with a generous free tier that includes:
- **Authentication** - 50,000 monthly active users (free forever)
- **PostgreSQL Database** - 500 MB database (free forever)
- **Storage** - 1 GB file storage (free forever)
- **Edge Functions** - 500,000 invocations/month (free forever)
- **Real-time subscriptions** - Unlimited connections on free tier

## 📋 Prerequisites

Before starting, you'll need:
- A Supabase account (sign up at https://supabase.com)
- Flutter installed (for running the mobile app)
- Basic understanding of SQL (for database setup)

## 🚀 Step-by-Step Setup

### Step 1: Create Supabase Project

1. **Go to Supabase Dashboard:**
   - Visit: https://app.supabase.com
   - Sign in with your GitHub account or email

2. **Create a New Project:**
   - Click "New project"
   - Organization: Select or create an organization
   - Project name: `rpi-communication` (or your preferred name)
   - Database password: Create a strong password (save it!)
   - Region: Choose the closest region to your users
   - Click "Create new project"
   - Wait for project creation (~2 minutes)

### Step 2: Set Up Database Schema

1. **Open SQL Editor:**
   - In your Supabase dashboard, click "SQL Editor" in the left sidebar
   - Click "New query"

2. **Run Schema SQL:**
   - Open the file `infra/supabase_schema.sql` from this repository
   - Copy all the SQL code
   - Paste it into the Supabase SQL editor
   - Click "Run" or press `Ctrl+Enter`
   - Wait for completion message

3. **Run RLS Policies:**
   - Create a new query in SQL Editor
   - Open the file `infra/supabase_rls_policies.sql` from this repository
   - Copy all the SQL code
   - Paste it into the Supabase SQL editor
   - Click "Run" or press `Ctrl+Enter`
   - Wait for completion message

### Step 3: Configure Storage Buckets

1. **Create Storage Buckets:**
   - In your Supabase dashboard, click "Storage" in the left sidebar
   - Click "Create bucket"
   - Create three buckets:
     - Name: `profile-images`, Public: Yes
     - Name: `notice-attachments`, Public: Yes
     - Name: `message-attachments`, Public: No

2. **Set Storage Policies:**
   For each bucket, click on it and go to "Policies" tab:
   
   **For profile-images:**
   ```sql
   -- Allow authenticated users to upload their own profile image
   CREATE POLICY "Users can upload profile images"
   ON storage.objects FOR INSERT
   WITH CHECK (auth.uid()::text = (storage.foldername(name))[1]);
   
   -- Allow public read access
   CREATE POLICY "Public can view profile images"
   ON storage.objects FOR SELECT
   USING (bucket_id = 'profile-images');
   ```

   **For notice-attachments:**
   ```sql
   -- Allow teachers and admins to upload
   CREATE POLICY "Teachers and admins can upload notice attachments"
   ON storage.objects FOR INSERT
   WITH CHECK (auth.uid() IS NOT NULL);
   
   -- Allow authenticated users to view
   CREATE POLICY "Authenticated users can view notice attachments"
   ON storage.objects FOR SELECT
   USING (auth.uid() IS NOT NULL);
   ```

### Step 4: Get Your Supabase Credentials

1. **Get API Keys:**
   - In your Supabase dashboard, click "Settings" (gear icon)
   - Click "API" in the left sidebar
   - You'll see:
     - **Project URL** (e.g., `https://xxxxx.supabase.co`)
     - **anon public** key (starts with `eyJ...`)

2. **Update App Configuration:**
   - Open `apps/mobile/lib/supabase_config.dart`
   - Replace the placeholder values:
     ```dart
     static const String supabaseUrl = 'YOUR_PROJECT_URL';
     static const String supabaseAnonKey = 'YOUR_ANON_KEY';
     ```

### Step 5: Set Up Authentication

1. **Configure Email Auth:**
   - In Supabase dashboard, go to "Authentication"
   - Click "Settings" → "Email Auth"
   - Enable "Enable email confirmations" (recommended)
   - Disable "Enable email confirmations" for testing (optional)

2. **Configure Auth Redirects (Optional):**
   - Go to "Authentication" → "URL Configuration"
   - Add your app's redirect URLs if needed

### Step 6: Run the Mobile App

1. **Install Dependencies:**
   ```bash
   cd apps/mobile
   flutter pub get
   ```

2. **Run the App:**
   ```bash
   flutter run
   ```

3. **Test Authentication:**
   - Try registering a new user
   - Try logging in
   - Verify that the app connects successfully

### Step 7: Create First Admin User (Important!)

After the first user registers, you need to manually set them as admin:

1. **Go to Table Editor:**
   - In Supabase dashboard, click "Table Editor"
   - Select the "users" table
   - Find your user's row
   - Edit the "role" column to `admin`
   - Save

2. **Verify Admin Access:**
   - Log out and log back in
   - You should now have admin privileges

## 🔒 Security Best Practices

1. **Never Commit Secrets:**
   - Add `supabase_config.dart` to `.gitignore` if it contains real credentials
   - Use environment variables in production

2. **Enable Email Verification:**
   - In production, always enable email verification
   - This prevents spam accounts

3. **Review RLS Policies:**
   - Test your Row Level Security policies
   - Ensure users can only access their own data

4. **Monitor Usage:**
   - Check your Supabase dashboard regularly
   - Monitor database size and API usage
   - Set up alerts for approaching limits

## 📊 Migrating Existing Data (Optional)

If you have existing Firebase data to migrate:

1. **Export from Firebase:**
   - Go to Firebase Console → Firestore → Export
   - Download your data as JSON

2. **Transform Data:**
   - Convert Firestore documents to PostgreSQL format
   - Adjust field names (snake_case instead of camelCase)
   - Convert Timestamps to ISO 8601 format

3. **Import to Supabase:**
   - Use the Table Editor to manually import small datasets
   - Or use SQL INSERT statements for larger datasets

## 🆘 Troubleshooting

### Connection Issues
- Verify your Supabase URL and anon key are correct
- Check that your project is not paused (free tier projects pause after 1 week of inactivity)
- Ensure you have internet connectivity

### Authentication Errors
- Verify email auth is enabled in Supabase dashboard
- Check that RLS policies are properly configured
- Ensure the users table was created correctly

### Database Errors
- Run the schema SQL again if tables are missing
- Verify RLS is enabled on all tables
- Check query syntax if custom queries fail

### Storage Errors
- Verify storage buckets exist
- Check storage policies are correctly configured
- Ensure file sizes are within limits

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Supabase Client](https://supabase.com/docs/reference/dart/introduction)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Storage Guide](https://supabase.com/docs/guides/storage)

## 💰 Cost Comparison

### Firebase (Previous)
- Could incur charges after free tier limits
- Pay-as-you-go pricing
- Unpredictable costs

### Supabase (Current)
- Free tier: 500 MB database, 1 GB storage
- Predictable pricing
- Pro plan: $25/month (if needed)
- No surprise bills

## 🎉 You're All Set!

Your RPI Communication App is now running on Supabase with zero monthly costs! The free tier is generous enough for most college communication needs.

If you have any questions or encounter issues, please open an issue on GitHub.
