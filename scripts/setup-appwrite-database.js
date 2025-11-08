#!/usr/bin/env node

/**
 * Appwrite Database Setup Script
 * 
 * This script programmatically creates/updates all collections, attributes,
 * indexes, and storage buckets for the RPI Communication App.
 * 
 * Usage:
 *   node scripts/setup-appwrite-database.js
 * 
 * Prerequisites:
 *   - Node.js 18+
 *   - npm install node-appwrite
 *   - Environment variables set (from tools/mcp/appwrite.mcp.env)
 */

const sdk = require('node-appwrite');
const fs = require('fs');
const path = require('path');

// Load environment variables
require('dotenv').config({ path: path.join(__dirname, '../tools/mcp/appwrite.mcp.env') });

const ENDPOINT = process.env.APPWRITE_ENDPOINT || 'https://sgp.cloud.appwrite.io/v1';
const PROJECT_ID = process.env.APPWRITE_PROJECT_ID;
const API_KEY = process.env.APPWRITE_API_KEY;
const DATABASE_ID = 'rpi_communication';

// Validation
if (!PROJECT_ID || !API_KEY) {
  console.error('❌ Missing required environment variables!');
  console.error('   Please ensure APPWRITE_PROJECT_ID and APPWRITE_API_KEY are set.');
  process.exit(1);
}

// Initialize Appwrite SDK
const client = new sdk.Client()
  .setEndpoint(ENDPOINT)
  .setProject(PROJECT_ID)
  .setKey(API_KEY);

const databases = new sdk.Databases(client);
const storage = new sdk.Storage(client);

// Helper: Sleep function
const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

// Helper: Create or update attribute
async function ensureAttribute(databaseId, collectionId, attribute) {
  try {
    const { key, type, size, required, array, defaultValue, xdefault } = attribute;
    
    console.log(`   → ${key} (${type}${size ? `, size: ${size}` : ''}${required ? ', required' : ''}${array ? ', array' : ''})`);
    
    // Check if attribute exists
    try {
      await databases.getAttribute(databaseId, collectionId, key);
      console.log(`      ✓ Already exists`);
      return;
    } catch (err) {
      if (err.code !== 404) throw err;
    }
    
    // Create attribute based on type
    let result;
    const def = defaultValue || xdefault;
    
    switch (type) {
      case 'string':
        result = await databases.createStringAttribute(
          databaseId, collectionId, key, size || 255, required || false, def, array || false
        );
        break;
      case 'email':
        result = await databases.createEmailAttribute(
          databaseId, collectionId, key, required || false, def, array || false
        );
        break;
      case 'url':
        result = await databases.createUrlAttribute(
          databaseId, collectionId, key, required || false, def, array || false
        );
        break;
      case 'integer':
        result = await databases.createIntegerAttribute(
          databaseId, collectionId, key, required || false, null, null, def, array || false
        );
        break;
      case 'float':
        result = await databases.createFloatAttribute(
          databaseId, collectionId, key, required || false, null, null, def, array || false
        );
        break;
      case 'boolean':
        result = await databases.createBooleanAttribute(
          databaseId, collectionId, key, required || false, def, array || false
        );
        break;
      case 'datetime':
        result = await databases.createDatetimeAttribute(
          databaseId, collectionId, key, required || false, def, array || false
        );
        break;
      case 'enum':
        result = await databases.createEnumAttribute(
          databaseId, collectionId, key, attribute.elements, required || false, def, array || false
        );
        break;
      default:
        console.log(`      ⚠️  Unknown type: ${type}`);
        return;
    }
    
    console.log(`      ✓ Created`);
    await sleep(500); // Prevent rate limiting
    
  } catch (err) {
    console.error(`      ✗ Error: ${err.message}`);
  }
}

// Helper: Create or update index
async function ensureIndex(databaseId, collectionId, index) {
  try {
    const { key, type, attributes, orders } = index;
    
    console.log(`   → Index: ${key} (${type}) on [${attributes.join(', ')}]`);
    
    // Check if index exists
    try {
      await databases.getIndex(databaseId, collectionId, key);
      console.log(`      ✓ Already exists`);
      return;
    } catch (err) {
      if (err.code !== 404) throw err;
    }
    
    // Create index
    await databases.createIndex(
      databaseId,
      collectionId,
      key,
      type || 'key',
      attributes,
      orders || attributes.map(() => 'ASC')
    );
    
    console.log(`      ✓ Created`);
    await sleep(500);
    
  } catch (err) {
    console.error(`      ✗ Error: ${err.message}`);
  }
}

