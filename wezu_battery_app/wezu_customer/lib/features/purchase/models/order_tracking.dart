enum OrderStatus { ordered, packed, shipped, outForDelivery, delivered }

class TrackingEvent {
  final OrderStatus status;
  final DateTime timestamp;
  final String location;
  final String description;

  TrackingEvent({
    required this.status,
    required this.timestamp,
    required this.location,
    required this.description,
  });
}

class OrderTracking {
  final String orderId;
  final String trackingNumber;
  final OrderStatus currentStatus;
  final List<TrackingEvent> timeline;
  final String deliveryPartnerName;
  final String deliveryPartnerPhone;
  final String deliveryPartnerPhoto;
  final DateTime expectedDelivery;
  final String? deliveryProofUrl;

  OrderTracking({
    required this.orderId,
    required this.trackingNumber,
    required this.currentStatus,
    required this.timeline,
    required this.deliveryPartnerName,
    required this.deliveryPartnerPhone,
    required this.deliveryPartnerPhoto,
    required this.expectedDelivery,
    this.deliveryProofUrl,
  });

  bool get isDelivered => currentStatus == OrderStatus.delivered;
}
