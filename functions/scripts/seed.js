#!/usr/bin/env node

const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp();
const db = admin.firestore();

// Sample data for seeding
const SAMPLE_DATA = {
  users: [
    {
      uid: 'admin1',
      email: 'admin@campus.edu',
      displayName: 'John Admin',
      photoURL: '',
      role: 'admin',
      department: 'Administration',
      year: '',
      isActive: true,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now()
    },
    {
      uid: 'teacher1',
      email: 'prof.smith@campus.edu',
      displayName: 'Dr. Sarah Smith',
      photoURL: '',
      role: 'teacher',
      department: 'Computer Science',
      year: '',
      isActive: true,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now()
    },
    {
      uid: 'teacher2',
      email: 'prof.johnson@campus.edu',
      displayName: 'Prof. Michael Johnson',
      photoURL: '',
      role: 'teacher',
      department: 'Mathematics',
      year: '',
      isActive: true,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now()
    },
    {
      uid: 'student1',
      email: 'alice.wilson@student.campus.edu',
      displayName: 'Alice Wilson',
      photoURL: '',
      role: 'student',
      department: 'Computer Science',
      year: '3rd Year',
      isActive: true,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now()
    },
    {
      uid: 'student2',
      email: 'bob.brown@student.campus.edu',
      displayName: 'Bob Brown',
      photoURL: '',
      role: 'student',
      department: 'Mathematics',
      year: '2nd Year',
      isActive: true,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now()
    },
    {
      uid: 'student3',
      email: 'emma.davis@student.campus.edu',
      displayName: 'Emma Davis',
      photoURL: '',
      role: 'student',
      department: 'Computer Science',
      year: '1st Year',
      isActive: true,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now()
    }
  ],

  notices: [
    {
      title: 'Welcome to New Academic Year 2024',
      content: 'We are excited to welcome all students to the new academic year. Please check your course schedules and attend the orientation sessions.',
      type: 'announcement',
      targetAudience: 'all',
      authorId: 'admin1',
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now(),
      expiresAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)), // 30 days from now
      isActive: true
    },
    {
      title: 'Computer Science Department Meeting',
      content: 'All Computer Science students are required to attend the department meeting on Friday at 2 PM in Room 101.',
      type: 'event',
      targetAudience: 'students',
      authorId: 'teacher1',
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now(),
      expiresAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)), // 7 days from now
      isActive: true
    },
    {
      title: 'Library System Maintenance',
      content: 'The library system will be down for maintenance on Saturday from 2 AM to 6 AM. Plan your research activities accordingly.',
      type: 'urgent',
      targetAudience: 'all',
      authorId: 'admin1',
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now(),
      expiresAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 3 * 24 * 60 * 60 * 1000)), // 3 days from now
      isActive: true
    },
    {
      title: 'Faculty Meeting - Monthly Review',
      content: 'Monthly faculty meeting to discuss curriculum updates and student progress. All teachers are required to attend.',
      type: 'announcement',
      targetAudience: 'teachers',
      authorId: 'admin1',
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now(),
      expiresAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 5 * 24 * 60 * 60 * 1000)), // 5 days from now
      isActive: true
    }
  ],

  messages: [
    {
      senderId: 'teacher1',
      recipientId: 'student1',
      content: 'Hi Alice, please submit your assignment by tomorrow. Let me know if you have any questions.',
      type: 'text',
      createdAt: admin.firestore.Timestamp.now(),
      read: false
    },
    {
      senderId: 'student1',
      recipientId: 'teacher1',
      content: 'Thank you for the reminder, Professor. I will submit it by end of day.',
      type: 'text',
      createdAt: admin.firestore.Timestamp.now(),
      read: true,
      readAt: admin.firestore.Timestamp.now()
    },
    {
      senderId: 'admin1',
      recipientId: 'student2',
      content: 'Your enrollment for the Mathematics advanced course has been approved. Welcome!',
      type: 'text',
      createdAt: admin.firestore.Timestamp.now(),
      read: false
    },
    {
      senderId: 'student3',
      recipientId: 'teacher2',
      content: 'Could you please clarify the homework requirements for Chapter 5?',
      type: 'text',
      createdAt: admin.firestore.Timestamp.now(),
      read: false
    },
    {
      senderId: 'teacher2',
      recipientId: 'student3',
      content: 'Sure Emma, please solve problems 1-10 from Chapter 5. Show all working steps.',
      type: 'text',
      createdAt: admin.firestore.Timestamp.now(),
      read: false
    }
  ],

  notifications: [
    {
      userId: 'student1',
      type: 'notice',
      title: 'New Notice: Computer Science Department Meeting',
      body: 'All Computer Science students are required to attend...',
      data: {
        noticeId: 'notice_cs_meeting',
        type: 'event'
      },
      createdAt: admin.firestore.Timestamp.now(),
      read: false
    },
    {
      userId: 'student2',
      type: 'message',
      title: 'New Message',
      body: 'Your enrollment for the Mathematics...',
      data: {
        type: 'message',
        senderId: 'admin1'
      },
      createdAt: admin.firestore.Timestamp.now(),
      read: false
    },
    {
      userId: 'teacher1',
      type: 'message',
      title: 'New Message from Alice Wilson',
      body: 'Thank you for the reminder, Professor...',
      data: {
        type: 'message',
        senderId: 'student1'
      },
      createdAt: admin.firestore.Timestamp.now(),
      read: true
    },
    {
      userId: 'teacher2',
      type: 'message',
      title: 'New Message from Emma Davis',
      body: 'Could you please clarify the homework...',
      data: {
        type: 'message',
        senderId: 'student3'
      },
      createdAt: admin.firestore.Timestamp.now(),
      read: false
    }
  ]
};

