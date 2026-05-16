import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@JsonSerializable()
class Category {
  final int id;
  final String name;
  final String code;
  final String? description;
  final String? icon;
  final String? color;
  @JsonKey(name: 'eventsCount')
  final int? eventsCount;
  @JsonKey(name: 'eventTypesCount')
  final int? eventTypesCount;
  @JsonKey(name: 'vendorsCount')
  final int? vendorsCount;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  Category({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.icon,
    this.color,
    this.eventsCount,
    this.eventTypesCount,
    this.vendorsCount,
    this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
