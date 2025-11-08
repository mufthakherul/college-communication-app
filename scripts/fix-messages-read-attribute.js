#!/usr/bin/env node

/**
 * Fix Messages Collection - Rename is_read to read
 * 
 * The Flutter app expects a 'read' attribute but the database has 'is_read'.
 * This script fixes the mismatch.
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

async function fixMessagesCollection() {
  console.log('\n🔧 Fixing Messages Collection Attribute...\n');
  
  try {
    // Step 1: Check if 'read' attribute already exists
    console.log('Checking current attributes...');
    const collection = await databases.getCollection(DATABASE_ID, 'messages');
    const hasRead = collection.attributes.some(attr => attr.key === 'read');
    const hasIsRead = collection.attributes.some(attr => attr.key === 'is_read');
    
    console.log(`  - 'read' attribute exists: ${hasRead}`);
    console.log(`  - 'is_read' attribute exists: ${hasIsRead}\n`);
    
    if (hasRead) {
      console.log('✅ The collection already has the correct \'read\' attribute!');
      return;
    }
    
    // Step 2: Delete is_read if it exists
    if (hasIsRead) {
      console.log('Deleting \'is_read\' attribute...');
      try {
        await databases.deleteAttribute(DATABASE_ID, 'messages', 'is_read');
        console.log('✅ Deleted \'is_read\' attribute');
        
        // Wait for deletion to complete
        console.log('Waiting for attribute deletion to complete (5 seconds)...');
        await new Promise(resolve => setTimeout(resolve, 5000));
      } catch (err) {
        console.error('❌ Error deleting is_read:', err.message);
        throw err;
      }
    }
    
    // Step 3: Create 'read' attribute
    console.log('\nCreating \'read\' attribute...');
    try {
      await databases.createBooleanAttribute(
        DATABASE_ID,
        'messages',
        'read',
        false,  // required = false (we have default value)
        false   // default value
      );
      console.log('✅ Created \'read\' attribute with default value: false');
      
      // Wait for attribute creation to complete
      console.log('Waiting for attribute creation to complete (5 seconds)...');
      await new Promise(resolve => setTimeout(resolve, 5000));
    } catch (err) {
      console.error('❌ Error creating read attribute:', err.message);
      throw err;
    }
    
    // Step 4: Verify the fix
    console.log('\nVerifying the fix...');
    const updatedCollection = await databases.getCollection(DATABASE_ID, 'messages');
    const readAttr = updatedCollection.attributes.find(attr => attr.key === 'read');
    
    if (readAttr) {
      console.log('✅ Verification successful!');
      console.log(`   - Attribute: ${readAttr.key}`);
      console.log(`   - Type: ${readAttr.type}`);
      console.log(`   - Required: ${readAttr.required}`);
      console.log(`   - Default: ${readAttr.default}`);
    } else {
      console.log('❌ Verification failed - attribute not found');
    }
    
    console.log('\n🎉 Messages collection has been fixed!');
    console.log('   You can now send messages with the \'read\' attribute.\n');
    
  } catch (err) {
    console.error('\n❌ Error:', err.message);
    process.exit(1);
  }
}

fixMessagesCollection();
