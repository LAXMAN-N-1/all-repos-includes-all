import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';

class RolesService {
  final Dio _dio;

  RolesService(this._dio);

  Future<bool> inviteUser({
    required String email,
    required int roleId,
    List<String> stations = const [],
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.roles}/users/invite',
        data: {
          'email': email,
          'role_id': roleId,
          'stations': stations,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> changeUserRole(int userId, int roleId) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.roles}/$roleId/users',
        data: {'user_id': userId},
      );
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> removeUserFromRole(int roleId, int userId) async {
    try {
      final response = await _dio.delete(
        '${ApiConstants.roles}/$roleId/users/$userId',
      );
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAuditLog(int roleId) async {
    try {
      final response = await _dio.get('${ApiConstants.roles}/$roleId${ApiConstants.roleAuditLog}');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createRole(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiConstants.roles, data: data);
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateRole(int roleId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('${ApiConstants.roles}/$roleId', data: data);
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteRole(int roleId) async {
    try {
      final response = await _dio.delete('${ApiConstants.roles}/$roleId');
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }
}

final rolesServiceProvider = Provider<RolesService>((ref) {
  final dio = ref.watch(dioProvider);
  return RolesService(dio);
});
