// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BookingModel _$BookingModelFromJson(Map<String, dynamic> json) {
  return _BookingModel.fromJson(json);
}

/// @nodoc
mixin _$BookingModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get stationId => throw _privateConstructorUsedError;
  String get slotId => throw _privateConstructorUsedError;
  BookingStatus get status => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  double get pricePerHour => throw _privateConstructorUsedError;
  int get durationHours => throw _privateConstructorUsedError;
  double get totalPrice => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get cancelledAt => throw _privateConstructorUsedError;
  String? get cancellationReason => throw _privateConstructorUsedError;
  String? get qrToken => throw _privateConstructorUsedError;

  /// Serializes this BookingModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingModelCopyWith<BookingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingModelCopyWith<$Res> {
  factory $BookingModelCopyWith(
          BookingModel value, $Res Function(BookingModel) then) =
      _$BookingModelCopyWithImpl<$Res, BookingModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String stationId,
      String slotId,
      BookingStatus status,
      DateTime startTime,
      DateTime? endTime,
      double pricePerHour,
      int durationHours,
      double totalPrice,
      DateTime createdAt,
      DateTime? cancelledAt,
      String? cancellationReason,
      String? qrToken});
}

/// @nodoc
class _$BookingModelCopyWithImpl<$Res, $Val extends BookingModel>
    implements $BookingModelCopyWith<$Res> {
  _$BookingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? stationId = null,
    Object? slotId = null,
    Object? status = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? pricePerHour = null,
    Object? durationHours = null,
    Object? totalPrice = null,
    Object? createdAt = null,
    Object? cancelledAt = freezed,
    Object? cancellationReason = freezed,
    Object? qrToken = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      stationId: null == stationId
          ? _value.stationId
          : stationId // ignore: cast_nullable_to_non_nullable
              as String,
      slotId: null == slotId
          ? _value.slotId
          : slotId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pricePerHour: null == pricePerHour
          ? _value.pricePerHour
          : pricePerHour // ignore: cast_nullable_to_non_nullable
              as double,
      durationHours: null == durationHours
          ? _value.durationHours
          : durationHours // ignore: cast_nullable_to_non_nullable
              as int,
      totalPrice: null == totalPrice
          ? _value.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancellationReason: freezed == cancellationReason
          ? _value.cancellationReason
          : cancellationReason // ignore: cast_nullable_to_non_nullable
              as String?,
      qrToken: freezed == qrToken
          ? _value.qrToken
          : qrToken // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookingModelImplCopyWith<$Res>
    implements $BookingModelCopyWith<$Res> {
  factory _$$BookingModelImplCopyWith(
          _$BookingModelImpl value, $Res Function(_$BookingModelImpl) then) =
      __$$BookingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String stationId,
      String slotId,
      BookingStatus status,
      DateTime startTime,
      DateTime? endTime,
      double pricePerHour,
      int durationHours,
      double totalPrice,
      DateTime createdAt,
      DateTime? cancelledAt,
      String? cancellationReason,
      String? qrToken});
}

