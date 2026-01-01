import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

class SwiftSendApp extends StatelessWidget {
  const SwiftSendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwiftSend Kenya',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      builder: (context, child) {
        // Ensure text scaling doesn't break layouts on all devices
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}