// Helper: Create or update collection
async function ensureCollection(databaseId, collection) {
  try {
    const { id, name, permissions, documentSecurity, enabled, attributes: attrs, indexes } = collection;
    
    console.log(`\n📦 Collection: ${name} (${id})`);
    
    // Check if collection exists
    let collectionExists = false;
    try {
      await databases.getCollection(databaseId, id);
      collectionExists = true;
      console.log(`   ✓ Collection exists`);
    } catch (err) {
      if (err.code !== 404) throw err;
    }
    
    // Create collection if doesn't exist
    if (!collectionExists) {
      await databases.createCollection(
        databaseId,
        id,
        name,
        permissions || [],
        documentSecurity !== undefined ? documentSecurity : false,
        enabled !== undefined ? enabled : true
      );
      console.log(`   ✓ Collection created`);
      await sleep(1000);
    }
    
    // Create attributes
    if (attrs && attrs.length > 0) {
      console.log(`   📝 Attributes (${attrs.length}):`);
      for (const attr of attrs) {
        await ensureAttribute(databaseId, id, attr);
      }
    }
    
    // Wait for attributes to be available
    await sleep(2000);
    
    // Create indexes
    if (indexes && indexes.length > 0) {
      console.log(`   🔍 Indexes (${indexes.length}):`);
      for (const index of indexes) {
        await ensureIndex(databaseId, id, index);
      }
    }
    
  } catch (err) {
    console.error(`   ✗ Error: ${err.message}`);
  }
}

