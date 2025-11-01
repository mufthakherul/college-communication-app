import 'package:flutter/material.dart';
import 'package:campus_mesh/screens/notices/notices_screen.dart';
import 'package:campus_mesh/screens/messages/messages_screen.dart';
import 'package:campus_mesh/screens/books/books_screen.dart';
import 'package:campus_mesh/screens/tools/tools_screen.dart';
import 'package:campus_mesh/screens/profile/profile_screen.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/services/demo_mode_service.dart';
import 'package:campus_mesh/services/connectivity_service.dart';
import 'package:campus_mesh/services/offline_queue_service.dart';
import 'package:campus_mesh/models/user_model.dart';
import 'package:campus_mesh/widgets/connectivity_banner.dart';
import 'package:campus_mesh/widgets/network_status_widget.dart';
import 'package:campus_mesh/screens/qr/qr_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _authService = AuthService();
  final _demoModeService = DemoModeService();
  final _connectivityService = ConnectivityService();
  final _offlineQueueService = OfflineQueueService();
  UserModel? _currentUser;
  bool _isDemoMode = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _checkDemoMode();
    _initializeOfflineSupport();
  }

  Future<void> _initializeOfflineSupport() async {
    await _offlineQueueService.loadQueue();
    // Listen for connectivity changes to process queue
    _connectivityService.connectivityStream.listen((isOnline) {
      if (isOnline && _offlineQueueService.pendingActionsCount > 0) {
        _offlineQueueService.processQueue();
      }
    });
  }

  Future<void> _checkDemoMode() async {
    final isDemo = await _demoModeService.isDemoModeEnabled();
    if (mounted) {
      setState(() => _isDemoMode = isDemo);
    }
  }

  Future<void> _loadUserProfile() async {
    // Check if in demo mode first
    final isDemo = await _demoModeService.isDemoModeEnabled();
    if (isDemo) {
      final demoUser = await _demoModeService.getDemoUser();
      if (mounted) {
        setState(() => _currentUser = demoUser);
      }
      return;
    }

    // Otherwise load from Appwrite
    await _authService.initialize();
    final userId = _authService.currentUserId;
    if (userId != null) {
      final profile = await _authService.getUserProfile(userId);
      if (mounted) {
        setState(() => _currentUser = profile);
      }
    }
  }

  List<Widget> get _screens => [
        const NoticesScreen(),
        const MessagesScreen(),
        const BooksScreen(),
        const ToolsScreen(),
        ProfileScreen(user: _currentUser, currentUser: _currentUser),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Network status widget (shown when offline or poor connection)
          const NetworkStatusWidget(),
          // Connectivity banner (shown when offline or syncing)
          const ConnectivityBanner(),
          // Demo mode banner
          if (_isDemoMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.orange[700],
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'DEMO MODE - Using sample data only',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await _demoModeService.disableDemoMode();
                        if (mounted) {
                          Navigator.of(context).pushReplacementNamed('/');
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Exit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(child: _screens[_currentIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notices',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Tools'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QRScannerScreen()),
          );
        },
        tooltip: 'Scan QR Code',
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
