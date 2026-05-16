import 'package:json_annotation/json_annotation.dart';

part 'vendor_bid_model.g.dart';

@JsonSerializable()
class VendorBidModel {
  final int? id;
  @JsonKey(name: 'booking_id') // We use this in form, logically linked
  final int? bookingId; 
  final double amount;
  final String proposal;
  final String? status;
  
  VendorBidModel({
    this.id,
    this.bookingId,
    required this.amount,
    required this.proposal,
    this.status
  });
  
  // Custom ToJson for API submission logic if needed
  Map<String, dynamic> toSubmissionJson() {
    return {
      "amount": amount,
      "proposal": proposal
    };
  }

  factory VendorBidModel.fromJson(Map<String, dynamic> json) => _$VendorBidModelFromJson(json);
  Map<String, dynamic> toJson() => _$VendorBidModelToJson(this);
}
