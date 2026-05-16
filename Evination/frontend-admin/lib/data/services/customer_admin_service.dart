import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../models/customer/customer_admin_model.dart'; // Ensure correct path

class CustomerAdminService {
  final ApiClient apiClient;

  CustomerAdminService(this.apiClient);

  Future<List<CustomerStatModel>> getCustomers({int skip = 0, int limit = 100, String? search}) async {
    try {
      final response = await apiClient.get(
        '/api/admin/customers/',
        queryParameters: {
          'skip': skip,
          'limit': limit,
          'search': search,
        },
      );
      return (response.data as List).map((e) => CustomerStatModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch customers: $e');
    }
  }

  Future<CustomerDetailModel> getCustomerDetails(int id) async {
    try {
      final response = await apiClient.get('/api/admin/customers/$id');
      return CustomerDetailModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch customer details: $e');
    }
  }
}
