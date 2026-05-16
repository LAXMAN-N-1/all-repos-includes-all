import 'package:json_annotation/json_annotation.dart';

part 'event_type_model.g.dart';

@JsonSerializable()
class EventType {
  final int id;
  final String name;
  final String code;
  final String? color;
  final String? category; // Category Name
  @JsonKey(name: 'count', defaultValue: 0)
  final int count; 
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  EventType({
    required this.id,
    required this.name,
    required this.code,
    this.color,
    this.category,
    this.count = 0,
    this.createdAt,
  });

  factory EventType.fromJson(Map<String, dynamic> json) => _$EventTypeFromJson(json);
  Map<String, dynamic> toJson() => _$EventTypeToJson(this);
}
