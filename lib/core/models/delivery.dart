// This file is temporarily disabled until code generation is set up
// Will be implemented later with proper models

/*
import 'package:freezed_annotation/freezed_annotation.dart';

part 'delivery.freezed.dart';
part 'delivery.g.dart';

@freezed
class Delivery with _$Delivery {
  const factory Delivery({
    required String id,
    required String senderId,
    String? riderId,
    required String receiverName,
    required String receiverPhone,
    required String pickupAddress,
    required LocationData pickupLocation,
    required String dropoffAddress,
    required LocationData dropoffLocation,
    String? packageDescription,
    required PackageSize packageSize,
    double? initialPrice,
    double? agreedPrice,
    @Default(0.15) double commissionRate,
    double? platformFee,
    @Default(DeliveryStatus.pending) DeliveryStatus status,
    String? pickupPhotoUrl,
    String? deliveryPhotoUrl,
    String? signatureUrl,
    required DateTime createdAt,
    DateTime? pickedAt,
    DateTime? deliveredAt,
  }) = _Delivery;

  factory Delivery.fromJson(Map<String, dynamic> json) => _$DeliveryFromJson(json);
}

@freezed
class LocationData with _$LocationData {
  const factory LocationData({
    required double latitude,
    required double longitude,
    String? address,
  }) = _LocationData;

  factory LocationData.fromJson(Map<String, dynamic> json) => _$LocationDataFromJson(json);
}

@JsonEnum()
enum PackageSize {
  @JsonValue('small')
  small,
  @JsonValue('medium')
  medium,
  @JsonValue('large')
  large,
}

@JsonEnum()
enum DeliveryStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('negotiating')
  negotiating,
  @JsonValue('accepted')
  accepted,
  @JsonValue('picked_up')
  pickedUp,
  @JsonValue('in_transit')
  inTransit,
  @JsonValue('delivered')
  delivered,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('disputed')
  disputed,
}
*/