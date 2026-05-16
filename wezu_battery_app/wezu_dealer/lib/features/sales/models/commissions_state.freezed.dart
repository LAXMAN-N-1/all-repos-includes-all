// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commissions_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommissionDto {
  int get id;
  double get amount;
  String get status;
  @JsonKey(name: 'created_at')
  String get createdAt;
  @JsonKey(name: 'station_name')
  String? get stationName;
  @JsonKey(name: 'transaction_type')
  String? get transactionType;
  String? get description;
  double get grossRevenue;
  double get platformFees;
  double get netPayout;
  double get rate;

  /// Create a copy of CommissionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CommissionDtoCopyWith<CommissionDto> get copyWith =>
      _$CommissionDtoCopyWithImpl<CommissionDto>(
          this as CommissionDto, _$identity);

  /// Serializes this CommissionDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CommissionDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.stationName, stationName) ||
                other.stationName == stationName) &&
            (identical(other.transactionType, transactionType) ||
                other.transactionType == transactionType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.grossRevenue, grossRevenue) ||
                other.grossRevenue == grossRevenue) &&
            (identical(other.platformFees, platformFees) ||
                other.platformFees == platformFees) &&
            (identical(other.netPayout, netPayout) ||
                other.netPayout == netPayout) &&
            (identical(other.rate, rate) || other.rate == rate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      amount,
      status,
      createdAt,
      stationName,
      transactionType,
      description,
      grossRevenue,
      platformFees,
      netPayout,
      rate);

  @override
  String toString() {
    return 'CommissionDto(id: $id, amount: $amount, status: $status, createdAt: $createdAt, stationName: $stationName, transactionType: $transactionType, description: $description, grossRevenue: $grossRevenue, platformFees: $platformFees, netPayout: $netPayout, rate: $rate)';
  }
}

/// @nodoc
abstract mixin class $CommissionDtoCopyWith<$Res> {
  factory $CommissionDtoCopyWith(
          CommissionDto value, $Res Function(CommissionDto) _then) =
      _$CommissionDtoCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      double amount,
      String status,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'station_name') String? stationName,
      @JsonKey(name: 'transaction_type') String? transactionType,
      String? description,
      double grossRevenue,
      double platformFees,
      double netPayout,
      double rate});
}

