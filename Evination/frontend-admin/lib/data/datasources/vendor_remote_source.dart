import 'package:dio/dio.dart';
import 'package:admin_panel/data/models/vendor/vendor_admin_model.dart';
import 'package:admin_panel/data/models/vendor/vendor_registration_model.dart';
import 'package:admin_panel/core/api_client.dart'; // Assuming ApiClient exists or use Dio directly

abstract class VendorRemoteSource {
  Future<List<AdminVendorModel>> getPendingVendors();
  Future<List<AdminVendorModel>> getVendors(String status, {int? categoryId});
  Future<AdminVendorModel> getVendorDetails(int id);
  Future<void> approveVendor(int id);
  Future<void> rejectVendor(int id, String reason);
  Future<void> verifyDocument(int vendorId, int docId, String status, String? reason);
  Future<void> createVendor(VendorRegistrationModel data);
}

class VendorRemoteSourceImpl implements VendorRemoteSource {
  final ApiClient apiClient;

  VendorRemoteSourceImpl(this.apiClient);

  @override
  Future<List<AdminVendorModel>> getPendingVendors() async {
    return getVendors('pending');
  }

  @override
  Future<List<AdminVendorModel>> getVendors(String status, {int? categoryId}) async {
    try {
      final params = <String, dynamic>{'status': status};
      if (categoryId != null) params['category_id'] = categoryId;
      
      final response = await apiClient.get('/admin/vendors', queryParameters: params);
      return (response.data as List).map((e) => AdminVendorModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AdminVendorModel> getVendorDetails(int id) async {
     try {
       final response = await apiClient.get('/admin/vendors/$id'); 
       return AdminVendorModel.fromJson(response.data);
     } catch (e) {
       rethrow;
     }
  }

  @override
  Future<void> approveVendor(int id) async {
    await apiClient.post('/admin/vendors/$id/approve');
  }

  @override
  Future<void> rejectVendor(int id, String reason) async {
    await apiClient.post('/admin/vendors/$id/reject', data: {'reason': reason});
  }

  @override
  Future<void> verifyDocument(int vendorId, int docId, String status, String? reason) async {
    await apiClient.post('/admin/vendors/$vendorId/documents/$docId/verify', data: {
      'status': status,
      'reason': reason
    });
  }

  @override
  Future<void> createVendor(VendorRegistrationModel data) async {
    await apiClient.post('/admin/vendors', data: data.toJson());
  }
}
