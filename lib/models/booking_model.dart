import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'booking_model.freezed.dart';
part 'booking_model.g.dart';

@freezed
class BookingModel with _$BookingModel {
  const factory BookingModel({
    required String id,
    required String userId,
    required String stationId,
    required String slotId,
    required BookingStatus status,
    required DateTime startTime,
    DateTime? endTime,
    required double pricePerHour,
    required int durationHours,
    required double totalPrice,
    required DateTime createdAt,
    DateTime? cancelledAt,
    String? cancellationReason,
  }) = _BookingModel;

  factory BookingModel.fromJson(Map<String, dynamic> json) =>
      _$BookingModelFromJson(json);
}
