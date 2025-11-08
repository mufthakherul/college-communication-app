#!/usr/bin/env node

/**
 * Appwrite Database Test Script
 * Tests group chat functionality and storage buckets
 * 
 * Updated: November 2025
 * Changes: Modified to work with the new database structure:
 * - Authentication users: Created via Appwrite Users API
 * - Database users: Created in 'users' collection with common fields
 * - User profiles: Can be created in 'user_profiles' collection for role-specific data
 * 
 * This test creates both authentication users and database user entries.
 */

require('dotenv').config({ path: '../tools/mcp/appwrite.mcp.env' });
const sdk = require('node-appwrite');
const fs = require('fs');
const path = require('path');

// Configuration
const ENDPOINT = process.env.APPWRITE_ENDPOINT;
const PROJECT_ID = process.env.APPWRITE_PROJECT_ID;
const API_KEY = process.env.APPWRITE_API_KEY;
const DATABASE_ID = 'rpi_communication';

// Initialize Appwrite
const client = new sdk.Client()
  .setEndpoint(ENDPOINT)
  .setProject(PROJECT_ID)
  .setKey(API_KEY);

const databases = new sdk.Databases(client);
const storage = new sdk.Storage(client);
const users = new sdk.Users(client);

// Helper function to sleep
const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

// ANSI colors
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

const log = {
  success: (msg) => console.log(`${colors.green}✓${colors.reset} ${msg}`),
  error: (msg) => console.log(`${colors.red}✗${colors.reset} ${msg}`),
  info: (msg) => console.log(`${colors.blue}ℹ${colors.reset} ${msg}`),
  section: (msg) => console.log(`\n${colors.cyan}═══ ${msg} ═══${colors.reset}\n`),
};

// Test data
let testUserId1, testUserId2, testGroupId, testMemberId;

/**
 * Test 1: Create test users
 */
async function testCreateUsers() {
  log.section('Test 1: Creating Test Users');
  
  try {
    // Create test user 1 (Authentication user)
    try {
      const user1 = await users.create(
        sdk.ID.unique(),
        'testuser1@rpi.edu.bd',
        undefined,
        'Test User 1',
        'testpass123'
      );
      testUserId1 = user1.$id;
      log.success(`Created auth user 1: ${testUserId1}`);
      
      // Also create database user entry
      try {
        await databases.createDocument(
          DATABASE_ID,
          'users',
          sdk.ID.unique(),
          {
            email: 'testuser1@rpi.edu.bd',
            display_name: 'Test User 1',
            role: 'student',
            department: 'Computer Science',
            is_active: true,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
          }
        );
        log.success(`Created database user 1`);
      } catch (dbErr) {
        if (dbErr.code !== 409) {
          log.info(`Database user 1 may already exist or error: ${dbErr.message}`);
        }
      }
    } catch (err) {
      if (err.code === 409) {
        // User already exists, get existing user
        const usersList = await users.list([sdk.Query.equal('email', ['testuser1@rpi.edu.bd'])]);
        if (usersList.users.length > 0) {
          testUserId1 = usersList.users[0].$id;
          log.info(`Using existing auth user 1: ${testUserId1}`);
        }
      } else {
        throw err;
      }
    }

    await sleep(500);

    // Create test user 2 (Authentication user)
    try {
      const user2 = await users.create(
        sdk.ID.unique(),
        'testuser2@rpi.edu.bd',
        undefined,
        'Test User 2',
        'testpass123'
      );
      testUserId2 = user2.$id;
      log.success(`Created auth user 2: ${testUserId2}`);
      
      // Also create database user entry
      try {
        await databases.createDocument(
          DATABASE_ID,
          'users',
          sdk.ID.unique(),
          {
            email: 'testuser2@rpi.edu.bd',
            display_name: 'Test User 2',
            role: 'student',
            department: 'Computer Science',
            is_active: true,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
          }
        );
        log.success(`Created database user 2`);
      } catch (dbErr) {
        if (dbErr.code !== 409) {
          log.info(`Database user 2 may already exist or error: ${dbErr.message}`);
        }
      }
    } catch (err) {
      if (err.code === 409) {
        const usersList = await users.list([sdk.Query.equal('email', ['testuser2@rpi.edu.bd'])]);
        if (usersList.users.length > 0) {
          testUserId2 = usersList.users[0].$id;
          log.info(`Using existing auth user 2: ${testUserId2}`);
        }
      } else {
        throw err;
      }
    }

    return true;
  } catch (err) {
    log.error(`Failed to create users: ${err.message}`);
    return false;
  }
}

