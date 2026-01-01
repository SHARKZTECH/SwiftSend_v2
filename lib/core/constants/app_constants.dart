import 'package:flutter/material.dart';

/// App-wide constants for SwiftSend Kenya
class AppConstants {
  // App Info
  static const String appName = 'SwiftSend Kenya';
  static const String appTagline = 'Fast & Reliable Delivery';
  static const String appVersion = '1.0.0';

  // Design System
  static const double designWidth = 390; // iPhone 14 Pro width
  static const double designHeight = 844; // iPhone 14 Pro height
  
  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 1000);
  
  // Spacing & Sizing
  static const double paddingXS = 4;
  static const double paddingSM = 8;
  static const double paddingMD = 16;
  static const double paddingLG = 24;
  static const double paddingXL = 32;
  static const double paddingXXL = 48;
  
  static const double borderRadius = 12;
  static const double borderRadiusLG = 16;
  static const double borderRadiusXL = 24;
  
  // Icon Sizes
  static const double iconSM = 16;
  static const double iconMD = 24;
  static const double iconLG = 32;
  static const double iconXL = 48;
  static const double iconXXL = 64;
  
  // Delivery Status
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusInTransit = 'in_transit';
  static const String statusDelivered = 'delivered';
  static const String statusCancelled = 'cancelled';
  
  // User Types
  static const String userTypeCustomer = 'customer';
  static const String userTypeBusiness = 'business';
  static const String userTypeRider = 'rider';
  
  // Routes (for future navigation)
  static const String routeSplash = '/';
  static const String routeOnboarding = '/onboarding';
  static const String routeAuth = '/auth';
  static const String routeHome = '/home';
  static const String routeProfile = '/profile';
  static const String routeDeliveries = '/deliveries';
  static const String routeTracking = '/tracking';
  static const String routeCreateDelivery = '/create-delivery';
  static const String routeNotifications = '/notifications';
  
  // Asset Paths
  static const String logoPath = 'assets/logo/';
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  static const String fontsPath = 'assets/fonts/';
  
  // API Endpoints (for future use)
  static const String baseUrl = 'https://api.swiftsend.co.ke';
  static const String apiVersion = 'v1';
  
  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxMessageLength = 500;
  static const int phoneNumberLength = 10;
  
  // Features Flags
  static const bool enableBiometrics = true;
  static const bool enablePushNotifications = true;
  static const bool enableLocationTracking = true;
  
  // Supported Languages (for future i18n)
  static const String defaultLanguage = 'en';
  static const List<String> supportedLanguages = ['en', 'sw']; // English, Swahili
}

/// Screen breakpoints for responsive design
class BreakPoints {
  static const double mobile = 640;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double largeDesktop = 1280;
}

/// Animation curves used throughout the app
class AppCurves {
  static const easeIn = Curves.easeIn;
  static const easeOut = Curves.easeOut;
  static const easeInOut = Curves.easeInOut;
  static const fastOutSlowIn = Curves.fastOutSlowIn;
  static const elasticOut = Curves.elasticOut;
  static const bounceOut = Curves.bounceOut;
}