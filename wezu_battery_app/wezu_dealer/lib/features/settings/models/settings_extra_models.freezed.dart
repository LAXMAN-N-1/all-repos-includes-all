// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_extra_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StationDefaultsDto {
  @JsonKey(name: 'station_open_time')
  String? get stationOpenTime;
  @JsonKey(name: 'station_close_time')
  String? get stationCloseTime;
  @JsonKey(name: 'battery_capacity')
  String? get batteryCapacity;
  @JsonKey(name: 'low_stock_threshold')
  String? get lowStockThreshold;
  @JsonKey(name: 'charging_rules')
  Map<String, dynamic>? get chargingRules;

  /// Create a copy of StationDefaultsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StationDefaultsDtoCopyWith<StationDefaultsDto> get copyWith =>
      _$StationDefaultsDtoCopyWithImpl<StationDefaultsDto>(
          this as StationDefaultsDto, _$identity);

  /// Serializes this StationDefaultsDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StationDefaultsDto &&
            (identical(other.stationOpenTime, stationOpenTime) ||
                other.stationOpenTime == stationOpenTime) &&
            (identical(other.stationCloseTime, stationCloseTime) ||
                other.stationCloseTime == stationCloseTime) &&
            (identical(other.batteryCapacity, batteryCapacity) ||
                other.batteryCapacity == batteryCapacity) &&
            (identical(other.lowStockThreshold, lowStockThreshold) ||
                other.lowStockThreshold == lowStockThreshold) &&
            const DeepCollectionEquality()
                .equals(other.chargingRules, chargingRules));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      stationOpenTime,
      stationCloseTime,
      batteryCapacity,
      lowStockThreshold,
      const DeepCollectionEquality().hash(chargingRules));

  @override
  String toString() {
    return 'StationDefaultsDto(stationOpenTime: $stationOpenTime, stationCloseTime: $stationCloseTime, batteryCapacity: $batteryCapacity, lowStockThreshold: $lowStockThreshold, chargingRules: $chargingRules)';
  }
}

/// @nodoc
abstract mixin class $StationDefaultsDtoCopyWith<$Res> {
  factory $StationDefaultsDtoCopyWith(
          StationDefaultsDto value, $Res Function(StationDefaultsDto) _then) =
      _$StationDefaultsDtoCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'station_open_time') String? stationOpenTime,
      @JsonKey(name: 'station_close_time') String? stationCloseTime,
      @JsonKey(name: 'battery_capacity') String? batteryCapacity,
      @JsonKey(name: 'low_stock_threshold') String? lowStockThreshold,
      @JsonKey(name: 'charging_rules') Map<String, dynamic>? chargingRules});
}

/// @nodoc
class _$StationDefaultsDtoCopyWithImpl<$Res>
    implements $StationDefaultsDtoCopyWith<$Res> {
  _$StationDefaultsDtoCopyWithImpl(this._self, this._then);

  final StationDefaultsDto _self;
  final $Res Function(StationDefaultsDto) _then;

  /// Create a copy of StationDefaultsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stationOpenTime = freezed,
    Object? stationCloseTime = freezed,
    Object? batteryCapacity = freezed,
    Object? lowStockThreshold = freezed,
    Object? chargingRules = freezed,
  }) {
    return _then(_self.copyWith(
      stationOpenTime: freezed == stationOpenTime
          ? _self.stationOpenTime
          : stationOpenTime // ignore: cast_nullable_to_non_nullable
              as String?,
      stationCloseTime: freezed == stationCloseTime
          ? _self.stationCloseTime
          : stationCloseTime // ignore: cast_nullable_to_non_nullable
              as String?,
      batteryCapacity: freezed == batteryCapacity
          ? _self.batteryCapacity
          : batteryCapacity // ignore: cast_nullable_to_non_nullable
              as String?,
      lowStockThreshold: freezed == lowStockThreshold
          ? _self.lowStockThreshold
          : lowStockThreshold // ignore: cast_nullable_to_non_nullable
              as String?,
      chargingRules: freezed == chargingRules
          ? _self.chargingRules
          : chargingRules // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// Adds pattern-matching-related methods to [StationDefaultsDto].
extension StationDefaultsDtoPatterns on StationDefaultsDto {
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
    TResult Function(_StationDefaultsDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StationDefaultsDto() when $default != null:
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
    TResult Function(_StationDefaultsDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StationDefaultsDto():
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
    TResult? Function(_StationDefaultsDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StationDefaultsDto() when $default != null:
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
            @JsonKey(name: 'station_open_time') String? stationOpenTime,
            @JsonKey(name: 'station_close_time') String? stationCloseTime,
            @JsonKey(name: 'battery_capacity') String? batteryCapacity,
            @JsonKey(name: 'low_stock_threshold') String? lowStockThreshold,
            @JsonKey(name: 'charging_rules')
            Map<String, dynamic>? chargingRules)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StationDefaultsDto() when $default != null:
        return $default(
            _that.stationOpenTime,
            _that.stationCloseTime,
            _that.batteryCapacity,
            _that.lowStockThreshold,
            _that.chargingRules);
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
            @JsonKey(name: 'station_open_time') String? stationOpenTime,
            @JsonKey(name: 'station_close_time') String? stationCloseTime,
            @JsonKey(name: 'battery_capacity') String? batteryCapacity,
            @JsonKey(name: 'low_stock_threshold') String? lowStockThreshold,
            @JsonKey(name: 'charging_rules')
            Map<String, dynamic>? chargingRules)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StationDefaultsDto():
        return $default(
            _that.stationOpenTime,
            _that.stationCloseTime,
            _that.batteryCapacity,
            _that.lowStockThreshold,
            _that.chargingRules);
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
            @JsonKey(name: 'station_open_time') String? stationOpenTime,
            @JsonKey(name: 'station_close_time') String? stationCloseTime,
            @JsonKey(name: 'battery_capacity') String? batteryCapacity,
            @JsonKey(name: 'low_stock_threshold') String? lowStockThreshold,
            @JsonKey(name: 'charging_rules')
            Map<String, dynamic>? chargingRules)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StationDefaultsDto() when $default != null:
        return $default(
            _that.stationOpenTime,
            _that.stationCloseTime,
            _that.batteryCapacity,
            _that.lowStockThreshold,
            _that.chargingRules);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _StationDefaultsDto implements StationDefaultsDto {
  const _StationDefaultsDto(
      {@JsonKey(name: 'station_open_time') this.stationOpenTime,
      @JsonKey(name: 'station_close_time') this.stationCloseTime,
      @JsonKey(name: 'battery_capacity') this.batteryCapacity,
      @JsonKey(name: 'low_stock_threshold') this.lowStockThreshold,
      @JsonKey(name: 'charging_rules')
      final Map<String, dynamic>? chargingRules})
      : _chargingRules = chargingRules;
  factory _StationDefaultsDto.fromJson(Map<String, dynamic> json) =>
      _$StationDefaultsDtoFromJson(json);

  @override
  @JsonKey(name: 'station_open_time')
  final String? stationOpenTime;
  @override
  @JsonKey(name: 'station_close_time')
  final String? stationCloseTime;
  @override
  @JsonKey(name: 'battery_capacity')
  final String? batteryCapacity;
  @override
  @JsonKey(name: 'low_stock_threshold')
  final String? lowStockThreshold;
  final Map<String, dynamic>? _chargingRules;
  @override
  @JsonKey(name: 'charging_rules')
  Map<String, dynamic>? get chargingRules {
    final value = _chargingRules;
    if (value == null) return null;
    if (_chargingRules is EqualUnmodifiableMapView) return _chargingRules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of StationDefaultsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StationDefaultsDtoCopyWith<_StationDefaultsDto> get copyWith =>
      __$StationDefaultsDtoCopyWithImpl<_StationDefaultsDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$StationDefaultsDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StationDefaultsDto &&
            (identical(other.stationOpenTime, stationOpenTime) ||
                other.stationOpenTime == stationOpenTime) &&
            (identical(other.stationCloseTime, stationCloseTime) ||
                other.stationCloseTime == stationCloseTime) &&
            (identical(other.batteryCapacity, batteryCapacity) ||
                other.batteryCapacity == batteryCapacity) &&
            (identical(other.lowStockThreshold, lowStockThreshold) ||
                other.lowStockThreshold == lowStockThreshold) &&
            const DeepCollectionEquality()
                .equals(other._chargingRules, _chargingRules));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      stationOpenTime,
      stationCloseTime,
      batteryCapacity,
      lowStockThreshold,
      const DeepCollectionEquality().hash(_chargingRules));

  @override
  String toString() {
    return 'StationDefaultsDto(stationOpenTime: $stationOpenTime, stationCloseTime: $stationCloseTime, batteryCapacity: $batteryCapacity, lowStockThreshold: $lowStockThreshold, chargingRules: $chargingRules)';
  }
}

/// @nodoc
abstract mixin class _$StationDefaultsDtoCopyWith<$Res>
    implements $StationDefaultsDtoCopyWith<$Res> {
  factory _$StationDefaultsDtoCopyWith(
          _StationDefaultsDto value, $Res Function(_StationDefaultsDto) _then) =
      __$StationDefaultsDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'station_open_time') String? stationOpenTime,
      @JsonKey(name: 'station_close_time') String? stationCloseTime,
      @JsonKey(name: 'battery_capacity') String? batteryCapacity,
      @JsonKey(name: 'low_stock_threshold') String? lowStockThreshold,
      @JsonKey(name: 'charging_rules') Map<String, dynamic>? chargingRules});
}

