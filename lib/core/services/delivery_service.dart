import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/delivery_model.dart';

// Delivery service provider
final deliveryServiceProvider = Provider<DeliveryService>((ref) {
  return DeliveryService();
});

// Delivery state provider
final deliveryProvider = StateNotifierProvider<DeliveryNotifier, AsyncValue<List<DeliveryModel>>>((ref) {
  return DeliveryNotifier(ref.read(deliveryServiceProvider));
});

// Active deliveries provider
final activeDeliveriesProvider = Provider<List<DeliveryModel>>((ref) {
  final deliveries = ref.watch(deliveryProvider);
  if (!deliveries.hasValue) return [];
  
  return deliveries.value!.where((delivery) =>
    delivery.status != DeliveryStatus.delivered &&
    delivery.status != DeliveryStatus.cancelled
  ).toList();
});

// Completed deliveries provider
final completedDeliveriesProvider = Provider<List<DeliveryModel>>((ref) {
  final deliveries = ref.watch(deliveryProvider);
  if (!deliveries.hasValue) return [];
  
  return deliveries.value!.where((delivery) =>
    delivery.status == DeliveryStatus.delivered
  ).toList();
});

class DeliveryService {
  // Create a new delivery
  Future<DeliveryResult> createDelivery(DeliveryModel delivery) async {
    try {
      final response = await SupabaseConfig.from('deliveries')
          .insert(delivery.toJson())
          .select()
          .single();

      final createdDelivery = DeliveryModel.fromJson(response);
      
      // Notify available riders
      await _notifyAvailableRiders(createdDelivery);
      
      return DeliveryResult.success(
        delivery: createdDelivery,
        message: 'Delivery created successfully',
      );
    } catch (e) {
      return DeliveryResult.error(message: 'Failed to create delivery: $e');
    }
  }

