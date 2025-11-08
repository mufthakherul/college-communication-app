import 'package:appwrite/appwrite.dart';
import 'package:campus_mesh/models/user_profile_model.dart';
import 'package:campus_mesh/appwrite_config.dart';

/// Service for managing user profiles with role-specific data
class UserProfileService {
  final Databases _databases;

  UserProfileService(Client client)
      : _databases = Databases(client);

  /// Get user profile by user ID
  /// Returns null if profile doesn't exist
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.userProfilesCollectionId,
        queries: [
          Query.equal('user_id', userId),
          Query.limit(1),
        ],
      );

      if (response.documents.isEmpty) {
        return null;
      }

      return UserProfile.fromJson(response.documents.first.data);
    } catch (e) {
      if (e is AppwriteException && e.code == 404) {
        return null;
      }
      rethrow;
    }
  }

  /// Create a new user profile
  /// Automatically sets created_at timestamp
  Future<UserProfile> createUserProfile(UserProfile profile) async {
    try {
      final data = profile.toJson();
      data['created_at'] = DateTime.now().toIso8601String();
      
      final response = await _databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.userProfilesCollectionId,
        documentId: ID.unique(),
        data: data,
      );

      return UserProfile.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile by user ID
  /// Automatically sets updated_at timestamp
  /// Only updates provided fields (partial update supported)
  Future<UserProfile> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Get existing profile to find document ID
      final existingProfile = await getUserProfile(userId);
      if (existingProfile == null) {
        throw Exception('Profile not found for user: $userId');
      }

      // Add updated_at timestamp
      updates['updated_at'] = DateTime.now().toIso8601String();

      // Remove null values to avoid overwriting with nulls
      updates.removeWhere((key, value) => value == null);

      final response = await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.userProfilesCollectionId,
        documentId: existingProfile.id,
        data: updates,
      );

      return UserProfile.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user profile by user ID
  Future<void> deleteUserProfile(String userId) async {
    try {
      final existingProfile = await getUserProfile(userId);
      if (existingProfile == null) {
        throw Exception('Profile not found for user: $userId');
      }

      await _databases.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.userProfilesCollectionId,
        documentId: existingProfile.id,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get or create user profile
  /// Returns existing profile if found, otherwise creates a new one with default values
  Future<UserProfile> getOrCreateUserProfile(
    String userId,
    String role,
  ) async {
    final existingProfile = await getUserProfile(userId);
    if (existingProfile != null) {
      return existingProfile;
    }

    // Create default profile based on role
    final defaultProfile = UserProfile(
      id: '', // Will be set by Appwrite
      userId: userId,
      role: _parseRole(role),
    );

    return await createUserProfile(defaultProfile);
  }

  /// Helper to parse role string to UserRole enum
  UserRole _parseRole(String roleStr) {
    switch (roleStr.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'teacher':
        return UserRole.teacher;
      case 'student':
      default:
        return UserRole.student;
    }
  }

  /// Get all profiles for a specific role
  /// Useful for admin features (e.g., list all teachers)
  Future<List<UserProfile>> getProfilesByRole(UserRole role) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.userProfilesCollectionId,
        queries: [
          Query.equal('role', role.name),
        ],
      );

      return response.documents
          .map((doc) => UserProfile.fromJson(doc.data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Batch create profiles for multiple users
  /// Useful for initial data migration or bulk import
  Future<List<UserProfile>> createMultipleProfiles(
    List<UserProfile> profiles,
  ) async {
    final createdProfiles = <UserProfile>[];

    for (final profile in profiles) {
      try {
        final created = await createUserProfile(profile);
        createdProfiles.add(created);
      } catch (e) {
        print('Failed to create profile for user ${profile.userId}: $e');
        // Continue with other profiles
      }
    }

    return createdProfiles;
  }
}
