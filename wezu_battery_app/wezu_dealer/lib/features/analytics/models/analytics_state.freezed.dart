// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AnalyticsOverviewDto {
  double get revenue;
  int get totalSwaps;
  double get avgSwapDurationHrs;
  double get customerSatisfaction;
  Map<String, dynamic> get revenueTrends;
  Map<String, dynamic> get salesPerformance;
  double get growthMetrics;

  /// Create a copy of AnalyticsOverviewDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AnalyticsOverviewDtoCopyWith<AnalyticsOverviewDto> get copyWith =>
      _$AnalyticsOverviewDtoCopyWithImpl<AnalyticsOverviewDto>(
          this as AnalyticsOverviewDto, _$identity);

  /// Serializes this AnalyticsOverviewDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AnalyticsOverviewDto &&
            (identical(other.revenue, revenue) || other.revenue == revenue) &&
            (identical(other.totalSwaps, totalSwaps) ||
                other.totalSwaps == totalSwaps) &&
            (identical(other.avgSwapDurationHrs, avgSwapDurationHrs) ||
                other.avgSwapDurationHrs == avgSwapDurationHrs) &&
            (identical(other.customerSatisfaction, customerSatisfaction) ||
                other.customerSatisfaction == customerSatisfaction) &&
            const DeepCollectionEquality()
                .equals(other.revenueTrends, revenueTrends) &&
            const DeepCollectionEquality()
                .equals(other.salesPerformance, salesPerformance) &&
            (identical(other.growthMetrics, growthMetrics) ||
                other.growthMetrics == growthMetrics));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      revenue,
      totalSwaps,
      avgSwapDurationHrs,
      customerSatisfaction,
      const DeepCollectionEquality().hash(revenueTrends),
      const DeepCollectionEquality().hash(salesPerformance),
      growthMetrics);

  @override
  String toString() {
    return 'AnalyticsOverviewDto(revenue: $revenue, totalSwaps: $totalSwaps, avgSwapDurationHrs: $avgSwapDurationHrs, customerSatisfaction: $customerSatisfaction, revenueTrends: $revenueTrends, salesPerformance: $salesPerformance, growthMetrics: $growthMetrics)';
  }
}

/// @nodoc
abstract mixin class $AnalyticsOverviewDtoCopyWith<$Res> {
  factory $AnalyticsOverviewDtoCopyWith(AnalyticsOverviewDto value,
          $Res Function(AnalyticsOverviewDto) _then) =
      _$AnalyticsOverviewDtoCopyWithImpl;
  @useResult
  $Res call(
      {double revenue,
      int totalSwaps,
      double avgSwapDurationHrs,
      double customerSatisfaction,
      Map<String, dynamic> revenueTrends,
      Map<String, dynamic> salesPerformance,
      double growthMetrics});
}

