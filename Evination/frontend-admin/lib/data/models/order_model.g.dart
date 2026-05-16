// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: (json['id'] as num).toInt(),
  orderRef: json['order_ref'] as String,
  vendorName: json['vendor_name'] as String?,
  vendorContact: json['vendor_contact'] as String?,
  vendorEmail: json['vendor_email'] as String?,
  serviceDescription: json['service_description'] as String?,
  eventName: json['event_name'] as String?,
  eventDate: json['event_date'] == null
      ? null
      : DateTime.parse(json['event_date'] as String),
  eventLocation: json['event_location'] as String?,
  customerName: json['customer_name'] as String?,
  customerEmail: json['customer_email'] as String?,
  customerPhone: json['customer_phone'] as String?,
  amount: (json['amount'] as num).toDouble(),
  status: json['status'] as String,
  paidAmount: (json['paid_amount'] as num).toDouble(),
  paymentStatus: json['payment_status'] as String,
  progress: (json['progress'] as num?)?.toInt(),
  deliveryDate: json['delivery_date'] == null
      ? null
      : DateTime.parse(json['delivery_date'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'order_ref': instance.orderRef,
  'vendor_name': instance.vendorName,
  'vendor_contact': instance.vendorContact,
  'vendor_email': instance.vendorEmail,
  'service_description': instance.serviceDescription,
  'event_name': instance.eventName,
  'event_date': instance.eventDate?.toIso8601String(),
  'event_location': instance.eventLocation,
  'customer_name': instance.customerName,
  'customer_email': instance.customerEmail,
  'customer_phone': instance.customerPhone,
  'amount': instance.amount,
  'status': instance.status,
  'paid_amount': instance.paidAmount,
  'payment_status': instance.paymentStatus,
  'progress': instance.progress,
  'delivery_date': instance.deliveryDate?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};
