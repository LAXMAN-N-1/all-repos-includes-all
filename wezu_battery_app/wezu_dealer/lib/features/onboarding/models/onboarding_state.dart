import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';
part 'onboarding_state.g.dart';

@freezed
abstract class OnboardingStatusDto with _$OnboardingStatusDto {
  const factory OnboardingStatusDto({
    @JsonKey(name: 'current_stage') required String currentStage,
    @JsonKey(name: 'risk_score') double? riskScore,
    @Default([]) List<Map<String, dynamic>> history,
  }) = _OnboardingStatusDto;

  factory OnboardingStatusDto.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStatusDtoFromJson(json);
}

@freezed
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(true) bool isLoading,
    String? error,
    OnboardingStatusDto? status,
  }) = _OnboardingState;
}

enum OnboardingStage {
  submitted('SUBMITTED', 'Digital Application', 'Your application is being processed.'),
  automatedChecks('AUTOMATED_CHECKS_PASSED', 'Automated Verification', 'Background checks and data validation.'),
  kycSubmitted('KYC_SUBMITTED', 'KYC Capture', 'Identity and business documentation.'),
  manualReview('MANUAL_REVIEW_PASSED', 'Manual Review', 'Wait for our team to review your documents.'),
  visitScheduled('FIELD_VISIT_SCHEDULED', 'Field Visit Scheduled', 'Our officer will visit your location.'),
  visitCompleted('FIELD_VISIT_COMPLETED', 'Field Verification', 'Final space and infrastructure check.'),
  approved('APPROVED', 'Final Approval', 'Congratulations! Your application is approved.'),
  training('TRAINING_COMPLETED', 'Setup & Training', 'Complete your technical and operational training.'),
  active('ACTIVE', 'Go Live', 'Inventory handed over. Start operations!');

  final String code;
  final String title;
  final String description;
  const OnboardingStage(this.code, this.title, this.description);

  static OnboardingStage fromCode(String code) {
    return OnboardingStage.values.firstWhere(
      (e) => e.code == code,
      orElse: () => OnboardingStage.submitted,
    );
  }
}
