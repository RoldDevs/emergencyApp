import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  // Queue for managing notifications
  final List<Map<String, dynamic>> _notificationQueue = [];
  bool _isProcessingQueue = false;
  
  // Initialize notifications
  Future<void> initialize() async {
    // Initialize settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Initialize settings for iOS
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // Initialize settings for Windows
    final WindowsInitializationSettings initializationSettingsWindows =
        WindowsInitializationSettings(
          appName: 'Emergency App', 
          appUserModelId: 'com.example.emergency_app', 
          guid: '12345678-1234-1234-1234-123456789012'
    );
    
    // Initialize settings for all platforms
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      windows: initializationSettingsWindows,
    );
    
    // Initialize plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        // Handle notification tap
        debugPrint('Notification tapped: ${notificationResponse.payload}');
      },
    );
    
    // Request permission
    await _requestPermissions();
    
    debugPrint('Local notifications initialized');
  }
  
  // Request permissions
  Future<void> _requestPermissions() async {
    // Request Android permissions
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    // Request iOS permissions
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
  
  // Send notification
  Future<void> sendNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Add notification to queue
      _notificationQueue.add({
        'title': title,
        'body': body,
        'data': data,
      });
      
      // Start processing queue if not already processing
      if (!_isProcessingQueue) {
        _processNotificationQueue();
      }
      
      debugPrint('Notification queued: $title');
    } catch (e) {
      debugPrint('Error queueing notification: $e');
      rethrow;
    }
  }
  
  // Process notification queue
  Future<void> _processNotificationQueue() async {
    if (_notificationQueue.isEmpty) {
      _isProcessingQueue = false;
      return;
    }
    
    _isProcessingQueue = true;
    
    // Get next notification from queue
    final notification = _notificationQueue.removeAt(0);
    
    // Create platform-specific notification details
    NotificationDetails platformChannelSpecifics = _getPlatformNotificationDetails();
    
    // Show notification
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      notification['title'],
      notification['body'],
      platformChannelSpecifics,
      payload: notification['data']?.toString(),
    );
    
    // Trigger vibration on supported platforms
    if (!Platform.isWindows) { // Windows doesn't support vibration
      _showNotificationWithVibration();
    }
    
    debugPrint('Notification displayed: ${notification['title']}');
    
    // Wait for 4 seconds (notification display time)
    await Future.delayed(const Duration(seconds: 4));
    
    // Process next notification in queue
    _processNotificationQueue();
  }
  
  // Show notification with vibration
  void _showNotificationWithVibration() async {
    // Check if device can vibrate
    bool? hasVibrator = await Vibration.hasVibrator();
    
    if (hasVibrator == true) {
      // For emergency alerts, use a 4-second vibration pattern
      Vibration.vibrate(
        duration: 4000, // 4 seconds vibration
        amplitude: 255, // Maximum intensity
      );
    }
  }
  
  // Get platform-specific notification details
  NotificationDetails _getPlatformNotificationDetails() {
    // Android notification details
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'emergency_channel',
      'Emergency Notifications',
      channelDescription: 'Notifications for emergency alerts',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      sound: RawResourceAndroidNotificationSound('emergency_alert'),
    );
    
    // iOS notification details
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'emergency_alert.aiff',
    );
    
    // Windows notification details
    const WindowsNotificationDetails windowsPlatformChannelSpecifics =
        WindowsNotificationDetails(

    );
    
    // Return platform-specific notification details
    if (Platform.isAndroid) {
      return const NotificationDetails(android: androidPlatformChannelSpecifics);
    } else if (Platform.isIOS) {
      return const NotificationDetails(iOS: iOSPlatformChannelSpecifics);
    } else if (Platform.isWindows) {
      return const NotificationDetails(windows: windowsPlatformChannelSpecifics);
    } else {
      // Default to Android settings for other platforms
      return const NotificationDetails(android: androidPlatformChannelSpecifics);
    }
  }
  
  // Store device token in Firestore for the current user
  Future<void> saveDeviceToken(String userId) async {
    // For local notifications, we don't have a token to save
    // This method is kept for compatibility with the previous implementation
    debugPrint('Local notifications do not use device tokens');
  }
}

// Provider for the local notification service
final localNotificationServiceProvider = Provider<LocalNotificationService>((ref) {
  return LocalNotificationService();
});