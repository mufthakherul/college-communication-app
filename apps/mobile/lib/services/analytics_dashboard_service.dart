import 'package:appwrite/appwrite.dart';
import 'package:campus_mesh/appwrite_config.dart';
import 'package:campus_mesh/services/appwrite_service.dart';
import 'package:flutter/foundation.dart';

/// Analytics data models
class UserActivityData {
  UserActivityData({
    required this.userId,
    required this.userName,
    required this.noticeCount,
    required this.messageCount,
    required this.loginCount,
    required this.lastActive,
  });
  final String userId;
  final String userName;
  final int noticeCount;
  final int messageCount;
  final int loginCount;
  final DateTime lastActive;
}

class NoticeAnalytics {
  NoticeAnalytics({
    required this.totalNotices,
    required this.activeNotices,
    required this.expiredNotices,
    required this.noticesByType,
    required this.noticesByMonth,
    required this.topViewedNotices,
  });
  final int totalNotices;
  final int activeNotices;
  final int expiredNotices;
  final Map<String, int> noticesByType;
  final Map<String, int> noticesByMonth;
  final List<TopNotice> topViewedNotices;
}

class TopNotice {
  TopNotice({
    required this.id,
    required this.title,
    required this.views,
    required this.createdAt,
  });
  final String id;
  final String title;
  final int views;
  final DateTime createdAt;
}

class MessageAnalytics {
  MessageAnalytics({
    required this.totalMessages,
    required this.todayMessages,
    required this.weekMessages,
    required this.messagesByType,
    required this.messagesByDay,
    required this.mostActiveUsers,
  });
  final int totalMessages;
  final int todayMessages;
  final int weekMessages;
  final Map<String, int> messagesByType;
  final Map<String, int> messagesByDay;
  final List<ActiveUser> mostActiveUsers;
}

class ActiveUser {
  ActiveUser({
    required this.userId,
    required this.name,
    required this.messageCount,
  });
  final String userId;
  final String name;
  final int messageCount;
}

class SystemAnalytics {
  SystemAnalytics({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalNotices,
    required this.totalMessages,
    required this.averageMessagesPerUser,
    required this.usersByRole,
    required this.dailyActiveUsers,
  });
  final int totalUsers;
  final int activeUsers;
  final int totalNotices;
  final int totalMessages;
  final double averageMessagesPerUser;
  final Map<String, int> usersByRole;
  final Map<String, int> dailyActiveUsers;
}

/// Service for analytics dashboard with chart-ready data
class AnalyticsDashboardService {
  final _appwrite = AppwriteService();

