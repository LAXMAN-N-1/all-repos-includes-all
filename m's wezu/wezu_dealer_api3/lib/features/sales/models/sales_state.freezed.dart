// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionDto {
  int get id;
  @JsonKey(name: 'transaction_type')
  String get transactionType;
  double get amount;
  String get status;
  @JsonKey(name: 'created_at')
  String get createdAt;
  String? get description; // Detailed fields for UI
  @JsonKey(name: 'customer_name')
  String? get customerName;
  @JsonKey(name: 'customer_phone')
  String? get customerPhone;
  @JsonKey(name: 'battery_id')
  String? get batteryId;
  @JsonKey(name: 'station_name')
  String? get stationName;
  @JsonKey(name: 'terminal_number')
  String? get terminalNumber;
  String? get duration;
  @JsonKey(name: 'platform_fee')
  double get platformFee;
  @JsonKey(name: 'commission_rate')
  double get commissionRate;
  @JsonKey(name: 'commission_amount')
  double get commissionAmount;
  @JsonKey(name: 'net_amount')
  double get netAmount;
  @JsonKey(name: 'payment_method')
  String? get paymentMethod;
  @JsonKey(name: 'settlement_status')
  String? get settlementStatus;
  @JsonKey(name: 'expected_settlement_date')
  String? get expectedSettlementDate;

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
            (identical(other.transactionType, transactionType) ||
                other.transactionType == transactionType) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.batteryId, batteryId) ||
                other.batteryId == batteryId) &&
            (identical(other.stationName, stationName) ||
                other.stationName == stationName) &&
            (identical(other.terminalNumber, terminalNumber) ||
                other.terminalNumber == terminalNumber) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.platformFee, platformFee) ||
                other.platformFee == platformFee) &&
            (identical(other.commissionRate, commissionRate) ||
                other.commissionRate == commissionRate) &&
            (identical(other.commissionAmount, commissionAmount) ||
                other.commissionAmount == commissionAmount) &&
            (identical(other.netAmount, netAmount) ||
                other.netAmount == netAmount) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.settlementStatus, settlementStatus) ||
                other.settlementStatus == settlementStatus) &&
            (identical(other.expectedSettlementDate, expectedSettlementDate) ||
                other.expectedSettlementDate == expectedSettlementDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        transactionType,
        amount,
        status,
        createdAt,
        description,
        customerName,
        customerPhone,
        batteryId,
        stationName,
        terminalNumber,
        duration,
        platformFee,
        commissionRate,
        commissionAmount,
        netAmount,
        paymentMethod,
        settlementStatus,
        expectedSettlementDate
      ]);

  @override
  String toString() {
    return 'TransactionDto(id: $id, transactionType: $transactionType, amount: $amount, status: $status, createdAt: $createdAt, description: $description, customerName: $customerName, customerPhone: $customerPhone, batteryId: $batteryId, stationName: $stationName, terminalNumber: $terminalNumber, duration: $duration, platformFee: $platformFee, commissionRate: $commissionRate, commissionAmount: $commissionAmount, netAmount: $netAmount, paymentMethod: $paymentMethod, settlementStatus: $settlementStatus, expectedSettlementDate: $expectedSettlementDate)';
  }
}

