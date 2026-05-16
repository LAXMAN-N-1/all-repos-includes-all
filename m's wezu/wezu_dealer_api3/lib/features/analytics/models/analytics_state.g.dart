// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnalyticsTrendPoint _$AnalyticsTrendPointFromJson(Map<String, dynamic> json) =>
    _AnalyticsTrendPoint(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
    );

Map<String, dynamic> _$AnalyticsTrendPointToJson(
        _AnalyticsTrendPoint instance) =>
    <String, dynamic>{
      'label': instance.label,
      'value': instance.value,
    };

_AnalyticsStationUtilization _$AnalyticsStationUtilizationFromJson(
        Map<String, dynamic> json) =>
    _AnalyticsStationUtilization(
      name: json['name'] as String,
      utilization: (json['utilization'] as num).toDouble(),
    );

Map<String, dynamic> _$AnalyticsStationUtilizationToJson(
        _AnalyticsStationUtilization instance) =>
    <String, dynamic>{
      'name': instance.name,
      'utilization': instance.utilization,
    };

_AnalyticsBatteryHealth _$AnalyticsBatteryHealthFromJson(
        Map<String, dynamic> json) =>
    _AnalyticsBatteryHealth(
      good: (json['good'] as num?)?.toDouble() ?? 0.0,
      degraded: (json['degraded'] as num?)?.toDouble() ?? 0.0,
      critical: (json['critical'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$AnalyticsBatteryHealthToJson(
        _AnalyticsBatteryHealth instance) =>
    <String, dynamic>{
      'good': instance.good,
      'degraded': instance.degraded,
      'critical': instance.critical,
    };

_AnalyticsOverviewDto _$AnalyticsOverviewDtoFromJson(
        Map<String, dynamic> json) =>
    _AnalyticsOverviewDto(
      revenue: (json['revenue'] as num).toDouble(),
      totalSwaps: (json['totalSwaps'] as num?)?.toInt() ?? 0,
      avgSwapDurationHrs:
          (json['avgSwapDurationHrs'] as num?)?.toDouble() ?? 0.0,
      customerSatisfaction:
          (json['customerSatisfaction'] as num?)?.toDouble() ?? 0.0,
      revenueTrends: json['revenueTrends'] as Map<String, dynamic>? ?? const {},
      salesPerformance:
          json['salesPerformance'] as Map<String, dynamic>? ?? const {},
      growthMetrics: (json['growthMetrics'] as num?)?.toDouble() ?? 0.0,
      revenueChartData: (json['revenueChartData'] as List<dynamic>?)
              ?.map((e) =>
                  AnalyticsTrendPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      swapChartData: (json['swapChartData'] as List<dynamic>?)
              ?.map((e) =>
                  AnalyticsTrendPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      stationUtilization: (json['stationUtilization'] as List<dynamic>?)
              ?.map((e) => AnalyticsStationUtilization.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          const [],
      batteryHealth: json['batteryHealth'] == null
          ? null
          : AnalyticsBatteryHealth.fromJson(
              json['batteryHealth'] as Map<String, dynamic>),
      peakHoursData: (json['peakHoursData'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AnalyticsOverviewDtoToJson(
        _AnalyticsOverviewDto instance) =>
    <String, dynamic>{
      'revenue': instance.revenue,
      'totalSwaps': instance.totalSwaps,
      'avgSwapDurationHrs': instance.avgSwapDurationHrs,
      'customerSatisfaction': instance.customerSatisfaction,
      'revenueTrends': instance.revenueTrends,
      'salesPerformance': instance.salesPerformance,
      'growthMetrics': instance.growthMetrics,
      'revenueChartData': instance.revenueChartData,
      'swapChartData': instance.swapChartData,
      'stationUtilization': instance.stationUtilization,
      'batteryHealth': instance.batteryHealth,
      'peakHoursData': instance.peakHoursData,
    };
