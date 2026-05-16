import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_response.dart';
import '../models/kyc_status_state.dart';

final kycStatusProvider = StateNotifierProvider<KycStatusNotifier, KycStatusState>((ref) {
  return KycStatusNotifier(ref.watch(dioProvider));
});

class KycStatusNotifier extends StateNotifier<KycStatusState> {
  final Dio _dio;
  KycStatusNotifier(this._dio) : super(const KycStatusState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get(ApiConstants.kycStatus);
      final rawData = ApiResponse.asMap(response.data);

      if (rawData.isEmpty) {
        state = state.copyWith(isLoading: false, status: null);
        return;
      }

      // The active mounted endpoint currently returns onboarding status shape
      // (`current_stage`, `history`, `risk_score`). Normalize to KYC model.
      final normalized = <String, dynamic>{
        'id': rawData['id'] ?? 0,
        'user_id': rawData['user_id'] ?? 0,
        'application_state': rawData['application_state'] ?? rawData['current_stage'] ?? 'UNKNOWN',
        'rejection_reason': rawData['rejection_reason'],
        'adminComments': rawData['admin_comments'] ?? rawData['adminComments'],
        'submitted_at': rawData['submitted_at'],
        'reviewed_at': rawData['reviewed_at'],
        'risk_score': rawData['risk_score'],
        'history': rawData['history'] ?? const [],
      };

      state = state.copyWith(
        isLoading: false,
        status: KycStatusDto.fromJson(normalized),
      );
    } on DioException catch (e) {
      log('KYC Status API Error: ${e.message}', error: e);
      state = state.copyWith(
        isLoading: false,
        error: ApiResponse.errorMessage(e, fallback: 'Failed to load KYC status'),
      );
    } catch (e) {
      log('KYC Status Error: $e');
      state = state.copyWith(isLoading: false, error: 'Unexpected error');
    }
  }
}
