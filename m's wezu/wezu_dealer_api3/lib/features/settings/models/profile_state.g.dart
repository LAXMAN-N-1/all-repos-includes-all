// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfileDto _$ProfileDtoFromJson(Map<String, dynamic> json) => _ProfileDto(
      businessName: json['business_name'] as String?,
      gstNumber: json['gst_number'] as String?,
      panNumber: json['pan_number'] as String?,
      yearEstablished: json['year_established'] as String?,
      websiteUrl: json['website_url'] as String?,
      businessDescription: json['business_description'] as String?,
      contactPerson: json['contact_person'] as String?,
      contactEmail: json['contact_email'] as String?,
      contactPhone: json['contact_phone'] as String?,
      alternatePhone: json['alternate_phone'] as String?,
      whatsappNumber: json['whatsapp_number'] as String?,
      supportEmail: json['support_email'] as String?,
      supportPhone: json['support_phone'] as String?,
      email: json['email'] as String?,
      addressLine1: json['address_line1'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      bankDetails: json['bank_details'] as Map<String, dynamic>?,
      profilePicture: json['profile_picture'] as String?,
    );

Map<String, dynamic> _$ProfileDtoToJson(_ProfileDto instance) =>
    <String, dynamic>{
      'business_name': instance.businessName,
      'gst_number': instance.gstNumber,
      'pan_number': instance.panNumber,
      'year_established': instance.yearEstablished,
      'website_url': instance.websiteUrl,
      'business_description': instance.businessDescription,
      'contact_person': instance.contactPerson,
      'contact_email': instance.contactEmail,
      'contact_phone': instance.contactPhone,
      'alternate_phone': instance.alternatePhone,
      'whatsapp_number': instance.whatsappNumber,
      'support_email': instance.supportEmail,
      'support_phone': instance.supportPhone,
      'email': instance.email,
      'address_line1': instance.addressLine1,
      'city': instance.city,
      'state': instance.state,
      'pincode': instance.pincode,
      'bank_details': instance.bankDetails,
      'profile_picture': instance.profilePicture,
    };
