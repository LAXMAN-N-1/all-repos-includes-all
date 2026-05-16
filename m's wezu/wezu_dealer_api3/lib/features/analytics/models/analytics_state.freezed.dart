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
mixin _$AnalyticsTrendPoint {
  String get label;
  double get value;

  /// Create a copy of AnalyticsTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AnalyticsTrendPointCopyWith<AnalyticsTrendPoint> get copyWith =>
      _$AnalyticsTrendPointCopyWithImpl<AnalyticsTrendPoint>(
          this as AnalyticsTrendPoint, _$identity);

  /// Serializes this AnalyticsTrendPoint to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AnalyticsTrendPoint &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, label, value);

  @override
  String toString() {
    return 'AnalyticsTrendPoint(label: $label, value: $value)';
  }
}

/// @nodoc
abstract mixin class $AnalyticsTrendPointCopyWith<$Res> {
  factory $AnalyticsTrendPointCopyWith(
          AnalyticsTrendPoint value, $Res Function(AnalyticsTrendPoint) _then) =
      _$AnalyticsTrendPointCopyWithImpl;
  @useResult
  $Res call({String label, double value});
}

/// @nodoc
class _$AnalyticsTrendPointCopyWithImpl<$Res>
    implements $AnalyticsTrendPointCopyWith<$Res> {
  _$AnalyticsTrendPointCopyWithImpl(this._self, this._then);

  final AnalyticsTrendPoint _self;
  final $Res Function(AnalyticsTrendPoint) _then;

  /// Create a copy of AnalyticsTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = null,
  }) {
    return _then(_self.copyWith(
      label: null == label
          ? _self.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [AnalyticsTrendPoint].
extension AnalyticsTrendPointPatterns on AnalyticsTrendPoint {
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
    TResult Function(_AnalyticsTrendPoint value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AnalyticsTrendPoint() when $default != null:
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
    TResult Function(_AnalyticsTrendPoint value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyticsTrendPoint():
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
    TResult? Function(_AnalyticsTrendPoint value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyticsTrendPoint() when $default != null:
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
    TResult Function(String label, double value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AnalyticsTrendPoint() when $default != null:
        return $default(_that.label, _that.value);
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
    TResult Function(String label, double value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyticsTrendPoint():
        return $default(_that.label, _that.value);
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
    TResult? Function(String label, double value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyticsTrendPoint() when $default != null:
        return $default(_that.label, _that.value);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AnalyticsTrendPoint implements AnalyticsTrendPoint {
  const _AnalyticsTrendPoint({required this.label, required this.value});
  factory _AnalyticsTrendPoint.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsTrendPointFromJson(json);

  @override
  final String label;
  @override
  final double value;

  /// Create a copy of AnalyticsTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AnalyticsTrendPointCopyWith<_AnalyticsTrendPoint> get copyWith =>
      __$AnalyticsTrendPointCopyWithImpl<_AnalyticsTrendPoint>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AnalyticsTrendPointToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AnalyticsTrendPoint &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, label, value);

  @override
  String toString() {
    return 'AnalyticsTrendPoint(label: $label, value: $value)';
  }
}

/// @nodoc
abstract mixin class _$AnalyticsTrendPointCopyWith<$Res>
    implements $AnalyticsTrendPointCopyWith<$Res> {
  factory _$AnalyticsTrendPointCopyWith(_AnalyticsTrendPoint value,
          $Res Function(_AnalyticsTrendPoint) _then) =
      __$AnalyticsTrendPointCopyWithImpl;
  @override
  @useResult
  $Res call({String label, double value});
}

/// @nodoc
class __$AnalyticsTrendPointCopyWithImpl<$Res>
    implements _$AnalyticsTrendPointCopyWith<$Res> {
  __$AnalyticsTrendPointCopyWithImpl(this._self, this._then);

  final _AnalyticsTrendPoint _self;
  final $Res Function(_AnalyticsTrendPoint) _then;

  /// Create a copy of AnalyticsTrendPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? label = null,
    Object? value = null,
  }) {
    return _then(_AnalyticsTrendPoint(
      label: null == label
          ? _self.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
mixin _$AnalyticsStationUtilization {
  String get name;
  double get utilization;

  /// Create a copy of AnalyticsStationUtilization
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AnalyticsStationUtilizationCopyWith<AnalyticsStationUtilization>
      get copyWith => _$AnalyticsStationUtilizationCopyWithImpl<
              AnalyticsStationUtilization>(
          this as AnalyticsStationUtilization, _$identity);

  /// Serializes this AnalyticsStationUtilization to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AnalyticsStationUtilization &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.utilization, utilization) ||
                other.utilization == utilization));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, utilization);

  @override
  String toString() {
    return 'AnalyticsStationUtilization(name: $name, utilization: $utilization)';
  }
}

/// @nodoc
abstract mixin class $AnalyticsStationUtilizationCopyWith<$Res> {
  factory $AnalyticsStationUtilizationCopyWith(
          AnalyticsStationUtilization value,
          $Res Function(AnalyticsStationUtilization) _then) =
      _$AnalyticsStationUtilizationCopyWithImpl;
  @useResult
  $Res call({String name, double utilization});
}

/// @nodoc
class _$AnalyticsStationUtilizationCopyWithImpl<$Res>
    implements $AnalyticsStationUtilizationCopyWith<$Res> {
  _$AnalyticsStationUtilizationCopyWithImpl(this._self, this._then);

  final AnalyticsStationUtilization _self;
  final $Res Function(AnalyticsStationUtilization) _then;

  /// Create a copy of AnalyticsStationUtilization
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? utilization = null,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      utilization: null == utilization
          ? _self.utilization
          : utilization // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [AnalyticsStationUtilization].
extension AnalyticsStationUtilizationPatterns on AnalyticsStationUtilization {
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
    TResult Function(_AnalyticsStationUtilization value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AnalyticsStationUtilization() when $default != null:
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
    TResult Function(_AnalyticsStationUtilization value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyticsStationUtilization():
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
    TResult? Function(_AnalyticsStationUtilization value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyticsStationUtilization() when $default != null:
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
    TResult Function(String name, double utilization)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AnalyticsStationUtilization() when $default != null:
        return $default(_that.name, _that.utilization);
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
    TResult Function(String name, double utilization) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyticsStationUtilization():
        return $default(_that.name, _that.utilization);
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
    TResult? Function(String name, double utilization)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyticsStationUtilization() when $default != null:
        return $default(_that.name, _that.utilization);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AnalyticsStationUtilization implements AnalyticsStationUtilization {
  const _AnalyticsStationUtilization(
      {required this.name, required this.utilization});
  factory _AnalyticsStationUtilization.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsStationUtilizationFromJson(json);

  @override
  final String name;
  @override
  final double utilization;

  /// Create a copy of AnalyticsStationUtilization
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AnalyticsStationUtilizationCopyWith<_AnalyticsStationUtilization>
      get copyWith => __$AnalyticsStationUtilizationCopyWithImpl<
          _AnalyticsStationUtilization>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AnalyticsStationUtilizationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AnalyticsStationUtilization &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.utilization, utilization) ||
                other.utilization == utilization));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, utilization);

  @override
  String toString() {
    return 'AnalyticsStationUtilization(name: $name, utilization: $utilization)';
  }
}

/// @nodoc
abstract mixin class _$AnalyticsStationUtilizationCopyWith<$Res>
    implements $AnalyticsStationUtilizationCopyWith<$Res> {
  factory _$AnalyticsStationUtilizationCopyWith(
          _AnalyticsStationUtilization value,
          $Res Function(_AnalyticsStationUtilization) _then) =
      __$AnalyticsStationUtilizationCopyWithImpl;
  @override
  @useResult
  $Res call({String name, double utilization});
}

/// @nodoc
class __$AnalyticsStationUtilizationCopyWithImpl<$Res>
    implements _$AnalyticsStationUtilizationCopyWith<$Res> {
  __$AnalyticsStationUtilizationCopyWithImpl(this._self, this._then);

  final _AnalyticsStationUtilization _self;
  final $Res Function(_AnalyticsStationUtilization) _then;

  /// Create a copy of AnalyticsStationUtilization
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? utilization = null,
  }) {
    return _then(_AnalyticsStationUtilization(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      utilization: null == utilization
          ? _self.utilization
          : utilization // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
mixin _$AnalyticsBatteryHealth {
  double get good;
  double get degraded;
  double get critical;

  /// Create a copy of AnalyticsBatteryHealth
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AnalyticsBatteryHealthCopyWith<AnalyticsBatteryHealth> get copyWith =>
      _$AnalyticsBatteryHealthCopyWithImpl<AnalyticsBatteryHealth>(
          this as AnalyticsBatteryHealth, _$identity);

  /// Serializes this AnalyticsBatteryHealth to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AnalyticsBatteryHealth &&
            (identical(other.good, good) || other.good == good) &&
            (identical(other.degraded, degraded) ||
                other.degraded == degraded) &&
            (identical(other.critical, critical) ||
                other.critical == critical));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, good, degraded, critical);

  @override
  String toString() {
    return 'AnalyticsBatteryHealth(good: $good, degraded: $degraded, critical: $critical)';
  }
}

/// @nodoc
abstract mixin class $AnalyticsBatteryHealthCopyWith<$Res> {
  factory $AnalyticsBatteryHealthCopyWith(AnalyticsBatteryHealth value,
          $Res Function(AnalyticsBatteryHealth) _then) =
      _$AnalyticsBatteryHealthCopyWithImpl;
  @useResult
  $Res call({double good, double degraded, double critical});
}

/// @nodoc
class _$AnalyticsBatteryHealthCopyWithImpl<$Res>
    implements $AnalyticsBatteryHealthCopyWith<$Res> {
  _$AnalyticsBatteryHealthCopyWithImpl(this._self, this._then);

  final AnalyticsBatteryHealth _self;
  final $Res Function(AnalyticsBatteryHealth) _then;

  /// Create a copy of AnalyticsBatteryHealth
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? good = null,
    Object? degraded = null,
    Object? critical = null,
  }) {
    return _then(_self.copyWith(
      good: null == good
          ? _self.good
          : good // ignore: cast_nullable_to_non_nullable
              as double,
      degraded: null == degraded
          ? _self.degraded
          : degraded // ignore: cast_nullable_to_non_nullable
              as double,
      critical: null == critical
          ? _self.critical
          : critical // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [AnalyticsBatteryHealth].
extension AnalyticsBatteryHealthPatterns on AnalyticsBatteryHealth {
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
    TResult Function(_AnalyticsBatteryHealth value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AnalyticsBatteryHealth() when $default != null:
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
    TResult Function(_AnalyticsBatteryHealth value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyticsBatteryHealth():
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
    TResult? Function(_AnalyticsBatteryHealth value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyticsBatteryHealth() when $default != null:
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
    TResult Function(double good, double degraded, double critical)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AnalyticsBatteryHealth() when $default != null:
        return $default(_that.good, _that.degraded, _that.critical);
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
    TResult Function(double good, double degraded, double critical) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyticsBatteryHealth():
        return $default(_that.good, _that.degraded, _that.critical);
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
    TResult? Function(double good, double degraded, double critical)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnalyticsBatteryHealth() when $default != null:
        return $default(_that.good, _that.degraded, _that.critical);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AnalyticsBatteryHealth implements AnalyticsBatteryHealth {
  const _AnalyticsBatteryHealth(
      {this.good = 0.0, this.degraded = 0.0, this.critical = 0.0});
  factory _AnalyticsBatteryHealth.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsBatteryHealthFromJson(json);

  @override
  @JsonKey()
  final double good;
  @override
  @JsonKey()
  final double degraded;
  @override
  @JsonKey()
  final double critical;

  /// Create a copy of AnalyticsBatteryHealth
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AnalyticsBatteryHealthCopyWith<_AnalyticsBatteryHealth> get copyWith =>
      __$AnalyticsBatteryHealthCopyWithImpl<_AnalyticsBatteryHealth>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AnalyticsBatteryHealthToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AnalyticsBatteryHealth &&
            (identical(other.good, good) || other.good == good) &&
            (identical(other.degraded, degraded) ||
                other.degraded == degraded) &&
            (identical(other.critical, critical) ||
                other.critical == critical));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, good, degraded, critical);

  @override
  String toString() {
    return 'AnalyticsBatteryHealth(good: $good, degraded: $degraded, critical: $critical)';
  }
}

/// @nodoc
abstract mixin class _$AnalyticsBatteryHealthCopyWith<$Res>
    implements $AnalyticsBatteryHealthCopyWith<$Res> {
  factory _$AnalyticsBatteryHealthCopyWith(_AnalyticsBatteryHealth value,
          $Res Function(_AnalyticsBatteryHealth) _then) =
      __$AnalyticsBatteryHealthCopyWithImpl;
  @override
  @useResult
  $Res call({double good, double degraded, double critical});
}

/// @nodoc
class __$AnalyticsBatteryHealthCopyWithImpl<$Res>
    implements _$AnalyticsBatteryHealthCopyWith<$Res> {
  __$AnalyticsBatteryHealthCopyWithImpl(this._self, this._then);

  final _AnalyticsBatteryHealth _self;
  final $Res Function(_AnalyticsBatteryHealth) _then;

  /// Create a copy of AnalyticsBatteryHealth
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? good = null,
    Object? degraded = null,
    Object? critical = null,
  }) {
    return _then(_AnalyticsBatteryHealth(
      good: null == good
          ? _self.good
          : good // ignore: cast_nullable_to_non_nullable
              as double,
      degraded: null == degraded
          ? _self.degraded
          : degraded // ignore: cast_nullable_to_non_nullable
              as double,
      critical: null == critical
          ? _self.critical
          : critical // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
mixin _$AnalyticsOverviewDto {
  double get revenue;
  int get totalSwaps;
  double get avgSwapDurationHrs;
  double get customerSatisfaction;
  Map<String, dynamic> get revenueTrends;
  Map<String, dynamic> get salesPerformance;
  double get growthMetrics; // Chart-ready data parsed from API
  List<AnalyticsTrendPoint> get revenueChartData;
  List<AnalyticsTrendPoint> get swapChartData;
  List<AnalyticsStationUtilization> get stationUtilization;
  AnalyticsBatteryHealth?
      get batteryHealth; // Peak hours: list of 24 values (0.0–1.0 intensity per hour)
  List<double> get peakHoursData;

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
                other.growthMetrics == growthMetrics) &&
            const DeepCollectionEquality()
                .equals(other.revenueChartData, revenueChartData) &&
            const DeepCollectionEquality()
                .equals(other.swapChartData, swapChartData) &&
            const DeepCollectionEquality()
                .equals(other.stationUtilization, stationUtilization) &&
            (identical(other.batteryHealth, batteryHealth) ||
                other.batteryHealth == batteryHealth) &&
            const DeepCollectionEquality()
                .equals(other.peakHoursData, peakHoursData));
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
      growthMetrics,
      const DeepCollectionEquality().hash(revenueChartData),
      const DeepCollectionEquality().hash(swapChartData),
      const DeepCollectionEquality().hash(stationUtilization),
      batteryHealth,
      const DeepCollectionEquality().hash(peakHoursData));

  @override
  String toString() {
    return 'AnalyticsOverviewDto(revenue: $revenue, totalSwaps: $totalSwaps, avgSwapDurationHrs: $avgSwapDurationHrs, customerSatisfaction: $customerSatisfaction, revenueTrends: $revenueTrends, salesPerformance: $salesPerformance, growthMetrics: $growthMetrics, revenueChartData: $revenueChartData, swapChartData: $swapChartData, stationUtilization: $stationUtilization, batteryHealth: $batteryHealth, peakHoursData: $peakHoursData)';
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
      double growthMetrics,
      List<AnalyticsTrendPoint> revenueChartData,
      List<AnalyticsTrendPoint> swapChartData,
      List<AnalyticsStationUtilization> stationUtilization,
      AnalyticsBatteryHealth? batteryHealth,
      List<double> peakHoursData});

  $AnalyticsBatteryHealthCopyWith<$Res>? get batteryHealth;
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
    Object? revenueChartData = null,
    Object? swapChartData = null,
    Object? stationUtilization = null,
    Object? batteryHealth = freezed,
    Object? peakHoursData = null,
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
      revenueChartData: null == revenueChartData
          ? _self.revenueChartData
          : revenueChartData // ignore: cast_nullable_to_non_nullable
              as List<AnalyticsTrendPoint>,
      swapChartData: null == swapChartData
          ? _self.swapChartData
          : swapChartData // ignore: cast_nullable_to_non_nullable
              as List<AnalyticsTrendPoint>,
      stationUtilization: null == stationUtilization
          ? _self.stationUtilization
          : stationUtilization // ignore: cast_nullable_to_non_nullable
              as List<AnalyticsStationUtilization>,
      batteryHealth: freezed == batteryHealth
          ? _self.batteryHealth
          : batteryHealth // ignore: cast_nullable_to_non_nullable
              as AnalyticsBatteryHealth?,
      peakHoursData: null == peakHoursData
          ? _self.peakHoursData
          : peakHoursData // ignore: cast_nullable_to_non_nullable
              as List<double>,
    ));
  }

  /// Create a copy of AnalyticsOverviewDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AnalyticsBatteryHealthCopyWith<$Res>? get batteryHealth {
    if (_self.batteryHealth == null) {
      return null;
    }

    return $AnalyticsBatteryHealthCopyWith<$Res>(_self.batteryHealth!, (value) {
      return _then(_self.copyWith(batteryHealth: value));
    });
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
            double growthMetrics,
            List<AnalyticsTrendPoint> revenueChartData,
            List<AnalyticsTrendPoint> swapChartData,
            List<AnalyticsStationUtilization> stationUtilization,
            AnalyticsBatteryHealth? batteryHealth,
            List<double> peakHoursData)?
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
            _that.growthMetrics,
            _that.revenueChartData,
            _that.swapChartData,
            _that.stationUtilization,
            _that.batteryHealth,
            _that.peakHoursData);
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
            double growthMetrics,
            List<AnalyticsTrendPoint> revenueChartData,
            List<AnalyticsTrendPoint> swapChartData,
            List<AnalyticsStationUtilization> stationUtilization,
            AnalyticsBatteryHealth? batteryHealth,
            List<double> peakHoursData)
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
            _that.growthMetrics,
            _that.revenueChartData,
            _that.swapChartData,
            _that.stationUtilization,
            _that.batteryHealth,
            _that.peakHoursData);
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
            double growthMetrics,
            List<AnalyticsTrendPoint> revenueChartData,
            List<AnalyticsTrendPoint> swapChartData,
            List<AnalyticsStationUtilization> stationUtilization,
            AnalyticsBatteryHealth? batteryHealth,
            List<double> peakHoursData)?
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
            _that.growthMetrics,
            _that.revenueChartData,
            _that.swapChartData,
            _that.stationUtilization,
            _that.batteryHealth,
            _that.peakHoursData);
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
      this.growthMetrics = 0.0,
      final List<AnalyticsTrendPoint> revenueChartData = const [],
      final List<AnalyticsTrendPoint> swapChartData = const [],
      final List<AnalyticsStationUtilization> stationUtilization = const [],
      this.batteryHealth = null,
      final List<double> peakHoursData = const []})
      : _revenueTrends = revenueTrends,
        _salesPerformance = salesPerformance,
        _revenueChartData = revenueChartData,
        _swapChartData = swapChartData,
        _stationUtilization = stationUtilization,
        _peakHoursData = peakHoursData;
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
// Chart-ready data parsed from API
  final List<AnalyticsTrendPoint> _revenueChartData;
// Chart-ready data parsed from API
  @override
  @JsonKey()
  List<AnalyticsTrendPoint> get revenueChartData {
    if (_revenueChartData is EqualUnmodifiableListView)
      return _revenueChartData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_revenueChartData);
  }

  final List<AnalyticsTrendPoint> _swapChartData;
  @override
  @JsonKey()
  List<AnalyticsTrendPoint> get swapChartData {
    if (_swapChartData is EqualUnmodifiableListView) return _swapChartData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_swapChartData);
  }

  final List<AnalyticsStationUtilization> _stationUtilization;
  @override
  @JsonKey()
  List<AnalyticsStationUtilization> get stationUtilization {
    if (_stationUtilization is EqualUnmodifiableListView)
      return _stationUtilization;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stationUtilization);
  }

  @override
  @JsonKey()
  final AnalyticsBatteryHealth? batteryHealth;
