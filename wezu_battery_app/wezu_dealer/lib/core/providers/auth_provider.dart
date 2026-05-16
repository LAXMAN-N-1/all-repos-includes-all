import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import '../models/dealer_user.dart';
import '../services/users_service.dart';

// Auth state
class AuthState {
  final DealerUser? user;
  final bool isLoading;
  final bool isAuthenticated;
  final bool mustChangePassword;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.mustChangePassword = false,
    this.error,
  });

  AuthState copyWith({
    DealerUser? user,
    bool? isLoading,
    bool? isAuthenticated,
    bool? mustChangePassword,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthNotifier(this._dio, this._storage) : super(const AuthState());

  Future<bool> login(String identifier, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post(
        ApiConstants.login,
        // Backend keeps the field name as `email`, but accepts both email and phone values.
        data: {'email': identifier, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        final accessToken = data['access_token']?.toString();
        final refreshToken = data['refresh_token']?.toString();
        final userJson = data['user'];
        if (accessToken == null || refreshToken == null || userJson is! Map) {
          state = state.copyWith(
              isLoading: false, error: 'Invalid login response from server');
          return false;
        }

        await _storage.write(key: 'access_token', value: accessToken);
        await _storage.write(key: 'refresh_token', value: refreshToken);

        final user = DealerUser.fromJson(Map<String, dynamic>.from(userJson));
        final mustChange =
            data['must_change_password'] == true || user.forcePasswordChange;
        state = AuthState(
          user: user,
          isAuthenticated: true,
          isLoading: false,
          mustChangePassword: mustChange,
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Login failed');
      return false;
    } on DioException catch (e) {
      final data = e.response?.data;
      var message = 'Invalid credentials';
      if (data is Map) {
        final detail = data['detail'];
        if (detail is String && detail.isNotEmpty) {
          message = detail;
        } else if (detail is List && detail.isNotEmpty) {
          message = detail.first.toString();
        }
      }
      state = state.copyWith(isLoading: false, error: message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Connection error');
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String phoneNumber,
    required String fullName,
    required String password,
    required String businessName,
    required String contactPerson,
    required String addressLine1,
    required String city,
    required String state_,
    required String pincode,
    String? gstNumber,
    String? panNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'email': email,
          'phone_number': phoneNumber,
          'full_name': fullName,
          'password': password,
          'business_name': businessName,
          'contact_person': contactPerson,
          'address_line1': addressLine1,
          'city': city,
          'state': state_,
          'pincode': pincode,
          'gst_number': gstNumber,
          'pan_number': panNumber,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _storage.write(key: 'access_token', value: data['access_token']);
        await _storage.write(
            key: 'refresh_token', value: data['refresh_token']);

        final user = DealerUser.fromJson(data['user']);
        state = AuthState(user: user, isAuthenticated: true, isLoading: false);
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Registration failed');
      return false;
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data is Map) ? data['detail'] : 'Registration failed';
      state = state.copyWith(isLoading: false, error: message.toString());
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Connection error');
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = const AuthState();
  }

  Future<void> checkAuth() async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      await refreshUser();
      return;
    }
    state = const AuthState();
  }

  Future<void> refreshUser() async {
    try {
      final response = await _dio.get(ApiConstants.registrationStatus);
      if (response.statusCode == 200) {
        final user =
            DealerUser.fromJson(response.data['user'] ?? response.data);
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          isLoading: false,
        );
      }
    } catch (_) {
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
      state = const AuthState();
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(dio, storage);
});

final authBootstrapProvider = FutureProvider<void>((ref) async {
  await ref.read(authProvider.notifier).checkAuth();
});

/// Activate an invited account using the invite token
final activateAccountProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, String>>(
        (ref, params) async {
  final service = ref.watch(usersServiceProvider);
  return service.activateAccount(params['token']!, params['password']!);
});
