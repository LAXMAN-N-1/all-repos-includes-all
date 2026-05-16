// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'station_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StationDto {
  int get id;
  String get name;
  String get address;
  String get city;
  String get status;
  int get totalSlots;
  String get createdAt;
  double get latitude;
  double get longitude;
  String get stationType;
  int get availableBatteries;
  int get availableSlots;
  bool get is24x7;
  double get rating;
  int get activeSwaps;
  double get utilizationPercent;
  int get ongoingRentals;
  int get chargingBatteries;
  int get faultyBatteries;
  double get todayRevenue;
  int get totalReviews;
  int get maxCapacity;
  double get lowStockThreshold;
  String? get contactPhone;
  String? get contactEmail;
  String? get contactName;
  String? get operatingHours;
  String? get lastMaintenanceDate;
  String? get lastHeartbeat;
  String? get description;
  String? get stationCode;
  String? get automationMode;
  String? get imageUrl;
  String? get approvalStatus;
  String? get state;
  String? get pinCode;

  /// Create a copy of StationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StationDtoCopyWith<StationDto> get copyWith =>
      _$StationDtoCopyWithImpl<StationDto>(this as StationDto, _$identity);

  /// Serializes this StationDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StationDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.totalSlots, totalSlots) ||
                other.totalSlots == totalSlots) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.stationType, stationType) ||
                other.stationType == stationType) &&
            (identical(other.availableBatteries, availableBatteries) ||
                other.availableBatteries == availableBatteries) &&
            (identical(other.availableSlots, availableSlots) ||
                other.availableSlots == availableSlots) &&
            (identical(other.is24x7, is24x7) || other.is24x7 == is24x7) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.activeSwaps, activeSwaps) ||
                other.activeSwaps == activeSwaps) &&
            (identical(other.utilizationPercent, utilizationPercent) ||
                other.utilizationPercent == utilizationPercent) &&
            (identical(other.ongoingRentals, ongoingRentals) ||
                other.ongoingRentals == ongoingRentals) &&
            (identical(other.chargingBatteries, chargingBatteries) ||
                other.chargingBatteries == chargingBatteries) &&
            (identical(other.faultyBatteries, faultyBatteries) ||
                other.faultyBatteries == faultyBatteries) &&
            (identical(other.todayRevenue, todayRevenue) ||
                other.todayRevenue == todayRevenue) &&
            (identical(other.totalReviews, totalReviews) ||
                other.totalReviews == totalReviews) &&
            (identical(other.maxCapacity, maxCapacity) ||
                other.maxCapacity == maxCapacity) &&
            (identical(other.lowStockThreshold, lowStockThreshold) ||
                other.lowStockThreshold == lowStockThreshold) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail) &&
            (identical(other.contactName, contactName) ||
                other.contactName == contactName) &&
            (identical(other.operatingHours, operatingHours) ||
                other.operatingHours == operatingHours) &&
            (identical(other.lastMaintenanceDate, lastMaintenanceDate) ||
                other.lastMaintenanceDate == lastMaintenanceDate) &&
            (identical(other.lastHeartbeat, lastHeartbeat) ||
                other.lastHeartbeat == lastHeartbeat) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.stationCode, stationCode) ||
                other.stationCode == stationCode) &&
            (identical(other.automationMode, automationMode) ||
                other.automationMode == automationMode) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.approvalStatus, approvalStatus) ||
                other.approvalStatus == approvalStatus) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.pinCode, pinCode) || other.pinCode == pinCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        address,
        city,
        status,
        totalSlots,
        createdAt,
        latitude,
        longitude,
        stationType,
        availableBatteries,
        availableSlots,
        is24x7,
        rating,
        activeSwaps,
        utilizationPercent,
        ongoingRentals,
        chargingBatteries,
        faultyBatteries,
        todayRevenue,
        totalReviews,
        maxCapacity,
        lowStockThreshold,
        contactPhone,
        contactEmail,
        contactName,
        operatingHours,
        lastMaintenanceDate,
        lastHeartbeat,
        description,
        stationCode,
        automationMode,
        imageUrl,
        approvalStatus,
        state,
        pinCode
      ]);

  @override
  String toString() {
    return 'StationDto(id: $id, name: $name, address: $address, city: $city, status: $status, totalSlots: $totalSlots, createdAt: $createdAt, latitude: $latitude, longitude: $longitude, stationType: $stationType, availableBatteries: $availableBatteries, availableSlots: $availableSlots, is24x7: $is24x7, rating: $rating, activeSwaps: $activeSwaps, utilizationPercent: $utilizationPercent, ongoingRentals: $ongoingRentals, chargingBatteries: $chargingBatteries, faultyBatteries: $faultyBatteries, todayRevenue: $todayRevenue, totalReviews: $totalReviews, maxCapacity: $maxCapacity, lowStockThreshold: $lowStockThreshold, contactPhone: $contactPhone, contactEmail: $contactEmail, contactName: $contactName, operatingHours: $operatingHours, lastMaintenanceDate: $lastMaintenanceDate, lastHeartbeat: $lastHeartbeat, description: $description, stationCode: $stationCode, automationMode: $automationMode, imageUrl: $imageUrl, approvalStatus: $approvalStatus, state: $state, pinCode: $pinCode)';
  }
}

/// @nodoc
abstract mixin class $StationDtoCopyWith<$Res> {
  factory $StationDtoCopyWith(
          StationDto value, $Res Function(StationDto) _then) =
      _$StationDtoCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String name,
      String address,
      String city,
      String status,
      int totalSlots,
      String createdAt,
      double latitude,
      double longitude,
      String stationType,
      int availableBatteries,
      int availableSlots,
      bool is24x7,
      double rating,
      int activeSwaps,
      double utilizationPercent,
      int ongoingRentals,
      int chargingBatteries,
      int faultyBatteries,
      double todayRevenue,
      int totalReviews,
      int maxCapacity,
      double lowStockThreshold,
      String? contactPhone,
      String? contactEmail,
      String? contactName,
      String? operatingHours,
      String? lastMaintenanceDate,
      String? lastHeartbeat,
      String? description,
      String? stationCode,
      String? automationMode,
      String? imageUrl,
      String? approvalStatus,
      String? state,
      String? pinCode});
}

/// @nodoc
class _$StationDtoCopyWithImpl<$Res> implements $StationDtoCopyWith<$Res> {
  _$StationDtoCopyWithImpl(this._self, this._then);

  final StationDto _self;
  final $Res Function(StationDto) _then;

  /// Create a copy of StationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? city = null,
    Object? status = null,
    Object? totalSlots = null,
    Object? createdAt = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? stationType = null,
    Object? availableBatteries = null,
    Object? availableSlots = null,
    Object? is24x7 = null,
    Object? rating = null,
    Object? activeSwaps = null,
    Object? utilizationPercent = null,
    Object? ongoingRentals = null,
    Object? chargingBatteries = null,
    Object? faultyBatteries = null,
    Object? todayRevenue = null,
    Object? totalReviews = null,
    Object? maxCapacity = null,
    Object? lowStockThreshold = null,
    Object? contactPhone = freezed,
    Object? contactEmail = freezed,
    Object? contactName = freezed,
    Object? operatingHours = freezed,
    Object? lastMaintenanceDate = freezed,
    Object? lastHeartbeat = freezed,
    Object? description = freezed,
    Object? stationCode = freezed,
    Object? automationMode = freezed,
    Object? imageUrl = freezed,
    Object? approvalStatus = freezed,
    Object? state = freezed,
    Object? pinCode = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _self.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      totalSlots: null == totalSlots
          ? _self.totalSlots
          : totalSlots // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      stationType: null == stationType
          ? _self.stationType
          : stationType // ignore: cast_nullable_to_non_nullable
              as String,
      availableBatteries: null == availableBatteries
          ? _self.availableBatteries
          : availableBatteries // ignore: cast_nullable_to_non_nullable
              as int,
      availableSlots: null == availableSlots
          ? _self.availableSlots
          : availableSlots // ignore: cast_nullable_to_non_nullable
              as int,
      is24x7: null == is24x7
          ? _self.is24x7
          : is24x7 // ignore: cast_nullable_to_non_nullable
              as bool,
      rating: null == rating
          ? _self.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      activeSwaps: null == activeSwaps
          ? _self.activeSwaps
          : activeSwaps // ignore: cast_nullable_to_non_nullable
              as int,
      utilizationPercent: null == utilizationPercent
          ? _self.utilizationPercent
          : utilizationPercent // ignore: cast_nullable_to_non_nullable
              as double,
      ongoingRentals: null == ongoingRentals
          ? _self.ongoingRentals
          : ongoingRentals // ignore: cast_nullable_to_non_nullable
              as int,
      chargingBatteries: null == chargingBatteries
          ? _self.chargingBatteries
          : chargingBatteries // ignore: cast_nullable_to_non_nullable
              as int,
      faultyBatteries: null == faultyBatteries
          ? _self.faultyBatteries
          : faultyBatteries // ignore: cast_nullable_to_non_nullable
              as int,
      todayRevenue: null == todayRevenue
          ? _self.todayRevenue
          : todayRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      totalReviews: null == totalReviews
          ? _self.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
      maxCapacity: null == maxCapacity
          ? _self.maxCapacity
          : maxCapacity // ignore: cast_nullable_to_non_nullable
              as int,
      lowStockThreshold: null == lowStockThreshold
          ? _self.lowStockThreshold
          : lowStockThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      contactPhone: freezed == contactPhone
          ? _self.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _self.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      contactName: freezed == contactName
          ? _self.contactName
          : contactName // ignore: cast_nullable_to_non_nullable
              as String?,
      operatingHours: freezed == operatingHours
          ? _self.operatingHours
          : operatingHours // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMaintenanceDate: freezed == lastMaintenanceDate
          ? _self.lastMaintenanceDate
          : lastMaintenanceDate // ignore: cast_nullable_to_non_nullable
              as String?,
      lastHeartbeat: freezed == lastHeartbeat
          ? _self.lastHeartbeat
          : lastHeartbeat // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      stationCode: freezed == stationCode
          ? _self.stationCode
          : stationCode // ignore: cast_nullable_to_non_nullable
              as String?,
      automationMode: freezed == automationMode
          ? _self.automationMode
          : automationMode // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      approvalStatus: freezed == approvalStatus
          ? _self.approvalStatus
          : approvalStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      pinCode: freezed == pinCode
          ? _self.pinCode
          : pinCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [StationDto].
extension StationDtoPatterns on StationDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_StationDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StationDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_StationDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StationDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_StationDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StationDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int id,
            String name,
            String address,
            String city,
            String status,
            int totalSlots,
            String createdAt,
            double latitude,
            double longitude,
            String stationType,
            int availableBatteries,
            int availableSlots,
            bool is24x7,
            double rating,
            int activeSwaps,
            double utilizationPercent,
            int ongoingRentals,
            int chargingBatteries,
            int faultyBatteries,
            double todayRevenue,
            int totalReviews,
            int maxCapacity,
            double lowStockThreshold,
            String? contactPhone,
            String? contactEmail,
            String? contactName,
            String? operatingHours,
            String? lastMaintenanceDate,
            String? lastHeartbeat,
            String? description,
            String? stationCode,
            String? automationMode,
            String? imageUrl,
            String? approvalStatus,
            String? state,
            String? pinCode)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StationDto() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.address,
            _that.city,
            _that.status,
            _that.totalSlots,
            _that.createdAt,
            _that.latitude,
            _that.longitude,
            _that.stationType,
            _that.availableBatteries,
            _that.availableSlots,
            _that.is24x7,
            _that.rating,
            _that.activeSwaps,
            _that.utilizationPercent,
            _that.ongoingRentals,
            _that.chargingBatteries,
            _that.faultyBatteries,
            _that.todayRevenue,
            _that.totalReviews,
            _that.maxCapacity,
            _that.lowStockThreshold,
            _that.contactPhone,
            _that.contactEmail,
            _that.contactName,
            _that.operatingHours,
            _that.lastMaintenanceDate,
            _that.lastHeartbeat,
            _that.description,
            _that.stationCode,
            _that.automationMode,
            _that.imageUrl,
            _that.approvalStatus,
            _that.state,
            _that.pinCode);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int id,
            String name,
            String address,
            String city,
            String status,
            int totalSlots,
            String createdAt,
            double latitude,
            double longitude,
            String stationType,
            int availableBatteries,
            int availableSlots,
            bool is24x7,
            double rating,
            int activeSwaps,
            double utilizationPercent,
            int ongoingRentals,
            int chargingBatteries,
            int faultyBatteries,
            double todayRevenue,
            int totalReviews,
            int maxCapacity,
            double lowStockThreshold,
            String? contactPhone,
            String? contactEmail,
            String? contactName,
            String? operatingHours,
            String? lastMaintenanceDate,
            String? lastHeartbeat,
            String? description,
            String? stationCode,
            String? automationMode,
            String? imageUrl,
            String? approvalStatus,
            String? state,
            String? pinCode)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StationDto():
        return $default(
            _that.id,
            _that.name,
            _that.address,
            _that.city,
            _that.status,
            _that.totalSlots,
            _that.createdAt,
            _that.latitude,
            _that.longitude,
            _that.stationType,
            _that.availableBatteries,
            _that.availableSlots,
            _that.is24x7,
            _that.rating,
            _that.activeSwaps,
            _that.utilizationPercent,
            _that.ongoingRentals,
            _that.chargingBatteries,
            _that.faultyBatteries,
            _that.todayRevenue,
            _that.totalReviews,
            _that.maxCapacity,
            _that.lowStockThreshold,
            _that.contactPhone,
            _that.contactEmail,
            _that.contactName,
            _that.operatingHours,
            _that.lastMaintenanceDate,
            _that.lastHeartbeat,
            _that.description,
            _that.stationCode,
            _that.automationMode,
            _that.imageUrl,
            _that.approvalStatus,
            _that.state,
            _that.pinCode);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int id,
            String name,
            String address,
            String city,
            String status,
            int totalSlots,
            String createdAt,
            double latitude,
            double longitude,
            String stationType,
            int availableBatteries,
            int availableSlots,
            bool is24x7,
            double rating,
            int activeSwaps,
            double utilizationPercent,
            int ongoingRentals,
            int chargingBatteries,
            int faultyBatteries,
            double todayRevenue,
            int totalReviews,
            int maxCapacity,
            double lowStockThreshold,
            String? contactPhone,
            String? contactEmail,
            String? contactName,
            String? operatingHours,
            String? lastMaintenanceDate,
            String? lastHeartbeat,
            String? description,
            String? stationCode,
            String? automationMode,
            String? imageUrl,
            String? approvalStatus,
            String? state,
            String? pinCode)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StationDto() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.address,
            _that.city,
            _that.status,
            _that.totalSlots,
            _that.createdAt,
            _that.latitude,
            _that.longitude,
            _that.stationType,
            _that.availableBatteries,
            _that.availableSlots,
            _that.is24x7,
            _that.rating,
            _that.activeSwaps,
            _that.utilizationPercent,
            _that.ongoingRentals,
            _that.chargingBatteries,
            _that.faultyBatteries,
            _that.todayRevenue,
            _that.totalReviews,
            _that.maxCapacity,
            _that.lowStockThreshold,
            _that.contactPhone,
            _that.contactEmail,
            _that.contactName,
            _that.operatingHours,
            _that.lastMaintenanceDate,
            _that.lastHeartbeat,
            _that.description,
            _that.stationCode,
            _that.automationMode,
            _that.imageUrl,
            _that.approvalStatus,
            _that.state,
            _that.pinCode);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _StationDto implements StationDto {
  const _StationDto(
      {required this.id,
      required this.name,
      required this.address,
      this.city = '',
      required this.status,
      required this.totalSlots,
      required this.createdAt,
      this.latitude = 0.0,
      this.longitude = 0.0,
      this.stationType = 'automated',
      this.availableBatteries = 0,
      this.availableSlots = 0,
      this.is24x7 = false,
      this.rating = 0.0,
      this.activeSwaps = 0,
      this.utilizationPercent = 0.0,
      this.ongoingRentals = 0,
      this.chargingBatteries = 0,
      this.faultyBatteries = 0,
      this.todayRevenue = 0.0,
      this.totalReviews = 0,
      this.maxCapacity = 0,
      this.lowStockThreshold = 20.0,
      this.contactPhone,
      this.contactEmail,
      this.contactName,
      this.operatingHours,
      this.lastMaintenanceDate,
      this.lastHeartbeat,
      this.description,
      this.stationCode,
      this.automationMode,
      this.imageUrl,
      this.approvalStatus,
      this.state,
      this.pinCode});
  factory _StationDto.fromJson(Map<String, dynamic> json) =>
      _$StationDtoFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String address;
  @override
  @JsonKey()
  final String city;
  @override
  final String status;
  @override
  final int totalSlots;
  @override
  final String createdAt;
  @override
  @JsonKey()
  final double latitude;
  @override
  @JsonKey()
  final double longitude;
  @override
  @JsonKey()
  final String stationType;
  @override
  @JsonKey()
  final int availableBatteries;
  @override
  @JsonKey()
  final int availableSlots;
  @override
  @JsonKey()
  final bool is24x7;
  @override
  @JsonKey()
  final double rating;
  @override
  @JsonKey()
  final int activeSwaps;
  @override
  @JsonKey()
  final double utilizationPercent;
  @override
  @JsonKey()
  final int ongoingRentals;
  @override
  @JsonKey()
  final int chargingBatteries;
  @override
  @JsonKey()
  final int faultyBatteries;
  @override
  @JsonKey()
  final double todayRevenue;
  @override
  @JsonKey()
  final int totalReviews;
  @override
  @JsonKey()
  final int maxCapacity;
  @override
  @JsonKey()
  final double lowStockThreshold;
  @override
  final String? contactPhone;
  @override
  final String? contactEmail;
  @override
  final String? contactName;
  @override
  final String? operatingHours;
  @override
  final String? lastMaintenanceDate;
  @override
  final String? lastHeartbeat;
  @override
  final String? description;
  @override
  final String? stationCode;
  @override
  final String? automationMode;
  @override
  final String? imageUrl;
  @override
  final String? approvalStatus;
  @override
  final String? state;
  @override
  final String? pinCode;

  /// Create a copy of StationDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StationDtoCopyWith<_StationDto> get copyWith =>
      __$StationDtoCopyWithImpl<_StationDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$StationDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StationDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.totalSlots, totalSlots) ||
                other.totalSlots == totalSlots) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.stationType, stationType) ||
                other.stationType == stationType) &&
            (identical(other.availableBatteries, availableBatteries) ||
                other.availableBatteries == availableBatteries) &&
            (identical(other.availableSlots, availableSlots) ||
                other.availableSlots == availableSlots) &&
            (identical(other.is24x7, is24x7) || other.is24x7 == is24x7) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.activeSwaps, activeSwaps) ||
                other.activeSwaps == activeSwaps) &&
            (identical(other.utilizationPercent, utilizationPercent) ||
                other.utilizationPercent == utilizationPercent) &&
            (identical(other.ongoingRentals, ongoingRentals) ||
                other.ongoingRentals == ongoingRentals) &&
            (identical(other.chargingBatteries, chargingBatteries) ||
                other.chargingBatteries == chargingBatteries) &&
            (identical(other.faultyBatteries, faultyBatteries) ||
                other.faultyBatteries == faultyBatteries) &&
            (identical(other.todayRevenue, todayRevenue) ||
                other.todayRevenue == todayRevenue) &&
            (identical(other.totalReviews, totalReviews) ||
                other.totalReviews == totalReviews) &&
            (identical(other.maxCapacity, maxCapacity) ||
                other.maxCapacity == maxCapacity) &&
            (identical(other.lowStockThreshold, lowStockThreshold) ||
                other.lowStockThreshold == lowStockThreshold) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail) &&
            (identical(other.contactName, contactName) ||
                other.contactName == contactName) &&
            (identical(other.operatingHours, operatingHours) ||
                other.operatingHours == operatingHours) &&
            (identical(other.lastMaintenanceDate, lastMaintenanceDate) ||
                other.lastMaintenanceDate == lastMaintenanceDate) &&
            (identical(other.lastHeartbeat, lastHeartbeat) ||
                other.lastHeartbeat == lastHeartbeat) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.stationCode, stationCode) ||
                other.stationCode == stationCode) &&
            (identical(other.automationMode, automationMode) ||
                other.automationMode == automationMode) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.approvalStatus, approvalStatus) ||
                other.approvalStatus == approvalStatus) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.pinCode, pinCode) || other.pinCode == pinCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        address,
        city,
        status,
        totalSlots,
        createdAt,
        latitude,
        longitude,
        stationType,
        availableBatteries,
        availableSlots,
        is24x7,
        rating,
        activeSwaps,
        utilizationPercent,
        ongoingRentals,
        chargingBatteries,
        faultyBatteries,
        todayRevenue,
        totalReviews,
        maxCapacity,
        lowStockThreshold,
        contactPhone,
        contactEmail,
        contactName,
        operatingHours,
        lastMaintenanceDate,
        lastHeartbeat,
        description,
        stationCode,
        automationMode,
        imageUrl,
        approvalStatus,
        state,
        pinCode
      ]);

  @override
  String toString() {
    return 'StationDto(id: $id, name: $name, address: $address, city: $city, status: $status, totalSlots: $totalSlots, createdAt: $createdAt, latitude: $latitude, longitude: $longitude, stationType: $stationType, availableBatteries: $availableBatteries, availableSlots: $availableSlots, is24x7: $is24x7, rating: $rating, activeSwaps: $activeSwaps, utilizationPercent: $utilizationPercent, ongoingRentals: $ongoingRentals, chargingBatteries: $chargingBatteries, faultyBatteries: $faultyBatteries, todayRevenue: $todayRevenue, totalReviews: $totalReviews, maxCapacity: $maxCapacity, lowStockThreshold: $lowStockThreshold, contactPhone: $contactPhone, contactEmail: $contactEmail, contactName: $contactName, operatingHours: $operatingHours, lastMaintenanceDate: $lastMaintenanceDate, lastHeartbeat: $lastHeartbeat, description: $description, stationCode: $stationCode, automationMode: $automationMode, imageUrl: $imageUrl, approvalStatus: $approvalStatus, state: $state, pinCode: $pinCode)';
  }
}

