import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/storage_service.dart';

class AuthService {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthService(this._apiClient, this._storageService);

  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiClient.client.post('/auth/login', data: {
        'username': email, // FastAPI OAuth2PasswordRequestForm expects 'username'
        'password': password,
      }, options: Options(contentType: Headers.formUrlEncodedContentType));

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        if (token != null) {
          await _storageService.saveToken(token);
          // Fetch user details?
          // await fetchUserProfile();
          return true;
        }
      }
      return false;
    } on DioException catch (e) {
      // Log error or rethrow
      print("Login Failed: ${e.response?.data ?? e.message}");
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
  }

  Future<bool> isAuthenticated() async {
    final token = await _storageService.getToken();
    return token != null;
  }
}
