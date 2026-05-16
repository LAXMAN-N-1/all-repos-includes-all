// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OnboardingStatusDto {
  @JsonKey(name: 'current_stage')
  String get currentStage;
  @JsonKey(name: 'risk_score')
  double? get riskScore;
  List<Map<String, dynamic>> get history;

  /// Create a copy of OnboardingStatusDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OnboardingStatusDtoCopyWith<OnboardingStatusDto> get copyWith =>
      _$OnboardingStatusDtoCopyWithImpl<OnboardingStatusDto>(
          this as OnboardingStatusDto, _$identity);

  /// Serializes this OnboardingStatusDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OnboardingStatusDto &&
            (identical(other.currentStage, currentStage) ||
                other.currentStage == currentStage) &&
            (identical(other.riskScore, riskScore) ||
                other.riskScore == riskScore) &&
            const DeepCollectionEquality().equals(other.history, history));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, currentStage, riskScore,
      const DeepCollectionEquality().hash(history));

  @override
  String toString() {
    return 'OnboardingStatusDto(currentStage: $currentStage, riskScore: $riskScore, history: $history)';
  }
}

/// @nodoc
abstract mixin class $OnboardingStatusDtoCopyWith<$Res> {
  factory $OnboardingStatusDtoCopyWith(
          OnboardingStatusDto value, $Res Function(OnboardingStatusDto) _then) =
      _$OnboardingStatusDtoCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'current_stage') String currentStage,
      @JsonKey(name: 'risk_score') double? riskScore,
      List<Map<String, dynamic>> history});
}

/// @nodoc
class _$OnboardingStatusDtoCopyWithImpl<$Res>
    implements $OnboardingStatusDtoCopyWith<$Res> {
  _$OnboardingStatusDtoCopyWithImpl(this._self, this._then);

  final OnboardingStatusDto _self;
  final $Res Function(OnboardingStatusDto) _then;

  /// Create a copy of OnboardingStatusDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStage = null,
    Object? riskScore = freezed,
    Object? history = null,
  }) {
    return _then(_self.copyWith(
      currentStage: null == currentStage
          ? _self.currentStage
          : currentStage // ignore: cast_nullable_to_non_nullable
              as String,
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

/// Adds pattern-matching-related methods to [OnboardingStatusDto].
extension OnboardingStatusDtoPatterns on OnboardingStatusDto {
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
    TResult Function(_OnboardingStatusDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OnboardingStatusDto() when $default != null:
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
    TResult Function(_OnboardingStatusDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingStatusDto():
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
    TResult? Function(_OnboardingStatusDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingStatusDto() when $default != null:
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
            @JsonKey(name: 'current_stage') String currentStage,
            @JsonKey(name: 'risk_score') double? riskScore,
            List<Map<String, dynamic>> history)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OnboardingStatusDto() when $default != null:
        return $default(_that.currentStage, _that.riskScore, _that.history);
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
            @JsonKey(name: 'current_stage') String currentStage,
            @JsonKey(name: 'risk_score') double? riskScore,
            List<Map<String, dynamic>> history)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingStatusDto():
        return $default(_that.currentStage, _that.riskScore, _that.history);
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
            @JsonKey(name: 'current_stage') String currentStage,
            @JsonKey(name: 'risk_score') double? riskScore,
            List<Map<String, dynamic>> history)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingStatusDto() when $default != null:
        return $default(_that.currentStage, _that.riskScore, _that.history);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _OnboardingStatusDto implements OnboardingStatusDto {
  const _OnboardingStatusDto(
      {@JsonKey(name: 'current_stage') required this.currentStage,
      @JsonKey(name: 'risk_score') this.riskScore,
      final List<Map<String, dynamic>> history = const []})
      : _history = history;
  factory _OnboardingStatusDto.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStatusDtoFromJson(json);

  @override
  @JsonKey(name: 'current_stage')
  final String currentStage;
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

  /// Create a copy of OnboardingStatusDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OnboardingStatusDtoCopyWith<_OnboardingStatusDto> get copyWith =>
      __$OnboardingStatusDtoCopyWithImpl<_OnboardingStatusDto>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$OnboardingStatusDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OnboardingStatusDto &&
            (identical(other.currentStage, currentStage) ||
                other.currentStage == currentStage) &&
            (identical(other.riskScore, riskScore) ||
                other.riskScore == riskScore) &&
            const DeepCollectionEquality().equals(other._history, _history));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, currentStage, riskScore,
      const DeepCollectionEquality().hash(_history));

  @override
  String toString() {
    return 'OnboardingStatusDto(currentStage: $currentStage, riskScore: $riskScore, history: $history)';
  }
}

/// @nodoc
abstract mixin class _$OnboardingStatusDtoCopyWith<$Res>
    implements $OnboardingStatusDtoCopyWith<$Res> {
  factory _$OnboardingStatusDtoCopyWith(_OnboardingStatusDto value,
          $Res Function(_OnboardingStatusDto) _then) =
      __$OnboardingStatusDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'current_stage') String currentStage,
      @JsonKey(name: 'risk_score') double? riskScore,
      List<Map<String, dynamic>> history});
}