// Collection Definitions
const COLLECTIONS = [
  {
    id: 'users',
    name: 'Users',
    permissions: ['read("any")', 'create("users")', 'update("users")', 'delete("label:admin")'],
    documentSecurity: true,
    attributes: [
      { key: 'email', type: 'string', size: 255, required: true },
      { key: 'display_name', type: 'string', size: 255, required: true },
      { key: 'photo_url', type: 'string', size: 2000, required: false },
      { key: 'role', type: 'enum', elements: ['student', 'teacher', 'admin'], required: true, defaultValue: 'student' },
      { key: 'department', type: 'string', size: 100, required: false },
      { key: 'year', type: 'string', size: 20, required: false },
      { key: 'shift', type: 'string', size: 50, required: false },
      { key: 'group', type: 'string', size: 10, required: false },
      { key: 'class_roll', type: 'string', size: 20, required: false },
      { key: 'academic_session', type: 'string', size: 50, required: false },
      { key: 'phone_number', type: 'string', size: 20, required: false },
      { key: 'is_active', type: 'boolean', required: false, defaultValue: true },
      { key: 'created_at', type: 'datetime', required: true },
      { key: 'updated_at', type: 'datetime', required: true },
    ],
    indexes: [
      { key: 'email_unique', type: 'unique', attributes: ['email'] },
      { key: 'role_idx', type: 'key', attributes: ['role'] },
      { key: 'department_idx', type: 'key', attributes: ['department'] },
    ],
  },
  
  {
    id: 'notices',
    name: 'Notices',
    permissions: ['read("any")', 'create("label:teacher")', 'create("label:admin")', 'update("users")', 'delete("label:admin")'],
    attributes: [
      { key: 'title', type: 'string', size: 500, required: true },
      { key: 'content', type: 'string', size: 10000, required: true },
      { key: 'type', type: 'enum', elements: ['announcement', 'event', 'urgent'], required: true, defaultValue: 'announcement' },
      { key: 'author_id', type: 'string', size: 255, required: true },
      { key: 'author_name', type: 'string', size: 255, required: false },
      { key: 'target_audience', type: 'string', size: 100, required: false, array: true },
      { key: 'is_active', type: 'boolean', required: false, defaultValue: true },
      { key: 'expires_at', type: 'datetime', required: false },
      { key: 'created_at', type: 'datetime', required: true },
      { key: 'updated_at', type: 'datetime', required: false },
    ],
    indexes: [
      { key: 'type_idx', type: 'key', attributes: ['type'] },
      { key: 'is_active_idx', type: 'key', attributes: ['is_active'] },
      { key: 'created_at_idx', type: 'key', attributes: ['created_at'], orders: ['DESC'] },
    ],
  },
  
  {
    id: 'messages',
    name: 'Messages',
    permissions: ['read("users")', 'create("users")', 'update("users")', 'delete("users")'],
    documentSecurity: true,
    attributes: [
      { key: 'sender_id', type: 'string', size: 255, required: true },
      { key: 'recipient_id', type: 'string', size: 255, required: true },
      { key: 'content', type: 'string', size: 5000, required: true },
      { key: 'type', type: 'enum', elements: ['text', 'image', 'file', 'video', 'audio', 'document'], required: true, defaultValue: 'text' },
      { key: 'attachment_url', type: 'url', required: false },
      { key: 'is_read', type: 'boolean', required: true, defaultValue: false },
      { key: 'created_at', type: 'datetime', required: true },
      // Group chat support fields
      { key: 'group_id', type: 'string', size: 255, required: false },
      { key: 'is_group_message', type: 'boolean', required: true, defaultValue: false },
      { key: 'sender_display_name', type: 'string', size: 255, required: false },
      { key: 'sender_photo_url', type: 'string', size: 2000, required: false },
      { key: 'mention_ids', type: 'string', size: 255, required: false, array: true },
      { key: 'reply_to_message_id', type: 'string', size: 255, required: false },
      // Note: reactions field removed due to attribute limit
    ],
    indexes: [
      { key: 'sender_idx', type: 'key', attributes: ['sender_id'] },
      { key: 'recipient_idx', type: 'key', attributes: ['recipient_id'] },
      { key: 'created_at_idx', type: 'key', attributes: ['created_at'], orders: ['DESC'] },
      { key: 'group_idx', type: 'key', attributes: ['group_id'] },
      { key: 'is_group_idx', type: 'key', attributes: ['is_group_message'] },
    ],
  },
  
  {
    id: 'groups',
    name: 'Groups',
    permissions: ['read("users")', 'create("users")', 'update("users")', 'delete("users")'],
    documentSecurity: true,
    attributes: [
      { key: 'name', type: 'string', size: 255, required: true },
      { key: 'description', type: 'string', size: 2000, required: false },
      { key: 'owner_id', type: 'string', size: 255, required: true },
      { key: 'group_type', type: 'enum', elements: ['class', 'department', 'project', 'interest'], required: false, defaultValue: 'interest' },
      { key: 'avatar_url', type: 'url', required: false },
      { key: 'member_count', type: 'integer', required: false, defaultValue: 1 },
      { key: 'is_active', type: 'boolean', required: false, defaultValue: true },
      { key: 'created_at', type: 'datetime', required: true },
      { key: 'updated_at', type: 'datetime', required: true },
      { key: 'metadata', type: 'string', size: 2000, required: false }, // JSON string
    ],
    indexes: [
      { key: 'owner_idx', type: 'key', attributes: ['owner_id'] },
      { key: 'type_idx', type: 'key', attributes: ['group_type'] },
      { key: 'active_idx', type: 'key', attributes: ['is_active'] },
      { key: 'created_at_idx', type: 'key', attributes: ['created_at'], orders: ['DESC'] },
    ],
  },
  
  {
    id: 'group_members',
    name: 'GroupMembers',
    permissions: ['read("users")', 'create("users")', 'update("users")', 'delete("users")'],
    documentSecurity: true,
    attributes: [
      { key: 'group_id', type: 'string', size: 255, required: true },
      { key: 'user_id', type: 'string', size: 255, required: true },
      { key: 'role', type: 'enum', elements: ['admin', 'moderator', 'member'], required: false, defaultValue: 'member' },
      { key: 'nickname', type: 'string', size: 255, required: false },
      { key: 'status', type: 'enum', elements: ['active', 'muted', 'blocked', 'inactive'], required: false, defaultValue: 'active' },
      { key: 'joined_at', type: 'datetime', required: true },
      { key: 'last_seen_at', type: 'datetime', required: false },
      { key: 'unread_count', type: 'integer', required: false, defaultValue: 0 },
      { key: 'metadata', type: 'string', size: 2000, required: false }, // JSON string
    ],
    indexes: [
      { key: 'group_idx', type: 'key', attributes: ['group_id'] },
      { key: 'user_idx', type: 'key', attributes: ['user_id'] },
      { key: 'role_idx', type: 'key', attributes: ['role'] },
      { key: 'status_idx', type: 'key', attributes: ['status'] },
      { key: 'joined_idx', type: 'key', attributes: ['joined_at'], orders: ['DESC'] },
    ],
  },
  
  {
    id: 'notifications',
    name: 'Notifications',
    permissions: ['read("users")', 'create("users")', 'update("users")', 'delete("users")'],
    documentSecurity: true,
    attributes: [
      { key: 'user_id', type: 'string', size: 255, required: true },
      { key: 'title', type: 'string', size: 255, required: true },
      { key: 'body', type: 'string', size: 2000, required: true },
      { key: 'type', type: 'string', size: 50, required: true },
      { key: 'data', type: 'string', size: 2000, required: false }, // JSON string
      { key: 'is_read', type: 'boolean', required: true, defaultValue: false },
      { key: 'created_at', type: 'datetime', required: true },
    ],
    indexes: [
      { key: 'user_idx', type: 'key', attributes: ['user_id'] },
      { key: 'is_read_idx', type: 'key', attributes: ['is_read'] },
      { key: 'created_at_idx', type: 'key', attributes: ['created_at'], orders: ['DESC'] },
    ],
  },
  
  {
    id: 'books',
    name: 'Books',
    permissions: ['read("any")', 'create("label:teacher")', 'create("label:admin")', 'update("label:teacher")', 'update("label:admin")', 'delete("label:admin")'],
    attributes: [
      { key: 'title', type: 'string', size: 500, required: true },
      { key: 'author', type: 'string', size: 255, required: true },
      { key: 'isbn', type: 'string', size: 50, required: false },
      { key: 'category', type: 'enum', elements: ['textbook', 'reference', 'fiction', 'technical', 'research', 'magazine', 'journal', 'other'], required: true, defaultValue: 'textbook' },
      { key: 'description', type: 'string', size: 2000, required: false },
      { key: 'cover_url', type: 'url', required: false },
      { key: 'file_url', type: 'url', required: false },
      { key: 'status', type: 'enum', elements: ['available', 'borrowed', 'reserved', 'maintenance'], required: true, defaultValue: 'available' },
      { key: 'publisher', type: 'string', size: 255, required: false },
      { key: 'edition', type: 'string', size: 50, required: false },
      { key: 'publication_year', type: 'integer', required: false, defaultValue: 0 },
      { key: 'total_copies', type: 'integer', required: false, defaultValue: 1 },
      { key: 'available_copies', type: 'integer', required: false, defaultValue: 1 },
      { key: 'department', type: 'string', size: 100, required: false },
      { key: 'tags', type: 'string', size: 500, required: false },
      { key: 'created_at', type: 'datetime', required: true },
      { key: 'updated_at', type: 'datetime', required: false },
      { key: 'added_by', type: 'string', size: 255, required: true },
    ],
    indexes: [
      { key: 'category_idx', type: 'key', attributes: ['category'] },
      { key: 'status_idx', type: 'key', attributes: ['status'] },
      { key: 'department_idx', type: 'key', attributes: ['department'] },
      { key: 'title_fulltext', type: 'fulltext', attributes: ['title'] },
      { key: 'author_fulltext', type: 'fulltext', attributes: ['author'] },
    ],
  },
  
  {
    id: 'book_borrows',
    name: 'BookBorrows',
    permissions: ['read("users")', 'create("users")', 'update("label:teacher")', 'update("label:admin")', 'delete("label:admin")'],
    attributes: [
      { key: 'book_id', type: 'string', size: 255, required: true },
      { key: 'user_id', type: 'string', size: 255, required: true },
      { key: 'user_name', type: 'string', size: 255, required: true },
      { key: 'user_email', type: 'email', required: true },
      { key: 'borrow_date', type: 'datetime', required: true },
      { key: 'due_date', type: 'datetime', required: true },
      { key: 'return_date', type: 'datetime', required: false },
      { key: 'status', type: 'enum', elements: ['borrowed', 'returned', 'overdue'], required: true, defaultValue: 'borrowed' },
      { key: 'notes', type: 'string', size: 1000, required: false },
    ],
    indexes: [
      { key: 'book_idx', type: 'key', attributes: ['book_id'] },
      { key: 'user_idx', type: 'key', attributes: ['user_id'] },
      { key: 'status_idx', type: 'key', attributes: ['status'] },
      { key: 'due_date_idx', type: 'key', attributes: ['due_date'] },
    ],
  },
  
  {
    id: 'events',
    name: 'Events',
    permissions: ['read("any")', 'create("label:teacher")', 'create("label:admin")', 'update("users")', 'delete("label:admin")'],
    attributes: [
      { key: 'title', type: 'string', size: 255, required: true },
      { key: 'description', type: 'string', size: 5000, required: true },
      { key: 'type', type: 'enum', elements: ['seminar', 'workshop', 'exam', 'sports', 'cultural', 'other'], required: false, defaultValue: 'seminar' },
      { key: 'start_date', type: 'datetime', required: true },
      { key: 'end_date', type: 'datetime', required: true },
      { key: 'venue', type: 'string', size: 255, required: true },
      { key: 'organizer', type: 'string', size: 255, required: true },
      { key: 'image_url', type: 'url', required: false },
      { key: 'is_registration_required', type: 'boolean', required: false, defaultValue: false },
      { key: 'max_participants', type: 'integer', required: false },
      { key: 'current_participants', type: 'integer', required: false, defaultValue: 0 },
      { key: 'registration_link', type: 'url', required: false },
      { key: 'target_audience', type: 'string', size: 100, required: false, array: true },
      { key: 'created_at', type: 'datetime', required: true },
      { key: 'updated_at', type: 'datetime', required: false },
    ],
    indexes: [
      { key: 'type_idx', type: 'key', attributes: ['type'] },
      { key: 'start_date_idx', type: 'key', attributes: ['start_date'] },
    ],
  },
  
  {
    id: 'assignments',
    name: 'Assignments',
    permissions: ['read("users")', 'create("label:teacher")', 'create("label:admin")', 'update("users")', 'delete("label:admin")'],
    attributes: [
      { key: 'title', type: 'string', size: 255, required: true },
      { key: 'description', type: 'string', size: 5000, required: true },
      { key: 'subject', type: 'string', size: 100, required: true },
      { key: 'teacher_id', type: 'string', size: 255, required: true },
      { key: 'teacher_name', type: 'string', size: 255, required: true },
      { key: 'due_date', type: 'datetime', required: true },
      { key: 'max_marks', type: 'integer', required: false, defaultValue: 100 },
      { key: 'attachment_url', type: 'url', required: false },
      { key: 'target_groups', type: 'string', size: 100, required: false, array: true },
      { key: 'department', type: 'string', size: 100, required: false },
      { key: 'created_at', type: 'datetime', required: true },
      { key: 'updated_at', type: 'datetime', required: false },
    ],
    indexes: [
      { key: 'teacher_idx', type: 'key', attributes: ['teacher_id'] },
      { key: 'due_date_idx', type: 'key', attributes: ['due_date'] },
      { key: 'department_idx', type: 'key', attributes: ['department'] },
    ],
  },
  
  {
    id: 'timetables',
    name: 'Timetables',
    permissions: ['read("any")', 'create("label:teacher")', 'create("label:admin")', 'update("label:teacher")', 'update("label:admin")', 'delete("label:admin")'],
    attributes: [
      { key: 'class_name', type: 'string', size: 100, required: true },
      { key: 'department', type: 'string', size: 100, required: true },
      { key: 'shift', type: 'string', size: 50, required: true },
      { key: 'periods', type: 'string', size: 10000, required: true }, // JSON string
      { key: 'created_at', type: 'datetime', required: true },
      { key: 'updated_at', type: 'datetime', required: false },
    ],
    indexes: [
      { key: 'department_idx', type: 'key', attributes: ['department'] },
      { key: 'shift_idx', type: 'key', attributes: ['shift'] },
    ],
  },
  
  {
    id: 'study_groups',
    name: 'StudyGroups',
    permissions: ['read("any")', 'create("users")', 'update("users")', 'delete("users")'],
    documentSecurity: true,
    attributes: [
      { key: 'name', type: 'string', size: 255, required: true },
      { key: 'description', type: 'string', size: 2000, required: false },
      { key: 'subject', type: 'string', size: 100, required: true },
      { key: 'creator_id', type: 'string', size: 255, required: true },
      { key: 'members', type: 'string', size: 255, required: true, array: true },
      { key: 'max_members', type: 'integer', required: false },
      { key: 'is_public', type: 'boolean', required: false, defaultValue: true },
      { key: 'created_at', type: 'datetime', required: true },
      { key: 'updated_at', type: 'datetime', required: false },
    ],
    indexes: [
      { key: 'subject_idx', type: 'key', attributes: ['subject'] },
      { key: 'is_public_idx', type: 'key', attributes: ['is_public'] },
    ],
  },
  
  {
    id: 'approval_requests',
    name: 'ApprovalRequests',
    permissions: ['read("label:admin")', 'read("label:teacher")', 'create("users")', 'update("label:admin")', 'update("label:teacher")', 'delete("label:admin")'],
    attributes: [
      { key: 'user_id', type: 'string', size: 255, required: true },
      { key: 'request_type', type: 'string', size: 100, required: true },
      { key: 'status', type: 'enum', elements: ['pending', 'approved', 'rejected'], required: true, defaultValue: 'pending' },
      { key: 'data', type: 'string', size: 5000, required: false }, // JSON string
      { key: 'created_at', type: 'datetime', required: true },
      { key: 'updated_at', type: 'datetime', required: true },
    ],
    indexes: [
      { key: 'user_idx', type: 'key', attributes: ['user_id'] },
      { key: 'status_idx', type: 'key', attributes: ['status'] },
    ],
  },
  
  {
    id: 'user_activity',
    name: 'UserActivity',
    permissions: ['read("label:admin")', 'create("users")', 'update("label:admin")', 'delete("label:admin")'],
    attributes: [
      { key: 'user_id', type: 'string', size: 255, required: false },
      { key: 'activity_type', type: 'string', size: 100, required: true },
      { key: 'data', type: 'string', size: 2000, required: false }, // JSON string
      { key: 'created_at', type: 'datetime', required: true },
    ],
    indexes: [
      { key: 'user_idx', type: 'key', attributes: ['user_id'] },
      { key: 'activity_type_idx', type: 'key', attributes: ['activity_type'] },
      { key: 'created_at_idx', type: 'key', attributes: ['created_at'], orders: ['DESC'] },
    ],
  },
];

