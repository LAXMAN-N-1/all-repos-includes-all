import 'package:json_annotation/json_annotation.dart';

part 'admin_bid_model.g.dart';

@JsonSerializable()
class AdminBidModel {
  final int id;
  @JsonKey(name: 'vendor_id')
  final int vendorId;
  final double amount;
  final String proposal;
  final String status;
  
  @JsonKey(name: 'platform_commission')
  final double? platformCommission;
  @JsonKey(name: 'gst_on_commission')
  final double? gstOnCommission;
  @JsonKey(name: 'gateway_fee')
  final double? gatewayFee;
  @JsonKey(name: 'final_price')
  final double? finalPrice;
  @JsonKey(name: 'is_pushed')
  final int? isPushed;
  @JsonKey(name: 'vendor_name')
  final String? vendorName;

  AdminBidModel({
    required this.id,
    required this.vendorId,
    required this.amount,
    required this.proposal,
    required this.status,
    this.platformCommission,
    this.gstOnCommission,
    this.gatewayFee,
    this.finalPrice,
    this.isPushed,
    this.vendorName,
  });

  factory AdminBidModel.fromJson(Map<String, dynamic> json) => _$AdminBidModelFromJson(json);
  Map<String, dynamic> toJson() => _$AdminBidModelToJson(this);
}
