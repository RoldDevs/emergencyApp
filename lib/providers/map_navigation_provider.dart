import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emergency_app/models/emergency_notification.dart';
import 'package:emergency_app/providers/admin_navigation_provider.dart';

// Provider to store the currently selected emergency notification for map navigation
final selectedEmergencyProvider = StateProvider<EmergencyNotification?>((ref) => null);

// Provider to automatically navigate to map screen when an emergency is selected
final mapNavigationProvider = Provider<void>((ref) {
  final selectedEmergency = ref.watch(selectedEmergencyProvider);
  
  // When an emergency is selected, navigate to the map screen (index 1)
  if (selectedEmergency != null) {
    ref.read(adminNavigationProvider.notifier).state = 1;
  }
});