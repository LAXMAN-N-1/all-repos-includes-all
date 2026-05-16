// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
  id: (json['id'] as num).toInt(),
  organizationId: (json['organization_id'] as num).toInt(),
  name: json['name'] as String,
  categoryId: (json['category_id'] as num).toInt(),
  eventTypeId: (json['event_type_id'] as num).toInt(),
  eventDate: DateTime.parse(json['event_date'] as String),
  startTime: json['start_time'] == null
      ? null
      : DateTime.parse(json['start_time'] as String),
  endTime: json['end_time'] == null
      ? null
      : DateTime.parse(json['end_time'] as String),
  location: json['location'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  venue: json['venue'] as String?,
  expectedAttendees: (json['expected_attendees'] as num?)?.toInt() ?? 0,
  actualAttendees: (json['actual_attendees'] as num?)?.toInt(),
  budget: (json['budget'] as num?)?.toDouble(),
  description: json['description'] as String?,
  specialRequirements: json['special_requirements'] as String?,
  status: json['status'] as String,
  eventManagerId: (json['event_manager_id'] as num?)?.toInt(),
  eventManager: json['event_manager'] == null
      ? null
      : User.fromJson(json['event_manager'] as Map<String, dynamic>),
);

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'name': instance.name,
  'category_id': instance.categoryId,
  'event_type_id': instance.eventTypeId,
  'event_date': instance.eventDate.toIso8601String(),
  'start_time': instance.startTime?.toIso8601String(),
  'end_time': instance.endTime?.toIso8601String(),
  'location': instance.location,
  'city': instance.city,
  'state': instance.state,
  'venue': instance.venue,
  'expected_attendees': instance.expectedAttendees,
  'actual_attendees': instance.actualAttendees,
  'budget': instance.budget,
  'description': instance.description,
  'special_requirements': instance.specialRequirements,
  'status': instance.status,
  'event_manager_id': instance.eventManagerId,
  'event_manager': instance.eventManager,
};
