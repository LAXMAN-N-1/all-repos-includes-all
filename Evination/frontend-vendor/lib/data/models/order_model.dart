import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

@JsonSerializable()
class Order {
  final int id;
  @JsonKey(name: 'order_ref')
  final String orderRef;
  
  @JsonKey(name: 'vendor_name')
  final String? vendorName;
  @JsonKey(name: 'vendor_contact')
  final String? vendorContact;
  @JsonKey(name: 'vendor_email')
  final String? vendorEmail;
  @JsonKey(name: 'service_description')
  final String? serviceDescription;

  @JsonKey(name: 'event_name')
  final String? eventName;
  @JsonKey(name: 'event_date')
  final DateTime? eventDate;
  @JsonKey(name: 'event_location')
  final String? eventLocation;

  @JsonKey(name: 'customer_name')
  final String? customerName;
  @JsonKey(name: 'customer_email')
  final String? customerEmail;
  @JsonKey(name: 'customer_phone')
  final String? customerPhone;

  final double amount;
  final String status;
  
  @JsonKey(name: 'paid_amount')
  final double paidAmount;
  @JsonKey(name: 'payment_status')
  final String paymentStatus;

  final int? progress;
  @JsonKey(name: 'delivery_date')
  final DateTime? deliveryDate;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Order({
    required this.id,
    required this.orderRef,
    this.vendorName,
    this.vendorContact,
    this.vendorEmail,
    this.serviceDescription,
    this.eventName,
    this.eventDate,
    this.eventLocation,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    required this.amount,
    required this.status,
    required this.paidAmount,
    required this.paymentStatus,
    this.progress,
    this.deliveryDate,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