/// @nodoc
class __$StationDefaultsDtoCopyWithImpl<$Res>
    implements _$StationDefaultsDtoCopyWith<$Res> {
  __$StationDefaultsDtoCopyWithImpl(this._self, this._then);

  final _StationDefaultsDto _self;
  final $Res Function(_StationDefaultsDto) _then;

  /// Create a copy of StationDefaultsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? stationOpenTime = freezed,
    Object? stationCloseTime = freezed,
    Object? batteryCapacity = freezed,
    Object? lowStockThreshold = freezed,
    Object? chargingRules = freezed,
  }) {
    return _then(_StationDefaultsDto(
      stationOpenTime: freezed == stationOpenTime
          ? _self.stationOpenTime
          : stationOpenTime // ignore: cast_nullable_to_non_nullable
              as String?,
      stationCloseTime: freezed == stationCloseTime
          ? _self.stationCloseTime
          : stationCloseTime // ignore: cast_nullable_to_non_nullable
              as String?,
      batteryCapacity: freezed == batteryCapacity
          ? _self.batteryCapacity
          : batteryCapacity // ignore: cast_nullable_to_non_nullable
              as String?,
      lowStockThreshold: freezed == lowStockThreshold
          ? _self.lowStockThreshold
          : lowStockThreshold // ignore: cast_nullable_to_non_nullable
              as String?,
      chargingRules: freezed == chargingRules
          ? _self._chargingRules
          : chargingRules // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
mixin _$InventoryRulesDto {
  @JsonKey(name: 'alert_offline_val')
  String? get alertOfflineVal;
  @JsonKey(name: 'alert_anomaly_val')
  String? get alertAnomalyVal;
  @JsonKey(name: 'auto_reorder_enabled')
  bool get autoReorderEnabled;
  @JsonKey(name: 'reorder_threshold')
  int? get reorderThreshold;

  /// Create a copy of InventoryRulesDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InventoryRulesDtoCopyWith<InventoryRulesDto> get copyWith =>
      _$InventoryRulesDtoCopyWithImpl<InventoryRulesDto>(
          this as InventoryRulesDto, _$identity);

  /// Serializes this InventoryRulesDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InventoryRulesDto &&
            (identical(other.alertOfflineVal, alertOfflineVal) ||
                other.alertOfflineVal == alertOfflineVal) &&
            (identical(other.alertAnomalyVal, alertAnomalyVal) ||
                other.alertAnomalyVal == alertAnomalyVal) &&
            (identical(other.autoReorderEnabled, autoReorderEnabled) ||
                other.autoReorderEnabled == autoReorderEnabled) &&
            (identical(other.reorderThreshold, reorderThreshold) ||
                other.reorderThreshold == reorderThreshold));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, alertOfflineVal, alertAnomalyVal,
      autoReorderEnabled, reorderThreshold);

  @override
  String toString() {
    return 'InventoryRulesDto(alertOfflineVal: $alertOfflineVal, alertAnomalyVal: $alertAnomalyVal, autoReorderEnabled: $autoReorderEnabled, reorderThreshold: $reorderThreshold)';
  }
}

/// @nodoc
abstract mixin class $InventoryRulesDtoCopyWith<$Res> {
  factory $InventoryRulesDtoCopyWith(
          InventoryRulesDto value, $Res Function(InventoryRulesDto) _then) =
      _$InventoryRulesDtoCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'alert_offline_val') String? alertOfflineVal,
      @JsonKey(name: 'alert_anomaly_val') String? alertAnomalyVal,
      @JsonKey(name: 'auto_reorder_enabled') bool autoReorderEnabled,
      @JsonKey(name: 'reorder_threshold') int? reorderThreshold});
}

/// @nodoc
class _$InventoryRulesDtoCopyWithImpl<$Res>
    implements $InventoryRulesDtoCopyWith<$Res> {
  _$InventoryRulesDtoCopyWithImpl(this._self, this._then);

  final InventoryRulesDto _self;
  final $Res Function(InventoryRulesDto) _then;

  /// Create a copy of InventoryRulesDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alertOfflineVal = freezed,
    Object? alertAnomalyVal = freezed,
    Object? autoReorderEnabled = null,
    Object? reorderThreshold = freezed,
  }) {
    return _then(_self.copyWith(
      alertOfflineVal: freezed == alertOfflineVal
          ? _self.alertOfflineVal
          : alertOfflineVal // ignore: cast_nullable_to_non_nullable
              as String?,
      alertAnomalyVal: freezed == alertAnomalyVal
          ? _self.alertAnomalyVal
          : alertAnomalyVal // ignore: cast_nullable_to_non_nullable
              as String?,
      autoReorderEnabled: null == autoReorderEnabled
          ? _self.autoReorderEnabled
          : autoReorderEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      reorderThreshold: freezed == reorderThreshold
          ? _self.reorderThreshold
          : reorderThreshold // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// Adds pattern-matching-related methods to [InventoryRulesDto].
extension InventoryRulesDtoPatterns on InventoryRulesDto {
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
    TResult Function(_InventoryRulesDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InventoryRulesDto() when $default != null:
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
    TResult Function(_InventoryRulesDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InventoryRulesDto():
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
    TResult? Function(_InventoryRulesDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InventoryRulesDto() when $default != null:
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
            @JsonKey(name: 'alert_offline_val') String? alertOfflineVal,
            @JsonKey(name: 'alert_anomaly_val') String? alertAnomalyVal,
            @JsonKey(name: 'auto_reorder_enabled') bool autoReorderEnabled,
            @JsonKey(name: 'reorder_threshold') int? reorderThreshold)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InventoryRulesDto() when $default != null:
        return $default(_that.alertOfflineVal, _that.alertAnomalyVal,
            _that.autoReorderEnabled, _that.reorderThreshold);
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
            @JsonKey(name: 'alert_offline_val') String? alertOfflineVal,
            @JsonKey(name: 'alert_anomaly_val') String? alertAnomalyVal,
            @JsonKey(name: 'auto_reorder_enabled') bool autoReorderEnabled,
            @JsonKey(name: 'reorder_threshold') int? reorderThreshold)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InventoryRulesDto():
        return $default(_that.alertOfflineVal, _that.alertAnomalyVal,
            _that.autoReorderEnabled, _that.reorderThreshold);
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
            @JsonKey(name: 'alert_offline_val') String? alertOfflineVal,
            @JsonKey(name: 'alert_anomaly_val') String? alertAnomalyVal,
            @JsonKey(name: 'auto_reorder_enabled') bool autoReorderEnabled,
            @JsonKey(name: 'reorder_threshold') int? reorderThreshold)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InventoryRulesDto() when $default != null:
        return $default(_that.alertOfflineVal, _that.alertAnomalyVal,
            _that.autoReorderEnabled, _that.reorderThreshold);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _InventoryRulesDto implements InventoryRulesDto {
  const _InventoryRulesDto(
      {@JsonKey(name: 'alert_offline_val') this.alertOfflineVal,
      @JsonKey(name: 'alert_anomaly_val') this.alertAnomalyVal,
      @JsonKey(name: 'auto_reorder_enabled') this.autoReorderEnabled = false,
      @JsonKey(name: 'reorder_threshold') this.reorderThreshold});
  factory _InventoryRulesDto.fromJson(Map<String, dynamic> json) =>
      _$InventoryRulesDtoFromJson(json);

  @override
  @JsonKey(name: 'alert_offline_val')
  final String? alertOfflineVal;
  @override
  @JsonKey(name: 'alert_anomaly_val')
  final String? alertAnomalyVal;
  @override
  @JsonKey(name: 'auto_reorder_enabled')
  final bool autoReorderEnabled;
  @override
  @JsonKey(name: 'reorder_threshold')
  final int? reorderThreshold;

  /// Create a copy of InventoryRulesDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InventoryRulesDtoCopyWith<_InventoryRulesDto> get copyWith =>
      __$InventoryRulesDtoCopyWithImpl<_InventoryRulesDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$InventoryRulesDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InventoryRulesDto &&
            (identical(other.alertOfflineVal, alertOfflineVal) ||
                other.alertOfflineVal == alertOfflineVal) &&
            (identical(other.alertAnomalyVal, alertAnomalyVal) ||
                other.alertAnomalyVal == alertAnomalyVal) &&
            (identical(other.autoReorderEnabled, autoReorderEnabled) ||
                other.autoReorderEnabled == autoReorderEnabled) &&
            (identical(other.reorderThreshold, reorderThreshold) ||
                other.reorderThreshold == reorderThreshold));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, alertOfflineVal, alertAnomalyVal,
      autoReorderEnabled, reorderThreshold);

  @override
  String toString() {
    return 'InventoryRulesDto(alertOfflineVal: $alertOfflineVal, alertAnomalyVal: $alertAnomalyVal, autoReorderEnabled: $autoReorderEnabled, reorderThreshold: $reorderThreshold)';
  }
}

/// @nodoc
abstract mixin class _$InventoryRulesDtoCopyWith<$Res>
    implements $InventoryRulesDtoCopyWith<$Res> {
  factory _$InventoryRulesDtoCopyWith(
          _InventoryRulesDto value, $Res Function(_InventoryRulesDto) _then) =
      __$InventoryRulesDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'alert_offline_val') String? alertOfflineVal,
      @JsonKey(name: 'alert_anomaly_val') String? alertAnomalyVal,
      @JsonKey(name: 'auto_reorder_enabled') bool autoReorderEnabled,
      @JsonKey(name: 'reorder_threshold') int? reorderThreshold});
}

