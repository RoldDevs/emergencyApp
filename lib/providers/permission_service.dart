import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService extends StateNotifier<AsyncValue<bool>> {
  PermissionService() : super(const AsyncValue.loading());

  // Check if all required permissions are granted
  Future<bool> checkPermissions() async {
    try {
      state = const AsyncValue.loading();
      
      // Check location permissions
      final locationStatus = await Permission.location.status;
      final notificationStatus = await Permission.notification.status;
      
      // Add other permission checks as needed
      final allGranted = locationStatus.isGranted && notificationStatus.isGranted;
      
      state = AsyncValue.data(allGranted);
      return allGranted;
    } catch (e, stackTrace) {
      debugPrint('Error checking permissions: $e');
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  Future<bool> requestAllPermissions() async {
    try {
      state = const AsyncValue.loading();
      
      // Request location permissions
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.notification,
        // Add other permissions as needed
      ].request();
      
      // Check if all permissions are granted
      bool allGranted = true;
      statuses.forEach((permission, status) {
        if (!status.isGranted) {
          allGranted = false;
          debugPrint('Permission not granted: $permission');
        }
      });
      
      state = AsyncValue.data(allGranted);
      return allGranted;
    } catch (e, stackTrace) {
      debugPrint('Error requesting permissions: $e');
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
  
  // Show permission dialog with settings option
  Future<void> showPermissionDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
            'This app requires location and notification permissions to function properly. '
            'Please grant these permissions to use all features.'
          ),
          actions: [
            TextButton(
              onPressed: () => openAppSettings(),
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
          ],
        );
      },
    );
  }
}

final permissionServiceProvider = StateNotifierProvider<PermissionService, AsyncValue<bool>>(
  (ref) => PermissionService(),
);