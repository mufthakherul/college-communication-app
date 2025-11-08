#!/usr/bin/env node

/**
 * Data migration script: Migrate existing users to user_profiles
 * 
 * This script creates user_profiles entries for existing users who don't have one yet.
 * Useful for migrating legacy data after the schema change.
 */

const sdk = require('node-appwrite');

// Initialize Appwrite client
const client = new sdk.Client()
  .setEndpoint(process.env.APPWRITE_ENDPOINT || 'https://sgp.cloud.appwrite.io/v1')
  .setProject(process.env.APPWRITE_PROJECT_ID || '6904cfb1001e5253725b')
  .setKey(process.env.APPWRITE_API_KEY || '');

const databases = new sdk.Databases(client);

const DATABASE_ID = 'rpi_communication';
const USERS_COLLECTION_ID = 'users';
const PROFILES_COLLECTION_ID = 'user_profiles';

async function migrateExistingUsers() {
  console.log('🔄 Starting user profile migration...\n');

  let migrated = 0;
  let skipped = 0;
  let failed = 0;

  try {
    // Fetch all users
    console.log('📋 Fetching all users...');
    let allUsers = [];
    let offset = 0;
    const limit = 100;
    let hasMore = true;

    while (hasMore) {
      const response = await databases.listDocuments(
        DATABASE_ID,
        USERS_COLLECTION_ID,
        [
          sdk.Query.limit(limit),
          sdk.Query.offset(offset),
        ]
      );

      allUsers = allUsers.concat(response.documents);
      offset += limit;
      hasMore = response.documents.length === limit;
    }

    console.log(`✅ Found ${allUsers.length} users\n`);

    // Fetch all existing profiles
    console.log('📋 Fetching existing profiles...');
    let existingProfiles = [];
    offset = 0;
    hasMore = true;

    while (hasMore) {
      const response = await databases.listDocuments(
        DATABASE_ID,
        PROFILES_COLLECTION_ID,
        [
          sdk.Query.limit(limit),
          sdk.Query.offset(offset),
        ]
      );

      existingProfiles = existingProfiles.concat(response.documents);
      offset += limit;
      hasMore = response.documents.length === limit;
    }

    const existingUserIds = new Set(existingProfiles.map(p => p.user_id));
    console.log(`✅ Found ${existingProfiles.length} existing profiles\n`);

    // Migrate users without profiles
    console.log('🔄 Creating profiles for users without one...\n');

    for (const user of allUsers) {
      // Skip if profile already exists
      if (existingUserIds.has(user.$id)) {
        console.log(`⏭️  Skipping ${user.display_name} - profile exists`);
        skipped++;
        continue;
      }

      try {
        // Create basic profile based on role
        const profileData = {
          user_id: user.$id,
          role: user.role || 'student',
          created_at: new Date().toISOString(),
        };

        await databases.createDocument(
          DATABASE_ID,
          PROFILES_COLLECTION_ID,
          sdk.ID.unique(),
          profileData
        );

        console.log(`✅ Created profile for ${user.display_name} (${user.role})`);
        migrated++;
      } catch (error) {
        console.error(`❌ Failed to create profile for ${user.display_name}:`, error.message);
        failed++;
      }
    }

    // Summary
    console.log('\n' + '='.repeat(60));
    console.log('📊 MIGRATION SUMMARY');
    console.log('='.repeat(60));
    console.log(`Total Users: ${allUsers.length}`);
    console.log(`✅ Profiles Created: ${migrated}`);
    console.log(`⏭️  Skipped (already exists): ${skipped}`);
    console.log(`❌ Failed: ${failed}`);
    console.log('='.repeat(60));

    if (failed === 0) {
      console.log('\n✨ Migration completed successfully!');
    } else {
      console.log('\n⚠️  Migration completed with some failures. Check errors above.');
    }

  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
}

// Run migration
migrateExistingUsers().catch((error) => {
  console.error('❌ Unexpected error:', error);
  process.exit(1);
});
