import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_state.freezed.dart';
part 'user_state.g.dart';

@freezed
abstract class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    required String name,
    required String email,
    required String role,
    required String status,
    @JsonKey(name: 'last_active') required String lastActive,
    String? avatar,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}

@freezed
abstract class UserState with _$UserState {
  const factory UserState({
    @Default(true) bool isLoading,
    String? error,
    @Default([]) List<UserDto> users,
  }) = _UserState;
}
