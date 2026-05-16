import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_models.freezed.dart';
part 'event_models.g.dart';

@freezed
class Event with _$Event {
  const factory Event({
    required int id,
    required String title,
    String? description,
    required DateTime date,
    required String location,
    String? status, // e.g., Draft, Published, Completed
    @JsonKey(name: 'organization_id') int? organizationId,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}

@freezed
class CreateEventRequest with _$CreateEventRequest {
  const factory CreateEventRequest({
    required String title,
    String? description,
    required DateTime date,
    required String location,
    @Default('Draft') String status,
  }) = _CreateEventRequest;

  factory CreateEventRequest.fromJson(Map<String, dynamic> json) => _$CreateEventRequestFromJson(json);
}
