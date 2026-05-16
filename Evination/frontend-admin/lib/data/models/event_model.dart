import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'event_model.g.dart';

@JsonSerializable()
class Event {
  final int id;
  @JsonKey(name: 'organization_id')
  final int organizationId;
  final String name;
  @JsonKey(name: 'category_id')
  final int categoryId;
  @JsonKey(name: 'event_type_id')
  final int eventTypeId;
  @JsonKey(name: 'event_date')
  final DateTime eventDate;
  @JsonKey(name: 'start_time')
  final DateTime? startTime;
  @JsonKey(name: 'end_time')
  final DateTime? endTime;
  final String? location;
  final String? city;
  final String? state;
  final String? venue;
  @JsonKey(name: 'expected_attendees')
  final int expectedAttendees;
  @JsonKey(name: 'actual_attendees')
  final int? actualAttendees;
  final double? budget;
  final String? description;
  @JsonKey(name: 'special_requirements')
  final String? specialRequirements;
  final String status; // Using String for Enum
  @JsonKey(name: 'event_manager_id')
  final int? eventManagerId;
  @JsonKey(name: 'event_manager')
  final User? eventManager;

  Event({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.categoryId,
    required this.eventTypeId,
    required this.eventDate,
    this.startTime,
    this.endTime,
    this.location,
    this.city,
    this.state,
    this.venue,
    this.expectedAttendees = 0,
    this.actualAttendees,
    this.budget,
    this.description,
    this.specialRequirements,
    required this.status, // Planning, Confirmed, Active, Completed, Cancelled
    this.eventManagerId,
    this.eventManager,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  Map<String, dynamic> toJson() => _$EventToJson(this);
}
