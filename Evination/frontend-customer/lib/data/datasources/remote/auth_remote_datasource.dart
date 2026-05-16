import 'package:dio/dio.dart';
import '../../models/auth/token_model.dart';
import '../../models/user/user_model.dart';
import '../../../../core/api/api_endpoints.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<TokenModel> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      return TokenModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        throw Exception(e.response?.data['detail'] ?? 'Login failed');
      }
      throw Exception('Network error during login');
    }
  }

  Future<TokenModel> signup(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.signup,
        data: userData,
      );
      return TokenModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        throw Exception(e.response?.data['detail'] ?? 'Signup failed');
      }
      throw Exception('Network error during signup');
    }
  }

  Future<UserModel> getUser() async {
    final response = await _dio.get('/customer/auth/me');
    return UserModel.fromJson(response.data);
  }
}
