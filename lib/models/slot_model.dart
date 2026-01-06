import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'slot_model.freezed.dart';
part 'slot_model.g.dart';

@freezed
class SlotModel with _$SlotModel {
  const factory SlotModel({
    required String id,
    required String stationId,
    required int slotIndex,
    required SlotType type,
    required SlotStatus status,
    BatteryStatus? batteryStatus,
    required DateTime lastUpdated,
    String? reservedByUserId,
    DateTime? reservedUntil,
  }) = _SlotModel;

  factory SlotModel.fromJson(Map<String, dynamic> json) =>
      _$SlotModelFromJson(json);
}
