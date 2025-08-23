import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emergency_app/providers/auth_service.dart';
import 'package:emergency_app/providers/local_notification_service.dart';

class NotificationListenerService {
  final FirebaseFirestore _firestore;
  final AuthService _authService;
  final LocalNotificationService _notificationService;
  Timer? _timer;
  StreamSubscription? _adminNotificationsSubscription;
  StreamSubscription? _userNotificationsSubscription;
  
  NotificationListenerService(this._firestore, this._authService, this._notificationService);
  
  void startListening() {
    // Use real-time listeners instead of periodic checks
    _setupNotificationListeners();
    
    // Also keep the periodic check as a backup (reduced frequency)
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _checkForNotifications());
  }
  
  void _setupNotificationListeners() {
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) return;
    
    // Cancel any existing subscriptions
    _adminNotificationsSubscription?.cancel();
    _userNotificationsSubscription?.cancel();
    
    try {
      if (currentUser.email == 'admin@emergency.app') {
        // Admin: Listen for emergency notifications in real-time
        _adminNotificationsSubscription = _firestore
            .collection('admin_notifications')
            .where('isRead', isEqualTo: false)
            .orderBy('timestamp', descending: true)
            .limit(10)
            .snapshots()
            .listen(_handleAdminNotifications);
      } else {
        // Regular user: Listen for acknowledgment notifications in real-time
        _userNotificationsSubscription = _firestore
            .collection('user_notifications')
            .where('userId', isEqualTo: currentUser.uid)
            .where('isRead', isEqualTo: false)
            .orderBy('timestamp', descending: true)
            .limit(10)
            .snapshots()
            .listen((snapshot) => _handleUserNotifications(snapshot, currentUser.uid));
      }
    } catch (e) {
      debugPrint('Error setting up notification listeners: $e');
    }
  }
  
  void _handleAdminNotifications(QuerySnapshot snapshot) {
    // Process only new documents
    final newDocs = snapshot.docChanges
        .where((change) => change.type == DocumentChangeType.added)
        .map((change) => change.doc);
    
    for (final doc in newDocs) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Ensure we're on the main thread for platform channel operations
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Display notification
        await _notificationService.sendNotification(
          title: data['title'] ?? 'New Emergency Alert',
          body: data['body'] ?? 'Someone needs emergency assistance',
          data: {
            'emergencyId': data['emergencyId'],
            'type': data['type'],
          },
        );
        
        // Mark as read
        await doc.reference.update({'isRead': true});
      });
    }
  }
  
  void _handleUserNotifications(QuerySnapshot snapshot, String userId) {
    // Process only new documents
    final newDocs = snapshot.docChanges
        .where((change) => change.type == DocumentChangeType.added)
        .map((change) => change.doc);
    
    for (final doc in newDocs) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Ensure we're on the main thread for platform channel operations
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Display notification
        await _notificationService.sendNotification(
          title: data['title'] ?? 'Emergency Update',
          body: data['body'] ?? 'Update on your emergency',
          data: {
            'emergencyId': data['emergencyId'],
          },
        );
        
        // Mark as read
        await doc.reference.update({'isRead': true});
      });
    }
  }
  
  // Keep the periodic check as a backup
  Future<void> _checkForNotifications() async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) return;
    
    try {
      if (currentUser.email == 'admin@emergency.app') {
        // Admin: Check for emergency notifications
        await _checkAdminNotifications();
      } else {
        // Regular user: Check for acknowledgment notifications
        await _checkUserNotifications(currentUser.uid);
      }
    } catch (e) {
      debugPrint('Error checking notifications: $e');
    }
  }
  
  Future<void> _checkAdminNotifications() async {
    final snapshot = await _firestore
        .collection('admin_notifications')
        .where('isRead', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();
    
    for (final doc in snapshot.docs) {
      final data = doc.data();
      
      // Ensure we're on the main thread for platform channel operations
      await Future.microtask(() async {
        // Display notification
        await _notificationService.sendNotification(
          title: data['title'] ?? 'New Emergency Alert',
          body: data['body'] ?? 'Someone needs emergency assistance',
          data: {
            'emergencyId': data['emergencyId'],
            'type': data['type'],
          },
        );
        
        // Mark as read
        await doc.reference.update({'isRead': true});
      });
    }
  }
  
  Future<void> _checkUserNotifications(String userId) async {
    final snapshot = await _firestore
        .collection('user_notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();
    
    for (final doc in snapshot.docs) {
      final data = doc.data();
      
      // Ensure we're on the main thread for platform channel operations
      await Future.microtask(() async {
        // Display notification
        await _notificationService.sendNotification(
          title: data['title'] ?? 'Emergency Update',
          body: data['body'] ?? 'Update on your emergency',
          data: {
            'emergencyId': data['emergencyId'],
          },
        );
        
        // Mark as read
        await doc.reference.update({'isRead': true});
      });
    }
  }
  
  void dispose() {
    _timer?.cancel();
    _adminNotificationsSubscription?.cancel();
    _userNotificationsSubscription?.cancel();
  }
}

// Provider
final notificationListenerServiceProvider = Provider<NotificationListenerService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final authService = ref.watch(authServiceProvider.notifier);
  final notificationService = ref.watch(localNotificationServiceProvider);
  
  return NotificationListenerService(firestore, authService, notificationService);
});