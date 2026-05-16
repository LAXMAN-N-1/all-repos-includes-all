import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserService(apiClient);
});

class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  Future<List<User>> getUsers({int skip = 0, int limit = 100}) async {
    try {
      final response = await _apiClient.get(
        '/users/',
        queryParameters: {'skip': skip, 'limit': limit},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  Future<User> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.post('/users/', data: userData);
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<User> updateUser(int id, Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.put('/users/$id', data: userData);
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _apiClient.delete('/users/$id');
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}
