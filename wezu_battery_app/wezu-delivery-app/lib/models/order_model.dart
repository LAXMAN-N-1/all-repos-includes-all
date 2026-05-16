enum OrderStatus {
  pending,
  accepted,
  pickingUp, // Driver moving to pickup battery
  delivering, // Driver in transit to dropoff
  delivered,
  cancelled,
}

/// Maps backend `status` string to [OrderStatus].
OrderStatus _statusFromString(String? s) {
  switch (s) {
    case 'pending':
      return OrderStatus.pending;
    case 'accepted':
    case 'assigned':
      return OrderStatus.accepted;
    case 'picking_up':
    case 'pickingUp':
      return OrderStatus.pickingUp;
    case 'in_transit':
    case 'delivering':
      return OrderStatus.delivering;
    case 'delivered':
    case 'completed':
      return OrderStatus.delivered;
    case 'cancelled':
    case 'failed':
      return OrderStatus.cancelled;
    default:
      return OrderStatus.pending;
  }
}

class Order {
  final String id;
  final String pickupName;
  final String pickupAddress;
  final String dropoffName;
  final String dropoffAddress;
  final double amount;
  final OrderStatus status;
  final DateTime timestamp;
  final double distance; // km

  // Backend extras (nullable for backwards compat)
  final double? originLat;
  final double? originLng;
  final double? destinationLat;
  final double? destinationLng;
  final String? trackingUrl;
  final String? proofOfDeliveryUrl;
  final String? completionOtp;
  final String? orderType;

  Order({
    required this.id,
    required this.pickupName,
    required this.pickupAddress,
    required this.dropoffName,
    required this.dropoffAddress,
    required this.amount,
    required this.status,
    required this.timestamp,
    required this.distance,
    this.originLat,
    this.originLng,
    this.destinationLat,
    this.destinationLng,
    this.trackingUrl,
    this.proofOfDeliveryUrl,
    this.completionOtp,
    this.orderType,
  });

  /// Parse a backend `DeliveryOrder` JSON object into [Order].
  factory Order.fromJson(Map<String, dynamic> json) {
    // Derive display names from addresses / order type
    final orderType = json['order_type']?.toString() ?? 'delivery';
    final pickupAddr =
        json['origin_address']?.toString() ??
        json['pickup_address']?.toString() ??
        'Station';
    final dropoffAddr =
        json['destination_address']?.toString() ??
        json['dropoff_address']?.toString() ??
        'Customer';

    // Amount: backend may include delivery_fee, or default to 0
    final amount =
        (json['delivery_fee'] as num?)?.toDouble() ??
        (json['amount'] as num?)?.toDouble() ??
        0.0;

    // Distance: derive from backend or default
    final distance =
        (json['distance_km'] as num?)?.toDouble() ??
        (json['distance'] as num?)?.toDouble() ??
        0.0;

    // Timestamp: prefer scheduled_at, then created_at
    DateTime ts;
    try {
      final rawTs =
          json['scheduled_at'] ?? json['created_at'] ?? json['timestamp'];
      ts = rawTs != null ? DateTime.parse(rawTs.toString()) : DateTime.now();
    } catch (_) {
      ts = DateTime.now();
    }

    return Order(
      id: json['id']?.toString() ?? '',
      pickupName: _labelForPickup(orderType, json),
      pickupAddress: pickupAddr,
      dropoffName: _labelForDropoff(orderType, json),
      dropoffAddress: dropoffAddr,
      amount: amount,
      status: _statusFromString(json['status']?.toString()),
      timestamp: ts,
      distance: distance,
      originLat: (json['origin_lat'] as num?)?.toDouble(),
      originLng: (json['origin_lng'] as num?)?.toDouble(),
      destinationLat: (json['destination_lat'] as num?)?.toDouble(),
      destinationLng: (json['destination_lng'] as num?)?.toDouble(),
      trackingUrl: json['tracking_url']?.toString(),
      proofOfDeliveryUrl: json['proof_of_delivery_url']?.toString(),
      completionOtp: json['completion_otp']?.toString(),
      orderType: orderType,
    );
  }

  static String _labelForPickup(String orderType, Map<String, dynamic> json) {
    if (orderType == 'return') return 'Customer Location';
    return json['station_name']?.toString() ?? 'Wezu Station';
  }

  static String _labelForDropoff(String orderType, Map<String, dynamic> json) {
    if (orderType == 'return') return 'Wezu Station';
    final custName = json['customer_name']?.toString();
    final plate = json['vehicle_plate']?.toString();
    if (custName != null && custName.isNotEmpty) return custName;
    if (plate != null && plate.isNotEmpty) return 'Vehicle $plate';
    return 'Customer';
  }

  Order copyWith({
    String? id,
    String? pickupName,
    String? pickupAddress,
    String? dropoffName,
    String? dropoffAddress,
    double? amount,
    OrderStatus? status,
    DateTime? timestamp,
    double? distance,
  }) {
    return Order(
      id: id ?? this.id,
      pickupName: pickupName ?? this.pickupName,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffName: dropoffName ?? this.dropoffName,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      distance: distance ?? this.distance,
      originLat: originLat,
      originLng: originLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      trackingUrl: trackingUrl,
      proofOfDeliveryUrl: proofOfDeliveryUrl,
      completionOtp: completionOtp,
      orderType: orderType,
    );
  }
}
