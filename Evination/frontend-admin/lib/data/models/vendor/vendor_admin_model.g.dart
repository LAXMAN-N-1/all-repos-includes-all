// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_admin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminVendorModel _$AdminVendorModelFromJson(Map<String, dynamic> json) =>
    AdminVendorModel(
      id: (json['id'] as num).toInt(),
      companyName: json['company_name'] as String?,
      businessName: json['business_name'] as String?,
      vendorType: json['vendor_type'] as String,
      contactPerson: json['contact_person'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String,
      tier: json['tier'] as String?,
      is_verified: json['is_verified'] as bool?,
      joinedDate: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      city: json['city'] as String?,
      state: json['state'] as String?,
      description: json['description'] as String?,
      gstNumber: json['gst_number'] as String?,
      panNumber: json['pan_number'] as String?,
      documents: (json['documents'] as List<dynamic>?)
          ?.map(
            (e) => VendorDocumentAdminModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      address: json['address'] as String?,
      zipCode: json['zip_code'] as String?,
      servicesOffered: json['services_offered'] as List<dynamic>?,
      payoutSetting: json['payout_setting'] == null
          ? null
          : VendorPayoutSettingAdminModel.fromJson(
              json['payout_setting'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$AdminVendorModelToJson(AdminVendorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company_name': instance.companyName,
      'business_name': instance.businessName,
      'vendor_type': instance.vendorType,
      'contact_person': instance.contactPerson,
      'email': instance.email,
      'phone': instance.phone,
      'status': instance.status,
      'tier': instance.tier,
      'is_verified': instance.is_verified,
      'created_at': instance.joinedDate?.toIso8601String(),
      'city': instance.city,
      'state': instance.state,
      'description': instance.description,
      'gst_number': instance.gstNumber,
      'pan_number': instance.panNumber,
      'address': instance.address,
      'zip_code': instance.zipCode,
      'services_offered': instance.servicesOffered,
      'payout_setting': instance.payoutSetting,
      'documents': instance.documents,
    };

VendorDocumentAdminModel _$VendorDocumentAdminModelFromJson(
  Map<String, dynamic> json,
) => VendorDocumentAdminModel(
  id: (json['id'] as num).toInt(),
  documentType: json['document_type'] as String,
  fileUrl: json['file_url'] as String,
  documentNumber: json['document_number'] as String?,
  verificationStatus: json['verification_status'] as String,
  rejectionReason: json['rejection_reason'] as String?,
);

Map<String, dynamic> _$VendorDocumentAdminModelToJson(
  VendorDocumentAdminModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'document_type': instance.documentType,
  'file_url': instance.fileUrl,
  'document_number': instance.documentNumber,
  'verification_status': instance.verificationStatus,
  'rejection_reason': instance.rejectionReason,
};

VendorPayoutSettingAdminModel _$VendorPayoutSettingAdminModelFromJson(
  Map<String, dynamic> json,
) => VendorPayoutSettingAdminModel(
  id: (json['id'] as num).toInt(),
  bankAccountNumber: json['bank_account_number'] as String?,
  bankIfsc: json['bank_ifsc'] as String?,
  bankName: json['bank_name'] as String?,
  beneficiaryName: json['beneficiary_name'] as String?,
);

Map<String, dynamic> _$VendorPayoutSettingAdminModelToJson(
  VendorPayoutSettingAdminModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'bank_account_number': instance.bankAccountNumber,
  'bank_ifsc': instance.bankIfsc,
  'bank_name': instance.bankName,
  'beneficiary_name': instance.beneficiaryName,
};
