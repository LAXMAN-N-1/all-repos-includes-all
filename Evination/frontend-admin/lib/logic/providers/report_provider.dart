import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../data/services/report_service.dart';
import '../../data/models/reports/report_models.dart';

final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService(ref.watch(apiClientProvider));
});

final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  return ref.watch(reportServiceProvider).getDashboardStats();
});

final performanceReportProvider = FutureProvider.autoDispose<PerformanceReport>((ref) async {
  return ref.watch(reportServiceProvider).getPerformanceReport();
});

final profitLossProvider = FutureProvider.autoDispose<ProfitLossReport>((ref) async {
  return ref.watch(reportServiceProvider).getProfitLossReport();
});

final dashboardChartsProvider = FutureProvider.autoDispose<DashboardCharts>((ref) async {
  return ref.watch(reportServiceProvider).getDashboardCharts();
});