/// @nodoc
abstract mixin class _$StationDtoCopyWith<$Res>
    implements $StationDtoCopyWith<$Res> {
  factory _$StationDtoCopyWith(
          _StationDto value, $Res Function(_StationDto) _then) =
      __$StationDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String address,
      String city,
      String status,
      int totalSlots,
      String createdAt,
      double latitude,
      double longitude,
      String stationType,
      int availableBatteries,
      int availableSlots,
      bool is24x7,
      double rating,
      int activeSwaps,
      double utilizationPercent,
      int ongoingRentals,
      int chargingBatteries,
      int faultyBatteries,
      double todayRevenue,
      int totalReviews,
      int maxCapacity,
      double lowStockThreshold,
      String? contactPhone,
      String? contactEmail,
      String? contactName,
      String? operatingHours,
      String? lastMaintenanceDate,
      String? lastHeartbeat,
      String? description,
      String? stationCode,
      String? automationMode,
      String? imageUrl,
      String? approvalStatus,
      String? state,
      String? pinCode});
}

/// @nodoc
class __$StationDtoCopyWithImpl<$Res> implements _$StationDtoCopyWith<$Res> {
  __$StationDtoCopyWithImpl(this._self, this._then);

  final _StationDto _self;
  final $Res Function(_StationDto) _then;

  /// Create a copy of StationDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? city = null,
    Object? status = null,
    Object? totalSlots = null,
    Object? createdAt = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? stationType = null,
    Object? availableBatteries = null,
    Object? availableSlots = null,
    Object? is24x7 = null,
    Object? rating = null,
    Object? activeSwaps = null,
    Object? utilizationPercent = null,
    Object? ongoingRentals = null,
    Object? chargingBatteries = null,
    Object? faultyBatteries = null,
    Object? todayRevenue = null,
    Object? totalReviews = null,
    Object? maxCapacity = null,
    Object? lowStockThreshold = null,
    Object? contactPhone = freezed,
    Object? contactEmail = freezed,
    Object? contactName = freezed,
    Object? operatingHours = freezed,
    Object? lastMaintenanceDate = freezed,
    Object? lastHeartbeat = freezed,
    Object? description = freezed,
    Object? stationCode = freezed,
    Object? automationMode = freezed,
    Object? imageUrl = freezed,
    Object? approvalStatus = freezed,
    Object? state = freezed,
    Object? pinCode = freezed,
  }) {
    return _then(_StationDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _self.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      totalSlots: null == totalSlots
          ? _self.totalSlots
          : totalSlots // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      stationType: null == stationType
          ? _self.stationType
          : stationType // ignore: cast_nullable_to_non_nullable
              as String,
      availableBatteries: null == availableBatteries
          ? _self.availableBatteries
          : availableBatteries // ignore: cast_nullable_to_non_nullable
              as int,
      availableSlots: null == availableSlots
          ? _self.availableSlots
          : availableSlots // ignore: cast_nullable_to_non_nullable
              as int,
      is24x7: null == is24x7
          ? _self.is24x7
          : is24x7 // ignore: cast_nullable_to_non_nullable
              as bool,
      rating: null == rating
          ? _self.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      activeSwaps: null == activeSwaps
          ? _self.activeSwaps
          : activeSwaps // ignore: cast_nullable_to_non_nullable
              as int,
      utilizationPercent: null == utilizationPercent
          ? _self.utilizationPercent
          : utilizationPercent // ignore: cast_nullable_to_non_nullable
              as double,
      ongoingRentals: null == ongoingRentals
          ? _self.ongoingRentals
          : ongoingRentals // ignore: cast_nullable_to_non_nullable
              as int,
      chargingBatteries: null == chargingBatteries
          ? _self.chargingBatteries
          : chargingBatteries // ignore: cast_nullable_to_non_nullable
              as int,
      faultyBatteries: null == faultyBatteries
          ? _self.faultyBatteries
          : faultyBatteries // ignore: cast_nullable_to_non_nullable
              as int,
      todayRevenue: null == todayRevenue
          ? _self.todayRevenue
          : todayRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      totalReviews: null == totalReviews
          ? _self.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
      maxCapacity: null == maxCapacity
          ? _self.maxCapacity
          : maxCapacity // ignore: cast_nullable_to_non_nullable
              as int,
      lowStockThreshold: null == lowStockThreshold
          ? _self.lowStockThreshold
          : lowStockThreshold // ignore: cast_nullable_to_non_nullable
              as double,
      contactPhone: freezed == contactPhone
          ? _self.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _self.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      contactName: freezed == contactName
          ? _self.contactName
          : contactName // ignore: cast_nullable_to_non_nullable
              as String?,
      operatingHours: freezed == operatingHours
          ? _self.operatingHours
          : operatingHours // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMaintenanceDate: freezed == lastMaintenanceDate
          ? _self.lastMaintenanceDate
          : lastMaintenanceDate // ignore: cast_nullable_to_non_nullable
              as String?,
      lastHeartbeat: freezed == lastHeartbeat
          ? _self.lastHeartbeat
          : lastHeartbeat // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      stationCode: freezed == stationCode
          ? _self.stationCode
          : stationCode // ignore: cast_nullable_to_non_nullable
              as String?,
      automationMode: freezed == automationMode
          ? _self.automationMode
          : automationMode // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      approvalStatus: freezed == approvalStatus
          ? _self.approvalStatus
          : approvalStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      pinCode: freezed == pinCode
          ? _self.pinCode
          : pinCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$StationState {
  bool get isLoading;
  String? get error;
  List<StationDto> get stations;

  /// Create a copy of StationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StationStateCopyWith<StationState> get copyWith =>
      _$StationStateCopyWithImpl<StationState>(
          this as StationState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StationState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other.stations, stations));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, error,
      const DeepCollectionEquality().hash(stations));

  @override
  String toString() {
    return 'StationState(isLoading: $isLoading, error: $error, stations: $stations)';
  }
}

/// @nodoc
abstract mixin class $StationStateCopyWith<$Res> {
  factory $StationStateCopyWith(
          StationState value, $Res Function(StationState) _then) =
      _$StationStateCopyWithImpl;
  @useResult
  $Res call({bool isLoading, String? error, List<StationDto> stations});
}

/// @nodoc
class _$StationStateCopyWithImpl<$Res> implements $StationStateCopyWith<$Res> {
  _$StationStateCopyWithImpl(this._self, this._then);

  final StationState _self;
  final $Res Function(StationState) _then;

  /// Create a copy of StationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? stations = null,
  }) {
    return _then(_self.copyWith(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      stations: null == stations
          ? _self.stations
          : stations // ignore: cast_nullable_to_non_nullable
              as List<StationDto>,
    ));
  }
}

/// Adds pattern-matching-related methods to [StationState].
extension StationStatePatterns on StationState {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_StationState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StationState() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_StationState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StationState():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_StationState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StationState() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(bool isLoading, String? error, List<StationDto> stations)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StationState() when $default != null:
        return $default(_that.isLoading, _that.error, _that.stations);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(bool isLoading, String? error, List<StationDto> stations)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StationState():
        return $default(_that.isLoading, _that.error, _that.stations);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(bool isLoading, String? error, List<StationDto> stations)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StationState() when $default != null:
        return $default(_that.isLoading, _that.error, _that.stations);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _StationState implements StationState {
  const _StationState(
      {this.isLoading = true,
      this.error,
      final List<StationDto> stations = const []})
      : _stations = stations;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  final List<StationDto> _stations;
  @override
  @JsonKey()
  List<StationDto> get stations {
    if (_stations is EqualUnmodifiableListView) return _stations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stations);
  }

  /// Create a copy of StationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StationStateCopyWith<_StationState> get copyWith =>
      __$StationStateCopyWithImpl<_StationState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StationState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other._stations, _stations));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, error,
      const DeepCollectionEquality().hash(_stations));

  @override
  String toString() {
    return 'StationState(isLoading: $isLoading, error: $error, stations: $stations)';
  }
}

/// @nodoc
abstract mixin class _$StationStateCopyWith<$Res>
    implements $StationStateCopyWith<$Res> {
  factory _$StationStateCopyWith(
          _StationState value, $Res Function(_StationState) _then) =
      __$StationStateCopyWithImpl;
  @override
  @useResult
  $Res call({bool isLoading, String? error, List<StationDto> stations});
}

