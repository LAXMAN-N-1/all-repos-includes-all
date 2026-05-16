import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../models/vendor_model.dart';
import 'package:dio/dio.dart';

final vendorServiceProvider = Provider<VendorService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VendorService(apiClient);
});

class VendorService {
  final ApiClient _apiClient;

  VendorService(this._apiClient);

  Future<List<Vendor>> getVendors({int skip = 0, int limit = 100}) async {
    try {
      final response = await _apiClient.get('/vendors/', queryParameters: {'skip': skip, 'limit': limit});
      final List<dynamic> data = response.data;
      return data.map((json) => Vendor.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load vendors: $e');
    }
  }

  Future<void> updateVendorStatus(int id, String status) async {
     try {
      await _apiClient.put('/vendors/$id/status', data: {'status': status});
    } catch (e) {
      throw Exception('Failed to update vendor status: $e');
    }
  }
}
