enum EmergencyLocationType {
  hospital,
  police,
  fireStation,
  other
}

class EmergencyLocation {
  final String name;
  final double latitude;
  final double longitude;
  final String phone;
  final EmergencyLocationType type;
  final String address;
  final String description;
  final String website;
  final String operatingHours;

  EmergencyLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.type,
    this.address = '',
    this.description = '',
    this.website = '',
    this.operatingHours = '',
  });

  factory EmergencyLocation.fromJson(Map<String, dynamic> json, EmergencyLocationType type) {
    return EmergencyLocation(
      name: json['name'] ?? 'Unnamed Location',
      latitude: json['lat'] ?? 0.0,
      longitude: json['lng'] ?? 0.0,
      phone: json['phone'] ?? 'No contact info',
      type: type,
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      website: json['website'] ?? '',
      operatingHours: json['operating_hours'] ?? '',
    );
  }
}