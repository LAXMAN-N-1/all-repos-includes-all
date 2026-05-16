import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_extra_models.freezed.dart';
part 'settings_extra_models.g.dart';

@freezed
abstract class StationDefaultsDto with _$StationDefaultsDto {
  const factory StationDefaultsDto({
    @JsonKey(name: 'station_open_time') String? stationOpenTime,
    @JsonKey(name: 'station_close_time') String? stationCloseTime,
    @JsonKey(name: 'battery_capacity') String? batteryCapacity,
    @JsonKey(name: 'low_stock_threshold') String? lowStockThreshold,
    @JsonKey(name: 'charging_rules') Map<String, dynamic>? chargingRules,
  }) = _StationDefaultsDto;

  factory StationDefaultsDto.fromJson(Map<String, dynamic> json) =>
      _$StationDefaultsDtoFromJson(json);
}

@freezed
abstract class InventoryRulesDto with _$InventoryRulesDto {
  const factory InventoryRulesDto({
    @JsonKey(name: 'alert_offline_val') String? alertOfflineVal,
    @JsonKey(name: 'alert_anomaly_val') String? alertAnomalyVal,
    @JsonKey(name: 'auto_reorder_enabled')
    @Default(false)
    bool autoReorderEnabled,
    @JsonKey(name: 'reorder_threshold') int? reorderThreshold,
  }) = _InventoryRulesDto;

  factory InventoryRulesDto.fromJson(Map<String, dynamic> json) =>
      _$InventoryRulesDtoFromJson(json);
}

@freezed
abstract class HolidayCalendarDto with _$HolidayCalendarDto {
  const factory HolidayCalendarDto({
    required String name,
    required String date,
    String? description,
    @JsonKey(name: 'is_national') @Default(false) bool isNational,
  }) = _HolidayCalendarDto;

  factory HolidayCalendarDto.fromJson(Map<String, dynamic> json) =>
      _$HolidayCalendarDtoFromJson(json);
}

@freezed
abstract class RentalSettingsDto with _$RentalSettingsDto {
  const factory RentalSettingsDto({
    @JsonKey(name: 'daily_rate') double? dailyRate,
    @JsonKey(name: 'security_deposit') double? securityDeposit,
    @JsonKey(name: 'late_fee_hourly') double? lateFeeHourly,
    @JsonKey(name: 'grace_period_hours') int? gracePeriodHours,
    @JsonKey(name: 'allow_extension') @Default(true) bool allowExtension,
    @JsonKey(name: 'allow_pause') @Default(false) bool allowPause,
    @JsonKey(name: 'max_concurrent_rentals')
    @Default(1)
    int maxConcurrentRentals,
    @JsonKey(name: 'min_battery_checkout') @Default(80) int minBatteryCheckout,
  }) = _RentalSettingsDto;

  factory RentalSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$RentalSettingsDtoFromJson(json);
}

@freezed
abstract class StationDefaultsState with _$StationDefaultsState {
  const factory StationDefaultsState({
    @Default(true) bool isLoading,
    @Default(false) bool isUpdating,
    @Default(false) bool isRealTime,
    String? error,
    StationDefaultsDto? data,
  }) = _StationDefaultsState;
}

@freezed
abstract class InventoryRulesState with _$InventoryRulesState {
  const factory InventoryRulesState({
    @Default(true) bool isLoading,
    @Default(false) bool isUpdating,
    @Default(false) bool isRealTime,
    String? error,
    InventoryRulesDto? data,
  }) = _InventoryRulesState;
}

@freezed
abstract class HolidayCalendarState with _$HolidayCalendarState {
  const factory HolidayCalendarState({
    @Default(true) bool isLoading,
    @Default(false) bool isUpdating,
    String? error,
    @Default([]) List<HolidayCalendarDto> holidays,
  }) = _HolidayCalendarState;
}

@freezed
abstract class RentalSettingsState with _$RentalSettingsState {
  const factory RentalSettingsState({
    @Default(true) bool isLoading,
    @Default(false) bool isUpdating,
    @Default(false) bool isRealTime,
    String? error,
    RentalSettingsDto? data,
  }) = _RentalSettingsState;
}

@freezed
abstract class SessionDto with _$SessionDto {
  const factory SessionDto({
    required int id,
    @JsonKey(name: 'device_type') required String deviceType,
    @JsonKey(name: 'device_name') String? deviceName,
    @JsonKey(name: 'ip_address') String? ipAddress,
    @JsonKey(name: 'last_active_at') required DateTime lastActiveAt,
    @JsonKey(name: 'is_current') @Default(false) bool isCurrent,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    String? location, // Added for UI, may be derived server-side
  }) = _SessionDto;

  factory SessionDto.fromJson(Map<String, dynamic> json) =>
      _$SessionDtoFromJson(json);
}

@freezed
abstract class SessionsState with _$SessionsState {
  const factory SessionsState({
    @Default(true) bool isLoading,
    int? revokingSessionId,
    @Default(false) bool isAscending,
    String? error,
    @Default([]) List<SessionDto> sessions,
  }) = _SessionsState;
}