/// @nodoc
class __$InventoryRulesDtoCopyWithImpl<$Res>
    implements _$InventoryRulesDtoCopyWith<$Res> {
  __$InventoryRulesDtoCopyWithImpl(this._self, this._then);

  final _InventoryRulesDto _self;
  final $Res Function(_InventoryRulesDto) _then;

  /// Create a copy of InventoryRulesDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? alertOfflineVal = freezed,
    Object? alertAnomalyVal = freezed,
    Object? autoReorderEnabled = null,
    Object? reorderThreshold = freezed,
  }) {
    return _then(_InventoryRulesDto(
      alertOfflineVal: freezed == alertOfflineVal
          ? _self.alertOfflineVal
          : alertOfflineVal // ignore: cast_nullable_to_non_nullable
              as String?,
      alertAnomalyVal: freezed == alertAnomalyVal
          ? _self.alertAnomalyVal
          : alertAnomalyVal // ignore: cast_nullable_to_non_nullable
              as String?,
      autoReorderEnabled: null == autoReorderEnabled
          ? _self.autoReorderEnabled
          : autoReorderEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      reorderThreshold: freezed == reorderThreshold
          ? _self.reorderThreshold
          : reorderThreshold // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
mixin _$HolidayCalendarDto {
  String get name;
  String get date;
  String? get description;
  @JsonKey(name: 'is_national')
  bool get isNational;

  /// Create a copy of HolidayCalendarDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HolidayCalendarDtoCopyWith<HolidayCalendarDto> get copyWith =>
      _$HolidayCalendarDtoCopyWithImpl<HolidayCalendarDto>(
          this as HolidayCalendarDto, _$identity);

  /// Serializes this HolidayCalendarDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HolidayCalendarDto &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isNational, isNational) ||
                other.isNational == isNational));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, date, description, isNational);

  @override
  String toString() {
    return 'HolidayCalendarDto(name: $name, date: $date, description: $description, isNational: $isNational)';
  }
}

/// @nodoc
abstract mixin class $HolidayCalendarDtoCopyWith<$Res> {
  factory $HolidayCalendarDtoCopyWith(
          HolidayCalendarDto value, $Res Function(HolidayCalendarDto) _then) =
      _$HolidayCalendarDtoCopyWithImpl;
  @useResult
  $Res call(
      {String name,
      String date,
      String? description,
      @JsonKey(name: 'is_national') bool isNational});
}

/// @nodoc
class _$HolidayCalendarDtoCopyWithImpl<$Res>
    implements $HolidayCalendarDtoCopyWith<$Res> {
  _$HolidayCalendarDtoCopyWithImpl(this._self, this._then);

  final HolidayCalendarDto _self;
  final $Res Function(HolidayCalendarDto) _then;

  /// Create a copy of HolidayCalendarDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? date = null,
    Object? description = freezed,
    Object? isNational = null,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      isNational: null == isNational
          ? _self.isNational
          : isNational // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [HolidayCalendarDto].
extension HolidayCalendarDtoPatterns on HolidayCalendarDto {
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
    TResult Function(_HolidayCalendarDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HolidayCalendarDto() when $default != null:
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
    TResult Function(_HolidayCalendarDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HolidayCalendarDto():
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
    TResult? Function(_HolidayCalendarDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HolidayCalendarDto() when $default != null:
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
    TResult Function(String name, String date, String? description,
            @JsonKey(name: 'is_national') bool isNational)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HolidayCalendarDto() when $default != null:
        return $default(
            _that.name, _that.date, _that.description, _that.isNational);
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
    TResult Function(String name, String date, String? description,
            @JsonKey(name: 'is_national') bool isNational)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HolidayCalendarDto():
        return $default(
            _that.name, _that.date, _that.description, _that.isNational);
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
    TResult? Function(String name, String date, String? description,
            @JsonKey(name: 'is_national') bool isNational)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HolidayCalendarDto() when $default != null:
        return $default(
            _that.name, _that.date, _that.description, _that.isNational);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _HolidayCalendarDto implements HolidayCalendarDto {
  const _HolidayCalendarDto(
      {required this.name,
      required this.date,
      this.description,
      @JsonKey(name: 'is_national') this.isNational = false});
  factory _HolidayCalendarDto.fromJson(Map<String, dynamic> json) =>
      _$HolidayCalendarDtoFromJson(json);

  @override
  final String name;
  @override
  final String date;
  @override
  final String? description;
  @override
  @JsonKey(name: 'is_national')
  final bool isNational;

  /// Create a copy of HolidayCalendarDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HolidayCalendarDtoCopyWith<_HolidayCalendarDto> get copyWith =>
      __$HolidayCalendarDtoCopyWithImpl<_HolidayCalendarDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$HolidayCalendarDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _HolidayCalendarDto &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isNational, isNational) ||
                other.isNational == isNational));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, date, description, isNational);

  @override
  String toString() {
    return 'HolidayCalendarDto(name: $name, date: $date, description: $description, isNational: $isNational)';
  }
}

/// @nodoc
abstract mixin class _$HolidayCalendarDtoCopyWith<$Res>
    implements $HolidayCalendarDtoCopyWith<$Res> {
  factory _$HolidayCalendarDtoCopyWith(
          _HolidayCalendarDto value, $Res Function(_HolidayCalendarDto) _then) =
      __$HolidayCalendarDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String name,
      String date,
      String? description,
      @JsonKey(name: 'is_national') bool isNational});
}

/// @nodoc
class __$HolidayCalendarDtoCopyWithImpl<$Res>
    implements _$HolidayCalendarDtoCopyWith<$Res> {
  __$HolidayCalendarDtoCopyWithImpl(this._self, this._then);

  final _HolidayCalendarDto _self;
  final $Res Function(_HolidayCalendarDto) _then;

  /// Create a copy of HolidayCalendarDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? date = null,
    Object? description = freezed,
    Object? isNational = null,
  }) {
    return _then(_HolidayCalendarDto(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      isNational: null == isNational
          ? _self.isNational
          : isNational // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$RentalSettingsDto {
  @JsonKey(name: 'daily_rate')
  double? get dailyRate;
  @JsonKey(name: 'security_deposit')
  double? get securityDeposit;
  @JsonKey(name: 'late_fee_hourly')
  double? get lateFeeHourly;
  @JsonKey(name: 'grace_period_hours')
  int? get gracePeriodHours;
  @JsonKey(name: 'allow_extension')
  bool get allowExtension;
  @JsonKey(name: 'allow_pause')
  bool get allowPause;
  @JsonKey(name: 'max_concurrent_rentals')
  int get maxConcurrentRentals;
  @JsonKey(name: 'min_battery_checkout')
  int get minBatteryCheckout;

  /// Create a copy of RentalSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RentalSettingsDtoCopyWith<RentalSettingsDto> get copyWith =>
      _$RentalSettingsDtoCopyWithImpl<RentalSettingsDto>(
          this as RentalSettingsDto, _$identity);

  /// Serializes this RentalSettingsDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RentalSettingsDto &&
            (identical(other.dailyRate, dailyRate) ||
                other.dailyRate == dailyRate) &&
            (identical(other.securityDeposit, securityDeposit) ||
                other.securityDeposit == securityDeposit) &&
            (identical(other.lateFeeHourly, lateFeeHourly) ||
                other.lateFeeHourly == lateFeeHourly) &&
            (identical(other.gracePeriodHours, gracePeriodHours) ||
                other.gracePeriodHours == gracePeriodHours) &&
            (identical(other.allowExtension, allowExtension) ||
                other.allowExtension == allowExtension) &&
            (identical(other.allowPause, allowPause) ||
                other.allowPause == allowPause) &&
            (identical(other.maxConcurrentRentals, maxConcurrentRentals) ||
                other.maxConcurrentRentals == maxConcurrentRentals) &&
            (identical(other.minBatteryCheckout, minBatteryCheckout) ||
                other.minBatteryCheckout == minBatteryCheckout));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      dailyRate,
      securityDeposit,
      lateFeeHourly,
      gracePeriodHours,
      allowExtension,
      allowPause,
      maxConcurrentRentals,
      minBatteryCheckout);

  @override
  String toString() {
    return 'RentalSettingsDto(dailyRate: $dailyRate, securityDeposit: $securityDeposit, lateFeeHourly: $lateFeeHourly, gracePeriodHours: $gracePeriodHours, allowExtension: $allowExtension, allowPause: $allowPause, maxConcurrentRentals: $maxConcurrentRentals, minBatteryCheckout: $minBatteryCheckout)';
  }
}

/// @nodoc
abstract mixin class $RentalSettingsDtoCopyWith<$Res> {
  factory $RentalSettingsDtoCopyWith(
          RentalSettingsDto value, $Res Function(RentalSettingsDto) _then) =
      _$RentalSettingsDtoCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'daily_rate') double? dailyRate,
      @JsonKey(name: 'security_deposit') double? securityDeposit,
      @JsonKey(name: 'late_fee_hourly') double? lateFeeHourly,
      @JsonKey(name: 'grace_period_hours') int? gracePeriodHours,
      @JsonKey(name: 'allow_extension') bool allowExtension,
      @JsonKey(name: 'allow_pause') bool allowPause,
      @JsonKey(name: 'max_concurrent_rentals') int maxConcurrentRentals,
      @JsonKey(name: 'min_battery_checkout') int minBatteryCheckout});
}

