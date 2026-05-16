import '../services/api_service.dart';
import '../models/user.dart';
import 'package:wezu_customer_app/core/constants/api_constants.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  // Request OTP for registration
  Future<Map<String, dynamic>> requestOtp(String target, String purpose) async {
    try {
      final response = await _apiService.dio.post(
        ApiConstants.registerRequestOtp,
        data: {
          'target': target,
          'purpose': purpose,
        },
      );
      return {'success': true, 'message': response.data['message']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Verify OTP and register
  Future<Map<String, dynamic>> verifyOtp({
    required String target,
    required String code,
    required String purpose,
    String? fullName,
  }) async {
    try {
      final response = await _apiService.dio.post(
        ApiConstants.registerVerifyOtp,
        data: {
          'target': target,
          'code': code,
          'purpose': purpose,
          'full_name': fullName,
        },
      );

      // Save tokens
      await _apiService.saveToken(
        response.data['access_token'],
        response.data['refresh_token'],
      );

      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String target, String code) async {
    try {
      final response = await _apiService.dio.post(
        ApiConstants.login,
        data: {
          'target': target,
          'code': code,
        },
      );

      // Save tokens
      await _apiService.saveToken(
        response.data['access_token'],
        response.data['refresh_token'],
      );

      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiService.dio.get(ApiConstants.userMe);
      return User.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.dio.post(ApiConstants.logout);
    } finally {
      await _apiService.clearTokens();
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _apiService.getToken();
    return token != null;
  }
}
