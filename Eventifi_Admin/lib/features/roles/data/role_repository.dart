import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eventifi_admin/core/constants/api_constants.dart';
import 'package:eventifi_admin/core/network/dio_client.dart';
import 'package:eventifi_admin/features/roles/domain/role_models.dart';
import 'package:eventifi_admin/features/auth/domain/auth_models.dart';

part 'role_repository.g.dart';

class RoleRepository {
  final Dio _dio;

  RoleRepository(this._dio);

  Future<List<Role>> getRoles() async {
    try {
      final response = await _dio.get(ApiConstants.roles);
      final List<dynamic> data = response.data is List ? response.data : (response.data['data'] ?? []);
      return data.map((json) => Role.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Menu>> getAllMenus() async {
     // TODO: Add endpoint for fetching all available menus if not hardcoded
     // For now, returning empty or assuming there's an endpoint
     // If backend doesn't have it, we might need to hardcode the "available" menus in frontend 
     // or fetch from an endpoint. assuming /menus exists for now.
    try {
      // Temporary: check if we can get this. If not, we might need to use a predefined list.
      // final response = await _dio.get('/menus'); 
      // return (response.data as List).map((json) => Menu.fromJson(json)).toList();
      return []; 
    } catch (e) {
      return [];
    }
  }

  Future<Role> createRole(CreateRoleRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.roles,
        data: request.toJson(),
      );
      return Role.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Role> updateRole(int id, CreateRoleRequest request) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.roles}/$id',
        data: request.toJson(),
      );
      return Role.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> deleteRole(int id) async {
      try {
      await _dio.delete('${ApiConstants.roles}/$id');
    } catch (e) {
      rethrow;
    }
  }
}

@riverpod
RoleRepository roleRepository(RoleRepositoryRef ref) {
  return RoleRepository(ref.watch(dioClientProvider));
}
