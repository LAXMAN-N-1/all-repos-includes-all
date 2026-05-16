import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../models/order_model.dart';
import 'package:dio/dio.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OrderService(apiClient);
});

class OrderService {
  final ApiClient _apiClient;

  OrderService(this._apiClient);

  Future<List<Order>> getOrders({int skip = 0, int limit = 100}) async {
    try {
      final response = await _apiClient.get(
        '/orders/', 
        queryParameters: {'skip': skip, 'limit': limit}
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }
}
