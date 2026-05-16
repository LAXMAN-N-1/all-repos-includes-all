import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket_state.freezed.dart';
part 'ticket_state.g.dart';

@freezed
abstract class TicketMessage with _$TicketMessage {
  const factory TicketMessage({
    required int id,
    required String senderName,
    required String senderAvatar,
    required String text,
    required DateTime timestamp,
    required String type, // 'customer', 'agent', 'note'
  }) = _TicketMessage;

  factory TicketMessage.fromJson(Map<String, dynamic> json) =>
      _$TicketMessageFromJson(json);
}

@freezed
abstract class StatusChangeEvent with _$StatusChangeEvent {
  const factory StatusChangeEvent({
    required DateTime timestamp,
    required String description,
    required String dotColor,
  }) = _StatusChangeEvent;

  factory StatusChangeEvent.fromJson(Map<String, dynamic> json) =>
      _$StatusChangeEventFromJson(json);
}

@freezed
abstract class TicketDto with _$TicketDto {
  const factory TicketDto({
    required int id,
    required String subject,
    required String description,
    required String customerName,
    required String customerPhone,
    required String customerAvatar,
    required String priority, // 'Low', 'Medium', 'High', 'Critical'
    required String status, // 'Open', 'In Progress', 'Resolved', 'Closed', 'Escalated'
    required String category,
    required String createdAt,
    String? updatedAt,
    String? assignedToName,
    String? assignedToAvatar,
    DateTime? slaDeadline,
    String? stationName,
    String? batteryId,
    String? transactionId,
    @Default([]) List<String> tags,
    @Default('Mobile App') String sourceChannel,
    @Default([]) List<TicketMessage> messages,
    @Default([]) List<StatusChangeEvent> statusHistory,
    @Default(false) bool isCritical,
    @Default(false) bool isResolved,
  }) = _TicketDto;

  factory TicketDto.fromJson(Map<String, dynamic> json) =>
      _$TicketDtoFromJson(json);
}

@freezed
abstract class TicketMetric with _$TicketMetric {
  const factory TicketMetric({
    required String label,
    required String value,
    String? trend,
    required String color, // 'amber', 'cyan', 'red', 'green'
  }) = _TicketMetric;

  factory TicketMetric.fromJson(Map<String, dynamic> json) =>
      _$TicketMetricFromJson(json);
}

@freezed
abstract class TicketState with _$TicketState {
  const factory TicketState({
    @Default(true) bool isLoading,
    String? error,
    @Default([]) List<TicketDto> tickets,
    @Default([]) List<TicketMetric> metrics,
    int? selectedTicketId,
    @Default(false) bool isFilterPanelOpen,
    @Default(false) bool isMetricsView,
  }) = _TicketState;
}
