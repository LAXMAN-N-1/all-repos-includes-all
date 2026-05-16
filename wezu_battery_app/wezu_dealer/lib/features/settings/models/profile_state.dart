import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.freezed.dart';
part 'profile_state.g.dart';

@freezed
abstract class ProfileDto with _$ProfileDto {
  const factory ProfileDto({
    @JsonKey(name: 'business_name') String? businessName,
    @JsonKey(name: 'gst_number') String? gstNumber,
    @JsonKey(name: 'pan_number') String? panNumber,
    
    @JsonKey(name: 'year_established') String? yearEstablished,
    @JsonKey(name: 'website_url') String? websiteUrl,
    @JsonKey(name: 'business_description') String? businessDescription,
    
    @JsonKey(name: 'contact_person') String? contactPerson,
    @JsonKey(name: 'contact_email') String? contactEmail,
    @JsonKey(name: 'contact_phone') String? contactPhone,
    @JsonKey(name: 'alternate_phone') String? alternatePhone,
    @JsonKey(name: 'whatsapp_number') String? whatsappNumber,
    @JsonKey(name: 'support_email') String? supportEmail,
    @JsonKey(name: 'support_phone') String? supportPhone,
    
    String? email, // Primary account email from User table
    @JsonKey(name: 'address_line1') String? addressLine1,
    String? city,
    String? state,
    String? pincode,
    @JsonKey(name: 'bank_details') Map<String, dynamic>? bankDetails,
    @JsonKey(name: 'profile_picture') String? profilePicture,
  }) = _ProfileDto;

  factory ProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileDtoFromJson(json);
}

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(true) bool isLoading,
    @Default(false) bool isUpdating,
    String? error,
    ProfileDto? profile,
  }) = _ProfileState;
}
