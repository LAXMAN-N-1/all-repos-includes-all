import 'package:freezed_annotation/freezed_annotation.dart';

part 'kyc_status_state.freezed.dart';
part 'kyc_status_state.g.dart';

@freezed
abstract class KycStatusDto with _$KycStatusDto {
  const factory KycStatusDto({
    required int id,
    @JsonKey(name: 'user_id') required int userId,
    @JsonKey(name: 'application_state') required String status,
    @JsonKey(name: 'rejection_reason') String? rejectionReason,
    String? adminComments,
    @JsonKey(name: 'submitted_at') String? submittedAt,
    @JsonKey(name: 'reviewed_at') String? reviewedAt,
    @JsonKey(name: 'risk_score') double? riskScore,
    @Default([]) List<Map<String, dynamic>> history,
  }) = _KycStatusDto;

  factory KycStatusDto.fromJson(Map<String, dynamic> json) =>
      _$KycStatusDtoFromJson(json);
}

@freezed
abstract class KycStatusState with _$KycStatusState {
  const factory KycStatusState({
    @Default(true) bool isLoading,
    String? error,
    KycStatusDto? status,
  }) = _KycStatusState;
}
