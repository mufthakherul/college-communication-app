#!/usr/bin/env node

/**
 * Migration: Create user_profiles collection for role-specific extended data
 * 
 * Architecture:
 * - users collection = common auth/identity data (email, display_name, role, department, etc.)
 * - user_profiles collection = role-specific extended data (student/teacher/admin fields)
 * 
 * This keeps services (messaging, etc.) unchanged while supporting rich profiles.
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

async function ensureCollection(databaseId, id, name, permissions, documentSecurity = true) {
  try {
    await databases.getCollection(databaseId, id);
    console.log(`✓ Collection '${id}' already exists`);
    return false; // Already exists
  } catch (err) {
    if (err.code !== 404) throw err;
    console.log(`➕ Creating collection '${id}'...`);
    await databases.createCollection(databaseId, id, name, permissions, documentSecurity);
    console.log(`✓ Created '${id}'`);
    return true; // Newly created
  }
}

async function ensureAttribute(type, key, size, required, defaultValue, array = false) {
  try {
    switch (type) {
      case 'string':
        await databases.createStringAttribute(DATABASE_ID, 'user_profiles', key, size, required, defaultValue, array);
        break;
      case 'enum':
        await databases.createEnumAttribute(DATABASE_ID, 'user_profiles', key, size, required, defaultValue); // size = elements array for enum
        break;
      case 'datetime':
        await databases.createDatetimeAttribute(DATABASE_ID, 'user_profiles', key, required, defaultValue);
        break;
      default:
        throw new Error(`Unknown attribute type: ${type}`);
    }
    console.log(`  ✓ Attribute '${key}' created`);
  } catch (err) {
    if (err.code === 409) {
      console.log(`  ✓ Attribute '${key}' already exists`);
    } else {
      throw err;
    }
  }
}

async function ensureIndex(databaseId, collectionId, index) {
  try {
    await databases.createIndex(databaseId, collectionId, index.key, index.type, index.attributes, index.orders);
    console.log(`  🔍 Index '${index.key}' created`);
  } catch (err) {
    if (err.code === 409) {
      console.log(`  🔍 Index '${index.key}' already exists`);
    } else {
      throw err;
    }
  }
}

async function migrate() {
  console.log(`\n🚀 Creating 'user_profiles' collection...\n`);

  // Create collection with document-level security
  // Permissions: users can read all, create their own, only they can update/delete their profile
  const created = await ensureCollection(
    DATABASE_ID,
    'user_profiles',
    'User Profiles',
    ['read("users")', 'create("users")', 'update("users")', 'delete("users")'],
    true
  );

  console.log('\n🧱 Ensuring attributes...');
  
  // Core linkage
  await ensureAttribute('string', 'user_id', 255, true);
  await ensureAttribute('enum', 'role', ['student', 'teacher', 'admin'], false, 'student');
  
  // Common optional fields (all roles)
  await ensureAttribute('string', 'bio', 1000, false);
  await ensureAttribute('string', 'phone_number', 20, false);
  
  // Student-specific fields
  await ensureAttribute('string', 'shift', 50, false);
  await ensureAttribute('string', 'group', 10, false);
  await ensureAttribute('string', 'class_roll', 20, false);
  await ensureAttribute('string', 'academic_session', 50, false);
  await ensureAttribute('string', 'registration_no', 100, false);
  await ensureAttribute('string', 'guardian_name', 255, false);
  await ensureAttribute('string', 'guardian_phone', 20, false);
  
  // Teacher-specific fields
  await ensureAttribute('string', 'designation', 100, false);
  await ensureAttribute('string', 'office_room', 50, false);
  await ensureAttribute('string', 'subjects', 100, false, undefined, true); // Array
  await ensureAttribute('string', 'qualification', 255, false);
  await ensureAttribute('string', 'office_hours', 255, false);
  
  // Admin-specific fields
  await ensureAttribute('string', 'admin_title', 100, false);
  await ensureAttribute('string', 'admin_scopes', 50, false, undefined, true); // Array
  
  // Audit timestamps
  await ensureAttribute('datetime', 'created_at', null, true);
  await ensureAttribute('datetime', 'updated_at', null, false);

  console.log('\n🔍 Ensuring indexes...');
  await ensureIndex(DATABASE_ID, 'user_profiles', { key: 'user_id_idx', type: 'key', attributes: ['user_id'] });
  await ensureIndex(DATABASE_ID, 'user_profiles', { key: 'role_idx', type: 'key', attributes: ['role'] });

  console.log(`\n✅ Migration complete!`);
  console.log(`\n📋 Next steps:`);
  console.log(`   1. Run: node cleanup-users-collection.js (to remove student fields from users)`);
  console.log(`   2. Update Flutter UserModel to remove student-specific fields`);
  console.log(`   3. Create UserProfile model and UserProfileService`);
  console.log(`   4. Update EditProfileScreen to work with both collections\n`);
}

migrate().catch(err => {
  console.error('❌ Migration failed:', err.message);
  console.error(err);
  process.exit(1);
});
