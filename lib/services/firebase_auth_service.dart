import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firebase_config.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseConfig.auth;
  final FirebaseFirestore _firestore = FirebaseConfig.firestore;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update display name
        await userCredential.user!.updateDisplayName(name);
        
        // Create user profile document
        await _createUserProfile(
          userCredential.user!.uid,
          email,
          name,
        );

        return userCredential.user;
      }

      throw Exception('User creation failed');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> _createUserProfile(String userId, String email, String name) async {
    try {
      await _firestore.collection(FirebaseConfig.usersCollection).doc(userId).set({
        'email': email,
        'name': name,
        'totalBookings': 0,
        'totalHoursParked': 0.0,
        'loyaltyPoints': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Log error but don't throw - user creation should succeed even if profile creation fails
      print('Failed to create user profile: $e');
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email format';
      case 'weak-password':
        return 'Password is too weak';
      case 'email-already-in-use':
        return 'User already exists';
      case 'user-not-found':
        return 'User not found';
      case 'wrong-password':
        return 'Invalid credentials';
      case 'invalid-credential':
        return 'Invalid credentials';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}