// Storage Bucket Definitions
const BUCKETS = [
  {
    id: 'profile-images',
    name: 'Profile Images',
    permissions: ['read("any")', 'create("users")', 'update("user:{userId}")', 'delete("user:{userId}")'],
    fileSecurity: true,
    enabled: true,
    maximumFileSize: 5 * 1024 * 1024, // 5 MB
    allowedFileExtensions: ['jpg', 'jpeg', 'png', 'gif'],
    encryption: true,
    antivirus: true,
  },
  {
    id: 'notice-attachments',
    name: 'Notice Attachments',
    permissions: ['read("any")', 'create("label:teacher")', 'create("label:admin")', 'delete("label:admin")'],
    fileSecurity: true,
    enabled: true,
    maximumFileSize: 10 * 1024 * 1024, // 10 MB
    allowedFileExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    encryption: true,
    antivirus: true,
  },
  {
    id: 'message-attachments',
    name: 'Message Attachments',
    permissions: ['read("user:{userId}")', 'create("users")', 'delete("user:{userId}")'],
    fileSecurity: true,
    enabled: true,
    maximumFileSize: 25 * 1024 * 1024, // 25 MB
    allowedFileExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'xls', 'xlsx'],
    encryption: true,
    antivirus: true,
  },
  {
    id: 'book-covers',
    name: 'Book Covers',
    permissions: ['read("any")', 'create("label:teacher")', 'create("label:admin")', 'delete("label:admin")'],
    fileSecurity: true,
    enabled: true,
    maximumFileSize: 2 * 1024 * 1024, // 2 MB
    allowedFileExtensions: ['jpg', 'jpeg', 'png'],
    encryption: false,
    antivirus: true,
  },
  {
    id: 'book-files',
    name: 'Book Files',
    permissions: ['read("users")', 'create("label:teacher")', 'create("label:admin")', 'delete("label:admin")'],
    fileSecurity: true,
    enabled: true,
    maximumFileSize: 100 * 1024 * 1024, // 100 MB
    allowedFileExtensions: ['pdf'],
    encryption: true,
    antivirus: true,
  },
  {
    id: 'assignment-files',
    name: 'Assignment Files',
    permissions: ['read("users")', 'create("label:teacher")', 'create("label:admin")', 'delete("label:admin")'],
    fileSecurity: true,
    enabled: true,
    maximumFileSize: 50 * 1024 * 1024, // 50 MB
    allowedFileExtensions: ['pdf', 'doc', 'docx', 'zip'],
    encryption: true,
    antivirus: true,
  },
];

