import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';
import 'package:campus_mesh/models/notification_model.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/services/appwrite_service.dart';
import 'package:campus_mesh/services/website_scraper_service.dart';
import 'package:campus_mesh/appwrite_config.dart';
import 'dart:async';

/// Notification sources
enum NotificationSource {
  teacherAdmin, // Notifications from teachers/admin via Appwrite
  websiteNotices, // Notices scraped from school website
  all, // Both sources
}

class NotificationService {
  final _authService = AuthService();
  final _appwrite = AppwriteService();
  final _websiteScraper = WebsiteScraperService();

  // Get current user ID
  String? get _currentUserId => _authService.currentUserId;

  // Initialize notifications
  Future<void> initialize() async {
    if (kDebugMode) {
      debugPrint('Notification service initialized');
    }
    
    // Start periodic website scraping
    _websiteScraper.startPeriodicCheck();
  }

  // Get notifications for current user from specific source
  Stream<List<NotificationModel>> getNotifications({
    NotificationSource source = NotificationSource.all,
  }) async* {
    final userId = _currentUserId;
    if (userId == null) {
      yield [];
      return;
    }

    while (true) {
      try {
        final notifications = <NotificationModel>[];

        // Get notifications from Appwrite (teachers/admin)
        if (source == NotificationSource.teacherAdmin ||
            source == NotificationSource.all) {
          final appwriteNotifications = await _getAppwriteNotifications(userId);
          notifications.addAll(appwriteNotifications);
        }

        // Get notifications from website scraping
        if (source == NotificationSource.websiteNotices ||
            source == NotificationSource.all) {
          final websiteNotifications = await _getWebsiteNotifications(userId);
          notifications.addAll(websiteNotifications);
        }

        // Sort by created date (newest first)
        notifications.sort((a, b) {
          final aTime = a.createdAt;
          final bTime = b.createdAt;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });

        yield notifications;
      } catch (e) {
        debugPrint('Error getting notifications: $e');
        yield [];
      }

      await Future.delayed(const Duration(seconds: 10));
    }
  }

  // Get notifications from Appwrite database
  Future<List<NotificationModel>> _getAppwriteNotifications(String userId) async {
    try {
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.notificationsCollectionId,
        queries: [
          Query.equal('user_id', userId),
          Query.orderDesc('created_at'),
          Query.limit(50),
        ],
      );

      return response.documents
          .map((doc) => NotificationModel.fromJson(doc.data))
          .toList();
    } catch (e) {
      debugPrint('Error getting Appwrite notifications: $e');
      return [];
    }
  }

  // Get notifications from website scraping
  Future<List<NotificationModel>> _getWebsiteNotifications(String userId) async {
    try {
      final scrapedNotices = await _websiteScraper.getNotices();
      return _websiteScraper.toNotificationModels(scrapedNotices, userId);
    } catch (e) {
      debugPrint('Error getting website notifications: $e');
      return [];
    }
  }

  // Get unread notification count
  Stream<int> getUnreadCount({NotificationSource? source}) async* {
    final userId = _currentUserId;
    if (userId == null) {
      yield 0;
      return;
    }

    await for (final notifications in getNotifications(source: source ?? NotificationSource.all)) {
      final unreadCount = notifications.where((n) => !n.read).length;
      yield unreadCount;
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _appwrite.databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.notificationsCollectionId,
        documentId: notificationId,
        data: {'read': true},
      );
    } catch (e) {
      debugPrint('Failed to mark notification as read: $e');
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      // Get all unread notifications
      final response = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.notificationsCollectionId,
        queries: [
          Query.equal('user_id', userId),
          Query.equal('read', false),
        ],
      );

      // Mark each as read (consider using batch operations if available)
      // TODO: Use batch operations when Appwrite supports it for better performance
      final futures = response.documents.map((doc) => markAsRead(doc.$id));
      await Future.wait(futures);
    } catch (e) {
      debugPrint('Failed to mark all notifications as read: $e');
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  // Refresh website notices manually
  Future<void> refreshWebsiteNotices() async {
    await _websiteScraper.getNotices(forceRefresh: true);
  }

  // Get last website check time
  Future<DateTime?> getLastWebsiteCheckTime() async {
    return await _websiteScraper.getLastCheckTime();
  }

  void dispose() {
    _websiteScraper.dispose();
  }
}