/// @nodoc
class _$AnalyticsOverviewDtoCopyWithImpl<$Res>
    implements $AnalyticsOverviewDtoCopyWith<$Res> {
  _$AnalyticsOverviewDtoCopyWithImpl(this._self, this._then);

  final AnalyticsOverviewDto _self;
  final $Res Function(AnalyticsOverviewDto) _then;

  /// Create a copy of AnalyticsOverviewDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? revenue = null,
    Object? totalSwaps = null,
    Object? avgSwapDurationHrs = null,
    Object? customerSatisfaction = null,
    Object? revenueTrends = null,
    Object? salesPerformance = null,
    Object? growthMetrics = null,
  }) {
    return _then(_self.copyWith(
      revenue: null == revenue
          ? _self.revenue
          : revenue // ignore: cast_nullable_to_non_nullable
              as double,
      totalSwaps: null == totalSwaps
          ? _self.totalSwaps
          : totalSwaps // ignore: cast_nullable_to_non_nullable
              as int,
      avgSwapDurationHrs: null == avgSwapDurationHrs
          ? _self.avgSwapDurationHrs
          : avgSwapDurationHrs // ignore: cast_nullable_to_non_nullable
              as double,
      customerSatisfaction: null == customerSatisfaction
          ? _self.customerSatisfaction
          : customerSatisfaction // ignore: cast_nullable_to_non_nullable
              as double,
      revenueTrends: null == revenueTrends
          ? _self.revenueTrends
          : revenueTrends // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      salesPerformance: null == salesPerformance
          ? _self.salesPerformance
          : salesPerformance // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      growthMetrics: null == growthMetrics
          ? _self.growthMetrics
          : growthMetrics // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [AnalyticsOverviewDto].
extension AnalyticsOverviewDtoPatterns on AnalyticsOverviewDto {
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
    TResult Function(_AnalyticsOverviewDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AnalyticsOverviewDto() when $default != null:
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
    TResult Function(_AnalyticsOverviewDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyticsOverviewDto():
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
    TResult? Function(_AnalyticsOverviewDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyticsOverviewDto() when $default != null:
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
            double revenue,
            int totalSwaps,
            double avgSwapDurationHrs,
            double customerSatisfaction,
            Map<String, dynamic> revenueTrends,
            Map<String, dynamic> salesPerformance,
            double growthMetrics)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AnalyticsOverviewDto() when $default != null:
        return $default(
            _that.revenue,
            _that.totalSwaps,
            _that.avgSwapDurationHrs,
            _that.customerSatisfaction,
            _that.revenueTrends,
            _that.salesPerformance,
            _that.growthMetrics);
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
            double revenue,
            int totalSwaps,
            double avgSwapDurationHrs,
            double customerSatisfaction,
            Map<String, dynamic> revenueTrends,
            Map<String, dynamic> salesPerformance,
            double growthMetrics)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyticsOverviewDto():
        return $default(
            _that.revenue,
            _that.totalSwaps,
            _that.avgSwapDurationHrs,
            _that.customerSatisfaction,
            _that.revenueTrends,
            _that.salesPerformance,
            _that.growthMetrics);
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
            double revenue,
            int totalSwaps,
            double avgSwapDurationHrs,
            double customerSatisfaction,
            Map<String, dynamic> revenueTrends,
            Map<String, dynamic> salesPerformance,
            double growthMetrics)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyticsOverviewDto() when $default != null:
        return $default(
            _that.revenue,
            _that.totalSwaps,
            _that.avgSwapDurationHrs,
            _that.customerSatisfaction,
            _that.revenueTrends,
            _that.salesPerformance,
            _that.growthMetrics);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AnalyticsOverviewDto implements AnalyticsOverviewDto {
  const _AnalyticsOverviewDto(
      {required this.revenue,
      this.totalSwaps = 0,
      this.avgSwapDurationHrs = 0.0,
      this.customerSatisfaction = 0.0,
      final Map<String, dynamic> revenueTrends = const {},
      final Map<String, dynamic> salesPerformance = const {},
      this.growthMetrics = 0.0})
      : _revenueTrends = revenueTrends,
        _salesPerformance = salesPerformance;
  factory _AnalyticsOverviewDto.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsOverviewDtoFromJson(json);

  @override
  final double revenue;
  @override
  @JsonKey()
  final int totalSwaps;
  @override
  @JsonKey()
  final double avgSwapDurationHrs;
  @override
  @JsonKey()
  final double customerSatisfaction;
  final Map<String, dynamic> _revenueTrends;
  @override
  @JsonKey()
  Map<String, dynamic> get revenueTrends {
    if (_revenueTrends is EqualUnmodifiableMapView) return _revenueTrends;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_revenueTrends);
  }

  final Map<String, dynamic> _salesPerformance;
  @override
  @JsonKey()
  Map<String, dynamic> get salesPerformance {
    if (_salesPerformance is EqualUnmodifiableMapView) return _salesPerformance;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_salesPerformance);
  }

  @override
  @JsonKey()
  final double growthMetrics;

  /// Create a copy of AnalyticsOverviewDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AnalyticsOverviewDtoCopyWith<_AnalyticsOverviewDto> get copyWith =>
      __$AnalyticsOverviewDtoCopyWithImpl<_AnalyticsOverviewDto>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AnalyticsOverviewDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AnalyticsOverviewDto &&
            (identical(other.revenue, revenue) || other.revenue == revenue) &&
            (identical(other.totalSwaps, totalSwaps) ||
                other.totalSwaps == totalSwaps) &&
            (identical(other.avgSwapDurationHrs, avgSwapDurationHrs) ||
                other.avgSwapDurationHrs == avgSwapDurationHrs) &&
            (identical(other.customerSatisfaction, customerSatisfaction) ||
                other.customerSatisfaction == customerSatisfaction) &&
            const DeepCollectionEquality()
                .equals(other._revenueTrends, _revenueTrends) &&
            const DeepCollectionEquality()
                .equals(other._salesPerformance, _salesPerformance) &&
            (identical(other.growthMetrics, growthMetrics) ||
                other.growthMetrics == growthMetrics));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      revenue,
      totalSwaps,
      avgSwapDurationHrs,
      customerSatisfaction,
      const DeepCollectionEquality().hash(_revenueTrends),
      const DeepCollectionEquality().hash(_salesPerformance),
      growthMetrics);

  @override
  String toString() {
    return 'AnalyticsOverviewDto(revenue: $revenue, totalSwaps: $totalSwaps, avgSwapDurationHrs: $avgSwapDurationHrs, customerSatisfaction: $customerSatisfaction, revenueTrends: $revenueTrends, salesPerformance: $salesPerformance, growthMetrics: $growthMetrics)';
  }
}

