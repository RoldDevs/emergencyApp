import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emergency_app/models/user.dart';
import 'package:latlong2/latlong.dart';

enum EmergencyType {
  police,
  ambulance,
  fire,
  flood
}

class EmergencyNotification {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final String? userAddress;
  final double latitude;
  final double longitude;
  final EmergencyType type;
  final DateTime timestamp;
  final bool isAcknowledged;
  final String? acknowledgedBy;
  final DateTime? acknowledgedAt;

  EmergencyNotification({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    this.userAddress,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.timestamp,
    this.isAcknowledged = false,
    this.acknowledgedBy,
    this.acknowledgedAt,
  });

  // Create from user data and location
  factory EmergencyNotification.create({
    required User user,
    required LatLng location,
    required EmergencyType type,
  }) {
    return EmergencyNotification(
      id: FirebaseFirestore.instance.collection('emergencies').doc().id,
      userId: user.uid,
      userName: user.displayName ?? 'Unknown User',
      userEmail: user.email,
      userPhone: user.phoneNumber,
      userAddress: user.address,
      latitude: location.latitude,
      longitude: location.longitude,
      type: type,
      timestamp: DateTime.now(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'userAddress': userAddress,
      'latitude': latitude,
      'longitude': longitude,
      'type': type.toString().split('.').last,
      'timestamp': timestamp,
      'isAcknowledged': isAcknowledged,
      'acknowledgedBy': acknowledgedBy,
      'acknowledgedAt': acknowledgedAt,
    };
  }

  // Create from Firestore document
  factory EmergencyNotification.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return EmergencyNotification(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown User',
      userEmail: data['userEmail'] ?? '',
      userPhone: data['userPhone'],
      userAddress: data['userAddress'],
      latitude: data['latitude'] ?? 0.0,
      longitude: data['longitude'] ?? 0.0,
      type: _stringToEmergencyType(data['type'] ?? 'police'),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isAcknowledged: data['isAcknowledged'] ?? false,
      acknowledgedBy: data['acknowledgedBy'],
      acknowledgedAt: (data['acknowledgedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Helper method to convert string to EmergencyType
  static EmergencyType _stringToEmergencyType(String typeStr) {
    switch (typeStr) {
      case 'police':
        return EmergencyType.police;
      case 'ambulance':
        return EmergencyType.ambulance;
      case 'fire':
        return EmergencyType.fire;
      case 'flood':
        return EmergencyType.flood;
      default:
        return EmergencyType.police;
    }
  }

  // Create a copy with updated fields
  EmergencyNotification copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? userAddress,
    double? latitude,
    double? longitude,
    EmergencyType? type,
    DateTime? timestamp,
    bool? isAcknowledged,
    String? acknowledgedBy,
    DateTime? acknowledgedAt,
  }) {
    return EmergencyNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      userAddress: userAddress ?? this.userAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
    );
  }
}