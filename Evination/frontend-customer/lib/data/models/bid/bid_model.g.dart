// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bid_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BidModelImpl _$$BidModelImplFromJson(Map<String, dynamic> json) =>
    _$BidModelImpl(
      id: (json['id'] as num).toInt(),
      vendorId: (json['vendorId'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      proposal: json['proposal'] as String,
      status: json['status'] as String,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      platformCommission: (json['platformCommission'] as num?)?.toDouble(),
      gstOnCommission: (json['gstOnCommission'] as num?)?.toDouble(),
      gatewayFee: (json['gatewayFee'] as num?)?.toDouble(),
      finalPrice: (json['finalPrice'] as num?)?.toDouble(),
      vendorName: json['vendorName'] as String?,
      vendorImage: json['vendorImage'] as String?,
      vendorRating: (json['vendorRating'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$BidModelImplToJson(_$BidModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vendorId': instance.vendorId,
      'amount': instance.amount,
      'proposal': instance.proposal,
      'status': instance.status,
      'submittedAt': instance.submittedAt.toIso8601String(),
      'platformCommission': instance.platformCommission,
      'gstOnCommission': instance.gstOnCommission,
      'gatewayFee': instance.gatewayFee,
      'finalPrice': instance.finalPrice,
      'vendorName': instance.vendorName,
      'vendorImage': instance.vendorImage,
      'vendorRating': instance.vendorRating,
    };
