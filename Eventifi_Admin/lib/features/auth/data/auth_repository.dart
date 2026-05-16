import 'package:dio/dio.dart';
import 'package:eventifi_admin/core/constants/api_constants.dart';
import 'package:eventifi_admin/core/network/dio_client.dart';
import 'package:eventifi_admin/features/auth/domain/auth_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<LoginResponse> login(String username, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: LoginRequest(username: username, password: password).toJson(),
      );
      return LoginResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(ref.watch(dioClientProvider));
}
