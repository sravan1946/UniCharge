// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slot_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SlotModelImpl _$$SlotModelImplFromJson(Map<String, dynamic> json) =>
    _$SlotModelImpl(
      id: json['id'] as String,
      stationId: json['stationId'] as String,
      slotIndex: (json['slotIndex'] as num).toInt(),
      type: $enumDecode(_$SlotTypeEnumMap, json['type']),
      status: $enumDecode(_$SlotStatusEnumMap, json['status']),
      batteryStatus:
          $enumDecodeNullable(_$BatteryStatusEnumMap, json['batteryStatus']),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      reservedByUserId: json['reservedByUserId'] as String?,
      reservedUntil: json['reservedUntil'] == null
          ? null
          : DateTime.parse(json['reservedUntil'] as String),
    );

Map<String, dynamic> _$$SlotModelImplToJson(_$SlotModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stationId': instance.stationId,
      'slotIndex': instance.slotIndex,
      'type': _$SlotTypeEnumMap[instance.type]!,
      'status': _$SlotStatusEnumMap[instance.status]!,
      'batteryStatus': _$BatteryStatusEnumMap[instance.batteryStatus],
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'reservedByUserId': instance.reservedByUserId,
      'reservedUntil': instance.reservedUntil?.toIso8601String(),
    };

const _$SlotTypeEnumMap = {
  SlotType.parkingSpace: 'parkingSpace',
  SlotType.chargingPad: 'chargingPad',
};

const _$SlotStatusEnumMap = {
  SlotStatus.available: 'available',
  SlotStatus.occupied: 'occupied',
  SlotStatus.reserved: 'reserved',
  SlotStatus.maintenance: 'maintenance',
};

const _$BatteryStatusEnumMap = {
  BatteryStatus.charged: 'charged',
  BatteryStatus.charging: 'charging',
  BatteryStatus.swapped: 'swapped',
  BatteryStatus.empty: 'empty',
};
