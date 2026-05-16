import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../models/reports/report_models.dart';

class ReportService {
  final ApiClient apiClient;

  ReportService(this.apiClient);

  Future<DashboardStats> getDashboardStats() async {
    final response = await apiClient.get('/api/reports/dashboard-stats');
    return DashboardStats.fromJson(response.data);
  }

  Future<PerformanceReport> getPerformanceReport() async {
    final response = await apiClient.get('/api/reports/performance');
    return PerformanceReport.fromJson(response.data);
  }

  Future<ProfitLossReport> getProfitLossReport() async {
    final response = await apiClient.get('/api/reports/profit-loss');
    return ProfitLossReport.fromJson(response.data);
  }

  Future<DashboardCharts> getDashboardCharts() async {
    final response = await apiClient.get('/api/reports/dashboard-charts');
    return DashboardCharts.fromJson(response.data);
  }
}
