import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_response.dart';
import '../models/analytics_state.dart';

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier(ref.watch(dioProvider));
});

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final Dio _dio;
  AnalyticsNotifier(this._dio) : super(const AnalyticsState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get(ApiConstants.analyticsOverview);

      // DealerAnalyticsService.get_overview returns flat dict
      final raw = ApiResponse.asMap(response.data);

      final parsed = AnalyticsOverviewDto(
        revenue: _toDouble(raw['revenue_month'] ?? raw['revenue_this_month'] ?? raw['total_revenue']),
        totalSwaps: _toInt(raw['swaps_month'] ?? raw['swaps_today'] ?? raw['total_swaps']),
        avgSwapDurationHrs: _toDouble(raw['avg_swap_duration_hrs'] ?? raw['avg_duration'] ?? 0.0),
        customerSatisfaction: _toDouble(raw['avg_rating'] ?? raw['customer_satisfaction'] ?? 0.0),
        revenueTrends: (raw['revenue_trends'] is Map) ? Map<String, dynamic>.from(raw['revenue_trends']) : {},
        salesPerformance: (raw['sales_performance'] is Map) ? Map<String, dynamic>.from(raw['sales_performance']) : {},
        growthMetrics: _toDouble(raw['growth_metrics'] ?? raw['growth']),
      );

      state = state.copyWith(isLoading: false, overview: parsed);
    } on DioException catch (e) {
      log('Analytics API Error: ${e.message}', error: e);
      state = state.copyWith(
        isLoading: false,
        error: ApiResponse.errorMessage(e, fallback: 'Failed to load analytics'),
      );
    } catch (e) {
      log('Analytics Error: $e');
      state = state.copyWith(isLoading: false, error: 'Unexpected error');
    }
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}
