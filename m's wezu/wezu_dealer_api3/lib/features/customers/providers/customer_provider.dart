import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_response.dart';
import '../models/customer_state.dart';

final customerProvider = StateNotifierProvider<CustomerNotifier, CustomerState>((ref) {
  return CustomerNotifier(ref.watch(dioProvider));
});

class CustomerNotifier extends StateNotifier<CustomerState> {
  final Dio _dio;
  CustomerNotifier(this._dio) : super(const CustomerState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get(ApiConstants.customers);

      // Backend returns {"data": [...], "total": N}
      final rawList = ApiResponse.asList(
        response.data,
        keys: const ['customers', 'data'],
      );

      final parsed = rawList.map((e) {
        return CustomerDto(
          id: e['id'] ?? 0,
          name: e['name']?.toString() ?? e['full_name']?.toString() ?? 'Unknown',
          email: e['email']?.toString() ?? 'N/A',
          phone: e['phone']?.toString() ?? e['phone_number']?.toString() ?? 'N/A',
          totalRentals: e['total_rentals'] ?? 0,
          status: e['status']?.toString() ?? 'Active',
          joinedAt: e['joined_at']?.toString() ?? e['created_at']?.toString(),
        );
      }).toList();
      state = state.copyWith(isLoading: false, customers: parsed);
    } on DioException catch (e) {
      log('Customer API Error: ${e.message}', error: e);
      state = state.copyWith(
        isLoading: false,
        error: ApiResponse.errorMessage(e, fallback: 'Failed to load customers'),
      );
    } catch (e) {
      log('Customer Error: $e');
      state = state.copyWith(isLoading: false, error: 'Unexpected error');
    }
  }
}
