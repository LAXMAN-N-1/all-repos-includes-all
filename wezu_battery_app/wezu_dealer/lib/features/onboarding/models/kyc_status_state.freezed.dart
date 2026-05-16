// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kyc_status_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KycStatusDto {
  int get id;
  @JsonKey(name: 'user_id')
  int get userId;
  @JsonKey(name: 'application_state')
  String get status;
  @JsonKey(name: 'rejection_reason')
  String? get rejectionReason;
  String? get adminComments;
  @JsonKey(name: 'submitted_at')
  String? get submittedAt;
  @JsonKey(name: 'reviewed_at')
  String? get reviewedAt;
  @JsonKey(name: 'risk_score')
  double? get riskScore;
  List<Map<String, dynamic>> get history;

  /// Create a copy of KycStatusDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $KycStatusDtoCopyWith<KycStatusDto> get copyWith =>
      _$KycStatusDtoCopyWithImpl<KycStatusDto>(
          this as KycStatusDto, _$identity);

  /// Serializes this KycStatusDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is KycStatusDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.adminComments, adminComments) ||
                other.adminComments == adminComments) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            (identical(other.riskScore, riskScore) ||
                other.riskScore == riskScore) &&
            const DeepCollectionEquality().equals(other.history, history));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      status,
      rejectionReason,
      adminComments,
      submittedAt,
      reviewedAt,
      riskScore,
      const DeepCollectionEquality().hash(history));

  @override
  String toString() {
    return 'KycStatusDto(id: $id, userId: $userId, status: $status, rejectionReason: $rejectionReason, adminComments: $adminComments, submittedAt: $submittedAt, reviewedAt: $reviewedAt, riskScore: $riskScore, history: $history)';
  }
}

/// @nodoc
abstract mixin class $KycStatusDtoCopyWith<$Res> {
  factory $KycStatusDtoCopyWith(
          KycStatusDto value, $Res Function(KycStatusDto) _then) =
      _$KycStatusDtoCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'user_id') int userId,
      @JsonKey(name: 'application_state') String status,
      @JsonKey(name: 'rejection_reason') String? rejectionReason,
      String? adminComments,
      @JsonKey(name: 'submitted_at') String? submittedAt,
      @JsonKey(name: 'reviewed_at') String? reviewedAt,
      @JsonKey(name: 'risk_score') double? riskScore,
      List<Map<String, dynamic>> history});
}

/// @nodoc
class _$KycStatusDtoCopyWithImpl<$Res> implements $KycStatusDtoCopyWith<$Res> {
  _$KycStatusDtoCopyWithImpl(this._self, this._then);

  final KycStatusDto _self;
  final $Res Function(KycStatusDto) _then;

  /// Create a copy of KycStatusDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? status = null,
    Object? rejectionReason = freezed,
    Object? adminComments = freezed,
    Object? submittedAt = freezed,
    Object? reviewedAt = freezed,
    Object? riskScore = freezed,
    Object? history = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      rejectionReason: freezed == rejectionReason
          ? _self.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      adminComments: freezed == adminComments
          ? _self.adminComments
          : adminComments // ignore: cast_nullable_to_non_nullable
              as String?,
      submittedAt: freezed == submittedAt
          ? _self.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewedAt: freezed == reviewedAt
          ? _self.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      riskScore: freezed == riskScore
          ? _self.riskScore
          : riskScore // ignore: cast_nullable_to_non_nullable
              as double?,
      history: null == history
          ? _self.history
          : history // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
    ));
  }
}

