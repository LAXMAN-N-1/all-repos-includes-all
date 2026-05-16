import 'package:json_annotation/json_annotation.dart';

part 'menu_model.g.dart';

@JsonSerializable()
class Menu {
  final int id;
  final String name;
  final String? route;
  final String code;
  final String? icon;
  @JsonKey(name: 'parent_id')
  final int? parentId;

  Menu({
    required this.id,
    required this.name,
    this.route,
    required this.code,
    this.icon,
    this.parentId,
  });

  factory Menu.fromJson(Map<String, dynamic> json) => _$MenuFromJson(json);

  Map<String, dynamic> toJson() => _$MenuToJson(this);
}
