// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_bid_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VendorBidModel _$VendorBidModelFromJson(Map<String, dynamic> json) =>
    VendorBidModel(
      id: (json['id'] as num?)?.toInt(),
      bookingId: (json['booking_id'] as num?)?.toInt(),
      amount: (json['amount'] as num).toDouble(),
      proposal: json['proposal'] as String,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$VendorBidModelToJson(VendorBidModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'booking_id': instance.bookingId,
      'amount': instance.amount,
      'proposal': instance.proposal,
      'status': instance.status,
    };
