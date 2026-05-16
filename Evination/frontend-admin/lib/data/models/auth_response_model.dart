import 'package:json_annotation/json_annotation.dart';
import 'menu_model.dart';
import 'role_right_model.dart';
import 'user_model.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'token_type')
  final String tokenType;
  final User user;
  final List<Menu> menus;
  final List<RoleRight> rights;
  final List<String> permissions;

  AuthResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
    required this.menus,
    required this.rights,
    required this.permissions,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
