// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventType _$EventTypeFromJson(Map<String, dynamic> json) => EventType(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  code: json['code'] as String,
  color: json['color'] as String?,
  category: json['category'] as String?,
  count: (json['count'] as num?)?.toInt() ?? 0,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$EventTypeToJson(EventType instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'code': instance.code,
  'color': instance.color,
  'category': instance.category,
  'count': instance.count,
  'created_at': instance.createdAt?.toIso8601String(),
};