/// @nodoc
abstract mixin class _$AnalyticsOverviewDtoCopyWith<$Res>
    implements $AnalyticsOverviewDtoCopyWith<$Res> {
  factory _$AnalyticsOverviewDtoCopyWith(_AnalyticsOverviewDto value,
          $Res Function(_AnalyticsOverviewDto) _then) =
      __$AnalyticsOverviewDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double revenue,
      int totalSwaps,
      double avgSwapDurationHrs,
      double customerSatisfaction,
      Map<String, dynamic> revenueTrends,
      Map<String, dynamic> salesPerformance,
      double growthMetrics});
}

/// @nodoc
class __$AnalyticsOverviewDtoCopyWithImpl<$Res>
    implements _$AnalyticsOverviewDtoCopyWith<$Res> {
  __$AnalyticsOverviewDtoCopyWithImpl(this._self, this._then);

  final _AnalyticsOverviewDto _self;
  final $Res Function(_AnalyticsOverviewDto) _then;

  /// Create a copy of AnalyticsOverviewDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? revenue = null,
    Object? totalSwaps = null,
    Object? avgSwapDurationHrs = null,
    Object? customerSatisfaction = null,
    Object? revenueTrends = null,
    Object? salesPerformance = null,
    Object? growthMetrics = null,
  }) {
    return _then(_AnalyticsOverviewDto(
      revenue: null == revenue
          ? _self.revenue
          : revenue // ignore: cast_nullable_to_non_nullable
              as double,
      totalSwaps: null == totalSwaps
          ? _self.totalSwaps
          : totalSwaps // ignore: cast_nullable_to_non_nullable
              as int,
      avgSwapDurationHrs: null == avgSwapDurationHrs
          ? _self.avgSwapDurationHrs
          : avgSwapDurationHrs // ignore: cast_nullable_to_non_nullable
              as double,
      customerSatisfaction: null == customerSatisfaction
          ? _self.customerSatisfaction
          : customerSatisfaction // ignore: cast_nullable_to_non_nullable
              as double,
      revenueTrends: null == revenueTrends
          ? _self._revenueTrends
          : revenueTrends // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      salesPerformance: null == salesPerformance
          ? _self._salesPerformance
          : salesPerformance // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      growthMetrics: null == growthMetrics
          ? _self.growthMetrics
          : growthMetrics // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
mixin _$AnalyticsState {
  bool get isLoading;
  String? get error;
  AnalyticsOverviewDto? get overview;

  /// Create a copy of AnalyticsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AnalyticsStateCopyWith<AnalyticsState> get copyWith =>
      _$AnalyticsStateCopyWithImpl<AnalyticsState>(
          this as AnalyticsState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AnalyticsState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.overview, overview) ||
                other.overview == overview));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, error, overview);

  @override
  String toString() {
    return 'AnalyticsState(isLoading: $isLoading, error: $error, overview: $overview)';
  }
}