/// @nodoc
class _$CommissionDtoCopyWithImpl<$Res>
    implements $CommissionDtoCopyWith<$Res> {
  _$CommissionDtoCopyWithImpl(this._self, this._then);

  final CommissionDto _self;
  final $Res Function(CommissionDto) _then;

  /// Create a copy of CommissionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? status = null,
    Object? createdAt = null,
    Object? stationName = freezed,
    Object? transactionType = freezed,
    Object? description = freezed,
    Object? grossRevenue = null,
    Object? platformFees = null,
    Object? netPayout = null,
    Object? rate = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
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
      stationName: freezed == stationName
          ? _self.stationName
          : stationName // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionType: freezed == transactionType
          ? _self.transactionType
          : transactionType // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      grossRevenue: null == grossRevenue
          ? _self.grossRevenue
          : grossRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      platformFees: null == platformFees
          ? _self.platformFees
          : platformFees // ignore: cast_nullable_to_non_nullable
              as double,
      netPayout: null == netPayout
          ? _self.netPayout
          : netPayout // ignore: cast_nullable_to_non_nullable
              as double,
      rate: null == rate
          ? _self.rate
          : rate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [CommissionDto].
extension CommissionDtoPatterns on CommissionDto {
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
    TResult Function(_CommissionDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CommissionDto() when $default != null:
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
    TResult Function(_CommissionDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommissionDto():
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
    TResult? Function(_CommissionDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommissionDto() when $default != null:
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
            double amount,
            String status,
            @JsonKey(name: 'created_at') String createdAt,
            @JsonKey(name: 'station_name') String? stationName,
            @JsonKey(name: 'transaction_type') String? transactionType,
            String? description,
            double grossRevenue,
            double platformFees,
            double netPayout,
            double rate)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CommissionDto() when $default != null:
        return $default(
            _that.id,
            _that.amount,
            _that.status,
            _that.createdAt,
            _that.stationName,
            _that.transactionType,
            _that.description,
            _that.grossRevenue,
            _that.platformFees,
            _that.netPayout,
            _that.rate);
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
            double amount,
            String status,
            @JsonKey(name: 'created_at') String createdAt,
            @JsonKey(name: 'station_name') String? stationName,
            @JsonKey(name: 'transaction_type') String? transactionType,
            String? description,
            double grossRevenue,
            double platformFees,
            double netPayout,
            double rate)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommissionDto():
        return $default(
            _that.id,
            _that.amount,
            _that.status,
            _that.createdAt,
            _that.stationName,
            _that.transactionType,
            _that.description,
            _that.grossRevenue,
            _that.platformFees,
            _that.netPayout,
            _that.rate);
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
            double amount,
            String status,
            @JsonKey(name: 'created_at') String createdAt,
            @JsonKey(name: 'station_name') String? stationName,
            @JsonKey(name: 'transaction_type') String? transactionType,
            String? description,
            double grossRevenue,
            double platformFees,
            double netPayout,
            double rate)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommissionDto() when $default != null:
        return $default(
            _that.id,
            _that.amount,
            _that.status,
            _that.createdAt,
            _that.stationName,
            _that.transactionType,
            _that.description,
            _that.grossRevenue,
            _that.platformFees,
            _that.netPayout,
            _that.rate);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CommissionDto implements CommissionDto {
  const _CommissionDto(
      {required this.id,
      required this.amount,
      required this.status,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'station_name') this.stationName,
      @JsonKey(name: 'transaction_type') this.transactionType,
      this.description,
      this.grossRevenue = 0.0,
      this.platformFees = 0.0,
      this.netPayout = 0.0,
      this.rate = 0.05});
  factory _CommissionDto.fromJson(Map<String, dynamic> json) =>
      _$CommissionDtoFromJson(json);

  @override
  final int id;
  @override
  final double amount;
  @override
  final String status;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;
  @override
  @JsonKey(name: 'station_name')
  final String? stationName;
  @override
  @JsonKey(name: 'transaction_type')
  final String? transactionType;
  @override
  final String? description;
  @override
  @JsonKey()
  final double grossRevenue;
  @override
  @JsonKey()
  final double platformFees;
  @override
  @JsonKey()
  final double netPayout;
  @override
  @JsonKey()
  final double rate;

  /// Create a copy of CommissionDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CommissionDtoCopyWith<_CommissionDto> get copyWith =>
      __$CommissionDtoCopyWithImpl<_CommissionDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CommissionDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CommissionDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.stationName, stationName) ||
                other.stationName == stationName) &&
            (identical(other.transactionType, transactionType) ||
                other.transactionType == transactionType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.grossRevenue, grossRevenue) ||
                other.grossRevenue == grossRevenue) &&
            (identical(other.platformFees, platformFees) ||
                other.platformFees == platformFees) &&
            (identical(other.netPayout, netPayout) ||
                other.netPayout == netPayout) &&
            (identical(other.rate, rate) || other.rate == rate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      amount,
      status,
      createdAt,
      stationName,
      transactionType,
      description,
      grossRevenue,
      platformFees,
      netPayout,
      rate);

  @override
  String toString() {
    return 'CommissionDto(id: $id, amount: $amount, status: $status, createdAt: $createdAt, stationName: $stationName, transactionType: $transactionType, description: $description, grossRevenue: $grossRevenue, platformFees: $platformFees, netPayout: $netPayout, rate: $rate)';
  }
}

/// @nodoc
abstract mixin class _$CommissionDtoCopyWith<$Res>
    implements $CommissionDtoCopyWith<$Res> {
  factory _$CommissionDtoCopyWith(
          _CommissionDto value, $Res Function(_CommissionDto) _then) =
      __$CommissionDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      double amount,
      String status,
      @JsonKey(name: 'created_at') String createdAt,
      @JsonKey(name: 'station_name') String? stationName,
      @JsonKey(name: 'transaction_type') String? transactionType,
      String? description,
      double grossRevenue,
      double platformFees,
      double netPayout,
      double rate});
}

