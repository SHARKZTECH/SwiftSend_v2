class DeliveryModel {
  final String id;
  final String senderId;
  final String? riderId;
  final String receiverName;
  final String receiverPhone;
  final String pickupAddress;
  final LocationData pickupLocation;
  final String dropoffAddress;
  final LocationData dropoffLocation;
  final PackageInfo packageInfo;
  final double estimatedPrice;
  final double? finalPrice;
  final DeliveryStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final String? specialInstructions;
  final PaymentInfo? paymentInfo;
  final List<DeliveryUpdate>? updates;

  const DeliveryModel({
    required this.id,
    required this.senderId,
    this.riderId,
    required this.receiverName,
    required this.receiverPhone,
    required this.pickupAddress,
    required this.pickupLocation,
    required this.dropoffAddress,
    required this.dropoffLocation,
    required this.packageInfo,
    required this.estimatedPrice,
    this.finalPrice,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.specialInstructions,
    this.paymentInfo,
    this.updates,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      riderId: json['rider_id'] as String?,
      receiverName: json['receiver_name'] as String,
      receiverPhone: json['receiver_phone'] as String,
      pickupAddress: json['pickup_address'] as String,
      pickupLocation: LocationData.fromJson(json['pickup_location'] as Map<String, dynamic>),
      dropoffAddress: json['dropoff_address'] as String,
      dropoffLocation: LocationData.fromJson(json['dropoff_location'] as Map<String, dynamic>),
      packageInfo: PackageInfo.fromJson(json['package_info'] as Map<String, dynamic>),
      estimatedPrice: (json['estimated_price'] as num).toDouble(),
      finalPrice: json['final_price'] != null ? (json['final_price'] as num).toDouble() : null,
      status: DeliveryStatus.values.firstWhere(
        (e) => e.value == json['status'],
        orElse: () => DeliveryStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      acceptedAt: json['accepted_at'] != null ? DateTime.parse(json['accepted_at'] as String) : null,
      pickedUpAt: json['picked_up_at'] != null ? DateTime.parse(json['picked_up_at'] as String) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at'] as String) : null,
      specialInstructions: json['special_instructions'] as String?,
      paymentInfo: json['payment_info'] != null 
          ? PaymentInfo.fromJson(json['payment_info'] as Map<String, dynamic>) 
          : null,
      updates: json['updates'] != null
          ? (json['updates'] as List).map((e) => DeliveryUpdate.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'rider_id': riderId,
      'receiver_name': receiverName,
      'receiver_phone': receiverPhone,
      'pickup_address': pickupAddress,
      'pickup_location': pickupLocation.toJson(),
      'dropoff_address': dropoffAddress,
      'dropoff_location': dropoffLocation.toJson(),
      'package_info': packageInfo.toJson(),
      'estimated_price': estimatedPrice,
      'final_price': finalPrice,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'picked_up_at': pickedUpAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'special_instructions': specialInstructions,
      'payment_info': paymentInfo?.toJson(),
      'updates': updates?.map((e) => e.toJson()).toList(),
    };
  }

  DeliveryModel copyWith({
    String? id,
    String? senderId,
    String? riderId,
    String? receiverName,
    String? receiverPhone,
    String? pickupAddress,
    LocationData? pickupLocation,
    String? dropoffAddress,
    LocationData? dropoffLocation,
    PackageInfo? packageInfo,
    double? estimatedPrice,
    double? finalPrice,
    DeliveryStatus? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
    String? specialInstructions,
    PaymentInfo? paymentInfo,
    List<DeliveryUpdate>? updates,
  }) {
    return DeliveryModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      riderId: riderId ?? this.riderId,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      packageInfo: packageInfo ?? this.packageInfo,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      finalPrice: finalPrice ?? this.finalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      paymentInfo: paymentInfo ?? this.paymentInfo,
      updates: updates ?? this.updates,
    );
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final String address;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}

class PackageInfo {
  final PackageSize size;
  final String description;
  final bool isFragile;
  final bool requiresSignature;
  final double? weight;
  final String? category;

  const PackageInfo({
    required this.size,
    required this.description,
    required this.isFragile,
    required this.requiresSignature,
    this.weight,
    this.category,
  });

  factory PackageInfo.fromJson(Map<String, dynamic> json) {
    return PackageInfo(
      size: PackageSize.values.firstWhere(
        (e) => e.value == json['size'],
        orElse: () => PackageSize.small,
      ),
      description: json['description'] as String,
      isFragile: json['is_fragile'] as bool,
      requiresSignature: json['requires_signature'] as bool,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'size': size.value,
      'description': description,
      'is_fragile': isFragile,
      'requires_signature': requiresSignature,
      'weight': weight,
      'category': category,
    };
  }
}

class PaymentInfo {
  final String transactionId;
  final PaymentMethod method;
  final PaymentStatus status;
  final double amount;
  final DateTime? paidAt;
  final String? phoneNumber;

  const PaymentInfo({
    required this.transactionId,
    required this.method,
    required this.status,
    required this.amount,
    this.paidAt,
    this.phoneNumber,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      transactionId: json['transaction_id'] as String,
      method: PaymentMethod.values.firstWhere(
        (e) => e.value == json['method'],
        orElse: () => PaymentMethod.mpesa,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.value == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      amount: (json['amount'] as num).toDouble(),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at'] as String) : null,
      phoneNumber: json['phone_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'method': method.value,
      'status': status.value,
      'amount': amount,
      'paid_at': paidAt?.toIso8601String(),
      'phone_number': phoneNumber,
    };
  }
}

class DeliveryUpdate {
  final String id;
  final String deliveryId;
  final String status;
  final String message;
  final DateTime timestamp;
  final LocationData? location;

  const DeliveryUpdate({
    required this.id,
    required this.deliveryId,
    required this.status,
    required this.message,
    required this.timestamp,
    this.location,
  });

  factory DeliveryUpdate.fromJson(Map<String, dynamic> json) {
    return DeliveryUpdate(
      id: json['id'] as String,
      deliveryId: json['delivery_id'] as String,
      status: json['status'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      location: json['location'] != null
          ? LocationData.fromJson(json['location'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'delivery_id': deliveryId,
      'status': status,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'location': location?.toJson(),
    };
  }
}

enum DeliveryStatus {
  pending('pending'),
  accepted('accepted'),
  pickedUp('picked_up'),
  inTransit('in_transit'),
  delivered('delivered'),
  cancelled('cancelled'),
  failed('failed');

  const DeliveryStatus(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case DeliveryStatus.pending:
        return 'Pending';
      case DeliveryStatus.accepted:
        return 'Accepted';
      case DeliveryStatus.pickedUp:
        return 'Picked Up';
      case DeliveryStatus.inTransit:
        return 'In Transit';
      case DeliveryStatus.delivered:
        return 'Delivered';
      case DeliveryStatus.cancelled:
        return 'Cancelled';
      case DeliveryStatus.failed:
        return 'Failed';
    }
  }
}

enum PackageSize {
  small('small'),
  medium('medium'),
  large('large'),
  extraLarge('extra_large');

  const PackageSize(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case PackageSize.small:
        return 'Small';
      case PackageSize.medium:
        return 'Medium';
      case PackageSize.large:
        return 'Large';
      case PackageSize.extraLarge:
        return 'Extra Large';
    }
  }
}

enum PaymentMethod {
  mpesa('mpesa'),
  airtelMoney('airtel_money'),
  card('card'),
  cash('cash');

  const PaymentMethod(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case PaymentMethod.mpesa:
        return 'M-Pesa';
      case PaymentMethod.airtelMoney:
        return 'Airtel Money';
      case PaymentMethod.card:
        return 'Credit/Debit Card';
      case PaymentMethod.cash:
        return 'Cash';
    }
  }
}

enum PaymentStatus {
  pending('pending'),
  processing('processing'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled'),
  refunded('refunded');

  const PaymentStatus(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }
}