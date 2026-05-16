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
      // Fetch overview + trends in parallel
      final results = await Future.wait([
        _safeFetch(ApiConstants.analyticsOverview),
        _safeFetch(ApiConstants.analyticsTrends),
        _safeFetch(ApiConstants.analyticsStations),
      ]);

      final raw = ApiResponse.asMap(results[0]);
      final trendsRaw = ApiResponse.asMap(results[1]);
      final stationsRaw = results[2];

      // ── Revenue chart data ────────────────────────────────
      final revenueChartData = _parseTrendPoints(
        raw['revenue_trend'] ?? raw['revenue_trends'] ??
        trendsRaw['weekly_revenue'] ?? trendsRaw['revenue_trend'] ?? trendsRaw['data'],
        valueKeys: const ['revenue', 'amount', 'value'],
        labelKeys: const ['day', 'date', 'label', 'period'],
      );

      // ── Swap volume chart data ────────────────────────────
      final swapChartData = _parseTrendPoints(
        raw['swap_trend'] ?? raw['swaps_trend'] ??
        trendsRaw['weekly_swaps'] ?? trendsRaw['swap_trend'],
        valueKeys: const ['swaps', 'count', 'value'],
        labelKeys: const ['day', 'date', 'label'],
      );

      // ── Station utilization ───────────────────────────────
      final stationUtilization = _parseStationUtilization(
        raw['station_utilization'] ?? stationsRaw,
      );

      // ── Battery health breakdown ──────────────────────────
      final batteryHealth = _parseBatteryHealth(
        raw['battery_health'] ?? raw['battery_health_breakdown'],
      );

      // ── Peak hours (list of 24 hourly intensities) ────────
      final peakHoursData = _parsePeakHours(
        raw['peak_hours'] ?? raw['hourly_activity'],
      );

      final parsed = AnalyticsOverviewDto(
        revenue: _toDouble(raw['revenue_month'] ?? raw['revenue_this_month'] ?? raw['total_revenue']),
        totalSwaps: _toInt(raw['swaps_month'] ?? raw['swaps_today'] ?? raw['total_swaps']),
        avgSwapDurationHrs: _toDouble(raw['avg_swap_duration_hrs'] ?? raw['avg_duration'] ?? 0.0),
        customerSatisfaction: _toDouble(raw['avg_rating'] ?? raw['customer_satisfaction'] ?? 0.0),
        revenueTrends: (raw['revenue_trends'] is Map) ? Map<String, dynamic>.from(raw['revenue_trends'] as Map) : {},
        salesPerformance: (raw['sales_performance'] is Map) ? Map<String, dynamic>.from(raw['sales_performance'] as Map) : {},
        growthMetrics: _toDouble(raw['growth_metrics'] ?? raw['growth']),
        revenueChartData: revenueChartData,
        swapChartData: swapChartData,
        stationUtilization: stationUtilization,
        batteryHealth: batteryHealth,
        peakHoursData: peakHoursData,
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
      state = state.copyWith(isLoading: false, error: 'Failed to load analytics data.');
    }
  }

  Future<dynamic> _safeFetch(String url) async {
    try {
      final response = await _dio.get(url);
      return response.data;
    } catch (e) {
      log('Analytics sub-fetch failed ($url): $e');
      return {};
    }
  }

  /// Parse a raw list/map of trend data into [AnalyticsTrendPoint] list
  List<AnalyticsTrendPoint> _parseTrendPoints(
    dynamic raw, {
    required List<String> valueKeys,
    required List<String> labelKeys,
  }) {
    if (raw == null) return [];
    if (raw is List) {
      return raw.whereType<Map>().map((e) {
        final valueKey = valueKeys.firstWhere((k) => e.containsKey(k), orElse: () => '');
        final labelKey = labelKeys.firstWhere((k) => e.containsKey(k), orElse: () => '');
        return AnalyticsTrendPoint(
          label: labelKey.isNotEmpty ? (e[labelKey]?.toString() ?? '') : '',
          value: _toDouble(valueKey.isNotEmpty ? e[valueKey] : 0),
        );
      }).toList();
    }
    if (raw is Map) {
      // e.g. {"Mon": 1200, "Tue": 1500, ...}
      return raw.entries.map((entry) => AnalyticsTrendPoint(
        label: entry.key.toString(),
        value: _toDouble(entry.value),
      )).toList();
    }
    return [];
  }

  List<AnalyticsStationUtilization> _parseStationUtilization(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw.whereType<Map>().map((e) => AnalyticsStationUtilization(
        name: e['station_name']?.toString() ?? e['name']?.toString() ?? 'Station',
        utilization: _toDouble(e['utilization'] ?? e['utilization_rate'] ?? e['rate']),
      )).toList();
    }
    return [];
  }

  AnalyticsBatteryHealth? _parseBatteryHealth(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map) {
      return AnalyticsBatteryHealth(
        good: _toDouble(raw['good'] ?? raw['healthy'] ?? 0),
        degraded: _toDouble(raw['degraded'] ?? raw['fair'] ?? raw['warning'] ?? 0),
        critical: _toDouble(raw['critical'] ?? raw['poor'] ?? raw['bad'] ?? 0),
      );
    }
    return null;
  }

  List<double> _parsePeakHours(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw.map<double>(_toDouble).toList();
    }
    if (raw is Map) {
      // e.g. {"0": 5, "1": 2, ... "23": 8}
      final result = List<double>.filled(24, 0.0);
      raw.forEach((k, v) {
        final hour = int.tryParse(k.toString());
        if (hour != null && hour >= 0 && hour < 24) {
          result[hour] = _toDouble(v);
        }
      });
      return result;
    }
    return [];
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
