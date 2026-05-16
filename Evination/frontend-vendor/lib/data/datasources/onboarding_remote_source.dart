import 'package:dio/dio.dart';
import 'package:vendor_app/data/models/onboarding/onboarding_models.dart';

abstract class OnboardingRemoteSource {
  Future<Map<String, dynamic>> initiateOnboarding(InitiateRequest data);
  Future<void> saveBusinessDetails(BusinessDetailsRequest data);
  Future<void> saveDocuments(DocumentUploadRequest data);
  // Future<void> saveBankingDetails(BankingDetailsRequest data); // Add endpoint if specific exists, else use details Patch
  Future<void> submitApplication();
}

class OnboardingRemoteSourceImpl implements OnboardingRemoteSource {
  final Dio dio;

  OnboardingRemoteSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> initiateOnboarding(InitiateRequest data) async {
    try {
      final response = await dio.post('/api/onboarding/initiate', data: data.toJson());
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveBusinessDetails(BusinessDetailsRequest data) async {
    try {
      await dio.patch('/api/onboarding/details', data: data.toJson());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveDocuments(DocumentUploadRequest data) async {
    try {
      await dio.post('/api/onboarding/documents', data: data.toJson());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> submitApplication() async {
    try {
      await dio.post('/api/onboarding/submit');
    } catch (e) {
      rethrow;
    }
  }
}
