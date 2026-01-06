// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookingModelImpl _$$BookingModelImplFromJson(Map<String, dynamic> json) =>
    _$BookingModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      stationId: json['stationId'] as String,
      slotId: json['slotId'] as String,
      status: $enumDecode(_$BookingStatusEnumMap, json['status']),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      durationHours: (json['durationHours'] as num).toInt(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
      cancellationReason: json['cancellationReason'] as String?,
      qrToken: json['qrToken'] as String?,
    );

Map<String, dynamic> _$$BookingModelImplToJson(_$BookingModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'stationId': instance.stationId,
      'slotId': instance.slotId,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'pricePerHour': instance.pricePerHour,
      'durationHours': instance.durationHours,
      'totalPrice': instance.totalPrice,
      'createdAt': instance.createdAt.toIso8601String(),
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'cancellationReason': instance.cancellationReason,
      'qrToken': instance.qrToken,
    };

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'pending',
  BookingStatus.active: 'active',
  BookingStatus.reserved: 'reserved',
  BookingStatus.completed: 'completed',
  BookingStatus.cancelled: 'cancelled',
};
