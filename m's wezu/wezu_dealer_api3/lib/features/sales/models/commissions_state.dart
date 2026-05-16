import 'package:freezed_annotation/freezed_annotation.dart';

part 'commissions_state.freezed.dart';
part 'commissions_state.g.dart';

@freezed
abstract class CommissionDto with _$CommissionDto {
  const factory CommissionDto({
    required int id,
    required double amount,
    required String status,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'station_name') String? stationName,
    @JsonKey(name: 'transaction_type') String? transactionType,
    String? description,
    @Default(0.0) double grossRevenue,
    @Default(0.0) double platformFees,
    @Default(0.0) double netPayout,
    @Default(0.05) double rate,
  }) = _CommissionDto;

  factory CommissionDto.fromJson(Map<String, dynamic> json) =>
      _$CommissionDtoFromJson(json);
}

@freezed
abstract class PayoutDto with _$PayoutDto {
  const factory PayoutDto({
    required int id,
    required double amount,
    required String status,
    required String date,
    String? bankName,
    String? accountMask,
    String? ifsc,
    bool? isVerified,
  }) = _PayoutDto;

  factory PayoutDto.fromJson(Map<String, dynamic> json) =>
      _$PayoutDtoFromJson(json);
}

@freezed
abstract class CommissionSummaryDto with _$CommissionSummaryDto {
  const factory CommissionSummaryDto({
    @Default(0.0) double totalEarnings,
    @Default(0.0) double pendingPayouts,
    @Default(0.0) double totalCommissionEarned,
    @JsonKey(name: 'current_commission_rate')
    @Default(0.0)
    double currentCommissionRate,
    @Default({}) Map<String, dynamic> revenueSplit,
    @Default({}) Map<String, dynamic> financialSummary,
  }) = _CommissionSummaryDto;

  factory CommissionSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$CommissionSummaryDtoFromJson(json);
}

@freezed
abstract class CommissionsState with _$CommissionsState {
  const factory CommissionsState({
    @Default(true) bool isLoading,
    String? error,
    @Default([]) List<CommissionDto> commissions,
    @Default([]) List<PayoutDto> payouts,
    @Default(0) int total,
    CommissionSummaryDto? summary,
  }) = _CommissionsState;
}