// Peak hours: list of 24 values (0.0–1.0 intensity per hour)
  final List<double> _peakHoursData;
// Peak hours: list of 24 values (0.0–1.0 intensity per hour)
  @override
  @JsonKey()
  List<double> get peakHoursData {
    if (_peakHoursData is EqualUnmodifiableListView) return _peakHoursData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_peakHoursData);
  }

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
                other.growthMetrics == growthMetrics) &&
            const DeepCollectionEquality()
                .equals(other._revenueChartData, _revenueChartData) &&
            const DeepCollectionEquality()
                .equals(other._swapChartData, _swapChartData) &&
            const DeepCollectionEquality()
                .equals(other._stationUtilization, _stationUtilization) &&
            (identical(other.batteryHealth, batteryHealth) ||
                other.batteryHealth == batteryHealth) &&
            const DeepCollectionEquality()
                .equals(other._peakHoursData, _peakHoursData));
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
      growthMetrics,
      const DeepCollectionEquality().hash(_revenueChartData),
      const DeepCollectionEquality().hash(_swapChartData),
      const DeepCollectionEquality().hash(_stationUtilization),
      batteryHealth,
      const DeepCollectionEquality().hash(_peakHoursData));

  @override
  String toString() {
    return 'AnalyticsOverviewDto(revenue: $revenue, totalSwaps: $totalSwaps, avgSwapDurationHrs: $avgSwapDurationHrs, customerSatisfaction: $customerSatisfaction, revenueTrends: $revenueTrends, salesPerformance: $salesPerformance, growthMetrics: $growthMetrics, revenueChartData: $revenueChartData, swapChartData: $swapChartData, stationUtilization: $stationUtilization, batteryHealth: $batteryHealth, peakHoursData: $peakHoursData)';
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
      double growthMetrics,
      List<AnalyticsTrendPoint> revenueChartData,
      List<AnalyticsTrendPoint> swapChartData,
      List<AnalyticsStationUtilization> stationUtilization,
      AnalyticsBatteryHealth? batteryHealth,
      List<double> peakHoursData});

  @override
  $AnalyticsBatteryHealthCopyWith<$Res>? get batteryHealth;
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
    Object? revenueChartData = null,
    Object? swapChartData = null,
    Object? stationUtilization = null,
    Object? batteryHealth = freezed,
    Object? peakHoursData = null,
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
      revenueChartData: null == revenueChartData
          ? _self._revenueChartData
          : revenueChartData // ignore: cast_nullable_to_non_nullable
              as List<AnalyticsTrendPoint>,
      swapChartData: null == swapChartData
          ? _self._swapChartData
          : swapChartData // ignore: cast_nullable_to_non_nullable
              as List<AnalyticsTrendPoint>,
      stationUtilization: null == stationUtilization
          ? _self._stationUtilization
          : stationUtilization // ignore: cast_nullable_to_non_nullable
              as List<AnalyticsStationUtilization>,
      batteryHealth: freezed == batteryHealth
          ? _self.batteryHealth
          : batteryHealth // ignore: cast_nullable_to_non_nullable
              as AnalyticsBatteryHealth?,
      peakHoursData: null == peakHoursData
          ? _self._peakHoursData
          : peakHoursData // ignore: cast_nullable_to_non_nullable
              as List<double>,
    ));
  }

  /// Create a copy of AnalyticsOverviewDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AnalyticsBatteryHealthCopyWith<$Res>? get batteryHealth {
    if (_self.batteryHealth == null) {
      return null;
    }

    return $AnalyticsBatteryHealthCopyWith<$Res>(_self.batteryHealth!, (value) {
      return _then(_self.copyWith(batteryHealth: value));
    });
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
