import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'station_model.freezed.dart';
part 'station_model.g.dart';

@freezed
class StationModel with _$StationModel {
  const factory StationModel({
    required String id,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required StationType type,
    required double pricePerHour,
    required bool batterySwap,
    required int totalSlots,
    required int availableSlots,
    required String imageUrl,
    required List<String> amenities,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _StationModel;

  factory StationModel.fromJson(Map<String, dynamic> json) =>
      _$StationModelFromJson(json);
}
