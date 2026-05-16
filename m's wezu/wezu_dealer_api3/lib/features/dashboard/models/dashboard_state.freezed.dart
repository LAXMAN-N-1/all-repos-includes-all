// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DashboardMetrics {
  int get totalBatteries;
  int get totalDamaged;
  int get activeRentals;
  double get revenueThisMonth;
  int get totalStations;
  int get activeStations;
  int get openTickets;
  double get customerSatisfaction;
  int get totalSales;
  String? get batteryUsageStats;
  List<InventorySummary> get inventorySummary;
  List<double> get weeklyRevenue;
  List<String> get weeklyDays;

  /// Create a copy of DashboardMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DashboardMetricsCopyWith<DashboardMetrics> get copyWith =>
      _$DashboardMetricsCopyWithImpl<DashboardMetrics>(
          this as DashboardMetrics, _$identity);

  /// Serializes this DashboardMetrics to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DashboardMetrics &&
            (identical(other.totalBatteries, totalBatteries) ||
                other.totalBatteries == totalBatteries) &&
            (identical(other.totalDamaged, totalDamaged) ||
                other.totalDamaged == totalDamaged) &&
            (identical(other.activeRentals, activeRentals) ||
                other.activeRentals == activeRentals) &&
            (identical(other.revenueThisMonth, revenueThisMonth) ||
                other.revenueThisMonth == revenueThisMonth) &&
            (identical(other.totalStations, totalStations) ||
                other.totalStations == totalStations) &&
            (identical(other.activeStations, activeStations) ||
                other.activeStations == activeStations) &&
            (identical(other.openTickets, openTickets) ||
                other.openTickets == openTickets) &&
            (identical(other.customerSatisfaction, customerSatisfaction) ||
                other.customerSatisfaction == customerSatisfaction) &&
            (identical(other.totalSales, totalSales) ||
                other.totalSales == totalSales) &&
            (identical(other.batteryUsageStats, batteryUsageStats) ||
                other.batteryUsageStats == batteryUsageStats) &&
            const DeepCollectionEquality()
                .equals(other.inventorySummary, inventorySummary) &&
            const DeepCollectionEquality()
                .equals(other.weeklyRevenue, weeklyRevenue) &&
            const DeepCollectionEquality()
                .equals(other.weeklyDays, weeklyDays));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalBatteries,
      totalDamaged,
      activeRentals,
      revenueThisMonth,
      totalStations,
      activeStations,
      openTickets,
      customerSatisfaction,
      totalSales,
      batteryUsageStats,
      const DeepCollectionEquality().hash(inventorySummary),
      const DeepCollectionEquality().hash(weeklyRevenue),
      const DeepCollectionEquality().hash(weeklyDays));

  @override
  String toString() {
    return 'DashboardMetrics(totalBatteries: $totalBatteries, totalDamaged: $totalDamaged, activeRentals: $activeRentals, revenueThisMonth: $revenueThisMonth, totalStations: $totalStations, activeStations: $activeStations, openTickets: $openTickets, customerSatisfaction: $customerSatisfaction, totalSales: $totalSales, batteryUsageStats: $batteryUsageStats, inventorySummary: $inventorySummary, weeklyRevenue: $weeklyRevenue, weeklyDays: $weeklyDays)';
  }
}

/// @nodoc
abstract mixin class $DashboardMetricsCopyWith<$Res> {
  factory $DashboardMetricsCopyWith(
          DashboardMetrics value, $Res Function(DashboardMetrics) _then) =
      _$DashboardMetricsCopyWithImpl;
  @useResult
  $Res call(
      {int totalBatteries,
      int totalDamaged,
      int activeRentals,
      double revenueThisMonth,
      int totalStations,
      int activeStations,
      int openTickets,
      double customerSatisfaction,
      int totalSales,
      String? batteryUsageStats,
      List<InventorySummary> inventorySummary,
      List<double> weeklyRevenue,
      List<String> weeklyDays});
}

