// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slot_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SlotModel _$SlotModelFromJson(Map<String, dynamic> json) {
  return _SlotModel.fromJson(json);
}

/// @nodoc
mixin _$SlotModel {
  String get id => throw _privateConstructorUsedError;
  String get stationId => throw _privateConstructorUsedError;
  int get slotIndex => throw _privateConstructorUsedError;
  SlotType get type => throw _privateConstructorUsedError;
  SlotStatus get status => throw _privateConstructorUsedError;
  BatteryStatus? get batteryStatus => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;
  String? get reservedByUserId => throw _privateConstructorUsedError;
  DateTime? get reservedUntil => throw _privateConstructorUsedError;

  /// Serializes this SlotModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SlotModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SlotModelCopyWith<SlotModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SlotModelCopyWith<$Res> {
  factory $SlotModelCopyWith(SlotModel value, $Res Function(SlotModel) then) =
      _$SlotModelCopyWithImpl<$Res, SlotModel>;
  @useResult
  $Res call(
      {String id,
      String stationId,
      int slotIndex,
      SlotType type,
      SlotStatus status,
      BatteryStatus? batteryStatus,
      DateTime lastUpdated,
      String? reservedByUserId,
      DateTime? reservedUntil});
}

/// @nodoc
class _$SlotModelCopyWithImpl<$Res, $Val extends SlotModel>
    implements $SlotModelCopyWith<$Res> {
  _$SlotModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SlotModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stationId = null,
    Object? slotIndex = null,
    Object? type = null,
    Object? status = null,
    Object? batteryStatus = freezed,
    Object? lastUpdated = null,
    Object? reservedByUserId = freezed,
    Object? reservedUntil = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      stationId: null == stationId
          ? _value.stationId
          : stationId // ignore: cast_nullable_to_non_nullable
              as String,
      slotIndex: null == slotIndex
          ? _value.slotIndex
          : slotIndex // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SlotType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SlotStatus,
      batteryStatus: freezed == batteryStatus
          ? _value.batteryStatus
          : batteryStatus // ignore: cast_nullable_to_non_nullable
              as BatteryStatus?,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reservedByUserId: freezed == reservedByUserId
          ? _value.reservedByUserId
          : reservedByUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      reservedUntil: freezed == reservedUntil
          ? _value.reservedUntil
          : reservedUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SlotModelImplCopyWith<$Res>
    implements $SlotModelCopyWith<$Res> {
  factory _$$SlotModelImplCopyWith(
          _$SlotModelImpl value, $Res Function(_$SlotModelImpl) then) =
      __$$SlotModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String stationId,
      int slotIndex,
      SlotType type,
      SlotStatus status,
      BatteryStatus? batteryStatus,
      DateTime lastUpdated,
      String? reservedByUserId,
      DateTime? reservedUntil});
}

/// @nodoc
class __$$SlotModelImplCopyWithImpl<$Res>
    extends _$SlotModelCopyWithImpl<$Res, _$SlotModelImpl>
    implements _$$SlotModelImplCopyWith<$Res> {
  __$$SlotModelImplCopyWithImpl(
      _$SlotModelImpl _value, $Res Function(_$SlotModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SlotModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stationId = null,
    Object? slotIndex = null,
    Object? type = null,
    Object? status = null,
    Object? batteryStatus = freezed,
    Object? lastUpdated = null,
    Object? reservedByUserId = freezed,
    Object? reservedUntil = freezed,
  }) {
    return _then(_$SlotModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      stationId: null == stationId
          ? _value.stationId
          : stationId // ignore: cast_nullable_to_non_nullable
              as String,
      slotIndex: null == slotIndex
          ? _value.slotIndex
          : slotIndex // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SlotType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SlotStatus,
      batteryStatus: freezed == batteryStatus
          ? _value.batteryStatus
          : batteryStatus // ignore: cast_nullable_to_non_nullable
              as BatteryStatus?,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reservedByUserId: freezed == reservedByUserId
          ? _value.reservedByUserId
          : reservedByUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      reservedUntil: freezed == reservedUntil
          ? _value.reservedUntil
          : reservedUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SlotModelImpl implements _SlotModel {
  const _$SlotModelImpl(
      {required this.id,
      required this.stationId,
      required this.slotIndex,
      required this.type,
      required this.status,
      this.batteryStatus,
      required this.lastUpdated,
      this.reservedByUserId,
      this.reservedUntil});

  factory _$SlotModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SlotModelImplFromJson(json);

  @override
  final String id;
  @override
  final String stationId;
  @override
  final int slotIndex;
  @override
  final SlotType type;
  @override
  final SlotStatus status;
  @override
  final BatteryStatus? batteryStatus;
  @override
  final DateTime lastUpdated;
  @override
  final String? reservedByUserId;
  @override
  final DateTime? reservedUntil;

  @override
  String toString() {
    return 'SlotModel(id: $id, stationId: $stationId, slotIndex: $slotIndex, type: $type, status: $status, batteryStatus: $batteryStatus, lastUpdated: $lastUpdated, reservedByUserId: $reservedByUserId, reservedUntil: $reservedUntil)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SlotModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.stationId, stationId) ||
                other.stationId == stationId) &&
            (identical(other.slotIndex, slotIndex) ||
                other.slotIndex == slotIndex) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.batteryStatus, batteryStatus) ||
                other.batteryStatus == batteryStatus) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.reservedByUserId, reservedByUserId) ||
                other.reservedByUserId == reservedByUserId) &&
            (identical(other.reservedUntil, reservedUntil) ||
                other.reservedUntil == reservedUntil));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, stationId, slotIndex, type,
      status, batteryStatus, lastUpdated, reservedByUserId, reservedUntil);

  /// Create a copy of SlotModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SlotModelImplCopyWith<_$SlotModelImpl> get copyWith =>
      __$$SlotModelImplCopyWithImpl<_$SlotModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SlotModelImplToJson(
      this,
    );
  }
}

abstract class _SlotModel implements SlotModel {
  const factory _SlotModel(
      {required final String id,
      required final String stationId,
      required final int slotIndex,
      required final SlotType type,
      required final SlotStatus status,
      final BatteryStatus? batteryStatus,
      required final DateTime lastUpdated,
      final String? reservedByUserId,
      final DateTime? reservedUntil}) = _$SlotModelImpl;

  factory _SlotModel.fromJson(Map<String, dynamic> json) =
      _$SlotModelImpl.fromJson;

  @override
  String get id;
  @override
  String get stationId;
  @override
  int get slotIndex;
  @override
  SlotType get type;
  @override
  SlotStatus get status;
  @override
  BatteryStatus? get batteryStatus;
  @override
  DateTime get lastUpdated;
  @override
  String? get reservedByUserId;
  @override
  DateTime? get reservedUntil;

  /// Create a copy of SlotModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SlotModelImplCopyWith<_$SlotModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