/// @nodoc
class __$CommissionDtoCopyWithImpl<$Res>
    implements _$CommissionDtoCopyWith<$Res> {
  __$CommissionDtoCopyWithImpl(this._self, this._then);

  final _CommissionDto _self;
  final $Res Function(_CommissionDto) _then;

  /// Create a copy of CommissionDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? status = null,
    Object? createdAt = null,
    Object? stationName = freezed,
    Object? transactionType = freezed,
    Object? description = freezed,
    Object? grossRevenue = null,
    Object? platformFees = null,
    Object? netPayout = null,
    Object? rate = null,
  }) {
    return _then(_CommissionDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
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
      stationName: freezed == stationName
          ? _self.stationName
          : stationName // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionType: freezed == transactionType
          ? _self.transactionType
          : transactionType // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      grossRevenue: null == grossRevenue
          ? _self.grossRevenue
          : grossRevenue // ignore: cast_nullable_to_non_nullable
              as double,
      platformFees: null == platformFees
          ? _self.platformFees
          : platformFees // ignore: cast_nullable_to_non_nullable
              as double,
      netPayout: null == netPayout
          ? _self.netPayout
          : netPayout // ignore: cast_nullable_to_non_nullable
              as double,
      rate: null == rate
          ? _self.rate
          : rate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
mixin _$PayoutDto {
  int get id;
  double get amount;
  String get status;
  String get date;
  String? get bankName;
  String? get accountMask;
  String? get ifsc;
  bool? get isVerified;

  /// Create a copy of PayoutDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PayoutDtoCopyWith<PayoutDto> get copyWith =>
      _$PayoutDtoCopyWithImpl<PayoutDto>(this as PayoutDto, _$identity);

  /// Serializes this PayoutDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PayoutDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.bankName, bankName) ||
                other.bankName == bankName) &&
            (identical(other.accountMask, accountMask) ||
                other.accountMask == accountMask) &&
            (identical(other.ifsc, ifsc) || other.ifsc == ifsc) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, amount, status, date,
      bankName, accountMask, ifsc, isVerified);

  @override
  String toString() {
    return 'PayoutDto(id: $id, amount: $amount, status: $status, date: $date, bankName: $bankName, accountMask: $accountMask, ifsc: $ifsc, isVerified: $isVerified)';
  }
}

/// @nodoc
abstract mixin class $PayoutDtoCopyWith<$Res> {
  factory $PayoutDtoCopyWith(PayoutDto value, $Res Function(PayoutDto) _then) =
      _$PayoutDtoCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      double amount,
      String status,
      String date,
      String? bankName,
      String? accountMask,
      String? ifsc,
      bool? isVerified});
}

/// @nodoc
class _$PayoutDtoCopyWithImpl<$Res> implements $PayoutDtoCopyWith<$Res> {
  _$PayoutDtoCopyWithImpl(this._self, this._then);

  final PayoutDto _self;
  final $Res Function(PayoutDto) _then;

