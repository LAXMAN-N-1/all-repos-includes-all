import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_state.freezed.dart';
part 'analytics_state.g.dart';

@freezed
abstract class AnalyticsTrendPoint with _$AnalyticsTrendPoint {
  const factory AnalyticsTrendPoint({
    required String label,
    required double value,
  }) = _AnalyticsTrendPoint;

  factory AnalyticsTrendPoint.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsTrendPointFromJson(json);
}

@freezed
abstract class AnalyticsStationUtilization with _$AnalyticsStationUtilization {
  const factory AnalyticsStationUtilization({
    required String name,
    required double utilization,
  }) = _AnalyticsStationUtilization;

  factory AnalyticsStationUtilization.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsStationUtilizationFromJson(json);
}

@freezed
abstract class AnalyticsBatteryHealth with _$AnalyticsBatteryHealth {
  const factory AnalyticsBatteryHealth({
    @Default(0.0) double good,
    @Default(0.0) double degraded,
    @Default(0.0) double critical,
  }) = _AnalyticsBatteryHealth;

  factory AnalyticsBatteryHealth.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsBatteryHealthFromJson(json);
}

@freezed
abstract class AnalyticsOverviewDto with _$AnalyticsOverviewDto {
  const factory AnalyticsOverviewDto({
    required double revenue,
    @Default(0) int totalSwaps,
    @Default(0.0) double avgSwapDurationHrs,
    @Default(0.0) double customerSatisfaction,
    @Default({}) Map<String, dynamic> revenueTrends,
    @Default({}) Map<String, dynamic> salesPerformance,
    @Default(0.0) double growthMetrics,
    // Chart-ready data parsed from API
    @Default([]) List<AnalyticsTrendPoint> revenueChartData,
    @Default([]) List<AnalyticsTrendPoint> swapChartData,
    @Default([]) List<AnalyticsStationUtilization> stationUtilization,
    @Default(null) AnalyticsBatteryHealth? batteryHealth,
    // Peak hours: list of 24 values (0.0–1.0 intensity per hour)
    @Default([]) List<double> peakHoursData,
  }) = _AnalyticsOverviewDto;

  factory AnalyticsOverviewDto.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsOverviewDtoFromJson(json);
}

@freezed
abstract class AnalyticsState with _$AnalyticsState {
  const factory AnalyticsState({
    @Default(true) bool isLoading,
    String? error,
    AnalyticsOverviewDto? overview,
  }) = _AnalyticsState;
}
