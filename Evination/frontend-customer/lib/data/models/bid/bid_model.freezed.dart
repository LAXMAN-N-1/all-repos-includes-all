// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bid_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BidModel _$BidModelFromJson(Map<String, dynamic> json) {
  return _BidModel.fromJson(json);
}

/// @nodoc
mixin _$BidModel {
  int get id => throw _privateConstructorUsedError;
  int get vendorId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get proposal => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime get submittedAt =>
      throw _privateConstructorUsedError; // Admin Curation Fields
  double? get platformCommission => throw _privateConstructorUsedError;
  double? get gstOnCommission => throw _privateConstructorUsedError;
  double? get gatewayFee => throw _privateConstructorUsedError;
  double? get finalPrice => throw _privateConstructorUsedError; // UI Helper
  String? get vendorName => throw _privateConstructorUsedError;
  String? get vendorImage => throw _privateConstructorUsedError;
  double? get vendorRating => throw _privateConstructorUsedError;

  /// Serializes this BidModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BidModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BidModelCopyWith<BidModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BidModelCopyWith<$Res> {
  factory $BidModelCopyWith(BidModel value, $Res Function(BidModel) then) =
      _$BidModelCopyWithImpl<$Res, BidModel>;
  @useResult
  $Res call(
      {int id,
      int vendorId,
      double amount,
      String proposal,
      String status,
      DateTime submittedAt,
      double? platformCommission,
      double? gstOnCommission,
      double? gatewayFee,
      double? finalPrice,
      String? vendorName,
      String? vendorImage,
      double? vendorRating});
}

/// @nodoc
class _$BidModelCopyWithImpl<$Res, $Val extends BidModel>
    implements $BidModelCopyWith<$Res> {
  _$BidModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BidModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? vendorId = null,
    Object? amount = null,
    Object? proposal = null,
    Object? status = null,
    Object? submittedAt = null,
    Object? platformCommission = freezed,
    Object? gstOnCommission = freezed,
    Object? gatewayFee = freezed,
    Object? finalPrice = freezed,
    Object? vendorName = freezed,
    Object? vendorImage = freezed,
    Object? vendorRating = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      vendorId: null == vendorId
          ? _value.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as int,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      proposal: null == proposal
          ? _value.proposal
          : proposal // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      submittedAt: null == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      platformCommission: freezed == platformCommission
          ? _value.platformCommission
          : platformCommission // ignore: cast_nullable_to_non_nullable
              as double?,
      gstOnCommission: freezed == gstOnCommission
          ? _value.gstOnCommission
          : gstOnCommission // ignore: cast_nullable_to_non_nullable
              as double?,
      gatewayFee: freezed == gatewayFee
          ? _value.gatewayFee
          : gatewayFee // ignore: cast_nullable_to_non_nullable
              as double?,
      finalPrice: freezed == finalPrice
          ? _value.finalPrice
          : finalPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      vendorName: freezed == vendorName
          ? _value.vendorName
          : vendorName // ignore: cast_nullable_to_non_nullable
              as String?,
      vendorImage: freezed == vendorImage
          ? _value.vendorImage
          : vendorImage // ignore: cast_nullable_to_non_nullable
              as String?,
      vendorRating: freezed == vendorRating
          ? _value.vendorRating
          : vendorRating // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BidModelImplCopyWith<$Res>
    implements $BidModelCopyWith<$Res> {
  factory _$$BidModelImplCopyWith(
          _$BidModelImpl value, $Res Function(_$BidModelImpl) then) =
      __$$BidModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int vendorId,
      double amount,
      String proposal,
      String status,
      DateTime submittedAt,
      double? platformCommission,
      double? gstOnCommission,
      double? gatewayFee,
      double? finalPrice,
      String? vendorName,
      String? vendorImage,
      double? vendorRating});
}