  /// Create a copy of PayoutDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? status = null,
    Object? date = null,
    Object? bankName = freezed,
    Object? accountMask = freezed,
    Object? ifsc = freezed,
    Object? isVerified = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      bankName: freezed == bankName
          ? _self.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String?,
      accountMask: freezed == accountMask
          ? _self.accountMask
          : accountMask // ignore: cast_nullable_to_non_nullable
              as String?,
      ifsc: freezed == ifsc
          ? _self.ifsc
          : ifsc // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerified: freezed == isVerified
          ? _self.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// Adds pattern-matching-related methods to [PayoutDto].
extension PayoutDtoPatterns on PayoutDto {
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
    TResult Function(_PayoutDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PayoutDto() when $default != null:
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
    TResult Function(_PayoutDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PayoutDto():
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
    TResult? Function(_PayoutDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PayoutDto() when $default != null:
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
            double amount,
            String status,
            String date,
            String? bankName,
            String? accountMask,
            String? ifsc,
            bool? isVerified)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PayoutDto() when $default != null:
        return $default(_that.id, _that.amount, _that.status, _that.date,
            _that.bankName, _that.accountMask, _that.ifsc, _that.isVerified);
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
            double amount,
            String status,
            String date,
            String? bankName,
            String? accountMask,
            String? ifsc,
            bool? isVerified)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PayoutDto():
        return $default(_that.id, _that.amount, _that.status, _that.date,
            _that.bankName, _that.accountMask, _that.ifsc, _that.isVerified);
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
            double amount,
            String status,
            String date,
            String? bankName,
            String? accountMask,
            String? ifsc,
            bool? isVerified)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PayoutDto() when $default != null:
        return $default(_that.id, _that.amount, _that.status, _that.date,
            _that.bankName, _that.accountMask, _that.ifsc, _that.isVerified);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PayoutDto implements PayoutDto {
  const _PayoutDto(
      {required this.id,
      required this.amount,
      required this.status,
      required this.date,
      this.bankName,
      this.accountMask,
      this.ifsc,
      this.isVerified});
  factory _PayoutDto.fromJson(Map<String, dynamic> json) =>
      _$PayoutDtoFromJson(json);

  @override
  final int id;
  @override
  final double amount;
  @override
  final String status;
  @override
  final String date;
  @override
  final String? bankName;
  @override
  final String? accountMask;
  @override
  final String? ifsc;
  @override
  final bool? isVerified;

  /// Create a copy of PayoutDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PayoutDtoCopyWith<_PayoutDto> get copyWith =>
      __$PayoutDtoCopyWithImpl<_PayoutDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PayoutDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PayoutDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.bankName, bankName) ||
                other.bankName == bankName) &&
            (identical(other.accountMask, accountMask) ||
                other.accountMask == accountMask) &&
            (identical(other.ifsc, ifsc) || other.ifsc == ifsc) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, amount, status, date,
      bankName, accountMask, ifsc, isVerified);

  @override
  String toString() {
    return 'PayoutDto(id: $id, amount: $amount, status: $status, date: $date, bankName: $bankName, accountMask: $accountMask, ifsc: $ifsc, isVerified: $isVerified)';
  }
}

/// @nodoc
abstract mixin class _$PayoutDtoCopyWith<$Res>
    implements $PayoutDtoCopyWith<$Res> {
  factory _$PayoutDtoCopyWith(
          _PayoutDto value, $Res Function(_PayoutDto) _then) =
      __$PayoutDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      double amount,
      String status,
      String date,
      String? bankName,
      String? accountMask,
      String? ifsc,
      bool? isVerified});
}

/// @nodoc
class __$PayoutDtoCopyWithImpl<$Res> implements _$PayoutDtoCopyWith<$Res> {
  __$PayoutDtoCopyWithImpl(this._self, this._then);

  final _PayoutDto _self;
  final $Res Function(_PayoutDto) _then;