/// @nodoc
class _$RentalSettingsDtoCopyWithImpl<$Res>
    implements $RentalSettingsDtoCopyWith<$Res> {
  _$RentalSettingsDtoCopyWithImpl(this._self, this._then);

  final RentalSettingsDto _self;
  final $Res Function(RentalSettingsDto) _then;

  /// Create a copy of RentalSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dailyRate = freezed,
    Object? securityDeposit = freezed,
    Object? lateFeeHourly = freezed,
    Object? gracePeriodHours = freezed,
    Object? allowExtension = null,
    Object? allowPause = null,
    Object? maxConcurrentRentals = null,
    Object? minBatteryCheckout = null,
  }) {
    return _then(_self.copyWith(
      dailyRate: freezed == dailyRate
          ? _self.dailyRate
          : dailyRate // ignore: cast_nullable_to_non_nullable
              as double?,
      securityDeposit: freezed == securityDeposit
          ? _self.securityDeposit
          : securityDeposit // ignore: cast_nullable_to_non_nullable
              as double?,
      lateFeeHourly: freezed == lateFeeHourly
          ? _self.lateFeeHourly
          : lateFeeHourly // ignore: cast_nullable_to_non_nullable
              as double?,
      gracePeriodHours: freezed == gracePeriodHours
          ? _self.gracePeriodHours
          : gracePeriodHours // ignore: cast_nullable_to_non_nullable
              as int?,
      allowExtension: null == allowExtension
          ? _self.allowExtension
          : allowExtension // ignore: cast_nullable_to_non_nullable
              as bool,
      allowPause: null == allowPause
          ? _self.allowPause
          : allowPause // ignore: cast_nullable_to_non_nullable
              as bool,
      maxConcurrentRentals: null == maxConcurrentRentals
          ? _self.maxConcurrentRentals
          : maxConcurrentRentals // ignore: cast_nullable_to_non_nullable
              as int,
      minBatteryCheckout: null == minBatteryCheckout
          ? _self.minBatteryCheckout
          : minBatteryCheckout // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [RentalSettingsDto].
extension RentalSettingsDtoPatterns on RentalSettingsDto {
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
    TResult Function(_RentalSettingsDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RentalSettingsDto() when $default != null:
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
    TResult Function(_RentalSettingsDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RentalSettingsDto():
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
    TResult? Function(_RentalSettingsDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RentalSettingsDto() when $default != null:
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
            @JsonKey(name: 'daily_rate') double? dailyRate,
            @JsonKey(name: 'security_deposit') double? securityDeposit,
            @JsonKey(name: 'late_fee_hourly') double? lateFeeHourly,
            @JsonKey(name: 'grace_period_hours') int? gracePeriodHours,
            @JsonKey(name: 'allow_extension') bool allowExtension,
            @JsonKey(name: 'allow_pause') bool allowPause,
            @JsonKey(name: 'max_concurrent_rentals') int maxConcurrentRentals,
            @JsonKey(name: 'min_battery_checkout') int minBatteryCheckout)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RentalSettingsDto() when $default != null:
        return $default(
            _that.dailyRate,
            _that.securityDeposit,
            _that.lateFeeHourly,
            _that.gracePeriodHours,
            _that.allowExtension,
            _that.allowPause,
            _that.maxConcurrentRentals,
            _that.minBatteryCheckout);
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
            @JsonKey(name: 'daily_rate') double? dailyRate,
            @JsonKey(name: 'security_deposit') double? securityDeposit,
            @JsonKey(name: 'late_fee_hourly') double? lateFeeHourly,
            @JsonKey(name: 'grace_period_hours') int? gracePeriodHours,
            @JsonKey(name: 'allow_extension') bool allowExtension,
            @JsonKey(name: 'allow_pause') bool allowPause,
            @JsonKey(name: 'max_concurrent_rentals') int maxConcurrentRentals,
            @JsonKey(name: 'min_battery_checkout') int minBatteryCheckout)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RentalSettingsDto():
        return $default(
            _that.dailyRate,
            _that.securityDeposit,
            _that.lateFeeHourly,
            _that.gracePeriodHours,
            _that.allowExtension,
            _that.allowPause,
            _that.maxConcurrentRentals,
            _that.minBatteryCheckout);
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
            @JsonKey(name: 'daily_rate') double? dailyRate,
            @JsonKey(name: 'security_deposit') double? securityDeposit,
            @JsonKey(name: 'late_fee_hourly') double? lateFeeHourly,
            @JsonKey(name: 'grace_period_hours') int? gracePeriodHours,
            @JsonKey(name: 'allow_extension') bool allowExtension,
            @JsonKey(name: 'allow_pause') bool allowPause,
            @JsonKey(name: 'max_concurrent_rentals') int maxConcurrentRentals,
            @JsonKey(name: 'min_battery_checkout') int minBatteryCheckout)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RentalSettingsDto() when $default != null:
        return $default(
            _that.dailyRate,
            _that.securityDeposit,
            _that.lateFeeHourly,
            _that.gracePeriodHours,
            _that.allowExtension,
            _that.allowPause,
            _that.maxConcurrentRentals,
            _that.minBatteryCheckout);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _RentalSettingsDto implements RentalSettingsDto {
  const _RentalSettingsDto(
      {@JsonKey(name: 'daily_rate') this.dailyRate,
      @JsonKey(name: 'security_deposit') this.securityDeposit,
      @JsonKey(name: 'late_fee_hourly') this.lateFeeHourly,
      @JsonKey(name: 'grace_period_hours') this.gracePeriodHours,
      @JsonKey(name: 'allow_extension') this.allowExtension = true,
      @JsonKey(name: 'allow_pause') this.allowPause = false,
      @JsonKey(name: 'max_concurrent_rentals') this.maxConcurrentRentals = 1,
      @JsonKey(name: 'min_battery_checkout') this.minBatteryCheckout = 80});
  factory _RentalSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$RentalSettingsDtoFromJson(json);

  @override
  @JsonKey(name: 'daily_rate')
  final double? dailyRate;
  @override
  @JsonKey(name: 'security_deposit')
  final double? securityDeposit;
  @override
  @JsonKey(name: 'late_fee_hourly')
  final double? lateFeeHourly;
  @override
  @JsonKey(name: 'grace_period_hours')
  final int? gracePeriodHours;
  @override
  @JsonKey(name: 'allow_extension')
  final bool allowExtension;
  @override
  @JsonKey(name: 'allow_pause')
  final bool allowPause;
  @override
  @JsonKey(name: 'max_concurrent_rentals')
  final int maxConcurrentRentals;
  @override
  @JsonKey(name: 'min_battery_checkout')
  final int minBatteryCheckout;

  /// Create a copy of RentalSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RentalSettingsDtoCopyWith<_RentalSettingsDto> get copyWith =>
      __$RentalSettingsDtoCopyWithImpl<_RentalSettingsDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$RentalSettingsDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RentalSettingsDto &&
            (identical(other.dailyRate, dailyRate) ||
                other.dailyRate == dailyRate) &&
            (identical(other.securityDeposit, securityDeposit) ||
                other.securityDeposit == securityDeposit) &&
            (identical(other.lateFeeHourly, lateFeeHourly) ||
                other.lateFeeHourly == lateFeeHourly) &&
            (identical(other.gracePeriodHours, gracePeriodHours) ||
                other.gracePeriodHours == gracePeriodHours) &&
            (identical(other.allowExtension, allowExtension) ||
                other.allowExtension == allowExtension) &&
            (identical(other.allowPause, allowPause) ||
                other.allowPause == allowPause) &&
            (identical(other.maxConcurrentRentals, maxConcurrentRentals) ||
                other.maxConcurrentRentals == maxConcurrentRentals) &&
            (identical(other.minBatteryCheckout, minBatteryCheckout) ||
                other.minBatteryCheckout == minBatteryCheckout));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      dailyRate,
      securityDeposit,
      lateFeeHourly,
      gracePeriodHours,
      allowExtension,
      allowPause,
      maxConcurrentRentals,
      minBatteryCheckout);

  @override
  String toString() {
    return 'RentalSettingsDto(dailyRate: $dailyRate, securityDeposit: $securityDeposit, lateFeeHourly: $lateFeeHourly, gracePeriodHours: $gracePeriodHours, allowExtension: $allowExtension, allowPause: $allowPause, maxConcurrentRentals: $maxConcurrentRentals, minBatteryCheckout: $minBatteryCheckout)';
  }
}

/// @nodoc
abstract mixin class _$RentalSettingsDtoCopyWith<$Res>
    implements $RentalSettingsDtoCopyWith<$Res> {
  factory _$RentalSettingsDtoCopyWith(
          _RentalSettingsDto value, $Res Function(_RentalSettingsDto) _then) =
      __$RentalSettingsDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'daily_rate') double? dailyRate,
      @JsonKey(name: 'security_deposit') double? securityDeposit,
      @JsonKey(name: 'late_fee_hourly') double? lateFeeHourly,
      @JsonKey(name: 'grace_period_hours') int? gracePeriodHours,
      @JsonKey(name: 'allow_extension') bool allowExtension,
      @JsonKey(name: 'allow_pause') bool allowPause,
      @JsonKey(name: 'max_concurrent_rentals') int maxConcurrentRentals,
      @JsonKey(name: 'min_battery_checkout') int minBatteryCheckout});
}