/**
 * Test 2: Create a group
 */
async function testCreateGroup() {
  log.section('Test 2: Creating a Test Group');
  
  try {
    const groupData = {
      name: 'Test CS Group',
      description: 'Computer Science test group',
      owner_id: testUserId1,
      group_type: 'department',
      member_count: 1,
      is_active: true,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      metadata: JSON.stringify({ test: true }),
    };

    const group = await databases.createDocument(
      DATABASE_ID,
      'groups',
      sdk.ID.unique(),
      groupData,
      [
        sdk.Permission.read(sdk.Role.users()),
        sdk.Permission.update(sdk.Role.user(testUserId1)),
        sdk.Permission.delete(sdk.Role.user(testUserId1)),
      ]
    );

    testGroupId = group.$id;
    log.success(`Created group: ${group.name} (${testGroupId})`);
    log.info(`  Owner: ${group.owner_id}`);
    log.info(`  Type: ${group.group_type}`);
    log.info(`  Members: ${group.member_count}`);
    
    return true;
  } catch (err) {
    log.error(`Failed to create group: ${err.message}`);
    return false;
  }
}

/**
 * Test 3: Add members to group
 */
async function testAddGroupMembers() {
  log.section('Test 3: Adding Members to Group');
  
  try {
    // Add user 1 as admin
    const member1 = await databases.createDocument(
      DATABASE_ID,
      'group_members',
      sdk.ID.unique(),
      {
        group_id: testGroupId,
        user_id: testUserId1,
        role: 'admin',
        status: 'active',
        joined_at: new Date().toISOString(),
        unread_count: 0,
        metadata: JSON.stringify({ admin: true }),
      },
      [
        sdk.Permission.read(sdk.Role.users()),
        sdk.Permission.update(sdk.Role.user(testUserId1)),
        sdk.Permission.delete(sdk.Role.user(testUserId1)),
      ]
    );
    log.success(`Added ${testUserId1} as admin`);

    await sleep(500);

    // Add user 2 as member
    const member2 = await databases.createDocument(
      DATABASE_ID,
      'group_members',
      sdk.ID.unique(),
      {
        group_id: testGroupId,
        user_id: testUserId2,
        role: 'member',
        status: 'active',
        joined_at: new Date().toISOString(),
        unread_count: 0,
      },
      [
        sdk.Permission.read(sdk.Role.users()),
        sdk.Permission.update(sdk.Role.user(testUserId2)),
        sdk.Permission.delete(sdk.Role.user(testUserId2)),
      ]
    );
    testMemberId = member2.$id;
    log.success(`Added ${testUserId2} as member`);

    // Update group member count
    await databases.updateDocument(
      DATABASE_ID,
      'groups',
      testGroupId,
      { member_count: 2 }
    );
    log.success(`Updated group member count to 2`);

    return true;
  } catch (err) {
    log.error(`Failed to add members: ${err.message}`);
    return false;
  }
}

/**
 * Test 4: Send group messages
 */
