// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
    };