/// @nodoc
class __$RentalSettingsDtoCopyWithImpl<$Res>
    implements _$RentalSettingsDtoCopyWith<$Res> {
  __$RentalSettingsDtoCopyWithImpl(this._self, this._then);

  final _RentalSettingsDto _self;
  final $Res Function(_RentalSettingsDto) _then;

  /// Create a copy of RentalSettingsDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? dailyRate = freezed,
    Object? securityDeposit = freezed,
    Object? lateFeeHourly = freezed,
    Object? gracePeriodHours = freezed,
    Object? allowExtension = null,
    Object? allowPause = null,
    Object? maxConcurrentRentals = null,
    Object? minBatteryCheckout = null,
  }) {
    return _then(_RentalSettingsDto(
      dailyRate: freezed == dailyRate
          ? _self.dailyRate
          : dailyRate // ignore: cast_nullable_to_non_nullable
              as double?,
      securityDeposit: freezed == securityDeposit
          ? _self.securityDeposit
          : securityDeposit // ignore: cast_nullable_to_non_nullable
              as double?,
      lateFeeHourly: freezed == lateFeeHourly
          ? _self.lateFeeHourly
          : lateFeeHourly // ignore: cast_nullable_to_non_nullable
              as double?,
      gracePeriodHours: freezed == gracePeriodHours
          ? _self.gracePeriodHours
          : gracePeriodHours // ignore: cast_nullable_to_non_nullable
              as int?,
      allowExtension: null == allowExtension
          ? _self.allowExtension
          : allowExtension // ignore: cast_nullable_to_non_nullable
              as bool,
      allowPause: null == allowPause
          ? _self.allowPause
          : allowPause // ignore: cast_nullable_to_non_nullable
              as bool,
      maxConcurrentRentals: null == maxConcurrentRentals
          ? _self.maxConcurrentRentals
          : maxConcurrentRentals // ignore: cast_nullable_to_non_nullable
              as int,
      minBatteryCheckout: null == minBatteryCheckout
          ? _self.minBatteryCheckout
          : minBatteryCheckout // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$StationDefaultsState {
  bool get isLoading;
  bool get isUpdating;
  bool get isRealTime;
  String? get error;
  StationDefaultsDto? get data;

  /// Create a copy of StationDefaultsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StationDefaultsStateCopyWith<StationDefaultsState> get copyWith =>
      _$StationDefaultsStateCopyWithImpl<StationDefaultsState>(
          this as StationDefaultsState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StationDefaultsState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isUpdating, isUpdating) ||
                other.isUpdating == isUpdating) &&
            (identical(other.isRealTime, isRealTime) ||
                other.isRealTime == isRealTime) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isLoading, isUpdating, isRealTime, error, data);

  @override
  String toString() {
    return 'StationDefaultsState(isLoading: $isLoading, isUpdating: $isUpdating, isRealTime: $isRealTime, error: $error, data: $data)';
  }
}

/// @nodoc
abstract mixin class $StationDefaultsStateCopyWith<$Res> {
  factory $StationDefaultsStateCopyWith(StationDefaultsState value,
          $Res Function(StationDefaultsState) _then) =
      _$StationDefaultsStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isLoading,
      bool isUpdating,
      bool isRealTime,
      String? error,
      StationDefaultsDto? data});

  $StationDefaultsDtoCopyWith<$Res>? get data;
}

/// @nodoc
class _$StationDefaultsStateCopyWithImpl<$Res>
    implements $StationDefaultsStateCopyWith<$Res> {
  _$StationDefaultsStateCopyWithImpl(this._self, this._then);

  final StationDefaultsState _self;
  final $Res Function(StationDefaultsState) _then;

  /// Create a copy of StationDefaultsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isUpdating = null,
    Object? isRealTime = null,
    Object? error = freezed,
    Object? data = freezed,
  }) {
    return _then(_self.copyWith(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdating: null == isUpdating
          ? _self.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      isRealTime: null == isRealTime
          ? _self.isRealTime
          : isRealTime // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as StationDefaultsDto?,
    ));
  }

  /// Create a copy of StationDefaultsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StationDefaultsDtoCopyWith<$Res>? get data {
    if (_self.data == null) {
      return null;
    }

    return $StationDefaultsDtoCopyWith<$Res>(_self.data!, (value) {
      return _then(_self.copyWith(data: value));
    });
  }
}

/// Adds pattern-matching-related methods to [StationDefaultsState].
extension StationDefaultsStatePatterns on StationDefaultsState {
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
    TResult Function(_StationDefaultsState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StationDefaultsState() when $default != null:
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
    TResult Function(_StationDefaultsState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StationDefaultsState():
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
    TResult? Function(_StationDefaultsState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StationDefaultsState() when $default != null:
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
    TResult Function(bool isLoading, bool isUpdating, bool isRealTime,
            String? error, StationDefaultsDto? data)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StationDefaultsState() when $default != null:
        return $default(_that.isLoading, _that.isUpdating, _that.isRealTime,
            _that.error, _that.data);
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
    TResult Function(bool isLoading, bool isUpdating, bool isRealTime,
            String? error, StationDefaultsDto? data)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StationDefaultsState():
        return $default(_that.isLoading, _that.isUpdating, _that.isRealTime,
            _that.error, _that.data);
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
    TResult? Function(bool isLoading, bool isUpdating, bool isRealTime,
            String? error, StationDefaultsDto? data)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StationDefaultsState() when $default != null:
        return $default(_that.isLoading, _that.isUpdating, _that.isRealTime,
            _that.error, _that.data);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _StationDefaultsState implements StationDefaultsState {
  const _StationDefaultsState(
      {this.isLoading = true,
      this.isUpdating = false,
      this.isRealTime = false,
      this.error,
      this.data});

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isUpdating;
  @override
  @JsonKey()
  final bool isRealTime;
  @override
  final String? error;
  @override
  final StationDefaultsDto? data;

  /// Create a copy of StationDefaultsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StationDefaultsStateCopyWith<_StationDefaultsState> get copyWith =>
      __$StationDefaultsStateCopyWithImpl<_StationDefaultsState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StationDefaultsState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isUpdating, isUpdating) ||
                other.isUpdating == isUpdating) &&
            (identical(other.isRealTime, isRealTime) ||
                other.isRealTime == isRealTime) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isLoading, isUpdating, isRealTime, error, data);

  @override
  String toString() {
    return 'StationDefaultsState(isLoading: $isLoading, isUpdating: $isUpdating, isRealTime: $isRealTime, error: $error, data: $data)';
  }
}

/// @nodoc
abstract mixin class _$StationDefaultsStateCopyWith<$Res>
    implements $StationDefaultsStateCopyWith<$Res> {
  factory _$StationDefaultsStateCopyWith(_StationDefaultsState value,
          $Res Function(_StationDefaultsState) _then) =
      __$StationDefaultsStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isUpdating,
      bool isRealTime,
      String? error,
      StationDefaultsDto? data});

  @override
  $StationDefaultsDtoCopyWith<$Res>? get data;
}

/// @nodoc
class __$StationDefaultsStateCopyWithImpl<$Res>
    implements _$StationDefaultsStateCopyWith<$Res> {
  __$StationDefaultsStateCopyWithImpl(this._self, this._then);

  final _StationDefaultsState _self;
  final $Res Function(_StationDefaultsState) _then;

  /// Create a copy of StationDefaultsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? isUpdating = null,
    Object? isRealTime = null,
    Object? error = freezed,
    Object? data = freezed,
  }) {
    return _then(_StationDefaultsState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdating: null == isUpdating
          ? _self.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      isRealTime: null == isRealTime
          ? _self.isRealTime
          : isRealTime // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as StationDefaultsDto?,
    ));
  }

  /// Create a copy of StationDefaultsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StationDefaultsDtoCopyWith<$Res>? get data {
    if (_self.data == null) {
      return null;
    }

    return $StationDefaultsDtoCopyWith<$Res>(_self.data!, (value) {
      return _then(_self.copyWith(data: value));
    });
  }
}

/// @nodoc
mixin _$InventoryRulesState {
  bool get isLoading;
  bool get isUpdating;
  bool get isRealTime;
  String? get error;
  InventoryRulesDto? get data;

  /// Create a copy of InventoryRulesState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InventoryRulesStateCopyWith<InventoryRulesState> get copyWith =>
      _$InventoryRulesStateCopyWithImpl<InventoryRulesState>(
          this as InventoryRulesState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InventoryRulesState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isUpdating, isUpdating) ||
                other.isUpdating == isUpdating) &&
            (identical(other.isRealTime, isRealTime) ||
                other.isRealTime == isRealTime) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isLoading, isUpdating, isRealTime, error, data);

  @override
  String toString() {
    return 'InventoryRulesState(isLoading: $isLoading, isUpdating: $isUpdating, isRealTime: $isRealTime, error: $error, data: $data)';
  }
}

/// @nodoc
abstract mixin class $InventoryRulesStateCopyWith<$Res> {
  factory $InventoryRulesStateCopyWith(
          InventoryRulesState value, $Res Function(InventoryRulesState) _then) =
      _$InventoryRulesStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isLoading,
      bool isUpdating,
      bool isRealTime,
      String? error,
      InventoryRulesDto? data});

  $InventoryRulesDtoCopyWith<$Res>? get data;
}

/// @nodoc
class _$InventoryRulesStateCopyWithImpl<$Res>
    implements $InventoryRulesStateCopyWith<$Res> {
  _$InventoryRulesStateCopyWithImpl(this._self, this._then);

  final InventoryRulesState _self;
  final $Res Function(InventoryRulesState) _then;

  /// Create a copy of InventoryRulesState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isUpdating = null,
    Object? isRealTime = null,
    Object? error = freezed,
    Object? data = freezed,
  }) {
    return _then(_self.copyWith(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdating: null == isUpdating
          ? _self.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      isRealTime: null == isRealTime
          ? _self.isRealTime
          : isRealTime // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as InventoryRulesDto?,
    ));
  }

  /// Create a copy of InventoryRulesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InventoryRulesDtoCopyWith<$Res>? get data {
    if (_self.data == null) {
      return null;
    }

    return $InventoryRulesDtoCopyWith<$Res>(_self.data!, (value) {
      return _then(_self.copyWith(data: value));
    });
  }
}