async function testSendGroupMessages() {
  log.section('Test 4: Sending Group Messages');
  
  try {
    // Message from user 1
    const message1 = await databases.createDocument(
      DATABASE_ID,
      'messages',
      sdk.ID.unique(),
      {
        sender_id: testUserId1,
        recipient_id: testGroupId, // Group ID as recipient
        content: 'Hello everyone! This is a test group message.',
        type: 'text',
          read: false,
          is_read: false,
          created_at: new Date().toISOString(),
        group_id: testGroupId,
        is_group_message: true,
        sender_display_name: 'Test User 1',
        sender_photo_url: null,
      },
      [
        sdk.Permission.read(sdk.Role.users()),
        sdk.Permission.update(sdk.Role.user(testUserId1)),
        sdk.Permission.delete(sdk.Role.user(testUserId1)),
      ]
    );
    log.success(`Message 1 sent: "${message1.content}"`);

    await sleep(500);

    // Message from user 2
    const message2 = await databases.createDocument(
      DATABASE_ID,
      'messages',
      sdk.ID.unique(),
      {
        sender_id: testUserId2,
        recipient_id: testGroupId,
        content: 'Hi! This is a reply to the group message.',
        type: 'text',
          read: false,
          is_read: false,
          created_at: new Date().toISOString(),
        group_id: testGroupId,
        is_group_message: true,
        sender_display_name: 'Test User 2',
        reply_to_message_id: message1.$id,
      },
      [
        sdk.Permission.read(sdk.Role.users()),
        sdk.Permission.update(sdk.Role.user(testUserId2)),
        sdk.Permission.delete(sdk.Role.user(testUserId2)),
      ]
    );
    log.success(`Message 2 sent: "${message2.content}" (reply to message 1)`);

    // Message with mention
    const message3 = await databases.createDocument(
      DATABASE_ID,
      'messages',
      sdk.ID.unique(),
      {
        sender_id: testUserId1,
        recipient_id: testGroupId,
        content: '@TestUser2 Can you check this?',
        type: 'text',
          read: false,
          is_read: false,
          created_at: new Date().toISOString(),
        group_id: testGroupId,
        is_group_message: true,
        sender_display_name: 'Test User 1',
        mention_ids: [testUserId2],
      },
      [
        sdk.Permission.read(sdk.Role.users()),
        sdk.Permission.update(sdk.Role.user(testUserId1)),
        sdk.Permission.delete(sdk.Role.user(testUserId1)),
      ]
    );
    log.success(`Message 3 sent with mention: "${message3.content}"`);

    return true;
  } catch (err) {
    log.error(`Failed to send messages: ${err.message}`);
    return false;
  }
}

/**
 * Test 5: Query group messages
 */
async function testQueryGroupMessages() {
  log.section('Test 5: Querying Group Messages');
  
  try {
    const messages = await databases.listDocuments(
      DATABASE_ID,
      'messages',
      [
        sdk.Query.equal('group_id', [testGroupId]),
        sdk.Query.equal('is_group_message', [true]),
        sdk.Query.orderDesc('created_at'),
        sdk.Query.limit(10),
      ]
    );

    log.success(`Found ${messages.total} group messages`);
    messages.documents.forEach((msg, idx) => {
      log.info(`  ${idx + 1}. ${msg.sender_display_name}: ${msg.content}`);
      if (msg.reply_to_message_id) {
        log.info(`     ↳ Reply to: ${msg.reply_to_message_id}`);
      }
      if (msg.mention_ids && msg.mention_ids.length > 0) {
        log.info(`     ↳ Mentions: ${msg.mention_ids.length} user(s)`);
      }
    });

    return true;
  } catch (err) {
    log.error(`Failed to query messages: ${err.message}`);
    return false;
  }
}

/**
 * Test 6: Test storage buckets
 */
async function testStorageBuckets() {
  log.section('Test 6: Testing Storage Buckets');
  
  const buckets = [
    { id: 'profile-images', name: 'Profile Images' },
    { id: 'notice-attachments', name: 'Notice Attachments' },
    { id: 'message-attachments', name: 'Message Attachments' },
    { id: 'book-covers', name: 'Book Covers' },
    { id: 'book-files', name: 'Book Files' },
    { id: 'assignment-files', name: 'Assignment Files' },
  ];

  let successCount = 0;

  for (const bucket of buckets) {
    try {
      const result = await storage.getBucket(bucket.id);
      log.success(`${bucket.name}: Available`);
      log.info(`  ID: ${result.$id}`);
      log.info(`  Max File Size: ${(result.maximumFileSize / (1024 * 1024)).toFixed(1)} MB`);
      log.info(`  Allowed Extensions: ${result.allowedFileExtensions.join(', ')}`);
      log.info(`  Encryption: ${result.encryption ? 'Enabled' : 'Disabled'}`);
      successCount++;
    } catch (err) {
      log.error(`${bucket.name}: ${err.message}`);
    }
  }

  log.info(`\n${successCount}/${buckets.length} storage buckets verified`);
  return successCount === buckets.length;
}

