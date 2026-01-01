import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/user_model.dart';

// Auth service provider
final supabaseAuthServiceProvider = Provider<SupabaseAuthService>((ref) {
  return SupabaseAuthService();
});

// Auth state provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.read(supabaseAuthServiceProvider);
  return authService.authStateChanges;
});

// Current user provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authService = ref.read(supabaseAuthServiceProvider);
  return authService.getCurrentUser();
});

class SupabaseAuthService {
  GoTrueClient get _auth => SupabaseConfig.auth;

  // Stream of auth state changes
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // Get current session
  Session? get currentSession => _auth.currentSession;

  // Get current user from Supabase
  User? get currentSupabaseUser => _auth.currentUser;

  // Sign up with email and password
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required UserType userType,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone_number': phoneNumber,
          'user_type': userType.value,
        },
      );

      if (response.user != null) {
        return AuthResult.success(
          message: 'Account created successfully. Please check your email for verification.',
        );
      } else {
        return AuthResult.error(message: 'Failed to create account');
      }
    } on AuthException catch (e) {
      return AuthResult.error(message: e.message);
    } catch (e) {
      return AuthResult.error(message: 'An unexpected error occurred');
    }
  }

  // Sign in with email and password
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return AuthResult.success(message: 'Signed in successfully');
      } else {
        return AuthResult.error(message: 'Failed to sign in');
      }
    } on AuthException catch (e) {
      return AuthResult.error(message: e.message);
    } catch (e) {
      return AuthResult.error(message: 'An unexpected error occurred');
    }
  }

  // Sign out
  Future<AuthResult> signOut() async {
    try {
      await _auth.signOut();
      return AuthResult.success(message: 'Signed out successfully');
    } catch (e) {
      return AuthResult.error(message: 'Failed to sign out');
    }
  }

  // Reset password
  Future<AuthResult> resetPassword({required String email}) async {
    try {
      await _auth.resetPasswordForEmail(email);
      return AuthResult.success(
        message: 'Password reset instructions sent to your email',
      );
    } on AuthException catch (e) {
      return AuthResult.error(message: e.message);
    } catch (e) {
      return AuthResult.error(message: 'An unexpected error occurred');
    }
  }

  // Update password
  Future<AuthResult> updatePassword({required String newPassword}) async {
    try {
      await _auth.updateUser(UserAttributes(password: newPassword));
      return AuthResult.success(message: 'Password updated successfully');
    } on AuthException catch (e) {
      return AuthResult.error(message: e.message);
    } catch (e) {
      return AuthResult.error(message: 'An unexpected error occurred');
    }
  }

  // Get current user profile
  Future<UserModel?> getCurrentUser() async {
    final user = currentSupabaseUser;
    if (user == null) return null;

    try {
      // First try using the RPC function
      final response = await SupabaseConfig.client
          .rpc('get_current_user_profile')
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      // Fallback to direct query
      try {
        final response = await SupabaseConfig.from('users')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (response != null) {
          return UserModel.fromJson(response);
        }
        return null;
      } catch (fallbackError) {
        return null;
      }
    }
  }


  // Update user profile
  Future<AuthResult> updateUserProfile(UserModel user) async {
    try {
      await SupabaseConfig.from('users')
          .update(user.toJson())
          .eq('id', user.id);

      return AuthResult.success(message: 'Profile updated successfully');
    } catch (e) {
      return AuthResult.error(message: 'Failed to update profile');
    }
  }

  // Delete account
  Future<AuthResult> deleteAccount() async {
    try {
      final user = currentSupabaseUser;
      if (user == null) {
        return AuthResult.error(message: 'No user logged in');
      }

      // Mark user as inactive instead of deleting
      await SupabaseConfig.from('users')
          .update({'is_active': false})
          .eq('id', user.id);

      await signOut();
      return AuthResult.success(message: 'Account deleted successfully');
    } catch (e) {
      return AuthResult.error(message: 'Failed to delete account');
    }
  }


  // Verify email
  Future<AuthResult> verifyEmail(String token) async {
    try {
      await _auth.verifyOTP(
        type: OtpType.email,
        token: token,
        email: currentSupabaseUser?.email ?? '',
      );
      return AuthResult.success(message: 'Email verified successfully');
    } on AuthException catch (e) {
      return AuthResult.error(message: e.message);
    } catch (e) {
      return AuthResult.error(message: 'An unexpected error occurred');
    }
  }

  // Send email verification
  Future<AuthResult> sendEmailVerification() async {
    try {
      final user = currentSupabaseUser;
      if (user == null || user.email == null) {
        return AuthResult.error(message: 'No user logged in');
      }

      await _auth.resend(
        type: OtpType.email,
        email: user.email,
      );
      return AuthResult.success(
        message: 'Verification email sent successfully',
      );
    } on AuthException catch (e) {
      return AuthResult.error(message: e.message);
    } catch (e) {
      return AuthResult.error(message: 'An unexpected error occurred');
    }
  }

  // Check if email is verified
  bool get isEmailVerified => currentSupabaseUser?.emailConfirmedAt != null;
}

class AuthResult {
  final bool isSuccess;
  final String message;

  const AuthResult._({
    required this.isSuccess,
    required this.message,
  });

  factory AuthResult.success({required String message}) {
    return AuthResult._(isSuccess: true, message: message);
  }

  factory AuthResult.error({required String message}) {
    return AuthResult._(isSuccess: false, message: message);
  }
}