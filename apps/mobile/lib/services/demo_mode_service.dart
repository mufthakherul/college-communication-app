import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class DemoModeService {
  static const String _demoModeKey = 'demo_mode_enabled';
  static const String _demoUserKey = 'demo_user_data';

  // Check if demo mode is enabled
  Future<bool> isDemoModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_demoModeKey) ?? false;
  }

  // Enable demo mode
  Future<void> enableDemoMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_demoModeKey, true);
  }

  // Disable demo mode
  Future<void> disableDemoMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_demoModeKey, false);
    await prefs.remove(_demoUserKey);
  }

  // Get demo user
  Future<UserModel?> getDemoUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isDemoEnabled = await isDemoModeEnabled();
    
    if (!isDemoEnabled) return null;

    // Return a demo user with sample data
    return UserModel(
      uid: 'demo_user_001',
      email: 'demo@rangpur.polytech.gov.bd',
      displayName: 'Demo User',
      role: UserRole.student,
      photoURL: '',
      department: 'Computer Technology',
      year: '2024',
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  // Create demo user with GitHub-style verification
  Future<UserModel> createDemoUserWithGitHub(String githubUsername) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_demoModeKey, true);
    
    // Create a demo user with GitHub username
    return UserModel(
      uid: 'demo_github_${githubUsername.toLowerCase()}',
      email: '$githubUsername@demo.github',
      displayName: githubUsername,
      role: UserRole.admin, // Demo users get admin access to view all features
      photoURL: 'https://github.com/$githubUsername.png',
      department: 'Demo Mode',
      year: 'N/A',
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  // Get sample notices for demo mode
  List<Map<String, dynamic>> getSampleNotices() {
    return [
      {
        'id': 'notice_1',
        'title': 'Welcome to RPI Communication',
        'content': 'This is a demo notice. Connect Firebase to see real data.',
        'type': 'announcement',
        'authorId': 'demo_admin',
        'authorName': 'Admin',
        'targetAudience': 'all',
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
        'expiresAt': DateTime.now().add(const Duration(days: 30)),
      },
      {
        'id': 'notice_2',
        'title': 'Demo Mode Active',
        'content': 'You are viewing this app in demo mode. Firebase connection is not required for demo mode.',
        'type': 'urgent',
        'authorId': 'demo_admin',
        'authorName': 'System',
        'targetAudience': 'all',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
        'expiresAt': DateTime.now().add(const Duration(days: 30)),
      },
      {
        'id': 'notice_3',
        'title': 'Upcoming Event',
        'content': 'Sample event notice. All features are available in demo mode.',
        'type': 'event',
        'authorId': 'demo_teacher',
        'authorName': 'Demo Teacher',
        'targetAudience': 'students',
        'createdAt': DateTime.now(),
        'expiresAt': DateTime.now().add(const Duration(days: 15)),
      },
    ];
  }

  // Get sample messages for demo mode
  List<Map<String, dynamic>> getSampleMessages() {
    return [
      {
        'id': 'msg_1',
        'content': 'Welcome to demo mode! This is a sample message.',
        'senderId': 'demo_admin',
        'senderName': 'Admin',
        'recipientId': 'demo_user_001',
        'recipientName': 'Demo User',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'isRead': false,
      },
      {
        'id': 'msg_2',
        'content': 'You can explore all features without Firebase connection.',
        'senderId': 'demo_teacher',
        'senderName': 'Demo Teacher',
        'recipientId': 'demo_user_001',
        'recipientName': 'Demo User',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
        'isRead': false,
      },
    ];
  }
}
