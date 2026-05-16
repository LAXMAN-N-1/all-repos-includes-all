import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eventifi_admin/core/constants/api_constants.dart';
import 'package:eventifi_admin/core/network/dio_client.dart';
import 'package:eventifi_admin/features/auth/domain/auth_models.dart';
import 'package:eventifi_admin/features/users/domain/user_models.dart';

part 'user_repository.g.dart';

class UserRepository {
  final Dio _dio;

  UserRepository(this._dio);

  Future<List<User>> getUsers() async {
    try {
      final response = await _dio.get(ApiConstants.users);
      // Assuming response.data is a list or contains a 'data' field that is a list
      // Adjust based on actual backend response structure. 
      // Safe default: check if it's a list directly or inside a key
      final List<dynamic> data = response.data is List ? response.data : (response.data['data'] ?? []);
      return data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<User> createUser(CreateUserRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.users,
        data: request.toJson(),
      );
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateUser(int id, UpdateUserRequest request) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.users}/$id',
        data: request.toJson(),
      );
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _dio.delete('${ApiConstants.users}/$id');
    } catch (e) {
      rethrow;
    }
  }
}

@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  return UserRepository(ref.watch(dioClientProvider));
}
