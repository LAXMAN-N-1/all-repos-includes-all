import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/admin/data/mock_users.dart'; // Fallback / Type re-use

class UsersService {
  final ApiClient _apiClient;

  UsersService(this._apiClient);

  Future<List<AdminUser>> getAdminUsers() async {
    try {
      final response = await _apiClient.client.get('/users/admins'); // Endpoint assumption
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => AdminUser(
          id: json['id'].toString(),
          name: json['full_name'] ?? 'Unknown',
          email: json['email'] ?? '',
          role: json['role']?['name'] ?? 'Admin',
          status: json['is_active'] ? 'Active' : 'Inactive',
          lastLogin: DateTime.now(), // Backend might not send this yet
        )).toList();
      }
      return [];
    } on DioException catch (e) {
      print("Fetch Users Failed: ${e.message}");
      // Fallback to mock data for demo purposes if backend fails
      return mockAdmins; 
    }
  }
}
