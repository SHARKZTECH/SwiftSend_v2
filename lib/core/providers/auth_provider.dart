// This file is temporarily disabled until code generation is set up
// Using auth_provider_simple.dart instead

/*
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user_simple.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<User?> build() {
    // Initialize with no user (not authenticated)
    return const AsyncValue.data(null);
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    
    try {
      // TODO: Implement actual authentication with Supabase
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
      // TODO: Implement actual sign out with Supabase
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
      // TODO: Implement actual sign up with Supabase
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

// Computed providers
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.hasValue && authState.value != null;
}

@riverpod
User? currentUser(CurrentUserRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.value;
}

@riverpod
UserType? currentUserType(CurrentUserTypeRef ref) {
  final user = ref.watch(currentUserProvider);
  return user?.userType;
}
*/