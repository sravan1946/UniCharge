import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicharge/services/appwrite_auth_service.dart';
import 'package:unicharge/models/user_profile_model.dart';

// Auth service provider
final authServiceProvider = Provider<AppwriteAuthService>((ref) {
  return AppwriteAuthService();
});

// Current user provider
final currentUserProvider = FutureProvider<dynamic>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getCurrentUser();
});

// Auth state provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AsyncValue<dynamic>>((ref) {
  return AuthStateNotifier(ref.watch(authServiceProvider));
});

// User profile provider
final userProfileProvider = FutureProvider.family<UserProfileModel?, String>((ref, userId) async {
  // This would typically fetch from database service
  // For now, return null as we'll implement this later
  return null;
});

class AuthStateNotifier extends StateNotifier<AsyncValue<dynamic>> {
  final AppwriteAuthService _authService;

  AuthStateNotifier(this._authService) : super(const AsyncValue.loading()) {
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      final user = await _authService.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );
      await _checkAuthState();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authService.login(email: email, password: password);
      await _checkAuthState();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