/// @nodoc
class __$StationStateCopyWithImpl<$Res>
    implements _$StationStateCopyWith<$Res> {
  __$StationStateCopyWithImpl(this._self, this._then);

  final _StationState _self;
  final $Res Function(_StationState) _then;

  /// Create a copy of StationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? stations = null,
  }) {
    return _then(_StationState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      stations: null == stations
          ? _self._stations
          : stations // ignore: cast_nullable_to_non_nullable
              as List<StationDto>,
    ));
  }
}

/// @nodoc
mixin _$DealerStatsDto {
  int get availableBatteries;
  int get totalBatteries;
  int get ongoingRentals;
  int get currentSwaps;
  double get avgRating;
  int get stationCount;

  /// Create a copy of DealerStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DealerStatsDtoCopyWith<DealerStatsDto> get copyWith =>
      _$DealerStatsDtoCopyWithImpl<DealerStatsDto>(
          this as DealerStatsDto, _$identity);

  /// Serializes this DealerStatsDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DealerStatsDto &&
            (identical(other.availableBatteries, availableBatteries) ||
                other.availableBatteries == availableBatteries) &&
            (identical(other.totalBatteries, totalBatteries) ||
                other.totalBatteries == totalBatteries) &&
            (identical(other.ongoingRentals, ongoingRentals) ||
                other.ongoingRentals == ongoingRentals) &&
            (identical(other.currentSwaps, currentSwaps) ||
                other.currentSwaps == currentSwaps) &&
            (identical(other.avgRating, avgRating) ||
                other.avgRating == avgRating) &&
            (identical(other.stationCount, stationCount) ||
                other.stationCount == stationCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, availableBatteries,
      totalBatteries, ongoingRentals, currentSwaps, avgRating, stationCount);

  @override
  String toString() {
    return 'DealerStatsDto(availableBatteries: $availableBatteries, totalBatteries: $totalBatteries, ongoingRentals: $ongoingRentals, currentSwaps: $currentSwaps, avgRating: $avgRating, stationCount: $stationCount)';
  }
}

/// @nodoc
abstract mixin class $DealerStatsDtoCopyWith<$Res> {
  factory $DealerStatsDtoCopyWith(
          DealerStatsDto value, $Res Function(DealerStatsDto) _then) =
      _$DealerStatsDtoCopyWithImpl;
  @useResult
  $Res call(
      {int availableBatteries,
      int totalBatteries,
      int ongoingRentals,
      int currentSwaps,
      double avgRating,
      int stationCount});
}

/// @nodoc
class _$DealerStatsDtoCopyWithImpl<$Res>
    implements $DealerStatsDtoCopyWith<$Res> {
  _$DealerStatsDtoCopyWithImpl(this._self, this._then);

  final DealerStatsDto _self;
  final $Res Function(DealerStatsDto) _then;

  /// Create a copy of DealerStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? availableBatteries = null,
    Object? totalBatteries = null,
    Object? ongoingRentals = null,
    Object? currentSwaps = null,
    Object? avgRating = null,
    Object? stationCount = null,
  }) {
    return _then(_self.copyWith(
      availableBatteries: null == availableBatteries
          ? _self.availableBatteries
          : availableBatteries // ignore: cast_nullable_to_non_nullable
              as int,
      totalBatteries: null == totalBatteries
          ? _self.totalBatteries
          : totalBatteries // ignore: cast_nullable_to_non_nullable
              as int,
      ongoingRentals: null == ongoingRentals
          ? _self.ongoingRentals
          : ongoingRentals // ignore: cast_nullable_to_non_nullable
              as int,
      currentSwaps: null == currentSwaps
          ? _self.currentSwaps
          : currentSwaps // ignore: cast_nullable_to_non_nullable
              as int,
      avgRating: null == avgRating
          ? _self.avgRating
          : avgRating // ignore: cast_nullable_to_non_nullable
              as double,
      stationCount: null == stationCount
          ? _self.stationCount
          : stationCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [DealerStatsDto].
extension DealerStatsDtoPatterns on DealerStatsDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DealerStatsDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DealerStatsDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DealerStatsDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DealerStatsDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DealerStatsDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DealerStatsDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int availableBatteries,
            int totalBatteries,
            int ongoingRentals,
            int currentSwaps,
            double avgRating,
            int stationCount)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DealerStatsDto() when $default != null:
        return $default(
            _that.availableBatteries,
            _that.totalBatteries,
            _that.ongoingRentals,
            _that.currentSwaps,
            _that.avgRating,
            _that.stationCount);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int availableBatteries,
            int totalBatteries,
            int ongoingRentals,
            int currentSwaps,
            double avgRating,
            int stationCount)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DealerStatsDto():
        return $default(
            _that.availableBatteries,
            _that.totalBatteries,
            _that.ongoingRentals,
            _that.currentSwaps,
            _that.avgRating,
            _that.stationCount);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int availableBatteries,
            int totalBatteries,
            int ongoingRentals,
            int currentSwaps,
            double avgRating,
            int stationCount)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DealerStatsDto() when $default != null:
        return $default(
            _that.availableBatteries,
            _that.totalBatteries,
            _that.ongoingRentals,
            _that.currentSwaps,
            _that.avgRating,
            _that.stationCount);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DealerStatsDto implements DealerStatsDto {
  const _DealerStatsDto(
      {this.availableBatteries = 0,
      this.totalBatteries = 0,
      this.ongoingRentals = 0,
      this.currentSwaps = 0,
      this.avgRating = 0.0,
      this.stationCount = 0});
  factory _DealerStatsDto.fromJson(Map<String, dynamic> json) =>
      _$DealerStatsDtoFromJson(json);

  @override
  @JsonKey()
  final int availableBatteries;
  @override
  @JsonKey()
  final int totalBatteries;
  @override
  @JsonKey()
  final int ongoingRentals;
  @override
  @JsonKey()
  final int currentSwaps;
  @override
  @JsonKey()
  final double avgRating;
  @override
  @JsonKey()
  final int stationCount;

  /// Create a copy of DealerStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DealerStatsDtoCopyWith<_DealerStatsDto> get copyWith =>
      __$DealerStatsDtoCopyWithImpl<_DealerStatsDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DealerStatsDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DealerStatsDto &&
            (identical(other.availableBatteries, availableBatteries) ||
                other.availableBatteries == availableBatteries) &&
            (identical(other.totalBatteries, totalBatteries) ||
                other.totalBatteries == totalBatteries) &&
            (identical(other.ongoingRentals, ongoingRentals) ||
                other.ongoingRentals == ongoingRentals) &&
            (identical(other.currentSwaps, currentSwaps) ||
                other.currentSwaps == currentSwaps) &&
            (identical(other.avgRating, avgRating) ||
                other.avgRating == avgRating) &&
            (identical(other.stationCount, stationCount) ||
                other.stationCount == stationCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, availableBatteries,
      totalBatteries, ongoingRentals, currentSwaps, avgRating, stationCount);

  @override
  String toString() {
    return 'DealerStatsDto(availableBatteries: $availableBatteries, totalBatteries: $totalBatteries, ongoingRentals: $ongoingRentals, currentSwaps: $currentSwaps, avgRating: $avgRating, stationCount: $stationCount)';
  }
}

/// @nodoc
abstract mixin class _$DealerStatsDtoCopyWith<$Res>
    implements $DealerStatsDtoCopyWith<$Res> {
  factory _$DealerStatsDtoCopyWith(
          _DealerStatsDto value, $Res Function(_DealerStatsDto) _then) =
      __$DealerStatsDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int availableBatteries,
      int totalBatteries,
      int ongoingRentals,
      int currentSwaps,
      double avgRating,
      int stationCount});
}

/// @nodoc
class __$DealerStatsDtoCopyWithImpl<$Res>
    implements _$DealerStatsDtoCopyWith<$Res> {
  __$DealerStatsDtoCopyWithImpl(this._self, this._then);

  final _DealerStatsDto _self;
  final $Res Function(_DealerStatsDto) _then;

  /// Create a copy of DealerStatsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? availableBatteries = null,
    Object? totalBatteries = null,
    Object? ongoingRentals = null,
    Object? currentSwaps = null,
    Object? avgRating = null,
    Object? stationCount = null,
  }) {
    return _then(_DealerStatsDto(
      availableBatteries: null == availableBatteries
          ? _self.availableBatteries
          : availableBatteries // ignore: cast_nullable_to_non_nullable
              as int,
      totalBatteries: null == totalBatteries
          ? _self.totalBatteries
          : totalBatteries // ignore: cast_nullable_to_non_nullable
              as int,
      ongoingRentals: null == ongoingRentals
          ? _self.ongoingRentals
          : ongoingRentals // ignore: cast_nullable_to_non_nullable
              as int,
      currentSwaps: null == currentSwaps
          ? _self.currentSwaps
          : currentSwaps // ignore: cast_nullable_to_non_nullable
              as int,
      avgRating: null == avgRating
          ? _self.avgRating
          : avgRating // ignore: cast_nullable_to_non_nullable
              as double,
      stationCount: null == stationCount
          ? _self.stationCount
          : stationCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$BatteryDto {
  int get id;
  String get serialNumber;
  String get stationName;
  int get stationId;
  String get status;
  double get chargePercentage;
  double get healthPercentage;
  int get cycleCount;
  String get batteryType;
  String? get currentCustomer;
  String? get rentalStartTime;
  String? get lastRental;
  int get daysIdle;
  String? get faultDescription;
  String? get lastChargedAt;
  String? get createdAt;

  /// Create a copy of BatteryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BatteryDtoCopyWith<BatteryDto> get copyWith =>
      _$BatteryDtoCopyWithImpl<BatteryDto>(this as BatteryDto, _$identity);

  /// Serializes this BatteryDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BatteryDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.serialNumber, serialNumber) ||
                other.serialNumber == serialNumber) &&
            (identical(other.stationName, stationName) ||
                other.stationName == stationName) &&
            (identical(other.stationId, stationId) ||
                other.stationId == stationId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.chargePercentage, chargePercentage) ||
                other.chargePercentage == chargePercentage) &&
            (identical(other.healthPercentage, healthPercentage) ||
                other.healthPercentage == healthPercentage) &&
            (identical(other.cycleCount, cycleCount) ||
                other.cycleCount == cycleCount) &&
            (identical(other.batteryType, batteryType) ||
                other.batteryType == batteryType) &&
            (identical(other.currentCustomer, currentCustomer) ||
                other.currentCustomer == currentCustomer) &&
            (identical(other.rentalStartTime, rentalStartTime) ||
                other.rentalStartTime == rentalStartTime) &&
            (identical(other.lastRental, lastRental) ||
                other.lastRental == lastRental) &&
            (identical(other.daysIdle, daysIdle) ||
                other.daysIdle == daysIdle) &&
            (identical(other.faultDescription, faultDescription) ||
                other.faultDescription == faultDescription) &&
            (identical(other.lastChargedAt, lastChargedAt) ||
                other.lastChargedAt == lastChargedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      serialNumber,
      stationName,
      stationId,
      status,
      chargePercentage,
      healthPercentage,
      cycleCount,
      batteryType,
      currentCustomer,
      rentalStartTime,
      lastRental,
      daysIdle,
      faultDescription,
      lastChargedAt,
      createdAt);

  @override
  String toString() {
    return 'BatteryDto(id: $id, serialNumber: $serialNumber, stationName: $stationName, stationId: $stationId, status: $status, chargePercentage: $chargePercentage, healthPercentage: $healthPercentage, cycleCount: $cycleCount, batteryType: $batteryType, currentCustomer: $currentCustomer, rentalStartTime: $rentalStartTime, lastRental: $lastRental, daysIdle: $daysIdle, faultDescription: $faultDescription, lastChargedAt: $lastChargedAt, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $BatteryDtoCopyWith<$Res> {
  factory $BatteryDtoCopyWith(
          BatteryDto value, $Res Function(BatteryDto) _then) =
      _$BatteryDtoCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String serialNumber,
      String stationName,
      int stationId,
      String status,
      double chargePercentage,
      double healthPercentage,
      int cycleCount,
      String batteryType,
      String? currentCustomer,
      String? rentalStartTime,
      String? lastRental,
      int daysIdle,
      String? faultDescription,
      String? lastChargedAt,
      String? createdAt});
}

/// @nodoc
class _$BatteryDtoCopyWithImpl<$Res> implements $BatteryDtoCopyWith<$Res> {
  _$BatteryDtoCopyWithImpl(this._self, this._then);

  final BatteryDto _self;
  final $Res Function(BatteryDto) _then;

