// ignore_for_file: unawaited_futures
import 'package:campus_mesh/models/user_model.dart';
import 'package:campus_mesh/screens/books/books_screen.dart';
import 'package:campus_mesh/screens/messages/messages_screen.dart';
import 'package:campus_mesh/screens/notices/notices_screen.dart';
import 'package:campus_mesh/screens/profile/profile_screen.dart';
import 'package:campus_mesh/screens/qr/qr_generator_menu_screen.dart';
import 'package:campus_mesh/screens/qr/qr_scanner_screen.dart';
import 'package:campus_mesh/screens/tools/tools_screen.dart';
import 'package:campus_mesh/services/auth_service.dart';
import 'package:campus_mesh/services/connectivity_service.dart';
import 'package:campus_mesh/services/demo_mode_service.dart';
import 'package:campus_mesh/services/offline_queue_service.dart';
import 'package:campus_mesh/widgets/connectivity_banner.dart';
import 'package:campus_mesh/widgets/network_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  void _showQROptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: Colors.blue),
              title: const Text('Scan QR Code'),
              subtitle: const Text('Scan a QR code from another device'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRScannerScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code, color: Colors.green),
              title: const Text('Generate QR Code'),
              subtitle: const Text('Create a QR code to share information'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRGeneratorMenuScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient backdrop for subtle depth
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.surface,
                    if (isDark)
                      scheme.surfaceContainerHighest.withValues(alpha: 0.4)
                    else
                      scheme.secondaryContainer.withValues(alpha: 0.25),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              // Network status widget (shown when offline or poor connection)
              const NetworkStatusWidget(),
              // Connectivity banner (shown when offline or syncing)
              const ConnectivityBanner(),
              // Demo mode banner
              if (_isDemoMode)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.orange.shade600,
                        Colors.orange.shade400,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.shade800.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
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
                        Expanded(
                          child: Text(
                            'DEMO MODE - Using sample data only',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final navigator = Navigator.of(context);
                            await _demoModeService.disableDemoMode();
                            if (mounted) {
                              navigator.pushReplacementNamed('/');
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Exit',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Content with fade-in animation wrapper
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  switchInCurve: Curves.easeOutQuart,
                  switchOutCurve: Curves.easeInQuart,
                  child: _screens[_currentIndex],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => setState(() => _currentIndex = index),
            height: 70,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.notifications_outlined),
                selectedIcon: Icon(Icons.notifications),
                label: 'Notices',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.message),
                label: 'Messages',
              ),
              NavigationDestination(
                icon: Icon(Icons.library_books_outlined),
                selectedIcon: Icon(Icons.library_books),
                label: 'Library',
              ),
              NavigationDestination(
                icon: Icon(Icons.build_outlined),
                selectedIcon: Icon(Icons.build),
                label: 'Tools',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Tooltip(
        message: 'QR Code Options',
        child: FloatingActionButton(
          onPressed: _showQROptions,
          elevation: 6,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.qr_code_2),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