/**
 * Test 7: Test file upload
 */
async function testFileUpload() {
  log.section('Test 7: Testing File Upload');
  
  try {
    // Create a test file
    const testFileName = 'test-image.txt';
    const testFilePath = path.join('/tmp', testFileName);
    const testContent = 'This is a test file for Appwrite storage bucket validation.\nCreated: ' + new Date().toISOString();
    
    fs.writeFileSync(testFilePath, testContent);
    log.info(`Created test file: ${testFilePath}`);

      // Upload to profile-images bucket  
    // For node-appwrite, create stream from absolute path
      const fileStream = fs.createReadStream(testFilePath);
    
      const file = await storage.createFile(
        'profile-images',
        sdk.ID.unique(),
        fileStream
      );

    log.success(`File uploaded successfully!`);
    log.info(`  File ID: ${file.$id}`);
    log.info(`  File Name: ${file.name}`);
    log.info(`  File Size: ${file.sizeOriginal} bytes`);
    log.info(`  MIME Type: ${file.mimeType}`);

    // Get file preview URL
    const previewUrl = storage.getFilePreview('profile-images', file.$id);
    log.info(`  Preview URL: ${previewUrl}`);

    // Delete test file
    await storage.deleteFile('profile-images', file.$id);
    log.success(`Test file deleted from storage`);

    // Clean up local file
    fs.unlinkSync(testFilePath);
    log.info(`Local test file cleaned up`);

    return true;
  } catch (err) {
    log.error(`File upload failed: ${err.message}`);
    return false;
  }
}

/**
 * Test 8: Query group members
 */
async function testQueryGroupMembers() {
  log.section('Test 8: Querying Group Members');
  
  try {
    const members = await databases.listDocuments(
      DATABASE_ID,
      'group_members',
      [
        sdk.Query.equal('group_id', [testGroupId]),
        sdk.Query.orderAsc('joined_at'),
      ]
    );

    log.success(`Found ${members.total} group members`);
    members.documents.forEach((member, idx) => {
      log.info(`  ${idx + 1}. User: ${member.user_id}`);
      log.info(`     Role: ${member.role}`);
      log.info(`     Status: ${member.status}`);
      log.info(`     Joined: ${new Date(member.joined_at).toLocaleString()}`);
    });

    return true;
  } catch (err) {
    log.error(`Failed to query members: ${err.message}`);
    return false;
  }
}

/**
 * Test 9: Test event creation
 */
async function testCreateEvent() {
  log.section('Test 9: Creating Test Event');
  
  try {
    const event = await databases.createDocument(
      DATABASE_ID,
      'events',
      sdk.ID.unique(),
      {
        title: 'Test Tech Workshop',
        description: 'A test workshop for computer science students',
        type: 'workshop',
        start_date: new Date(Date.now() + 86400000).toISOString(), // Tomorrow
        end_date: new Date(Date.now() + 90000000).toISOString(), // Tomorrow + 1 hour
        venue: 'Lab 101',
        organizer: 'CS Department',
        is_registration_required: true,
        max_participants: 50,
        current_participants: 0,
        target_audience: ['CSE', 'IT'],
        created_at: new Date().toISOString(),
      },
      [
        sdk.Permission.read(sdk.Role.any()),
        sdk.Permission.update(sdk.Role.users()),
        sdk.Permission.delete(sdk.Role.label('admin')),
      ]
    );

    log.success(`Event created: ${event.title}`);
    log.info(`  Type: ${event.type}`);
    log.info(`  Venue: ${event.venue}`);
    log.info(`  Start: ${new Date(event.start_date).toLocaleString()}`);
    log.info(`  Max Participants: ${event.max_participants}`);

    return true;
  } catch (err) {
    log.error(`Failed to create event: ${err.message}`);
    return false;
  }
}

