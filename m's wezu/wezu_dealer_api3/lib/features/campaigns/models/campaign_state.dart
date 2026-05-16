import 'package:freezed_annotation/freezed_annotation.dart';

part 'campaign_state.freezed.dart';
part 'campaign_state.g.dart';

@freezed
abstract class CampaignDto with _$CampaignDto {
  const factory CampaignDto({
    required int id,
    required String title,
    required String desc,
    required String status,
    required String dates,
    required String redemptions,
    required String revenue,
  }) = _CampaignDto;

  factory CampaignDto.fromJson(Map<String, dynamic> json) =>
      _$CampaignDtoFromJson(json);
}

@freezed
abstract class CampaignState with _$CampaignState {
  const factory CampaignState({
    @Default(true) bool isLoading,
    String? error,
    @Default([]) List<CampaignDto> campaigns,
  }) = _CampaignState;
}
