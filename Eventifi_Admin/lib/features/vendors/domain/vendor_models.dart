import 'package:freezed_annotation/freezed_annotation.dart';

part 'vendor_models.freezed.dart';
part 'vendor_models.g.dart';

@freezed
class Vendor with _$Vendor {
  const factory Vendor({
    required int id,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    required String email,
    String? phone,
    @JsonKey(name: 'company_name') String? companyName,
    @Default('Pending') String status, // Active, Pending, Suspended
  }) = _Vendor;

  factory Vendor.fromJson(Map<String, dynamic> json) => _$VendorFromJson(json);
}

@freezed
class CreateVendorRequest with _$CreateVendorRequest {
  const factory CreateVendorRequest({
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') required String lastName,
    required String email,
    String? phone,
    @JsonKey(name: 'company_name') String? companyName,
    @Default('Pending') String status,
  }) = _CreateVendorRequest;

  factory CreateVendorRequest.fromJson(Map<String, dynamic> json) => _$CreateVendorRequestFromJson(json);
}
