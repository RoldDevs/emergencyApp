import 'package:flutter/material.dart';  
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class LocationService extends StateNotifier<AsyncValue<LatLng?>> {
  LocationService() : super(const AsyncValue.loading()) {
    getCurrentLocation();
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        return null;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever.
      debugPrint('Location permissions are permanently denied, cannot request.');
      return null;
    }

    // When we reach here, permissions are granted and we can continue accessing the position of the device
    return await Geolocator.getCurrentPosition();
  }

  Future<void> getCurrentLocation() async {
    try {
      state = const AsyncValue.loading();
      
      final position = await _determinePosition();
      
      if (position == null) {
        state = const AsyncValue.data(null); // No permission or services disabled
        return;
      }
      
      state = AsyncValue.data(LatLng(position.latitude, position.longitude));
    } catch (e, stackTrace) {
      debugPrint('Error getting location: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// ... existing code ...
final locationServiceProvider = StateNotifierProvider<LocationService, AsyncValue<LatLng?>>(  
  (ref) => LocationService(),
);

// Default center coordinates for Davao City
final defaultCenterProvider = Provider<LatLng>((ref) {
  return const LatLng(7.0731, 125.6125); // Davao City coordinates
});

// Map center provider that uses user location if available, otherwise defaults to Davao City
final mapCenterProvider = Provider<LatLng>((ref) {
  final userLocationAsync = ref.watch(locationServiceProvider);
  final defaultCenter = ref.watch(defaultCenterProvider);
  
  return userLocationAsync.when(
    data: (location) => location ?? defaultCenter,
    loading: () => defaultCenter,
    error: (_, __) => defaultCenter,
  );
});