/// @nodoc
abstract mixin class $TransactionDtoCopyWith<$Res> {
  factory $TransactionDtoCopyWith(
          TransactionDto value, $Res Function(TransactionDto) _then) =
      _$TransactionDtoCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'transaction_type') String transactionType,
      double amount,
      String status,
      @JsonKey(name: 'created_at') String createdAt,
      String? description,
      @JsonKey(name: 'customer_name') String? customerName,
      @JsonKey(name: 'customer_phone') String? customerPhone,
      @JsonKey(name: 'battery_id') String? batteryId,
      @JsonKey(name: 'station_name') String? stationName,
      @JsonKey(name: 'terminal_number') String? terminalNumber,
      String? duration,
      @JsonKey(name: 'platform_fee') double platformFee,
      @JsonKey(name: 'commission_rate') double commissionRate,
      @JsonKey(name: 'commission_amount') double commissionAmount,
      @JsonKey(name: 'net_amount') double netAmount,
      @JsonKey(name: 'payment_method') String? paymentMethod,
      @JsonKey(name: 'settlement_status') String? settlementStatus,
      @JsonKey(name: 'expected_settlement_date')
      String? expectedSettlementDate});
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
    Object? transactionType = null,
    Object? amount = null,
    Object? status = null,
    Object? createdAt = null,
    Object? description = freezed,
    Object? customerName = freezed,
    Object? customerPhone = freezed,
    Object? batteryId = freezed,
    Object? stationName = freezed,
    Object? terminalNumber = freezed,
    Object? duration = freezed,
    Object? platformFee = null,
    Object? commissionRate = null,
    Object? commissionAmount = null,
    Object? netAmount = null,
    Object? paymentMethod = freezed,
    Object? settlementStatus = freezed,
    Object? expectedSettlementDate = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      transactionType: null == transactionType
          ? _self.transactionType
          : transactionType // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      customerName: freezed == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      customerPhone: freezed == customerPhone
          ? _self.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      batteryId: freezed == batteryId
          ? _self.batteryId
          : batteryId // ignore: cast_nullable_to_non_nullable
              as String?,
      stationName: freezed == stationName
          ? _self.stationName
          : stationName // ignore: cast_nullable_to_non_nullable
              as String?,
      terminalNumber: freezed == terminalNumber
          ? _self.terminalNumber
          : terminalNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _self.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String?,
      platformFee: null == platformFee
          ? _self.platformFee
          : platformFee // ignore: cast_nullable_to_non_nullable
              as double,
      commissionRate: null == commissionRate
          ? _self.commissionRate
          : commissionRate // ignore: cast_nullable_to_non_nullable
              as double,
      commissionAmount: null == commissionAmount
          ? _self.commissionAmount
          : commissionAmount // ignore: cast_nullable_to_non_nullable
              as double,
      netAmount: null == netAmount
          ? _self.netAmount
          : netAmount // ignore: cast_nullable_to_non_nullable
              as double,
      paymentMethod: freezed == paymentMethod
          ? _self.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String?,
      settlementStatus: freezed == settlementStatus
          ? _self.settlementStatus
          : settlementStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      expectedSettlementDate: freezed == expectedSettlementDate
          ? _self.expectedSettlementDate
          : expectedSettlementDate // ignore: cast_nullable_to_non_nullable
              as String?,
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
            int id,
            @JsonKey(name: 'transaction_type') String transactionType,
            double amount,
            String status,
            @JsonKey(name: 'created_at') String createdAt,
            String? description,
            @JsonKey(name: 'customer_name') String? customerName,
            @JsonKey(name: 'customer_phone') String? customerPhone,
            @JsonKey(name: 'battery_id') String? batteryId,
            @JsonKey(name: 'station_name') String? stationName,
            @JsonKey(name: 'terminal_number') String? terminalNumber,
            String? duration,
            @JsonKey(name: 'platform_fee') double platformFee,
            @JsonKey(name: 'commission_rate') double commissionRate,
            @JsonKey(name: 'commission_amount') double commissionAmount,
            @JsonKey(name: 'net_amount') double netAmount,
            @JsonKey(name: 'payment_method') String? paymentMethod,
            @JsonKey(name: 'settlement_status') String? settlementStatus,
            @JsonKey(name: 'expected_settlement_date')
            String? expectedSettlementDate)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TransactionDto() when $default != null:
        return $default(
            _that.id,
            _that.transactionType,
            _that.amount,
            _that.status,
            _that.createdAt,
            _that.description,
            _that.customerName,
            _that.customerPhone,
            _that.batteryId,
            _that.stationName,
            _that.terminalNumber,
            _that.duration,
            _that.platformFee,
            _that.commissionRate,
            _that.commissionAmount,
            _that.netAmount,
            _that.paymentMethod,
            _that.settlementStatus,
            _that.expectedSettlementDate);
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
            @JsonKey(name: 'transaction_type') String transactionType,
            double amount,
            String status,
            @JsonKey(name: 'created_at') String createdAt,
            String? description,
            @JsonKey(name: 'customer_name') String? customerName,
            @JsonKey(name: 'customer_phone') String? customerPhone,
            @JsonKey(name: 'battery_id') String? batteryId,
            @JsonKey(name: 'station_name') String? stationName,
            @JsonKey(name: 'terminal_number') String? terminalNumber,
            String? duration,
            @JsonKey(name: 'platform_fee') double platformFee,
            @JsonKey(name: 'commission_rate') double commissionRate,
            @JsonKey(name: 'commission_amount') double commissionAmount,
            @JsonKey(name: 'net_amount') double netAmount,
            @JsonKey(name: 'payment_method') String? paymentMethod,
            @JsonKey(name: 'settlement_status') String? settlementStatus,
            @JsonKey(name: 'expected_settlement_date')
            String? expectedSettlementDate)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TransactionDto():
        return $default(
            _that.id,
            _that.transactionType,
            _that.amount,
            _that.status,
            _that.createdAt,
            _that.description,
            _that.customerName,
            _that.customerPhone,
            _that.batteryId,
            _that.stationName,
            _that.terminalNumber,
            _that.duration,
            _that.platformFee,
            _that.commissionRate,
            _that.commissionAmount,
            _that.netAmount,
            _that.paymentMethod,
            _that.settlementStatus,
            _that.expectedSettlementDate);
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
            @JsonKey(name: 'transaction_type') String transactionType,
            double amount,
            String status,
            @JsonKey(name: 'created_at') String createdAt,
            String? description,
            @JsonKey(name: 'customer_name') String? customerName,
            @JsonKey(name: 'customer_phone') String? customerPhone,
            @JsonKey(name: 'battery_id') String? batteryId,
            @JsonKey(name: 'station_name') String? stationName,
            @JsonKey(name: 'terminal_number') String? terminalNumber,
            String? duration,
            @JsonKey(name: 'platform_fee') double platformFee,
            @JsonKey(name: 'commission_rate') double commissionRate,
            @JsonKey(name: 'commission_amount') double commissionAmount,
            @JsonKey(name: 'net_amount') double netAmount,
            @JsonKey(name: 'payment_method') String? paymentMethod,
            @JsonKey(name: 'settlement_status') String? settlementStatus,
            @JsonKey(name: 'expected_settlement_date')
            String? expectedSettlementDate)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TransactionDto() when $default != null:
        return $default(
            _that.id,
            _that.transactionType,
            _that.amount,
            _that.status,
            _that.createdAt,
            _that.description,
            _that.customerName,
            _that.customerPhone,
            _that.batteryId,
            _that.stationName,
            _that.terminalNumber,
            _that.duration,
            _that.platformFee,
            _that.commissionRate,
            _that.commissionAmount,
            _that.netAmount,
            _that.paymentMethod,
            _that.settlementStatus,
            _that.expectedSettlementDate);
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
      @JsonKey(name: 'transaction_type') required this.transactionType,
      required this.amount,
      required this.status,
      @JsonKey(name: 'created_at') required this.createdAt,
      this.description,
      @JsonKey(name: 'customer_name') this.customerName,
      @JsonKey(name: 'customer_phone') this.customerPhone,
      @JsonKey(name: 'battery_id') this.batteryId,
      @JsonKey(name: 'station_name') this.stationName,
      @JsonKey(name: 'terminal_number') this.terminalNumber,
      this.duration,
      @JsonKey(name: 'platform_fee') this.platformFee = 0.0,
      @JsonKey(name: 'commission_rate') this.commissionRate = 0.05,
      @JsonKey(name: 'commission_amount') this.commissionAmount = 0.0,
      @JsonKey(name: 'net_amount') this.netAmount = 0.0,
      @JsonKey(name: 'payment_method') this.paymentMethod,
      @JsonKey(name: 'settlement_status') this.settlementStatus,
      @JsonKey(name: 'expected_settlement_date') this.expectedSettlementDate});
  factory _TransactionDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionDtoFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'transaction_type')
  final String transactionType;
  @override
  final double amount;
  @override
  final String status;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;
  @override
  final String? description;
