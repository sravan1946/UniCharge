// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StationModelImpl _$$StationModelImplFromJson(Map<String, dynamic> json) =>
    _$StationModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      type: $enumDecode(_$StationTypeEnumMap, json['type']),
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      batterySwap: json['batterySwap'] as bool,
      totalSlots: (json['totalSlots'] as num).toInt(),
      availableSlots: (json['availableSlots'] as num).toInt(),
      imageUrl: json['imageUrl'] as String,
      amenities:
          (json['amenities'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$StationModelImplToJson(_$StationModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'type': _$StationTypeEnumMap[instance.type]!,
      'pricePerHour': instance.pricePerHour,
      'batterySwap': instance.batterySwap,
      'totalSlots': instance.totalSlots,
      'availableSlots': instance.availableSlots,
      'imageUrl': instance.imageUrl,
      'amenities': instance.amenities,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$StationTypeEnumMap = {
  StationType.parking: 'parking',
  StationType.charging: 'charging',
  StationType.hybrid: 'hybrid',
};