// Helper: Create or update bucket
async function ensureBucket(bucket) {
  try {
    const { id, name, permissions, fileSecurity, enabled, maximumFileSize, allowedFileExtensions, encryption, antivirus } = bucket;
    
    console.log(`\n🗂️  Bucket: ${name} (${id})`);
    
    // Check if bucket exists
    let bucketExists = false;
    try {
      await storage.getBucket(id);
      bucketExists = true;
      console.log(`   ✓ Bucket exists`);
    } catch (err) {
      if (err.code !== 404) throw err;
    }
    
    // Create bucket if doesn't exist
    if (!bucketExists) {
      await storage.createBucket(
        id,
        name,
        permissions || [],
        fileSecurity !== undefined ? fileSecurity : false,
        enabled !== undefined ? enabled : true,
        maximumFileSize,
        allowedFileExtensions,
        undefined, // compression
        encryption !== undefined ? encryption : true,
        antivirus !== undefined ? antivirus : true
      );
      console.log(`   ✓ Bucket created`);
      console.log(`      Max size: ${(maximumFileSize / 1024 / 1024).toFixed(0)} MB`);
      console.log(`      Extensions: ${allowedFileExtensions.join(', ')}`);
      await sleep(500);
    }
    
  } catch (err) {
    console.error(`   ✗ Error: ${err.message}`);
  }
}

