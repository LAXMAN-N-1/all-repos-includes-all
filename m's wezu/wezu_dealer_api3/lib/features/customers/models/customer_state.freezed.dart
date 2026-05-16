// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CustomerDto {
  int get id;
  String get name;
  String get email;
  String get phone;
  int get totalRentals;
  String get status;
  String? get joinedAt;

  /// Create a copy of CustomerDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CustomerDtoCopyWith<CustomerDto> get copyWith =>
      _$CustomerDtoCopyWithImpl<CustomerDto>(this as CustomerDto, _$identity);

  /// Serializes this CustomerDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CustomerDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.totalRentals, totalRentals) ||
                other.totalRentals == totalRentals) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, email, phone, totalRentals, status, joinedAt);

  @override
  String toString() {
    return 'CustomerDto(id: $id, name: $name, email: $email, phone: $phone, totalRentals: $totalRentals, status: $status, joinedAt: $joinedAt)';
  }
}

/// @nodoc
abstract mixin class $CustomerDtoCopyWith<$Res> {
  factory $CustomerDtoCopyWith(
          CustomerDto value, $Res Function(CustomerDto) _then) =
      _$CustomerDtoCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String name,
      String email,
      String phone,
      int totalRentals,
      String status,
      String? joinedAt});
}

/// @nodoc
class _$CustomerDtoCopyWithImpl<$Res> implements $CustomerDtoCopyWith<$Res> {
  _$CustomerDtoCopyWithImpl(this._self, this._then);

  final CustomerDto _self;
  final $Res Function(CustomerDto) _then;

  /// Create a copy of CustomerDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? phone = null,
    Object? totalRentals = null,
    Object? status = null,
    Object? joinedAt = freezed,
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
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      totalRentals: null == totalRentals
          ? _self.totalRentals
          : totalRentals // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      joinedAt: freezed == joinedAt
          ? _self.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [CustomerDto].
extension CustomerDtoPatterns on CustomerDto {
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
    TResult Function(_CustomerDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CustomerDto() when $default != null:
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
    TResult Function(_CustomerDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CustomerDto():
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
    TResult? Function(_CustomerDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CustomerDto() when $default != null:
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
    TResult Function(int id, String name, String email, String phone,
            int totalRentals, String status, String? joinedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CustomerDto() when $default != null:
        return $default(_that.id, _that.name, _that.email, _that.phone,
            _that.totalRentals, _that.status, _that.joinedAt);
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
    TResult Function(int id, String name, String email, String phone,
            int totalRentals, String status, String? joinedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CustomerDto():
        return $default(_that.id, _that.name, _that.email, _that.phone,
            _that.totalRentals, _that.status, _that.joinedAt);
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
    TResult? Function(int id, String name, String email, String phone,
            int totalRentals, String status, String? joinedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CustomerDto() when $default != null:
        return $default(_that.id, _that.name, _that.email, _that.phone,
            _that.totalRentals, _that.status, _that.joinedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CustomerDto implements CustomerDto {
  const _CustomerDto(
      {required this.id,
      required this.name,
      required this.email,
      required this.phone,
      required this.totalRentals,
      required this.status,
      this.joinedAt});
  factory _CustomerDto.fromJson(Map<String, dynamic> json) =>
      _$CustomerDtoFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String email;
  @override
  final String phone;
  @override
  final int totalRentals;
  @override
  final String status;
  @override
  final String? joinedAt;

  /// Create a copy of CustomerDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CustomerDtoCopyWith<_CustomerDto> get copyWith =>
      __$CustomerDtoCopyWithImpl<_CustomerDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CustomerDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CustomerDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.totalRentals, totalRentals) ||
                other.totalRentals == totalRentals) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, email, phone, totalRentals, status, joinedAt);

  @override
  String toString() {
    return 'CustomerDto(id: $id, name: $name, email: $email, phone: $phone, totalRentals: $totalRentals, status: $status, joinedAt: $joinedAt)';
  }
}

/// @nodoc
abstract mixin class _$CustomerDtoCopyWith<$Res>
    implements $CustomerDtoCopyWith<$Res> {
  factory _$CustomerDtoCopyWith(
          _CustomerDto value, $Res Function(_CustomerDto) _then) =
      __$CustomerDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String email,
      String phone,
      int totalRentals,
      String status,
      String? joinedAt});
}

/// @nodoc
class __$CustomerDtoCopyWithImpl<$Res> implements _$CustomerDtoCopyWith<$Res> {
  __$CustomerDtoCopyWithImpl(this._self, this._then);

  final _CustomerDto _self;
  final $Res Function(_CustomerDto) _then;

  /// Create a copy of CustomerDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? phone = null,
    Object? totalRentals = null,
    Object? status = null,
    Object? joinedAt = freezed,
  }) {
    return _then(_CustomerDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      totalRentals: null == totalRentals
          ? _self.totalRentals
          : totalRentals // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      joinedAt: freezed == joinedAt
          ? _self.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$CustomerState {
  bool get isLoading;
  String? get error;
  List<CustomerDto> get customers;

  /// Create a copy of CustomerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CustomerStateCopyWith<CustomerState> get copyWith =>
      _$CustomerStateCopyWithImpl<CustomerState>(
          this as CustomerState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CustomerState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other.customers, customers));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, error,
      const DeepCollectionEquality().hash(customers));

  @override
  String toString() {
    return 'CustomerState(isLoading: $isLoading, error: $error, customers: $customers)';
  }
}

/// @nodoc
abstract mixin class $CustomerStateCopyWith<$Res> {
  factory $CustomerStateCopyWith(
          CustomerState value, $Res Function(CustomerState) _then) =
      _$CustomerStateCopyWithImpl;
  @useResult
  $Res call({bool isLoading, String? error, List<CustomerDto> customers});
}

/// @nodoc
class _$CustomerStateCopyWithImpl<$Res>
    implements $CustomerStateCopyWith<$Res> {
  _$CustomerStateCopyWithImpl(this._self, this._then);

  final CustomerState _self;
  final $Res Function(CustomerState) _then;

  /// Create a copy of CustomerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? customers = null,
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
      customers: null == customers
          ? _self.customers
          : customers // ignore: cast_nullable_to_non_nullable
              as List<CustomerDto>,
    ));
  }
}

