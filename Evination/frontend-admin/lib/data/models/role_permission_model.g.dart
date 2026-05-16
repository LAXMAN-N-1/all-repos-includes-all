// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_permission_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RolePermission _$RolePermissionFromJson(Map<String, dynamic> json) =>
    RolePermission(
      id: (json['id'] as num).toInt(),
      roleId: (json['role_id'] as num).toInt(),
      permissionId: (json['permission_id'] as num).toInt(),
      permission: json['permission'] == null
          ? null
          : Permission.fromJson(json['permission'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RolePermissionToJson(RolePermission instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role_id': instance.roleId,
      'permission_id': instance.permissionId,
      'permission': instance.permission,
    };
