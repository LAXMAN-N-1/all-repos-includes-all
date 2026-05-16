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
  int get id => throw _privateConstructorUsedError;
  String get referenceId => throw _privateConstructorUsedError;
  int get customerId => throw _privateConstructorUsedError;
  String get eventName => throw _privateConstructorUsedError;
  String get eventType => throw _privateConstructorUsedError;
  String get eventDate => throw _privateConstructorUsedError;
  String? get eventTime => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get guestCount => throw _privateConstructorUsedError;
  double get budget => throw _privateConstructorUsedError;
  String? get requirements => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get transactionId => throw _privateConstructorUsedError;
  String get bookingStep => throw _privateConstructorUsedError;
  DateTime get createdAt =>
      throw _privateConstructorUsedError; // New fields for Bidding System
  String? get subCategory => throw _privateConstructorUsedError;
  List<String>? get images => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String get paymentStatus => throw _privateConstructorUsedError;
  String get escrowStatus => throw _privateConstructorUsedError;

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
      {int id,
      String referenceId,
      int customerId,
      String eventName,
      String eventType,
      String eventDate,
      String? eventTime,
      String location,
      String? city,
      String? guestCount,
      double budget,
      String? requirements,
      String status,
      String? transactionId,
      String bookingStep,
      DateTime createdAt,
      String? subCategory,
      List<String>? images,
      double? latitude,
      double? longitude,
      String paymentStatus,
      String escrowStatus});
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
    Object? referenceId = null,
    Object? customerId = null,
    Object? eventName = null,
    Object? eventType = null,
    Object? eventDate = null,
    Object? eventTime = freezed,
    Object? location = null,
    Object? city = freezed,
    Object? guestCount = freezed,
    Object? budget = null,
    Object? requirements = freezed,
    Object? status = null,
    Object? transactionId = freezed,
    Object? bookingStep = null,
    Object? createdAt = null,
    Object? subCategory = freezed,
    Object? images = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? paymentStatus = null,
    Object? escrowStatus = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      referenceId: null == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as int,
      eventName: null == eventName
          ? _value.eventName
          : eventName // ignore: cast_nullable_to_non_nullable
              as String,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      eventDate: null == eventDate
          ? _value.eventDate
          : eventDate // ignore: cast_nullable_to_non_nullable
              as String,
      eventTime: freezed == eventTime
          ? _value.eventTime
          : eventTime // ignore: cast_nullable_to_non_nullable
              as String?,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      guestCount: freezed == guestCount
          ? _value.guestCount
          : guestCount // ignore: cast_nullable_to_non_nullable
              as String?,
      budget: null == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as double,
      requirements: freezed == requirements
          ? _value.requirements
          : requirements // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingStep: null == bookingStep
          ? _value.bookingStep
          : bookingStep // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      subCategory: freezed == subCategory
          ? _value.subCategory
          : subCategory // ignore: cast_nullable_to_non_nullable
              as String?,
      images: freezed == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      escrowStatus: null == escrowStatus
          ? _value.escrowStatus
          : escrowStatus // ignore: cast_nullable_to_non_nullable
              as String,
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
      {int id,
      String referenceId,
      int customerId,
      String eventName,
      String eventType,
      String eventDate,
      String? eventTime,
      String location,
      String? city,
      String? guestCount,
      double budget,
      String? requirements,
      String status,
      String? transactionId,
      String bookingStep,
      DateTime createdAt,
      String? subCategory,
      List<String>? images,
      double? latitude,
      double? longitude,
      String paymentStatus,
      String escrowStatus});
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
    Object? referenceId = null,
    Object? customerId = null,
    Object? eventName = null,
    Object? eventType = null,
    Object? eventDate = null,
    Object? eventTime = freezed,
    Object? location = null,
    Object? city = freezed,
    Object? guestCount = freezed,
    Object? budget = null,
    Object? requirements = freezed,
    Object? status = null,
    Object? transactionId = freezed,
    Object? bookingStep = null,
    Object? createdAt = null,
    Object? subCategory = freezed,
    Object? images = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? paymentStatus = null,
    Object? escrowStatus = null,
  }) {
    return _then(_$BookingModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      referenceId: null == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as int,
      eventName: null == eventName
          ? _value.eventName
          : eventName // ignore: cast_nullable_to_non_nullable
              as String,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      eventDate: null == eventDate
          ? _value.eventDate
          : eventDate // ignore: cast_nullable_to_non_nullable
              as String,
      eventTime: freezed == eventTime
          ? _value.eventTime
          : eventTime // ignore: cast_nullable_to_non_nullable
              as String?,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      guestCount: freezed == guestCount
          ? _value.guestCount
          : guestCount // ignore: cast_nullable_to_non_nullable
              as String?,
      budget: null == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as double,
      requirements: freezed == requirements
          ? _value.requirements
          : requirements // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingStep: null == bookingStep
          ? _value.bookingStep
          : bookingStep // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      subCategory: freezed == subCategory
          ? _value.subCategory
          : subCategory // ignore: cast_nullable_to_non_nullable
              as String?,
      images: freezed == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      escrowStatus: null == escrowStatus
          ? _value.escrowStatus
          : escrowStatus // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingModelImpl implements _BookingModel {
  const _$BookingModelImpl(
      {required this.id,
      required this.referenceId,
      required this.customerId,
      required this.eventName,
      required this.eventType,
      required this.eventDate,
      this.eventTime,
      required this.location,
      this.city,
      this.guestCount,
      required this.budget,
      this.requirements,
      required this.status,
      this.transactionId,
      required this.bookingStep,
      required this.createdAt,
      this.subCategory,
      final List<String>? images,
      this.latitude,
      this.longitude,
      this.paymentStatus = 'pending',
      this.escrowStatus = 'none'})
      : _images = images;

  factory _$BookingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingModelImplFromJson(json);

  @override
  final int id;
  @override
  final String referenceId;
  @override
  final int customerId;
  @override
  final String eventName;
  @override
  final String eventType;
  @override
  final String eventDate;
  @override
  final String? eventTime;
  @override
  final String location;
  @override
  final String? city;
  @override
  final String? guestCount;
  @override
  final double budget;
  @override
  final String? requirements;
  @override
  final String status;
  @override
  final String? transactionId;
  @override
  final String bookingStep;
  @override
  final DateTime createdAt;
// New fields for Bidding System
  @override
  final String? subCategory;
  final List<String>? _images;
  @override
  List<String>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  @JsonKey()
  final String paymentStatus;
  @override
  @JsonKey()
  final String escrowStatus;

  @override
  String toString() {
    return 'BookingModel(id: $id, referenceId: $referenceId, customerId: $customerId, eventName: $eventName, eventType: $eventType, eventDate: $eventDate, eventTime: $eventTime, location: $location, city: $city, guestCount: $guestCount, budget: $budget, requirements: $requirements, status: $status, transactionId: $transactionId, bookingStep: $bookingStep, createdAt: $createdAt, subCategory: $subCategory, images: $images, latitude: $latitude, longitude: $longitude, paymentStatus: $paymentStatus, escrowStatus: $escrowStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.referenceId, referenceId) ||
                other.referenceId == referenceId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.eventName, eventName) ||
                other.eventName == eventName) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.eventDate, eventDate) ||
                other.eventDate == eventDate) &&
            (identical(other.eventTime, eventTime) ||
                other.eventTime == eventTime) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.guestCount, guestCount) ||
                other.guestCount == guestCount) &&
            (identical(other.budget, budget) || other.budget == budget) &&
            (identical(other.requirements, requirements) ||
                other.requirements == requirements) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.bookingStep, bookingStep) ||
                other.bookingStep == bookingStep) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.subCategory, subCategory) ||
                other.subCategory == subCategory) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.escrowStatus, escrowStatus) ||
                other.escrowStatus == escrowStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        referenceId,
        customerId,
        eventName,
        eventType,
        eventDate,
        eventTime,
        location,
        city,
        guestCount,
        budget,
        requirements,
        status,
        transactionId,
        bookingStep,
        createdAt,
        subCategory,
        const DeepCollectionEquality().hash(_images),
        latitude,
        longitude,
        paymentStatus,
        escrowStatus
      ]);

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
      {required final int id,
      required final String referenceId,
      required final int customerId,
      required final String eventName,
      required final String eventType,
      required final String eventDate,
      final String? eventTime,
      required final String location,
      final String? city,
      final String? guestCount,
      required final double budget,
      final String? requirements,
      required final String status,
      final String? transactionId,
      required final String bookingStep,
      required final DateTime createdAt,
      final String? subCategory,
      final List<String>? images,
      final double? latitude,
      final double? longitude,
      final String paymentStatus,
      final String escrowStatus}) = _$BookingModelImpl;

  factory _BookingModel.fromJson(Map<String, dynamic> json) =
      _$BookingModelImpl.fromJson;

  @override
  int get id;
  @override
  String get referenceId;
  @override
  int get customerId;
  @override
  String get eventName;
  @override
  String get eventType;
  @override
  String get eventDate;
  @override
  String? get eventTime;
  @override
  String get location;
  @override
  String? get city;
  @override
  String? get guestCount;
  @override
  double get budget;
  @override
  String? get requirements;
  @override
  String get status;
  @override
  String? get transactionId;
  @override
  String get bookingStep;
  @override
  DateTime get createdAt; // New fields for Bidding System
  @override
  String? get subCategory;
  @override
  List<String>? get images;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  String get paymentStatus;
  @override
  String get escrowStatus;

  /// Create a copy of BookingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingModelImplCopyWith<_$BookingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