// Main execution
async function main() {
  console.log('\n╔══════════════════════════════════════════════════════════════╗');
  console.log('║   Appwrite Database Setup - RPI Communication App           ║');
  console.log('╚══════════════════════════════════════════════════════════════╝\n');
  console.log(`📍 Endpoint: ${ENDPOINT}`);
  console.log(`🗄️  Database: ${DATABASE_ID}`);
  console.log(`🔑 Project: ${PROJECT_ID}\n`);
  
  // Check if database exists
  try {
    await databases.get(DATABASE_ID);
    console.log('✓ Database exists\n');
  } catch (err) {
    if (err.code === 404) {
      console.log('⚠️  Database not found. Creating...');
      await databases.create(DATABASE_ID, 'RPI Communication');
      console.log('✓ Database created\n');
      await sleep(1000);
    } else {
      throw err;
    }
  }
  
  // Create/update collections
  console.log('═══════════════════════════════════════════════════════════════');
  console.log('COLLECTIONS');
  console.log('═══════════════════════════════════════════════════════════════');
  
  for (const collection of COLLECTIONS) {
    await ensureCollection(DATABASE_ID, collection);
  }
  
  // Create/update storage buckets
  console.log('\n═══════════════════════════════════════════════════════════════');
  console.log('STORAGE BUCKETS');
  console.log('═══════════════════════════════════════════════════════════════');
  
  for (const bucket of BUCKETS) {
    await ensureBucket(bucket);
  }
  
  console.log('\n╔══════════════════════════════════════════════════════════════╗');
  console.log('║                    SETUP COMPLETE! ✅                         ║');
  console.log('╚══════════════════════════════════════════════════════════════╝\n');
  console.log('📊 Summary:');
  console.log(`   - Collections: ${COLLECTIONS.length}`);
  console.log(`   - Storage Buckets: ${BUCKETS.length}`);
  console.log('\n✨ Your Appwrite database is ready for production!\n');
}

// Run the script
main().catch(err => {
  console.error('\n❌ Fatal error:', err.message);
  console.error(err.stack);
  process.exit(1);
});