/// @nodoc
class __$OnboardingStatusDtoCopyWithImpl<$Res>
    implements _$OnboardingStatusDtoCopyWith<$Res> {
  __$OnboardingStatusDtoCopyWithImpl(this._self, this._then);

  final _OnboardingStatusDto _self;
  final $Res Function(_OnboardingStatusDto) _then;

  /// Create a copy of OnboardingStatusDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? currentStage = null,
    Object? riskScore = freezed,
    Object? history = null,
  }) {
    return _then(_OnboardingStatusDto(
      currentStage: null == currentStage
          ? _self.currentStage
          : currentStage // ignore: cast_nullable_to_non_nullable
              as String,
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
mixin _$OnboardingState {
  bool get isLoading;
  String? get error;
  OnboardingStatusDto? get status;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $OnboardingStateCopyWith<OnboardingState> get copyWith =>
      _$OnboardingStateCopyWithImpl<OnboardingState>(
          this as OnboardingState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is OnboardingState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, error, status);

  @override
  String toString() {
    return 'OnboardingState(isLoading: $isLoading, error: $error, status: $status)';
  }
}

/// @nodoc
abstract mixin class $OnboardingStateCopyWith<$Res> {
  factory $OnboardingStateCopyWith(
          OnboardingState value, $Res Function(OnboardingState) _then) =
      _$OnboardingStateCopyWithImpl;
  @useResult
  $Res call({bool isLoading, String? error, OnboardingStatusDto? status});

  $OnboardingStatusDtoCopyWith<$Res>? get status;
}

/// @nodoc
class _$OnboardingStateCopyWithImpl<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  _$OnboardingStateCopyWithImpl(this._self, this._then);

  final OnboardingState _self;
  final $Res Function(OnboardingState) _then;

  /// Create a copy of OnboardingState
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
              as OnboardingStatusDto?,
    ));
  }

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OnboardingStatusDtoCopyWith<$Res>? get status {
    if (_self.status == null) {
      return null;
    }

    return $OnboardingStatusDtoCopyWith<$Res>(_self.status!, (value) {
      return _then(_self.copyWith(status: value));
    });
  }
}

/// Adds pattern-matching-related methods to [OnboardingState].
extension OnboardingStatePatterns on OnboardingState {
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
    TResult Function(_OnboardingState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OnboardingState() when $default != null:
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
    TResult Function(_OnboardingState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingState():
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
    TResult? Function(_OnboardingState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingState() when $default != null:
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
            bool isLoading, String? error, OnboardingStatusDto? status)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _OnboardingState() when $default != null:
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
    TResult Function(bool isLoading, String? error, OnboardingStatusDto? status)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingState():
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
    TResult? Function(
            bool isLoading, String? error, OnboardingStatusDto? status)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _OnboardingState() when $default != null:
        return $default(_that.isLoading, _that.error, _that.status);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _OnboardingState implements OnboardingState {
  const _OnboardingState({this.isLoading = true, this.error, this.status});

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  @override
  final OnboardingStatusDto? status;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$OnboardingStateCopyWith<_OnboardingState> get copyWith =>
      __$OnboardingStateCopyWithImpl<_OnboardingState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _OnboardingState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, error, status);

  @override
  String toString() {
    return 'OnboardingState(isLoading: $isLoading, error: $error, status: $status)';
  }
}

/// @nodoc
abstract mixin class _$OnboardingStateCopyWith<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  factory _$OnboardingStateCopyWith(
          _OnboardingState value, $Res Function(_OnboardingState) _then) =
      __$OnboardingStateCopyWithImpl;
  @override
  @useResult
  $Res call({bool isLoading, String? error, OnboardingStatusDto? status});

  @override
  $OnboardingStatusDtoCopyWith<$Res>? get status;
}

/// @nodoc
class __$OnboardingStateCopyWithImpl<$Res>
    implements _$OnboardingStateCopyWith<$Res> {
  __$OnboardingStateCopyWithImpl(this._self, this._then);

  final _OnboardingState _self;
  final $Res Function(_OnboardingState) _then;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? status = freezed,
  }) {
    return _then(_OnboardingState(
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
              as OnboardingStatusDto?,
    ));
  }

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OnboardingStatusDtoCopyWith<$Res>? get status {
    if (_self.status == null) {
      return null;
    }

    return $OnboardingStatusDtoCopyWith<$Res>(_self.status!, (value) {
      return _then(_self.copyWith(status: value));
    });
  }
}

// dart format on
