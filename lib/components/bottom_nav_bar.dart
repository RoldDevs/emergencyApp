import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../providers/navigation_provider.dart';
import '../utils/themes.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationProvider);
    
    return Container(
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
                icon: Icons.phone,
                text: 'Emergency',
              ),
              GButton(
                icon: Icons.medical_services,
                text: 'First Aid',
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
              ref.read(navigationProvider.notifier).state = index;
            },
          ),
        ),
      ),
    );
  }
}