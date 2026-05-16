import 'package:json_annotation/json_annotation.dart';
import 'role_right_model.dart';

part 'role_model.g.dart';

@JsonSerializable()
class Role {
  final int id;
  final String name;
  final String code;
  final String? description;
  @JsonKey(defaultValue: 'gray')
  final String color;
  @JsonKey(name: 'users_count', defaultValue: 0)
  final int usersCount;
  
  @JsonKey(name: 'role_rights')
  final List<RoleRight>? roleRights;

  Role({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.color = 'gray',
    this.usersCount = 0,
    this.roleRights,
  });

  bool hasPermission(String permissionCode) {
    if (code == 'SUPERADMIN') return true;
    // return roleRights?.any((rp) => rp.permission?.code == permissionCode) ?? false;
    // TODO: Implement permission check based on RoleRight (Menu + Action) or fetch Permission list
    return false;
  }

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);

  Map<String, dynamic> toJson() => _$RoleToJson(this);
}
