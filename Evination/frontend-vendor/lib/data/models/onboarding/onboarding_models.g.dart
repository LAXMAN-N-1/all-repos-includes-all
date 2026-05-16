// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InitiateRequest _$InitiateRequestFromJson(Map<String, dynamic> json) =>
    InitiateRequest(
      vendor_type: json['vendor_type'] as String,
      company_name: json['company_name'] as String?,
      business_name: json['business_name'] as String?,
      contact_person: json['contact_person'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$InitiateRequestToJson(InitiateRequest instance) =>
    <String, dynamic>{
      'vendor_type': instance.vendor_type,
      'company_name': instance.company_name,
      'business_name': instance.business_name,
      'contact_person': instance.contact_person,
      'phone': instance.phone,
      'email': instance.email,
    };

BusinessDetailsRequest _$BusinessDetailsRequestFromJson(
  Map<String, dynamic> json,
) => BusinessDetailsRequest(
  company_name: json['company_name'] as String?,
  trade_name: json['trade_name'] as String?,
  company_type: json['company_type'] as String?,
  team_size: json['team_size'] as String?,
  office_type: json['office_type'] as String?,
  description: json['description'] as String?,
  website: json['website'] as String?,
  year_established: json['year_established'] as String?,
  address: json['address'] as String?,
  city: json['city'] as String,
  state: json['state'] as String,
  zip_code: json['zip_code'] as String?,
  coverage_areas:
      (json['coverage_areas'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  categories: (json['categories'] as List<dynamic>)
      .map((e) => CategorySelection.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BusinessDetailsRequestToJson(
  BusinessDetailsRequest instance,
) => <String, dynamic>{
  'company_name': instance.company_name,
  'trade_name': instance.trade_name,
  'company_type': instance.company_type,
  'team_size': instance.team_size,
  'office_type': instance.office_type,
  'description': instance.description,
  'website': instance.website,
  'year_established': instance.year_established,
  'address': instance.address,
  'city': instance.city,
  'state': instance.state,
  'zip_code': instance.zip_code,
  'coverage_areas': instance.coverage_areas,
  'categories': instance.categories,
};

CategorySelection _$CategorySelectionFromJson(Map<String, dynamic> json) =>
    CategorySelection(
      category_id: (json['category_id'] as num).toInt(),
      sub_categories:
          (json['sub_categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      price_min: (json['price_min'] as num?)?.toDouble() ?? 0,
      price_max: (json['price_max'] as num?)?.toDouble(),
      experience_years: (json['experience_years'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CategorySelectionToJson(CategorySelection instance) =>
    <String, dynamic>{
      'category_id': instance.category_id,
      'sub_categories': instance.sub_categories,
      'price_min': instance.price_min,
      'price_max': instance.price_max,
      'experience_years': instance.experience_years,
    };

DocItem _$DocItemFromJson(Map<String, dynamic> json) => DocItem(
  type: json['type'] as String,
  url: json['url'] as String,
  number: json['number'] as String?,
);

Map<String, dynamic> _$DocItemToJson(DocItem instance) => <String, dynamic>{
  'type': instance.type,
  'url': instance.url,
  'number': instance.number,
};

DocumentUploadRequest _$DocumentUploadRequestFromJson(
  Map<String, dynamic> json,
) => DocumentUploadRequest(
  documents: (json['documents'] as List<dynamic>)
      .map((e) => DocItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DocumentUploadRequestToJson(
  DocumentUploadRequest instance,
) => <String, dynamic>{'documents': instance.documents};

BankingDetailsRequest _$BankingDetailsRequestFromJson(
  Map<String, dynamic> json,
) => BankingDetailsRequest(
  account_number: json['account_number'] as String?,
  ifsc: json['ifsc'] as String?,
  upi_id: json['upi_id'] as String?,
  gst_number: json['gst_number'] as String?,
  pan_number: json['pan_number'] as String?,
);

Map<String, dynamic> _$BankingDetailsRequestToJson(
  BankingDetailsRequest instance,
) => <String, dynamic>{
  'account_number': instance.account_number,
  'ifsc': instance.ifsc,
  'upi_id': instance.upi_id,
  'gst_number': instance.gst_number,
  'pan_number': instance.pan_number,
};
