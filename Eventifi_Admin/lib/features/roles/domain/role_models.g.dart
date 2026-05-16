// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Role _$RoleFromJson(Map<String, dynamic> json) => _Role(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  code: json['code'] as String,
  description: json['description'] as String?,
  rights:
      (json['rights'] as List<dynamic>?)
          ?.map((e) => RoleRight.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$RoleToJson(_Role instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'code': instance.code,
  'description': instance.description,
  'rights': instance.rights,
};

_CreateRoleRequest _$CreateRoleRequestFromJson(Map<String, dynamic> json) =>
    _CreateRoleRequest(
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      rights:
          (json['rights'] as List<dynamic>?)
              ?.map((e) => RoleRight.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CreateRoleRequestToJson(_CreateRoleRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'code': instance.code,
      'description': instance.description,
      'rights': instance.rights,
    };
