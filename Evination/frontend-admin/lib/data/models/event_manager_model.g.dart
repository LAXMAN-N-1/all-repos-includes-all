// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_manager_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventManager _$EventManagerFromJson(Map<String, dynamic> json) => EventManager(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
  avatar: json['avatar'] as String?,
  activeEvents: (json['activeEvents'] as num).toInt(),
  completedEvents: (json['completedEvents'] as num).toInt(),
  rating: (json['rating'] as num).toDouble(),
  specialties: (json['specialties'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  status: json['status'] as String,
  totalBudgetManaged: (json['totalBudgetManaged'] as num?)?.toDouble(),
  avgAttendees: (json['avgAttendees'] as num?)?.toInt(),
);

Map<String, dynamic> _$EventManagerToJson(EventManager instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'email': instance.email,
      'avatar': instance.avatar,
      'activeEvents': instance.activeEvents,
      'completedEvents': instance.completedEvents,
      'rating': instance.rating,
      'specialties': instance.specialties,
      'status': instance.status,
      'totalBudgetManaged': instance.totalBudgetManaged,
      'avgAttendees': instance.avgAttendees,
    };
