import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../models/branch_model.dart';
import 'package:dio/dio.dart';

final branchServiceProvider = Provider<BranchService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BranchService(apiClient);
});

class BranchService {
  final ApiClient _apiClient;

  BranchService(this._apiClient);

  Future<List<Branch>> getBranches() async {
    try {
      final response = await _apiClient.get('/branches/'); // Assuming /branches/ endpoint exists (it should based on file list)
      final List<dynamic> data = response.data;
      return data.map((json) => Branch.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load branches: $e');
    }
  }

  Future<void> createBranch(Map<String, dynamic> data) async {
    try {
      await _apiClient.post('/branches/', data: data);
    } catch (e) {
      throw Exception('Failed to create branch: $e');
    }
  }

  Future<void> updateBranch(int id, Map<String, dynamic> data) async {
    try {
      await _apiClient.put('/branches/$id', data: data);
    } catch (e) {
      throw Exception('Failed to update branch: $e');
    }
  }

  Future<void> deleteBranch(int id) async {
    try {
      await _apiClient.delete('/branches/$id');
    } catch (e) {
      throw Exception('Failed to delete branch: $e');
    }
  }
}
