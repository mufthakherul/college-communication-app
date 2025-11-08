#!/usr/bin/env node

/**
 * Test script for user profiles functionality
 * Tests CRUD operations for all three roles (student, teacher, admin)
 * 
 * Updated: November 2025
 * Changes: Modified to work with the new database structure:
 * - users collection: Common user data (email, display_name, role, department, etc.)
 * - user_profiles collection: Role-specific data (student/teacher/admin specific fields)
 * 
 * Each test now creates a user in the 'users' collection first, then creates
 * the corresponding profile with role-specific data in 'user_profiles' collection.
 */

const sdk = require('node-appwrite');

// Initialize Appwrite client
const client = new sdk.Client()
  .setEndpoint(process.env.APPWRITE_ENDPOINT || 'https://sgp.cloud.appwrite.io/v1')
  .setProject(process.env.APPWRITE_PROJECT_ID || '6904cfb1001e5253725b')
  .setKey(process.env.APPWRITE_API_KEY || '');

const databases = new sdk.Databases(client);
const users = new sdk.Users(client);

const DATABASE_ID = 'rpi_communication';
const USERS_COLLECTION_ID = 'users';
const PROFILES_COLLECTION_ID = 'user_profiles';

async function testProfiles() {
  console.log('🧪 Testing User Profiles Functionality\n');

  let testResults = {
    passed: 0,
    failed: 0,
    tests: [],
  };

  // Test 1: Create student profile
  try {
    console.log('📝 Test 1: Create student profile');
    
    // First, create a test user in the users collection (common data only)
    const testUser = await databases.createDocument(
      DATABASE_ID,
      USERS_COLLECTION_ID,
      sdk.ID.unique(),
      {
        email: `test-student-${Date.now()}@test.com`,
        display_name: 'Test Student',
        role: 'student',
        department: 'Computer Science',
        year: '2024',
        is_active: true,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      }
    );

    console.log('  ✓ User created:', testUser.$id);

    // Then create the student-specific profile in user_profiles collection
    const studentProfile = await databases.createDocument(
      DATABASE_ID,
      PROFILES_COLLECTION_ID,
      sdk.ID.unique(),
      {
        user_id: testUser.$id,
        role: 'student',
        shift: 'Day',
        group: 'A',
        class_roll: '101',
        academic_session: '2024-2025',
        registration_no: 'REG2024001',
        guardian_name: 'Test Guardian',
        guardian_phone: '+1234567890',
        bio: 'Test student bio',
        phone_number: '+0987654321',
        created_at: new Date().toISOString(),
      }
    );

    console.log('✅ Student profile created:', studentProfile.$id);
    testResults.passed++;
    testResults.tests.push({ name: 'Create student profile', status: 'PASSED' });
  } catch (error) {
    console.error('❌ Failed:', error.message);
    testResults.failed++;
    testResults.tests.push({ name: 'Create student profile', status: 'FAILED', error: error.message });
  }

  // Test 2: Create teacher profile
  try {
    console.log('\n📝 Test 2: Create teacher profile');
    
    // Create user in users collection
    const testUser = await databases.createDocument(
      DATABASE_ID,
      USERS_COLLECTION_ID,
      sdk.ID.unique(),
      {
        email: `test-teacher-${Date.now()}@test.com`,
        display_name: 'Test Teacher',
        role: 'teacher',
        department: 'Mathematics',
        is_active: true,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      }
    );

    console.log('  ✓ User created:', testUser.$id);

    // Create teacher-specific profile in user_profiles collection
    const teacherProfile = await databases.createDocument(
      DATABASE_ID,
      PROFILES_COLLECTION_ID,
      sdk.ID.unique(),
      {
        user_id: testUser.$id,
        role: 'teacher',
        designation: 'Associate Professor',
        office_room: 'Room 301',
        subjects: ['Calculus', 'Linear Algebra', 'Statistics'],
        qualification: 'PhD in Mathematics',
        office_hours: 'Mon-Fri 2PM-4PM',
        bio: 'Experienced mathematics professor',
        phone_number: '+1122334455',
        created_at: new Date().toISOString(),
      }
    );

    console.log('✅ Teacher profile created:', teacherProfile.$id);
    testResults.passed++;
    testResults.tests.push({ name: 'Create teacher profile', status: 'PASSED' });
  } catch (error) {
    console.error('❌ Failed:', error.message);
    testResults.failed++;
    testResults.tests.push({ name: 'Create teacher profile', status: 'FAILED', error: error.message });
  }

  // Test 3: Create admin profile
  try {
    console.log('\n📝 Test 3: Create admin profile');
    
    // Create user in users collection
    const testUser = await databases.createDocument(
      DATABASE_ID,
      USERS_COLLECTION_ID,
      sdk.ID.unique(),
      {
        email: `test-admin-${Date.now()}@test.com`,
        display_name: 'Test Admin',
        role: 'admin',
        department: 'Administration',
        is_active: true,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      }
    );

    console.log('  ✓ User created:', testUser.$id);

    // Create admin-specific profile in user_profiles collection
    const adminProfile = await databases.createDocument(
      DATABASE_ID,
      PROFILES_COLLECTION_ID,
      sdk.ID.unique(),
      {
        user_id: testUser.$id,
        role: 'admin',
        admin_title: 'System Administrator',
        admin_scopes: ['notices', 'users', 'groups', 'reports'],
        bio: 'Managing the college communication system',
        phone_number: '+9988776655',
        created_at: new Date().toISOString(),
      }
    );

    console.log('✅ Admin profile created:', adminProfile.$id);
    testResults.passed++;
    testResults.tests.push({ name: 'Create admin profile', status: 'PASSED' });
  } catch (error) {
    console.error('❌ Failed:', error.message);
    testResults.failed++;
    testResults.tests.push({ name: 'Create admin profile', status: 'FAILED', error: error.message });
  }

  // Test 4: Query profiles by role
  try {
    console.log('\n📝 Test 4: Query profiles by role');
    
    const studentProfiles = await databases.listDocuments(
      DATABASE_ID,
      PROFILES_COLLECTION_ID,
      [sdk.Query.equal('role', 'student')]
    );

    console.log(`✅ Found ${studentProfiles.documents.length} student profiles`);
    testResults.passed++;
    testResults.tests.push({ name: 'Query profiles by role', status: 'PASSED' });
  } catch (error) {
    console.error('❌ Failed:', error.message);
    testResults.failed++;
    testResults.tests.push({ name: 'Query profiles by role', status: 'FAILED', error: error.message });
  }

  // Test 5: Update profile
  try {
    console.log('\n📝 Test 5: Update profile');
    
    // Get a profile to update
    const profiles = await databases.listDocuments(
      DATABASE_ID,
      PROFILES_COLLECTION_ID,
      [sdk.Query.limit(1)]
    );

    if (profiles.documents.length === 0) {
      throw new Error('No profiles found to update');
    }

    const profileToUpdate = profiles.documents[0];
    const updated = await databases.updateDocument(
      DATABASE_ID,
      PROFILES_COLLECTION_ID,
      profileToUpdate.$id,
      {
        bio: 'Updated bio text',
        updated_at: new Date().toISOString(),
      }
    );

    console.log('✅ Profile updated:', updated.$id);
    testResults.passed++;
    testResults.tests.push({ name: 'Update profile', status: 'PASSED' });
  } catch (error) {
    console.error('❌ Failed:', error.message);
    testResults.failed++;
    testResults.tests.push({ name: 'Update profile', status: 'FAILED', error: error.message });
  }

  // Test 6: Get profile by user_id
  try {
    console.log('\n📝 Test 6: Get profile by user_id');
    
    const profiles = await databases.listDocuments(
      DATABASE_ID,
      PROFILES_COLLECTION_ID,
      [sdk.Query.limit(1)]
    );

    if (profiles.documents.length === 0) {
      throw new Error('No profiles found');
    }

    const profile = profiles.documents[0];
    const foundProfiles = await databases.listDocuments(
      DATABASE_ID,
      PROFILES_COLLECTION_ID,
      [sdk.Query.equal('user_id', profile.user_id)]
    );

    if (foundProfiles.documents.length > 0) {
      console.log('✅ Profile found by user_id');
      testResults.passed++;
      testResults.tests.push({ name: 'Get profile by user_id', status: 'PASSED' });
    } else {
      throw new Error('Profile not found by user_id');
    }
  } catch (error) {
    console.error('❌ Failed:', error.message);
    testResults.failed++;
    testResults.tests.push({ name: 'Get profile by user_id', status: 'FAILED', error: error.message });
  }

  // Print summary
  console.log('\n' + '='.repeat(50));
  console.log('📊 TEST SUMMARY');
  console.log('='.repeat(50));
  console.log(`Total Tests: ${testResults.passed + testResults.failed}`);
  console.log(`✅ Passed: ${testResults.passed}`);
  console.log(`❌ Failed: ${testResults.failed}`);
  console.log(`Success Rate: ${((testResults.passed / (testResults.passed + testResults.failed)) * 100).toFixed(1)}%`);
  console.log('\n📋 Detailed Results:');
  testResults.tests.forEach((test, index) => {
    const icon = test.status === 'PASSED' ? '✅' : '❌';
    console.log(`${index + 1}. ${icon} ${test.name}: ${test.status}`);
    if (test.error) {
      console.log(`   Error: ${test.error}`);
    }
  });

  console.log('\n✨ Profile testing complete!');
}

// Run tests
testProfiles().catch((error) => {
  console.error('❌ Test execution failed:', error);
  process.exit(1);
});