  /// Create a copy of BatteryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? serialNumber = null,
    Object? stationName = null,
    Object? stationId = null,
    Object? status = null,
    Object? chargePercentage = null,
    Object? healthPercentage = null,
    Object? cycleCount = null,
    Object? batteryType = null,
    Object? currentCustomer = freezed,
    Object? rentalStartTime = freezed,
    Object? lastRental = freezed,
    Object? daysIdle = null,
    Object? faultDescription = freezed,
    Object? lastChargedAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      serialNumber: null == serialNumber
          ? _self.serialNumber
          : serialNumber // ignore: cast_nullable_to_non_nullable
              as String,
      stationName: null == stationName
          ? _self.stationName
          : stationName // ignore: cast_nullable_to_non_nullable
              as String,
      stationId: null == stationId
          ? _self.stationId
          : stationId // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      chargePercentage: null == chargePercentage
          ? _self.chargePercentage
          : chargePercentage // ignore: cast_nullable_to_non_nullable
              as double,
      healthPercentage: null == healthPercentage
          ? _self.healthPercentage
          : healthPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      cycleCount: null == cycleCount
          ? _self.cycleCount
          : cycleCount // ignore: cast_nullable_to_non_nullable
              as int,
      batteryType: null == batteryType
          ? _self.batteryType
          : batteryType // ignore: cast_nullable_to_non_nullable
              as String,
      currentCustomer: freezed == currentCustomer
          ? _self.currentCustomer
          : currentCustomer // ignore: cast_nullable_to_non_nullable
              as String?,
      rentalStartTime: freezed == rentalStartTime
          ? _self.rentalStartTime
          : rentalStartTime // ignore: cast_nullable_to_non_nullable
              as String?,
      lastRental: freezed == lastRental
          ? _self.lastRental
          : lastRental // ignore: cast_nullable_to_non_nullable
              as String?,
      daysIdle: null == daysIdle
          ? _self.daysIdle
          : daysIdle // ignore: cast_nullable_to_non_nullable
              as int,
      faultDescription: freezed == faultDescription
          ? _self.faultDescription
          : faultDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      lastChargedAt: freezed == lastChargedAt
          ? _self.lastChargedAt
          : lastChargedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [BatteryDto].
extension BatteryDtoPatterns on BatteryDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BatteryDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BatteryDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BatteryDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BatteryDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BatteryDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BatteryDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int id,
            String serialNumber,
            String stationName,
            int stationId,
            String status,
            double chargePercentage,
            double healthPercentage,
            int cycleCount,
            String batteryType,
            String? currentCustomer,
            String? rentalStartTime,
            String? lastRental,
            int daysIdle,
            String? faultDescription,
            String? lastChargedAt,
            String? createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BatteryDto() when $default != null:
        return $default(
            _that.id,
            _that.serialNumber,
            _that.stationName,
            _that.stationId,
            _that.status,
            _that.chargePercentage,
            _that.healthPercentage,
            _that.cycleCount,
            _that.batteryType,
            _that.currentCustomer,
            _that.rentalStartTime,
            _that.lastRental,
            _that.daysIdle,
            _that.faultDescription,
            _that.lastChargedAt,
            _that.createdAt);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int id,
            String serialNumber,
            String stationName,
            int stationId,
            String status,
            double chargePercentage,
            double healthPercentage,
            int cycleCount,
            String batteryType,
            String? currentCustomer,
            String? rentalStartTime,
            String? lastRental,
            int daysIdle,
            String? faultDescription,
            String? lastChargedAt,
            String? createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BatteryDto():
        return $default(
            _that.id,
            _that.serialNumber,
            _that.stationName,
            _that.stationId,
            _that.status,
            _that.chargePercentage,
            _that.healthPercentage,
            _that.cycleCount,
            _that.batteryType,
            _that.currentCustomer,
            _that.rentalStartTime,
            _that.lastRental,
            _that.daysIdle,
            _that.faultDescription,
            _that.lastChargedAt,
            _that.createdAt);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int id,
            String serialNumber,
            String stationName,
            int stationId,
            String status,
            double chargePercentage,
            double healthPercentage,
            int cycleCount,
            String batteryType,
            String? currentCustomer,
            String? rentalStartTime,
            String? lastRental,
            int daysIdle,
            String? faultDescription,
            String? lastChargedAt,
            String? createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BatteryDto() when $default != null:
        return $default(
            _that.id,
            _that.serialNumber,
            _that.stationName,
            _that.stationId,
            _that.status,
            _that.chargePercentage,
            _that.healthPercentage,
            _that.cycleCount,
            _that.batteryType,
            _that.currentCustomer,
            _that.rentalStartTime,
            _that.lastRental,
            _that.daysIdle,
            _that.faultDescription,
            _that.lastChargedAt,
            _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _BatteryDto implements BatteryDto {
  const _BatteryDto(
      {required this.id,
      required this.serialNumber,
      this.stationName = '',
      this.stationId = 0,
      this.status = 'available',
      this.chargePercentage = 100.0,
      this.healthPercentage = 100.0,
      this.cycleCount = 0,
      this.batteryType = '',
      this.currentCustomer,
      this.rentalStartTime,
      this.lastRental,
      this.daysIdle = 0,
      this.faultDescription,
      this.lastChargedAt,
      this.createdAt});
  factory _BatteryDto.fromJson(Map<String, dynamic> json) =>
      _$BatteryDtoFromJson(json);

  @override
  final int id;
  @override
  final String serialNumber;
  @override
  @JsonKey()
  final String stationName;
  @override
  @JsonKey()
  final int stationId;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final double chargePercentage;
  @override
  @JsonKey()
  final double healthPercentage;
  @override
  @JsonKey()
  final int cycleCount;
  @override
  @JsonKey()
  final String batteryType;
  @override
  final String? currentCustomer;
  @override
  final String? rentalStartTime;
  @override
  final String? lastRental;
  @override
  @JsonKey()
  final int daysIdle;
  @override
  final String? faultDescription;
  @override
  final String? lastChargedAt;
  @override
  final String? createdAt;

  /// Create a copy of BatteryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BatteryDtoCopyWith<_BatteryDto> get copyWith =>
      __$BatteryDtoCopyWithImpl<_BatteryDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$BatteryDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BatteryDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.serialNumber, serialNumber) ||
                other.serialNumber == serialNumber) &&
            (identical(other.stationName, stationName) ||
                other.stationName == stationName) &&
            (identical(other.stationId, stationId) ||
                other.stationId == stationId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.chargePercentage, chargePercentage) ||
                other.chargePercentage == chargePercentage) &&
            (identical(other.healthPercentage, healthPercentage) ||
                other.healthPercentage == healthPercentage) &&
            (identical(other.cycleCount, cycleCount) ||
                other.cycleCount == cycleCount) &&
            (identical(other.batteryType, batteryType) ||
                other.batteryType == batteryType) &&
            (identical(other.currentCustomer, currentCustomer) ||
                other.currentCustomer == currentCustomer) &&
            (identical(other.rentalStartTime, rentalStartTime) ||
                other.rentalStartTime == rentalStartTime) &&
            (identical(other.lastRental, lastRental) ||
                other.lastRental == lastRental) &&
            (identical(other.daysIdle, daysIdle) ||
                other.daysIdle == daysIdle) &&
            (identical(other.faultDescription, faultDescription) ||
                other.faultDescription == faultDescription) &&
            (identical(other.lastChargedAt, lastChargedAt) ||
                other.lastChargedAt == lastChargedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      serialNumber,
      stationName,
      stationId,
      status,
      chargePercentage,
      healthPercentage,
      cycleCount,
      batteryType,
      currentCustomer,
      rentalStartTime,
      lastRental,
      daysIdle,
      faultDescription,
      lastChargedAt,
      createdAt);

  @override
  String toString() {
    return 'BatteryDto(id: $id, serialNumber: $serialNumber, stationName: $stationName, stationId: $stationId, status: $status, chargePercentage: $chargePercentage, healthPercentage: $healthPercentage, cycleCount: $cycleCount, batteryType: $batteryType, currentCustomer: $currentCustomer, rentalStartTime: $rentalStartTime, lastRental: $lastRental, daysIdle: $daysIdle, faultDescription: $faultDescription, lastChargedAt: $lastChargedAt, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$BatteryDtoCopyWith<$Res>
    implements $BatteryDtoCopyWith<$Res> {
  factory _$BatteryDtoCopyWith(
          _BatteryDto value, $Res Function(_BatteryDto) _then) =
      __$BatteryDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String serialNumber,
      String stationName,
      int stationId,
      String status,
      double chargePercentage,
      double healthPercentage,
      int cycleCount,
      String batteryType,
      String? currentCustomer,
      String? rentalStartTime,
      String? lastRental,
      int daysIdle,
      String? faultDescription,
      String? lastChargedAt,
      String? createdAt});
}

/// @nodoc
class __$BatteryDtoCopyWithImpl<$Res> implements _$BatteryDtoCopyWith<$Res> {
  __$BatteryDtoCopyWithImpl(this._self, this._then);

  final _BatteryDto _self;
  final $Res Function(_BatteryDto) _then;

  /// Create a copy of BatteryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? serialNumber = null,
    Object? stationName = null,
    Object? stationId = null,
    Object? status = null,
    Object? chargePercentage = null,
    Object? healthPercentage = null,
    Object? cycleCount = null,
    Object? batteryType = null,
    Object? currentCustomer = freezed,
    Object? rentalStartTime = freezed,
    Object? lastRental = freezed,
    Object? daysIdle = null,
    Object? faultDescription = freezed,
    Object? lastChargedAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_BatteryDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      serialNumber: null == serialNumber
          ? _self.serialNumber
          : serialNumber // ignore: cast_nullable_to_non_nullable
              as String,
      stationName: null == stationName
          ? _self.stationName
          : stationName // ignore: cast_nullable_to_non_nullable
              as String,
      stationId: null == stationId
          ? _self.stationId
          : stationId // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      chargePercentage: null == chargePercentage
          ? _self.chargePercentage
          : chargePercentage // ignore: cast_nullable_to_non_nullable
              as double,
      healthPercentage: null == healthPercentage
          ? _self.healthPercentage
          : healthPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      cycleCount: null == cycleCount
          ? _self.cycleCount
          : cycleCount // ignore: cast_nullable_to_non_nullable
              as int,
      batteryType: null == batteryType
          ? _self.batteryType
          : batteryType // ignore: cast_nullable_to_non_nullable
              as String,
      currentCustomer: freezed == currentCustomer
          ? _self.currentCustomer
          : currentCustomer // ignore: cast_nullable_to_non_nullable
              as String?,
      rentalStartTime: freezed == rentalStartTime
          ? _self.rentalStartTime
          : rentalStartTime // ignore: cast_nullable_to_non_nullable
              as String?,
      lastRental: freezed == lastRental
          ? _self.lastRental
          : lastRental // ignore: cast_nullable_to_non_nullable
              as String?,
      daysIdle: null == daysIdle
          ? _self.daysIdle
          : daysIdle // ignore: cast_nullable_to_non_nullable
              as int,
      faultDescription: freezed == faultDescription
          ? _self.faultDescription
          : faultDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      lastChargedAt: freezed == lastChargedAt
          ? _self.lastChargedAt
          : lastChargedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$ActiveRentalDto {
  int get id;
  String get customerName;
  String get customerPhone;
  String get customerInitial;
  String get batteryCode;
  int get batteryId;
  String get stationName;
  int get stationId;
  String get startTime;
  String get expectedReturn;
  double get totalAmount;
  double get lateFee;
  String get status;
  int get durationMinutes;

  /// Create a copy of ActiveRentalDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ActiveRentalDtoCopyWith<ActiveRentalDto> get copyWith =>
      _$ActiveRentalDtoCopyWithImpl<ActiveRentalDto>(
          this as ActiveRentalDto, _$identity);

  /// Serializes this ActiveRentalDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ActiveRentalDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.customerInitial, customerInitial) ||
                other.customerInitial == customerInitial) &&
            (identical(other.batteryCode, batteryCode) ||
                other.batteryCode == batteryCode) &&
            (identical(other.batteryId, batteryId) ||
                other.batteryId == batteryId) &&
            (identical(other.stationName, stationName) ||
                other.stationName == stationName) &&
            (identical(other.stationId, stationId) ||
                other.stationId == stationId) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.expectedReturn, expectedReturn) ||
                other.expectedReturn == expectedReturn) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.lateFee, lateFee) || other.lateFee == lateFee) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      customerName,
      customerPhone,
      customerInitial,
      batteryCode,
      batteryId,
      stationName,
      stationId,
      startTime,
      expectedReturn,
      totalAmount,
      lateFee,
      status,
      durationMinutes);

  @override
  String toString() {
    return 'ActiveRentalDto(id: $id, customerName: $customerName, customerPhone: $customerPhone, customerInitial: $customerInitial, batteryCode: $batteryCode, batteryId: $batteryId, stationName: $stationName, stationId: $stationId, startTime: $startTime, expectedReturn: $expectedReturn, totalAmount: $totalAmount, lateFee: $lateFee, status: $status, durationMinutes: $durationMinutes)';
  }
}

/// @nodoc
abstract mixin class $ActiveRentalDtoCopyWith<$Res> {
  factory $ActiveRentalDtoCopyWith(
          ActiveRentalDto value, $Res Function(ActiveRentalDto) _then) =
      _$ActiveRentalDtoCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String customerName,
      String customerPhone,
      String customerInitial,
      String batteryCode,
      int batteryId,
      String stationName,
      int stationId,
      String startTime,
      String expectedReturn,
      double totalAmount,
      double lateFee,
      String status,
      int durationMinutes});
}

/// @nodoc
class _$ActiveRentalDtoCopyWithImpl<$Res>
    implements $ActiveRentalDtoCopyWith<$Res> {
  _$ActiveRentalDtoCopyWithImpl(this._self, this._then);

  final ActiveRentalDto _self;
  final $Res Function(ActiveRentalDto) _then;

  /// Create a copy of ActiveRentalDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? customerPhone = null,
    Object? customerInitial = null,
    Object? batteryCode = null,
    Object? batteryId = null,
    Object? stationName = null,
    Object? stationId = null,
    Object? startTime = null,
    Object? expectedReturn = null,
    Object? totalAmount = null,
    Object? lateFee = null,
    Object? status = null,
    Object? durationMinutes = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      customerName: null == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      customerPhone: null == customerPhone
          ? _self.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String,
      customerInitial: null == customerInitial
          ? _self.customerInitial
          : customerInitial // ignore: cast_nullable_to_non_nullable
              as String,
      batteryCode: null == batteryCode
          ? _self.batteryCode
          : batteryCode // ignore: cast_nullable_to_non_nullable
              as String,
      batteryId: null == batteryId
          ? _self.batteryId
          : batteryId // ignore: cast_nullable_to_non_nullable
              as int,
      stationName: null == stationName
          ? _self.stationName
          : stationName // ignore: cast_nullable_to_non_nullable
              as String,
      stationId: null == stationId
          ? _self.stationId
          : stationId // ignore: cast_nullable_to_non_nullable
              as int,
      startTime: null == startTime
          ? _self.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      expectedReturn: null == expectedReturn
          ? _self.expectedReturn
          : expectedReturn // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _self.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      lateFee: null == lateFee
          ? _self.lateFee
          : lateFee // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      durationMinutes: null == durationMinutes
          ? _self.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [ActiveRentalDto].
extension ActiveRentalDtoPatterns on ActiveRentalDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ActiveRentalDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ActiveRentalDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ActiveRentalDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActiveRentalDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ActiveRentalDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActiveRentalDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int id,
            String customerName,
            String customerPhone,
            String customerInitial,
            String batteryCode,
            int batteryId,
            String stationName,
            int stationId,
            String startTime,
            String expectedReturn,
            double totalAmount,
            double lateFee,
            String status,
            int durationMinutes)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ActiveRentalDto() when $default != null:
        return $default(
            _that.id,
            _that.customerName,
            _that.customerPhone,
            _that.customerInitial,
            _that.batteryCode,
            _that.batteryId,
            _that.stationName,
            _that.stationId,
            _that.startTime,
            _that.expectedReturn,
            _that.totalAmount,
            _that.lateFee,
            _that.status,
            _that.durationMinutes);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int id,
            String customerName,
            String customerPhone,
            String customerInitial,
            String batteryCode,
            int batteryId,
            String stationName,
            int stationId,
            String startTime,
            String expectedReturn,
            double totalAmount,
            double lateFee,
            String status,
            int durationMinutes)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActiveRentalDto():
        return $default(
            _that.id,
            _that.customerName,
            _that.customerPhone,
            _that.customerInitial,
            _that.batteryCode,
            _that.batteryId,
            _that.stationName,
            _that.stationId,
            _that.startTime,
            _that.expectedReturn,
            _that.totalAmount,
            _that.lateFee,
            _that.status,
            _that.durationMinutes);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int id,
            String customerName,
            String customerPhone,
            String customerInitial,
            String batteryCode,
            int batteryId,
            String stationName,
            int stationId,
            String startTime,
            String expectedReturn,
            double totalAmount,
            double lateFee,
            String status,
            int durationMinutes)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActiveRentalDto() when $default != null:
        return $default(
            _that.id,
            _that.customerName,
            _that.customerPhone,
            _that.customerInitial,
            _that.batteryCode,
            _that.batteryId,
            _that.stationName,
            _that.stationId,
            _that.startTime,
            _that.expectedReturn,
            _that.totalAmount,
            _that.lateFee,
            _that.status,
            _that.durationMinutes);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ActiveRentalDto implements ActiveRentalDto {
  const _ActiveRentalDto(
      {required this.id,
      this.customerName = '',
      this.customerPhone = '',
      this.customerInitial = '',
      this.batteryCode = '',
      this.batteryId = 0,
      this.stationName = '',
      this.stationId = 0,
      required this.startTime,
      this.expectedReturn = '',
      this.totalAmount = 0.0,
      this.lateFee = 0.0,
      this.status = 'active',
      this.durationMinutes = 0});
  factory _ActiveRentalDto.fromJson(Map<String, dynamic> json) =>
      _$ActiveRentalDtoFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final String customerName;
  @override
  @JsonKey()
  final String customerPhone;
  @override
  @JsonKey()
  final String customerInitial;
  @override
  @JsonKey()
  final String batteryCode;
  @override
  @JsonKey()
  final int batteryId;
  @override
  @JsonKey()
  final String stationName;
  @override
  @JsonKey()
  final int stationId;
  @override
  final String startTime;
  @override
  @JsonKey()
  final String expectedReturn;
  @override
  @JsonKey()
  final double totalAmount;
  @override
  @JsonKey()
  final double lateFee;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final int durationMinutes;

  /// Create a copy of ActiveRentalDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ActiveRentalDtoCopyWith<_ActiveRentalDto> get copyWith =>
      __$ActiveRentalDtoCopyWithImpl<_ActiveRentalDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ActiveRentalDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ActiveRentalDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.customerInitial, customerInitial) ||
                other.customerInitial == customerInitial) &&
            (identical(other.batteryCode, batteryCode) ||
                other.batteryCode == batteryCode) &&
            (identical(other.batteryId, batteryId) ||
                other.batteryId == batteryId) &&
            (identical(other.stationName, stationName) ||
                other.stationName == stationName) &&
            (identical(other.stationId, stationId) ||
                other.stationId == stationId) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.expectedReturn, expectedReturn) ||
                other.expectedReturn == expectedReturn) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.lateFee, lateFee) || other.lateFee == lateFee) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      customerName,
      customerPhone,
      customerInitial,
      batteryCode,
      batteryId,
      stationName,
      stationId,
      startTime,
      expectedReturn,
      totalAmount,
      lateFee,
      status,
      durationMinutes);

  @override
  String toString() {
    return 'ActiveRentalDto(id: $id, customerName: $customerName, customerPhone: $customerPhone, customerInitial: $customerInitial, batteryCode: $batteryCode, batteryId: $batteryId, stationName: $stationName, stationId: $stationId, startTime: $startTime, expectedReturn: $expectedReturn, totalAmount: $totalAmount, lateFee: $lateFee, status: $status, durationMinutes: $durationMinutes)';
  }
}

