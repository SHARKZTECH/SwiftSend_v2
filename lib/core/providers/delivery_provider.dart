// This file is temporarily disabled until code generation is set up
// Will be implemented later with proper delivery models

/*
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/delivery.dart';

part 'delivery_provider.g.dart';

@riverpod
class DeliveryNotifier extends _$DeliveryNotifier {
  @override
  List<Delivery> build() {
    // Initialize with mock delivery data
    return [
      Delivery(
        id: '1',
        senderId: 'user1',
        receiverName: 'John Doe',
        receiverPhone: '+254700000001',
        pickupAddress: 'Westlands Shopping Mall',
        pickupLocation: const LocationData(
          latitude: -1.2634,
          longitude: 36.8107,
          address: 'Westlands Shopping Mall',
        ),
        dropoffAddress: 'Karen Shopping Centre',
        dropoffLocation: const LocationData(
          latitude: -1.3194,
          longitude: 36.7073,
          address: 'Karen Shopping Centre',
        ),
        packageSize: PackageSize.small,
        initialPrice: 300.0,
        agreedPrice: 280.0,
        status: DeliveryStatus.delivered,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        deliveredAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Delivery(
        id: '2',
        senderId: 'user1',
        receiverName: 'Jane Smith',
        receiverPhone: '+254700000002',
        pickupAddress: 'CBD Post Office',
        pickupLocation: const LocationData(
          latitude: -1.2841,
          longitude: 36.8155,
          address: 'CBD Post Office',
        ),
        dropoffAddress: 'Kilimani Estate',
        dropoffLocation: const LocationData(
          latitude: -1.2921,
          longitude: 36.7879,
          address: 'Kilimani Estate',
        ),
        packageSize: PackageSize.medium,
        initialPrice: 450.0,
        status: DeliveryStatus.inTransit,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        pickedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];
  }

  Future<void> createDelivery(Delivery delivery) async {
    // TODO: Implement actual delivery creation with Supabase
    await Future.delayed(const Duration(seconds: 1)); // Mock delay
    
    state = [...state, delivery];
  }

  Future<void> updateDeliveryStatus(String deliveryId, DeliveryStatus status) async {
    // TODO: Implement actual status update with Supabase
    await Future.delayed(const Duration(milliseconds: 500)); // Mock delay
    
    state = [
      for (final delivery in state)
        if (delivery.id == deliveryId)
          delivery.copyWith(status: status)
        else
          delivery,
    ];
  }

  Future<void> assignRider(String deliveryId, String riderId) async {
    // TODO: Implement actual rider assignment with Supabase
    await Future.delayed(const Duration(milliseconds: 500)); // Mock delay
    
    state = [
      for (final delivery in state)
        if (delivery.id == deliveryId)
          delivery.copyWith(riderId: riderId, status: DeliveryStatus.accepted)
        else
          delivery,
    ];
  }
}

// Computed providers for filtered deliveries
@riverpod
List<Delivery> activeDeliveries(ActiveDeliveriesRef ref) {
  final deliveries = ref.watch(deliveryNotifierProvider);
  return deliveries.where((delivery) => 
    delivery.status != DeliveryStatus.delivered && 
    delivery.status != DeliveryStatus.cancelled
  ).toList();
}

@riverpod
List<Delivery> completedDeliveries(CompletedDeliveriesRef ref) {
  final deliveries = ref.watch(deliveryNotifierProvider);
  return deliveries.where((delivery) => 
    delivery.status == DeliveryStatus.delivered
  ).toList();
}

@riverpod
List<Delivery> userDeliveries(UserDeliveriesRef ref, String userId) {
  final deliveries = ref.watch(deliveryNotifierProvider);
  return deliveries.where((delivery) => 
    delivery.senderId == userId || delivery.riderId == userId
  ).toList();
}
*/