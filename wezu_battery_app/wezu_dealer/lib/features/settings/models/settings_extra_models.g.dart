// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_extra_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StationDefaultsDto _$StationDefaultsDtoFromJson(Map<String, dynamic> json) =>
    _StationDefaultsDto(
      stationOpenTime: json['station_open_time'] as String?,
      stationCloseTime: json['station_close_time'] as String?,
      batteryCapacity: json['battery_capacity'] as String?,
      lowStockThreshold: json['low_stock_threshold'] as String?,
      chargingRules: json['charging_rules'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$StationDefaultsDtoToJson(_StationDefaultsDto instance) =>
    <String, dynamic>{
      'station_open_time': instance.stationOpenTime,
      'station_close_time': instance.stationCloseTime,
      'battery_capacity': instance.batteryCapacity,
      'low_stock_threshold': instance.lowStockThreshold,
      'charging_rules': instance.chargingRules,
    };

_InventoryRulesDto _$InventoryRulesDtoFromJson(Map<String, dynamic> json) =>
    _InventoryRulesDto(
      alertOfflineVal: json['alert_offline_val'] as String?,
      alertAnomalyVal: json['alert_anomaly_val'] as String?,
      autoReorderEnabled: json['auto_reorder_enabled'] as bool? ?? false,
      reorderThreshold: (json['reorder_threshold'] as num?)?.toInt(),
    );

Map<String, dynamic> _$InventoryRulesDtoToJson(_InventoryRulesDto instance) =>
    <String, dynamic>{
      'alert_offline_val': instance.alertOfflineVal,
      'alert_anomaly_val': instance.alertAnomalyVal,
      'auto_reorder_enabled': instance.autoReorderEnabled,
      'reorder_threshold': instance.reorderThreshold,
    };

_HolidayCalendarDto _$HolidayCalendarDtoFromJson(Map<String, dynamic> json) =>
    _HolidayCalendarDto(
      name: json['name'] as String,
      date: json['date'] as String,
      description: json['description'] as String?,
      isNational: json['is_national'] as bool? ?? false,
    );

Map<String, dynamic> _$HolidayCalendarDtoToJson(_HolidayCalendarDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'date': instance.date,
      'description': instance.description,
      'is_national': instance.isNational,
    };

_RentalSettingsDto _$RentalSettingsDtoFromJson(Map<String, dynamic> json) =>
    _RentalSettingsDto(
      dailyRate: (json['daily_rate'] as num?)?.toDouble(),
      securityDeposit: (json['security_deposit'] as num?)?.toDouble(),
      lateFeeHourly: (json['late_fee_hourly'] as num?)?.toDouble(),
      gracePeriodHours: (json['grace_period_hours'] as num?)?.toInt(),
      allowExtension: json['allow_extension'] as bool? ?? true,
      allowPause: json['allow_pause'] as bool? ?? false,
      maxConcurrentRentals:
          (json['max_concurrent_rentals'] as num?)?.toInt() ?? 1,
      minBatteryCheckout: (json['min_battery_checkout'] as num?)?.toInt() ?? 80,
    );

Map<String, dynamic> _$RentalSettingsDtoToJson(_RentalSettingsDto instance) =>
    <String, dynamic>{
      'daily_rate': instance.dailyRate,
      'security_deposit': instance.securityDeposit,
      'late_fee_hourly': instance.lateFeeHourly,
      'grace_period_hours': instance.gracePeriodHours,
      'allow_extension': instance.allowExtension,
      'allow_pause': instance.allowPause,
      'max_concurrent_rentals': instance.maxConcurrentRentals,
      'min_battery_checkout': instance.minBatteryCheckout,
    };

_SessionDto _$SessionDtoFromJson(Map<String, dynamic> json) => _SessionDto(
      id: (json['id'] as num).toInt(),
      deviceType: json['device_type'] as String,
      deviceName: json['device_name'] as String?,
      ipAddress: json['ip_address'] as String?,
      lastActiveAt: DateTime.parse(json['last_active_at'] as String),
      isCurrent: json['is_current'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      location: json['location'] as String?,
    );

Map<String, dynamic> _$SessionDtoToJson(_SessionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'device_type': instance.deviceType,
      'device_name': instance.deviceName,
      'ip_address': instance.ipAddress,
      'last_active_at': instance.lastActiveAt.toIso8601String(),
      'is_current': instance.isCurrent,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'location': instance.location,
    };
