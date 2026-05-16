import 'package:json_annotation/json_annotation.dart';
import 'role_model.dart';
import 'branch_model.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String username;
  final String email;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  final String? phone;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @JsonKey(name: 'role_id')
  final int roleId;
  final Role? role;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.avatarUrl,
    required this.roleId,
    this.role,
    this.branchId,
    this.branch,
    this.lastLoginAt,
    this.isActive = true,
    this.organizationId,
  });

  @JsonKey(name: 'last_login_at')
  final DateTime? lastLoginAt;
  @JsonKey(name: 'inactive', defaultValue: false)
  final bool isActive;
  @JsonKey(name: 'organization_id')
  final int? organizationId;
  @JsonKey(name: 'branch_id')
  final int? branchId;
  final Branch? branch;

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