// Detailed fields for UI
  @override
  @JsonKey(name: 'customer_name')
  final String? customerName;
  @override
  @JsonKey(name: 'customer_phone')
  final String? customerPhone;
  @override
  @JsonKey(name: 'battery_id')
  final String? batteryId;
  @override
  @JsonKey(name: 'station_name')
  final String? stationName;
  @override
  @JsonKey(name: 'terminal_number')
  final String? terminalNumber;
  @override
  final String? duration;
  @override
  @JsonKey(name: 'platform_fee')
  final double platformFee;
  @override
  @JsonKey(name: 'commission_rate')
  final double commissionRate;
  @override
  @JsonKey(name: 'commission_amount')
  final double commissionAmount;
  @override
  @JsonKey(name: 'net_amount')
  final double netAmount;
  @override
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  @override
  @JsonKey(name: 'settlement_status')
  final String? settlementStatus;
  @override
  @JsonKey(name: 'expected_settlement_date')
  final String? expectedSettlementDate;

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
            (identical(other.transactionType, transactionType) ||
                other.transactionType == transactionType) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.batteryId, batteryId) ||
                other.batteryId == batteryId) &&
            (identical(other.stationName, stationName) ||
                other.stationName == stationName) &&
            (identical(other.terminalNumber, terminalNumber) ||
                other.terminalNumber == terminalNumber) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.platformFee, platformFee) ||
                other.platformFee == platformFee) &&
            (identical(other.commissionRate, commissionRate) ||
                other.commissionRate == commissionRate) &&
            (identical(other.commissionAmount, commissionAmount) ||
                other.commissionAmount == commissionAmount) &&
            (identical(other.netAmount, netAmount) ||
                other.netAmount == netAmount) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.settlementStatus, settlementStatus) ||
                other.settlementStatus == settlementStatus) &&
            (identical(other.expectedSettlementDate, expectedSettlementDate) ||
                other.expectedSettlementDate == expectedSettlementDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        transactionType,
        amount,
        status,
        createdAt,
        description,
        customerName,
        customerPhone,
        batteryId,
        stationName,
        terminalNumber,
        duration,
        platformFee,
        commissionRate,
        commissionAmount,
        netAmount,
        paymentMethod,
        settlementStatus,
        expectedSettlementDate
      ]);

  @override
  String toString() {
    return 'TransactionDto(id: $id, transactionType: $transactionType, amount: $amount, status: $status, createdAt: $createdAt, description: $description, customerName: $customerName, customerPhone: $customerPhone, batteryId: $batteryId, stationName: $stationName, terminalNumber: $terminalNumber, duration: $duration, platformFee: $platformFee, commissionRate: $commissionRate, commissionAmount: $commissionAmount, netAmount: $netAmount, paymentMethod: $paymentMethod, settlementStatus: $settlementStatus, expectedSettlementDate: $expectedSettlementDate)';
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
  $Res call(
      {int id,
      @JsonKey(name: 'transaction_type') String transactionType,
      double amount,
      String status,
      @JsonKey(name: 'created_at') String createdAt,
      String? description,
      @JsonKey(name: 'customer_name') String? customerName,
      @JsonKey(name: 'customer_phone') String? customerPhone,
      @JsonKey(name: 'battery_id') String? batteryId,
      @JsonKey(name: 'station_name') String? stationName,
      @JsonKey(name: 'terminal_number') String? terminalNumber,
      String? duration,
      @JsonKey(name: 'platform_fee') double platformFee,
      @JsonKey(name: 'commission_rate') double commissionRate,
      @JsonKey(name: 'commission_amount') double commissionAmount,
      @JsonKey(name: 'net_amount') double netAmount,
      @JsonKey(name: 'payment_method') String? paymentMethod,
      @JsonKey(name: 'settlement_status') String? settlementStatus,
      @JsonKey(name: 'expected_settlement_date')
      String? expectedSettlementDate});
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
    Object? transactionType = null,
    Object? amount = null,
    Object? status = null,
    Object? createdAt = null,
    Object? description = freezed,
    Object? customerName = freezed,
    Object? customerPhone = freezed,
    Object? batteryId = freezed,
    Object? stationName = freezed,
    Object? terminalNumber = freezed,
    Object? duration = freezed,
    Object? platformFee = null,
    Object? commissionRate = null,
    Object? commissionAmount = null,
    Object? netAmount = null,
    Object? paymentMethod = freezed,
    Object? settlementStatus = freezed,
    Object? expectedSettlementDate = freezed,
  }) {
    return _then(_TransactionDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      transactionType: null == transactionType
          ? _self.transactionType
          : transactionType // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      customerName: freezed == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      customerPhone: freezed == customerPhone
          ? _self.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      batteryId: freezed == batteryId
          ? _self.batteryId
          : batteryId // ignore: cast_nullable_to_non_nullable
              as String?,
      stationName: freezed == stationName
          ? _self.stationName
          : stationName // ignore: cast_nullable_to_non_nullable
              as String?,
      terminalNumber: freezed == terminalNumber
          ? _self.terminalNumber
          : terminalNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _self.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String?,
      platformFee: null == platformFee
          ? _self.platformFee
          : platformFee // ignore: cast_nullable_to_non_nullable
              as double,
      commissionRate: null == commissionRate
          ? _self.commissionRate
          : commissionRate // ignore: cast_nullable_to_non_nullable
              as double,
      commissionAmount: null == commissionAmount
          ? _self.commissionAmount
          : commissionAmount // ignore: cast_nullable_to_non_nullable
              as double,
      netAmount: null == netAmount
          ? _self.netAmount
          : netAmount // ignore: cast_nullable_to_non_nullable
              as double,
      paymentMethod: freezed == paymentMethod
          ? _self.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String?,
      settlementStatus: freezed == settlementStatus
          ? _self.settlementStatus
          : settlementStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      expectedSettlementDate: freezed == expectedSettlementDate
          ? _self.expectedSettlementDate
          : expectedSettlementDate // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$SalesState {
  bool get isLoading;
  String? get error;
  List<TransactionDto> get transactions;

  /// Create a copy of SalesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SalesStateCopyWith<SalesState> get copyWith =>
      _$SalesStateCopyWithImpl<SalesState>(this as SalesState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SalesState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality()
                .equals(other.transactions, transactions));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, error,
      const DeepCollectionEquality().hash(transactions));

  @override
  String toString() {
    return 'SalesState(isLoading: $isLoading, error: $error, transactions: $transactions)';
  }
}

