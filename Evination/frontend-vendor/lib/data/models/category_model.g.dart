// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  code: json['code'] as String,
  description: json['description'] as String?,
  icon: json['icon'] as String?,
  color: json['color'] as String?,
  eventsCount: (json['eventsCount'] as num?)?.toInt(),
  eventTypesCount: (json['eventTypesCount'] as num?)?.toInt(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'code': instance.code,
  'description': instance.description,
  'icon': instance.icon,
  'color': instance.color,
  'eventsCount': instance.eventsCount,
  'eventTypesCount': instance.eventTypesCount,
  'created_at': instance.createdAt?.toIso8601String(),
};
