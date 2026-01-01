import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Notification state provider
final notificationProvider = StateNotifierProvider<NotificationNotifier, List<AppNotification>>((ref) {
  return NotificationNotifier();
});

class NotificationService {
  // IMPLEMENTATION: Initialize Firebase Cloud Messaging
  Future<void> initialize() async {
    // Request notification permissions
    await _requestPermissions();
    
    // Initialize FCM
    await _initializeFCM();
    
    // Setup notification handlers
    _setupNotificationHandlers();
  }

  Future<void> _requestPermissions() async {
    // IMPLEMENTATION: Request notification permissions from the system
    debugPrint('Requesting notification permissions...');
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate
    debugPrint('Notification permissions granted');
  }

  Future<void> _initializeFCM() async {
    // IMPLEMENTATION: Initialize Firebase Cloud Messaging
    debugPrint('Initializing FCM...');
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate
    debugPrint('FCM initialized');
  }

  void _setupNotificationHandlers() {
    // IMPLEMENTATION: Setup FCM message handlers
    // Handle foreground messages
    // Handle background messages
    // Handle notification tap events
    debugPrint('Notification handlers setup complete');
  }

  Future<String?> getToken() async {
    // IMPLEMENTATION: Get FCM token for this device
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate
    return 'mock_fcm_token_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> subscribeToTopic(String topic) async {
    // IMPLEMENTATION: Subscribe to FCM topic
    debugPrint('Subscribed to topic: $topic');
    await Future.delayed(const Duration(milliseconds: 200)); // Simulate
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    // IMPLEMENTATION: Unsubscribe from FCM topic
    debugPrint('Unsubscribed from topic: $topic');
    await Future.delayed(const Duration(milliseconds: 200)); // Simulate
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    // IMPLEMENTATION: Show local notification
    debugPrint('Local notification: $title - $body');
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate
  }
}

class NotificationNotifier extends StateNotifier<List<AppNotification>> {
  NotificationNotifier() : super([]) {
    _loadMockNotifications();
  }

  void _loadMockNotifications() {
    // Load some mock notifications
    state = [
      AppNotification(
        id: '1',
        title: 'Delivery Accepted',
        message: 'John has accepted your delivery request #SW001',
        type: NotificationType.deliveryUpdate,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
        data: {'delivery_id': 'SW001', 'rider_id': 'john_123'},
      ),
      AppNotification(
        id: '2',
        title: 'Payment Successful',
        message: 'Your payment of KSh 350 has been processed',
        type: NotificationType.payment,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isRead: false,
        data: {'amount': '350', 'transaction_id': 'MP123456'},
      ),
      AppNotification(
        id: '3',
        title: 'Delivery Completed',
        message: 'Your package has been delivered successfully',
        type: NotificationType.deliveryUpdate,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
        data: {'delivery_id': 'SW002'},
      ),
      AppNotification(
        id: '4',
        title: 'New Promotion',
        message: 'Get 20% off your next delivery. Use code SWIFT20',
        type: NotificationType.promotion,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: true,
        data: {'promo_code': 'SWIFT20', 'discount': '20'},
      ),
      AppNotification(
        id: '5',
        title: 'Rider Nearby',
        message: 'Your rider is 2 minutes away from the pickup location',
        type: NotificationType.deliveryUpdate,
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        isRead: true,
        data: {'delivery_id': 'SW003', 'eta': '2'},
      ),
    ];
  }

  void addNotification(AppNotification notification) {
    state = [notification, ...state];
  }

  void markAsRead(String notificationId) {
    state = [
      for (final notification in state)
        if (notification.id == notificationId)
          notification.copyWith(isRead: true)
        else
          notification,
    ];
  }

  void markAllAsRead() {
    state = [
      for (final notification in state)
        notification.copyWith(isRead: true),
    ];
  }

  void removeNotification(String notificationId) {
    state = state.where((notification) => notification.id != notificationId).toList();
  }

  void clearAll() {
    state = [];
  }

  int get unreadCount => state.where((notification) => !notification.isRead).length;
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, String>? data;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
    this.data,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, String>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}

enum NotificationType {
  deliveryUpdate,
  payment,
  promotion,
  system,
  rider;

  String get displayName {
    switch (this) {
      case NotificationType.deliveryUpdate:
        return 'Delivery Update';
      case NotificationType.payment:
        return 'Payment';
      case NotificationType.promotion:
        return 'Promotion';
      case NotificationType.system:
        return 'System';
      case NotificationType.rider:
        return 'Rider';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.deliveryUpdate:
        return Icons.local_shipping;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.system:
        return Icons.info;
      case NotificationType.rider:
        return Icons.motorcycle;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.deliveryUpdate:
        return Colors.blue;
      case NotificationType.payment:
        return Colors.green;
      case NotificationType.promotion:
        return Colors.orange;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.rider:
        return Colors.purple;
    }
  }
}