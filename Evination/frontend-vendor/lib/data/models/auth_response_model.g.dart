// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
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

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'user': instance.user,
      'menus': instance.menus,
      'rights': instance.rights,
      'permissions': instance.permissions,
    };
