// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookingModelImpl _$$BookingModelImplFromJson(Map<String, dynamic> json) =>
    _$BookingModelImpl(
      id: (json['id'] as num).toInt(),
      referenceId: json['referenceId'] as String,
      customerId: (json['customerId'] as num).toInt(),
      eventName: json['eventName'] as String,
      eventType: json['eventType'] as String,
      eventDate: json['eventDate'] as String,
      eventTime: json['eventTime'] as String?,
      location: json['location'] as String,
      city: json['city'] as String?,
      guestCount: json['guestCount'] as String?,
      budget: (json['budget'] as num).toDouble(),
      requirements: json['requirements'] as String?,
      status: json['status'] as String,
      transactionId: json['transactionId'] as String?,
      bookingStep: json['bookingStep'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      subCategory: json['subCategory'] as String?,
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      paymentStatus: json['paymentStatus'] as String? ?? 'pending',
      escrowStatus: json['escrowStatus'] as String? ?? 'none',
    );

Map<String, dynamic> _$$BookingModelImplToJson(_$BookingModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'referenceId': instance.referenceId,
      'customerId': instance.customerId,
      'eventName': instance.eventName,
      'eventType': instance.eventType,
      'eventDate': instance.eventDate,
      'eventTime': instance.eventTime,
      'location': instance.location,
      'city': instance.city,
      'guestCount': instance.guestCount,
      'budget': instance.budget,
      'requirements': instance.requirements,
      'status': instance.status,
      'transactionId': instance.transactionId,
      'bookingStep': instance.bookingStep,
      'createdAt': instance.createdAt.toIso8601String(),
      'subCategory': instance.subCategory,
      'images': instance.images,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'paymentStatus': instance.paymentStatus,
      'escrowStatus': instance.escrowStatus,
    };
