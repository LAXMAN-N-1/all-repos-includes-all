import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_client.dart';

class AdminService {
  final ApiClient _apiClient;

  AdminService(this._apiClient);

  // --- Plans Management ---

  Future<List<dynamic>> getPlans() async {
    try {
      final response = await _apiClient.client.get('/admin/plans');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to fetch plans');
    }
  }

  Future<dynamic> createPlan(Map<String, dynamic> planData) async {
    try {
      final response = await _apiClient.client.post('/admin/plans', data: planData);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to create plan');
    }
  }

  // --- Organization Onboarding ---

  Future<dynamic> onboardOrganization(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.client.post('/admin/orgs/onboarding', data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to onboard organization');
    }
  }

  Future<List<dynamic>> getOrganizations() async {
    try {
      final response = await _apiClient.client.get('/admin/orgs');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to fetch organizations');
    }
  }

  // --- Dashboard & Analytics ---

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _apiClient.client.get('/admin/stats');
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to load dashboard stats');
    }
  }

  // --- Tenant Management ---

  Future<void> suspendOrganization(int orgId) async {
    try {
      await _apiClient.client.post('/admin/orgs/$orgId/suspend');
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to suspend organization');
    }
  }

  Future<void> reactivateOrganization(int orgId) async {
    try {
      await _apiClient.client.post('/admin/orgs/$orgId/reactivate');
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to reactivate organization');
    }
  }
}