/// @nodoc
class __$$BidModelImplCopyWithImpl<$Res>
    extends _$BidModelCopyWithImpl<$Res, _$BidModelImpl>
    implements _$$BidModelImplCopyWith<$Res> {
  __$$BidModelImplCopyWithImpl(
      _$BidModelImpl _value, $Res Function(_$BidModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of BidModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? vendorId = null,
    Object? amount = null,
    Object? proposal = null,
    Object? status = null,
    Object? submittedAt = null,
    Object? platformCommission = freezed,
    Object? gstOnCommission = freezed,
    Object? gatewayFee = freezed,
    Object? finalPrice = freezed,
    Object? vendorName = freezed,
    Object? vendorImage = freezed,
    Object? vendorRating = freezed,
  }) {
    return _then(_$BidModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      vendorId: null == vendorId
          ? _value.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as int,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      proposal: null == proposal
          ? _value.proposal
          : proposal // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      submittedAt: null == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      platformCommission: freezed == platformCommission
          ? _value.platformCommission
          : platformCommission // ignore: cast_nullable_to_non_nullable
              as double?,
      gstOnCommission: freezed == gstOnCommission
          ? _value.gstOnCommission
          : gstOnCommission // ignore: cast_nullable_to_non_nullable
              as double?,
      gatewayFee: freezed == gatewayFee
          ? _value.gatewayFee
          : gatewayFee // ignore: cast_nullable_to_non_nullable
              as double?,
      finalPrice: freezed == finalPrice
          ? _value.finalPrice
          : finalPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      vendorName: freezed == vendorName
          ? _value.vendorName
          : vendorName // ignore: cast_nullable_to_non_nullable
              as String?,
      vendorImage: freezed == vendorImage
          ? _value.vendorImage
          : vendorImage // ignore: cast_nullable_to_non_nullable
              as String?,
      vendorRating: freezed == vendorRating
          ? _value.vendorRating
          : vendorRating // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BidModelImpl implements _BidModel {
  const _$BidModelImpl(
      {required this.id,
      required this.vendorId,
      required this.amount,
      required this.proposal,
      required this.status,
      required this.submittedAt,
      this.platformCommission,
      this.gstOnCommission,
      this.gatewayFee,
      this.finalPrice,
      this.vendorName,
      this.vendorImage,
      this.vendorRating});

  factory _$BidModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BidModelImplFromJson(json);

  @override
  final int id;
  @override
  final int vendorId;
  @override
  final double amount;
  @override
  final String proposal;
  @override
  final String status;
  @override
  final DateTime submittedAt;
// Admin Curation Fields
  @override
  final double? platformCommission;
  @override
  final double? gstOnCommission;
  @override
  final double? gatewayFee;
  @override
  final double? finalPrice;
// UI Helper
  @override
  final String? vendorName;
  @override
  final String? vendorImage;
  @override
  final double? vendorRating;

  @override
  String toString() {
    return 'BidModel(id: $id, vendorId: $vendorId, amount: $amount, proposal: $proposal, status: $status, submittedAt: $submittedAt, platformCommission: $platformCommission, gstOnCommission: $gstOnCommission, gatewayFee: $gatewayFee, finalPrice: $finalPrice, vendorName: $vendorName, vendorImage: $vendorImage, vendorRating: $vendorRating)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BidModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.proposal, proposal) ||
                other.proposal == proposal) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.platformCommission, platformCommission) ||
                other.platformCommission == platformCommission) &&
            (identical(other.gstOnCommission, gstOnCommission) ||
                other.gstOnCommission == gstOnCommission) &&
            (identical(other.gatewayFee, gatewayFee) ||
                other.gatewayFee == gatewayFee) &&
            (identical(other.finalPrice, finalPrice) ||
                other.finalPrice == finalPrice) &&
            (identical(other.vendorName, vendorName) ||
                other.vendorName == vendorName) &&
            (identical(other.vendorImage, vendorImage) ||
                other.vendorImage == vendorImage) &&
            (identical(other.vendorRating, vendorRating) ||
                other.vendorRating == vendorRating));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      vendorId,
      amount,
      proposal,
      status,
      submittedAt,
      platformCommission,
      gstOnCommission,
      gatewayFee,
      finalPrice,
      vendorName,
      vendorImage,
      vendorRating);

  /// Create a copy of BidModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BidModelImplCopyWith<_$BidModelImpl> get copyWith =>
      __$$BidModelImplCopyWithImpl<_$BidModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BidModelImplToJson(
      this,
    );
  }
}

abstract class _BidModel implements BidModel {
  const factory _BidModel(
      {required final int id,
      required final int vendorId,
      required final double amount,
      required final String proposal,
      required final String status,
      required final DateTime submittedAt,
      final double? platformCommission,
      final double? gstOnCommission,
      final double? gatewayFee,
      final double? finalPrice,
      final String? vendorName,
      final String? vendorImage,
      final double? vendorRating}) = _$BidModelImpl;

  factory _BidModel.fromJson(Map<String, dynamic> json) =
      _$BidModelImpl.fromJson;

  @override
  int get id;
  @override
  int get vendorId;
  @override
  double get amount;
  @override
  String get proposal;
  @override
  String get status;
  @override
  DateTime get submittedAt; // Admin Curation Fields
  @override
  double? get platformCommission;
  @override
  double? get gstOnCommission;
  @override
  double? get gatewayFee;
  @override
  double? get finalPrice; // UI Helper
  @override
  String? get vendorName;
  @override
  String? get vendorImage;
  @override
  double? get vendorRating;

  /// Create a copy of BidModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BidModelImplCopyWith<_$BidModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