/// Adds pattern-matching-related methods to [InventoryRulesState].
extension InventoryRulesStatePatterns on InventoryRulesState {
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
    TResult Function(_InventoryRulesState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InventoryRulesState() when $default != null:
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
    TResult Function(_InventoryRulesState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InventoryRulesState():
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
    TResult? Function(_InventoryRulesState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InventoryRulesState() when $default != null:
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
    TResult Function(bool isLoading, bool isUpdating, bool isRealTime,
            String? error, InventoryRulesDto? data)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InventoryRulesState() when $default != null:
        return $default(_that.isLoading, _that.isUpdating, _that.isRealTime,
            _that.error, _that.data);
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
    TResult Function(bool isLoading, bool isUpdating, bool isRealTime,
            String? error, InventoryRulesDto? data)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InventoryRulesState():
        return $default(_that.isLoading, _that.isUpdating, _that.isRealTime,
            _that.error, _that.data);
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
    TResult? Function(bool isLoading, bool isUpdating, bool isRealTime,
            String? error, InventoryRulesDto? data)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InventoryRulesState() when $default != null:
        return $default(_that.isLoading, _that.isUpdating, _that.isRealTime,
            _that.error, _that.data);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _InventoryRulesState implements InventoryRulesState {
  const _InventoryRulesState(
      {this.isLoading = true,
      this.isUpdating = false,
      this.isRealTime = false,
      this.error,
      this.data});

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isUpdating;
  @override
  @JsonKey()
  final bool isRealTime;
  @override
  final String? error;
  @override
  final InventoryRulesDto? data;

  /// Create a copy of InventoryRulesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InventoryRulesStateCopyWith<_InventoryRulesState> get copyWith =>
      __$InventoryRulesStateCopyWithImpl<_InventoryRulesState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InventoryRulesState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isUpdating, isUpdating) ||
                other.isUpdating == isUpdating) &&
            (identical(other.isRealTime, isRealTime) ||
                other.isRealTime == isRealTime) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isLoading, isUpdating, isRealTime, error, data);

  @override
  String toString() {
    return 'InventoryRulesState(isLoading: $isLoading, isUpdating: $isUpdating, isRealTime: $isRealTime, error: $error, data: $data)';
  }
}

/// @nodoc
abstract mixin class _$InventoryRulesStateCopyWith<$Res>
    implements $InventoryRulesStateCopyWith<$Res> {
  factory _$InventoryRulesStateCopyWith(_InventoryRulesState value,
          $Res Function(_InventoryRulesState) _then) =
      __$InventoryRulesStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isUpdating,
      bool isRealTime,
      String? error,
      InventoryRulesDto? data});

  @override
  $InventoryRulesDtoCopyWith<$Res>? get data;
}

/// @nodoc
class __$InventoryRulesStateCopyWithImpl<$Res>
    implements _$InventoryRulesStateCopyWith<$Res> {
  __$InventoryRulesStateCopyWithImpl(this._self, this._then);

  final _InventoryRulesState _self;
  final $Res Function(_InventoryRulesState) _then;

  /// Create a copy of InventoryRulesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? isUpdating = null,
    Object? isRealTime = null,
    Object? error = freezed,
    Object? data = freezed,
  }) {
    return _then(_InventoryRulesState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdating: null == isUpdating
          ? _self.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      isRealTime: null == isRealTime
          ? _self.isRealTime
          : isRealTime // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as InventoryRulesDto?,
    ));
  }

  /// Create a copy of InventoryRulesState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InventoryRulesDtoCopyWith<$Res>? get data {
    if (_self.data == null) {
      return null;
    }

    return $InventoryRulesDtoCopyWith<$Res>(_self.data!, (value) {
      return _then(_self.copyWith(data: value));
    });
  }
}

/// @nodoc
mixin _$HolidayCalendarState {
  bool get isLoading;
  bool get isUpdating;
  String? get error;
  List<HolidayCalendarDto> get holidays;

  /// Create a copy of HolidayCalendarState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HolidayCalendarStateCopyWith<HolidayCalendarState> get copyWith =>
      _$HolidayCalendarStateCopyWithImpl<HolidayCalendarState>(
          this as HolidayCalendarState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HolidayCalendarState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isUpdating, isUpdating) ||
                other.isUpdating == isUpdating) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other.holidays, holidays));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, isUpdating, error,
      const DeepCollectionEquality().hash(holidays));

  @override
  String toString() {
    return 'HolidayCalendarState(isLoading: $isLoading, isUpdating: $isUpdating, error: $error, holidays: $holidays)';
  }
}

/// @nodoc
abstract mixin class $HolidayCalendarStateCopyWith<$Res> {
  factory $HolidayCalendarStateCopyWith(HolidayCalendarState value,
          $Res Function(HolidayCalendarState) _then) =
      _$HolidayCalendarStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isLoading,
      bool isUpdating,
      String? error,
      List<HolidayCalendarDto> holidays});
}

/// @nodoc
class _$HolidayCalendarStateCopyWithImpl<$Res>
    implements $HolidayCalendarStateCopyWith<$Res> {
  _$HolidayCalendarStateCopyWithImpl(this._self, this._then);

  final HolidayCalendarState _self;
  final $Res Function(HolidayCalendarState) _then;

  /// Create a copy of HolidayCalendarState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isUpdating = null,
    Object? error = freezed,
    Object? holidays = null,
  }) {
    return _then(_self.copyWith(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdating: null == isUpdating
          ? _self.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      holidays: null == holidays
          ? _self.holidays
          : holidays // ignore: cast_nullable_to_non_nullable
              as List<HolidayCalendarDto>,
    ));
  }
}

/// Adds pattern-matching-related methods to [HolidayCalendarState].
extension HolidayCalendarStatePatterns on HolidayCalendarState {
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
    TResult Function(_HolidayCalendarState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HolidayCalendarState() when $default != null:
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
    TResult Function(_HolidayCalendarState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HolidayCalendarState():
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
    TResult? Function(_HolidayCalendarState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HolidayCalendarState() when $default != null:
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
    TResult Function(bool isLoading, bool isUpdating, String? error,
            List<HolidayCalendarDto> holidays)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HolidayCalendarState() when $default != null:
        return $default(
            _that.isLoading, _that.isUpdating, _that.error, _that.holidays);
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
    TResult Function(bool isLoading, bool isUpdating, String? error,
            List<HolidayCalendarDto> holidays)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HolidayCalendarState():
        return $default(
            _that.isLoading, _that.isUpdating, _that.error, _that.holidays);
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
    TResult? Function(bool isLoading, bool isUpdating, String? error,
            List<HolidayCalendarDto> holidays)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HolidayCalendarState() when $default != null:
        return $default(
            _that.isLoading, _that.isUpdating, _that.error, _that.holidays);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _HolidayCalendarState implements HolidayCalendarState {
  const _HolidayCalendarState(
      {this.isLoading = true,
      this.isUpdating = false,
      this.error,
      final List<HolidayCalendarDto> holidays = const []})
      : _holidays = holidays;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isUpdating;
  @override
  final String? error;
  final List<HolidayCalendarDto> _holidays;
  @override
  @JsonKey()
  List<HolidayCalendarDto> get holidays {
    if (_holidays is EqualUnmodifiableListView) return _holidays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_holidays);
  }

  /// Create a copy of HolidayCalendarState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HolidayCalendarStateCopyWith<_HolidayCalendarState> get copyWith =>
      __$HolidayCalendarStateCopyWithImpl<_HolidayCalendarState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _HolidayCalendarState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isUpdating, isUpdating) ||
                other.isUpdating == isUpdating) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other._holidays, _holidays));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, isUpdating, error,
      const DeepCollectionEquality().hash(_holidays));

  @override
  String toString() {
    return 'HolidayCalendarState(isLoading: $isLoading, isUpdating: $isUpdating, error: $error, holidays: $holidays)';
  }
}

/// @nodoc
abstract mixin class _$HolidayCalendarStateCopyWith<$Res>
    implements $HolidayCalendarStateCopyWith<$Res> {
  factory _$HolidayCalendarStateCopyWith(_HolidayCalendarState value,
          $Res Function(_HolidayCalendarState) _then) =
      __$HolidayCalendarStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isUpdating,
      String? error,
      List<HolidayCalendarDto> holidays});
}

/// @nodoc
class __$HolidayCalendarStateCopyWithImpl<$Res>
    implements _$HolidayCalendarStateCopyWith<$Res> {
  __$HolidayCalendarStateCopyWithImpl(this._self, this._then);

  final _HolidayCalendarState _self;
  final $Res Function(_HolidayCalendarState) _then;

  /// Create a copy of HolidayCalendarState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? isUpdating = null,
    Object? error = freezed,
    Object? holidays = null,
  }) {
    return _then(_HolidayCalendarState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdating: null == isUpdating
          ? _self.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      holidays: null == holidays
          ? _self._holidays
          : holidays // ignore: cast_nullable_to_non_nullable
              as List<HolidayCalendarDto>,
    ));
  }
}

/// @nodoc
mixin _$RentalSettingsState {
  bool get isLoading;
  bool get isUpdating;
  bool get isRealTime;
  String? get error;
  RentalSettingsDto? get data;

  /// Create a copy of RentalSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RentalSettingsStateCopyWith<RentalSettingsState> get copyWith =>
      _$RentalSettingsStateCopyWithImpl<RentalSettingsState>(
          this as RentalSettingsState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RentalSettingsState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isUpdating, isUpdating) ||
                other.isUpdating == isUpdating) &&
            (identical(other.isRealTime, isRealTime) ||
                other.isRealTime == isRealTime) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isLoading, isUpdating, isRealTime, error, data);

  @override
  String toString() {
    return 'RentalSettingsState(isLoading: $isLoading, isUpdating: $isUpdating, isRealTime: $isRealTime, error: $error, data: $data)';
  }
}

/// @nodoc
abstract mixin class $RentalSettingsStateCopyWith<$Res> {
  factory $RentalSettingsStateCopyWith(
          RentalSettingsState value, $Res Function(RentalSettingsState) _then) =
      _$RentalSettingsStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isLoading,
      bool isUpdating,
      bool isRealTime,
      String? error,
      RentalSettingsDto? data});

  $RentalSettingsDtoCopyWith<$Res>? get data;
}