/// Adds pattern-matching-related methods to [KycStatusDto].
extension KycStatusDtoPatterns on KycStatusDto {
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
    TResult Function(_KycStatusDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _KycStatusDto() when $default != null:
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
    TResult Function(_KycStatusDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _KycStatusDto():
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
    TResult? Function(_KycStatusDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _KycStatusDto() when $default != null:
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
            @JsonKey(name: 'user_id') int userId,
            @JsonKey(name: 'application_state') String status,
            @JsonKey(name: 'rejection_reason') String? rejectionReason,
            String? adminComments,
            @JsonKey(name: 'submitted_at') String? submittedAt,
            @JsonKey(name: 'reviewed_at') String? reviewedAt,
            @JsonKey(name: 'risk_score') double? riskScore,
            List<Map<String, dynamic>> history)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _KycStatusDto() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.status,
            _that.rejectionReason,
            _that.adminComments,
            _that.submittedAt,
            _that.reviewedAt,
            _that.riskScore,
            _that.history);
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
            @JsonKey(name: 'user_id') int userId,
            @JsonKey(name: 'application_state') String status,
            @JsonKey(name: 'rejection_reason') String? rejectionReason,
            String? adminComments,
            @JsonKey(name: 'submitted_at') String? submittedAt,
            @JsonKey(name: 'reviewed_at') String? reviewedAt,
            @JsonKey(name: 'risk_score') double? riskScore,
            List<Map<String, dynamic>> history)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _KycStatusDto():
        return $default(
            _that.id,
            _that.userId,
            _that.status,
            _that.rejectionReason,
            _that.adminComments,
            _that.submittedAt,
            _that.reviewedAt,
            _that.riskScore,
            _that.history);
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
            @JsonKey(name: 'user_id') int userId,
            @JsonKey(name: 'application_state') String status,
            @JsonKey(name: 'rejection_reason') String? rejectionReason,
            String? adminComments,
            @JsonKey(name: 'submitted_at') String? submittedAt,
            @JsonKey(name: 'reviewed_at') String? reviewedAt,
            @JsonKey(name: 'risk_score') double? riskScore,
            List<Map<String, dynamic>> history)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _KycStatusDto() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.status,
            _that.rejectionReason,
            _that.adminComments,
            _that.submittedAt,
            _that.reviewedAt,
            _that.riskScore,
            _that.history);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _KycStatusDto implements KycStatusDto {
  const _KycStatusDto(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'application_state') required this.status,
      @JsonKey(name: 'rejection_reason') this.rejectionReason,
      this.adminComments,
      @JsonKey(name: 'submitted_at') this.submittedAt,
      @JsonKey(name: 'reviewed_at') this.reviewedAt,
      @JsonKey(name: 'risk_score') this.riskScore,
      final List<Map<String, dynamic>> history = const []})
      : _history = history;
  factory _KycStatusDto.fromJson(Map<String, dynamic> json) =>
      _$KycStatusDtoFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'user_id')
  final int userId;
  @override
  @JsonKey(name: 'application_state')
  final String status;
  @override
  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason;
  @override
  final String? adminComments;
  @override
  @JsonKey(name: 'submitted_at')
  final String? submittedAt;
  @override
  @JsonKey(name: 'reviewed_at')
  final String? reviewedAt;
  @override
  @JsonKey(name: 'risk_score')
  final double? riskScore;
  final List<Map<String, dynamic>> _history;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get history {
    if (_history is EqualUnmodifiableListView) return _history;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_history);
  }

  /// Create a copy of KycStatusDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$KycStatusDtoCopyWith<_KycStatusDto> get copyWith =>
      __$KycStatusDtoCopyWithImpl<_KycStatusDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$KycStatusDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _KycStatusDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.adminComments, adminComments) ||
                other.adminComments == adminComments) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            (identical(other.riskScore, riskScore) ||
                other.riskScore == riskScore) &&
            const DeepCollectionEquality().equals(other._history, _history));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      status,
      rejectionReason,
      adminComments,
      submittedAt,
      reviewedAt,
      riskScore,
      const DeepCollectionEquality().hash(_history));

  @override
  String toString() {
    return 'KycStatusDto(id: $id, userId: $userId, status: $status, rejectionReason: $rejectionReason, adminComments: $adminComments, submittedAt: $submittedAt, reviewedAt: $reviewedAt, riskScore: $riskScore, history: $history)';
  }
}

/// @nodoc
abstract mixin class _$KycStatusDtoCopyWith<$Res>
    implements $KycStatusDtoCopyWith<$Res> {
  factory _$KycStatusDtoCopyWith(
          _KycStatusDto value, $Res Function(_KycStatusDto) _then) =
      __$KycStatusDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'user_id') int userId,
      @JsonKey(name: 'application_state') String status,
      @JsonKey(name: 'rejection_reason') String? rejectionReason,
      String? adminComments,
      @JsonKey(name: 'submitted_at') String? submittedAt,
      @JsonKey(name: 'reviewed_at') String? reviewedAt,
      @JsonKey(name: 'risk_score') double? riskScore,
      List<Map<String, dynamic>> history});
}

/// @nodoc
class __$KycStatusDtoCopyWithImpl<$Res>
    implements _$KycStatusDtoCopyWith<$Res> {
  __$KycStatusDtoCopyWithImpl(this._self, this._then);

  final _KycStatusDto _self;
  final $Res Function(_KycStatusDto) _then;

  /// Create a copy of KycStatusDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? status = null,
    Object? rejectionReason = freezed,
    Object? adminComments = freezed,
    Object? submittedAt = freezed,
    Object? reviewedAt = freezed,
    Object? riskScore = freezed,
    Object? history = null,
  }) {
    return _then(_KycStatusDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      rejectionReason: freezed == rejectionReason
          ? _self.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      adminComments: freezed == adminComments
          ? _self.adminComments
          : adminComments // ignore: cast_nullable_to_non_nullable
              as String?,
      submittedAt: freezed == submittedAt
          ? _self.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewedAt: freezed == reviewedAt
          ? _self.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      riskScore: freezed == riskScore
          ? _self.riskScore
          : riskScore // ignore: cast_nullable_to_non_nullable
              as double?,
      history: null == history
          ? _self._history
          : history // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
    ));
  }
}

