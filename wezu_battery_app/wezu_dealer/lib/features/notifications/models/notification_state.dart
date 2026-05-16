import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_state.freezed.dart';
part 'notification_state.g.dart';

@freezed
abstract class NotificationDto with _$NotificationDto {
  const factory NotificationDto({
    required int id,
    required String title,
    required String message,
    required String type,
    @JsonKey(name: 'is_read') required bool isRead,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _NotificationDto;

  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDtoFromJson(json);
}

@freezed
abstract class NotificationState with _$NotificationState {
  const factory NotificationState({
    @Default(true) bool isLoading,
    String? error,
    @Default([]) List<NotificationDto> notifications,
    @Default(0) int unreadCount,
    @Default(0) int total,
  }) = _NotificationState;
}