/// @nodoc
abstract mixin class _$ActiveRentalDtoCopyWith<$Res>
    implements $ActiveRentalDtoCopyWith<$Res> {
  factory _$ActiveRentalDtoCopyWith(
          _ActiveRentalDto value, $Res Function(_ActiveRentalDto) _then) =
      __$ActiveRentalDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String customerName,
      String customerPhone,
      String customerInitial,
      String batteryCode,
      int batteryId,
      String stationName,
      int stationId,
      String startTime,
      String expectedReturn,
      double totalAmount,
      double lateFee,
      String status,
      int durationMinutes});
}

/// @nodoc
class __$ActiveRentalDtoCopyWithImpl<$Res>
    implements _$ActiveRentalDtoCopyWith<$Res> {
  __$ActiveRentalDtoCopyWithImpl(this._self, this._then);

  final _ActiveRentalDto _self;
  final $Res Function(_ActiveRentalDto) _then;

  /// Create a copy of ActiveRentalDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? customerPhone = null,
    Object? customerInitial = null,
    Object? batteryCode = null,
    Object? batteryId = null,
    Object? stationName = null,
    Object? stationId = null,
    Object? startTime = null,
    Object? expectedReturn = null,
    Object? totalAmount = null,
    Object? lateFee = null,
    Object? status = null,
    Object? durationMinutes = null,
  }) {
    return _then(_ActiveRentalDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      customerName: null == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      customerPhone: null == customerPhone
          ? _self.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String,
      customerInitial: null == customerInitial
          ? _self.customerInitial
          : customerInitial // ignore: cast_nullable_to_non_nullable
              as String,
      batteryCode: null == batteryCode
          ? _self.batteryCode
          : batteryCode // ignore: cast_nullable_to_non_nullable
              as String,
      batteryId: null == batteryId
          ? _self.batteryId
          : batteryId // ignore: cast_nullable_to_non_nullable
              as int,
      stationName: null == stationName
          ? _self.stationName
          : stationName // ignore: cast_nullable_to_non_nullable
              as String,
      stationId: null == stationId
          ? _self.stationId
          : stationId // ignore: cast_nullable_to_non_nullable
              as int,
      startTime: null == startTime
          ? _self.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      expectedReturn: null == expectedReturn
          ? _self.expectedReturn
          : expectedReturn // ignore: cast_nullable_to_non_nullable
              as String,
      totalAmount: null == totalAmount
          ? _self.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      lateFee: null == lateFee
          ? _self.lateFee
          : lateFee // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      durationMinutes: null == durationMinutes
          ? _self.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$SwapPortDto {
  int get portNumber;
  String get state; // ready, active, charging, fault, offline, reserved
  String? get customerName;
  String? get customerId;
  String? get batteryCode;
  String? get newBatteryCode;
  double get chargePercent;
  double get healthPercentage;
  String? get swapStartedAt;
  String? get faultCode;
  String? get lastUsedAt;
  String? get reservationExpiry;

  /// Create a copy of SwapPortDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SwapPortDtoCopyWith<SwapPortDto> get copyWith =>
      _$SwapPortDtoCopyWithImpl<SwapPortDto>(this as SwapPortDto, _$identity);

  /// Serializes this SwapPortDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SwapPortDto &&
            (identical(other.portNumber, portNumber) ||
                other.portNumber == portNumber) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.batteryCode, batteryCode) ||
                other.batteryCode == batteryCode) &&
            (identical(other.newBatteryCode, newBatteryCode) ||
                other.newBatteryCode == newBatteryCode) &&
            (identical(other.chargePercent, chargePercent) ||
                other.chargePercent == chargePercent) &&
            (identical(other.healthPercentage, healthPercentage) ||
                other.healthPercentage == healthPercentage) &&
            (identical(other.swapStartedAt, swapStartedAt) ||
                other.swapStartedAt == swapStartedAt) &&
            (identical(other.faultCode, faultCode) ||
                other.faultCode == faultCode) &&
            (identical(other.lastUsedAt, lastUsedAt) ||
                other.lastUsedAt == lastUsedAt) &&
            (identical(other.reservationExpiry, reservationExpiry) ||
                other.reservationExpiry == reservationExpiry));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      portNumber,
      state,
      customerName,
      customerId,
      batteryCode,
      newBatteryCode,
      chargePercent,
      healthPercentage,
      swapStartedAt,
      faultCode,
      lastUsedAt,
      reservationExpiry);

  @override
  String toString() {
    return 'SwapPortDto(portNumber: $portNumber, state: $state, customerName: $customerName, customerId: $customerId, batteryCode: $batteryCode, newBatteryCode: $newBatteryCode, chargePercent: $chargePercent, healthPercentage: $healthPercentage, swapStartedAt: $swapStartedAt, faultCode: $faultCode, lastUsedAt: $lastUsedAt, reservationExpiry: $reservationExpiry)';
  }
}

/// @nodoc
abstract mixin class $SwapPortDtoCopyWith<$Res> {
  factory $SwapPortDtoCopyWith(
          SwapPortDto value, $Res Function(SwapPortDto) _then) =
      _$SwapPortDtoCopyWithImpl;
  @useResult
  $Res call(
      {int portNumber,
      String state,
      String? customerName,
      String? customerId,
      String? batteryCode,
      String? newBatteryCode,
      double chargePercent,
      double healthPercentage,
      String? swapStartedAt,
      String? faultCode,
      String? lastUsedAt,
      String? reservationExpiry});
}

/// @nodoc
class _$SwapPortDtoCopyWithImpl<$Res> implements $SwapPortDtoCopyWith<$Res> {
  _$SwapPortDtoCopyWithImpl(this._self, this._then);

  final SwapPortDto _self;
  final $Res Function(SwapPortDto) _then;

  /// Create a copy of SwapPortDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? portNumber = null,
    Object? state = null,
    Object? customerName = freezed,
    Object? customerId = freezed,
    Object? batteryCode = freezed,
    Object? newBatteryCode = freezed,
    Object? chargePercent = null,
    Object? healthPercentage = null,
    Object? swapStartedAt = freezed,
    Object? faultCode = freezed,
    Object? lastUsedAt = freezed,
    Object? reservationExpiry = freezed,
  }) {
    return _then(_self.copyWith(
      portNumber: null == portNumber
          ? _self.portNumber
          : portNumber // ignore: cast_nullable_to_non_nullable
              as int,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: freezed == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      customerId: freezed == customerId
          ? _self.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      batteryCode: freezed == batteryCode
          ? _self.batteryCode
          : batteryCode // ignore: cast_nullable_to_non_nullable
              as String?,
      newBatteryCode: freezed == newBatteryCode
          ? _self.newBatteryCode
          : newBatteryCode // ignore: cast_nullable_to_non_nullable
              as String?,
      chargePercent: null == chargePercent
          ? _self.chargePercent
          : chargePercent // ignore: cast_nullable_to_non_nullable
              as double,
      healthPercentage: null == healthPercentage
          ? _self.healthPercentage
          : healthPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      swapStartedAt: freezed == swapStartedAt
          ? _self.swapStartedAt
          : swapStartedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      faultCode: freezed == faultCode
          ? _self.faultCode
          : faultCode // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUsedAt: freezed == lastUsedAt
          ? _self.lastUsedAt
          : lastUsedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      reservationExpiry: freezed == reservationExpiry
          ? _self.reservationExpiry
          : reservationExpiry // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [SwapPortDto].
extension SwapPortDtoPatterns on SwapPortDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SwapPortDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SwapPortDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SwapPortDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SwapPortDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SwapPortDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SwapPortDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int portNumber,
            String state,
            String? customerName,
            String? customerId,
            String? batteryCode,
            String? newBatteryCode,
            double chargePercent,
            double healthPercentage,
            String? swapStartedAt,
            String? faultCode,
            String? lastUsedAt,
            String? reservationExpiry)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SwapPortDto() when $default != null:
        return $default(
            _that.portNumber,
            _that.state,
            _that.customerName,
            _that.customerId,
            _that.batteryCode,
            _that.newBatteryCode,
            _that.chargePercent,
            _that.healthPercentage,
            _that.swapStartedAt,
            _that.faultCode,
            _that.lastUsedAt,
            _that.reservationExpiry);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int portNumber,
            String state,
            String? customerName,
            String? customerId,
            String? batteryCode,
            String? newBatteryCode,
            double chargePercent,
            double healthPercentage,
            String? swapStartedAt,
            String? faultCode,
            String? lastUsedAt,
            String? reservationExpiry)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SwapPortDto():
        return $default(
            _that.portNumber,
            _that.state,
            _that.customerName,
            _that.customerId,
            _that.batteryCode,
            _that.newBatteryCode,
            _that.chargePercent,
            _that.healthPercentage,
            _that.swapStartedAt,
            _that.faultCode,
            _that.lastUsedAt,
            _that.reservationExpiry);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int portNumber,
            String state,
            String? customerName,
            String? customerId,
            String? batteryCode,
            String? newBatteryCode,
            double chargePercent,
            double healthPercentage,
            String? swapStartedAt,
            String? faultCode,
            String? lastUsedAt,
            String? reservationExpiry)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SwapPortDto() when $default != null:
        return $default(
            _that.portNumber,
            _that.state,
            _that.customerName,
            _that.customerId,
            _that.batteryCode,
            _that.newBatteryCode,
            _that.chargePercent,
            _that.healthPercentage,
            _that.swapStartedAt,
            _that.faultCode,
            _that.lastUsedAt,
            _that.reservationExpiry);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SwapPortDto implements SwapPortDto {
  const _SwapPortDto(
      {required this.portNumber,
      this.state = 'ready',
      this.customerName,
      this.customerId,
      this.batteryCode,
      this.newBatteryCode,
      this.chargePercent = 0.0,
      this.healthPercentage = 100.0,
      this.swapStartedAt,
      this.faultCode,
      this.lastUsedAt,
      this.reservationExpiry});
  factory _SwapPortDto.fromJson(Map<String, dynamic> json) =>
      _$SwapPortDtoFromJson(json);

  @override
  final int portNumber;
  @override
  @JsonKey()
  final String state;
// ready, active, charging, fault, offline, reserved
  @override
  final String? customerName;
  @override
  final String? customerId;
  @override
  final String? batteryCode;
  @override
  final String? newBatteryCode;
  @override
  @JsonKey()
  final double chargePercent;
  @override
  @JsonKey()
  final double healthPercentage;
  @override
  final String? swapStartedAt;
  @override
  final String? faultCode;
  @override
  final String? lastUsedAt;
  @override
  final String? reservationExpiry;

  /// Create a copy of SwapPortDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SwapPortDtoCopyWith<_SwapPortDto> get copyWith =>
      __$SwapPortDtoCopyWithImpl<_SwapPortDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SwapPortDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SwapPortDto &&
            (identical(other.portNumber, portNumber) ||
                other.portNumber == portNumber) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.batteryCode, batteryCode) ||
                other.batteryCode == batteryCode) &&
            (identical(other.newBatteryCode, newBatteryCode) ||
                other.newBatteryCode == newBatteryCode) &&
            (identical(other.chargePercent, chargePercent) ||
                other.chargePercent == chargePercent) &&
            (identical(other.healthPercentage, healthPercentage) ||
                other.healthPercentage == healthPercentage) &&
            (identical(other.swapStartedAt, swapStartedAt) ||
                other.swapStartedAt == swapStartedAt) &&
            (identical(other.faultCode, faultCode) ||
                other.faultCode == faultCode) &&
            (identical(other.lastUsedAt, lastUsedAt) ||
                other.lastUsedAt == lastUsedAt) &&
            (identical(other.reservationExpiry, reservationExpiry) ||
                other.reservationExpiry == reservationExpiry));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      portNumber,
      state,
      customerName,
      customerId,
      batteryCode,
      newBatteryCode,
      chargePercent,
      healthPercentage,
      swapStartedAt,
      faultCode,
      lastUsedAt,
      reservationExpiry);

  @override
  String toString() {
    return 'SwapPortDto(portNumber: $portNumber, state: $state, customerName: $customerName, customerId: $customerId, batteryCode: $batteryCode, newBatteryCode: $newBatteryCode, chargePercent: $chargePercent, healthPercentage: $healthPercentage, swapStartedAt: $swapStartedAt, faultCode: $faultCode, lastUsedAt: $lastUsedAt, reservationExpiry: $reservationExpiry)';
  }
}

/// @nodoc
abstract mixin class _$SwapPortDtoCopyWith<$Res>
    implements $SwapPortDtoCopyWith<$Res> {
  factory _$SwapPortDtoCopyWith(
          _SwapPortDto value, $Res Function(_SwapPortDto) _then) =
      __$SwapPortDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int portNumber,
      String state,
      String? customerName,
      String? customerId,
      String? batteryCode,
      String? newBatteryCode,
      double chargePercent,
      double healthPercentage,
      String? swapStartedAt,
      String? faultCode,
      String? lastUsedAt,
      String? reservationExpiry});
}

