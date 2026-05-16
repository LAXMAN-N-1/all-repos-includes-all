// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) =>
    _LoginRequest(
      username: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(_LoginRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  email: json['email'] as String,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  roleCode: json['role_code'] as String,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'role_code': instance.roleCode,
};

_Menu _$MenuFromJson(Map<String, dynamic> json) => _Menu(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  route: json['route'] as String?,
  code: json['code'] as String?,
  icon: json['icon'] as String?,
);

Map<String, dynamic> _$MenuToJson(_Menu instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'route': instance.route,
  'code': instance.code,
  'icon': instance.icon,
};

_RoleRight _$RoleRightFromJson(Map<String, dynamic> json) => _RoleRight(
  menuId: (json['menu_id'] as num).toInt(),
  canView: json['can_view'] as bool,
  canCreate: json['can_create'] as bool,
  canEdit: json['can_edit'] as bool,
  canDelete: json['can_delete'] as bool,
);

Map<String, dynamic> _$RoleRightToJson(_RoleRight instance) =>
    <String, dynamic>{
      'menu_id': instance.menuId,
      'can_view': instance.canView,
      'can_create': instance.canCreate,
      'can_edit': instance.canEdit,
      'can_delete': instance.canDelete,
    };

_LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    _LoginResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      menus: (json['menus'] as List<dynamic>)
          .map((e) => Menu.fromJson(e as Map<String, dynamic>))
          .toList(),
      rights: (json['rights'] as List<dynamic>)
          .map((e) => RoleRight.fromJson(e as Map<String, dynamic>))
          .toList(),
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$LoginResponseToJson(_LoginResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'user': instance.user,
      'menus': instance.menus,
      'rights': instance.rights,
      'permissions': instance.permissions,
    };