/**
 * Deletes all existing data from the database collections to ensure a clean state
 */
async function clearDatabase() {
  console.log('🧹 Clearing existing data from database...');
  
  const collections = ['users', 'notices', 'messages', 'notifications'];
  
  for (const collectionName of collections) {
    console.log(`  - Clearing ${collectionName} collection...`);
    
    const collectionRef = db.collection(collectionName);
    const snapshot = await collectionRef.get();
    
    if (snapshot.empty) {
      console.log(`    ✅ ${collectionName} collection is already empty`);
      continue;
    }
    
    // Delete documents in batches to avoid quota limits
    const batchSize = 100;
    const batches = [];
    
    for (let i = 0; i < snapshot.docs.length; i += batchSize) {
      const batch = db.batch();
      const batchDocs = snapshot.docs.slice(i, i + batchSize);
      
      batchDocs.forEach(doc => {
        batch.delete(doc.ref);
      });
      
      batches.push(batch);
    }
    
    // Execute all batches
    await Promise.all(batches.map(batch => batch.commit()));
    console.log(`    ✅ Deleted ${snapshot.docs.length} documents from ${collectionName}`);
  }
  
  console.log('✅ Database cleared successfully');
}

/**
 * Imports sample data into the database
 */
async function seedDatabase() {
  console.log('🌱 Seeding database with sample data...');
  
  // Seed users
  console.log('  - Seeding users...');
  const userBatch = db.batch();
  SAMPLE_DATA.users.forEach(user => {
    const userRef = db.collection('users').doc(user.uid);
    userBatch.set(userRef, user);
  });
  await userBatch.commit();
  console.log(`    ✅ Added ${SAMPLE_DATA.users.length} users`);
  
  // Seed notices
  console.log('  - Seeding notices...');
  const noticeBatch = db.batch();
  SAMPLE_DATA.notices.forEach(notice => {
    const noticeRef = db.collection('notices').doc();
    noticeBatch.set(noticeRef, notice);
  });
  await noticeBatch.commit();
  console.log(`    ✅ Added ${SAMPLE_DATA.notices.length} notices`);
  
  // Seed messages
  console.log('  - Seeding messages...');
  const messageBatch = db.batch();
  SAMPLE_DATA.messages.forEach(message => {
    const messageRef = db.collection('messages').doc();
    messageBatch.set(messageRef, message);
  });
  await messageBatch.commit();
  console.log(`    ✅ Added ${SAMPLE_DATA.messages.length} messages`);
  
  // Seed notifications
  console.log('  - Seeding notifications...');
  const notificationBatch = db.batch();
  SAMPLE_DATA.notifications.forEach(notification => {
    const notificationRef = db.collection('notifications').doc();
    notificationBatch.set(notificationRef, notification);
  });
  await notificationBatch.commit();
  console.log(`    ✅ Added ${SAMPLE_DATA.notifications.length} notifications`);
  
  console.log('✅ Database seeded successfully');
}

/**
 * Main function to run the seeding process
 */
async function main() {
  try {
    console.log('🚀 Starting database seeding process...');
    console.log('=====================================');
    
    // Step 1: Clear existing data
    await clearDatabase();
    console.log('');
    
    // Step 2: Seed with sample data
    await seedDatabase();
    console.log('');
    
    console.log('=====================================');
    console.log('🎉 Database seeding completed successfully!');
    console.log('');
    console.log('📊 Summary:');
    console.log(`   - Users: ${SAMPLE_DATA.users.length}`);
    console.log(`   - Notices: ${SAMPLE_DATA.notices.length}`);
    console.log(`   - Messages: ${SAMPLE_DATA.messages.length}`);
    console.log(`   - Notifications: ${SAMPLE_DATA.notifications.length}`);
    
  } catch (error) {
    console.error('❌ Error during seeding process:', error);
    process.exit(1);
  } finally {
    // Clean up
    process.exit(0);
  }
}

// Run the seeding process
if (require.main === module) {
  main();
}

module.exports = {
  clearDatabase,
  seedDatabase,
  SAMPLE_DATA
};