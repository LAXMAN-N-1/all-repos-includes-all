import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String username,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
}

@freezed
class User with _$User {
  const factory User({
    required int id,
    required String username,
    required String email,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    @JsonKey(name: 'role_code') required String roleCode,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class Menu with _$Menu {
  const factory Menu({
    required int id,
    required String name,
    String? route,
    String? code,
    String? icon,
  }) = _Menu;

  factory Menu.fromJson(Map<String, dynamic> json) => _$MenuFromJson(json);
}

@freezed
class RoleRight with _$RoleRight {
  const factory RoleRight({
    @JsonKey(name: 'menu_id') required int menuId,
    @JsonKey(name: 'can_view') required bool canView,
    @JsonKey(name: 'can_create') required bool canCreate,
    @JsonKey(name: 'can_edit') required bool canEdit,
    @JsonKey(name: 'can_delete') required bool canDelete,
  }) = _RoleRight;

  factory RoleRight.fromJson(Map<String, dynamic> json) => _$RoleRightFromJson(json);
}

@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'token_type') required String tokenType,
    required User user,
    required List<Menu> menus,
    required List<RoleRight> rights,
    required List<String> permissions,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
}
