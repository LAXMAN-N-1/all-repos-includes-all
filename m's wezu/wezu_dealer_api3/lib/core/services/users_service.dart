import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/api_response.dart';
import '../models/dealer_user.dart';

/// Service for all dealer portal user management operations.
class UsersService {
  final Dio _dio;
  UsersService(this._dio);

  // ── List & Stats ──────────────────────────────────────

  Future<List<DealerUser>> listUsers({
    String? search,
    int? roleId,
    String? status,
  }) async {
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (roleId != null) params['role_id'] = roleId;
    if (status != null && status != 'all') params['status_filter'] = status;

    final response = await _dio.get(
      ApiConstants.dealerUsers,
      queryParameters: params,
    );
    final rawList = ApiResponse.asList(
      response.data,
      keys: const ['users', 'data'],
    );
    return rawList
        .whereType<Map>()
        .map((json) => DealerUser.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<Map<String, int>> getStats() async {
    final response = await _dio.get(ApiConstants.dealerUsersStats);
    final data = ApiResponse.asMap(response.data);
    return {
      'total': _toInt(data['total']),
      'active': _toInt(data['active']),
      'pending': _toInt(data['pending']),
      'inactive': _toInt(data['inactive']),
    };
  }

  // ── CRUD ──────────────────────────────────────────────

  Future<DealerUser> createUser(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.dealerUsers, data: data);
    return DealerUser.fromJson(ApiResponse.asMap(response.data));
  }

  Future<Map<String, dynamic>> getUserDetail(int userId) async {
    final response = await _dio.get('${ApiConstants.dealerUsers}/$userId');
    return ApiResponse.asMap(response.data);
  }

  Future<DealerUser> updateUser(int userId, Map<String, dynamic> data) async {
    final response = await _dio.put(
      '${ApiConstants.dealerUsers}/$userId',
      data: data,
    );
    return DealerUser.fromJson(ApiResponse.asMap(response.data));
  }

  Future<bool> deleteUser(int userId) async {
    final response = await _dio.delete('${ApiConstants.dealerUsers}/$userId');
    return _isSuccess(response.statusCode);
  }

  // ── Email Check ───────────────────────────────────────

  Future<Map<String, dynamic>> checkEmail(String email) async {
    final response = await _dio.post(
      ApiConstants.dealerUsersCheckEmail,
      data: {'email': email},
    );
    return ApiResponse.asMap(response.data);
  }

  // ── Status & Password ─────────────────────────────────

  Future<bool> changeStatus(int userId, String status) async {
    final response = await _dio.patch(
      '${ApiConstants.dealerUsers}/$userId/status',
      data: {'status': status},
    );
    return _isSuccess(response.statusCode);
  }

  Future<bool> resetPassword(int userId, Map<String, dynamic> data) async {
    final response = await _dio.post(
      '${ApiConstants.dealerUsers}/$userId/reset-password',
      data: data,
    );
    return _isSuccess(response.statusCode);
  }

  Future<bool> resendInvite(int userId) async {
    final response = await _dio.post(
      '${ApiConstants.dealerUsers}/$userId/resend-invite',
    );
    return _isSuccess(response.statusCode);
  }

  // ── Sessions ──────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getSessions(int userId) async {
    final response = await _dio.get(
      '${ApiConstants.dealerUsers}/$userId/sessions',
    );
    final rawList = ApiResponse.asList(
      response.data,
      keys: const ['sessions', 'data'],
    );
    return rawList
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<bool> terminateAllSessions(int userId) async {
    final response = await _dio.delete(
      '${ApiConstants.dealerUsers}/$userId/sessions',
    );
    return _isSuccess(response.statusCode);
  }

  Future<bool> terminateSession(int userId, int sessionId) async {
    final response = await _dio.delete(
      '${ApiConstants.dealerUsers}/$userId/sessions/$sessionId',
    );
    return _isSuccess(response.statusCode);
  }

  // ── Bulk Actions ──────────────────────────────────────

  Future<Map<String, dynamic>> bulkAction(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.dealerUsersBulk, data: data);
    return ApiResponse.asMap(response.data);
  }

  // ── Auth: Activate & Invite Validation ────────────────

  Future<Map<String, dynamic>> validateInvite(String token) async {
    final response = await _dio.get('${ApiConstants.validateInvite}/$token');
    return ApiResponse.asMap(response.data);
  }

  Future<Map<String, dynamic>> activateAccount(
    String token,
    String password,
  ) async {
    final response = await _dio.post(
      '${ApiConstants.activateAccount}/$token',
      data: {'password': password},
    );
    return ApiResponse.asMap(response.data);
  }

  Future<bool> forceChangePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final response = await _dio.post(
      ApiConstants.forceChangePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
    return _isSuccess(response.statusCode);
  }

  bool _isSuccess(int? statusCode) {
    if (statusCode == null) return false;
    return statusCode >= 200 && statusCode < 300;
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

final usersServiceProvider = Provider<UsersService>((ref) {
  final dio = ref.watch(dioProvider);
  return UsersService(dio);
});