/// Adds pattern-matching-related methods to [CustomerState].
extension CustomerStatePatterns on CustomerState {
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
    TResult Function(_CustomerState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CustomerState() when $default != null:
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
    TResult Function(_CustomerState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CustomerState():
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
    TResult? Function(_CustomerState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CustomerState() when $default != null:
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
            bool isLoading, String? error, List<CustomerDto> customers)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CustomerState() when $default != null:
        return $default(_that.isLoading, _that.error, _that.customers);
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
    TResult Function(bool isLoading, String? error, List<CustomerDto> customers)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CustomerState():
        return $default(_that.isLoading, _that.error, _that.customers);
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
            bool isLoading, String? error, List<CustomerDto> customers)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CustomerState() when $default != null:
        return $default(_that.isLoading, _that.error, _that.customers);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CustomerState implements CustomerState {
  const _CustomerState(
      {this.isLoading = true,
      this.error,
      final List<CustomerDto> customers = const []})
      : _customers = customers;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  final List<CustomerDto> _customers;
  @override
  @JsonKey()
  List<CustomerDto> get customers {
    if (_customers is EqualUnmodifiableListView) return _customers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_customers);
  }

  /// Create a copy of CustomerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CustomerStateCopyWith<_CustomerState> get copyWith =>
      __$CustomerStateCopyWithImpl<_CustomerState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CustomerState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality()
                .equals(other._customers, _customers));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, error,
      const DeepCollectionEquality().hash(_customers));

  @override
  String toString() {
    return 'CustomerState(isLoading: $isLoading, error: $error, customers: $customers)';
  }
}

/// @nodoc
abstract mixin class _$CustomerStateCopyWith<$Res>
    implements $CustomerStateCopyWith<$Res> {
  factory _$CustomerStateCopyWith(
          _CustomerState value, $Res Function(_CustomerState) _then) =
      __$CustomerStateCopyWithImpl;
  @override
  @useResult
  $Res call({bool isLoading, String? error, List<CustomerDto> customers});
}

/// @nodoc
class __$CustomerStateCopyWithImpl<$Res>
    implements _$CustomerStateCopyWith<$Res> {
  __$CustomerStateCopyWithImpl(this._self, this._then);

  final _CustomerState _self;
  final $Res Function(_CustomerState) _then;

  /// Create a copy of CustomerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? customers = null,
  }) {
    return _then(_CustomerState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      customers: null == customers
          ? _self._customers
          : customers // ignore: cast_nullable_to_non_nullable
              as List<CustomerDto>,
    ));
  }
}

// dart format on
