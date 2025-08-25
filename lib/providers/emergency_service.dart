import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emergency_app/providers/emergency_notification_service.dart';
import 'package:emergency_app/models/emergency_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; 

class EmergencyCooldownState {
  final Map<EmergencyType, DateTime> _cooldownEndTimes = {};
  final Duration cooldownDuration = const Duration(minutes: 1);
  
  // Initialize from SharedPreferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load saved cooldown times for each emergency type
    for (final type in EmergencyType.values) {
      final key = _getCooldownKey(type);
      final timestamp = prefs.getInt(key);
      
      if (timestamp != null) {
        final endTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().isBefore(endTime)) {
          _cooldownEndTimes[type] = endTime;
        } else {
          // Clear expired cooldowns
          await prefs.remove(key);
        }
      }
    }
  }
  
  bool isInCooldown(EmergencyType type) {
    final endTime = _cooldownEndTimes[type];
    if (endTime == null) return false;
    return DateTime.now().isBefore(endTime);
  }
  
  bool isAnyButtonInCooldown() {
    return EmergencyType.values.any((type) => isInCooldown(type));
  }
  
  Future<void> startCooldown(EmergencyType type) async {
    final endTime = DateTime.now().add(cooldownDuration);
    _cooldownEndTimes[type] = endTime;
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_getCooldownKey(type), endTime.millisecondsSinceEpoch);
  }
  
  Future<void> startCooldownForAllExcept(EmergencyType activeType) async {
    final endTime = DateTime.now().add(cooldownDuration);
    final prefs = await SharedPreferences.getInstance();
    
    // Set cooldown for all types except the active one
    for (final type in EmergencyType.values) {
      if (type != activeType) {
        _cooldownEndTimes[type] = endTime;
        await prefs.setInt(_getCooldownKey(type), endTime.millisecondsSinceEpoch);
      }
    }
  }
  
  int remainingCooldownSeconds(EmergencyType type) {
    final endTime = _cooldownEndTimes[type];
    if (endTime == null) return 0;
    
    final remaining = endTime.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }
  
  // Helper to generate consistent SharedPreferences keys
  String _getCooldownKey(EmergencyType type) {
    return 'emergency_cooldown_${type.toString().split('.').last}';
  }
}

class EmergencyService extends StateNotifier<bool> {
  final Ref _ref;
  final EmergencyCooldownState _cooldownState = EmergencyCooldownState();
  Timer? _cooldownTimer; // Add timer field
  
  EmergencyService(this._ref) : super(false) {
    // Initialize cooldown state from SharedPreferences
    _initializeCooldownState();
  }
  
  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _initializeCooldownState() async {
    await _cooldownState.initialize();
    // Notify listeners that cooldown state might have changed
    _ref.read(emergencyCooldownProvider.notifier).state = _cooldownState;
    
    // Start a timer to periodically check and update cooldown state
    _startCooldownTimer();
  }
  
  void _startCooldownTimer() {
    // Cancel any existing timer
    _cooldownTimer?.cancel();
    
    // Create a new timer that fires every second
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      // Check if any button is still in cooldown
      bool anyInCooldown = _cooldownState.isAnyButtonInCooldown();
      
      // Force a state refresh every second to update UI
      // Create a new instance to force Riverpod to detect the state change
      _ref.read(emergencyCooldownProvider.notifier).state = EmergencyCooldownState();
      // Then set it back to our actual state with updated cooldown times
      _ref.read(emergencyCooldownProvider.notifier).state = _cooldownState;
      
      // If no buttons are in cooldown anymore but timer is still running,
      // trigger one final update to reset UI elements
      if (!anyInCooldown) {
        // Cancel the timer to save resources
        _cooldownTimer?.cancel();
        
        // Force one final UI refresh to ensure buttons are re-enabled
        _ref.read(emergencyCooldownProvider.notifier).state = EmergencyCooldownState();
        _ref.read(emergencyCooldownProvider.notifier).state = _cooldownState;
      }
    });
  }
  
  EmergencyCooldownState get cooldownState => _cooldownState;

  Future<void> callEmergency(EmergencyType type) async {
    try {
      // Check if button is in cooldown
      if (_cooldownState.isInCooldown(type)) {
        return; // Don't proceed if in cooldown
      }
      
      // Set state to true to show loading indicator
      state = true;
      
      // Send emergency notification
      await _ref.read(emergencyNotificationServiceProvider.notifier).sendEmergencyNotification(type);
      
      // Start cooldown for all buttons
      for (final emergencyType in EmergencyType.values) {
        await _cooldownState.startCooldown(emergencyType);
      }
      
      // Notify listeners that cooldown state changed
      _ref.read(emergencyCooldownProvider.notifier).state = EmergencyCooldownState();
      _ref.read(emergencyCooldownProvider.notifier).state = _cooldownState;
      
      // Ensure the timer is running
      _startCooldownTimer();
      
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

// Provider to access the cooldown state
final emergencyCooldownProvider = StateProvider<EmergencyCooldownState>(
  (ref) => ref.read(emergencyServiceProvider.notifier).cooldownState,
);

// Provider to check if a specific button type is in cooldown
final isButtonInCooldownProvider = Provider.family<bool, EmergencyType>(
  (ref, type) => ref.watch(emergencyCooldownProvider).isInCooldown(type),
);

// Add this at the end of the file

// Provider to check if any emergency button is in cooldown
final isAnyCooldownActiveProvider = Provider<bool>(
  (ref) => ref.watch(emergencyCooldownProvider).isAnyButtonInCooldown(),
);

// Provider to get the maximum remaining cooldown time across all buttons
final remainingCooldownSecondsProvider = Provider<int>(
  (ref) {
    final cooldownState = ref.watch(emergencyCooldownProvider);
    int maxRemaining = 0;
    
    for (final type in EmergencyType.values) {
      final remaining = cooldownState.remainingCooldownSeconds(type);
      if (remaining > maxRemaining) {
        maxRemaining = remaining;
      }
    }
    
    return maxRemaining;
  },
);