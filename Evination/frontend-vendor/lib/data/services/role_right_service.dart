import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../models/role_right_model.dart';
import 'package:dio/dio.dart';

final roleRightServiceProvider = Provider<RoleRightService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RoleRightService(apiClient);
});

class RoleRightService {
  final ApiClient _apiClient;

  RoleRightService(this._apiClient);

  Future<List<RoleRight>> getRoleRights(int roleId) async {
    try {
      final response = await _apiClient.get('/role-rights/$roleId');
      final List<dynamic> data = response.data;
      return data.map((json) => RoleRight.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load role rights: $e');
    }
  }

  Future<void> syncRoleRightsBulk(int roleId, List<RoleRightBulkItem> rights) async {
    try {
      await _apiClient.post('/role-rights/bulk', data: {
        'role_id': roleId,
        'rights': rights.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to sync role rights: $e');
    }
  }
}
