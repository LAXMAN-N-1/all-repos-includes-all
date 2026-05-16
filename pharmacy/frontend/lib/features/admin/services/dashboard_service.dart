import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_client.dart';

class DashboardService {
  final ApiClient _apiClient;

  DashboardService(this._apiClient);

  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _apiClient.client.get('/dashboard/stats');
      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } on DioException catch (e) {
      print("Fetch Dashboard Stats Failed: ${e.message}");
      return {}; // Return empty to trigger fallback or empty state
    }
  }
}