  /// Create a copy of PayoutDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? status = null,
    Object? date = null,
    Object? bankName = freezed,
    Object? accountMask = freezed,
    Object? ifsc = freezed,
    Object? isVerified = freezed,
  }) {
    return _then(_PayoutDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      bankName: freezed == bankName
          ? _self.bankName
          : bankName // ignore: cast_nullable_to_non_nullable
              as String?,
      accountMask: freezed == accountMask
          ? _self.accountMask
          : accountMask // ignore: cast_nullable_to_non_nullable
              as String?,
      ifsc: freezed == ifsc
          ? _self.ifsc
          : ifsc // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerified: freezed == isVerified
          ? _self.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
mixin _$CommissionSummaryDto {
  double get totalEarnings;
  double get pendingPayouts;
  double get totalCommissionEarned;
  @JsonKey(name: 'current_commission_rate')
  double get currentCommissionRate;
  Map<String, dynamic> get revenueSplit;
  Map<String, dynamic> get financialSummary;

  /// Create a copy of CommissionSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CommissionSummaryDtoCopyWith<CommissionSummaryDto> get copyWith =>
      _$CommissionSummaryDtoCopyWithImpl<CommissionSummaryDto>(
          this as CommissionSummaryDto, _$identity);

  /// Serializes this CommissionSummaryDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CommissionSummaryDto &&
            (identical(other.totalEarnings, totalEarnings) ||
                other.totalEarnings == totalEarnings) &&
            (identical(other.pendingPayouts, pendingPayouts) ||
                other.pendingPayouts == pendingPayouts) &&
            (identical(other.totalCommissionEarned, totalCommissionEarned) ||
                other.totalCommissionEarned == totalCommissionEarned) &&
            (identical(other.currentCommissionRate, currentCommissionRate) ||
                other.currentCommissionRate == currentCommissionRate) &&
            const DeepCollectionEquality()
                .equals(other.revenueSplit, revenueSplit) &&
            const DeepCollectionEquality()
                .equals(other.financialSummary, financialSummary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalEarnings,
      pendingPayouts,
      totalCommissionEarned,
      currentCommissionRate,
      const DeepCollectionEquality().hash(revenueSplit),
      const DeepCollectionEquality().hash(financialSummary));

  @override
  String toString() {
    return 'CommissionSummaryDto(totalEarnings: $totalEarnings, pendingPayouts: $pendingPayouts, totalCommissionEarned: $totalCommissionEarned, currentCommissionRate: $currentCommissionRate, revenueSplit: $revenueSplit, financialSummary: $financialSummary)';
  }
}

/// @nodoc
abstract mixin class $CommissionSummaryDtoCopyWith<$Res> {
  factory $CommissionSummaryDtoCopyWith(CommissionSummaryDto value,
          $Res Function(CommissionSummaryDto) _then) =
      _$CommissionSummaryDtoCopyWithImpl;
  @useResult
  $Res call(
      {double totalEarnings,
      double pendingPayouts,
      double totalCommissionEarned,
      @JsonKey(name: 'current_commission_rate') double currentCommissionRate,
      Map<String, dynamic> revenueSplit,
      Map<String, dynamic> financialSummary});
}

/// @nodoc
class _$CommissionSummaryDtoCopyWithImpl<$Res>
    implements $CommissionSummaryDtoCopyWith<$Res> {
  _$CommissionSummaryDtoCopyWithImpl(this._self, this._then);

  final CommissionSummaryDto _self;
  final $Res Function(CommissionSummaryDto) _then;

  /// Create a copy of CommissionSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalEarnings = null,
    Object? pendingPayouts = null,
    Object? totalCommissionEarned = null,
    Object? currentCommissionRate = null,
    Object? revenueSplit = null,
    Object? financialSummary = null,
  }) {
    return _then(_self.copyWith(
      totalEarnings: null == totalEarnings
          ? _self.totalEarnings
          : totalEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      pendingPayouts: null == pendingPayouts
          ? _self.pendingPayouts
          : pendingPayouts // ignore: cast_nullable_to_non_nullable
              as double,
      totalCommissionEarned: null == totalCommissionEarned
          ? _self.totalCommissionEarned
          : totalCommissionEarned // ignore: cast_nullable_to_non_nullable
              as double,
      currentCommissionRate: null == currentCommissionRate
          ? _self.currentCommissionRate
          : currentCommissionRate // ignore: cast_nullable_to_non_nullable
              as double,
      revenueSplit: null == revenueSplit
          ? _self.revenueSplit
          : revenueSplit // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      financialSummary: null == financialSummary
          ? _self.financialSummary
          : financialSummary // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// Adds pattern-matching-related methods to [CommissionSummaryDto].
extension CommissionSummaryDtoPatterns on CommissionSummaryDto {
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
    TResult Function(_CommissionSummaryDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CommissionSummaryDto() when $default != null:
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
    TResult Function(_CommissionSummaryDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommissionSummaryDto():
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
    TResult? Function(_CommissionSummaryDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommissionSummaryDto() when $default != null:
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
            double totalEarnings,
            double pendingPayouts,
            double totalCommissionEarned,
            @JsonKey(name: 'current_commission_rate')
            double currentCommissionRate,
            Map<String, dynamic> revenueSplit,
            Map<String, dynamic> financialSummary)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CommissionSummaryDto() when $default != null:
        return $default(
            _that.totalEarnings,
            _that.pendingPayouts,
            _that.totalCommissionEarned,
            _that.currentCommissionRate,
            _that.revenueSplit,
            _that.financialSummary);
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
            double totalEarnings,
            double pendingPayouts,
            double totalCommissionEarned,
            @JsonKey(name: 'current_commission_rate')
            double currentCommissionRate,
            Map<String, dynamic> revenueSplit,
            Map<String, dynamic> financialSummary)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommissionSummaryDto():
        return $default(
            _that.totalEarnings,
            _that.pendingPayouts,
            _that.totalCommissionEarned,
            _that.currentCommissionRate,
            _that.revenueSplit,
            _that.financialSummary);
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
            double totalEarnings,
            double pendingPayouts,
            double totalCommissionEarned,
            @JsonKey(name: 'current_commission_rate')
            double currentCommissionRate,
            Map<String, dynamic> revenueSplit,
            Map<String, dynamic> financialSummary)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommissionSummaryDto() when $default != null:
        return $default(
            _that.totalEarnings,
            _that.pendingPayouts,
            _that.totalCommissionEarned,
            _that.currentCommissionRate,
            _that.revenueSplit,
            _that.financialSummary);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CommissionSummaryDto implements CommissionSummaryDto {
  const _CommissionSummaryDto(
      {this.totalEarnings = 0.0,
      this.pendingPayouts = 0.0,
      this.totalCommissionEarned = 0.0,
      @JsonKey(name: 'current_commission_rate')
      this.currentCommissionRate = 0.0,
      final Map<String, dynamic> revenueSplit = const {},
      final Map<String, dynamic> financialSummary = const {}})
      : _revenueSplit = revenueSplit,
        _financialSummary = financialSummary;
  factory _CommissionSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$CommissionSummaryDtoFromJson(json);

  @override
  @JsonKey()
  final double totalEarnings;
  @override
  @JsonKey()
  final double pendingPayouts;
  @override
  @JsonKey()
  final double totalCommissionEarned;
  @override
  @JsonKey(name: 'current_commission_rate')
  final double currentCommissionRate;
  final Map<String, dynamic> _revenueSplit;
  @override
  @JsonKey()
  Map<String, dynamic> get revenueSplit {
    if (_revenueSplit is EqualUnmodifiableMapView) return _revenueSplit;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_revenueSplit);
  }

  final Map<String, dynamic> _financialSummary;
  @override
  @JsonKey()
  Map<String, dynamic> get financialSummary {
    if (_financialSummary is EqualUnmodifiableMapView) return _financialSummary;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_financialSummary);
  }

  /// Create a copy of CommissionSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CommissionSummaryDtoCopyWith<_CommissionSummaryDto> get copyWith =>
      __$CommissionSummaryDtoCopyWithImpl<_CommissionSummaryDto>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CommissionSummaryDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CommissionSummaryDto &&
            (identical(other.totalEarnings, totalEarnings) ||
                other.totalEarnings == totalEarnings) &&
            (identical(other.pendingPayouts, pendingPayouts) ||
                other.pendingPayouts == pendingPayouts) &&
            (identical(other.totalCommissionEarned, totalCommissionEarned) ||
                other.totalCommissionEarned == totalCommissionEarned) &&
            (identical(other.currentCommissionRate, currentCommissionRate) ||
                other.currentCommissionRate == currentCommissionRate) &&
            const DeepCollectionEquality()
                .equals(other._revenueSplit, _revenueSplit) &&
            const DeepCollectionEquality()
                .equals(other._financialSummary, _financialSummary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalEarnings,
      pendingPayouts,
      totalCommissionEarned,
      currentCommissionRate,
      const DeepCollectionEquality().hash(_revenueSplit),
      const DeepCollectionEquality().hash(_financialSummary));

  @override
  String toString() {
    return 'CommissionSummaryDto(totalEarnings: $totalEarnings, pendingPayouts: $pendingPayouts, totalCommissionEarned: $totalCommissionEarned, currentCommissionRate: $currentCommissionRate, revenueSplit: $revenueSplit, financialSummary: $financialSummary)';
  }
}

/// @nodoc
abstract mixin class _$CommissionSummaryDtoCopyWith<$Res>
    implements $CommissionSummaryDtoCopyWith<$Res> {
  factory _$CommissionSummaryDtoCopyWith(_CommissionSummaryDto value,
          $Res Function(_CommissionSummaryDto) _then) =
      __$CommissionSummaryDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double totalEarnings,
      double pendingPayouts,
      double totalCommissionEarned,
      @JsonKey(name: 'current_commission_rate') double currentCommissionRate,
      Map<String, dynamic> revenueSplit,
      Map<String, dynamic> financialSummary});
}

/// @nodoc
class __$CommissionSummaryDtoCopyWithImpl<$Res>
    implements _$CommissionSummaryDtoCopyWith<$Res> {
  __$CommissionSummaryDtoCopyWithImpl(this._self, this._then);

  final _CommissionSummaryDto _self;
  final $Res Function(_CommissionSummaryDto) _then;

  /// Create a copy of CommissionSummaryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? totalEarnings = null,
    Object? pendingPayouts = null,
    Object? totalCommissionEarned = null,
    Object? currentCommissionRate = null,
    Object? revenueSplit = null,
    Object? financialSummary = null,
  }) {
    return _then(_CommissionSummaryDto(
      totalEarnings: null == totalEarnings
          ? _self.totalEarnings
          : totalEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      pendingPayouts: null == pendingPayouts
          ? _self.pendingPayouts
          : pendingPayouts // ignore: cast_nullable_to_non_nullable
              as double,
      totalCommissionEarned: null == totalCommissionEarned
          ? _self.totalCommissionEarned
          : totalCommissionEarned // ignore: cast_nullable_to_non_nullable
              as double,
      currentCommissionRate: null == currentCommissionRate
          ? _self.currentCommissionRate
          : currentCommissionRate // ignore: cast_nullable_to_non_nullable
              as double,
      revenueSplit: null == revenueSplit
          ? _self._revenueSplit
          : revenueSplit // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      financialSummary: null == financialSummary
          ? _self._financialSummary
          : financialSummary // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
mixin _$CommissionsState {
  bool get isLoading;
  String? get error;
  List<CommissionDto> get commissions;
  List<PayoutDto> get payouts;
  int get total;
  CommissionSummaryDto? get summary;

  /// Create a copy of CommissionsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CommissionsStateCopyWith<CommissionsState> get copyWith =>
      _$CommissionsStateCopyWithImpl<CommissionsState>(
          this as CommissionsState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CommissionsState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality()
                .equals(other.commissions, commissions) &&
            const DeepCollectionEquality().equals(other.payouts, payouts) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.summary, summary) || other.summary == summary));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      error,
      const DeepCollectionEquality().hash(commissions),
      const DeepCollectionEquality().hash(payouts),
      total,
      summary);

  @override
  String toString() {
    return 'CommissionsState(isLoading: $isLoading, error: $error, commissions: $commissions, payouts: $payouts, total: $total, summary: $summary)';
  }
}

