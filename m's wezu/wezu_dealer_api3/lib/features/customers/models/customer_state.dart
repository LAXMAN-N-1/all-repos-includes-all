import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_state.freezed.dart';
part 'customer_state.g.dart';

@freezed
abstract class CustomerDto with _$CustomerDto {
  const factory CustomerDto({
    required int id,
    required String name,
    required String email,
    required String phone,
    required int totalRentals,
    required String status,
    String? joinedAt,
  }) = _CustomerDto;

  factory CustomerDto.fromJson(Map<String, dynamic> json) =>
      _$CustomerDtoFromJson(json);
}

@freezed
abstract class CustomerState with _$CustomerState {
  const factory CustomerState({
    @Default(true) bool isLoading,
    String? error,
    @Default([]) List<CustomerDto> customers,
  }) = _CustomerState;
}
