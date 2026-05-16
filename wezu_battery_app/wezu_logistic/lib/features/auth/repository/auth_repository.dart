import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/api_exception.dart';
import '../../../core/result.dart';
import '../../../models/user_model.dart';
import '../../../services/api/api_client.dart';
import '../../../services/storage_service.dart';

class SessionRestoreProgress {
  final double value;
  final String message;

  const SessionRestoreProgress({required this.value, required this.message});
}

typedef SessionRestoreProgressCallback =
    void Function(SessionRestoreProgress progress);

/// Repository for all auth-related data operations.
class AuthRepository {
  final ApiClient _api;
  final StorageService _storage;

  AuthRepository({required ApiClient api, required StorageService storage})
    : _api = api,
      _storage = storage;

  /// Authenticate with email and password.
  /// Uses /auth/token (OAuth2 form-encoded endpoint).
  Future<Result<UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('AUTH_DEBUG: Starting login for $email');
      print('AUTH_DEBUG: Base URL = ${_api.toString()}');

      // /auth/token requires form-encoded data (OAuth2 standard)
      final data = await _api.post<Map<String, dynamic>>(
        '/auth/token',
        data: FormData.fromMap({'username': email, 'password': password}),
      );

      print('AUTH_DEBUG: Response received, keys: ${data.keys.toList()}');

      final token = data['access_token'] as String;
      print('AUTH_DEBUG: Token extracted (${token.length} chars)');

      // Parse user from response (included in /auth/token response)
      UserModel user;
      if (data['user'] != null && data['user'] is Map<String, dynamic>) {
        print('AUTH_DEBUG: Parsing user from response...');
        user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      } else {
        print('AUTH_DEBUG: No user in response, fetching /users/me...');
        // Persist token FIRST so AuthInterceptor can use it
        await _storage.saveToken(token);
        final userData = await _api.get<Map<String, dynamic>>('/users/me');
        user = UserModel.fromJson(userData);
      }
      print('AUTH_DEBUG: User parsed: ${user.name} (${user.email})');

      // Persist token and user data
      await _storage.saveToken(token);
      await _storage.saveUserData(jsonEncode(user.toJson()));

      return Result.success(user);
    } on ApiException catch (e) {
      print('AUTH_DEBUG: ApiException: ${e.message}, code=${e.statusCode}');
      if (e.statusCode == 401) {
        return Result.failure(
          'Invalid email or password',
          code: 'INVALID_CREDENTIALS',
        );
      }
      return Result.failure(e.message);
    } catch (e, stack) {
      print('AUTH_DEBUG: UNEXPECTED ERROR: $e');
      print('AUTH_DEBUG: Stack: $stack');
      return Result.failure('An unexpected error occurred: $e');
    }
  }

  /// Log out and clear stored credentials.
  Future<Result<void>> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {
      // Proceed with local logout even if API call fails
    }

    await _storage.clearTokens();
    await _storage.clearUserData();
    return Result.success(null);
  }

  /// Check if a valid session exists.
  Future<Result<UserModel>> restoreSession({
    SessionRestoreProgressCallback? onProgress,
  }) async {
    try {
      onProgress?.call(
        const SessionRestoreProgress(
          value: 0.08,
          message: 'Preparing secure session...',
        ),
      );
      final token = await _storage.getToken();
      if (token == null) {
        print('AUTH_DEBUG: No token found in storage.');
        onProgress?.call(
          const SessionRestoreProgress(
            value: 1.0,
            message: 'No saved session found',
          ),
        );
        return Result.failure('No session found', code: 'NO_SESSION');
      }
      print(
        'AUTH_DEBUG: Token found (${token.length} chars). Restoring session...',
      );
      onProgress?.call(
        const SessionRestoreProgress(
          value: 0.42,
          message: 'Validating saved session...',
        ),
      );

      // Token is automatically injected by AuthInterceptor
      final data = await _api.get<Map<String, dynamic>>('/users/me');
      print('AUTH_DEBUG: Session restored successfully.');
      onProgress?.call(
        const SessionRestoreProgress(
          value: 0.82,
          message: 'Loading your workspace...',
        ),
      );
      final user = UserModel.fromJson(data);
      // Update cache
      await _storage.saveUserData(jsonEncode(user.toJson()));
      onProgress?.call(
        const SessionRestoreProgress(value: 1.0, message: 'Session restored'),
      );
      return Result.success(user);
    } on ApiException catch (e) {
      print(
        'AUTH_DEBUG: Session restore failed (API Error): ${e.message} (${e.statusCode})',
      );

      // Only clear token if explicitly unauthorized
      if (e.statusCode == 401) {
        await _storage.clearTokens();
        await _storage.clearUserData();
        onProgress?.call(
          const SessionRestoreProgress(value: 1.0, message: 'Session expired'),
        );
        return Result.failure('Session expired', code: 'SESSION_EXPIRED');
      }

      // ─── OFFLINE SUPPORT ───
      // If API failed (e.g. 500 or Network Error), try to load cached user
      final cachedJson = _storage.getUserData();
      if (cachedJson != null) {
        try {
          print(
            'AUTH_DEBUG: API failed (${e.statusCode}), falling back to cached user data.',
          );
          onProgress?.call(
            const SessionRestoreProgress(
              value: 0.9,
              message: 'Network issue. Using cached profile...',
            ),
          );
          final user = UserModel.fromJson(jsonDecode(cachedJson));
          onProgress?.call(
            const SessionRestoreProgress(
              value: 1.0,
              message: 'Loaded cached profile',
            ),
          );
          return Result.success(user);
        } catch (_) {
          print('AUTH_DEBUG: Cached user data was corrupted.');
        }
      } else {
        print(
          'AUTH_DEBUG: API failed and no cached user data found. Cannot restore session.',
        );
      }

      // For other errors (e.g. 500, network), keep the token but return failure
      onProgress?.call(
        const SessionRestoreProgress(
          value: 1.0,
          message: 'Could not restore session',
        ),
      );
      return Result.failure('Failed to restore session: ${e.message}');
    } catch (e) {
      onProgress?.call(
        const SessionRestoreProgress(
          value: 1.0,
          message: 'Unexpected startup error',
        ),
      );
      return Result.failure('Unexpected error restoring session');
    }
  }

  /// Update user profile.
  Future<Result<UserModel>> updateProfile({
    String? fullName,

    String? email,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (email != null) data['email'] = email;

      if (data.isEmpty) return Result.failure('No changes to update');

      final response = await _api.put<Map<String, dynamic>>(
        '/users/me',
        data: data,
      );
      final updatedUser = UserModel.fromJson(response);

      // Update cache
      await _storage.saveUserData(jsonEncode(updatedUser.toJson()));

      return Result.success(updatedUser);
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to update profile: $e');
    }
  }
}
