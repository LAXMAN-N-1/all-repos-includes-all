import 'package:json_annotation/json_annotation.dart';
import 'permission_model.dart';

part 'role_permission_model.g.dart';

@JsonSerializable()
class RolePermission {
  final int id;
  @JsonKey(name: 'role_id')
  final int roleId;
  @JsonKey(name: 'permission_id')
  final int permissionId;
  final Permission? permission;

  RolePermission({
    required this.id,
    required this.roleId,
    required this.permissionId,
    this.permission,
  });

  factory RolePermission.fromJson(Map<String, dynamic> json) =>
      _$RolePermissionFromJson(json);

  Map<String, dynamic> toJson() => _$RolePermissionToJson(this);
}
