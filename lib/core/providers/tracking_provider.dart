import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/delivery_model.dart';
import '../services/delivery_service.dart';

// Real-time tracking provider for a specific delivery
final deliveryTrackingProvider = StateNotifierProviderFamily<DeliveryTrackingNotifier, AsyncValue<DeliveryModel?>, String>(
  (ref, deliveryId) {
    final deliveryService = ref.read(deliveryServiceProvider);
    return DeliveryTrackingNotifier(deliveryService, deliveryId);
  },
);

// Provider for delivery updates/timeline
final deliveryUpdatesProvider = FutureProviderFamily<List<DeliveryUpdate>, String>(
  (ref, deliveryId) async {
    final deliveryService = ref.read(deliveryServiceProvider);
    return deliveryService.getDeliveryUpdates(deliveryId);
  },
);

// Provider for real-time location updates (for riders)
final riderLocationProvider = StateNotifierProvider<RiderLocationNotifier, LocationData?>(
  (ref) => RiderLocationNotifier(),
);

class DeliveryTrackingNotifier extends StateNotifier<AsyncValue<DeliveryModel?>> {
  DeliveryTrackingNotifier(this._deliveryService, this._deliveryId) 
      : super(const AsyncValue.loading()) {
    _init();
  }

  final DeliveryService _deliveryService;
  final String _deliveryId;
  RealtimeChannel? _subscription;
  Timer? _periodicTimer;

  Future<void> _init() async {
    try {
      // Load initial delivery data
      final delivery = await _deliveryService.getDeliveryById(_deliveryId);
      state = AsyncValue.data(delivery);

      // Set up real-time subscription
      _setupRealtimeSubscription();
      
      // Set up periodic updates for active deliveries
      if (delivery?.status == DeliveryStatus.inTransit) {
        _setupPeriodicUpdates();
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void _setupRealtimeSubscription() {
    _subscription = _deliveryService.subscribeToDeliveryUpdates(
      _deliveryId,
      (DeliveryModel updatedDelivery) {
        state = AsyncValue.data(updatedDelivery);
        
        // Handle status changes
        if (updatedDelivery.status == DeliveryStatus.inTransit) {
          _setupPeriodicUpdates();
        } else if (updatedDelivery.status == DeliveryStatus.delivered ||
                   updatedDelivery.status == DeliveryStatus.cancelled) {
          _cancelPeriodicUpdates();
        }
      },
    );
  }

  void _setupPeriodicUpdates() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshDelivery();
    });
  }

  void _cancelPeriodicUpdates() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  Future<void> _refreshDelivery() async {
    try {
      final delivery = await _deliveryService.getDeliveryById(_deliveryId);
      if (delivery != null) {
        state = AsyncValue.data(delivery);
      }
    } catch (error) {
      // Don't update state with error during periodic refresh
    }
  }

  Future<void> updateStatus(
    DeliveryStatus newStatus, {
    LocationData? location,
    String? message,
  }) async {
    try {
      final result = await _deliveryService.updateDeliveryStatus(
        _deliveryId,
        newStatus,
        location: location,
        message: message,
      );

      if (result.isSuccess && result.delivery != null) {
        state = AsyncValue.data(result.delivery);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _refreshDelivery();
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    _periodicTimer?.cancel();
    super.dispose();
  }
}

class RiderLocationNotifier extends StateNotifier<LocationData?> {
  RiderLocationNotifier() : super(null) {
    _startLocationTracking();
  }

  Timer? _locationTimer;
  
  void _startLocationTracking() {
    // Simulate location updates every 10 seconds
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _updateLocation();
    });
  }

  void _updateLocation() {
    // In a real app, this would get actual GPS coordinates
    // For now, simulate movement
    final currentLocation = state;
    if (currentLocation != null) {
      // Simulate slight movement
      state = LocationData(
        latitude: currentLocation.latitude + (0.001 * (DateTime.now().millisecond % 10 - 5)),
        longitude: currentLocation.longitude + (0.001 * (DateTime.now().millisecond % 10 - 5)),
        address: currentLocation.address,
      );
    } else {
      // Set initial location (Nairobi coordinates)
      state = const LocationData(
        latitude: -1.2921,
        longitude: 36.8219,
        address: 'Nairobi, Kenya',
      );
    }
  }

  void updateLocation(LocationData location) {
    state = location;
  }

  void startTracking() {
    _locationTimer ??= Timer.periodic(const Duration(seconds: 10), (_) {
      _updateLocation();
    });
  }

  void stopTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }
}

// Provider for calculating ETA
final deliveryETAProvider = ProviderFamily<String, DeliveryModel>((ref, delivery) {
  if (delivery.status != DeliveryStatus.inTransit) {
    return 'Not in transit';
  }
  
  // Simulate ETA calculation
  final remainingDistance = _calculateRemainingDistance(delivery);
  final estimatedMinutes = (remainingDistance * 3).round(); // 3 minutes per km
  
  if (estimatedMinutes < 1) {
    return 'Arriving now';
  } else if (estimatedMinutes < 60) {
    return '$estimatedMinutes min';
  } else {
    final hours = estimatedMinutes ~/ 60;
    final minutes = estimatedMinutes % 60;
    return '${hours}h ${minutes}m';
  }
});

// Provider for distance calculation
final deliveryDistanceProvider = ProviderFamily<String, DeliveryModel>((ref, delivery) {
  final distance = _calculateTotalDistance(delivery);
  if (distance < 1) {
    return '${(distance * 1000).round()}m';
  } else {
    return '${distance.toStringAsFixed(1)}km';
  }
});

// Helper functions
double _calculateRemainingDistance(DeliveryModel delivery) {
  // Simulate remaining distance calculation
  switch (delivery.status) {
    case DeliveryStatus.accepted:
      return 5.0; // 5km to pickup
    case DeliveryStatus.pickedUp:
    case DeliveryStatus.inTransit:
      return 3.0; // 3km to dropoff
    default:
      return 0.0;
  }
}

double _calculateTotalDistance(DeliveryModel delivery) {
  // Calculate distance between pickup and dropoff
  final pickup = delivery.pickupLocation;
  final dropoff = delivery.dropoffLocation;
  
  final latDiff = (dropoff.latitude - pickup.latitude).abs();
  final lonDiff = (dropoff.longitude - pickup.longitude).abs();
  
  // Simplified distance calculation (Haversine formula would be more accurate)
  return (latDiff + lonDiff) * 111; // 1 degree ≈ 111 km
}