/// @nodoc
abstract mixin class $AnalyticsStateCopyWith<$Res> {
  factory $AnalyticsStateCopyWith(
          AnalyticsState value, $Res Function(AnalyticsState) _then) =
      _$AnalyticsStateCopyWithImpl;
  @useResult
  $Res call({bool isLoading, String? error, AnalyticsOverviewDto? overview});

  $AnalyticsOverviewDtoCopyWith<$Res>? get overview;
}

/// @nodoc
class _$AnalyticsStateCopyWithImpl<$Res>
    implements $AnalyticsStateCopyWith<$Res> {
  _$AnalyticsStateCopyWithImpl(this._self, this._then);

  final AnalyticsState _self;
  final $Res Function(AnalyticsState) _then;

  /// Create a copy of AnalyticsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? overview = freezed,
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
      overview: freezed == overview
          ? _self.overview
          : overview // ignore: cast_nullable_to_non_nullable
              as AnalyticsOverviewDto?,
    ));
  }

  /// Create a copy of AnalyticsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AnalyticsOverviewDtoCopyWith<$Res>? get overview {
    if (_self.overview == null) {
      return null;
    }

    return $AnalyticsOverviewDtoCopyWith<$Res>(_self.overview!, (value) {
      return _then(_self.copyWith(overview: value));
    });
  }
}

/// Adds pattern-matching-related methods to [AnalyticsState].
extension AnalyticsStatePatterns on AnalyticsState {
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
    TResult Function(_AnalyticsState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AnalyticsState() when $default != null:
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
    TResult Function(_AnalyticsState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyticsState():
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
    TResult? Function(_AnalyticsState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyticsState() when $default != null:
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
            bool isLoading, String? error, AnalyticsOverviewDto? overview)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AnalyticsState() when $default != null:
        return $default(_that.isLoading, _that.error, _that.overview);
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
            bool isLoading, String? error, AnalyticsOverviewDto? overview)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyticsState():
        return $default(_that.isLoading, _that.error, _that.overview);
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
            bool isLoading, String? error, AnalyticsOverviewDto? overview)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyticsState() when $default != null:
        return $default(_that.isLoading, _that.error, _that.overview);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AnalyticsState implements AnalyticsState {
  const _AnalyticsState({this.isLoading = true, this.error, this.overview});

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  @override
  final AnalyticsOverviewDto? overview;

  /// Create a copy of AnalyticsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AnalyticsStateCopyWith<_AnalyticsState> get copyWith =>
      __$AnalyticsStateCopyWithImpl<_AnalyticsState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AnalyticsState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.overview, overview) ||
                other.overview == overview));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, error, overview);

  @override
  String toString() {
    return 'AnalyticsState(isLoading: $isLoading, error: $error, overview: $overview)';
  }
}

/// @nodoc
abstract mixin class _$AnalyticsStateCopyWith<$Res>
    implements $AnalyticsStateCopyWith<$Res> {
  factory _$AnalyticsStateCopyWith(
          _AnalyticsState value, $Res Function(_AnalyticsState) _then) =
      __$AnalyticsStateCopyWithImpl;
  @override
  @useResult
  $Res call({bool isLoading, String? error, AnalyticsOverviewDto? overview});

  @override
  $AnalyticsOverviewDtoCopyWith<$Res>? get overview;
}

/// @nodoc
class __$AnalyticsStateCopyWithImpl<$Res>
    implements _$AnalyticsStateCopyWith<$Res> {
  __$AnalyticsStateCopyWithImpl(this._self, this._then);

  final _AnalyticsState _self;
  final $Res Function(_AnalyticsState) _then;

  /// Create a copy of AnalyticsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? overview = freezed,
  }) {
    return _then(_AnalyticsState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      overview: freezed == overview
          ? _self.overview
          : overview // ignore: cast_nullable_to_non_nullable
              as AnalyticsOverviewDto?,
    ));
  }

  /// Create a copy of AnalyticsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AnalyticsOverviewDtoCopyWith<$Res>? get overview {
    if (_self.overview == null) {
      return null;
    }

    return $AnalyticsOverviewDtoCopyWith<$Res>(_self.overview!, (value) {
      return _then(_self.copyWith(overview: value));
    });
  }
}

// dart format on
