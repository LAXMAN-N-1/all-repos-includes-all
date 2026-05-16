import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_response.dart';
import '../models/onboarding_state.dart';

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(ref.watch(dioProvider));
});

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Dio _dio;
  OnboardingNotifier(this._dio) : super(const OnboardingState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get(ApiConstants.onboardingStatus);
      state = state.copyWith(
        isLoading: false,
        status: OnboardingStatusDto.fromJson(ApiResponse.asMap(response.data)),
      );
    } on DioException catch (e) {
      log('Onboarding API Error: ${e.message}', error: e);
      state = state.copyWith(
        isLoading: false,
        error: ApiResponse.errorMessage(e, fallback: 'Failed to load onboarding status'),
      );
    } catch (e) {
      log('Onboarding Error: $e');
      state = state.copyWith(isLoading: false, error: 'Unexpected error');
    }
  }

  Future<void> triggerAutomatedChecks() async {
    try {
      await _dio.post('${ApiConstants.onboardingStatus.replaceFirst('/status', '')}/stage/trigger-checks');
      await refresh();
    } catch (e) {
      log('Trigger checks error: $e');
    }
  }

  Future<void> submitKyc() async {
    try {
      await _dio.post('${ApiConstants.onboardingStatus.replaceFirst('/status', '')}/stage/submit-kyc');
      await refresh();
    } catch (e) {
      log('Submit KYC error: $e');
    }
  }

  Future<void> completeTraining() async {
    try {
      await _dio.post('${ApiConstants.onboardingStatus.replaceFirst('/status', '')}/stage/complete-training');
      await refresh();
    } catch (e) {
      log('Complete training error: $e');
    }
  }
}
