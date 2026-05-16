import 'package:json_annotation/json_annotation.dart';

part 'bid_model.g.dart';

@JsonSerializable()
class Bid {
  final int id;
  @JsonKey(name: 'vendor_name')
  final String? vendorName;
  @JsonKey(name: 'vendor_rating')
  final double? vendorRating;
  final double amount;
  final String status;
  @JsonKey(name: 'event_name')
  final String? eventName;
  @JsonKey(name: 'event_date')
  final DateTime? eventDate;
  
  // Details
  final String? proposal;
  final List<dynamic>? includes;
  final List<dynamic>? requirements;
  final List<dynamic>? advantages;
  @JsonKey(name: 'timeline_days')
  final int? timelineDays;
  @JsonKey(name: 'proposed_date')
  final DateTime? proposedDate;
  @JsonKey(name: 'is_recommended')
  final bool? isRecommended;
  @JsonKey(name: 'submitted_at')
  final DateTime? submittedAt;
  
  // New Detailed Fields
  @JsonKey(name: 'vendor_experience')
  final String? vendorExperience;
  @JsonKey(name: 'completed_events')
  final int? completedEvents;
  @JsonKey(name: 'vendor_category')
  final String? vendorCategory;
  @JsonKey(name: 'vendor_phone')
  final String? vendorPhone;
  @JsonKey(name: 'vendor_email')
  final String? vendorEmail;
  @JsonKey(name: 'vendor_location')
  final String? vendorLocation;
  @JsonKey(name: 'vendor_team_size')
  final String? vendorTeamSize;
  @JsonKey(name: 'vendor_notes')
  final String? vendorNotes;
  @JsonKey(name: 'vendor_documents')
  final List<String>? vendorDocuments;
  @JsonKey(name: 'vendor_certifications')
  final List<String>? vendorCertifications;
  @JsonKey(name: 'vendor_specializations')
  final List<String>? vendorSpecializations;
  @JsonKey(name: 'event_id')
  final int? eventId;
  
  @JsonKey(name: 'event_venue')
  final String? eventVenue;
  @JsonKey(name: 'event_location')
  final String? eventLocation;
  @JsonKey(name: 'event_guests')
  final int? eventGuests;

  Bid({
    required this.id,
    this.vendorName,
    this.vendorRating,
    required this.amount,
    required this.status,
    this.eventId,
    this.eventName,
    this.eventDate,
    this.proposal,
    this.includes,
    this.requirements,
    this.advantages,
    this.timelineDays,
    this.proposedDate,
    this.vendorCategory,
    this.isRecommended,
    this.submittedAt,
    this.vendorExperience,
    this.completedEvents,
    this.vendorPhone,
    this.vendorEmail,
    this.vendorLocation,
    this.vendorTeamSize,
    this.vendorNotes,
    this.vendorDocuments,
    this.vendorCertifications,
    this.vendorSpecializations,
    this.eventVenue,
    this.eventLocation,
    this.eventGuests,
    this.discount,
    this.validUntil,
    this.lineItems,
    this.tax,
    this.terms,
  });

  // Comparison Fields
  final double? discount;
  @JsonKey(name: 'valid_until')
  final DateTime? validUntil;
  
  // Quote Details
  @JsonKey(name: 'line_items')
  final List<dynamic>? lineItems;
  final double? tax;
  final List<String>? terms;
  
  String? get vendorContact => vendorPhone;
  String? get vendorMobile => vendorPhone; // Alias just in case

  factory Bid.fromJson(Map<String, dynamic> json) => _$BidFromJson(json);

  Map<String, dynamic> toJson() => _$BidToJson(this);
}
