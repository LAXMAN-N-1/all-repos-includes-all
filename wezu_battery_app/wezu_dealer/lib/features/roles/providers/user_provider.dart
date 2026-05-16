import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_response.dart';
import '../models/user_state.dart';

final usersProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref.watch(dioProvider));
});

class UserNotifier extends StateNotifier<UserState> {
  final Dio _dio;
  UserNotifier(this._dio) : super(const UserState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get(ApiConstants.dealerUsers);
      final rawList = ApiResponse.asList(
        response.data,
        keys: const ['users', 'data'],
      );
      final parsed = rawList.whereType<Map>().map((entry) {
        final e = Map<String, dynamic>.from(entry);
        final email = (e['email'] ?? '').toString();
        final fallbackName =
            email.contains('@') ? email.split('@').first : 'Unknown';
        return UserDto(
          id: (e['id'] ?? '').toString(),
          name: (e['name'] ?? e['full_name'] ?? fallbackName).toString(),
          email: email,
          role: (e['role_name'] ?? e['role'] ?? e['user_type'] ?? 'Staff')
              .toString(),
          status: (e['status'] ?? 'unknown').toString(),
          lastActive: (e['last_active'] ??
                  e['last_login'] ??
                  e['updated_at'] ??
                  e['created_at'] ??
                  '')
              .toString(),
          avatar: e['avatar']?.toString() ?? e['profile_picture']?.toString(),
        );
      }).toList();
      state = state.copyWith(isLoading: false, users: parsed);
    } on DioException catch (e) {
      log('Users API Error: ${e.message}', error: e);
      state = state.copyWith(
        isLoading: false,
        error: ApiResponse.errorMessage(e, fallback: 'Failed to load users'),
      );
    } catch (e) {
      log('Users Error: $e');
      state = state.copyWith(isLoading: false, error: 'Unexpected error');
    }
  }
}