  // Get deliveries for a specific user
  Future<List<DeliveryModel>> getUserDeliveries(String userId) async {
    try {
      final response = await SupabaseConfig.from('deliveries')
          .select()
          .or('sender_id.eq.$userId,rider_id.eq.$userId')
          .order('created_at', ascending: false);

      return response.map((json) => DeliveryModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get available deliveries for riders
  Future<List<DeliveryModel>> getAvailableDeliveries() async {
    try {
      final response = await SupabaseConfig.from('deliveries')
          .select()
          .eq('status', DeliveryStatus.pending.value)
          .isFilter('rider_id', null)
          .order('created_at', ascending: false);

      return response.map((json) => DeliveryModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Accept delivery (for riders)
  Future<DeliveryResult> acceptDelivery(String deliveryId, String riderId) async {
    try {
      final response = await SupabaseConfig.from('deliveries')
          .update({
            'rider_id': riderId,
            'status': DeliveryStatus.accepted.value,
            'accepted_at': DateTime.now().toIso8601String(),
          })
          .eq('id', deliveryId)
          .select()
          .single();

      final updatedDelivery = DeliveryModel.fromJson(response);
      
      // Add delivery update
      await _addDeliveryUpdate(
        deliveryId: deliveryId,
        status: 'accepted',
        message: 'Delivery accepted by rider',
      );
      
      return DeliveryResult.success(
        delivery: updatedDelivery,
        message: 'Delivery accepted successfully',
      );
    } catch (e) {
      return DeliveryResult.error(message: 'Failed to accept delivery: $e');
    }
  }

  // Update delivery status
  Future<DeliveryResult> updateDeliveryStatus(
    String deliveryId,
    DeliveryStatus status, {
    LocationData? location,
    String? message,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.value,
      };

      // Add timestamp fields based on status
      switch (status) {
        case DeliveryStatus.pickedUp:
          updateData['picked_up_at'] = DateTime.now().toIso8601String();
          break;
        case DeliveryStatus.delivered:
          updateData['delivered_at'] = DateTime.now().toIso8601String();
          break;
        default:
          break;
      }

      final response = await SupabaseConfig.from('deliveries')
          .update(updateData)
          .eq('id', deliveryId)
          .select()
          .single();

      final updatedDelivery = DeliveryModel.fromJson(response);
      
      // Add delivery update
      await _addDeliveryUpdate(
        deliveryId: deliveryId,
        status: status.value,
        message: message ?? 'Delivery status updated to ${status.displayName}',
        location: location,
      );
      
      return DeliveryResult.success(
        delivery: updatedDelivery,
        message: 'Delivery status updated successfully',
      );
    } catch (e) {
      return DeliveryResult.error(message: 'Failed to update delivery status: $e');
    }
  }

  // Cancel delivery
  Future<DeliveryResult> cancelDelivery(String deliveryId, String reason) async {
    try {
      final response = await SupabaseConfig.from('deliveries')
          .update({
            'status': DeliveryStatus.cancelled.value,
          })
          .eq('id', deliveryId)
          .select()
          .single();

      final updatedDelivery = DeliveryModel.fromJson(response);
      
      // Add delivery update
      await _addDeliveryUpdate(
        deliveryId: deliveryId,
        status: 'cancelled',
        message: 'Delivery cancelled: $reason',
      );
      
      return DeliveryResult.success(
        delivery: updatedDelivery,
        message: 'Delivery cancelled successfully',
      );
    } catch (e) {
      return DeliveryResult.error(message: 'Failed to cancel delivery: $e');
    }
  }

  // Get delivery by ID
  Future<DeliveryModel?> getDeliveryById(String deliveryId) async {
    try {
      final response = await SupabaseConfig.from('deliveries')
          .select()
          .eq('id', deliveryId)
          .single();

      return DeliveryModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Get delivery updates/tracking
  Future<List<DeliveryUpdate>> getDeliveryUpdates(String deliveryId) async {
    try {
      final response = await SupabaseConfig.from('delivery_updates')
          .select()
          .eq('delivery_id', deliveryId)
          .order('timestamp', ascending: true);

      return response.map((json) => DeliveryUpdate.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Calculate delivery price
  Future<double> calculateDeliveryPrice({
    required LocationData pickup,
    required LocationData dropoff,
    required PackageSize packageSize,
    bool isFragile = false,
    bool requiresSignature = false,
  }) async {
    // Basic price calculation
    double basePrice = 200.0;
    
    // Calculate distance (simplified - in real app would use maps API)
    final distance = _calculateDistance(pickup, dropoff);
    
    // Price based on package size
    switch (packageSize) {
      case PackageSize.small:
        basePrice = 200.0;
        break;
      case PackageSize.medium:
        basePrice = 350.0;
        break;
      case PackageSize.large:
        basePrice = 500.0;
        break;
      case PackageSize.extraLarge:
        basePrice = 750.0;
        break;
    }
    
    // Add distance multiplier
    basePrice += distance * 20; // KSh 20 per km
    
    // Add additional charges
    if (isFragile) basePrice += 100.0;
    if (requiresSignature) basePrice += 50.0;
    
    return basePrice;
  }

  // Subscribe to real-time delivery updates
  RealtimeChannel subscribeToDeliveryUpdates(String deliveryId, Function(DeliveryModel) onUpdate) {
    final channel = SupabaseConfig.realtime('deliveries');
    
    // Setup real-time subscription for delivery updates
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'deliveries',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: deliveryId,
      ),
      callback: (payload) {
        final newRecord = payload.newRecord;
        final delivery = DeliveryModel.fromJson(newRecord);
        onUpdate(delivery);
      },
    );
    
    channel.subscribe();
    return channel;
  }

  // Private helper methods
  Future<void> _notifyAvailableRiders(DeliveryModel delivery) async {
    // Implementation: Send push notifications to nearby riders
    // This would integrate with FCM or similar service
  }

  Future<void> _addDeliveryUpdate({
    required String deliveryId,
    required String status,
    required String message,
    LocationData? location,
  }) async {
    try {
      await SupabaseConfig.from('delivery_updates').insert({
        'id': _generateId(),
        'delivery_id': deliveryId,
        'status': status,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
        'location': location?.toJson(),
      });
    } catch (e) {
      // Log error but don't fail the main operation
    }
  }

  double _calculateDistance(LocationData point1, LocationData point2) {
    // Simplified distance calculation (Haversine formula would be more accurate)
    final lat1 = point1.latitude;
    final lon1 = point1.longitude;
    final lat2 = point2.latitude;
    final lon2 = point2.longitude;
    
    final latDiff = (lat2 - lat1).abs();
    final lonDiff = (lon2 - lon1).abs();
    
    // Approximate distance in km (simplified)
    return (latDiff + lonDiff) * 111; // 1 degree ≈ 111 km
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

class DeliveryNotifier extends StateNotifier<AsyncValue<List<DeliveryModel>>> {
  DeliveryNotifier(this._deliveryService) : super(const AsyncValue.loading());

  final DeliveryService _deliveryService;

  Future<void> loadUserDeliveries(String userId) async {
    try {
      final deliveries = await _deliveryService.getUserDeliveries(userId);
      state = AsyncValue.data(deliveries);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadAvailableDeliveries() async {
    try {
      final deliveries = await _deliveryService.getAvailableDeliveries();
      state = AsyncValue.data(deliveries);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<DeliveryResult> createDelivery(DeliveryModel delivery) async {
    final result = await _deliveryService.createDelivery(delivery);
    
    if (result.isSuccess && result.delivery != null) {
      // Add to current list if available
      if (state.hasValue) {
        state = AsyncValue.data([result.delivery!, ...state.value!]);
      }
    }
    
    return result;
  }

  Future<DeliveryResult> acceptDelivery(String deliveryId, String riderId) async {
    final result = await _deliveryService.acceptDelivery(deliveryId, riderId);
    
    if (result.isSuccess && result.delivery != null) {
      _updateDeliveryInState(result.delivery!);
    }
    
    return result;
  }

  Future<DeliveryResult> updateDeliveryStatus(
    String deliveryId,
    DeliveryStatus status, {
    LocationData? location,
    String? message,
  }) async {
    final result = await _deliveryService.updateDeliveryStatus(
      deliveryId,
      status,
      location: location,
      message: message,
    );
    
    if (result.isSuccess && result.delivery != null) {
      _updateDeliveryInState(result.delivery!);
    }
    
    return result;
  }

  void _updateDeliveryInState(DeliveryModel updatedDelivery) {
    if (state.hasValue) {
      final currentDeliveries = state.value!;
      final updatedList = currentDeliveries.map((delivery) {
        return delivery.id == updatedDelivery.id ? updatedDelivery : delivery;
      }).toList();
      
      state = AsyncValue.data(updatedList);
    }
  }
}

class DeliveryResult {
  final bool isSuccess;
  final String message;
  final DeliveryModel? delivery;

  const DeliveryResult._({
    required this.isSuccess,
    required this.message,
    this.delivery,
  });

  factory DeliveryResult.success({
    required String message,
    DeliveryModel? delivery,
  }) {
    return DeliveryResult._(
      isSuccess: true,
      message: message,
      delivery: delivery,
    );
  }

  factory DeliveryResult.error({required String message}) {
    return DeliveryResult._(
      isSuccess: false,
      message: message,
    );
  }
}