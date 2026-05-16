// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Vendor _$VendorFromJson(Map<String, dynamic> json) => _Vendor(
  id: (json['id'] as num).toInt(),
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  companyName: json['company_name'] as String?,
  status: json['status'] as String? ?? 'Pending',
);

Map<String, dynamic> _$VendorToJson(_Vendor instance) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'email': instance.email,
  'phone': instance.phone,
  'company_name': instance.companyName,
  'status': instance.status,
};

_CreateVendorRequest _$CreateVendorRequestFromJson(Map<String, dynamic> json) =>
    _CreateVendorRequest(
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      companyName: json['company_name'] as String?,
      status: json['status'] as String? ?? 'Pending',
    );

Map<String, dynamic> _$CreateVendorRequestToJson(
  _CreateVendorRequest instance,
) => <String, dynamic>{
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'email': instance.email,
  'phone': instance.phone,
  'company_name': instance.companyName,
  'status': instance.status,
};
