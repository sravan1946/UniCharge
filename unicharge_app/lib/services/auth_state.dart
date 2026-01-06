import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthState extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = true;
  static const String _userKey = 'current_user';

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  // Load persisted user on initialization
  Future<void> loadPersistedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        // User data persisted, but we need to verify session with Appwrite
        // This will be done by the AppWrapper
        setLoading(false);
      } else {
        setLoading(false);
      }
    } catch (e) {
      setLoading(false);
    }
  }

  void setUser(User? user) {
    _currentUser = user;
    _persistUser(user);
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void signOut() {
    _currentUser = null;
    _clearPersistedUser();
    notifyListeners();
  }

  Future<void> _persistUser(User? user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (user != null) {
        // Store user ID as a simple way to track that we have a logged-in user
        // The actual session is maintained by Appwrite cookies
        await prefs.setString(_userKey, user.id);
      } else {
        await prefs.remove(_userKey);
      }
    } catch (e) {
      print('Error persisting user: $e');
    }
  }

  Future<void> _clearPersistedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (e) {
      print('Error clearing persisted user: $e');
    }
  }

  bool hasPersistedUser() {
    // Check if we have a persisted user without async
    // This will be checked properly in loadPersistedUser
    return false;
  }
}

