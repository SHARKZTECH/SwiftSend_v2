class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final UserType userType;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? profileImageUrl;
  final bool isVerified;
  final bool isActive;
  final UserProfile? profile;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.userType,
    required this.createdAt,
    this.updatedAt,
    this.profileImageUrl,
    this.isVerified = false,
    this.isActive = true,
    this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      userType: UserType.values.firstWhere(
        (e) => e.value == json['user_type'],
        orElse: () => UserType.customer,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      profileImageUrl: json['profile_image_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      profile: json['profile'] != null 
          ? UserProfile.fromJson(json['profile'] as Map<String, dynamic>) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'user_type': userType.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'profile_image_url': profileImageUrl,
      'is_verified': isVerified,
      'is_active': isActive,
      'profile': profile?.toJson(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    UserType? userType,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profileImageUrl,
    bool? isVerified,
    bool? isActive,
    UserProfile? profile,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      profile: profile ?? this.profile,
    );
  }
}

class UserProfile {
  final String? bio;
  final String? address;
  final String? city;
  final String? country;
  final String? idNumber;
  final String? licenseNumber; // For riders
  final String? vehicleType; // For riders
  final String? plateNumber; // For riders
  final double? rating;
  final int? completedDeliveries;
  final double? totalEarnings; // For riders
  final BusinessInfo? businessInfo; // For business users

  const UserProfile({
    this.bio,
    this.address,
    this.city,
    this.country,
    this.idNumber,
    this.licenseNumber,
    this.vehicleType,
    this.plateNumber,
    this.rating,
    this.completedDeliveries,
    this.totalEarnings,
    this.businessInfo,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      bio: json['bio'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      idNumber: json['id_number'] as String?,
      licenseNumber: json['license_number'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      plateNumber: json['plate_number'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      completedDeliveries: json['completed_deliveries'] as int?,
      totalEarnings: json['total_earnings'] != null 
          ? (json['total_earnings'] as num).toDouble() 
          : null,
      businessInfo: json['business_info'] != null 
          ? BusinessInfo.fromJson(json['business_info'] as Map<String, dynamic>) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bio': bio,
      'address': address,
      'city': city,
      'country': country,
      'id_number': idNumber,
      'license_number': licenseNumber,
      'vehicle_type': vehicleType,
      'plate_number': plateNumber,
      'rating': rating,
      'completed_deliveries': completedDeliveries,
      'total_earnings': totalEarnings,
      'business_info': businessInfo?.toJson(),
    };
  }
}

class BusinessInfo {
  final String businessName;
  final String businessType;
  final String? businessRegistrationNumber;
  final String? taxNumber;
  final String? website;
  final String? description;

  const BusinessInfo({
    required this.businessName,
    required this.businessType,
    this.businessRegistrationNumber,
    this.taxNumber,
    this.website,
    this.description,
  });

  factory BusinessInfo.fromJson(Map<String, dynamic> json) {
    return BusinessInfo(
      businessName: json['business_name'] as String,
      businessType: json['business_type'] as String,
      businessRegistrationNumber: json['business_registration_number'] as String?,
      taxNumber: json['tax_number'] as String?,
      website: json['website'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_name': businessName,
      'business_type': businessType,
      'business_registration_number': businessRegistrationNumber,
      'tax_number': taxNumber,
      'website': website,
      'description': description,
    };
  }
}

enum UserType {
  customer('customer'),
  business('business'),
  rider('rider'),
  admin('admin');

  const UserType(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case UserType.customer:
        return 'Customer';
      case UserType.business:
        return 'Business';
      case UserType.rider:
        return 'Rider';
      case UserType.admin:
        return 'Admin';
    }
  }
}