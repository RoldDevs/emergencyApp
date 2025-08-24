import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:emergency_app/models/emergency_location.dart';

class MapService extends StateNotifier<AsyncValue<List<EmergencyLocation>>> {
  MapService() : super(const AsyncValue.loading()) {
    fetchAllEmergencyLocations();
  }

  Future<void> fetchAllEmergencyLocations() async {
    try {
      state = const AsyncValue.loading();
      final hospitals = await fetchHospitals();
      final policeStations = await fetchPoliceStations();
      
      state = AsyncValue.data([...hospitals, ...policeStations]);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Inside the MapService class methods
  Future<List<EmergencyLocation>> fetchHospitals() async {
    const String overpassQuery = '''
      [out:json];
      area[name="Davao City"]->.searchArea;
      (
        node["amenity"="hospital"](area.searchArea);
        way["amenity"="hospital"](area.searchArea);
        relation["amenity"="hospital"](area.searchArea);
      );
      out center;
    ''';
  
    final Uri url = Uri.parse("https://overpass-api.de/api/interpreter?data=$overpassQuery");
  
    try {
      final response = await http.get(url);
  
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<EmergencyLocation> loadedHospitals = [];
  
        for (var element in data["elements"]) {
          double lat = element["lat"] ?? element["center"]?["lat"] ?? 0.0;
          double lng = element["lon"] ?? element["center"]?["lon"] ?? 0.0;
          String name = element["tags"]?["name"] ?? "Unnamed Hospital";
          String phone = element["tags"]?["phone"] ?? "No contact info";
          String website = element["tags"]?["website"] ?? "";
          String address = element["tags"]?["addr:full"] ?? 
                          (element["tags"]?["addr:street"] != null ? 
                          "${element["tags"]?["addr:street"]} ${element["tags"]?["addr:housenumber"] ?? ''}" : 
                          "Davao City");
          String hours = element["tags"]?["opening_hours"] ?? "24/7";
          
          loadedHospitals.add(EmergencyLocation(
            name: name,
            latitude: lat,
            longitude: lng,
            phone: phone,
            type: EmergencyLocationType.hospital,
            address: address,
            website: website,
            operatingHours: hours,
            description: "Emergency medical services available.",
          ));
        }
        
        return loadedHospitals;
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching hospitals: $e");
      return [];
    }
  }

  // Similar updates for fetchPoliceStations() method
  Future<List<EmergencyLocation>> fetchPoliceStations() async {
    const String overpassQuery = '''
      [out:json];
      area[name="Davao City"]->.searchArea;
      (
        node["amenity"="police"](area.searchArea);
        way["amenity"="police"](area.searchArea);
        relation["amenity"="police"](area.searchArea);
      );
      out center;
    ''';
  
    final Uri url = Uri.parse("https://overpass-api.de/api/interpreter?data=$overpassQuery");
  
    try {
      final response = await http.get(url);
  
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<EmergencyLocation> loadedPoliceStations = [];
  
        for (var element in data["elements"]) {
          double lat = element["lat"] ?? element["center"]?["lat"] ?? 0.0;
          double lng = element["lon"] ?? element["center"]?["lon"] ?? 0.0;
          String name = element["tags"]?["name"] ?? "Unnamed Police Station";
          String phone = element["tags"]?["phone"] ?? "No contact info";
  
          loadedPoliceStations.add(
            EmergencyLocation(
              name: name,
              latitude: lat,
              longitude: lng,
              phone: phone,
              type: EmergencyLocationType.police,
            ),
          );
        }
  
        return loadedPoliceStations;
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching police stations: $e");
      return [];
    }
  }
}

final mapServiceProvider = StateNotifierProvider<MapService, AsyncValue<List<EmergencyLocation>>>(
  (ref) => MapService(),
);