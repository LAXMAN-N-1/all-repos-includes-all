import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_state.freezed.dart';
part 'analytics_state.g.dart';

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
