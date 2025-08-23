import 'package:flutter/material.dart';
import 'package:emergency_app/models/emergency_notification.dart';

class EmergencyNotificationMarker extends StatelessWidget {
  final EmergencyNotification notification;

  const EmergencyNotificationMarker({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _getEmergencyColor(notification.type).withOpacity(0.8),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          _getEmergencyIcon(notification.type),
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Color _getEmergencyColor(EmergencyType type) {
    switch (type) {
      case EmergencyType.police:
        return Colors.blue.shade700;
      case EmergencyType.ambulance:
        return Colors.green.shade700;
      case EmergencyType.fire:
        return Colors.red.shade700;
      case EmergencyType.flood:
        return Colors.orange.shade700;
    }
  }

  IconData _getEmergencyIcon(EmergencyType type) {
    switch (type) {
      case EmergencyType.police:
        return Icons.local_police;
      case EmergencyType.ambulance:
        return Icons.medical_services;
      case EmergencyType.fire:
        return Icons.local_fire_department;
      case EmergencyType.flood:
        return Icons.water;
    }
  }
}