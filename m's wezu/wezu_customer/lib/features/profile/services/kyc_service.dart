import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';

class KYCService {
  final Dio _dio;
  KYCService(this._dio);

  Future<void> submitKYC({required String idNumber, required String idType}) async {
    await _dio.post('/kyc/submit', data: {
      'id_number': idNumber,
      'id_type': idType,
    });
  }

  Future<void> uploadDocument({required String filePath, required String docType}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'type': docType, // e.g. 'utility_bill', 'video'
    });
    await _dio.post('/kyc/upload', data: formData);
  }
}

final kycServiceProvider = Provider((ref) {
  return KYCService(ref.read(authenticatedDioProvider));
});
