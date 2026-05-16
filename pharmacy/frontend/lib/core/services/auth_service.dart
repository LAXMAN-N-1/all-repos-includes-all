import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/storage_service.dart';

class AuthService {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthService(this._apiClient, this._storageService);

  ApiClient get apiClient => _apiClient;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.client.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;
      final accessToken = data['access_token'];
      final user = data['user'];

      if (accessToken != null) {
        await _storageService.saveToken(accessToken);
      }
      
      if (user != null) {
        await _storageService.saveUser(jsonEncode(user));
      }

      return data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Return error message from backend
        throw Exception(e.response?.data['detail'] ?? 'Login failed');
      }
      throw Exception('Network error or server unreachable');
    }
  }

  Future<void> logout() async {
    try {
      // Optional: Call backend logout if needed (e.g. to blacklist token)
      // await _apiClient.client.post('/auth/logout'); 
    } catch (e) {
      // Ignore logout API errors
    } finally {
      await _storageService.clearAll();
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await _storageService.getToken();
    return token != null;
  }
}
