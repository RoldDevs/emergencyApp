import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emergency_app/providers/admin_navigation_provider.dart';
import 'package:emergency_app/providers/app_refresh_provider.dart';
import 'package:emergency_app/utils/themes.dart';
import 'package:emergency_app/admin/classified/emergencylist.dart';
import 'package:emergency_app/admin/classified/profile.dart'; 
import 'package:emergency_app/pages/map.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class EmergencyDashboard extends ConsumerWidget {
  const EmergencyDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the refresh provider to rebuild when it changes
    ref.watch(appRefreshProvider);
    
    final selectedIndex = ref.watch(adminNavigationProvider);
    
    // Reapply system UI overlay style when screen changes
    AppTheme.configureSystemUI();
    
    // List of screens to display based on selected index
    final screens = [
      const EmergencyListScreen(), // Admin emergency list
      const MapScreen(), // Reusing existing map screen
      const AdminProfileScreen(), // Using admin profile screen
    ];
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.secondaryColor,
        elevation: 0,
      ),
      body: screens[selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: const Color.fromRGBO(0, 0, 0, 0.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: AppTheme.secondaryColor,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: AppTheme.primaryColor,
              color: Colors.black,
              tabs: const [
                GButton(
                  icon: Icons.list_alt,
                  text: 'Emergencies',
                ),
                GButton(
                  icon: Icons.map,
                  text: 'Map',
                ),
                GButton(
                  icon: Icons.person,
                  text: 'Profile',
                ),
              ],
              selectedIndex: selectedIndex,
              onTabChange: (index) {
                ref.read(adminNavigationProvider.notifier).state = index;
              },
            ),
          ),
        ),
      ),
    );
  }
}