/// Simple User model without code generation for immediate use
class User {
  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.userType,
    this.avatarUrl,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final UserType userType;
  final String? avatarUrl;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    UserType? userType,
    String? avatarUrl,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userType: userType ?? this.userType,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'user_type': userType.value,
      'avatar_url': avatarUrl,
      'is_verified': isVerified,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      userType: UserType.fromString(json['user_type'] as String),
      avatarUrl: json['avatar_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}

enum UserType {
  customer('customer'),
  business('business'),
  rider('rider');

  const UserType(this.value);
  final String value;

  static UserType fromString(String value) {
    return UserType.values.firstWhere((e) => e.value == value);
  }
}