/// @nodoc
abstract mixin class $CommissionsStateCopyWith<$Res> {
  factory $CommissionsStateCopyWith(
          CommissionsState value, $Res Function(CommissionsState) _then) =
      _$CommissionsStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isLoading,
      String? error,
      List<CommissionDto> commissions,
      List<PayoutDto> payouts,
      int total,
      CommissionSummaryDto? summary});

  $CommissionSummaryDtoCopyWith<$Res>? get summary;
}

/// @nodoc
class _$CommissionsStateCopyWithImpl<$Res>
    implements $CommissionsStateCopyWith<$Res> {
  _$CommissionsStateCopyWithImpl(this._self, this._then);

  final CommissionsState _self;
  final $Res Function(CommissionsState) _then;

  /// Create a copy of CommissionsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? commissions = null,
    Object? payouts = null,
    Object? total = null,
    Object? summary = freezed,
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
      commissions: null == commissions
          ? _self.commissions
          : commissions // ignore: cast_nullable_to_non_nullable
              as List<CommissionDto>,
      payouts: null == payouts
          ? _self.payouts
          : payouts // ignore: cast_nullable_to_non_nullable
              as List<PayoutDto>,
      total: null == total
          ? _self.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      summary: freezed == summary
          ? _self.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as CommissionSummaryDto?,
    ));
  }

  /// Create a copy of CommissionsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CommissionSummaryDtoCopyWith<$Res>? get summary {
    if (_self.summary == null) {
      return null;
    }

    return $CommissionSummaryDtoCopyWith<$Res>(_self.summary!, (value) {
      return _then(_self.copyWith(summary: value));
    });
  }
}

