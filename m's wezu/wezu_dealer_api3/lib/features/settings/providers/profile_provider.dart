import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_response.dart';
import '../models/profile_state.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  return ProfileNotifier(
    ref.watch(dioProvider),
    ref.watch(secureStorageProvider),
  );
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ProfileNotifier(this._dio, this._storage) : super(const ProfileState()) {
    refresh();
  }

  Future<void> refresh({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(isUpdating: true, error: null);
    }
    try {
      final response = await _dio.get(ApiConstants.dealerProfile);
      final rawData = ApiResponse.asMap(response.data, keys: const ['data']);

      state = state.copyWith(
        isLoading: false,
        isUpdating: false,
        profile: ProfileDto.fromJson(rawData),
      );
    } on DioException catch (e) {
      log('Profile API Error: ${e.message}', error: e);
      state = state.copyWith(
        isLoading: false,
        isUpdating: false,
        error: ApiResponse.errorMessage(e, fallback: 'Failed to load profile'),
      );
    } catch (e) {
      log('Profile Error: $e');
      state = state.copyWith(
          isLoading: false, isUpdating: false, error: 'Unexpected error');
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isUpdating: true);
      await _dio.patch(ApiConstants.updateProfile, data: data);
      await refresh(silent: true);
      return true;
    } on DioException catch (e) {
      log('Update profile error: ${e.message}', error: e);
      state = state.copyWith(
        isUpdating: false,
        error:
            ApiResponse.errorMessage(e, fallback: 'Failed to update profile'),
      );
      return false;
    } catch (e) {
      log('Update profile error: $e');
      state =
          state.copyWith(isUpdating: false, error: 'Failed to update profile');
      return false;
    }
  }

  Future<bool> updateBankAccount({
    required String accountNumber,
    required String ifscCode,
    required String accountHolderName,
    required String bankName,
  }) async {
    try {
      state = state.copyWith(isUpdating: true);
      await _dio.post(
        ApiConstants.dealerBankAccount,
        data: {
          'account_number': accountNumber,
          'ifsc_code': ifscCode,
          'account_holder_name': accountHolderName,
          'bank_name': bankName,
        },
      );
      await refresh(silent: true);
      return true;
    } on DioException catch (e) {
      log('Update bank account error: ${e.message}', error: e);
      state = state.copyWith(
        isUpdating: false,
        error: ApiResponse.errorMessage(e,
            fallback: 'Failed to update bank account'),
      );
      return false;
    } catch (e) {
      log('Update bank account error: $e');
      state = state.copyWith(
          isUpdating: false, error: 'Failed to update bank account');
      return false;
    }
  }

  Future<Map<String, bool>> fetchNotificationPreferences() async {
    try {
      final response = await _dio.get(ApiConstants.notificationPrefs);
      final data = ApiResponse.asMap(response.data, keys: const ['data']);
      return data.map(
        (key, value) => MapEntry(
          key,
          value == true || value.toString().toLowerCase() == 'true',
        ),
      );
    } on DioException catch (e) {
      log('Fetch notifications error: ${e.message}', error: e);
      state = state.copyWith(
        error: ApiResponse.errorMessage(
          e,
          fallback: 'Failed to load notification preferences',
        ),
      );
      return {};
    } catch (e) {
      log('Fetch notifications error: $e');
      return {};
    }
  }

  Future<bool> updateNotificationPreferences(Map<String, bool> prefs) async {
    try {
      state = state.copyWith(isUpdating: true);
      await _dio.put(ApiConstants.notificationPrefs, data: prefs);
      await refresh(silent: true);
      return true;
    } on DioException catch (e) {
      log('Update notification prefs error: ${e.message}', error: e);
      state = state.copyWith(
        isUpdating: false,
        error: ApiResponse.errorMessage(
          e,
          fallback: 'Failed to update notification preferences',
        ),
      );
      return false;
    } catch (e) {
      log('Update notification prefs error: $e');
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to update notification preferences',
      );
      return false;
    }
  }

  Future<String?> changePassword(
      String _currentPassword, String newPassword) async {
    try {
      state = state.copyWith(isUpdating: true);
      if (!ApiConstants.hasSupabaseConfig) {
        state = state.copyWith(isUpdating: false);
        return 'Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env';
      }

      final token =
          await _storage.read(key: ApiConstants.accessTokenStorageKey);
      if (token == null || token.isEmpty) {
        state = state.copyWith(isUpdating: false);
        return 'Please login again to change password.';
      }

      await Dio().put(
        ApiConstants.changePassword,
        data: {
          'password': newPassword,
        },
        options: Options(
          headers: ApiConstants.supabaseHeaders(accessToken: token),
          extra: {'api3_skip_refresh': true},
        ),
      );
      state = state.copyWith(isUpdating: false);
      return null;
    } on DioException catch (e) {
      log('Change password error: $e');
      state = state.copyWith(isUpdating: false);
      return ApiResponse.errorMessage(e, fallback: 'Failed to update password');
    } catch (e) {
      log('Change password error: $e');
      state = state.copyWith(isUpdating: false);
      return 'An unexpected error occurred';
    }
  }
}