/// @nodoc
class _$DashboardMetricsCopyWithImpl<$Res>
    implements $DashboardMetricsCopyWith<$Res> {
  _$DashboardMetricsCopyWithImpl(this._self, this._then);

  final DashboardMetrics _self;
  final $Res Function(DashboardMetrics) _then;

  /// Create a copy of DashboardMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalBatteries = null,
    Object? totalDamaged = null,
    Object? activeRentals = null,
    Object? revenueThisMonth = null,
    Object? totalStations = null,
    Object? activeStations = null,
    Object? openTickets = null,
    Object? customerSatisfaction = null,
    Object? totalSales = null,
    Object? batteryUsageStats = freezed,
    Object? inventorySummary = null,
    Object? weeklyRevenue = null,
    Object? weeklyDays = null,
  }) {
    return _then(_self.copyWith(
      totalBatteries: null == totalBatteries
          ? _self.totalBatteries
          : totalBatteries // ignore: cast_nullable_to_non_nullable
              as int,
      totalDamaged: null == totalDamaged
          ? _self.totalDamaged
          : totalDamaged // ignore: cast_nullable_to_non_nullable
              as int,
      activeRentals: null == activeRentals
          ? _self.activeRentals
          : activeRentals // ignore: cast_nullable_to_non_nullable
              as int,
      revenueThisMonth: null == revenueThisMonth
          ? _self.revenueThisMonth
          : revenueThisMonth // ignore: cast_nullable_to_non_nullable
              as double,
      totalStations: null == totalStations
          ? _self.totalStations
          : totalStations // ignore: cast_nullable_to_non_nullable
              as int,
      activeStations: null == activeStations
          ? _self.activeStations
          : activeStations // ignore: cast_nullable_to_non_nullable
              as int,
      openTickets: null == openTickets
          ? _self.openTickets
          : openTickets // ignore: cast_nullable_to_non_nullable
              as int,
      customerSatisfaction: null == customerSatisfaction
          ? _self.customerSatisfaction
          : customerSatisfaction // ignore: cast_nullable_to_non_nullable
              as double,
      totalSales: null == totalSales
          ? _self.totalSales
          : totalSales // ignore: cast_nullable_to_non_nullable
              as int,
      batteryUsageStats: freezed == batteryUsageStats
          ? _self.batteryUsageStats
          : batteryUsageStats // ignore: cast_nullable_to_non_nullable
              as String?,
      inventorySummary: null == inventorySummary
          ? _self.inventorySummary
          : inventorySummary // ignore: cast_nullable_to_non_nullable
              as List<InventorySummary>,
      weeklyRevenue: null == weeklyRevenue
          ? _self.weeklyRevenue
          : weeklyRevenue // ignore: cast_nullable_to_non_nullable
              as List<double>,
      weeklyDays: null == weeklyDays
          ? _self.weeklyDays
          : weeklyDays // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// Adds pattern-matching-related methods to [DashboardMetrics].
extension DashboardMetricsPatterns on DashboardMetrics {
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
    TResult Function(_DashboardMetrics value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DashboardMetrics() when $default != null:
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
    TResult Function(_DashboardMetrics value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardMetrics():
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
    TResult? Function(_DashboardMetrics value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardMetrics() when $default != null:
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
            int totalBatteries,
            int totalDamaged,
            int activeRentals,
            double revenueThisMonth,
            int totalStations,
            int activeStations,
            int openTickets,
            double customerSatisfaction,
            int totalSales,
            String? batteryUsageStats,
            List<InventorySummary> inventorySummary,
            List<double> weeklyRevenue,
            List<String> weeklyDays)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DashboardMetrics() when $default != null:
        return $default(
            _that.totalBatteries,
            _that.totalDamaged,
            _that.activeRentals,
            _that.revenueThisMonth,
            _that.totalStations,
            _that.activeStations,
            _that.openTickets,
            _that.customerSatisfaction,
            _that.totalSales,
            _that.batteryUsageStats,
            _that.inventorySummary,
            _that.weeklyRevenue,
            _that.weeklyDays);
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
            int totalBatteries,
            int totalDamaged,
            int activeRentals,
            double revenueThisMonth,
            int totalStations,
            int activeStations,
            int openTickets,
            double customerSatisfaction,
            int totalSales,
            String? batteryUsageStats,
            List<InventorySummary> inventorySummary,
            List<double> weeklyRevenue,
            List<String> weeklyDays)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardMetrics():
        return $default(
            _that.totalBatteries,
            _that.totalDamaged,
            _that.activeRentals,
            _that.revenueThisMonth,
            _that.totalStations,
            _that.activeStations,
            _that.openTickets,
            _that.customerSatisfaction,
            _that.totalSales,
            _that.batteryUsageStats,
            _that.inventorySummary,
            _that.weeklyRevenue,
            _that.weeklyDays);
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
            int totalBatteries,
            int totalDamaged,
            int activeRentals,
            double revenueThisMonth,
            int totalStations,
            int activeStations,
            int openTickets,
            double customerSatisfaction,
            int totalSales,
            String? batteryUsageStats,
            List<InventorySummary> inventorySummary,
            List<double> weeklyRevenue,
            List<String> weeklyDays)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardMetrics() when $default != null:
        return $default(
            _that.totalBatteries,
            _that.totalDamaged,
            _that.activeRentals,
            _that.revenueThisMonth,
            _that.totalStations,
            _that.activeStations,
            _that.openTickets,
            _that.customerSatisfaction,
            _that.totalSales,
            _that.batteryUsageStats,
            _that.inventorySummary,
            _that.weeklyRevenue,
            _that.weeklyDays);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DashboardMetrics implements DashboardMetrics {
  const _DashboardMetrics(
      {this.totalBatteries = 0,
      this.totalDamaged = 0,
      this.activeRentals = 0,
      this.revenueThisMonth = 0.0,
      this.totalStations = 0,
      this.activeStations = 0,
      this.openTickets = 0,
      this.customerSatisfaction = 0.0,
      this.totalSales = 0,
      this.batteryUsageStats,
      final List<InventorySummary> inventorySummary = const [],
      final List<double> weeklyRevenue = const [],
      final List<String> weeklyDays = const []})
      : _inventorySummary = inventorySummary,
        _weeklyRevenue = weeklyRevenue,
        _weeklyDays = weeklyDays;
  factory _DashboardMetrics.fromJson(Map<String, dynamic> json) =>
      _$DashboardMetricsFromJson(json);

  @override
  @JsonKey()
  final int totalBatteries;
  @override
  @JsonKey()
  final int totalDamaged;
  @override
  @JsonKey()
  final int activeRentals;
  @override
  @JsonKey()
  final double revenueThisMonth;
  @override
  @JsonKey()
  final int totalStations;
  @override
  @JsonKey()
  final int activeStations;
  @override
  @JsonKey()
  final int openTickets;
  @override
  @JsonKey()
  final double customerSatisfaction;
  @override
  @JsonKey()
  final int totalSales;
  @override
  final String? batteryUsageStats;
  final List<InventorySummary> _inventorySummary;
  @override
  @JsonKey()
  List<InventorySummary> get inventorySummary {
    if (_inventorySummary is EqualUnmodifiableListView)
      return _inventorySummary;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_inventorySummary);
  }

  final List<double> _weeklyRevenue;
  @override
  @JsonKey()
  List<double> get weeklyRevenue {
    if (_weeklyRevenue is EqualUnmodifiableListView) return _weeklyRevenue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weeklyRevenue);
  }

  final List<String> _weeklyDays;
  @override
  @JsonKey()
  List<String> get weeklyDays {
    if (_weeklyDays is EqualUnmodifiableListView) return _weeklyDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weeklyDays);
  }

  /// Create a copy of DashboardMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DashboardMetricsCopyWith<_DashboardMetrics> get copyWith =>
      __$DashboardMetricsCopyWithImpl<_DashboardMetrics>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DashboardMetricsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DashboardMetrics &&
            (identical(other.totalBatteries, totalBatteries) ||
                other.totalBatteries == totalBatteries) &&
            (identical(other.totalDamaged, totalDamaged) ||
                other.totalDamaged == totalDamaged) &&
            (identical(other.activeRentals, activeRentals) ||
                other.activeRentals == activeRentals) &&
            (identical(other.revenueThisMonth, revenueThisMonth) ||
                other.revenueThisMonth == revenueThisMonth) &&
            (identical(other.totalStations, totalStations) ||
                other.totalStations == totalStations) &&
            (identical(other.activeStations, activeStations) ||
                other.activeStations == activeStations) &&
            (identical(other.openTickets, openTickets) ||
                other.openTickets == openTickets) &&
            (identical(other.customerSatisfaction, customerSatisfaction) ||
                other.customerSatisfaction == customerSatisfaction) &&
            (identical(other.totalSales, totalSales) ||
                other.totalSales == totalSales) &&
            (identical(other.batteryUsageStats, batteryUsageStats) ||
                other.batteryUsageStats == batteryUsageStats) &&
            const DeepCollectionEquality()
                .equals(other._inventorySummary, _inventorySummary) &&
            const DeepCollectionEquality()
                .equals(other._weeklyRevenue, _weeklyRevenue) &&
            const DeepCollectionEquality()
                .equals(other._weeklyDays, _weeklyDays));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalBatteries,
      totalDamaged,
      activeRentals,
      revenueThisMonth,
      totalStations,
      activeStations,
      openTickets,
      customerSatisfaction,
      totalSales,
      batteryUsageStats,
      const DeepCollectionEquality().hash(_inventorySummary),
      const DeepCollectionEquality().hash(_weeklyRevenue),
      const DeepCollectionEquality().hash(_weeklyDays));

  @override
  String toString() {
    return 'DashboardMetrics(totalBatteries: $totalBatteries, totalDamaged: $totalDamaged, activeRentals: $activeRentals, revenueThisMonth: $revenueThisMonth, totalStations: $totalStations, activeStations: $activeStations, openTickets: $openTickets, customerSatisfaction: $customerSatisfaction, totalSales: $totalSales, batteryUsageStats: $batteryUsageStats, inventorySummary: $inventorySummary, weeklyRevenue: $weeklyRevenue, weeklyDays: $weeklyDays)';
  }
}