/**
 * Test 10: Test assignment creation
 */
async function testCreateAssignment() {
  log.section('Test 10: Creating Test Assignment');
  
  try {
    const assignment = await databases.createDocument(
      DATABASE_ID,
      'assignments',
      sdk.ID.unique(),
      {
        title: 'Test Assignment - Data Structures',
        description: 'Implement a binary search tree with insert, delete, and search operations',
        subject: 'Data Structures',
        teacher_id: testUserId1,
        teacher_name: 'Test User 1',
        due_date: new Date(Date.now() + 604800000).toISOString(), // 1 week from now
        max_marks: 100,
        target_groups: ['CSE-A', 'CSE-B'],
        department: 'CSE',
        created_at: new Date().toISOString(),
      },
      [
        sdk.Permission.read(sdk.Role.users()),
        sdk.Permission.update(sdk.Role.user(testUserId1)),
        sdk.Permission.delete(sdk.Role.user(testUserId1)),
      ]
    );

    log.success(`Assignment created: ${assignment.title}`);
    log.info(`  Subject: ${assignment.subject}`);
    log.info(`  Teacher: ${assignment.teacher_name}`);
    log.info(`  Due Date: ${new Date(assignment.due_date).toLocaleString()}`);
    log.info(`  Max Marks: ${assignment.max_marks}`);

    return true;
  } catch (err) {
    log.error(`Failed to create assignment: ${err.message}`);
    return false;
  }
}

/**
 * Main test runner
 */
async function runTests() {
  console.log('\n╔════════════════════════════════════════════════════════════╗');
  console.log('║     Appwrite Database Functionality Test Suite            ║');
  console.log('╚════════════════════════════════════════════════════════════╝\n');

  log.info(`Endpoint: ${ENDPOINT}`);
  log.info(`Project: ${PROJECT_ID}`);
  log.info(`Database: ${DATABASE_ID}\n`);

  const tests = [
    { name: 'Create Test Users', fn: testCreateUsers },
    { name: 'Create Group', fn: testCreateGroup },
    { name: 'Add Group Members', fn: testAddGroupMembers },
    { name: 'Send Group Messages', fn: testSendGroupMessages },
    { name: 'Query Group Messages', fn: testQueryGroupMessages },
    { name: 'Verify Storage Buckets', fn: testStorageBuckets },
    { name: 'Test File Upload', fn: testFileUpload },
    { name: 'Query Group Members', fn: testQueryGroupMembers },
    { name: 'Create Event', fn: testCreateEvent },
    { name: 'Create Assignment', fn: testCreateAssignment },
  ];

  let passed = 0;
  let failed = 0;

  for (const test of tests) {
    const result = await test.fn();
    if (result) {
      passed++;
    } else {
      failed++;
    }
    await sleep(1000);
  }

  // Summary
  console.log('\n╔════════════════════════════════════════════════════════════╗');
  console.log('║                      TEST SUMMARY                          ║');
  console.log('╚════════════════════════════════════════════════════════════╝\n');

  log.info(`Total Tests: ${tests.length}`);
  log.success(`Passed: ${passed}`);
  if (failed > 0) {
    log.error(`Failed: ${failed}`);
  }

  const successRate = ((passed / tests.length) * 100).toFixed(1);
  log.info(`Success Rate: ${successRate}%\n`);

  if (failed === 0) {
    console.log(`${colors.green}🎉 All tests passed! Database is fully functional.${colors.reset}\n`);
  } else {
    console.log(`${colors.yellow}⚠️  Some tests failed. Please check the errors above.${colors.reset}\n`);
  }

  // Cleanup instructions
  if (testGroupId) {
    log.info('\n💡 Test Data Created:');
    log.info(`   Group ID: ${testGroupId}`);
    log.info(`   User 1 ID: ${testUserId1}`);
    log.info(`   User 2 ID: ${testUserId2}`);
    log.info('\n   You can clean up this test data from the Appwrite Console if needed.');
  }
}

// Run tests
runTests().catch(err => {
  log.error(`Test suite failed: ${err.message}`);
  console.error(err);
  process.exit(1);
});
