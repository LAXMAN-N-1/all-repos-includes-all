import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_response.dart';
import '../models/campaign_state.dart';

final campaignsProvider = StateNotifierProvider<CampaignNotifier, CampaignState>((ref) {
  return CampaignNotifier(ref.watch(dioProvider));
});

class CampaignNotifier extends StateNotifier<CampaignState> {
  final Dio _dio;
  CampaignNotifier(this._dio) : super(const CampaignState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get(ApiConstants.campaigns);

      final rawList = ApiResponse.asList(
        response.data,
        keys: const ['campaigns', 'promotions', 'data'],
      );

      final parsed = rawList.map((e) {
        return CampaignDto(
          id: e['id'] ?? 0,
          title: e['title']?.toString() ?? e['name']?.toString() ?? 'Untitled',
          desc: e['desc']?.toString() ?? e['description']?.toString() ?? '',
          status: e['status']?.toString() ??
              ((e['is_active'] ?? false) ? 'Active' : 'Inactive'),
          dates: e['dates']?.toString() ??
              '${e['start_date']?.toString().split('T')[0] ?? ''} - ${e['end_date']?.toString().split('T')[0] ?? ''}',
          redemptions: e['redemptions']?.toString() ??
              (e['usage_count'] ?? 0).toString(),
          revenue: e['revenue']?.toString() ?? '-',
        );
      }).toList();
      state = state.copyWith(isLoading: false, campaigns: parsed);
    } on DioException catch (e) {
      log('Campaign API Error: ${e.message}', error: e);
      state = state.copyWith(
        isLoading: false,
        error: ApiResponse.errorMessage(e, fallback: 'Failed to load campaigns'),
      );
    } catch (e) {
      log('Campaign Error: $e');
      state = state.copyWith(isLoading: false, error: 'Unexpected error');
    }
  }
}
