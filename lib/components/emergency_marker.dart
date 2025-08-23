import 'package:flutter/material.dart';
import 'package:emergency_app/models/emergency_location.dart';

class EmergencyMarker extends StatelessWidget {
  final EmergencyLocation location;

  const EmergencyMarker({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return _buildMarkerIcon();
  }

  Widget _buildMarkerIcon() {
    switch (location.type) {
      case EmergencyLocationType.hospital:
        return const Icon(Icons.local_hospital, color: Colors.red, size: 35);
      case EmergencyLocationType.police:
        return Container(
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(5),
          child: const Icon(Icons.local_police, color: Colors.white, size: 25),
        );
      case EmergencyLocationType.fireStation:
        return const Icon(Icons.fire_truck, color: Colors.orange, size: 35);
      case EmergencyLocationType.other:
        return const Icon(Icons.emergency, color: Colors.purple, size: 35);
    }
  }
}