// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Role _$RoleFromJson(Map<String, dynamic> json) => Role(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  code: json['code'] as String,
  description: json['description'] as String?,
  color: json['color'] as String? ?? 'gray',
  usersCount: (json['users_count'] as num?)?.toInt() ?? 0,
  roleRights: (json['role_rights'] as List<dynamic>?)
      ?.map((e) => RoleRight.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RoleToJson(Role instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'code': instance.code,
  'description': instance.description,
  'color': instance.color,
  'users_count': instance.usersCount,
  'role_rights': instance.roleRights,
};
