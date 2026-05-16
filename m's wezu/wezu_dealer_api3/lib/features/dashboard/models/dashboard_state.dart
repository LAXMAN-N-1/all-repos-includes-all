import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_state.freezed.dart';
part 'dashboard_state.g.dart';

@freezed
abstract class DashboardMetrics with _$DashboardMetrics {
  const factory DashboardMetrics({
    @Default(0) int totalBatteries,
    @Default(0) int totalDamaged,
    @Default(0) int activeRentals,
    @Default(0.0) double revenueThisMonth,
    @Default(0) int totalStations,
    @Default(0) int activeStations,
    @Default(0) int openTickets,
    @Default(0.0) double customerSatisfaction,
    @Default(0) int totalSales,
    String? batteryUsageStats,
    @Default([]) List<InventorySummary> inventorySummary,
    @Default([]) List<double> weeklyRevenue,
    @Default([]) List<String> weeklyDays,
  }) = _DashboardMetrics;

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) =>
      _$DashboardMetricsFromJson(json);
}

@freezed
abstract class InventorySummary with _$InventorySummary {
  const factory InventorySummary({
    required String batteryModel,
    required int available,
    required int reserved,
    required int damaged,
  }) = _InventorySummary;

  factory InventorySummary.fromJson(Map<String, dynamic> json) =>
      _$InventorySummaryFromJson(json);
}

@freezed
abstract class DashboardAlert with _$DashboardAlert {
  const factory DashboardAlert({
    required String type,
    required String severity,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) = _DashboardAlert;

  factory DashboardAlert.fromJson(Map<String, dynamic> json) =>
      _$DashboardAlertFromJson(json);
}

@freezed
abstract class DashboardActivity with _$DashboardActivity {
  const factory DashboardActivity({
    required int id,
    required String type,
    required String title,
    required String message,
    required bool isRead,
    required String createdAt,
  }) = _DashboardActivity;

  factory DashboardActivity.fromJson(Map<String, dynamic> json) =>
      _$DashboardActivityFromJson(json);
}

@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    @Default(true) bool isLoading,
    String? error,
    DashboardMetrics? metrics,
    @Default([]) List<DashboardAlert> alerts,
    @Default([]) List<DashboardActivity> activityFeed,
  }) = _DashboardState;
}