/// @nodoc
class _$RentalSettingsStateCopyWithImpl<$Res>
    implements $RentalSettingsStateCopyWith<$Res> {
  _$RentalSettingsStateCopyWithImpl(this._self, this._then);

  final RentalSettingsState _self;
  final $Res Function(RentalSettingsState) _then;

  /// Create a copy of RentalSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isUpdating = null,
    Object? isRealTime = null,
    Object? error = freezed,
    Object? data = freezed,
  }) {
    return _then(_self.copyWith(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdating: null == isUpdating
          ? _self.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      isRealTime: null == isRealTime
          ? _self.isRealTime
          : isRealTime // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as RentalSettingsDto?,
    ));
  }

  /// Create a copy of RentalSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RentalSettingsDtoCopyWith<$Res>? get data {
    if (_self.data == null) {
      return null;
    }

    return $RentalSettingsDtoCopyWith<$Res>(_self.data!, (value) {
      return _then(_self.copyWith(data: value));
    });
  }
}

/// Adds pattern-matching-related methods to [RentalSettingsState].
extension RentalSettingsStatePatterns on RentalSettingsState {
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
    TResult Function(_RentalSettingsState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RentalSettingsState() when $default != null:
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
    TResult Function(_RentalSettingsState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RentalSettingsState():
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
    TResult? Function(_RentalSettingsState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RentalSettingsState() when $default != null:
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
    TResult Function(bool isLoading, bool isUpdating, bool isRealTime,
            String? error, RentalSettingsDto? data)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RentalSettingsState() when $default != null:
        return $default(_that.isLoading, _that.isUpdating, _that.isRealTime,
            _that.error, _that.data);
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
    TResult Function(bool isLoading, bool isUpdating, bool isRealTime,
            String? error, RentalSettingsDto? data)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RentalSettingsState():
        return $default(_that.isLoading, _that.isUpdating, _that.isRealTime,
            _that.error, _that.data);
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
    TResult? Function(bool isLoading, bool isUpdating, bool isRealTime,
            String? error, RentalSettingsDto? data)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RentalSettingsState() when $default != null:
        return $default(_that.isLoading, _that.isUpdating, _that.isRealTime,
            _that.error, _that.data);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _RentalSettingsState implements RentalSettingsState {
  const _RentalSettingsState(
      {this.isLoading = true,
      this.isUpdating = false,
      this.isRealTime = false,
      this.error,
      this.data});

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isUpdating;
  @override
  @JsonKey()
  final bool isRealTime;
  @override
  final String? error;
  @override
  final RentalSettingsDto? data;

  /// Create a copy of RentalSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RentalSettingsStateCopyWith<_RentalSettingsState> get copyWith =>
      __$RentalSettingsStateCopyWithImpl<_RentalSettingsState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RentalSettingsState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isUpdating, isUpdating) ||
                other.isUpdating == isUpdating) &&
            (identical(other.isRealTime, isRealTime) ||
                other.isRealTime == isRealTime) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isLoading, isUpdating, isRealTime, error, data);

  @override
  String toString() {
    return 'RentalSettingsState(isLoading: $isLoading, isUpdating: $isUpdating, isRealTime: $isRealTime, error: $error, data: $data)';
  }
}

/// @nodoc
abstract mixin class _$RentalSettingsStateCopyWith<$Res>
    implements $RentalSettingsStateCopyWith<$Res> {
  factory _$RentalSettingsStateCopyWith(_RentalSettingsState value,
          $Res Function(_RentalSettingsState) _then) =
      __$RentalSettingsStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isUpdating,
      bool isRealTime,
      String? error,
      RentalSettingsDto? data});

  @override
  $RentalSettingsDtoCopyWith<$Res>? get data;
}

/// @nodoc
class __$RentalSettingsStateCopyWithImpl<$Res>
    implements _$RentalSettingsStateCopyWith<$Res> {
  __$RentalSettingsStateCopyWithImpl(this._self, this._then);

  final _RentalSettingsState _self;
  final $Res Function(_RentalSettingsState) _then;

  /// Create a copy of RentalSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? isUpdating = null,
    Object? isRealTime = null,
    Object? error = freezed,
    Object? data = freezed,
  }) {
    return _then(_RentalSettingsState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdating: null == isUpdating
          ? _self.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      isRealTime: null == isRealTime
          ? _self.isRealTime
          : isRealTime // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      data: freezed == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as RentalSettingsDto?,
    ));
  }

  /// Create a copy of RentalSettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RentalSettingsDtoCopyWith<$Res>? get data {
    if (_self.data == null) {
      return null;
    }

    return $RentalSettingsDtoCopyWith<$Res>(_self.data!, (value) {
      return _then(_self.copyWith(data: value));
    });
  }
}

/// @nodoc
mixin _$SessionDto {
  int get id;
  @JsonKey(name: 'device_type')
  String get deviceType;
  @JsonKey(name: 'device_name')
  String? get deviceName;
  @JsonKey(name: 'ip_address')
  String? get ipAddress;
  @JsonKey(name: 'last_active_at')
  DateTime get lastActiveAt;
  @JsonKey(name: 'is_current')
  bool get isCurrent;
  @JsonKey(name: 'is_active')
  bool get isActive;
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  String? get location;

  /// Create a copy of SessionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SessionDtoCopyWith<SessionDto> get copyWith =>
      _$SessionDtoCopyWithImpl<SessionDto>(this as SessionDto, _$identity);

  /// Serializes this SessionDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SessionDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType) &&
            (identical(other.deviceName, deviceName) ||
                other.deviceName == deviceName) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.lastActiveAt, lastActiveAt) ||
                other.lastActiveAt == lastActiveAt) &&
            (identical(other.isCurrent, isCurrent) ||
                other.isCurrent == isCurrent) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.location, location) ||
                other.location == location));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, deviceType, deviceName,
      ipAddress, lastActiveAt, isCurrent, isActive, createdAt, location);

  @override
  String toString() {
    return 'SessionDto(id: $id, deviceType: $deviceType, deviceName: $deviceName, ipAddress: $ipAddress, lastActiveAt: $lastActiveAt, isCurrent: $isCurrent, isActive: $isActive, createdAt: $createdAt, location: $location)';
  }
}

/// @nodoc
abstract mixin class $SessionDtoCopyWith<$Res> {
  factory $SessionDtoCopyWith(
          SessionDto value, $Res Function(SessionDto) _then) =
      _$SessionDtoCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'device_type') String deviceType,
      @JsonKey(name: 'device_name') String? deviceName,
      @JsonKey(name: 'ip_address') String? ipAddress,
      @JsonKey(name: 'last_active_at') DateTime lastActiveAt,
      @JsonKey(name: 'is_current') bool isCurrent,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime createdAt,
      String? location});
}

/// @nodoc
class _$SessionDtoCopyWithImpl<$Res> implements $SessionDtoCopyWith<$Res> {
  _$SessionDtoCopyWithImpl(this._self, this._then);

  final SessionDto _self;
  final $Res Function(SessionDto) _then;

  /// Create a copy of SessionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deviceType = null,
    Object? deviceName = freezed,
    Object? ipAddress = freezed,
    Object? lastActiveAt = null,
    Object? isCurrent = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? location = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      deviceType: null == deviceType
          ? _self.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as String,
      deviceName: freezed == deviceName
          ? _self.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String?,
      ipAddress: freezed == ipAddress
          ? _self.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      lastActiveAt: null == lastActiveAt
          ? _self.lastActiveAt
          : lastActiveAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCurrent: null == isCurrent
          ? _self.isCurrent
          : isCurrent // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      location: freezed == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [SessionDto].
extension SessionDtoPatterns on SessionDto {
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
    TResult Function(_SessionDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SessionDto() when $default != null:
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
    TResult Function(_SessionDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SessionDto():
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
    TResult? Function(_SessionDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SessionDto() when $default != null:
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
            @JsonKey(name: 'device_type') String deviceType,
            @JsonKey(name: 'device_name') String? deviceName,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'last_active_at') DateTime lastActiveAt,
            @JsonKey(name: 'is_current') bool isCurrent,
            @JsonKey(name: 'is_active') bool isActive,
            @JsonKey(name: 'created_at') DateTime createdAt,
            String? location)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SessionDto() when $default != null:
        return $default(
            _that.id,
            _that.deviceType,
            _that.deviceName,
            _that.ipAddress,
            _that.lastActiveAt,
            _that.isCurrent,
            _that.isActive,
            _that.createdAt,
            _that.location);
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
            @JsonKey(name: 'device_type') String deviceType,
            @JsonKey(name: 'device_name') String? deviceName,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'last_active_at') DateTime lastActiveAt,
            @JsonKey(name: 'is_current') bool isCurrent,
            @JsonKey(name: 'is_active') bool isActive,
            @JsonKey(name: 'created_at') DateTime createdAt,
            String? location)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SessionDto():
        return $default(
            _that.id,
            _that.deviceType,
            _that.deviceName,
            _that.ipAddress,
            _that.lastActiveAt,
            _that.isCurrent,
            _that.isActive,
            _that.createdAt,
            _that.location);
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
            @JsonKey(name: 'device_type') String deviceType,
            @JsonKey(name: 'device_name') String? deviceName,
            @JsonKey(name: 'ip_address') String? ipAddress,
            @JsonKey(name: 'last_active_at') DateTime lastActiveAt,
            @JsonKey(name: 'is_current') bool isCurrent,
            @JsonKey(name: 'is_active') bool isActive,
            @JsonKey(name: 'created_at') DateTime createdAt,
            String? location)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SessionDto() when $default != null:
        return $default(
            _that.id,
            _that.deviceType,
            _that.deviceName,
            _that.ipAddress,
            _that.lastActiveAt,
            _that.isCurrent,
            _that.isActive,
            _that.createdAt,
            _that.location);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SessionDto implements SessionDto {
  const _SessionDto(
      {required this.id,
      @JsonKey(name: 'device_type') required this.deviceType,
      @JsonKey(name: 'device_name') this.deviceName,
      @JsonKey(name: 'ip_address') this.ipAddress,
      @JsonKey(name: 'last_active_at') required this.lastActiveAt,
      @JsonKey(name: 'is_current') this.isCurrent = false,
      @JsonKey(name: 'is_active') this.isActive = true,
      @JsonKey(name: 'created_at') required this.createdAt,
      this.location});
  factory _SessionDto.fromJson(Map<String, dynamic> json) =>
      _$SessionDtoFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'device_type')
  final String deviceType;
  @override
  @JsonKey(name: 'device_name')
  final String? deviceName;
  @override
  @JsonKey(name: 'ip_address')
  final String? ipAddress;
  @override
  @JsonKey(name: 'last_active_at')
  final DateTime lastActiveAt;
  @override
  @JsonKey(name: 'is_current')
  final bool isCurrent;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  final String? location;

  /// Create a copy of SessionDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SessionDtoCopyWith<_SessionDto> get copyWith =>
      __$SessionDtoCopyWithImpl<_SessionDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SessionDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SessionDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.deviceType, deviceType) ||
                other.deviceType == deviceType) &&
            (identical(other.deviceName, deviceName) ||
                other.deviceName == deviceName) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.lastActiveAt, lastActiveAt) ||
                other.lastActiveAt == lastActiveAt) &&
            (identical(other.isCurrent, isCurrent) ||
                other.isCurrent == isCurrent) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.location, location) ||
                other.location == location));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, deviceType, deviceName,
      ipAddress, lastActiveAt, isCurrent, isActive, createdAt, location);

  @override
  String toString() {
    return 'SessionDto(id: $id, deviceType: $deviceType, deviceName: $deviceName, ipAddress: $ipAddress, lastActiveAt: $lastActiveAt, isCurrent: $isCurrent, isActive: $isActive, createdAt: $createdAt, location: $location)';
  }
}

