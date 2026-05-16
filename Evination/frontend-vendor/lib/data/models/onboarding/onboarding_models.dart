import 'package:json_annotation/json_annotation.dart';

part 'onboarding_models.g.dart';

@JsonSerializable()
class InitiateRequest {
  final String vendor_type; // 'company' or 'individual'
  final String? company_name;
  final String? business_name;
  final String contact_person;
  final String? phone;
  final String? email;

  InitiateRequest({
    required this.vendor_type,
    this.company_name,
    this.business_name,
    required this.contact_person,
    this.phone,
    this.email,
  });

  factory InitiateRequest.fromJson(Map<String, dynamic> json) => _$InitiateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$InitiateRequestToJson(this);
}

@JsonSerializable()
class BusinessDetailsRequest {
  final String? company_name; // or legal/trade name updates
  final String? trade_name;
  final String? company_type;
  final String? team_size;
  final String? office_type;
  final String? description;
  final String? website;
  final String? year_established;
  
  final String? address;
  final String city;
  final String state;
  final String? zip_code;
  
  final List<String> coverage_areas;
  final List<CategorySelection> categories;

  BusinessDetailsRequest({
    this.company_name,
    this.trade_name,
    this.company_type,
    this.team_size,
    this.office_type,
    this.description,
    this.website,
    this.year_established,
    this.address,
    required this.city,
    required this.state,
    this.zip_code,
    this.coverage_areas = const [],
    required this.categories,
  });

  factory BusinessDetailsRequest.fromJson(Map<String, dynamic> json) => _$BusinessDetailsRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BusinessDetailsRequestToJson(this);
}

@JsonSerializable()
class CategorySelection {
  final int category_id;
  final List<String> sub_categories; // or IDs
  final double price_min;
  final double? price_max;
  final int experience_years;

  CategorySelection({
    required this.category_id,
    this.sub_categories = const [],
    this.price_min = 0,
    this.price_max,
    this.experience_years = 0,
  });

  factory CategorySelection.fromJson(Map<String, dynamic> json) => _$CategorySelectionFromJson(json);
  Map<String, dynamic> toJson() => _$CategorySelectionToJson(this);
}

@JsonSerializable()
class DocItem {
  final String type;
  final String url;
  final String? number;

  DocItem({required this.type, required this.url, this.number});

  factory DocItem.fromJson(Map<String, dynamic> json) => _$DocItemFromJson(json);
  Map<String, dynamic> toJson() => _$DocItemToJson(this);
}

@JsonSerializable()
class DocumentUploadRequest {
  final List<DocItem> documents;

  DocumentUploadRequest({required this.documents});

  factory DocumentUploadRequest.fromJson(Map<String, dynamic> json) => _$DocumentUploadRequestFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentUploadRequestToJson(this);
}

@JsonSerializable()
class BankingDetailsRequest {
  final String? account_number;
  final String? ifsc;
  final String? upi_id;
  final String? gst_number;
  final String? pan_number;

  BankingDetailsRequest({
    this.account_number,
    this.ifsc,
    this.upi_id,
    this.gst_number,
    this.pan_number,
  });

  factory BankingDetailsRequest.fromJson(Map<String, dynamic> json) => _$BankingDetailsRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BankingDetailsRequestToJson(this);
}
