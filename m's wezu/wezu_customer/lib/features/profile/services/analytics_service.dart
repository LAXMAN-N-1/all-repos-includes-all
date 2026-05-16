import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';

class AnalyticsService {
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await apiClient.get('/analytics/dashboard');
      if (response.data['success'] == true) {
        return response.data['data'];
      }
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
    }
    return {};
  }

  Future<List<dynamic>> getSpendingTrend() async {
    try {
      final response = await apiClient.get('/analytics/cost-analytics');
      if (response.data['success'] == true) {
        return response.data['data']['spending_trend'] ?? [];
      }
    } catch (e) {
      debugPrint('Error fetching spending trend: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>> getUsagePatterns() async {
    try {
      final response = await apiClient.get('/analytics/usage-patterns');
      if (response.data['success'] == true) {
        return response.data['data'];
      }
    } catch (e) {
      debugPrint('Error fetching usage patterns: $e');
    }
    return {};
  }
}
