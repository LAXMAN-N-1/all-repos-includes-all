import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eventifi_admin/core/constants/api_constants.dart';
import 'package:eventifi_admin/core/network/dio_client.dart';
import 'package:eventifi_admin/features/vendors/domain/vendor_models.dart';

part 'vendor_repository.g.dart';

class VendorRepository {
  final Dio _dio;

  VendorRepository(this._dio);

  Future<List<Vendor>> getVendors() async {
    try {
      final response = await _dio.get(ApiConstants.vendors);
      final List<dynamic> data = response.data is List ? response.data : (response.data['data'] ?? []);
      return data.map((json) => Vendor.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Vendor> createVendor(CreateVendorRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.vendors,
        data: request.toJson(),
      );
      return Vendor.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Vendor> updateVendor(int id, CreateVendorRequest request) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.vendors}/$id',
        data: request.toJson(),
      );
      return Vendor.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteVendor(int id) async {
    try {
      await _dio.delete('${ApiConstants.vendors}/$id');
    } catch (e) {
      rethrow;
    }
  }
}

@riverpod
VendorRepository vendorRepository(VendorRepositoryRef ref) {
  return VendorRepository(ref.watch(dioClientProvider));
}
