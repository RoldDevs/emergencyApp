import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergency_app/providers/app_refresh_provider.dart';
import 'package:emergency_app/providers/local_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emergency_app/models/emergency_notification.dart';
import 'package:emergency_app/providers/location_service.dart';
import 'package:emergency_app/providers/auth_service.dart';

class EmergencyNotificationService extends StateNotifier<AsyncValue<List<EmergencyNotification>>> {
  final FirebaseFirestore _firestore;
  final AuthService _authService;
  final Ref _ref;
  StreamSubscription<QuerySnapshot>? _emergencySubscription;
  
  EmergencyNotificationService(this._firestore, this._authService, this._ref) : super(const AsyncValue.loading()) {
    // Set up real-time listener when service is initialized
    _setupEmergencyListener();
  }

  // Set up real-time listener for emergency notifications
  void _setupEmergencyListener() {
    try {
      state = const AsyncValue.loading();
      
      // Create a real-time listener for the emergencies collection
      _emergencySubscription = _firestore
          .collection('emergencies')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
            final notifications = snapshot.docs
                .map((doc) => EmergencyNotification.fromFirestore(doc))
                .toList();
            
            state = AsyncValue.data(notifications);
          }, onError: (e, stackTrace) {
            debugPrint('Error in emergency listener: $e');
            state = AsyncValue.error(e, stackTrace);
          });
    } catch (e, stackTrace) {
      debugPrint('Error setting up emergency listener: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Send emergency notification
  Future<void> sendEmergencyNotification(EmergencyType type) async {
    try {
      // Get current user
      final currentUser = _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not logged in');
      }
      
      // Get current location
      final locationAsync = _ref.read(locationServiceProvider);
      final location = locationAsync.value;
      if (location == null) {
        throw Exception('Unable to get current location');
      }
      
      // Create emergency notification
      final notification = EmergencyNotification.create(
        user: currentUser,
        location: location,
        type: type,
      );
      
      // Save to Firestore
      await _firestore
          .collection('emergencies')
          .doc(notification.id)
          .set(notification.toMap());
      
      // Send notification to admin via OneSignal
      await _notifyAdmin(notification);
    } catch (e) {
      debugPrint('Error sending emergency notification: $e');
      rethrow;
    }
  }

  // Acknowledge emergency notification
  Future<void> acknowledgeEmergency(String emergencyId) async {
    try {
      // Get current admin user
      final admin = _authService.getCurrentUser();
      if (admin == null) {
        throw Exception('Admin not logged in');
      }
      
      // Get the emergency notification
      final docSnapshot = await _firestore.collection('emergencies').doc(emergencyId).get();
      final emergency = EmergencyNotification.fromFirestore(docSnapshot);
      
      // Update emergency notification in Firestore
      await _firestore.collection('emergencies').doc(emergencyId).update({
        'isAcknowledged': true,
        'acknowledgedBy': admin.uid,
        'acknowledgedAt': FieldValue.serverTimestamp(),
      });
      
      // Send notification to user via OneSignal
      await _notifyUser(emergency);
      
      // Refresh the app to update the UI
      _ref.read(appRefreshProvider.notifier).state++;
    } catch (e) {
      debugPrint('Error acknowledging emergency: $e');
      rethrow;
    }
  }

  // Send notification to admin
  Future<void> _notifyAdmin(EmergencyNotification emergency) async {
    try {
      // Get admin from Firestore
      final adminSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: 'admin@emergency.app')
          .limit(1)
          .get();
      
      if (adminSnapshot.docs.isNotEmpty) {
        // Store notification in admin_notifications collection
        await _firestore.collection('admin_notifications').add({
          'emergencyId': emergency.id,
          'type': emergency.type.toString().split('.').last,
          'latitude': emergency.latitude,
          'longitude': emergency.longitude,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'title': 'New Emergency Alert',
          'body': 'Someone needs a ${_getEmergencyTypeText(emergency.type)} emergency',
        });
        
        // Only show local notification if this is the admin device
        final currentUser = _authService.getCurrentUser();
        if (currentUser != null && currentUser.email == 'admin@emergency.app') {
          final notificationService = _ref.read(localNotificationServiceProvider);
          await notificationService.sendNotification(
            title: 'New Emergency Alert',
            body: 'Someone needs a ${_getEmergencyTypeText(emergency.type)} emergency',
            data: {
              'emergencyId': emergency.id,
              'type': emergency.type.toString().split('.').last,
              'latitude': emergency.latitude.toString(),
              'longitude': emergency.longitude.toString(),
            },
          );
        }
      }
    } catch (e) {
      debugPrint('Error sending admin notification: $e');
    }
  }
  
  // Send notification to user
  Future<void> _notifyUser(EmergencyNotification emergency) async {
    try {
      // Store notification in user_notifications collection
      await _firestore.collection('user_notifications').add({
        'userId': emergency.userId,
        'emergencyId': emergency.id,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'title': 'Emergency Acknowledged',
        'body': 'The department acknowledge your emergency, please stay on put',
      });
      
      // Only show local notification if this is the user's device
      final currentUser = _authService.getCurrentUser();
      if (currentUser != null && currentUser.uid == emergency.userId) {
        final notificationService = _ref.read(localNotificationServiceProvider);
        await notificationService.sendNotification(
          title: 'Emergency Acknowledged',
          body: 'The department acknowledge your emergency, please stay on put',
          data: {
            'emergencyId': emergency.id,
            'isAcknowledged': 'true',
          },
        );
      }
    } catch (e) {
      debugPrint('Error sending user notification: $e');
    }
  }
  
  String _getEmergencyTypeText(EmergencyType type) {
    switch (type) {
      case EmergencyType.police:
        return 'Police';
      case EmergencyType.ambulance:
        return 'Medical';
      case EmergencyType.fire:
        return 'Fire';
      default:
        return 'Emergency';
    }
  }
  
  @override
  void dispose() {
    _emergencySubscription?.cancel();
    super.dispose();
  }
}

// Provider for the emergency notification service
final emergencyNotificationServiceProvider = StateNotifierProvider<EmergencyNotificationService, AsyncValue<List<EmergencyNotification>>>(
  (ref) => EmergencyNotificationService(
    FirebaseFirestore.instance,
    ref.read(authServiceProvider.notifier),
    ref,
  ),
);