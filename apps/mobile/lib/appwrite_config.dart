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
  static const String noticesCollectionId = 'notices';
  static const String messagesCollectionId = 'messages';
  static const String notificationsCollectionId = 'notifications';
  static const String approvalRequestsCollectionId = 'approval_requests';
  static const String userActivityCollectionId = 'user_activity';

  // Storage bucket IDs
  static const String profileImagesBucketId = 'profile-images';
  static const String noticeAttachmentsBucketId = 'notice-attachments';
  static const String messageAttachmentsBucketId = 'message-attachments';
}
