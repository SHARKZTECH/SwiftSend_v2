import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import '../services/supabase_auth_service.dart';

// Auth state notifier using Supabase
class SupabaseAuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  SupabaseAuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _init();
  }

  final SupabaseAuthService _authService;

  void _init() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((authState) async {
      if (authState.event == AuthChangeEvent.signedIn) {
        final user = await _authService.getCurrentUser();
        state = AsyncValue.data(user);
      } else if (authState.event == AuthChangeEvent.signedOut) {
        state = const AsyncValue.data(null);
      }
    });

    // Load initial user state
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<AuthResult> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _authService.signIn(
        email: email,
        password: password,
      );

      if (result.isSuccess) {
        final user = await _authService.getCurrentUser();
        state = AsyncValue.data(user);
      } else {
        state = const AsyncValue.data(null);
      }

      return result;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return AuthResult.error(message: 'An unexpected error occurred');
    }
  }

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required UserType userType,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        userType: userType,
      );

      if (result.isSuccess) {
        final user = await _authService.getCurrentUser();
        state = AsyncValue.data(user);
      } else {
        state = const AsyncValue.data(null);
      }

      return result;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return AuthResult.error(message: 'An unexpected error occurred');
    }
  }

  Future<AuthResult> signOut() async {
    try {
      final result = await _authService.signOut();
      state = const AsyncValue.data(null);
      return result;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return AuthResult.error(message: 'Failed to sign out');
    }
  }

  Future<AuthResult> resetPassword(String email) async {
    try {
      return await _authService.resetPassword(email: email);
    } catch (error) {
      return AuthResult.error(message: 'Failed to send reset email');
    }
  }

  Future<AuthResult> updateProfile(UserModel user) async {
    try {
      final result = await _authService.updateUserProfile(user);
      
      if (result.isSuccess) {
        state = AsyncValue.data(user);
      }
      
      return result;
    } catch (error) {
      return AuthResult.error(message: 'Failed to update profile');
    }
  }

  Future<AuthResult> deleteAccount() async {
    try {
      final result = await _authService.deleteAccount();
      
      if (result.isSuccess) {
        state = const AsyncValue.data(null);
      }
      
      return result;
    } catch (error) {
      return AuthResult.error(message: 'Failed to delete account');
    }
  }

  // Utility getters
  bool get isAuthenticated {
    return state.hasValue && state.value != null;
  }

  UserModel? get currentUser {
    return state.hasValue ? state.value : null;
  }

  UserType? get currentUserType {
    return currentUser?.userType;
  }

  bool get isEmailVerified {
    return _authService.isEmailVerified;
  }
}

// Providers
final supabaseAuthNotifierProvider = StateNotifierProvider<SupabaseAuthNotifier, AsyncValue<UserModel?>>((ref) {
  final authService = ref.read(supabaseAuthServiceProvider);
  return SupabaseAuthNotifier(authService);
});

// Computed providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(supabaseAuthNotifierProvider);
  return authState.hasValue && authState.value != null;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(supabaseAuthNotifierProvider);
  return authState.value;
});

final currentUserTypeProvider = Provider<UserType?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.userType;
});

final isEmailVerifiedProvider = Provider<bool>((ref) {
  final authNotifier = ref.read(supabaseAuthNotifierProvider.notifier);
  return authNotifier.isEmailVerified;
});