/// Adds pattern-matching-related methods to [CommissionsState].
extension CommissionsStatePatterns on CommissionsState {
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
    TResult Function(_CommissionsState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CommissionsState() when $default != null:
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
    TResult Function(_CommissionsState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommissionsState():
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
    TResult? Function(_CommissionsState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommissionsState() when $default != null:
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
            bool isLoading,
            String? error,
            List<CommissionDto> commissions,
            List<PayoutDto> payouts,
            int total,
            CommissionSummaryDto? summary)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CommissionsState() when $default != null:
        return $default(_that.isLoading, _that.error, _that.commissions,
            _that.payouts, _that.total, _that.summary);
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
            bool isLoading,
            String? error,
            List<CommissionDto> commissions,
            List<PayoutDto> payouts,
            int total,
            CommissionSummaryDto? summary)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommissionsState():
        return $default(_that.isLoading, _that.error, _that.commissions,
            _that.payouts, _that.total, _that.summary);
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
            bool isLoading,
            String? error,
            List<CommissionDto> commissions,
            List<PayoutDto> payouts,
            int total,
            CommissionSummaryDto? summary)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CommissionsState() when $default != null:
        return $default(_that.isLoading, _that.error, _that.commissions,
            _that.payouts, _that.total, _that.summary);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CommissionsState implements CommissionsState {
  const _CommissionsState(
      {this.isLoading = true,
      this.error,
      final List<CommissionDto> commissions = const [],
      final List<PayoutDto> payouts = const [],
      this.total = 0,
      this.summary})
      : _commissions = commissions,
        _payouts = payouts;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  final List<CommissionDto> _commissions;
  @override
  @JsonKey()
  List<CommissionDto> get commissions {
    if (_commissions is EqualUnmodifiableListView) return _commissions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_commissions);
  }

