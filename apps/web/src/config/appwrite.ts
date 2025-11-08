/**
 * Appwrite configuration for RPI Teacher Dashboard
 * 
 * This uses the same Appwrite project as the mobile app
 */

export const AppwriteConfig = {
  // Project credentials
  endpoint: 'https://sgp.cloud.appwrite.io/v1',
  projectId: '6904cfb1001e5253725b',

  // Database configuration
  databaseId: 'rpi_communication',

  // Collection IDs
  collections: {
    users: 'users',
    notices: 'notices',
    messages: 'messages',
    messagesPending: 'messages_pending',
    notifications: 'notifications',
    approvalRequests: 'approval_requests',
    userActivity: 'user_activity',
    books: 'books',
    bookBorrows: 'book_borrows',
    assignments: 'assignments',
    assignmentSubmissions: 'assignment_submissions',
    timetables: 'timetables',
    studyGroups: 'study_groups',
    events: 'events',
  },

  // Storage bucket IDs
  buckets: {
    profileImages: 'profile-images',
    noticeAttachments: 'notice-attachments',
    messageAttachments: 'message-attachments',
    bookCovers: 'book-covers',
    bookFiles: 'book-files',
    assignmentFiles: 'assignment-files',
    // Releases bucket: store APK/AAB release artifacts here and reference by fileId
    releases: 'releases',
  },
} as const;
