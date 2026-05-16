import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../core/storage_service.dart';
import '../models/auth_response_model.dart';
import '../models/vendor_registration_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthService(apiClient, storageService);
});

class AuthService {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthService(this._apiClient, this._storageService);

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/vendor/login',
        data: {
          'email': email,
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

  Future<void> register(VendorRegistrationModel data) async {
    try {
      await _apiClient.post(
        '/auth/vendor/register',
        data: data.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Registration failed: ${e.message}');
    }
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
  }
}
