// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransactionDto _$TransactionDtoFromJson(Map<String, dynamic> json) =>
    _TransactionDto(
      id: (json['id'] as num).toInt(),
      transactionType: json['transaction_type'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      description: json['description'] as String?,
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      batteryId: json['battery_id'] as String?,
      stationName: json['station_name'] as String?,
      terminalNumber: json['terminal_number'] as String?,
      duration: json['duration'] as String?,
      platformFee: (json['platform_fee'] as num?)?.toDouble() ?? 0.0,
      commissionRate: (json['commission_rate'] as num?)?.toDouble() ?? 0.05,
      commissionAmount: (json['commission_amount'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['net_amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] as String?,
      settlementStatus: json['settlement_status'] as String?,
      expectedSettlementDate: json['expected_settlement_date'] as String?,
    );

Map<String, dynamic> _$TransactionDtoToJson(_TransactionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transaction_type': instance.transactionType,
      'amount': instance.amount,
      'status': instance.status,
      'created_at': instance.createdAt,
      'description': instance.description,
      'customer_name': instance.customerName,
      'customer_phone': instance.customerPhone,
      'battery_id': instance.batteryId,
      'station_name': instance.stationName,
      'terminal_number': instance.terminalNumber,
      'duration': instance.duration,
      'platform_fee': instance.platformFee,
      'commission_rate': instance.commissionRate,
      'commission_amount': instance.commissionAmount,
      'net_amount': instance.netAmount,
      'payment_method': instance.paymentMethod,
      'settlement_status': instance.settlementStatus,
      'expected_settlement_date': instance.expectedSettlementDate,
    };
