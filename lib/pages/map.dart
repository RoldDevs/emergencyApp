import 'package:emergency_app/models/emergency_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:emergency_app/providers/map_service.dart';
import 'package:emergency_app/components/emergency_marker.dart';
import 'package:emergency_app/components/user_location_marker.dart';
import 'package:emergency_app/components/emergency_notification_marker.dart';
import 'package:emergency_app/providers/location_service.dart';
import 'package:emergency_app/providers/map_navigation_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  static const String mapTilerApiKey = "PTGIsSlX5IFTWtjdqXnL";
  
  @override
  Widget build(BuildContext context) {
    final emergencyLocationsAsync = ref.watch(mapServiceProvider);
    final userLocationAsync = ref.watch(locationServiceProvider);
    final mapCenter = ref.watch(mapCenterProvider);
    final selectedEmergency = ref.watch(selectedEmergencyProvider);
    
    // Listen to the map navigation provider to trigger navigation
    ref.listen(mapNavigationProvider, (_, __) {});
    
    return emergencyLocationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error loading map data: $error'),
      ),
      data: (locations) => Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: selectedEmergency != null 
                  ? LatLng(selectedEmergency.latitude, selectedEmergency.longitude)
                  : mapCenter,
              initialZoom: selectedEmergency != null ? 15.0 : 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://api.maptiler.com/maps/basic-v2/{z}/{x}/{y}.png?key=$mapTilerApiKey",
                userAgentPackageName: "com.example.emergency_app",
              ),
              // Emergency locations markers
              MarkerLayer(
                markers: locations.map((location) {
                  return Marker(
                    width: 40.0,
                    height: 40.0,
                    point: LatLng(location.latitude, location.longitude),
                    child: EmergencyMarker(
                      location: location,
                    ),
                  );
                }).toList(),
              ),
              // User location marker
              userLocationAsync.when(
                data: (userLocation) => userLocation != null
                    ? MarkerLayer(
                        markers: [
                          Marker(
                            width: 50.0,
                            height: 50.0,
                            point: userLocation,
                            child: const UserLocationMarker(),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              // Selected emergency notification marker
              if (selectedEmergency != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 60.0, // Larger size to make it stand out
                      height: 60.0,
                      point: LatLng(selectedEmergency.latitude, selectedEmergency.longitude),
                      child: EmergencyNotificationMarker(
                        notification: selectedEmergency,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // Info panel for selected emergency
          if (selectedEmergency != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getEmergencyIcon(selectedEmergency.type),
                          color: _getEmergencyColor(selectedEmergency.type),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getEmergencyTypeText(selectedEmergency.type),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getEmergencyColor(selectedEmergency.type),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            ref.read(selectedEmergencyProvider.notifier).state = null;
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'User: ${selectedEmergency.userName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('Contact: ${selectedEmergency.userEmail}'),
                    if (selectedEmergency.userPhone != null && selectedEmergency.userPhone!.isNotEmpty)
                      Text('Phone: ${selectedEmergency.userPhone}'),
                    const SizedBox(height: 4),
                    Text(
                      'Location: ${selectedEmergency.latitude.toStringAsFixed(6)}, ${selectedEmergency.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
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
  
  String _getEmergencyTypeText(EmergencyType type) {
    switch (type) {
      case EmergencyType.police:
        return 'POLICE EMERGENCY';
      case EmergencyType.ambulance:
        return 'MEDICAL EMERGENCY';
      case EmergencyType.fire:
        return 'FIRE EMERGENCY';
      case EmergencyType.flood:
        return 'FLOOD EMERGENCY';
    }
  }
}