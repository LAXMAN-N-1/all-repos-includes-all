import 'package:dio/dio.dart';

import 'package:wezu_customer_app/core/constants/api_constants.dart';
import 'package:wezu_customer_app/core/services/storage_service.dart';

class AuthService {
  late final Dio _dio;

  AuthService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.customerApiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptor for attaching token and handling refresh
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expired, try to refresh
          // Prevent infinite loop if refresh also fails
          if (e.requestOptions.path.contains('/auth/refresh')) {
            return handler.next(e);
          }

          final refreshToken = await StorageService.getRefreshToken();
          if (refreshToken != null) {
            try {
              final response = await _dio
                  .post('/auth/refresh', data: {'refresh_token': refreshToken});
              final newAccessToken = response.data['access_token'];
              final newRefreshToken = response.data['refresh_token'];

              await StorageService.saveTokens(
                  accessToken: newAccessToken, refreshToken: newRefreshToken);

              // Retry original request
              final opts = e.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newAccessToken';
              final clonedRequest = await _dio.request(
                opts.path,
                options: Options(
                  method: opts.method,
                  headers: opts.headers,
                ),
                data: opts.data,
                queryParameters: opts.queryParameters,
              );
              return handler.resolve(clonedRequest);
            } catch (refreshError) {
              // Refresh failed, logout
              await StorageService.clearTokens();
              return handler.next(e);
            }
          }
        }
        return handler.next(e);
      },
    ));
  }

  // --- Auth Endpoints ---

  Future<void> register(Map<String, dynamic> data) async {
    try {
      await _dio.post('/auth/register', data: data);
    } catch (e) {
      rethrow;
    }
  }

  // Request OTP for registration
  Future<void> requestOtp(
      {required String target, String purpose = 'registration'}) async {
    try {
      await _dio.post('/auth/register/request-otp',
          data: {'target': target, 'purpose': purpose});
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP for registration
  Future<Map<String, dynamic>> verifyOtp(
      {required String target,
      required String code,
      String purpose = 'registration',
      String? fullName}) async {
    try {
      final response = await _dio.post('/auth/register/verify-otp', data: {
        'target': target,
        'code': code,
        'purpose': purpose,
        'full_name': fullName
      });
      return response.data; // Should contain tokens and user
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(
      {required String username, required String password}) async {
    try {
      final response = await _dio.post('/auth/login',
          data: {
            'username': username,
            'password': password,
          },
          options: Options(contentType: Headers.formUrlEncodedContentType));
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      // Ignore errors on logout
    } finally {
      await StorageService.clearTokens();
    }
  }

  // --- Password Reset ---

  Future<void> forgotPassword(String email) async {
    await _dio.post('/auth/forgot-password', data: {'email': email});
  }

  Future<void> resetPassword(
      {required String email,
      required String otp,
      required String newPassword}) async {
    await _dio.post('/auth/reset-password',
        data: {'email': email, 'otp': otp, 'new_password': newPassword});
  }

  // --- Social Auth ---

  Future<Map<String, dynamic>> googleLogin(String token) async {
    final response = await _dio.post('/auth/google', data: {'token': token});
    return response.data;
  }

  Future<Map<String, dynamic>> appleLogin(String token,
      {String? fullName}) async {
    final response = await _dio
        .post('/auth/apple', data: {'token': token, 'full_name': fullName});
    return response.data;
  }
}
