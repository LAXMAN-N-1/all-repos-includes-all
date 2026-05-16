// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vendor _$VendorFromJson(Map<String, dynamic> json) => Vendor(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  companyName: json['company_name'] as String,
  businessType: json['business_type'] as String?,
  phone: json['phone'] as String?,
  address: json['address'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  zipCode: json['zip_code'] as String?,
  website: json['website'] as String?,
  yearEstablished: json['year_established'] as String?,
  teamSize: json['team_size'] as String?,
  description: json['description'] as String?,
  status: json['status'] as String? ?? 'pending',
);

Map<String, dynamic> _$VendorToJson(Vendor instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'company_name': instance.companyName,
  'business_type': instance.businessType,
  'phone': instance.phone,
  'address': instance.address,
  'city': instance.city,
  'state': instance.state,
  'zip_code': instance.zipCode,
  'website': instance.website,
  'year_established': instance.yearEstablished,
  'team_size': instance.teamSize,
  'description': instance.description,
  'status': instance.status,
};
