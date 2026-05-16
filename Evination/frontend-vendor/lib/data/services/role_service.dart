import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../models/role_model.dart';
import 'package:dio/dio.dart';

final roleServiceProvider = Provider<RoleService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RoleService(apiClient);
});

class RoleService {
  final ApiClient _apiClient;

  RoleService(this._apiClient);

  Future<List<Role>> getRoles() async {
    try {
      final response = await _apiClient.get('/roles/');
      final List<dynamic> data = response.data;
      return data.map((json) => Role.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load roles: $e');
    }
  }

  Future<Role> createRole(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/roles/', data: data);
      return Role.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create role: $e');
    }
  }

  Future<void> updateRole(int id, Map<String, dynamic> data) async {
    try {
      await _apiClient.put('/roles/$id', data: data);
    } catch (e) {
      throw Exception('Failed to update role: $e');
    }
  }

  Future<void> deleteRole(int id) async {
    try {
      await _apiClient.delete('/roles/$id');
    } catch (e) {
      throw Exception('Failed to delete role: $e');
    }
  }
}
