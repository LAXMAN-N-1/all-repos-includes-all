// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Menu _$MenuFromJson(Map<String, dynamic> json) => Menu(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  route: json['route'] as String?,
  code: json['code'] as String,
  icon: json['icon'] as String?,
  parentId: (json['parent_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$MenuToJson(Menu instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'route': instance.route,
  'code': instance.code,
  'icon': instance.icon,
  'parent_id': instance.parentId,
};
