// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Event _$EventFromJson(Map<String, dynamic> json) => _Event(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String?,
  date: DateTime.parse(json['date'] as String),
  location: json['location'] as String,
  status: json['status'] as String?,
  organizationId: (json['organization_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$EventToJson(_Event instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'date': instance.date.toIso8601String(),
  'location': instance.location,
  'status': instance.status,
  'organization_id': instance.organizationId,
};

_CreateEventRequest _$CreateEventRequestFromJson(Map<String, dynamic> json) =>
    _CreateEventRequest(
      title: json['title'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as String,
      status: json['status'] as String? ?? 'Draft',
    );

Map<String, dynamic> _$CreateEventRequestToJson(_CreateEventRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'date': instance.date.toIso8601String(),
      'location': instance.location,
      'status': instance.status,
    };
