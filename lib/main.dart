import 'package:emergency_app/pages/chatbot.dart';
import 'package:emergency_app/pages/emergency.dart';
import 'package:emergency_app/pages/firstaid.dart';
import 'package:emergency_app/pages/map.dart';
import 'package:emergency_app/pages/profile.dart';
import 'package:emergency_app/admin/emergency_dashboard.dart';
import 'package:emergency_app/providers/notification_listener_service.dart';
import 'package:emergency_app/providers/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emergency_app/components/bottom_nav_bar.dart';
import 'package:emergency_app/providers/navigation_provider.dart';
import 'package:emergency_app/providers/auth_service.dart';
import 'package:emergency_app/providers/app_refresh_provider.dart';
import 'package:emergency_app/utils/themes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:emergency_app/providers/local_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:emergency_app/auth/signin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Create provider container
  final container = ProviderContainer();
  
  // Initialize Local Notifications
  await container.read(localNotificationServiceProvider).initialize();
  
  // Initialize notification listener service
  final notificationContainer = ProviderContainer();
  final notificationListener = notificationContainer.read(notificationListenerServiceProvider);
  notificationListener.startListening();
  
  AppTheme.configureSystemUI(); // Configure system UI
  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // In the MyApp class, modify the build method:
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the refresh provider to rebuild the app when it changes
    final refreshCounter = ref.watch(appRefreshProvider);
    
    final currentUser = ref.watch(userProvider);
    final isAdmin = currentUser != null && currentUser.email == 'admin@emergency.app';
    
    return MaterialApp(
      key: Key('app-$refreshCounter'), // Add this key that changes when refreshCounter changes
      title: 'Emergency App',
      theme: AppTheme.lightTheme(),
      home: currentUser == null ? const SignInPage() : 
            isAdmin ? const EmergencyDashboard() : const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  void initState() {
    super.initState();
    // Check permissions and first login status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissions();
      _checkFirstTimeLogin();
    });
  }

  Future<void> _checkPermissions() async {
    final permissionService = ref.read(permissionServiceProvider.notifier);
    final hasPermissions = await permissionService.checkPermissions();
    
    if (!hasPermissions && mounted) {
      // Show permission dialog if permissions are not granted
      permissionService.showPermissionDialog(context);
    }
  }

  Future<void> _checkFirstTimeLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('is_first_time_login') ?? true;
    
    if (isFirstTime && mounted) {
      // Show the welcome modal
      _showWelcomeModal();
      
      // Set the flag to false so it won't show again
      await prefs.setBool('is_first_time_login', false);
    }
  }

  void _showWelcomeModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Welcome to Emergency App!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'This application helps you quickly report emergencies and get assistance when needed.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                const Text(
                  'Key Features:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  '• One-tap emergency reporting\n• First aid video guides\n• Location sharing\n• Emergency chat assistance',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Get Started'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(navigationProvider);
    
    // Reapply system UI overlay style when screen changes
    AppTheme.configureSystemUI();
    
    // List of screens to display based on selected index
    final screens = [
      const EmergencyScreen(),
      const FirstAidScreen(),
      const MapScreen(),
      const ProfileScreen(),
    ];
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: screens[selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show the chatbot in a modal bottom sheet
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (_, controller) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: const ChatBotScreen(),
              ),
            ),
          );
        },
        child: const Icon(Icons.chat_bubble_outline),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}