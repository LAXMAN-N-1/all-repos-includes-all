// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Branch _$BranchFromJson(Map<String, dynamic> json) => Branch(
  id: (json['id'] as num).toInt(),
  organizationId: (json['organization_id'] as num).toInt(),
  name: json['name'] as String,
  code: json['code'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  address: json['address'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  country: json['country'] as String?,
  pincode: json['pincode'] as String?,
  isHeadOffice: (json['is_head_office'] as num?)?.toInt() ?? 0,
  managerId: (json['manager_id'] as num?)?.toInt(),
  manager: json['manager'] == null
      ? null
      : User.fromJson(json['manager'] as Map<String, dynamic>),
  inactive: json['inactive'] as bool? ?? false,
  employeesCount: (json['employees_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$BranchToJson(Branch instance) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'name': instance.name,
  'code': instance.code,
  'email': instance.email,
  'phone': instance.phone,
  'address': instance.address,
  'city': instance.city,
  'state': instance.state,
  'country': instance.country,
  'pincode': instance.pincode,
  'is_head_office': instance.isHeadOffice,
  'manager_id': instance.managerId,
  'manager': instance.manager,
  'inactive': instance.inactive,
  'employees_count': instance.employeesCount,
};