/// @nodoc
abstract mixin class $SalesStateCopyWith<$Res> {
  factory $SalesStateCopyWith(
          SalesState value, $Res Function(SalesState) _then) =
      _$SalesStateCopyWithImpl;
  @useResult
  $Res call({bool isLoading, String? error, List<TransactionDto> transactions});
}

/// @nodoc
class _$SalesStateCopyWithImpl<$Res> implements $SalesStateCopyWith<$Res> {
  _$SalesStateCopyWithImpl(this._self, this._then);

  final SalesState _self;
  final $Res Function(SalesState) _then;

  /// Create a copy of SalesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? transactions = null,
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
      transactions: null == transactions
          ? _self.transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as List<TransactionDto>,
    ));
  }
}

/// Adds pattern-matching-related methods to [SalesState].
extension SalesStatePatterns on SalesState {
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
    TResult Function(_SalesState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SalesState() when $default != null:
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
    TResult Function(_SalesState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SalesState():
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
    TResult? Function(_SalesState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SalesState() when $default != null:
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
            bool isLoading, String? error, List<TransactionDto> transactions)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SalesState() when $default != null:
        return $default(_that.isLoading, _that.error, _that.transactions);
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
            bool isLoading, String? error, List<TransactionDto> transactions)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SalesState():
        return $default(_that.isLoading, _that.error, _that.transactions);
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
            bool isLoading, String? error, List<TransactionDto> transactions)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SalesState() when $default != null:
        return $default(_that.isLoading, _that.error, _that.transactions);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _SalesState implements SalesState {
  const _SalesState(
      {this.isLoading = true,
      this.error,
      final List<TransactionDto> transactions = const []})
      : _transactions = transactions;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  final List<TransactionDto> _transactions;
  @override
  @JsonKey()
  List<TransactionDto> get transactions {
    if (_transactions is EqualUnmodifiableListView) return _transactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transactions);
  }

  /// Create a copy of SalesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SalesStateCopyWith<_SalesState> get copyWith =>
      __$SalesStateCopyWithImpl<_SalesState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SalesState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality()
                .equals(other._transactions, _transactions));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, error,
      const DeepCollectionEquality().hash(_transactions));

  @override
  String toString() {
    return 'SalesState(isLoading: $isLoading, error: $error, transactions: $transactions)';
  }
}

/// @nodoc
abstract mixin class _$SalesStateCopyWith<$Res>
    implements $SalesStateCopyWith<$Res> {
  factory _$SalesStateCopyWith(
          _SalesState value, $Res Function(_SalesState) _then) =
      __$SalesStateCopyWithImpl;
  @override
  @useResult
  $Res call({bool isLoading, String? error, List<TransactionDto> transactions});
}

/// @nodoc
class __$SalesStateCopyWithImpl<$Res> implements _$SalesStateCopyWith<$Res> {
  __$SalesStateCopyWithImpl(this._self, this._then);

  final _SalesState _self;
  final $Res Function(_SalesState) _then;

  /// Create a copy of SalesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? transactions = null,
  }) {
    return _then(_SalesState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      transactions: null == transactions
          ? _self._transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as List<TransactionDto>,
    ));
  }
}

// dart format on
