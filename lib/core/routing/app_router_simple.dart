import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/delivery/presentation/screens/create_delivery_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AppConstants.routeSplash,
    routes: [
      GoRoute(
        path: AppConstants.routeSplash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.routeOnboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppConstants.routeSignIn,
        name: 'sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppConstants.routeSignUp,
        name: 'sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppConstants.routeForgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppConstants.routeHome,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppConstants.routeCreateDelivery,
        name: 'create-delivery',
        builder: (context, state) => const CreateDeliveryScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: AppConstants.paddingMD),
            Text(
              'Page not found: ${state.uri}',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingMD),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.routeSplash),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});