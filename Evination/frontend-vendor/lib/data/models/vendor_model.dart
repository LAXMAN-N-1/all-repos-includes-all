import 'package:json_annotation/json_annotation.dart';

part 'vendor_model.g.dart';

@JsonSerializable()
class Vendor {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'company_name')
  final String companyName;
  @JsonKey(name: 'business_type')
  final String? businessType;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  @JsonKey(name: 'zip_code')
  final String? zipCode;
  final String? website;
  @JsonKey(name: 'year_established')
  final String? yearEstablished;
  @JsonKey(name: 'team_size')
  final String? teamSize;
  final String? description;
  final String status; // pending, approved, rejected

  // associated User fields usually come joined or separate.
  // We can add them if the API returns them nested.
  
  Vendor({
    required this.id,
    required this.userId,
    required this.companyName,
    this.businessType,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.website,
    this.yearEstablished,
    this.teamSize,
    this.description,
    this.status = 'pending',
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => _$VendorFromJson(json);

  Map<String, dynamic> toJson() => _$VendorToJson(this);
}
