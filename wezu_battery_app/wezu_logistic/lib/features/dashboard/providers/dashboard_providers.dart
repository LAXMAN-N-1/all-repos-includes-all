import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_notifier.dart';
import '../../../core/providers.dart';
import '../../../core/result.dart';
import '../../../models/dashboard_stats_model.dart';
import '../../../models/dashboard_analytics_model.dart';
import '../../../models/dashboard_alert_model.dart';
import '../repository/dashboard_repository.dart';

// ─── Repository Provider ────────────────────────────────────────────

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(api: ref.read(apiClientProvider));
});

// ─── Stats Provider ─────────────────────────────────────────────────

final dashboardStatsProvider =
    StateNotifierProvider<DashboardStatsNotifier, AsyncState<DashboardStats>>((ref) {
  return DashboardStatsNotifier(ref.read(dashboardRepositoryProvider));
});

class DashboardStatsNotifier extends BaseNotifier<DashboardStats> {
  final DashboardRepository _repository;

  DashboardStatsNotifier(this._repository);

  Future<void> loadStats() => execute(() => _repository.fetchStats());

  /// Refresh stats silently (no loading spinner).
  Future<void> refreshStats() => execute(
        () => _repository.fetchStats(),
        showLoading: false,
      );
}

// ─── Activity Provider ──────────────────────────────────────────────

final recentActivityProvider =
    StateNotifierProvider<RecentActivityNotifier, AsyncState<List<ActivityItem>>>((ref) {
  return RecentActivityNotifier(ref.read(dashboardRepositoryProvider));
});

class RecentActivityNotifier extends BaseNotifier<List<ActivityItem>> {
  final DashboardRepository _repository;

  RecentActivityNotifier(this._repository);

  Future<void> loadActivity({int limit = 10}) =>
      execute(() => _repository.fetchRecentActivity(limit: limit));
}

// ─── Analytics Provider ─────────────────────────────────────────────

final dashboardAnalyticsProvider =
    StateNotifierProvider<DashboardAnalyticsNotifier, AsyncState<DashboardAnalyticsData>>(
        (ref) {
  return DashboardAnalyticsNotifier(ref.read(dashboardRepositoryProvider));
});

class DashboardAnalyticsNotifier extends BaseNotifier<DashboardAnalyticsData> {
  final DashboardRepository _repository;

  DashboardAnalyticsNotifier(this._repository);

  Future<void> loadAnalytics() => execute(() => _repository.fetchAnalytics());
}

// ─── Alerts Provider ────────────────────────────────────────────────

final dashboardAlertsProvider =
    StateNotifierProvider<DashboardAlertsNotifier, AsyncState<List<DashboardAlert>>>(
        (ref) {
  return DashboardAlertsNotifier(ref.read(dashboardRepositoryProvider));
});

class DashboardAlertsNotifier extends BaseNotifier<List<DashboardAlert>> {
  final DashboardRepository _repository;

  DashboardAlertsNotifier(this._repository);

  Future<void> loadAlerts() => execute(() => _repository.fetchAlerts());
}
