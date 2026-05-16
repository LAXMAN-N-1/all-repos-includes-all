import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:eventifi_admin/features/auth/domain/auth_models.dart';

part 'role_models.freezed.dart';
part 'role_models.g.dart';

@freezed
class Role with _$Role {
  const factory Role({
    required int id,
    required String name,
    required String code,
    String? description,
    @Default([]) List<RoleRight> rights,
  }) = _Role;

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
}

@freezed
class CreateRoleRequest with _$CreateRoleRequest {
  const factory CreateRoleRequest({
    required String name,
    required String code,
    String? description,
    @Default([]) List<RoleRight> rights,
  }) = _CreateRoleRequest;

  factory CreateRoleRequest.fromJson(Map<String, dynamic> json) => _$CreateRoleRequestFromJson(json);
}