/// @nodoc
class __$SwapPortDtoCopyWithImpl<$Res> implements _$SwapPortDtoCopyWith<$Res> {
  __$SwapPortDtoCopyWithImpl(this._self, this._then);

  final _SwapPortDto _self;
  final $Res Function(_SwapPortDto) _then;

  /// Create a copy of SwapPortDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? portNumber = null,
    Object? state = null,
    Object? customerName = freezed,
    Object? customerId = freezed,
    Object? batteryCode = freezed,
    Object? newBatteryCode = freezed,
    Object? chargePercent = null,
    Object? healthPercentage = null,
    Object? swapStartedAt = freezed,
    Object? faultCode = freezed,
    Object? lastUsedAt = freezed,
    Object? reservationExpiry = freezed,
  }) {
    return _then(_SwapPortDto(
      portNumber: null == portNumber
          ? _self.portNumber
          : portNumber // ignore: cast_nullable_to_non_nullable
              as int,
      state: null == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: freezed == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      customerId: freezed == customerId
          ? _self.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String?,
      batteryCode: freezed == batteryCode
          ? _self.batteryCode
          : batteryCode // ignore: cast_nullable_to_non_nullable
              as String?,
      newBatteryCode: freezed == newBatteryCode
          ? _self.newBatteryCode
          : newBatteryCode // ignore: cast_nullable_to_non_nullable
              as String?,
      chargePercent: null == chargePercent
          ? _self.chargePercent
          : chargePercent // ignore: cast_nullable_to_non_nullable
              as double,
      healthPercentage: null == healthPercentage
          ? _self.healthPercentage
          : healthPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      swapStartedAt: freezed == swapStartedAt
          ? _self.swapStartedAt
          : swapStartedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      faultCode: freezed == faultCode
          ? _self.faultCode
          : faultCode // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUsedAt: freezed == lastUsedAt
          ? _self.lastUsedAt
          : lastUsedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      reservationExpiry: freezed == reservationExpiry
          ? _self.reservationExpiry
          : reservationExpiry // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$StationSwapDataDto {
  int get stationId;
  String get stationName;
  List<SwapPortDto> get ports;
  int get totalPorts;
  int get activeSwaps;
  int get availablePorts;

  /// Create a copy of StationSwapDataDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StationSwapDataDtoCopyWith<StationSwapDataDto> get copyWith =>
      _$StationSwapDataDtoCopyWithImpl<StationSwapDataDto>(
          this as StationSwapDataDto, _$identity);

  /// Serializes this StationSwapDataDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StationSwapDataDto &&
            (identical(other.stationId, stationId) ||
                other.stationId == stationId) &&
            (identical(other.stationName, stationName) ||
                other.stationName == stationName) &&
            const DeepCollectionEquality().equals(other.ports, ports) &&
            (identical(other.totalPorts, totalPorts) ||
                other.totalPorts == totalPorts) &&
            (identical(other.activeSwaps, activeSwaps) ||
                other.activeSwaps == activeSwaps) &&
            (identical(other.availablePorts, availablePorts) ||
                other.availablePorts == availablePorts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      stationId,
      stationName,
      const DeepCollectionEquality().hash(ports),
      totalPorts,
      activeSwaps,
      availablePorts);

  @override
  String toString() {
    return 'StationSwapDataDto(stationId: $stationId, stationName: $stationName, ports: $ports, totalPorts: $totalPorts, activeSwaps: $activeSwaps, availablePorts: $availablePorts)';
  }
}

/// @nodoc
abstract mixin class $StationSwapDataDtoCopyWith<$Res> {
  factory $StationSwapDataDtoCopyWith(
          StationSwapDataDto value, $Res Function(StationSwapDataDto) _then) =
      _$StationSwapDataDtoCopyWithImpl;
  @useResult
  $Res call(
      {int stationId,
      String stationName,
      List<SwapPortDto> ports,
      int totalPorts,
      int activeSwaps,
      int availablePorts});
}

/// @nodoc
class _$StationSwapDataDtoCopyWithImpl<$Res>
    implements $StationSwapDataDtoCopyWith<$Res> {
  _$StationSwapDataDtoCopyWithImpl(this._self, this._then);

  final StationSwapDataDto _self;
  final $Res Function(StationSwapDataDto) _then;

  /// Create a copy of StationSwapDataDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stationId = null,
    Object? stationName = null,
    Object? ports = null,
    Object? totalPorts = null,
    Object? activeSwaps = null,
    Object? availablePorts = null,
  }) {
    return _then(_self.copyWith(
      stationId: null == stationId
          ? _self.stationId
          : stationId // ignore: cast_nullable_to_non_nullable
              as int,
      stationName: null == stationName
          ? _self.stationName
          : stationName // ignore: cast_nullable_to_non_nullable
              as String,
      ports: null == ports
          ? _self.ports
          : ports // ignore: cast_nullable_to_non_nullable
              as List<SwapPortDto>,
      totalPorts: null == totalPorts
          ? _self.totalPorts
          : totalPorts // ignore: cast_nullable_to_non_nullable
              as int,
      activeSwaps: null == activeSwaps
          ? _self.activeSwaps
          : activeSwaps // ignore: cast_nullable_to_non_nullable
              as int,
      availablePorts: null == availablePorts
          ? _self.availablePorts
          : availablePorts // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [StationSwapDataDto].
extension StationSwapDataDtoPatterns on StationSwapDataDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_StationSwapDataDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StationSwapDataDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_StationSwapDataDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StationSwapDataDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_StationSwapDataDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StationSwapDataDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(int stationId, String stationName, List<SwapPortDto> ports,
            int totalPorts, int activeSwaps, int availablePorts)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StationSwapDataDto() when $default != null:
        return $default(_that.stationId, _that.stationName, _that.ports,
            _that.totalPorts, _that.activeSwaps, _that.availablePorts);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(int stationId, String stationName, List<SwapPortDto> ports,
            int totalPorts, int activeSwaps, int availablePorts)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StationSwapDataDto():
        return $default(_that.stationId, _that.stationName, _that.ports,
            _that.totalPorts, _that.activeSwaps, _that.availablePorts);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int stationId,
            String stationName,
            List<SwapPortDto> ports,
            int totalPorts,
            int activeSwaps,
            int availablePorts)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StationSwapDataDto() when $default != null:
        return $default(_that.stationId, _that.stationName, _that.ports,
            _that.totalPorts, _that.activeSwaps, _that.availablePorts);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _StationSwapDataDto implements StationSwapDataDto {
  const _StationSwapDataDto(
      {required this.stationId,
      required this.stationName,
      final List<SwapPortDto> ports = const [],
      this.totalPorts = 0,
      this.activeSwaps = 0,
      this.availablePorts = 0})
      : _ports = ports;
  factory _StationSwapDataDto.fromJson(Map<String, dynamic> json) =>
      _$StationSwapDataDtoFromJson(json);

  @override
  final int stationId;
  @override
  final String stationName;
  final List<SwapPortDto> _ports;
  @override
  @JsonKey()
  List<SwapPortDto> get ports {
    if (_ports is EqualUnmodifiableListView) return _ports;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ports);
  }

  @override
  @JsonKey()
  final int totalPorts;
  @override
  @JsonKey()
  final int activeSwaps;
  @override
  @JsonKey()
  final int availablePorts;

  /// Create a copy of StationSwapDataDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StationSwapDataDtoCopyWith<_StationSwapDataDto> get copyWith =>
      __$StationSwapDataDtoCopyWithImpl<_StationSwapDataDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$StationSwapDataDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StationSwapDataDto &&
            (identical(other.stationId, stationId) ||
                other.stationId == stationId) &&
            (identical(other.stationName, stationName) ||
                other.stationName == stationName) &&
            const DeepCollectionEquality().equals(other._ports, _ports) &&
            (identical(other.totalPorts, totalPorts) ||
                other.totalPorts == totalPorts) &&
            (identical(other.activeSwaps, activeSwaps) ||
                other.activeSwaps == activeSwaps) &&
            (identical(other.availablePorts, availablePorts) ||
                other.availablePorts == availablePorts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      stationId,
      stationName,
      const DeepCollectionEquality().hash(_ports),
      totalPorts,
      activeSwaps,
      availablePorts);

  @override
  String toString() {
    return 'StationSwapDataDto(stationId: $stationId, stationName: $stationName, ports: $ports, totalPorts: $totalPorts, activeSwaps: $activeSwaps, availablePorts: $availablePorts)';
  }
}

/// @nodoc
abstract mixin class _$StationSwapDataDtoCopyWith<$Res>
    implements $StationSwapDataDtoCopyWith<$Res> {
  factory _$StationSwapDataDtoCopyWith(
          _StationSwapDataDto value, $Res Function(_StationSwapDataDto) _then) =
      __$StationSwapDataDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int stationId,
      String stationName,
      List<SwapPortDto> ports,
      int totalPorts,
      int activeSwaps,
      int availablePorts});
}

/// @nodoc
class __$StationSwapDataDtoCopyWithImpl<$Res>
    implements _$StationSwapDataDtoCopyWith<$Res> {
  __$StationSwapDataDtoCopyWithImpl(this._self, this._then);

  final _StationSwapDataDto _self;
  final $Res Function(_StationSwapDataDto) _then;

  /// Create a copy of StationSwapDataDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? stationId = null,
    Object? stationName = null,
    Object? ports = null,
    Object? totalPorts = null,
    Object? activeSwaps = null,
    Object? availablePorts = null,
  }) {
    return _then(_StationSwapDataDto(
      stationId: null == stationId
          ? _self.stationId
          : stationId // ignore: cast_nullable_to_non_nullable
              as int,
      stationName: null == stationName
          ? _self.stationName
          : stationName // ignore: cast_nullable_to_non_nullable
              as String,
      ports: null == ports
          ? _self._ports
          : ports // ignore: cast_nullable_to_non_nullable
              as List<SwapPortDto>,
      totalPorts: null == totalPorts
          ? _self.totalPorts
          : totalPorts // ignore: cast_nullable_to_non_nullable
              as int,
      activeSwaps: null == activeSwaps
          ? _self.activeSwaps
          : activeSwaps // ignore: cast_nullable_to_non_nullable
              as int,
      availablePorts: null == availablePorts
          ? _self.availablePorts
          : availablePorts // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$ReviewDto {
  int get id;
  String get customerName;
  String get customerInitial;
  int get rating;
  String? get reviewText;
  String get stationName;
  int get stationId;
  String get createdAt;
  String? get dealerReply;
  String? get repliedAt;
  bool get isVerifiedRental;

  /// Create a copy of ReviewDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ReviewDtoCopyWith<ReviewDto> get copyWith =>
      _$ReviewDtoCopyWithImpl<ReviewDto>(this as ReviewDto, _$identity);

  /// Serializes this ReviewDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ReviewDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerInitial, customerInitial) ||
                other.customerInitial == customerInitial) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewText, reviewText) ||
                other.reviewText == reviewText) &&
            (identical(other.stationName, stationName) ||
                other.stationName == stationName) &&
            (identical(other.stationId, stationId) ||
                other.stationId == stationId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.dealerReply, dealerReply) ||
                other.dealerReply == dealerReply) &&
            (identical(other.repliedAt, repliedAt) ||
                other.repliedAt == repliedAt) &&
            (identical(other.isVerifiedRental, isVerifiedRental) ||
                other.isVerifiedRental == isVerifiedRental));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      customerName,
      customerInitial,
      rating,
      reviewText,
      stationName,
      stationId,
      createdAt,
      dealerReply,
      repliedAt,
      isVerifiedRental);

  @override
  String toString() {
    return 'ReviewDto(id: $id, customerName: $customerName, customerInitial: $customerInitial, rating: $rating, reviewText: $reviewText, stationName: $stationName, stationId: $stationId, createdAt: $createdAt, dealerReply: $dealerReply, repliedAt: $repliedAt, isVerifiedRental: $isVerifiedRental)';
  }
}

/// @nodoc
abstract mixin class $ReviewDtoCopyWith<$Res> {
  factory $ReviewDtoCopyWith(ReviewDto value, $Res Function(ReviewDto) _then) =
      _$ReviewDtoCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String customerName,
      String customerInitial,
      int rating,
      String? reviewText,
      String stationName,
      int stationId,
      String createdAt,
      String? dealerReply,
      String? repliedAt,
      bool isVerifiedRental});
}

/// @nodoc
class _$ReviewDtoCopyWithImpl<$Res> implements $ReviewDtoCopyWith<$Res> {
  _$ReviewDtoCopyWithImpl(this._self, this._then);

  final ReviewDto _self;
  final $Res Function(ReviewDto) _then;

  /// Create a copy of ReviewDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? customerInitial = null,
    Object? rating = null,
    Object? reviewText = freezed,
    Object? stationName = null,
    Object? stationId = null,
    Object? createdAt = null,
    Object? dealerReply = freezed,
    Object? repliedAt = freezed,
    Object? isVerifiedRental = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      customerName: null == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      customerInitial: null == customerInitial
          ? _self.customerInitial
          : customerInitial // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _self.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      reviewText: freezed == reviewText
          ? _self.reviewText
          : reviewText // ignore: cast_nullable_to_non_nullable
              as String?,
      stationName: null == stationName
          ? _self.stationName
          : stationName // ignore: cast_nullable_to_non_nullable
              as String,
      stationId: null == stationId
          ? _self.stationId
          : stationId // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      dealerReply: freezed == dealerReply
          ? _self.dealerReply
          : dealerReply // ignore: cast_nullable_to_non_nullable
              as String?,
      repliedAt: freezed == repliedAt
          ? _self.repliedAt
          : repliedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerifiedRental: null == isVerifiedRental
          ? _self.isVerifiedRental
          : isVerifiedRental // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [ReviewDto].
extension ReviewDtoPatterns on ReviewDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ReviewDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ReviewDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ReviewDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReviewDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ReviewDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReviewDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int id,
            String customerName,
            String customerInitial,
            int rating,
            String? reviewText,
            String stationName,
            int stationId,
            String createdAt,
            String? dealerReply,
            String? repliedAt,
            bool isVerifiedRental)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ReviewDto() when $default != null:
        return $default(
            _that.id,
            _that.customerName,
            _that.customerInitial,
            _that.rating,
            _that.reviewText,
            _that.stationName,
            _that.stationId,
            _that.createdAt,
            _that.dealerReply,
            _that.repliedAt,
            _that.isVerifiedRental);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int id,
            String customerName,
            String customerInitial,
            int rating,
            String? reviewText,
            String stationName,
            int stationId,
            String createdAt,
            String? dealerReply,
            String? repliedAt,
            bool isVerifiedRental)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReviewDto():
        return $default(
            _that.id,
            _that.customerName,
            _that.customerInitial,
            _that.rating,
            _that.reviewText,
            _that.stationName,
            _that.stationId,
            _that.createdAt,
            _that.dealerReply,
            _that.repliedAt,
            _that.isVerifiedRental);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int id,
            String customerName,
            String customerInitial,
            int rating,
            String? reviewText,
            String stationName,
            int stationId,
            String createdAt,
            String? dealerReply,
            String? repliedAt,
            bool isVerifiedRental)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReviewDto() when $default != null:
        return $default(
            _that.id,
            _that.customerName,
            _that.customerInitial,
            _that.rating,
            _that.reviewText,
            _that.stationName,
            _that.stationId,
            _that.createdAt,
            _that.dealerReply,
            _that.repliedAt,
            _that.isVerifiedRental);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ReviewDto implements ReviewDto {
  const _ReviewDto(
      {required this.id,
      this.customerName = '',
      this.customerInitial = '',
      this.rating = 5,
      this.reviewText,
      this.stationName = '',
      this.stationId = 0,
      required this.createdAt,
      this.dealerReply,
      this.repliedAt,
      this.isVerifiedRental = false});
  factory _ReviewDto.fromJson(Map<String, dynamic> json) =>
      _$ReviewDtoFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final String customerName;
  @override
  @JsonKey()
  final String customerInitial;
  @override
  @JsonKey()
  final int rating;
  @override
  final String? reviewText;
  @override
  @JsonKey()
  final String stationName;
  @override
  @JsonKey()
  final int stationId;
  @override
  final String createdAt;
  @override
  final String? dealerReply;
  @override
  final String? repliedAt;
  @override
  @JsonKey()
  final bool isVerifiedRental;

  /// Create a copy of ReviewDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ReviewDtoCopyWith<_ReviewDto> get copyWith =>
      __$ReviewDtoCopyWithImpl<_ReviewDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ReviewDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ReviewDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerInitial, customerInitial) ||
                other.customerInitial == customerInitial) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewText, reviewText) ||
                other.reviewText == reviewText) &&
            (identical(other.stationName, stationName) ||
                other.stationName == stationName) &&
            (identical(other.stationId, stationId) ||
                other.stationId == stationId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.dealerReply, dealerReply) ||
                other.dealerReply == dealerReply) &&
            (identical(other.repliedAt, repliedAt) ||
                other.repliedAt == repliedAt) &&
            (identical(other.isVerifiedRental, isVerifiedRental) ||
                other.isVerifiedRental == isVerifiedRental));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      customerName,
      customerInitial,
      rating,
      reviewText,
      stationName,
      stationId,
      createdAt,
      dealerReply,
      repliedAt,
      isVerifiedRental);

  @override
  String toString() {
    return 'ReviewDto(id: $id, customerName: $customerName, customerInitial: $customerInitial, rating: $rating, reviewText: $reviewText, stationName: $stationName, stationId: $stationId, createdAt: $createdAt, dealerReply: $dealerReply, repliedAt: $repliedAt, isVerifiedRental: $isVerifiedRental)';
  }
}