/// @nodoc
abstract mixin class _$DashboardMetricsCopyWith<$Res>
    implements $DashboardMetricsCopyWith<$Res> {
  factory _$DashboardMetricsCopyWith(
          _DashboardMetrics value, $Res Function(_DashboardMetrics) _then) =
      __$DashboardMetricsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int totalBatteries,
      int totalDamaged,
      int activeRentals,
      double revenueThisMonth,
      int totalStations,
      int activeStations,
      int openTickets,
      double customerSatisfaction,
      int totalSales,
      String? batteryUsageStats,
      List<InventorySummary> inventorySummary,
      List<double> weeklyRevenue,
      List<String> weeklyDays});
}

/// @nodoc
class __$DashboardMetricsCopyWithImpl<$Res>
    implements _$DashboardMetricsCopyWith<$Res> {
  __$DashboardMetricsCopyWithImpl(this._self, this._then);

  final _DashboardMetrics _self;
  final $Res Function(_DashboardMetrics) _then;

  /// Create a copy of DashboardMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? totalBatteries = null,
    Object? totalDamaged = null,
    Object? activeRentals = null,
    Object? revenueThisMonth = null,
    Object? totalStations = null,
    Object? activeStations = null,
    Object? openTickets = null,
    Object? customerSatisfaction = null,
    Object? totalSales = null,
    Object? batteryUsageStats = freezed,
    Object? inventorySummary = null,
    Object? weeklyRevenue = null,
    Object? weeklyDays = null,
  }) {
    return _then(_DashboardMetrics(
      totalBatteries: null == totalBatteries
          ? _self.totalBatteries
          : totalBatteries // ignore: cast_nullable_to_non_nullable
              as int,
      totalDamaged: null == totalDamaged
          ? _self.totalDamaged
          : totalDamaged // ignore: cast_nullable_to_non_nullable
              as int,
      activeRentals: null == activeRentals
          ? _self.activeRentals
          : activeRentals // ignore: cast_nullable_to_non_nullable
              as int,
      revenueThisMonth: null == revenueThisMonth
          ? _self.revenueThisMonth
          : revenueThisMonth // ignore: cast_nullable_to_non_nullable
              as double,
      totalStations: null == totalStations
          ? _self.totalStations
          : totalStations // ignore: cast_nullable_to_non_nullable
              as int,
      activeStations: null == activeStations
          ? _self.activeStations
          : activeStations // ignore: cast_nullable_to_non_nullable
              as int,
      openTickets: null == openTickets
          ? _self.openTickets
          : openTickets // ignore: cast_nullable_to_non_nullable
              as int,
      customerSatisfaction: null == customerSatisfaction
          ? _self.customerSatisfaction
          : customerSatisfaction // ignore: cast_nullable_to_non_nullable
              as double,
      totalSales: null == totalSales
          ? _self.totalSales
          : totalSales // ignore: cast_nullable_to_non_nullable
              as int,
      batteryUsageStats: freezed == batteryUsageStats
          ? _self.batteryUsageStats
          : batteryUsageStats // ignore: cast_nullable_to_non_nullable
              as String?,
      inventorySummary: null == inventorySummary
          ? _self._inventorySummary
          : inventorySummary // ignore: cast_nullable_to_non_nullable
              as List<InventorySummary>,
      weeklyRevenue: null == weeklyRevenue
          ? _self._weeklyRevenue
          : weeklyRevenue // ignore: cast_nullable_to_non_nullable
              as List<double>,
      weeklyDays: null == weeklyDays
          ? _self._weeklyDays
          : weeklyDays // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
mixin _$InventorySummary {
  String get batteryModel;
  int get available;
  int get reserved;
  int get damaged;

  /// Create a copy of InventorySummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InventorySummaryCopyWith<InventorySummary> get copyWith =>
      _$InventorySummaryCopyWithImpl<InventorySummary>(
          this as InventorySummary, _$identity);

  /// Serializes this InventorySummary to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InventorySummary &&
            (identical(other.batteryModel, batteryModel) ||
                other.batteryModel == batteryModel) &&
            (identical(other.available, available) ||
                other.available == available) &&
            (identical(other.reserved, reserved) ||
                other.reserved == reserved) &&
            (identical(other.damaged, damaged) || other.damaged == damaged));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, batteryModel, available, reserved, damaged);

  @override
  String toString() {
    return 'InventorySummary(batteryModel: $batteryModel, available: $available, reserved: $reserved, damaged: $damaged)';
  }
}

/// @nodoc
abstract mixin class $InventorySummaryCopyWith<$Res> {
  factory $InventorySummaryCopyWith(
          InventorySummary value, $Res Function(InventorySummary) _then) =
      _$InventorySummaryCopyWithImpl;
  @useResult
  $Res call({String batteryModel, int available, int reserved, int damaged});
}

/// @nodoc
class _$InventorySummaryCopyWithImpl<$Res>
    implements $InventorySummaryCopyWith<$Res> {
  _$InventorySummaryCopyWithImpl(this._self, this._then);

  final InventorySummary _self;
  final $Res Function(InventorySummary) _then;

  /// Create a copy of InventorySummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? batteryModel = null,
    Object? available = null,
    Object? reserved = null,
    Object? damaged = null,
  }) {
    return _then(_self.copyWith(
      batteryModel: null == batteryModel
          ? _self.batteryModel
          : batteryModel // ignore: cast_nullable_to_non_nullable
              as String,
      available: null == available
          ? _self.available
          : available // ignore: cast_nullable_to_non_nullable
              as int,
      reserved: null == reserved
          ? _self.reserved
          : reserved // ignore: cast_nullable_to_non_nullable
              as int,
      damaged: null == damaged
          ? _self.damaged
          : damaged // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [InventorySummary].
extension InventorySummaryPatterns on InventorySummary {
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
    TResult Function(_InventorySummary value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InventorySummary() when $default != null:
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
    TResult Function(_InventorySummary value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InventorySummary():
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
    TResult? Function(_InventorySummary value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InventorySummary() when $default != null:
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
            String batteryModel, int available, int reserved, int damaged)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InventorySummary() when $default != null:
        return $default(
            _that.batteryModel, _that.available, _that.reserved, _that.damaged);
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
            String batteryModel, int available, int reserved, int damaged)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InventorySummary():
        return $default(
            _that.batteryModel, _that.available, _that.reserved, _that.damaged);
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
            String batteryModel, int available, int reserved, int damaged)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InventorySummary() when $default != null:
        return $default(
            _that.batteryModel, _that.available, _that.reserved, _that.damaged);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _InventorySummary implements InventorySummary {
  const _InventorySummary(
      {required this.batteryModel,
      required this.available,
      required this.reserved,
      required this.damaged});
  factory _InventorySummary.fromJson(Map<String, dynamic> json) =>
      _$InventorySummaryFromJson(json);

  @override
  final String batteryModel;
  @override
  final int available;
  @override
  final int reserved;
  @override
  final int damaged;

  /// Create a copy of InventorySummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InventorySummaryCopyWith<_InventorySummary> get copyWith =>
      __$InventorySummaryCopyWithImpl<_InventorySummary>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$InventorySummaryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InventorySummary &&
            (identical(other.batteryModel, batteryModel) ||
                other.batteryModel == batteryModel) &&
            (identical(other.available, available) ||
                other.available == available) &&
            (identical(other.reserved, reserved) ||
                other.reserved == reserved) &&
            (identical(other.damaged, damaged) || other.damaged == damaged));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, batteryModel, available, reserved, damaged);

  @override
  String toString() {
    return 'InventorySummary(batteryModel: $batteryModel, available: $available, reserved: $reserved, damaged: $damaged)';
  }
}

/// @nodoc
abstract mixin class _$InventorySummaryCopyWith<$Res>
    implements $InventorySummaryCopyWith<$Res> {
  factory _$InventorySummaryCopyWith(
          _InventorySummary value, $Res Function(_InventorySummary) _then) =
      __$InventorySummaryCopyWithImpl;
  @override
  @useResult
  $Res call({String batteryModel, int available, int reserved, int damaged});
}

/// @nodoc
class __$InventorySummaryCopyWithImpl<$Res>
    implements _$InventorySummaryCopyWith<$Res> {
  __$InventorySummaryCopyWithImpl(this._self, this._then);

  final _InventorySummary _self;
  final $Res Function(_InventorySummary) _then;

  /// Create a copy of InventorySummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? batteryModel = null,
    Object? available = null,
    Object? reserved = null,
    Object? damaged = null,
  }) {
    return _then(_InventorySummary(
      batteryModel: null == batteryModel
          ? _self.batteryModel
          : batteryModel // ignore: cast_nullable_to_non_nullable
              as String,
      available: null == available
          ? _self.available
          : available // ignore: cast_nullable_to_non_nullable
              as int,
      reserved: null == reserved
          ? _self.reserved
          : reserved // ignore: cast_nullable_to_non_nullable
              as int,
      damaged: null == damaged
          ? _self.damaged
          : damaged // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$DashboardAlert {
  String get type;
  String get severity;
  String get title;
  String get message;
  Map<String, dynamic>? get data;

  /// Create a copy of DashboardAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DashboardAlertCopyWith<DashboardAlert> get copyWith =>
      _$DashboardAlertCopyWithImpl<DashboardAlert>(
          this as DashboardAlert, _$identity);

  /// Serializes this DashboardAlert to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DashboardAlert &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, severity, title, message,
      const DeepCollectionEquality().hash(data));

  @override
  String toString() {
    return 'DashboardAlert(type: $type, severity: $severity, title: $title, message: $message, data: $data)';
  }
}

/// @nodoc
abstract mixin class $DashboardAlertCopyWith<$Res> {
  factory $DashboardAlertCopyWith(
          DashboardAlert value, $Res Function(DashboardAlert) _then) =
      _$DashboardAlertCopyWithImpl;
  @useResult
  $Res call(
      {String type,
      String severity,
      String title,
      String message,
      Map<String, dynamic>? data});
}

/// @nodoc
class _$DashboardAlertCopyWithImpl<$Res>
    implements $DashboardAlertCopyWith<$Res> {
  _$DashboardAlertCopyWithImpl(this._self, this._then);

  final DashboardAlert _self;
  final $Res Function(DashboardAlert) _then;

  /// Create a copy of DashboardAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? severity = null,
    Object? title = null,
    Object? message = null,
    Object? data = freezed,
  }) {
    return _then(_self.copyWith(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _self.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      data: freezed == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// Adds pattern-matching-related methods to [DashboardAlert].
extension DashboardAlertPatterns on DashboardAlert {
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
    TResult Function(_DashboardAlert value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DashboardAlert() when $default != null:
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
    TResult Function(_DashboardAlert value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardAlert():
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
    TResult? Function(_DashboardAlert value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardAlert() when $default != null:
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
    TResult Function(String type, String severity, String title, String message,
            Map<String, dynamic>? data)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DashboardAlert() when $default != null:
        return $default(
            _that.type, _that.severity, _that.title, _that.message, _that.data);
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
    TResult Function(String type, String severity, String title, String message,
            Map<String, dynamic>? data)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardAlert():
        return $default(
            _that.type, _that.severity, _that.title, _that.message, _that.data);
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
    TResult? Function(String type, String severity, String title,
            String message, Map<String, dynamic>? data)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardAlert() when $default != null:
        return $default(
            _that.type, _that.severity, _that.title, _that.message, _that.data);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DashboardAlert implements DashboardAlert {
  const _DashboardAlert(
      {required this.type,
      required this.severity,
      required this.title,
      required this.message,
      final Map<String, dynamic>? data})
      : _data = data;
  factory _DashboardAlert.fromJson(Map<String, dynamic> json) =>
      _$DashboardAlertFromJson(json);

  @override
  final String type;
  @override
  final String severity;
  @override
  final String title;
  @override
  final String message;
  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of DashboardAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DashboardAlertCopyWith<_DashboardAlert> get copyWith =>
      __$DashboardAlertCopyWithImpl<_DashboardAlert>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DashboardAlertToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DashboardAlert &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, severity, title, message,
      const DeepCollectionEquality().hash(_data));

  @override
  String toString() {
    return 'DashboardAlert(type: $type, severity: $severity, title: $title, message: $message, data: $data)';
  }
}

/// @nodoc
abstract mixin class _$DashboardAlertCopyWith<$Res>
    implements $DashboardAlertCopyWith<$Res> {
  factory _$DashboardAlertCopyWith(
          _DashboardAlert value, $Res Function(_DashboardAlert) _then) =
      __$DashboardAlertCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String type,
      String severity,
      String title,
      String message,
      Map<String, dynamic>? data});
}

/// @nodoc
class __$DashboardAlertCopyWithImpl<$Res>
    implements _$DashboardAlertCopyWith<$Res> {
  __$DashboardAlertCopyWithImpl(this._self, this._then);

  final _DashboardAlert _self;
  final $Res Function(_DashboardAlert) _then;

  /// Create a copy of DashboardAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? type = null,
    Object? severity = null,
    Object? title = null,
    Object? message = null,
    Object? data = freezed,
  }) {
    return _then(_DashboardAlert(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _self.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      data: freezed == data
          ? _self._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
mixin _$DashboardActivity {
  int get id;
  String get type;
  String get title;
  String get message;
  bool get isRead;
  String get createdAt;

  /// Create a copy of DashboardActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DashboardActivityCopyWith<DashboardActivity> get copyWith =>
      _$DashboardActivityCopyWithImpl<DashboardActivity>(
          this as DashboardActivity, _$identity);

  /// Serializes this DashboardActivity to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DashboardActivity &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, type, title, message, isRead, createdAt);

  @override
  String toString() {
    return 'DashboardActivity(id: $id, type: $type, title: $title, message: $message, isRead: $isRead, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $DashboardActivityCopyWith<$Res> {
  factory $DashboardActivityCopyWith(
          DashboardActivity value, $Res Function(DashboardActivity) _then) =
      _$DashboardActivityCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String type,
      String title,
      String message,
      bool isRead,
      String createdAt});
}

/// @nodoc
class _$DashboardActivityCopyWithImpl<$Res>
    implements $DashboardActivityCopyWith<$Res> {
  _$DashboardActivityCopyWithImpl(this._self, this._then);

  final DashboardActivity _self;
  final $Res Function(DashboardActivity) _then;

  /// Create a copy of DashboardActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? message = null,
    Object? isRead = null,
    Object? createdAt = null,
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
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      isRead: null == isRead
          ? _self.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [DashboardActivity].
extension DashboardActivityPatterns on DashboardActivity {
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
    TResult Function(_DashboardActivity value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DashboardActivity() when $default != null:
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
    TResult Function(_DashboardActivity value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardActivity():
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
    TResult? Function(_DashboardActivity value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardActivity() when $default != null:
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
    TResult Function(int id, String type, String title, String message,
            bool isRead, String createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DashboardActivity() when $default != null:
        return $default(_that.id, _that.type, _that.title, _that.message,
            _that.isRead, _that.createdAt);
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
    TResult Function(int id, String type, String title, String message,
            bool isRead, String createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardActivity():
        return $default(_that.id, _that.type, _that.title, _that.message,
            _that.isRead, _that.createdAt);
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
    TResult? Function(int id, String type, String title, String message,
            bool isRead, String createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardActivity() when $default != null:
        return $default(_that.id, _that.type, _that.title, _that.message,
            _that.isRead, _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DashboardActivity implements DashboardActivity {
  const _DashboardActivity(
      {required this.id,
      required this.type,
      required this.title,
      required this.message,
      required this.isRead,
      required this.createdAt});
  factory _DashboardActivity.fromJson(Map<String, dynamic> json) =>
      _$DashboardActivityFromJson(json);

  @override
  final int id;
  @override
  final String type;
  @override
  final String title;
  @override
  final String message;
  @override
  final bool isRead;
  @override
  final String createdAt;

  /// Create a copy of DashboardActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DashboardActivityCopyWith<_DashboardActivity> get copyWith =>
      __$DashboardActivityCopyWithImpl<_DashboardActivity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DashboardActivityToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DashboardActivity &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, type, title, message, isRead, createdAt);

  @override
  String toString() {
    return 'DashboardActivity(id: $id, type: $type, title: $title, message: $message, isRead: $isRead, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$DashboardActivityCopyWith<$Res>
    implements $DashboardActivityCopyWith<$Res> {
  factory _$DashboardActivityCopyWith(
          _DashboardActivity value, $Res Function(_DashboardActivity) _then) =
      __$DashboardActivityCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String type,
      String title,
      String message,
      bool isRead,
      String createdAt});
}

/// @nodoc
class __$DashboardActivityCopyWithImpl<$Res>
    implements _$DashboardActivityCopyWith<$Res> {
  __$DashboardActivityCopyWithImpl(this._self, this._then);

  final _DashboardActivity _self;
  final $Res Function(_DashboardActivity) _then;

  /// Create a copy of DashboardActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? message = null,
    Object? isRead = null,
    Object? createdAt = null,
  }) {
    return _then(_DashboardActivity(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      isRead: null == isRead
          ? _self.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$DashboardState {
  bool get isLoading;
  String? get error;
  DashboardMetrics? get metrics;
  List<DashboardAlert> get alerts;
  List<DashboardActivity> get activityFeed;

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DashboardStateCopyWith<DashboardState> get copyWith =>
      _$DashboardStateCopyWithImpl<DashboardState>(
          this as DashboardState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DashboardState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.metrics, metrics) || other.metrics == metrics) &&
            const DeepCollectionEquality().equals(other.alerts, alerts) &&
            const DeepCollectionEquality()
                .equals(other.activityFeed, activityFeed));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      error,
      metrics,
      const DeepCollectionEquality().hash(alerts),
      const DeepCollectionEquality().hash(activityFeed));

  @override
  String toString() {
    return 'DashboardState(isLoading: $isLoading, error: $error, metrics: $metrics, alerts: $alerts, activityFeed: $activityFeed)';
  }
}

/// @nodoc
abstract mixin class $DashboardStateCopyWith<$Res> {
  factory $DashboardStateCopyWith(
          DashboardState value, $Res Function(DashboardState) _then) =
      _$DashboardStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isLoading,
      String? error,
      DashboardMetrics? metrics,
      List<DashboardAlert> alerts,
      List<DashboardActivity> activityFeed});

  $DashboardMetricsCopyWith<$Res>? get metrics;
}

/// @nodoc
class _$DashboardStateCopyWithImpl<$Res>
    implements $DashboardStateCopyWith<$Res> {
  _$DashboardStateCopyWithImpl(this._self, this._then);

  final DashboardState _self;
  final $Res Function(DashboardState) _then;

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? metrics = freezed,
    Object? alerts = null,
    Object? activityFeed = null,
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
      metrics: freezed == metrics
          ? _self.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as DashboardMetrics?,
      alerts: null == alerts
          ? _self.alerts
          : alerts // ignore: cast_nullable_to_non_nullable
              as List<DashboardAlert>,
      activityFeed: null == activityFeed
          ? _self.activityFeed
          : activityFeed // ignore: cast_nullable_to_non_nullable
              as List<DashboardActivity>,
    ));
  }

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DashboardMetricsCopyWith<$Res>? get metrics {
    if (_self.metrics == null) {
      return null;
    }

    return $DashboardMetricsCopyWith<$Res>(_self.metrics!, (value) {
      return _then(_self.copyWith(metrics: value));
    });
  }
}

/// Adds pattern-matching-related methods to [DashboardState].
extension DashboardStatePatterns on DashboardState {
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
    TResult Function(_DashboardState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DashboardState() when $default != null:
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
    TResult Function(_DashboardState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardState():
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
    TResult? Function(_DashboardState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardState() when $default != null:
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
    TResult Function(bool isLoading, String? error, DashboardMetrics? metrics,
            List<DashboardAlert> alerts, List<DashboardActivity> activityFeed)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DashboardState() when $default != null:
        return $default(_that.isLoading, _that.error, _that.metrics,
            _that.alerts, _that.activityFeed);
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
    TResult Function(bool isLoading, String? error, DashboardMetrics? metrics,
            List<DashboardAlert> alerts, List<DashboardActivity> activityFeed)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardState():
        return $default(_that.isLoading, _that.error, _that.metrics,
            _that.alerts, _that.activityFeed);
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
    TResult? Function(bool isLoading, String? error, DashboardMetrics? metrics,
            List<DashboardAlert> alerts, List<DashboardActivity> activityFeed)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardState() when $default != null:
        return $default(_that.isLoading, _that.error, _that.metrics,
            _that.alerts, _that.activityFeed);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _DashboardState implements DashboardState {
  const _DashboardState(
      {this.isLoading = true,
      this.error,
      this.metrics,
      final List<DashboardAlert> alerts = const [],
      final List<DashboardActivity> activityFeed = const []})
      : _alerts = alerts,
        _activityFeed = activityFeed;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  @override
  final DashboardMetrics? metrics;
  final List<DashboardAlert> _alerts;
  @override
  @JsonKey()
  List<DashboardAlert> get alerts {
    if (_alerts is EqualUnmodifiableListView) return _alerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alerts);
  }

  final List<DashboardActivity> _activityFeed;
  @override
  @JsonKey()
  List<DashboardActivity> get activityFeed {
    if (_activityFeed is EqualUnmodifiableListView) return _activityFeed;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activityFeed);
  }

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DashboardStateCopyWith<_DashboardState> get copyWith =>
      __$DashboardStateCopyWithImpl<_DashboardState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DashboardState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.metrics, metrics) || other.metrics == metrics) &&
            const DeepCollectionEquality().equals(other._alerts, _alerts) &&
            const DeepCollectionEquality()
                .equals(other._activityFeed, _activityFeed));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      error,
      metrics,
      const DeepCollectionEquality().hash(_alerts),
      const DeepCollectionEquality().hash(_activityFeed));

  @override
  String toString() {
    return 'DashboardState(isLoading: $isLoading, error: $error, metrics: $metrics, alerts: $alerts, activityFeed: $activityFeed)';
  }
}

/// @nodoc
abstract mixin class _$DashboardStateCopyWith<$Res>
    implements $DashboardStateCopyWith<$Res> {
  factory _$DashboardStateCopyWith(
          _DashboardState value, $Res Function(_DashboardState) _then) =
      __$DashboardStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      String? error,
      DashboardMetrics? metrics,
      List<DashboardAlert> alerts,
      List<DashboardActivity> activityFeed});

  @override
  $DashboardMetricsCopyWith<$Res>? get metrics;
}

/// @nodoc
class __$DashboardStateCopyWithImpl<$Res>
    implements _$DashboardStateCopyWith<$Res> {
  __$DashboardStateCopyWithImpl(this._self, this._then);

  final _DashboardState _self;
  final $Res Function(_DashboardState) _then;

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? metrics = freezed,
    Object? alerts = null,
    Object? activityFeed = null,
  }) {
    return _then(_DashboardState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      metrics: freezed == metrics
          ? _self.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as DashboardMetrics?,
      alerts: null == alerts
          ? _self._alerts
          : alerts // ignore: cast_nullable_to_non_nullable
              as List<DashboardAlert>,
      activityFeed: null == activityFeed
          ? _self._activityFeed
          : activityFeed // ignore: cast_nullable_to_non_nullable
              as List<DashboardActivity>,
    ));
  }

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DashboardMetricsCopyWith<$Res>? get metrics {
    if (_self.metrics == null) {
      return null;
    }

    return $DashboardMetricsCopyWith<$Res>(_self.metrics!, (value) {
      return _then(_self.copyWith(metrics: value));
    });
  }
}

// dart format on
