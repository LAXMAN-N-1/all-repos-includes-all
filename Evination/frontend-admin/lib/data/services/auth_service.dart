import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../core/storage_service.dart';
import '../models/auth_response_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthService(apiClient, storageService);
});

class AuthService {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthService(this._apiClient, this._storageService);

  Future<AuthResponse> login(String username, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );
      final authResponse = AuthResponse.fromJson(response.data);
      
      // Save token
      await _storageService.saveToken(authResponse.accessToken);
      
      return authResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid credentials');
      }
      throw Exception('Login failed: ${e.message}');
    }
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
  }
}