/// @nodoc
abstract mixin class _$ReviewDtoCopyWith<$Res>
    implements $ReviewDtoCopyWith<$Res> {
  factory _$ReviewDtoCopyWith(
          _ReviewDto value, $Res Function(_ReviewDto) _then) =
      __$ReviewDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String customerName,
      String customerInitial,
      int rating,
      String? reviewText,
      String stationName,
      int stationId,
      String createdAt,
      String? dealerReply,
      String? repliedAt,
      bool isVerifiedRental});
}

/// @nodoc
class __$ReviewDtoCopyWithImpl<$Res> implements _$ReviewDtoCopyWith<$Res> {
  __$ReviewDtoCopyWithImpl(this._self, this._then);

  final _ReviewDto _self;
  final $Res Function(_ReviewDto) _then;

  /// Create a copy of ReviewDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? customerInitial = null,
    Object? rating = null,
    Object? reviewText = freezed,
    Object? stationName = null,
    Object? stationId = null,
    Object? createdAt = null,
    Object? dealerReply = freezed,
    Object? repliedAt = freezed,
    Object? isVerifiedRental = null,
  }) {
    return _then(_ReviewDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      customerName: null == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      customerInitial: null == customerInitial
          ? _self.customerInitial
          : customerInitial // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _self.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      reviewText: freezed == reviewText
          ? _self.reviewText
          : reviewText // ignore: cast_nullable_to_non_nullable
              as String?,
      stationName: null == stationName
          ? _self.stationName
          : stationName // ignore: cast_nullable_to_non_nullable
              as String,
      stationId: null == stationId
          ? _self.stationId
          : stationId // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      dealerReply: freezed == dealerReply
          ? _self.dealerReply
          : dealerReply // ignore: cast_nullable_to_non_nullable
              as String?,
      repliedAt: freezed == repliedAt
          ? _self.repliedAt
          : repliedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerifiedRental: null == isVerifiedRental
          ? _self.isVerifiedRental
          : isVerifiedRental // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$SwapEventDto {
  String get description;
  String get timestamp;
  String get batteryCode;
  String get stationName;
  String get eventType;

  /// Create a copy of SwapEventDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SwapEventDtoCopyWith<SwapEventDto> get copyWith =>
      _$SwapEventDtoCopyWithImpl<SwapEventDto>(
          this as SwapEventDto, _$identity);

  /// Serializes this SwapEventDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SwapEventDto &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.batteryCode, batteryCode) ||
                other.batteryCode == batteryCode) &&
            (identical(other.stationName, stationName) ||
                other.stationName == stationName) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, description, timestamp, batteryCode, stationName, eventType);

  @override
  String toString() {
    return 'SwapEventDto(description: $description, timestamp: $timestamp, batteryCode: $batteryCode, stationName: $stationName, eventType: $eventType)';
  }
}

/// @nodoc
abstract mixin class $SwapEventDtoCopyWith<$Res> {
  factory $SwapEventDtoCopyWith(
          SwapEventDto value, $Res Function(SwapEventDto) _then) =
      _$SwapEventDtoCopyWithImpl;
  @useResult
  $Res call(
      {String description,
      String timestamp,
      String batteryCode,
      String stationName,
      String eventType});
}

/// @nodoc
class _$SwapEventDtoCopyWithImpl<$Res> implements $SwapEventDtoCopyWith<$Res> {
  _$SwapEventDtoCopyWithImpl(this._self, this._then);

  final SwapEventDto _self;
  final $Res Function(SwapEventDto) _then;

  /// Create a copy of SwapEventDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = null,
    Object? timestamp = null,
    Object? batteryCode = null,
    Object? stationName = null,
    Object? eventType = null,
  }) {
    return _then(_self.copyWith(
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String,
      batteryCode: null == batteryCode
          ? _self.batteryCode
          : batteryCode // ignore: cast_nullable_to_non_nullable
              as String,
      stationName: null == stationName
          ? _self.stationName
          : stationName // ignore: cast_nullable_to_non_nullable
              as String,
      eventType: null == eventType
          ? _self.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [SwapEventDto].
extension SwapEventDtoPatterns on SwapEventDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SwapEventDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SwapEventDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SwapEventDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SwapEventDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SwapEventDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SwapEventDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String description, String timestamp, String batteryCode,
            String stationName, String eventType)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SwapEventDto() when $default != null:
        return $default(_that.description, _that.timestamp, _that.batteryCode,
            _that.stationName, _that.eventType);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String description, String timestamp, String batteryCode,
            String stationName, String eventType)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SwapEventDto():
        return $default(_that.description, _that.timestamp, _that.batteryCode,
            _that.stationName, _that.eventType);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String description, String timestamp, String batteryCode,
            String stationName, String eventType)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SwapEventDto() when $default != null:
        return $default(_that.description, _that.timestamp, _that.batteryCode,
            _that.stationName, _that.eventType);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SwapEventDto implements SwapEventDto {
  const _SwapEventDto(
      {required this.description,
      required this.timestamp,
      this.batteryCode = '',
      this.stationName = '',
      this.eventType = 'completed'});
  factory _SwapEventDto.fromJson(Map<String, dynamic> json) =>
      _$SwapEventDtoFromJson(json);

  @override
  final String description;
  @override
  final String timestamp;
  @override
  @JsonKey()
  final String batteryCode;
  @override
  @JsonKey()
  final String stationName;
  @override
  @JsonKey()
  final String eventType;

  /// Create a copy of SwapEventDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SwapEventDtoCopyWith<_SwapEventDto> get copyWith =>
      __$SwapEventDtoCopyWithImpl<_SwapEventDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SwapEventDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SwapEventDto &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.batteryCode, batteryCode) ||
                other.batteryCode == batteryCode) &&
            (identical(other.stationName, stationName) ||
                other.stationName == stationName) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, description, timestamp, batteryCode, stationName, eventType);

  @override
  String toString() {
    return 'SwapEventDto(description: $description, timestamp: $timestamp, batteryCode: $batteryCode, stationName: $stationName, eventType: $eventType)';
  }
}

/// @nodoc
abstract mixin class _$SwapEventDtoCopyWith<$Res>
    implements $SwapEventDtoCopyWith<$Res> {
  factory _$SwapEventDtoCopyWith(
          _SwapEventDto value, $Res Function(_SwapEventDto) _then) =
      __$SwapEventDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String description,
      String timestamp,
      String batteryCode,
      String stationName,
      String eventType});
}

/// @nodoc
class __$SwapEventDtoCopyWithImpl<$Res>
    implements _$SwapEventDtoCopyWith<$Res> {
  __$SwapEventDtoCopyWithImpl(this._self, this._then);

  final _SwapEventDto _self;
  final $Res Function(_SwapEventDto) _then;

  /// Create a copy of SwapEventDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? description = null,
    Object? timestamp = null,
    Object? batteryCode = null,
    Object? stationName = null,
    Object? eventType = null,
  }) {
    return _then(_SwapEventDto(
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String,
      batteryCode: null == batteryCode
          ? _self.batteryCode
          : batteryCode // ignore: cast_nullable_to_non_nullable
              as String,
      stationName: null == stationName
          ? _self.stationName
          : stationName // ignore: cast_nullable_to_non_nullable
              as String,
      eventType: null == eventType
          ? _self.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$ActivityEventDto {
  int get id;
  String get eventType;
  String get description;
  String get createdAt;
  String? get batteryCode;
  String? get customerName;
  double get amount;

  /// Create a copy of ActivityEventDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ActivityEventDtoCopyWith<ActivityEventDto> get copyWith =>
      _$ActivityEventDtoCopyWithImpl<ActivityEventDto>(
          this as ActivityEventDto, _$identity);

  /// Serializes this ActivityEventDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ActivityEventDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.batteryCode, batteryCode) ||
                other.batteryCode == batteryCode) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, eventType, description,
      createdAt, batteryCode, customerName, amount);

  @override
  String toString() {
    return 'ActivityEventDto(id: $id, eventType: $eventType, description: $description, createdAt: $createdAt, batteryCode: $batteryCode, customerName: $customerName, amount: $amount)';
  }
}

/// @nodoc
abstract mixin class $ActivityEventDtoCopyWith<$Res> {
  factory $ActivityEventDtoCopyWith(
          ActivityEventDto value, $Res Function(ActivityEventDto) _then) =
      _$ActivityEventDtoCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String eventType,
      String description,
      String createdAt,
      String? batteryCode,
      String? customerName,
      double amount});
}

/// @nodoc
class _$ActivityEventDtoCopyWithImpl<$Res>
    implements $ActivityEventDtoCopyWith<$Res> {
  _$ActivityEventDtoCopyWithImpl(this._self, this._then);

  final ActivityEventDto _self;
  final $Res Function(ActivityEventDto) _then;

  /// Create a copy of ActivityEventDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventType = null,
    Object? description = null,
    Object? createdAt = null,
    Object? batteryCode = freezed,
    Object? customerName = freezed,
    Object? amount = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      eventType: null == eventType
          ? _self.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      batteryCode: freezed == batteryCode
          ? _self.batteryCode
          : batteryCode // ignore: cast_nullable_to_non_nullable
              as String?,
      customerName: freezed == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [ActivityEventDto].
extension ActivityEventDtoPatterns on ActivityEventDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ActivityEventDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ActivityEventDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ActivityEventDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActivityEventDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ActivityEventDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActivityEventDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int id,
            String eventType,
            String description,
            String createdAt,
            String? batteryCode,
            String? customerName,
            double amount)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ActivityEventDto() when $default != null:
        return $default(
            _that.id,
            _that.eventType,
            _that.description,
            _that.createdAt,
            _that.batteryCode,
            _that.customerName,
            _that.amount);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int id,
            String eventType,
            String description,
            String createdAt,
            String? batteryCode,
            String? customerName,
            double amount)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActivityEventDto():
        return $default(
            _that.id,
            _that.eventType,
            _that.description,
            _that.createdAt,
            _that.batteryCode,
            _that.customerName,
            _that.amount);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int id,
            String eventType,
            String description,
            String createdAt,
            String? batteryCode,
            String? customerName,
            double amount)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ActivityEventDto() when $default != null:
        return $default(
            _that.id,
            _that.eventType,
            _that.description,
            _that.createdAt,
            _that.batteryCode,
            _that.customerName,
            _that.amount);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ActivityEventDto implements ActivityEventDto {
  const _ActivityEventDto(
      {required this.id,
      required this.eventType,
      required this.description,
      required this.createdAt,
      this.batteryCode,
      this.customerName,
      this.amount = 0.0});
  factory _ActivityEventDto.fromJson(Map<String, dynamic> json) =>
      _$ActivityEventDtoFromJson(json);

  @override
  final int id;
  @override
  final String eventType;
  @override
  final String description;
  @override
  final String createdAt;
  @override
  final String? batteryCode;
  @override
  final String? customerName;
  @override
  @JsonKey()
  final double amount;

  /// Create a copy of ActivityEventDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ActivityEventDtoCopyWith<_ActivityEventDto> get copyWith =>
      __$ActivityEventDtoCopyWithImpl<_ActivityEventDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ActivityEventDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ActivityEventDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.batteryCode, batteryCode) ||
                other.batteryCode == batteryCode) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, eventType, description,
      createdAt, batteryCode, customerName, amount);

  @override
  String toString() {
    return 'ActivityEventDto(id: $id, eventType: $eventType, description: $description, createdAt: $createdAt, batteryCode: $batteryCode, customerName: $customerName, amount: $amount)';
  }
}

/// @nodoc
abstract mixin class _$ActivityEventDtoCopyWith<$Res>
    implements $ActivityEventDtoCopyWith<$Res> {
  factory _$ActivityEventDtoCopyWith(
          _ActivityEventDto value, $Res Function(_ActivityEventDto) _then) =
      __$ActivityEventDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String eventType,
      String description,
      String createdAt,
      String? batteryCode,
      String? customerName,
      double amount});
}

