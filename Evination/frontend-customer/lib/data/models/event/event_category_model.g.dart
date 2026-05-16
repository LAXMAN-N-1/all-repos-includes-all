// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventCategoryModelImpl _$$EventCategoryModelImplFromJson(
        Map<String, dynamic> json) =>
    _$EventCategoryModelImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      iconName: json['iconName'] as String?,
    );

Map<String, dynamic> _$$EventCategoryModelImplToJson(
        _$EventCategoryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'iconName': instance.iconName,
    };
