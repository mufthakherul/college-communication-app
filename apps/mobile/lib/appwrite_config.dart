/// Appwrite configuration for RPI Communication App
///
/// Educational benefits provided by Appwrite:
/// - Organization: GitHub Student Organization
/// - Project: rpi-communication
/// - Region: Singapore (sgp)

class AppwriteConfig {
  // Project credentials
  static const String endpoint = 'https://sgp.cloud.appwrite.io/v1';
  static const String projectId = '6904cfb1001e5253725b';

  // Database configuration
  static const String databaseId = 'rpi_communication';

  // Collection IDs
  static const String usersCollectionId = 'users';
  static const String userProfilesCollectionId = 'user_profiles';
  static const String noticesCollectionId = 'notices';
  static const String messagesCollectionId = 'messages';
  static const String messagesPendingCollectionId = 'messages_pending';
  static const String notificationsCollectionId = 'notifications';
  static const String approvalRequestsCollectionId = 'approval_requests';
  static const String userActivityCollectionId = 'user_activity';
  static const String booksCollectionId = 'books';
  static const String bookBorrowsCollectionId = 'book_borrows';
  static const String assignmentsCollectionId = 'assignments';
  static const String assignmentSubmissionsCollectionId =
      'assignment_submissions';
  static const String timetablesCollectionId = 'timetables';
  static const String studyGroupsCollectionId = 'study_groups';
  static const String eventsCollectionId = 'events';

  // Group chat collection IDs
  static const String groupsCollectionId = 'groups';
  static const String groupMembersCollectionId = 'group_members';

  // Storage bucket IDs
  static const String profileImagesBucketId = 'profile-images';
  static const String noticeAttachmentsBucketId = 'notice-attachments';
  static const String messageAttachmentsBucketId = 'message-attachments';
  static const String bookCoversBucketId = 'book-covers';
  static const String bookFilesBucketId = 'book-files';
  static const String assignmentFilesBucketId = 'assignment-files';
}
