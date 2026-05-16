import 'package:freezed_annotation/freezed_annotation.dart';

part 'sales_state.freezed.dart';
part 'sales_state.g.dart';

@freezed
abstract class TransactionDto with _$TransactionDto {
  const factory TransactionDto({
    required int id,
    @JsonKey(name: 'transaction_type') required String transactionType,
    required double amount,
    required String status,
    @JsonKey(name: 'created_at') required String createdAt,
    String? description,
    
    // Detailed fields for UI
    @JsonKey(name: 'customer_name') String? customerName,
    @JsonKey(name: 'customer_phone') String? customerPhone,
    @JsonKey(name: 'battery_id') String? batteryId,
    @JsonKey(name: 'station_name') String? stationName,
    @JsonKey(name: 'terminal_number') String? terminalNumber,
    String? duration,
    @JsonKey(name: 'platform_fee') @Default(0.0) double platformFee,
    @JsonKey(name: 'commission_rate') @Default(0.05) double commissionRate,
    @JsonKey(name: 'commission_amount') @Default(0.0) double commissionAmount,
    @JsonKey(name: 'net_amount') @Default(0.0) double netAmount,
    @JsonKey(name: 'payment_method') String? paymentMethod,
    @JsonKey(name: 'settlement_status') String? settlementStatus,
    @JsonKey(name: 'expected_settlement_date') String? expectedSettlementDate,
  }) = _TransactionDto;

  factory TransactionDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionDtoFromJson(json);
}

@freezed
abstract class SalesState with _$SalesState {
  const factory SalesState({
    @Default(true) bool isLoading,
    String? error,
    @Default([]) List<TransactionDto> transactions,
  }) = _SalesState;
}
