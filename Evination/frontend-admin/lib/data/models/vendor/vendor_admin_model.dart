import 'package:json_annotation/json_annotation.dart';

part 'vendor_admin_model.g.dart';

@JsonSerializable()
class AdminVendorModel {
  final int id;
  @JsonKey(name: 'company_name') final String? companyName; // for company
  @JsonKey(name: 'business_name') final String? businessName; // for individual
  @JsonKey(name: 'vendor_type') final String vendorType;
  @JsonKey(name: 'contact_person') final String? contactPerson;
  final String? email;
  final String? phone;
  final String status; // active, pending_approval, rejected, draft
  final String? tier;
  final bool? is_verified;
  
  @JsonKey(name: 'created_at') final DateTime? joinedDate;
  
  // Extra fields for details
  final String? city;
  final String? state;
  final String? description;
  @JsonKey(name: 'gst_number') final String? gstNumber;
  @JsonKey(name: 'pan_number') final String? panNumber;
  
  // Address & Extended fields
  final String? address;
  @JsonKey(name: 'zip_code') final String? zipCode;
  
  // Services
  @JsonKey(name: 'services_offered') final List<dynamic>? servicesOffered; 

  // Banking
  @JsonKey(name: 'payout_setting') final VendorPayoutSettingAdminModel? payoutSetting;
  
  // Relations
  @JsonKey(name: 'documents') final List<VendorDocumentAdminModel>? documents;

  AdminVendorModel({
    required this.id,
    this.companyName,
    this.businessName,
    required this.vendorType,
    this.contactPerson,
    this.email,
    this.phone,
    required this.status,
    this.tier,
    this.is_verified,
    this.joinedDate,
    this.city,
    this.state,
    this.description,
    this.gstNumber,
    this.panNumber,
    this.documents,
    this.address,
    this.zipCode,
    this.servicesOffered,
    this.payoutSetting,
  });

  String get displayName => companyName ?? businessName ?? "Unknown Vendor";

  factory AdminVendorModel.fromJson(Map<String, dynamic> json) => _$AdminVendorModelFromJson(json);
  Map<String, dynamic> toJson() => _$AdminVendorModelToJson(this);
}

@JsonSerializable()
class VendorDocumentAdminModel {
  final int id;
  @JsonKey(name: 'document_type') final String documentType;
  @JsonKey(name: 'file_url') final String fileUrl;
  @JsonKey(name: 'document_number') final String? documentNumber;
  @JsonKey(name: 'verification_status') final String verificationStatus; // PENDING, VERIFIED, REJECTED
  @JsonKey(name: 'rejection_reason') final String? rejectionReason;

  VendorDocumentAdminModel({
    required this.id,
    required this.documentType,
    required this.fileUrl,
    this.documentNumber,
    required this.verificationStatus,
    this.rejectionReason,
  });

  factory VendorDocumentAdminModel.fromJson(Map<String, dynamic> json) => _$VendorDocumentAdminModelFromJson(json);
  Map<String, dynamic> toJson() => _$VendorDocumentAdminModelToJson(this);
}

@JsonSerializable()
class VendorPayoutSettingAdminModel {
  final int id;
  @JsonKey(name: 'bank_account_number') final String? bankAccountNumber;
  @JsonKey(name: 'bank_ifsc') final String? bankIfsc;
  @JsonKey(name: 'bank_name') final String? bankName;
  @JsonKey(name: 'beneficiary_name') final String? beneficiaryName;

  VendorPayoutSettingAdminModel({
    required this.id,
    this.bankAccountNumber,
    this.bankIfsc,
    this.bankName,
    this.beneficiaryName,
  });

  factory VendorPayoutSettingAdminModel.fromJson(Map<String, dynamic> json) => _$VendorPayoutSettingAdminModelFromJson(json);
  Map<String, dynamic> toJson() => _$VendorPayoutSettingAdminModelToJson(this);
}
