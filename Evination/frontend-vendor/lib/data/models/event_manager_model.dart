import 'package:json_annotation/json_annotation.dart';

part 'event_manager_model.g.dart';

@JsonSerializable()
class EventManager {
  final int id;
  @JsonKey(name: 'userId')
  final int userId;
  final String name;
  final String email;
  final String? avatar;
  @JsonKey(name: 'activeEvents')
  final int activeEvents;
  @JsonKey(name: 'completedEvents')
  final int completedEvents;
  final double rating;
  final List<String> specialties;
  final String status; // Available, Busy, etc.
  @JsonKey(name: 'totalBudgetManaged')
  final double? totalBudgetManaged;
  @JsonKey(name: 'avgAttendees')
  final int? avgAttendees;

  EventManager({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.avatar,
    required this.activeEvents,
    required this.completedEvents,
    required this.rating,
    required this.specialties,
    required this.status,
    this.totalBudgetManaged,
    this.avgAttendees,
  });

  factory EventManager.fromJson(Map<String, dynamic> json) => _$EventManagerFromJson(json);
  Map<String, dynamic> toJson() => _$EventManagerToJson(this);
}
