import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_simple.dart';

// Auth state notifier
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier() : super(const AsyncValue.data(null));

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    
    try {
      // IMPLEMENTATION: Replace with actual authentication with Supabase
      await Future.delayed(const Duration(seconds: 1)); // Mock delay
      
      final user = User(
        id: '1',
        email: email,
        fullName: 'Test User',
        phoneNumber: '+254700000000',
        userType: UserType.customer,
        createdAt: DateTime.now(),
      );
      
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    
    try {
      // IMPLEMENTATION: Replace with actual sign out with Supabase
      await Future.delayed(const Duration(milliseconds: 500)); // Mock delay
      
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required UserType userType,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      // IMPLEMENTATION: Replace with actual sign up with Supabase
      await Future.delayed(const Duration(seconds: 2)); // Mock delay
      
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        userType: userType,
        createdAt: DateTime.now(),
      );
      
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Providers
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier();
});

// Computed providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.hasValue && authState.value != null;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.value;
});

final currentUserTypeProvider = Provider<UserType?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.userType;
});