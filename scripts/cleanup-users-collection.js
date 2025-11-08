#!/usr/bin/env node

/**
 * Cleanup: Remove student-specific fields from users collection
 * 
 * These fields are now in user_profiles collection:
 * - shift
 * - group
 * - class_roll
 * - academic_session
 * - phone_number
 * 
 * WARNING: This will delete attributes and their data. Run migration first!
 */

require('dotenv').config({ path: '../tools/mcp/appwrite.mcp.env' });
const sdk = require('node-appwrite');

const ENDPOINT = process.env.APPWRITE_ENDPOINT;
const PROJECT_ID = process.env.APPWRITE_PROJECT_ID;
const API_KEY = process.env.APPWRITE_API_KEY;
const DATABASE_ID = 'rpi_communication';

const client = new sdk.Client()
  .setEndpoint(ENDPOINT)
  .setProject(PROJECT_ID)
  .setKey(API_KEY);

const databases = new sdk.Databases(client);

const FIELDS_TO_REMOVE = [
  'shift',
  'group',
  'class_roll',
  'academic_session',
  'phone_number'
];

async function cleanup() {
  console.log(`\n🧹 Cleaning up 'users' collection...\n`);
  console.log(`⚠️  WARNING: This will remove the following attributes and their data:`);
  FIELDS_TO_REMOVE.forEach(field => console.log(`   - ${field}`));
  console.log(`\n⚠️  Make sure you've:`);
  console.log(`   1. Created user_profiles collection (run migrate-user-profiles.js)`);
  console.log(`   2. Migrated existing data if needed`);
  console.log(`   3. Backed up your database\n`);
  
  // Check if collection exists
  try {
    const collection = await databases.getCollection(DATABASE_ID, 'users');
    console.log(`✓ Found 'users' collection\n`);
    
    const existingAttributes = collection.attributes.map(attr => attr.key);
    let removedCount = 0;
    
    for (const field of FIELDS_TO_REMOVE) {
      if (existingAttributes.includes(field)) {
        try {
          console.log(`  ➖ Deleting attribute '${field}'...`);
          await databases.deleteAttribute(DATABASE_ID, 'users', field);
          console.log(`  ✓ Deleted '${field}'`);
          removedCount++;
          // Wait a bit between deletions to avoid rate limiting
          await new Promise(resolve => setTimeout(resolve, 2000));
        } catch (err) {
          console.error(`  ✗ Failed to delete '${field}': ${err.message}`);
        }
      } else {
        console.log(`  ○ Attribute '${field}' doesn't exist (already removed or never existed)`);
      }
    }
    
    console.log(`\n✅ Cleanup complete! Removed ${removedCount} attributes.`);
    console.log(`\n📋 Next steps:`);
    console.log(`   1. Update Flutter UserModel (remove student fields)`);
    console.log(`   2. Update AuthService.updateUserProfile() (remove student fields)`);
    console.log(`   3. Create UserProfile model and UserProfileService`);
    console.log(`   4. Update EditProfileScreen to use UserProfileService\n`);
    
  } catch (err) {
    console.error(`❌ Failed: ${err.message}`);
    process.exit(1);
  }
}

cleanup();
