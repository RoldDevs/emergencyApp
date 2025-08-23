import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoURL;
  final String? address; 
  final DateTime createdAt;
  final DateTime lastLogin;

  User({
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.photoURL,
    this.address, 
    DateTime? createdAt,
    DateTime? lastLogin,
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    lastLogin = lastLogin ?? DateTime.now();

  // Convert User object to a map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'address': address, 
      'createdAt': createdAt,
      'lastLogin': lastLogin,
    };
  }

  // Create User object from Firestore document
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return User(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      phoneNumber: data['phoneNumber'],
      photoURL: data['photoURL'],
      address: data['address'], // Added address from Firestore
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
    );
  }
}