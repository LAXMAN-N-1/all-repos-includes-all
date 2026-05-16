import 'package:json_annotation/json_annotation.dart';

part 'permission_model.g.dart';

@JsonSerializable()
class Permission {
  final int id;
  final String code;
  final String name;
  final String? description;
  final String module;
  final String action;

  Permission({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.module,
    required this.action,
  });

  factory Permission.fromJson(Map<String, dynamic> json) =>
      _$PermissionFromJson(json);

  Map<String, dynamic> toJson() => _$PermissionToJson(this);
}