/// @nodoc
mixin _$KycStatusState {
  bool get isLoading;
  String? get error;
  KycStatusDto? get status;

  /// Create a copy of KycStatusState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $KycStatusStateCopyWith<KycStatusState> get copyWith =>
      _$KycStatusStateCopyWithImpl<KycStatusState>(
          this as KycStatusState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is KycStatusState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, error, status);

  @override
  String toString() {
    return 'KycStatusState(isLoading: $isLoading, error: $error, status: $status)';
  }
}

/// @nodoc
abstract mixin class $KycStatusStateCopyWith<$Res> {
  factory $KycStatusStateCopyWith(
          KycStatusState value, $Res Function(KycStatusState) _then) =
      _$KycStatusStateCopyWithImpl;
  @useResult
  $Res call({bool isLoading, String? error, KycStatusDto? status});

  $KycStatusDtoCopyWith<$Res>? get status;
}

/// @nodoc
class _$KycStatusStateCopyWithImpl<$Res>
    implements $KycStatusStateCopyWith<$Res> {
  _$KycStatusStateCopyWithImpl(this._self, this._then);

  final KycStatusState _self;
  final $Res Function(KycStatusState) _then;

  /// Create a copy of KycStatusState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? status = freezed,
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
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as KycStatusDto?,
    ));
  }

  /// Create a copy of KycStatusState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $KycStatusDtoCopyWith<$Res>? get status {
    if (_self.status == null) {
      return null;
    }

    return $KycStatusDtoCopyWith<$Res>(_self.status!, (value) {
      return _then(_self.copyWith(status: value));
    });
  }
}

/// Adds pattern-matching-related methods to [KycStatusState].
extension KycStatusStatePatterns on KycStatusState {
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
    TResult Function(_KycStatusState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _KycStatusState() when $default != null:
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
    TResult Function(_KycStatusState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _KycStatusState():
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
    TResult? Function(_KycStatusState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _KycStatusState() when $default != null:
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
    TResult Function(bool isLoading, String? error, KycStatusDto? status)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _KycStatusState() when $default != null:
        return $default(_that.isLoading, _that.error, _that.status);
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
    TResult Function(bool isLoading, String? error, KycStatusDto? status)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _KycStatusState():
        return $default(_that.isLoading, _that.error, _that.status);
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
    TResult? Function(bool isLoading, String? error, KycStatusDto? status)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _KycStatusState() when $default != null:
        return $default(_that.isLoading, _that.error, _that.status);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _KycStatusState implements KycStatusState {
  const _KycStatusState({this.isLoading = true, this.error, this.status});

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  @override
  final KycStatusDto? status;

  /// Create a copy of KycStatusState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$KycStatusStateCopyWith<_KycStatusState> get copyWith =>
      __$KycStatusStateCopyWithImpl<_KycStatusState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _KycStatusState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, error, status);

  @override
  String toString() {
    return 'KycStatusState(isLoading: $isLoading, error: $error, status: $status)';
  }
}

/// @nodoc
abstract mixin class _$KycStatusStateCopyWith<$Res>
    implements $KycStatusStateCopyWith<$Res> {
  factory _$KycStatusStateCopyWith(
          _KycStatusState value, $Res Function(_KycStatusState) _then) =
      __$KycStatusStateCopyWithImpl;
  @override
  @useResult
  $Res call({bool isLoading, String? error, KycStatusDto? status});

  @override
  $KycStatusDtoCopyWith<$Res>? get status;
}

/// @nodoc
class __$KycStatusStateCopyWithImpl<$Res>
    implements _$KycStatusStateCopyWith<$Res> {
  __$KycStatusStateCopyWithImpl(this._self, this._then);

  final _KycStatusState _self;
  final $Res Function(_KycStatusState) _then;

  /// Create a copy of KycStatusState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? status = freezed,
  }) {
    return _then(_KycStatusState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as KycStatusDto?,
    ));
  }

  /// Create a copy of KycStatusState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $KycStatusDtoCopyWith<$Res>? get status {
    if (_self.status == null) {
      return null;
    }

    return $KycStatusDtoCopyWith<$Res>(_self.status!, (value) {
      return _then(_self.copyWith(status: value));
    });
  }
}

// dart format on
