// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  email: json['email'] as String,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  phone: json['phone'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  roleId: (json['role_id'] as num).toInt(),
  role: json['role'] == null
      ? null
      : Role.fromJson(json['role'] as Map<String, dynamic>),
  branchId: (json['branch_id'] as num?)?.toInt(),
  branch: json['branch'] == null
      ? null
      : Branch.fromJson(json['branch'] as Map<String, dynamic>),
  lastLoginAt: json['last_login_at'] == null
      ? null
      : DateTime.parse(json['last_login_at'] as String),
  isActive: json['inactive'] as bool? ?? false,
  organizationId: (json['organization_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'phone': instance.phone,
  'avatar_url': instance.avatarUrl,
  'role_id': instance.roleId,
  'role': instance.role,
  'last_login_at': instance.lastLoginAt?.toIso8601String(),
  'inactive': instance.isActive,
  'organization_id': instance.organizationId,
  'branch_id': instance.branchId,
  'branch': instance.branch,
};
