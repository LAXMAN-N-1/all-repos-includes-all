import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_response.dart';
import '../models/dashboard_state.dart';

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref.watch(dioProvider));
});

class DashboardNotifier extends StateNotifier<DashboardState> {
  final Dio _dio;

  DashboardNotifier(this._dio) : super(const DashboardState()) {
    refresh();
  }

  int _toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
  double _toDouble(dynamic v) => v is double ? v : double.tryParse(v?.toString() ?? '') ?? 0.0;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Fetch concurrently — each one independent so one failure doesn't crash all
      final results = await Future.wait([
        _safeFetch(ApiConstants.dashboard),
        _safeFetch(ApiConstants.alerts),
        _safeFetch(ApiConstants.activity),
        _safeFetch(ApiConstants.analyticsTrends),
      ]);

      final metricsData = ApiResponse.asMap(results[0]);
      final alertsRaw = ApiResponse.asList(results[1], keys: const ['alerts']);
      final activityRaw = ApiResponse.asList(results[2], keys: const ['data', 'activities']);

      // Parse weekly revenue from trends.
      // The /analytics/trends endpoint returns a raw List directly:
      // [{period, swaps, revenue}, ...] — NOT wrapped in a Map key.
      final List weeklyRaw;
      final raw3 = results[3];
      if (raw3 is List) {
        weeklyRaw = raw3;
      } else if (raw3 is Map) {
        weeklyRaw = (raw3['weekly_revenue'] as List?) ??
            (raw3['revenue_trend'] as List?) ??
            (raw3['data'] as List?) ??
            [];
      } else {
        weeklyRaw = [];
      }
      final weeklyRevenue = weeklyRaw.map<double>((v) =>
          _toDouble(v is Map ? (v['revenue'] ?? v['amount'] ?? v['value'] ?? 0) : v)).toList();
      final weeklyDays = weeklyRaw.map<String>((v) =>
          v is Map ? (v['period'] ?? v['day'] ?? v['date'] ?? v['label'] ?? '').toString() : '').toList();

      // Always set metrics (even if all zeros) so screen never null-crashes
      state = state.copyWith(
        isLoading: false,
        metrics: DashboardMetrics(
          totalBatteries: _toInt(metricsData['total_batteries']),
          totalDamaged: _toInt(metricsData['total_damaged']),
          activeRentals: _toInt(metricsData['active_rentals']),
          revenueThisMonth: _toDouble(metricsData['revenue_this_month']),
          totalStations: _toInt(metricsData['total_stations']),
          activeStations: _toInt(metricsData['active_stations']),
          openTickets: _toInt(metricsData['open_tickets']),
          customerSatisfaction: _toDouble(metricsData['customer_satisfaction']),
          totalSales: _toInt(metricsData['total_sales']),
          batteryUsageStats: metricsData['battery_usage_stats']?.toString(),
          inventorySummary: (metricsData['inventory_summary'] is List
                  ? metricsData['inventory_summary'] as List
                  : <dynamic>[])
              .whereType<Map>()
              .map((e) => InventorySummary(
                    batteryModel: e['battery_model']?.toString() ?? '',
                    available: _toInt(e['available']),
                    reserved: _toInt(e['reserved']),
                    damaged: _toInt(e['damaged']),
                  ))
              .toList(),
          weeklyRevenue: weeklyRevenue,
          weeklyDays: weeklyDays,
        ),
        alerts: alertsRaw.map((e) => DashboardAlert(
          type: e['type']?.toString() ?? 'info',
          severity: e['severity']?.toString() ?? 'low',
          title: e['title']?.toString() ?? '',
          message: e['message']?.toString() ?? '',
        )).toList(),
        activityFeed: activityRaw.map((e) => DashboardActivity(
          id: _toInt(e['id']),
          type: e['type']?.toString() ?? 'info',
          title: e['title']?.toString() ?? '',
          message: e['message']?.toString() ?? '',
          isRead: e['is_read'] == true,
          createdAt: e['created_at']?.toString() ?? '',
        )).toList(),
      );
    } on DioException catch (e) {
      log('Dashboard API Error: ${e.message}', error: e);
      state = state.copyWith(
        isLoading: false,
        error: ApiResponse.errorMessage(e, fallback: 'Failed to load dashboard'),
      );
    } catch (e) {
      log('Dashboard Error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString().contains('type \'')
            ? 'Dashboard data format error. Please retry.'
            : 'Failed to load dashboard data. Please retry.',
      );
    }
  }

  Future<dynamic> _safeFetch(String url) async {
    try {
      final response = await _dio.get(url);
      return response.data;
    } catch (e) {
      log('Dashboard sub-fetch failed ($url): $e');
      return {};
    }
  }
}
