import 'package:freezed_annotation/freezed_annotation.dart';

part 'bid_model.freezed.dart';
part 'bid_model.g.dart';

@freezed
class BidModel with _$BidModel {
  const factory BidModel({
    required int id,
    required int vendorId,
    required double amount,
    required String proposal,
    required String status,
    required DateTime submittedAt,
    
    // Admin Curation Fields
    double? platformCommission,
    double? gstOnCommission,
    double? gatewayFee,
    double? finalPrice,
    
    // UI Helper
    String? vendorName,
    String? vendorImage,
    double? vendorRating,
  }) = _BidModel;

  factory BidModel.fromJson(Map<String, dynamic> json) => _$BidModelFromJson(json);
}
