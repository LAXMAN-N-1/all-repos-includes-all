import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_response.dart';
import '../models/sales_state.dart';

final salesProvider = StateNotifierProvider<SalesNotifier, SalesState>((ref) {
  return SalesNotifier(ref.watch(dioProvider));
});

class SalesNotifier extends StateNotifier<SalesState> {
  final Dio _dio;
  SalesNotifier(this._dio) : super(const SalesState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get(ApiConstants.transactions);
      final rawList = ApiResponse.asList(
        response.data,
        keys: const ['transactions', 'data', 'items'],
      );

      final parsed = rawList.whereType<Map>().map((entry) {
        final raw = Map<String, dynamic>.from(entry);
        final amount = _toDouble(raw['amount'] ?? raw['total_amount']);
        final commissionRate = _toDouble(raw['commission_rate'] ?? 0.05);
        final commissionAmount = _toDouble(
          raw['commission_amount'] ??
              raw['commission'] ??
              (amount * commissionRate),
        );
        final platformFee =
            _toDouble(raw['platform_fee'] ?? raw['platform_fees']);
        final netAmount = _toDouble(
          raw['net_amount'] ?? (amount - platformFee - commissionAmount),
        );

        return TransactionDto.fromJson({
          'id': _toInt(raw['id']),
          'transaction_type':
              (raw['transaction_type'] ?? raw['type'] ?? 'Rental').toString(),
          'amount': amount,
          'status': _normalizeStatus(raw['status']?.toString()),
          'created_at': (raw['created_at'] ?? '').toString(),
          'description': raw['description']?.toString(),
          'customer_name': raw['customer_name']?.toString(),
          'customer_phone': raw['customer_phone']?.toString(),
          'battery_id': raw['battery_id']?.toString(),
          'station_name': raw['station_name']?.toString(),
          'terminal_number': raw['terminal_number']?.toString(),
          'duration': raw['duration']?.toString(),
          'platform_fee': platformFee,
          'commission_rate': commissionRate,
          'commission_amount': commissionAmount,
          'net_amount': netAmount,
          'payment_method': raw['payment_method']?.toString(),
          'settlement_status': raw['settlement_status']?.toString(),
          'expected_settlement_date':
              raw['expected_settlement_date']?.toString(),
        });
      }).toList();
      state = state.copyWith(isLoading: false, transactions: parsed);
    } on DioException catch (e) {
      log('Sales API Error: ${e.message}', error: e);
      state = state.copyWith(
        isLoading: false,
        error: ApiResponse.errorMessage(e,
            fallback: 'Failed to load transactions'),
      );
    } catch (e) {
      log('Sales Error: $e');
      state = state.copyWith(isLoading: false, error: 'Unexpected error');
    }
  }

  Future<TransactionDto?> fetchTransactionDetail(int rentalId) async {
    try {
      final response = await _dio.get(
        ApiConstants.dealerTransactionDetail('RENTAL-$rentalId'),
      );

      final raw = ApiResponse.asMap(response.data, keys: const ['data']);
      if (raw.isEmpty) return null;

      final grossAmount = _toDouble(raw['gross_amount']);
      final platformFee = _toDouble(raw['platform_fee']);
      final commissionRate = _toDouble(raw['commission_rate']);
      final commissionAmount = _toDouble(raw['commission_amount']);
      final netAmount = _toDouble(raw['net_amount']);

      return TransactionDto.fromJson({
        'id': rentalId,
        'transaction_type':
            (raw['type'] ?? raw['transaction_type'] ?? 'Rental').toString(),
        'amount': grossAmount,
        'status': _normalizeStatus(raw['status']?.toString()),
        'created_at':
            (raw['date'] ?? raw['created_at'] ?? '').toString(),
        'description': raw['description']?.toString(),
        'customer_name': raw['customer_name']?.toString(),
        'customer_phone': raw['customer_phone']?.toString(),
        'battery_id': raw['battery_id']?.toString(),
        'station_name': raw['station_name']?.toString(),
        'terminal_number': raw['terminal_number']?.toString(),
        'duration': raw['duration']?.toString(),
        'platform_fee': platformFee,
        'commission_rate': commissionRate,
        'commission_amount': commissionAmount,
        'net_amount': netAmount,
        'payment_method': raw['payment_method']?.toString(),
        'settlement_status': raw['settlement_status']?.toString(),
        'expected_settlement_date':
            raw['expected_settlement_date']?.toString(),
      });
    } on DioException catch (e) {
      log('Sales detail API Error: ${e.message}', error: e);
      return null;
    } catch (e) {
      log('Sales detail parse Error: $e');
      return null;
    }
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  String _normalizeStatus(String? rawStatus) {
    final status = (rawStatus ?? '').toLowerCase().trim();
    if (status.isEmpty) return 'PENDING';
    if (<String>{
      'success',
      'successful',
      'completed',
      'complete',
      'paid',
      'closed',
      'approved',
    }.contains(status)) {
      return 'SUCCESS';
    }
    if (<String>{'failed', 'error', 'cancelled', 'canceled', 'rejected'}
        .contains(status)) {
      return 'FAILED';
    }
    return 'PENDING';
  }
}
