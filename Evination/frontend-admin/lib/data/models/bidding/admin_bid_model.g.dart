// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_bid_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminBidModel _$AdminBidModelFromJson(Map<String, dynamic> json) =>
    AdminBidModel(
      id: (json['id'] as num).toInt(),
      vendorId: (json['vendor_id'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      proposal: json['proposal'] as String,
      status: json['status'] as String,
      platformCommission: (json['platform_commission'] as num?)?.toDouble(),
      gstOnCommission: (json['gst_on_commission'] as num?)?.toDouble(),
      gatewayFee: (json['gateway_fee'] as num?)?.toDouble(),
      finalPrice: (json['final_price'] as num?)?.toDouble(),
      isPushed: (json['is_pushed'] as num?)?.toInt(),
      vendorName: json['vendor_name'] as String?,
    );

Map<String, dynamic> _$AdminBidModelToJson(AdminBidModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vendor_id': instance.vendorId,
      'amount': instance.amount,
      'proposal': instance.proposal,
      'status': instance.status,
      'platform_commission': instance.platformCommission,
      'gst_on_commission': instance.gstOnCommission,
      'gateway_fee': instance.gatewayFee,
      'final_price': instance.finalPrice,
      'is_pushed': instance.isPushed,
      'vendor_name': instance.vendorName,
    };
