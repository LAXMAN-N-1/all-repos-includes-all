// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bid_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bid _$BidFromJson(Map<String, dynamic> json) => Bid(
  id: (json['id'] as num).toInt(),
  vendorName: json['vendor_name'] as String?,
  vendorRating: (json['vendor_rating'] as num?)?.toDouble(),
  amount: (json['amount'] as num).toDouble(),
  status: json['status'] as String,
  eventId: (json['event_id'] as num?)?.toInt(),
  eventName: json['event_name'] as String?,
  eventDate: json['event_date'] == null
      ? null
      : DateTime.parse(json['event_date'] as String),
  proposal: json['proposal'] as String?,
  includes: json['includes'] as List<dynamic>?,
  requirements: json['requirements'] as List<dynamic>?,
  advantages: json['advantages'] as List<dynamic>?,
  timelineDays: (json['timeline_days'] as num?)?.toInt(),
  proposedDate: json['proposed_date'] == null
      ? null
      : DateTime.parse(json['proposed_date'] as String),
  vendorCategory: json['vendor_category'] as String?,
  isRecommended: json['is_recommended'] as bool?,
  submittedAt: json['submitted_at'] == null
      ? null
      : DateTime.parse(json['submitted_at'] as String),
  vendorExperience: json['vendor_experience'] as String?,
  completedEvents: (json['completed_events'] as num?)?.toInt(),
  vendorPhone: json['vendor_phone'] as String?,
  vendorEmail: json['vendor_email'] as String?,
  vendorLocation: json['vendor_location'] as String?,
  vendorTeamSize: json['vendor_team_size'] as String?,
  vendorNotes: json['vendor_notes'] as String?,
  vendorDocuments: (json['vendor_documents'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  vendorCertifications: (json['vendor_certifications'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  vendorSpecializations: (json['vendor_specializations'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  eventVenue: json['event_venue'] as String?,
  eventLocation: json['event_location'] as String?,
  eventGuests: (json['event_guests'] as num?)?.toInt(),
  discount: (json['discount'] as num?)?.toDouble(),
  validUntil: json['valid_until'] == null
      ? null
      : DateTime.parse(json['valid_until'] as String),
  lineItems: json['line_items'] as List<dynamic>?,
  tax: (json['tax'] as num?)?.toDouble(),
  terms: (json['terms'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$BidToJson(Bid instance) => <String, dynamic>{
  'id': instance.id,
  'vendor_name': instance.vendorName,
  'vendor_rating': instance.vendorRating,
  'amount': instance.amount,
  'status': instance.status,
  'event_name': instance.eventName,
  'event_date': instance.eventDate?.toIso8601String(),
  'proposal': instance.proposal,
  'includes': instance.includes,
  'requirements': instance.requirements,
  'advantages': instance.advantages,
  'timeline_days': instance.timelineDays,
  'proposed_date': instance.proposedDate?.toIso8601String(),
  'is_recommended': instance.isRecommended,
  'submitted_at': instance.submittedAt?.toIso8601String(),
  'vendor_experience': instance.vendorExperience,
  'completed_events': instance.completedEvents,
  'vendor_category': instance.vendorCategory,
  'vendor_phone': instance.vendorPhone,
  'vendor_email': instance.vendorEmail,
  'vendor_location': instance.vendorLocation,
  'vendor_team_size': instance.vendorTeamSize,
  'vendor_notes': instance.vendorNotes,
  'vendor_documents': instance.vendorDocuments,
  'vendor_certifications': instance.vendorCertifications,
  'vendor_specializations': instance.vendorSpecializations,
  'event_id': instance.eventId,
  'event_venue': instance.eventVenue,
  'event_location': instance.eventLocation,
  'event_guests': instance.eventGuests,
  'discount': instance.discount,
  'valid_until': instance.validUntil?.toIso8601String(),
  'line_items': instance.lineItems,
  'tax': instance.tax,
  'terms': instance.terms,
};
