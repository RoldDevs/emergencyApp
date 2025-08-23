import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emergency_app/providers/emergency_notification_service.dart';
import 'package:emergency_app/models/emergency_notification.dart'; 

class EmergencyService extends StateNotifier<bool> {
  final Ref _ref;
  
  EmergencyService(this._ref) : super(false);

  Future<void> callEmergency(EmergencyType type) async {
    try {
      // Set state to true to show loading indicator
      state = true;
      
      // Send emergency notification
      await _ref.read(emergencyNotificationServiceProvider.notifier).sendEmergencyNotification(type);
      
      // Simulate delay for UI feedback
      await Future.delayed(const Duration(seconds: 2));
      
      // Set state back to false
      state = false;
    } catch (e) {
      debugPrint('Error calling emergency: $e');
      // Set state back to false in case of error
      state = false;
      rethrow;
    }
  }
}

final emergencyServiceProvider = StateNotifierProvider<EmergencyService, bool>(
  (ref) => EmergencyService(ref),
);

final isCallingProvider = Provider<bool>(
  (ref) => ref.watch(emergencyServiceProvider),
);