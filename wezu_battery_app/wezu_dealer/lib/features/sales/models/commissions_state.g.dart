// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commissions_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommissionDto _$CommissionDtoFromJson(Map<String, dynamic> json) =>
    _CommissionDto(
      id: (json['id'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      stationName: json['station_name'] as String?,
      transactionType: json['transaction_type'] as String?,
      description: json['description'] as String?,
      grossRevenue: (json['grossRevenue'] as num?)?.toDouble() ?? 0.0,
      platformFees: (json['platformFees'] as num?)?.toDouble() ?? 0.0,
      netPayout: (json['netPayout'] as num?)?.toDouble() ?? 0.0,
      rate: (json['rate'] as num?)?.toDouble() ?? 0.05,
    );

Map<String, dynamic> _$CommissionDtoToJson(_CommissionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'status': instance.status,
      'created_at': instance.createdAt,
      'station_name': instance.stationName,
      'transaction_type': instance.transactionType,
      'description': instance.description,
      'grossRevenue': instance.grossRevenue,
      'platformFees': instance.platformFees,
      'netPayout': instance.netPayout,
      'rate': instance.rate,
    };

_PayoutDto _$PayoutDtoFromJson(Map<String, dynamic> json) => _PayoutDto(
      id: (json['id'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      date: json['date'] as String,
      bankName: json['bankName'] as String?,
      accountMask: json['accountMask'] as String?,
      ifsc: json['ifsc'] as String?,
      isVerified: json['isVerified'] as bool?,
    );

Map<String, dynamic> _$PayoutDtoToJson(_PayoutDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'status': instance.status,
      'date': instance.date,
      'bankName': instance.bankName,
      'accountMask': instance.accountMask,
      'ifsc': instance.ifsc,
      'isVerified': instance.isVerified,
    };

_CommissionSummaryDto _$CommissionSummaryDtoFromJson(
        Map<String, dynamic> json) =>
    _CommissionSummaryDto(
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      pendingPayouts: (json['pendingPayouts'] as num?)?.toDouble() ?? 0.0,
      totalCommissionEarned:
          (json['totalCommissionEarned'] as num?)?.toDouble() ?? 0.0,
      currentCommissionRate:
          (json['current_commission_rate'] as num?)?.toDouble() ?? 0.0,
      revenueSplit: json['revenueSplit'] as Map<String, dynamic>? ?? const {},
      financialSummary:
          json['financialSummary'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$CommissionSummaryDtoToJson(
        _CommissionSummaryDto instance) =>
    <String, dynamic>{
      'totalEarnings': instance.totalEarnings,
      'pendingPayouts': instance.pendingPayouts,
      'totalCommissionEarned': instance.totalCommissionEarned,
      'current_commission_rate': instance.currentCommissionRate,
      'revenueSplit': instance.revenueSplit,
      'financialSummary': instance.financialSummary,
    };