  /// Get comprehensive notice analytics
  Future<NoticeAnalytics> getNoticeAnalytics() async {
    try {
      // Get all notices
      final allNotices = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.noticesCollectionId,
        queries: [Query.limit(500), Query.orderDesc('created_at')],
      );

      var activeCount = 0;
      var expiredCount = 0;
      final byType = <String, int>{};
      final byMonth = <String, int>{};
      final topNotices = <TopNotice>[];

      final now = DateTime.now();

      for (final doc in allNotices.documents) {
        final data = doc.data;

        // Count active vs expired
        final expiresAt = data['expires_at'] != null
            ? DateTime.parse(data['expires_at'])
            : null;

        if (expiresAt == null || expiresAt.isAfter(now)) {
          activeCount++;
        } else {
          expiredCount++;
        }

        // Count by type
        final type = data['type'] ?? 'announcement';
        byType[type] = (byType[type] ?? 0) + 1;

        // Count by month
        final createdAt = DateTime.parse(data['created_at']);
        final monthKey =
            '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';
        byMonth[monthKey] = (byMonth[monthKey] ?? 0) + 1;

        // Track top viewed notices
        topNotices.add(
          TopNotice(
            id: doc.$id,
            title: data['title'] ?? 'Untitled',
            views: data['view_count'] ?? 0,
            createdAt: createdAt,
          ),
        );
      }

      // Sort and limit top notices
      topNotices.sort((a, b) => b.views.compareTo(a.views));
      final limitedTopNotices = topNotices.take(10).toList();

      return NoticeAnalytics(
        totalNotices: allNotices.total,
        activeNotices: activeCount,
        expiredNotices: expiredCount,
        noticesByType: byType,
        noticesByMonth: byMonth,
        topViewedNotices: limitedTopNotices,
      );
    } catch (e) {
      debugPrint('Error getting notice analytics: $e');
      rethrow;
    }
  }

  /// Get message analytics
  Future<MessageAnalytics> getMessageAnalytics() async {
    try {
      // Get recent messages for analysis
      final allMessages = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        queries: [Query.limit(500), Query.orderDesc('created_at')],
      );

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekAgo = now.subtract(const Duration(days: 7));

      var todayCount = 0;
      var weekCount = 0;
      final byType = <String, int>{};
      final byDay = <String, int>{};
      final userMessageCounts = <String, int>{};

      for (final doc in allMessages.documents) {
        final data = doc.data;
        final createdAt = DateTime.parse(data['created_at']);

        // Count today and week messages
        if (createdAt.isAfter(today)) {
          todayCount++;
        }
        if (createdAt.isAfter(weekAgo)) {
          weekCount++;
        }

        // Count by type
        final type = data['type'] ?? 'text';
        byType[type] = (byType[type] ?? 0) + 1;

        // Count by day
        final dayKey =
            '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
        byDay[dayKey] = (byDay[dayKey] ?? 0) + 1;

        // Track user activity
        final senderId = data['sender_id'];
        if (senderId != null) {
          userMessageCounts[senderId] = (userMessageCounts[senderId] ?? 0) + 1;
        }
      }

      // Get top users
      // TODO(optimization): Fetch all users in a single query instead of individual queries
      final sortedUsers = userMessageCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final mostActive = <ActiveUser>[];
      for (final entry in sortedUsers.take(10)) {
        // Fetch user name (N+1 query - acceptable for top 10 users, consider caching for optimization)
        try {
          final user = await _appwrite.databases.getDocument(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.usersCollectionId,
            documentId: entry.key,
          );

          mostActive.add(
            ActiveUser(
              userId: entry.key,
              name: user.data['display_name'] ?? 'Unknown',
              messageCount: entry.value,
            ),
          );
        } catch (e) {
          debugPrint('Error fetching user data: $e');
        }
      }

      return MessageAnalytics(
        totalMessages: allMessages.total,
        todayMessages: todayCount,
        weekMessages: weekCount,
        messagesByType: byType,
        messagesByDay: byDay,
        mostActiveUsers: mostActive,
      );
    } catch (e) {
      debugPrint('Error getting message analytics: $e');
      rethrow;
    }
  }

  /// Get system-wide analytics
  Future<SystemAnalytics> getSystemAnalytics() async {
    try {
      // Get total users
      final allUsers = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [Query.limit(500)],
      );

      // Get total notices
      final noticesCount = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.noticesCollectionId,
        queries: [Query.limit(1)],
      );

      // Get total messages
      final messagesCount = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        queries: [Query.limit(1)],
      );

      var activeUsersCount = 0;
      final byRole = <String, int>{};
      final dailyActive = <String, int>{};
      final now = DateTime.now();
      final last30Days = now.subtract(const Duration(days: 30));

      for (final doc in allUsers.documents) {
        final data = doc.data;

        // Count by role
        final role = data['role'] ?? 'student';
        byRole[role] = (byRole[role] ?? 0) + 1;

        // Count active users (logged in within 30 days)
        final lastLoginStr = data['last_login'];
        if (lastLoginStr != null) {
          final lastLogin = DateTime.parse(lastLoginStr);
          if (lastLogin.isAfter(last30Days)) {
            activeUsersCount++;

            // Track daily active users
            final dayKey =
                '${lastLogin.year}-${lastLogin.month.toString().padLeft(2, '0')}-${lastLogin.day.toString().padLeft(2, '0')}';
            dailyActive[dayKey] = (dailyActive[dayKey] ?? 0) + 1;
          }
        }
      }

      final avgMessagesPerUser = allUsers.total > 0
          ? messagesCount.total / allUsers.total
          : 0.0;

      return SystemAnalytics(
        totalUsers: allUsers.total,
        activeUsers: activeUsersCount,
        totalNotices: noticesCount.total,
        totalMessages: messagesCount.total,
        averageMessagesPerUser: avgMessagesPerUser,
        usersByRole: byRole,
        dailyActiveUsers: dailyActive,
      );
    } catch (e) {
      debugPrint('Error getting system analytics: $e');
      rethrow;
    }
  }

  /// Get user activity data for admin dashboard
  ///
  /// Note: This method makes individual queries for each user's stats.
  /// For large user bases (>100 users), consider implementing:
  /// 1. Server-side aggregation with Appwrite Functions
  /// 2. Caching with periodic updates
  /// 3. Pagination with on-demand loading
  ///
  /// Current implementation is suitable for small-to-medium deployments (<100 users)
  Future<List<UserActivityData>> getUserActivityData({int limit = 50}) async {
    try {
      final users = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [Query.limit(limit), Query.orderDesc('last_login')],
      );

      final activityData = <UserActivityData>[];

      // TODO(performance): Optimize with batch queries or server-side aggregation for large user bases
      for (final doc in users.documents) {
        final data = doc.data;
        final userId = doc.$id;

        // Get user's notice count (for admins/teachers)
        var noticeCount = 0;
        try {
          final notices = await _appwrite.databases.listDocuments(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.noticesCollectionId,
            queries: [Query.equal('created_by', userId), Query.limit(1)],
          );
          noticeCount = notices.total;
        } catch (e) {
          debugPrint('Error getting notice count for user $userId: $e');
        }

        // Get user's message count
        var messageCount = 0;
        try {
          final messages = await _appwrite.databases.listDocuments(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.messagesCollectionId,
            queries: [Query.equal('sender_id', userId), Query.limit(1)],
          );
          messageCount = messages.total;
        } catch (e) {
          debugPrint('Error getting message count for user $userId: $e');
        }

        activityData.add(
          UserActivityData(
            userId: userId,
            userName: data['display_name'] ?? 'Unknown',
            noticeCount: noticeCount,
            messageCount: messageCount,
            loginCount: data['login_count'] ?? 0,
            lastActive: data['last_login'] != null
                ? DateTime.parse(data['last_login'])
                : DateTime.fromMillisecondsSinceEpoch(0),
          ),
        );
      }

      return activityData;
    } catch (e) {
      debugPrint('Error getting user activity data: $e');
      rethrow;
    }
  }

  /// Get growth trends over time
  Future<Map<String, List<Map<String, dynamic>>>> getGrowthTrends() async {
    try {
      final now = DateTime.now();
      final last90Days = now.subtract(const Duration(days: 90));

      // Get users registered in last 90 days
      final users = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [
          Query.greaterThan('created_at', last90Days.toIso8601String()),
          Query.limit(500),
        ],
      );

      // Get notices created in last 90 days
      final notices = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.noticesCollectionId,
        queries: [
          Query.greaterThan('created_at', last90Days.toIso8601String()),
          Query.limit(500),
        ],
      );

      // Get messages sent in last 90 days
      final messages = await _appwrite.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.messagesCollectionId,
        queries: [
          Query.greaterThan('created_at', last90Days.toIso8601String()),
          Query.limit(500),
        ],
      );

      // Group by day
      final usersByDay = <String, int>{};
      final noticesByDay = <String, int>{};
      final messagesByDay = <String, int>{};

      for (final doc in users.documents) {
        final createdAt = DateTime.parse(doc.data['created_at'] as String);
        final dayKey =
            '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
        usersByDay[dayKey] = (usersByDay[dayKey] ?? 0) + 1;
      }

      for (final doc in notices.documents) {
        final createdAt = DateTime.parse(doc.data['created_at'] as String);
        final dayKey =
            '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
        noticesByDay[dayKey] = (noticesByDay[dayKey] ?? 0) + 1;
      }

      for (final doc in messages.documents) {
        final createdAt = DateTime.parse(doc.data['created_at'] as String);
        final dayKey =
            '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
        messagesByDay[dayKey] = (messagesByDay[dayKey] ?? 0) + 1;
      }

      // Convert to chart-ready format
      final usersData = <Map<String, Object>>[];
      final noticesData = <Map<String, Object>>[];
      final messagesData = <Map<String, Object>>[];

      usersByDay.forEach((day, count) {
        usersData.add({'date': day, 'count': count});
      });

      noticesByDay.forEach((day, count) {
        noticesData.add({'date': day, 'count': count});
      });

      messagesByDay.forEach((day, count) {
        messagesData.add({'date': day, 'count': count});
      });

      // Sort by date
      usersData.sort(
        (a, b) => ((a['date'] as String?) ?? '').compareTo(
          (b['date'] as String?) ?? '',
        ),
      );
      noticesData.sort(
        (a, b) => ((a['date'] as String?) ?? '').compareTo(
          (b['date'] as String?) ?? '',
        ),
      );
      messagesData.sort(
        (a, b) => ((a['date'] as String?) ?? '').compareTo(
          (b['date'] as String?) ?? '',
        ),
      );

      return {
        'users': usersData,
        'notices': noticesData,
        'messages': messagesData,
      };
    } catch (e) {
      debugPrint('Error getting growth trends: $e');
      rethrow;
    }
  }
}
