import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/utils/web_download.dart';
import '../models/commissions_state.dart';

final commissionsProvider =
    StateNotifierProvider<CommissionsNotifier, CommissionsState>((ref) {
  return CommissionsNotifier(ref.watch(dioProvider));
});

class CommissionsNotifier extends StateNotifier<CommissionsState> {
  final Dio _dio;

  CommissionsNotifier(this._dio) : super(const CommissionsState()) {
    refresh();
  }

  int _toInt(dynamic v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
  double _toDouble(dynamic v) =>
      v is double ? v : double.tryParse(v?.toString() ?? '') ?? 0.0;
  Map<String, dynamic> _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
  List _asList(dynamic value) => value is List ? value : const [];
  String? _asString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  DateTime _safeDate(String? iso) =>
      DateTime.tryParse(iso ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
  String? _maskAccountNumber(String? accountNumber) {
    if (accountNumber == null || accountNumber.isEmpty) return null;
    if (accountNumber.length <= 4) return accountNumber;
    return 'XXXX ${accountNumber.substring(accountNumber.length - 4)}';
  }

  Future<void> refresh({int skip = 0, int limit = 50}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _dio.get(ApiConstants.commissions,
            queryParameters: {'skip': skip, 'limit': limit}),
        _dio.get(ApiConstants.commissionSummary),
        _dio.get(ApiConstants.dealerSettlements,
            queryParameters: {'skip': skip, 'limit': limit}),
        _dio.get(ApiConstants.dealerBankAccount),
      ]);

      final commsResponse = results[0];
      final summaryResponse = results[1];
      final settlementsResponse = results[2];
      final bankResponse = results[3];

      // Parse Commissions
      final dynamic commsData = commsResponse.data;
      List rawList = [];
      int total = 0;
      if (commsData is List) {
        rawList = commsData;
        total = rawList.length;
      } else if (commsData is Map) {
        final commsMap = _asMap(commsData);
        rawList = commsMap['data'] ??
            commsMap['commissions'] ??
            commsMap['items'] ??
            [];
        total =
            _toInt(commsMap['total'] ?? commsMap['count'] ?? rawList.length);
      }
      final parsedComms = rawList
          .map((e) => CommissionDto.fromJson(e as Map<String, dynamic>))
          .toList();

      // Parse Summary
      CommissionSummaryDto? summary;
      if (summaryResponse.data != null &&
          summaryResponse.data is Map<String, dynamic>) {
        final summaryData = summaryResponse.data as Map<String, dynamic>;

        // Merge data from both if they are split
        summary = CommissionSummaryDto.fromJson({
          ...summaryData,
          if (commsData is Map)
            ...commsData, // Might contain total_commission_earned etc.
        });
      }

      // Parse bank details once; apply to each payout row
      final bankRoot = _asMap(bankResponse.data);
      final bankData = _asMap(bankRoot['data']);
      final bankDetails =
          _asMap(bankData['bank_details'] ?? bankRoot['bank_details']);
      final bankName = _asString(bankDetails['bank_name']);
      final accountMask =
          _maskAccountNumber(_asString(bankDetails['account_number']));
      final ifsc = _asString(bankDetails['ifsc_code']);
      final isVerified = bankDetails['verified'] is bool
          ? bankDetails['verified'] as bool
          : null;

      // Parse payouts from dealer settlements endpoint
      final dynamic settlementsData = settlementsResponse.data;
      List settlementsRaw = [];
      if (settlementsData is List) {
        settlementsRaw = settlementsData;
      } else if (settlementsData is Map) {
        final settlementsMap = _asMap(settlementsData);
        settlementsRaw = _asList(
          settlementsMap['data'] ??
              settlementsMap['settlements'] ??
              settlementsMap['items'],
        );
      }

      final parsedPayouts = settlementsRaw
          .whereType<Map>()
          .map((raw) {
            final item = _asMap(raw);
            final date = _asString(item['due_date']) ??
                _asString(item['paid_at']) ??
                _asString(item['created_at']) ??
                DateTime.now().toIso8601String();
            return PayoutDto(
              id: _toInt(item['id']),
              amount: _toDouble(
                item['net_payable'] ??
                    item['amount'] ??
                    item['total_commission'],
              ),
              status: (_asString(item['status']) ?? 'PENDING').toUpperCase(),
              date: date,
              bankName: bankName,
              accountMask: accountMask,
              ifsc: ifsc,
              isVerified: isVerified,
            );
          })
          .where((p) => p.id > 0)
          .toList()
        ..sort((a, b) => _safeDate(b.date).compareTo(_safeDate(a.date)));

      state = state.copyWith(
        isLoading: false,
        commissions: parsedComms,
        payouts: parsedPayouts,
        total: total,
        summary: summary,
      );
    } on DioException catch (e) {
      log('Commissions API Error: ${e.message}', error: e);
      state = state.copyWith(
          isLoading: false,
          error: 'Failed to connect to backend: ${e.message}');
    } catch (e) {
      log('Commissions Error: $e');
      state = state.copyWith(isLoading: false, error: 'Unexpected error: $e');
    }
  }

  Future<void> loadMore({int limit = 50}) async {
    if (state.isLoading || state.commissions.length >= state.total) return;

    final currentSkip = state.commissions.length;
    try {
      final response = await _dio.get(
        ApiConstants.commissions,
        queryParameters: {
          'skip': currentSkip,
          'limit': limit,
        },
      );

      final dynamic data = response.data;
      List rawList = [];
      if (data is List) {
        rawList = data;
      } else if (data is Map) {
        rawList = data['data'] ?? data['commissions'] ?? data['items'] ?? [];
      }

      final parsed = rawList
          .map((e) => CommissionDto.fromJson(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        commissions: [...state.commissions, ...parsed],
      );
    } catch (e) {
      log('Commissions Load More Error: $e');
    }
  }

  Future<void> downloadSettlementPdf(int id) async {
    try {
      final response = await _dio.get<List<int>>(
        ApiConstants.settlementPdf(id),
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data != null) {
        triggerWebDownloadFromBytes(
          response.data!,
          'settlement_$id.pdf',
        );
      }
    } catch (e) {
      log('Download Settlement PDF Error: $e');
    }
  }
}