/// @nodoc
abstract mixin class _$SessionDtoCopyWith<$Res>
    implements $SessionDtoCopyWith<$Res> {
  factory _$SessionDtoCopyWith(
          _SessionDto value, $Res Function(_SessionDto) _then) =
      __$SessionDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'device_type') String deviceType,
      @JsonKey(name: 'device_name') String? deviceName,
      @JsonKey(name: 'ip_address') String? ipAddress,
      @JsonKey(name: 'last_active_at') DateTime lastActiveAt,
      @JsonKey(name: 'is_current') bool isCurrent,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime createdAt,
      String? location});
}

/// @nodoc
class __$SessionDtoCopyWithImpl<$Res> implements _$SessionDtoCopyWith<$Res> {
  __$SessionDtoCopyWithImpl(this._self, this._then);

  final _SessionDto _self;
  final $Res Function(_SessionDto) _then;

  /// Create a copy of SessionDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? deviceType = null,
    Object? deviceName = freezed,
    Object? ipAddress = freezed,
    Object? lastActiveAt = null,
    Object? isCurrent = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? location = freezed,
  }) {
    return _then(_SessionDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      deviceType: null == deviceType
          ? _self.deviceType
          : deviceType // ignore: cast_nullable_to_non_nullable
              as String,
      deviceName: freezed == deviceName
          ? _self.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String?,
      ipAddress: freezed == ipAddress
          ? _self.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      lastActiveAt: null == lastActiveAt
          ? _self.lastActiveAt
          : lastActiveAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isCurrent: null == isCurrent
          ? _self.isCurrent
          : isCurrent // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      location: freezed == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$SessionsState {
  bool get isLoading;
  int? get revokingSessionId;
  bool get isAscending;
  String? get error;
  List<SessionDto> get sessions;

  /// Create a copy of SessionsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SessionsStateCopyWith<SessionsState> get copyWith =>
      _$SessionsStateCopyWithImpl<SessionsState>(
          this as SessionsState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SessionsState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.revokingSessionId, revokingSessionId) ||
                other.revokingSessionId == revokingSessionId) &&
            (identical(other.isAscending, isAscending) ||
                other.isAscending == isAscending) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other.sessions, sessions));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, revokingSessionId,
      isAscending, error, const DeepCollectionEquality().hash(sessions));

  @override
  String toString() {
    return 'SessionsState(isLoading: $isLoading, revokingSessionId: $revokingSessionId, isAscending: $isAscending, error: $error, sessions: $sessions)';
  }
}

/// @nodoc
abstract mixin class $SessionsStateCopyWith<$Res> {
  factory $SessionsStateCopyWith(
          SessionsState value, $Res Function(SessionsState) _then) =
      _$SessionsStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isLoading,
      int? revokingSessionId,
      bool isAscending,
      String? error,
      List<SessionDto> sessions});
}

/// @nodoc
class _$SessionsStateCopyWithImpl<$Res>
    implements $SessionsStateCopyWith<$Res> {
  _$SessionsStateCopyWithImpl(this._self, this._then);

  final SessionsState _self;
  final $Res Function(SessionsState) _then;

  /// Create a copy of SessionsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? revokingSessionId = freezed,
    Object? isAscending = null,
    Object? error = freezed,
    Object? sessions = null,
  }) {
    return _then(_self.copyWith(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      revokingSessionId: freezed == revokingSessionId
          ? _self.revokingSessionId
          : revokingSessionId // ignore: cast_nullable_to_non_nullable
              as int?,
      isAscending: null == isAscending
          ? _self.isAscending
          : isAscending // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      sessions: null == sessions
          ? _self.sessions
          : sessions // ignore: cast_nullable_to_non_nullable
              as List<SessionDto>,
    ));
  }
}

/// Adds pattern-matching-related methods to [SessionsState].
extension SessionsStatePatterns on SessionsState {
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
    TResult Function(_SessionsState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SessionsState() when $default != null:
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
    TResult Function(_SessionsState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SessionsState():
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
    TResult? Function(_SessionsState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SessionsState() when $default != null:
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
    TResult Function(bool isLoading, int? revokingSessionId, bool isAscending,
            String? error, List<SessionDto> sessions)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SessionsState() when $default != null:
        return $default(_that.isLoading, _that.revokingSessionId,
            _that.isAscending, _that.error, _that.sessions);
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
    TResult Function(bool isLoading, int? revokingSessionId, bool isAscending,
            String? error, List<SessionDto> sessions)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SessionsState():
        return $default(_that.isLoading, _that.revokingSessionId,
            _that.isAscending, _that.error, _that.sessions);
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
    TResult? Function(bool isLoading, int? revokingSessionId, bool isAscending,
            String? error, List<SessionDto> sessions)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SessionsState() when $default != null:
        return $default(_that.isLoading, _that.revokingSessionId,
            _that.isAscending, _that.error, _that.sessions);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _SessionsState implements SessionsState {
  const _SessionsState(
      {this.isLoading = true,
      this.revokingSessionId,
      this.isAscending = false,
      this.error,
      final List<SessionDto> sessions = const []})
      : _sessions = sessions;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final int? revokingSessionId;
  @override
  @JsonKey()
  final bool isAscending;
  @override
  final String? error;
  final List<SessionDto> _sessions;
  @override
  @JsonKey()
  List<SessionDto> get sessions {
    if (_sessions is EqualUnmodifiableListView) return _sessions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sessions);
  }

  /// Create a copy of SessionsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SessionsStateCopyWith<_SessionsState> get copyWith =>
      __$SessionsStateCopyWithImpl<_SessionsState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SessionsState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.revokingSessionId, revokingSessionId) ||
                other.revokingSessionId == revokingSessionId) &&
            (identical(other.isAscending, isAscending) ||
                other.isAscending == isAscending) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other._sessions, _sessions));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, revokingSessionId,
      isAscending, error, const DeepCollectionEquality().hash(_sessions));

  @override
  String toString() {
    return 'SessionsState(isLoading: $isLoading, revokingSessionId: $revokingSessionId, isAscending: $isAscending, error: $error, sessions: $sessions)';
  }
}

/// @nodoc
abstract mixin class _$SessionsStateCopyWith<$Res>
    implements $SessionsStateCopyWith<$Res> {
  factory _$SessionsStateCopyWith(
          _SessionsState value, $Res Function(_SessionsState) _then) =
      __$SessionsStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      int? revokingSessionId,
      bool isAscending,
      String? error,
      List<SessionDto> sessions});
}

/// @nodoc
class __$SessionsStateCopyWithImpl<$Res>
    implements _$SessionsStateCopyWith<$Res> {
  __$SessionsStateCopyWithImpl(this._self, this._then);

  final _SessionsState _self;
  final $Res Function(_SessionsState) _then;

  /// Create a copy of SessionsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? revokingSessionId = freezed,
    Object? isAscending = null,
    Object? error = freezed,
    Object? sessions = null,
  }) {
    return _then(_SessionsState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      revokingSessionId: freezed == revokingSessionId
          ? _self.revokingSessionId
          : revokingSessionId // ignore: cast_nullable_to_non_nullable
              as int?,
      isAscending: null == isAscending
          ? _self.isAscending
          : isAscending // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      sessions: null == sessions
          ? _self._sessions
          : sessions // ignore: cast_nullable_to_non_nullable
              as List<SessionDto>,
    ));
  }
}

// dart format on