  final List<PayoutDto> _payouts;
  @override
  @JsonKey()
  List<PayoutDto> get payouts {
    if (_payouts is EqualUnmodifiableListView) return _payouts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_payouts);
  }

  @override
  @JsonKey()
  final int total;
  @override
  final CommissionSummaryDto? summary;

  /// Create a copy of CommissionsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CommissionsStateCopyWith<_CommissionsState> get copyWith =>
      __$CommissionsStateCopyWithImpl<_CommissionsState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CommissionsState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality()
                .equals(other._commissions, _commissions) &&
            const DeepCollectionEquality().equals(other._payouts, _payouts) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.summary, summary) || other.summary == summary));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      error,
      const DeepCollectionEquality().hash(_commissions),
      const DeepCollectionEquality().hash(_payouts),
      total,
      summary);

  @override
  String toString() {
    return 'CommissionsState(isLoading: $isLoading, error: $error, commissions: $commissions, payouts: $payouts, total: $total, summary: $summary)';
  }
}

/// @nodoc
abstract mixin class _$CommissionsStateCopyWith<$Res>
    implements $CommissionsStateCopyWith<$Res> {
  factory _$CommissionsStateCopyWith(
          _CommissionsState value, $Res Function(_CommissionsState) _then) =
      __$CommissionsStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      String? error,
      List<CommissionDto> commissions,
      List<PayoutDto> payouts,
      int total,
      CommissionSummaryDto? summary});

  @override
  $CommissionSummaryDtoCopyWith<$Res>? get summary;
}

/// @nodoc
class __$CommissionsStateCopyWithImpl<$Res>
    implements _$CommissionsStateCopyWith<$Res> {
  __$CommissionsStateCopyWithImpl(this._self, this._then);

  final _CommissionsState _self;
  final $Res Function(_CommissionsState) _then;

  /// Create a copy of CommissionsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? commissions = null,
    Object? payouts = null,
    Object? total = null,
    Object? summary = freezed,
  }) {
    return _then(_CommissionsState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      commissions: null == commissions
          ? _self._commissions
          : commissions // ignore: cast_nullable_to_non_nullable
              as List<CommissionDto>,
      payouts: null == payouts
          ? _self._payouts
          : payouts // ignore: cast_nullable_to_non_nullable
              as List<PayoutDto>,
      total: null == total
          ? _self.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      summary: freezed == summary
          ? _self.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as CommissionSummaryDto?,
    ));
  }

  /// Create a copy of CommissionsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CommissionSummaryDtoCopyWith<$Res>? get summary {
    if (_self.summary == null) {
      return null;
    }

    return $CommissionSummaryDtoCopyWith<$Res>(_self.summary!, (value) {
      return _then(_self.copyWith(summary: value));
    });
  }
}

// dart format on
