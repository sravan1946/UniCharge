import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_model.freezed.dart';
part 'user_profile_model.g.dart';

@freezed
class UserProfileModel with _$UserProfileModel {
  const factory UserProfileModel({
    required String id,
    required String email,
    required String name,
    String? phoneNumber,
    String? profileImageUrl,
    required int totalBookings,
    required double totalHoursParked,
    required int loyaltyPoints,
    required DateTime createdAt,
    required DateTime updatedAt,
    Map<String, dynamic>? preferences,
  }) = _UserProfileModel;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);
}
