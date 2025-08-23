import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emergency_app/models/user.dart' as app_models;

class AuthService extends StateNotifier<app_models.User?> {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthService(this._firebaseAuth, this._firestore) : super(null) {
    // Listen to auth state changes
    _firebaseAuth.authStateChanges().listen((firebase_auth.User? firebaseUser) {
      if (firebaseUser != null) {
        _getUserData(firebaseUser.uid);
      } else {
        state = null;
      }
    });
  }

  // Get user data from Firestore
  Future<void> _getUserData(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      
      if (docSnapshot.exists) {
        state = app_models.User.fromFirestore(docSnapshot);
      } else {
        final currentUser = _firebaseAuth.currentUser;
        if (currentUser != null) {
          // Create new user document if it doesn't exist
          final newUser = app_models.User(
            uid: currentUser.uid,
            email: currentUser.email ?? '',
            displayName: currentUser.displayName,
            phoneNumber: currentUser.phoneNumber,
            photoURL: currentUser.photoURL,
          );
          
          await _firestore.collection('users').doc(uid).set(newUser.toMap());
          state = newUser;
        }
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
  }

  // Sign in with email and password
  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // No error
    } on firebase_auth.FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }

  // Sign up with email and password
  Future<String?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // No error
    } on firebase_auth.FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Get current user
  app_models.User? getCurrentUser() {
    return state;
  }

  // Send password reset email
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return null; // No error
    } on firebase_auth.FirebaseAuthException catch (e) {
      return e.message; // Return error message
    }
  }

  // Check if user is signed in
  bool get isSignedIn => _firebaseAuth.currentUser != null;
  
  // Add this method to the AuthService class
  Future<void> updateUserProfile({
    String? displayName,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      final user = state;
      if (user != null) {
        // Create updated user object
        final updatedUser = app_models.User(
          uid: user.uid,
          email: user.email,
          displayName: displayName ?? user.displayName,
          phoneNumber: phoneNumber ?? user.phoneNumber,
          photoURL: user.photoURL,
          address: address ?? user.address,
          createdAt: user.createdAt,
          lastLogin: user.lastLogin,
        );
        
        // Update in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'displayName': displayName ?? user.displayName,
          'phoneNumber': phoneNumber ?? user.phoneNumber,
          'address': address ?? user.address,
        });
        
        // Update state
        state = updatedUser;
      }
    } catch (e) {
      print('Error updating user profile: $e');
      throw e;
    }
  }
}

// Providers
final firebaseAuthProvider = Provider<firebase_auth.FirebaseAuth>((ref) {
  return firebase_auth.FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final authServiceProvider = StateNotifierProvider<AuthService, app_models.User?>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);
  return AuthService(firebaseAuth, firestore);
});

// Convenience providers
final userProvider = Provider<app_models.User?>((ref) {
  return ref.watch(authServiceProvider);
});

final isSignedInProvider = Provider<bool>((ref) {
  return ref.watch(authServiceProvider) != null;
});