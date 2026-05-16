import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/admin/data/mock_master_data.dart'; // Fallback

class MasterDataService {
  final ApiClient _apiClient;

  MasterDataService(this._apiClient);

  Future<List<DrugModel>> getDrugs() async {
    try {
      final response = await _apiClient.client.get('/medicines');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => DrugModel(
          id: json['id'].toString(),
          genericName: json['generic_name'] ?? '',
          brandName: json['brand_name'] ?? 'Unknown',
          manufacturer: json['manufacturer'] ?? '',
          category: json['category'] ?? '',
          dosageForm: json['dosage_form'] ?? '',
          strength: json['strength'] ?? '',
          isActive: json['is_active'] ?? true,
        )).toList();
      }
      return [];
    } on DioException catch (e) {
      print("Fetch Drugs Failed: ${e.message}");
      return mockDrugs; // Fallback
    }
  }
}