/// @nodoc
class __$ActivityEventDtoCopyWithImpl<$Res>
    implements _$ActivityEventDtoCopyWith<$Res> {
  __$ActivityEventDtoCopyWithImpl(this._self, this._then);

  final _ActivityEventDto _self;
  final $Res Function(_ActivityEventDto) _then;

  /// Create a copy of ActivityEventDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? eventType = null,
    Object? description = null,
    Object? createdAt = null,
    Object? batteryCode = freezed,
    Object? customerName = freezed,
    Object? amount = null,
  }) {
    return _then(_ActivityEventDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      eventType: null == eventType
          ? _self.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      batteryCode: freezed == batteryCode
          ? _self.batteryCode
          : batteryCode // ignore: cast_nullable_to_non_nullable
              as String?,
      customerName: freezed == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
mixin _$TransactionDto {
  int get id;
  String get type;
  String get customer;
  double get amount;
  String get time;

  /// Create a copy of TransactionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransactionDtoCopyWith<TransactionDto> get copyWith =>
      _$TransactionDtoCopyWithImpl<TransactionDto>(
          this as TransactionDto, _$identity);

  /// Serializes this TransactionDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransactionDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.time, time) || other.time == time));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, type, customer, amount, time);

  @override
  String toString() {
    return 'TransactionDto(id: $id, type: $type, customer: $customer, amount: $amount, time: $time)';
  }
}

/// @nodoc
abstract mixin class $TransactionDtoCopyWith<$Res> {
  factory $TransactionDtoCopyWith(
          TransactionDto value, $Res Function(TransactionDto) _then) =
      _$TransactionDtoCopyWithImpl;
  @useResult
  $Res call({int id, String type, String customer, double amount, String time});
}

/// @nodoc
class _$TransactionDtoCopyWithImpl<$Res>
    implements $TransactionDtoCopyWith<$Res> {
  _$TransactionDtoCopyWithImpl(this._self, this._then);

  final TransactionDto _self;
  final $Res Function(TransactionDto) _then;

  /// Create a copy of TransactionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? customer = null,
    Object? amount = null,
    Object? time = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      customer: null == customer
          ? _self.customer
          : customer // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [TransactionDto].
extension TransactionDtoPatterns on TransactionDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_TransactionDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TransactionDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_TransactionDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TransactionDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_TransactionDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TransactionDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int id, String type, String customer, double amount, String time)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TransactionDto() when $default != null:
        return $default(
            _that.id, _that.type, _that.customer, _that.amount, _that.time);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int id, String type, String customer, double amount, String time)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TransactionDto():
        return $default(
            _that.id, _that.type, _that.customer, _that.amount, _that.time);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int id, String type, String customer, double amount, String time)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TransactionDto() when $default != null:
        return $default(
            _that.id, _that.type, _that.customer, _that.amount, _that.time);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TransactionDto implements TransactionDto {
  const _TransactionDto(
      {required this.id,
      this.type = 'Rental',
      this.customer = '',
      this.amount = 0.0,
      required this.time});
  factory _TransactionDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionDtoFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey()
  final String customer;
  @override
  @JsonKey()
  final double amount;
  @override
  final String time;

  /// Create a copy of TransactionDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TransactionDtoCopyWith<_TransactionDto> get copyWith =>
      __$TransactionDtoCopyWithImpl<_TransactionDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TransactionDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TransactionDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.customer, customer) ||
                other.customer == customer) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.time, time) || other.time == time));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, type, customer, amount, time);

  @override
  String toString() {
    return 'TransactionDto(id: $id, type: $type, customer: $customer, amount: $amount, time: $time)';
  }
}

/// @nodoc
abstract mixin class _$TransactionDtoCopyWith<$Res>
    implements $TransactionDtoCopyWith<$Res> {
  factory _$TransactionDtoCopyWith(
          _TransactionDto value, $Res Function(_TransactionDto) _then) =
      __$TransactionDtoCopyWithImpl;
  @override
  @useResult
  $Res call({int id, String type, String customer, double amount, String time});
}

/// @nodoc
class __$TransactionDtoCopyWithImpl<$Res>
    implements _$TransactionDtoCopyWith<$Res> {
  __$TransactionDtoCopyWithImpl(this._self, this._then);

  final _TransactionDto _self;
  final $Res Function(_TransactionDto) _then;

  /// Create a copy of TransactionDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? customer = null,
    Object? amount = null,
    Object? time = null,
  }) {
    return _then(_TransactionDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      customer: null == customer
          ? _self.customer
          : customer // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      time: null == time
          ? _self.time
          : time // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$SwapDto {
  int get id;
  String get customerName;
  int get customerId;
  String get stationName;
  int get stationId;
  String get oldBatteryCode;
  String get newBatteryCode;
  double get oldBatterySoc;
  double get newBatterySoc;
  double get swapAmount;
  String get status;
  String get paymentStatus;
  String get createdAt;
  String? get completedAt;

  /// Create a copy of SwapDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SwapDtoCopyWith<SwapDto> get copyWith =>
      _$SwapDtoCopyWithImpl<SwapDto>(this as SwapDto, _$identity);

  /// Serializes this SwapDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SwapDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.stationName, stationName) ||
                other.stationName == stationName) &&
            (identical(other.stationId, stationId) ||
                other.stationId == stationId) &&
            (identical(other.oldBatteryCode, oldBatteryCode) ||
                other.oldBatteryCode == oldBatteryCode) &&
            (identical(other.newBatteryCode, newBatteryCode) ||
                other.newBatteryCode == newBatteryCode) &&
            (identical(other.oldBatterySoc, oldBatterySoc) ||
                other.oldBatterySoc == oldBatterySoc) &&
            (identical(other.newBatterySoc, newBatterySoc) ||
                other.newBatterySoc == newBatterySoc) &&
            (identical(other.swapAmount, swapAmount) ||
                other.swapAmount == swapAmount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      customerName,
      customerId,
      stationName,
      stationId,
      oldBatteryCode,
      newBatteryCode,
      oldBatterySoc,
      newBatterySoc,
      swapAmount,
      status,
      paymentStatus,
      createdAt,
      completedAt);

  @override
  String toString() {
    return 'SwapDto(id: $id, customerName: $customerName, customerId: $customerId, stationName: $stationName, stationId: $stationId, oldBatteryCode: $oldBatteryCode, newBatteryCode: $newBatteryCode, oldBatterySoc: $oldBatterySoc, newBatterySoc: $newBatterySoc, swapAmount: $swapAmount, status: $status, paymentStatus: $paymentStatus, createdAt: $createdAt, completedAt: $completedAt)';
  }
}

/// @nodoc
abstract mixin class $SwapDtoCopyWith<$Res> {
  factory $SwapDtoCopyWith(SwapDto value, $Res Function(SwapDto) _then) =
      _$SwapDtoCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String customerName,
      int customerId,
      String stationName,
      int stationId,
      String oldBatteryCode,
      String newBatteryCode,
      double oldBatterySoc,
      double newBatterySoc,
      double swapAmount,
      String status,
      String paymentStatus,
      String createdAt,
      String? completedAt});
}

/// @nodoc
class _$SwapDtoCopyWithImpl<$Res> implements $SwapDtoCopyWith<$Res> {
  _$SwapDtoCopyWithImpl(this._self, this._then);

  final SwapDto _self;
  final $Res Function(SwapDto) _then;

  /// Create a copy of SwapDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? customerId = null,
    Object? stationName = null,
    Object? stationId = null,
    Object? oldBatteryCode = null,
    Object? newBatteryCode = null,
    Object? oldBatterySoc = null,
    Object? newBatterySoc = null,
    Object? swapAmount = null,
    Object? status = null,
    Object? paymentStatus = null,
    Object? createdAt = null,
    Object? completedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      customerName: null == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _self.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as int,
      stationName: null == stationName
          ? _self.stationName
          : stationName // ignore: cast_nullable_to_non_nullable
              as String,
      stationId: null == stationId
          ? _self.stationId
          : stationId // ignore: cast_nullable_to_non_nullable
              as int,
      oldBatteryCode: null == oldBatteryCode
          ? _self.oldBatteryCode
          : oldBatteryCode // ignore: cast_nullable_to_non_nullable
              as String,
      newBatteryCode: null == newBatteryCode
          ? _self.newBatteryCode
          : newBatteryCode // ignore: cast_nullable_to_non_nullable
              as String,
      oldBatterySoc: null == oldBatterySoc
          ? _self.oldBatterySoc
          : oldBatterySoc // ignore: cast_nullable_to_non_nullable
              as double,
      newBatterySoc: null == newBatterySoc
          ? _self.newBatterySoc
          : newBatterySoc // ignore: cast_nullable_to_non_nullable
              as double,
      swapAmount: null == swapAmount
          ? _self.swapAmount
          : swapAmount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      paymentStatus: null == paymentStatus
          ? _self.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      completedAt: freezed == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [SwapDto].
extension SwapDtoPatterns on SwapDto {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SwapDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SwapDto() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SwapDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SwapDto():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SwapDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SwapDto() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            int id,
            String customerName,
            int customerId,
            String stationName,
            int stationId,
            String oldBatteryCode,
            String newBatteryCode,
            double oldBatterySoc,
            double newBatterySoc,
            double swapAmount,
            String status,
            String paymentStatus,
            String createdAt,
            String? completedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SwapDto() when $default != null:
        return $default(
            _that.id,
            _that.customerName,
            _that.customerId,
            _that.stationName,
            _that.stationId,
            _that.oldBatteryCode,
            _that.newBatteryCode,
            _that.oldBatterySoc,
            _that.newBatterySoc,
            _that.swapAmount,
            _that.status,
            _that.paymentStatus,
            _that.createdAt,
            _that.completedAt);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            int id,
            String customerName,
            int customerId,
            String stationName,
            int stationId,
            String oldBatteryCode,
            String newBatteryCode,
            double oldBatterySoc,
            double newBatterySoc,
            double swapAmount,
            String status,
            String paymentStatus,
            String createdAt,
            String? completedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SwapDto():
        return $default(
            _that.id,
            _that.customerName,
            _that.customerId,
            _that.stationName,
            _that.stationId,
            _that.oldBatteryCode,
            _that.newBatteryCode,
            _that.oldBatterySoc,
            _that.newBatterySoc,
            _that.swapAmount,
            _that.status,
            _that.paymentStatus,
            _that.createdAt,
            _that.completedAt);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            int id,
            String customerName,
            int customerId,
            String stationName,
            int stationId,
            String oldBatteryCode,
            String newBatteryCode,
            double oldBatterySoc,
            double newBatterySoc,
            double swapAmount,
            String status,
            String paymentStatus,
            String createdAt,
            String? completedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SwapDto() when $default != null:
        return $default(
            _that.id,
            _that.customerName,
            _that.customerId,
            _that.stationName,
            _that.stationId,
            _that.oldBatteryCode,
            _that.newBatteryCode,
            _that.oldBatterySoc,
            _that.newBatterySoc,
            _that.swapAmount,
            _that.status,
            _that.paymentStatus,
            _that.createdAt,
            _that.completedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SwapDto implements SwapDto {
  const _SwapDto(
      {required this.id,
      this.customerName = '',
      this.customerId = 0,
      this.stationName = '',
      this.stationId = 0,
      this.oldBatteryCode = '',
      this.newBatteryCode = '',
      this.oldBatterySoc = 0.0,
      this.newBatterySoc = 0.0,
      this.swapAmount = 0.0,
      this.status = 'completed',
      this.paymentStatus = 'paid',
      required this.createdAt,
      this.completedAt});
  factory _SwapDto.fromJson(Map<String, dynamic> json) =>
      _$SwapDtoFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final String customerName;
  @override
  @JsonKey()
  final int customerId;
  @override
  @JsonKey()
  final String stationName;
  @override
  @JsonKey()
  final int stationId;
  @override
  @JsonKey()
  final String oldBatteryCode;
  @override
  @JsonKey()
  final String newBatteryCode;
  @override
  @JsonKey()
  final double oldBatterySoc;
  @override
  @JsonKey()
  final double newBatterySoc;
  @override
  @JsonKey()
  final double swapAmount;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final String paymentStatus;
  @override
  final String createdAt;
  @override
  final String? completedAt;

  /// Create a copy of SwapDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SwapDtoCopyWith<_SwapDto> get copyWith =>
      __$SwapDtoCopyWithImpl<_SwapDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SwapDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SwapDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.stationName, stationName) ||
                other.stationName == stationName) &&
            (identical(other.stationId, stationId) ||
                other.stationId == stationId) &&
            (identical(other.oldBatteryCode, oldBatteryCode) ||
                other.oldBatteryCode == oldBatteryCode) &&
            (identical(other.newBatteryCode, newBatteryCode) ||
                other.newBatteryCode == newBatteryCode) &&
            (identical(other.oldBatterySoc, oldBatterySoc) ||
                other.oldBatterySoc == oldBatterySoc) &&
            (identical(other.newBatterySoc, newBatterySoc) ||
                other.newBatterySoc == newBatterySoc) &&
            (identical(other.swapAmount, swapAmount) ||
                other.swapAmount == swapAmount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      customerName,
      customerId,
      stationName,
      stationId,
      oldBatteryCode,
      newBatteryCode,
      oldBatterySoc,
      newBatterySoc,
      swapAmount,
      status,
      paymentStatus,
      createdAt,
      completedAt);

  @override
  String toString() {
    return 'SwapDto(id: $id, customerName: $customerName, customerId: $customerId, stationName: $stationName, stationId: $stationId, oldBatteryCode: $oldBatteryCode, newBatteryCode: $newBatteryCode, oldBatterySoc: $oldBatterySoc, newBatterySoc: $newBatterySoc, swapAmount: $swapAmount, status: $status, paymentStatus: $paymentStatus, createdAt: $createdAt, completedAt: $completedAt)';
  }
}

/// @nodoc
abstract mixin class _$SwapDtoCopyWith<$Res> implements $SwapDtoCopyWith<$Res> {
  factory _$SwapDtoCopyWith(_SwapDto value, $Res Function(_SwapDto) _then) =
      __$SwapDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String customerName,
      int customerId,
      String stationName,
      int stationId,
      String oldBatteryCode,
      String newBatteryCode,
      double oldBatterySoc,
      double newBatterySoc,
      double swapAmount,
      String status,
      String paymentStatus,
      String createdAt,
      String? completedAt});
}

/// @nodoc
class __$SwapDtoCopyWithImpl<$Res> implements _$SwapDtoCopyWith<$Res> {
  __$SwapDtoCopyWithImpl(this._self, this._then);

  final _SwapDto _self;
  final $Res Function(_SwapDto) _then;

  /// Create a copy of SwapDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? customerName = null,
    Object? customerId = null,
    Object? stationName = null,
    Object? stationId = null,
    Object? oldBatteryCode = null,
    Object? newBatteryCode = null,
    Object? oldBatterySoc = null,
    Object? newBatterySoc = null,
    Object? swapAmount = null,
    Object? status = null,
    Object? paymentStatus = null,
    Object? createdAt = null,
    Object? completedAt = freezed,
  }) {
    return _then(_SwapDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      customerName: null == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _self.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as int,
      stationName: null == stationName
          ? _self.stationName
          : stationName // ignore: cast_nullable_to_non_nullable
              as String,
      stationId: null == stationId
          ? _self.stationId
          : stationId // ignore: cast_nullable_to_non_nullable
              as int,
      oldBatteryCode: null == oldBatteryCode
          ? _self.oldBatteryCode
          : oldBatteryCode // ignore: cast_nullable_to_non_nullable
              as String,
      newBatteryCode: null == newBatteryCode
          ? _self.newBatteryCode
          : newBatteryCode // ignore: cast_nullable_to_non_nullable
              as String,
      oldBatterySoc: null == oldBatterySoc
          ? _self.oldBatterySoc
          : oldBatterySoc // ignore: cast_nullable_to_non_nullable
              as double,
      newBatterySoc: null == newBatterySoc
          ? _self.newBatterySoc
          : newBatterySoc // ignore: cast_nullable_to_non_nullable
              as double,
      swapAmount: null == swapAmount
          ? _self.swapAmount
          : swapAmount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      paymentStatus: null == paymentStatus
          ? _self.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      completedAt: freezed == completedAt
          ? _self.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
