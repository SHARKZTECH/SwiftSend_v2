// This file is temporarily disabled until code generation is set up
// Will be replaced by user_simple.dart for now

/*
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String fullName,
    required String phoneNumber,
    required UserType userType,
    String? avatarUrl,
    @Default(false) bool isVerified,
    @Default(true) bool isActive,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@JsonEnum()
enum UserType {
  @JsonValue('customer')
  customer,
  @JsonValue('business') 
  business,
  @JsonValue('rider')
  rider,
}
*/