/// @nodoc
class __$$BookingModelImplCopyWithImpl<$Res>
    extends _$BookingModelCopyWithImpl<$Res, _$BookingModelImpl>
    implements _$$BookingModelImplCopyWith<$Res> {
  __$$BookingModelImplCopyWithImpl(
      _$BookingModelImpl _value, $Res Function(_$BookingModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? stationId = null,
    Object? slotId = null,
    Object? status = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? pricePerHour = null,
    Object? durationHours = null,
    Object? totalPrice = null,
    Object? createdAt = null,
    Object? cancelledAt = freezed,
    Object? cancellationReason = freezed,
    Object? qrToken = freezed,
  }) {
    return _then(_$BookingModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      stationId: null == stationId
          ? _value.stationId
          : stationId // ignore: cast_nullable_to_non_nullable
              as String,
      slotId: null == slotId
          ? _value.slotId
          : slotId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pricePerHour: null == pricePerHour
          ? _value.pricePerHour
          : pricePerHour // ignore: cast_nullable_to_non_nullable
              as double,
      durationHours: null == durationHours
          ? _value.durationHours
          : durationHours // ignore: cast_nullable_to_non_nullable
              as int,
      totalPrice: null == totalPrice
          ? _value.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancellationReason: freezed == cancellationReason
          ? _value.cancellationReason
          : cancellationReason // ignore: cast_nullable_to_non_nullable
              as String?,
      qrToken: freezed == qrToken
          ? _value.qrToken
          : qrToken // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingModelImpl implements _BookingModel {
  const _$BookingModelImpl(
      {required this.id,
      required this.userId,
      required this.stationId,
      required this.slotId,
      required this.status,
      required this.startTime,
      this.endTime,
      required this.pricePerHour,
      required this.durationHours,
      required this.totalPrice,
      required this.createdAt,
      this.cancelledAt,
      this.cancellationReason,
      this.qrToken});

  factory _$BookingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String stationId;
  @override
  final String slotId;
  @override
  final BookingStatus status;
  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;
  @override
  final double pricePerHour;
  @override
  final int durationHours;
  @override
  final double totalPrice;
  @override
  final DateTime createdAt;
  @override
  final DateTime? cancelledAt;
  @override
  final String? cancellationReason;
  @override
  final String? qrToken;

  @override
  String toString() {
    return 'BookingModel(id: $id, userId: $userId, stationId: $stationId, slotId: $slotId, status: $status, startTime: $startTime, endTime: $endTime, pricePerHour: $pricePerHour, durationHours: $durationHours, totalPrice: $totalPrice, createdAt: $createdAt, cancelledAt: $cancelledAt, cancellationReason: $cancellationReason, qrToken: $qrToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.stationId, stationId) ||
                other.stationId == stationId) &&
            (identical(other.slotId, slotId) || other.slotId == slotId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.pricePerHour, pricePerHour) ||
                other.pricePerHour == pricePerHour) &&
            (identical(other.durationHours, durationHours) ||
                other.durationHours == durationHours) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt) &&
            (identical(other.cancellationReason, cancellationReason) ||
                other.cancellationReason == cancellationReason) &&
            (identical(other.qrToken, qrToken) || other.qrToken == qrToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      stationId,
      slotId,
      status,
      startTime,
      endTime,
      pricePerHour,
      durationHours,
      totalPrice,
      createdAt,
      cancelledAt,
      cancellationReason,
      qrToken);

  /// Create a copy of BookingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingModelImplCopyWith<_$BookingModelImpl> get copyWith =>
      __$$BookingModelImplCopyWithImpl<_$BookingModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingModelImplToJson(
      this,
    );
  }
}

abstract class _BookingModel implements BookingModel {
  const factory _BookingModel(
      {required final String id,
      required final String userId,
      required final String stationId,
      required final String slotId,
      required final BookingStatus status,
      required final DateTime startTime,
      final DateTime? endTime,
      required final double pricePerHour,
      required final int durationHours,
      required final double totalPrice,
      required final DateTime createdAt,
      final DateTime? cancelledAt,
      final String? cancellationReason,
      final String? qrToken}) = _$BookingModelImpl;

  factory _BookingModel.fromJson(Map<String, dynamic> json) =
      _$BookingModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get stationId;
  @override
  String get slotId;
  @override
  BookingStatus get status;
  @override
  DateTime get startTime;
  @override
  DateTime? get endTime;
  @override
  double get pricePerHour;
  @override
  int get durationHours;
  @override
  double get totalPrice;
  @override
  DateTime get createdAt;
  @override
  DateTime? get cancelledAt;
  @override
  String? get cancellationReason;
  @override
  String? get qrToken;

  /// Create a copy of BookingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingModelImplCopyWith<_$BookingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
