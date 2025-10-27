import 'package:appwrite/appwrite.dart';
import 'package:unicharge/core/appwrite_config.dart';

class AppwriteAuthService {
  final Account _account = AppwriteConfig.account;

  Future<dynamic> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      
      // Create user profile document
      await _createUserProfile(user.$id, email, name);
      
      return user;
    } on AppwriteException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
    } on AppwriteException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<dynamic> getCurrentUser() async {
    try {
      return await _account.get();
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        return null; // User not authenticated
      }
      throw _handleAuthException(e);
    }
  }

  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } on AppwriteException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> _createUserProfile(String userId, String email, String name) async {
    try {
      await AppwriteConfig.databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: userId,
        data: {
          'email': email,
          'name': name,
          'totalBookings': 0,
          'totalHoursParked': 0.0,
          'loyaltyPoints': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
    } on AppwriteException catch (e) {
      // Log error but don't throw - user creation should succeed even if profile creation fails
      print('Failed to create user profile: ${e.message}');
    }
  }

  String _handleAuthException(AppwriteException e) {
    switch (e.code) {
      case 400:
        return 'Invalid email or password format';
      case 401:
        return 'Invalid credentials';
      case 409:
        return 'User already exists';
      case 429:
        return 'Too many requests. Please try again later';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}
