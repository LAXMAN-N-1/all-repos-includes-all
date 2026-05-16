import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Priority of an order.
enum OrderPriority {
  urgent,
  normal,
  low;

  String get label {
    switch (this) {
      case OrderPriority.urgent:
        return 'Urgent';
      case OrderPriority.normal:
        return 'Normal';
      case OrderPriority.low:
        return 'Low';
    }
  }

  static OrderPriority fromString(String value) {
    return OrderPriority.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => OrderPriority.normal,
    );
  }
}

/// Status of an order in the logistics pipeline.
/// FR-LOGISTICS-001: pending → in_transit → delivered | failed
enum OrderStatus {
  pending,
  inTransit,
  delivered,
  failed,
  cancelled;

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.inTransit:
        return 'In Transit';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.failed:
        return 'Failed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Progress value for the order pipeline (0.0 – 1.0).
  double get progress {
    switch (this) {
      case OrderStatus.pending:
        return 0.25;
      case OrderStatus.inTransit:
        return 0.65;
      case OrderStatus.delivered:
        return 1.0;
      case OrderStatus.failed:
        return 0.0;
      case OrderStatus.cancelled:
        return 0.0;
    }
  }

  static OrderStatus fromString(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    switch (normalized) {
      case 'in_transit':
      case 'intransit':
      case 'in_progress':
      case 'inprogress':
      case 'assigned':
      case 'dispatched':
      case 'out_for_delivery':
      case 'outfordelivery':
      case 'on_the_way':
      case 'en_route':
      case 'enroute':
      case 'shipped':
        return OrderStatus.inTransit;
      case 'delivered':
      case 'completed':
      case 'complete':
      case 'done':
      case 'success':
      case 'successful':
        return OrderStatus.delivered;
      case 'failed':
      case 'delivery_failed':
      case 'failed_delivery':
      case 'undelivered':
      case 'error':
        return OrderStatus.failed;
      case 'cancelled':
      case 'canceled':
      case 'cancel':
      case 'aborted':
      case 'rejected':
      case 'void':
        return OrderStatus.cancelled;
      // Legacy backend statuses mapped to closest equivalent
      case 'processing':
      case 'pending':
      case 'created':
      case 'new':
      case 'open':
      case 'queued':
      case 'unassigned':
      case 'awaiting_assignment':
      case 'awaiting_dispatch':
      case 'awaiting_pickup':
        return OrderStatus.pending;
      default:
        return OrderStatus.pending;
    }
  }

  String get apiValue {
    switch (this) {
      case OrderStatus.inTransit:
        return 'in_transit';
      default:
        return name;
    }
  }
}

/// Represents an order in the logistics system.
class OrderModel extends Equatable {
  final String id;
  final OrderStatus status;
  final OrderPriority priority;
  final int units;
  final String? destination;
  final String? notes;
  final String customerName;
  final String? customerPhone;
  final double totalValue;
  final String? trackingNumber;
  final List<String> assignedBatteryIds;
  final String? assignedDriverId;
  final String? assignedDriverName;
  final DateTime orderDate;
  final DateTime? estimatedDelivery;
  final DateTime? dispatchDate;
  final DateTime? deliveredAt;
  final DateTime updatedAt;

  // Proof of Delivery
  final String? proofOfDeliveryUrl;
  final String? proofOfDeliveryNotes;
  final String? proofOfDeliverySignatureUrl;
  final String? recipientName;
  final DateTime? proofOfDeliveryCapturedAt;

  // Failure info
  final String? failureReason;

  // Scheduling & Communication
  final DateTime? scheduledSlotStart;
  final DateTime? scheduledSlotEnd;
  final bool isConfirmed;
  final DateTime? confirmationSentAt;

  // Return & Reverse Logistics
  final String type; // delivery, return
  final String? originalOrderId;
  final String refundStatus; // none, pending, processed, failed

  const OrderModel({
    required this.id,
    required this.status,
    this.priority = OrderPriority.normal,
    required this.units,
    this.destination,
    this.notes,
    this.customerName = 'Unknown',
    this.customerPhone,
    this.totalValue = 0,
    this.trackingNumber,
    this.assignedBatteryIds = const [],
    this.assignedDriverId,
    this.assignedDriverName,
    required this.orderDate,
    this.estimatedDelivery,
    this.dispatchDate,
    this.deliveredAt,
    required this.updatedAt,
    this.proofOfDeliveryUrl,
    this.proofOfDeliveryNotes,
    this.proofOfDeliverySignatureUrl,
    this.recipientName,
    this.proofOfDeliveryCapturedAt,
    this.failureReason,
    this.scheduledSlotStart,
    this.scheduledSlotEnd,
    this.isConfirmed = false,
    this.confirmationSentAt,
    this.type = 'delivery',
    this.originalOrderId,
    this.refundStatus = 'none',
  });

  /// Unit price derived from total value and units.
  double get unitPrice => units > 0 ? totalValue / units : 0;

  /// Whether batteries have been assigned to this order.
  bool get hasBatteriesAssigned => assignedBatteryIds.isNotEmpty;

  /// Whether this order has tracking information.
  bool get hasTracking => trackingNumber != null && trackingNumber!.isNotEmpty;

  /// Whether proof of delivery has been captured.
  bool get hasProofOfDelivery => podImageUrl != null && podImageUrl!.isNotEmpty;

  String? get podImageUrl => _normalizeUploadPath(proofOfDeliveryUrl);
  String? get podSignatureUrl =>
      _normalizeUploadPath(proofOfDeliverySignatureUrl);
  String? get podNotes => _toNullableString(proofOfDeliveryNotes);
  String? get podRecipientName => _toNullableString(recipientName);
  DateTime? get podCapturedAt => proofOfDeliveryCapturedAt;
  bool get hasPodDisplayData =>
      podImageUrl != null || podNotes != null || podSignatureUrl != null;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Parse assigned_battery_ids from list or JSON string payload.
    List<String> batteryIds = [];
    final rawIds = json['assigned_battery_ids'];
    if (rawIds is List) {
      batteryIds = rawIds.map((e) => e.toString()).toList();
    } else if (rawIds is String && rawIds.isNotEmpty) {
      try {
        final parsed = jsonDecode(rawIds);
        if (parsed is List) {
          batteryIds = parsed.map((e) => e.toString()).toList();
        }
      } catch (_) {
        batteryIds = rawIds
            .split(',')
            .map((e) => e.trim().replaceAll('"', ''))
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    final assignedDriver =
        _toMap(json['assigned_driver']) ??
        _toMap(json['driver']) ??
        _toMap(json['assignedDriver']);
    final pod =
        pickMap(json, ['proof_of_delivery', 'proofOfDelivery']) ??
        const <String, dynamic>{};
    final podImageUrl = _normalizeUploadPath(
      _toNullableString(
        pick<dynamic>(json, ['proof_of_delivery_url', 'proofOfDeliveryUrl']) ??
            pick<dynamic>(pod, [
              'image_url',
              'imageUrl',
              'proof_of_delivery_url',
              'proofOfDeliveryUrl',
            ]),
      ),
    );
    final podNotes = _toNullableString(
      pick<dynamic>(json, [
            'proof_of_delivery_notes',
            'proofOfDeliveryNotes',
          ]) ??
          pick<dynamic>(pod, [
            'notes',
            'proof_of_delivery_notes',
            'proofOfDeliveryNotes',
          ]),
    );
    final podSignatureUrl = _normalizeUploadPath(
      _toNullableString(
        pick<dynamic>(json, [
              'proof_of_delivery_signature_url',
              'proofOfDeliverySignatureUrl',
            ]) ??
            pick<dynamic>(pod, [
              'signature_url',
              'signatureUrl',
              'proof_of_delivery_signature_url',
              'proofOfDeliverySignatureUrl',
            ]),
      ),
    );
    final podRecipientName = _toNullableString(
      pick<dynamic>(json, ['recipient_name', 'recipientName']) ??
          pick<dynamic>(pod, ['recipient_name', 'recipientName']),
    );
    final podCapturedAt = _toDateTime(
      pick<dynamic>(json, [
            'proof_of_delivery_captured_at',
            'proofOfDeliveryCapturedAt',
          ]) ??
          pick<dynamic>(pod, [
            'captured_at',
            'capturedAt',
            'proof_of_delivery_captured_at',
            'proofOfDeliveryCapturedAt',
          ]),
    );

    return OrderModel(
      id: json['id']?.toString() ?? '',
      status: _toOrderStatus(
        json['status'] ??
            json['order_status'] ??
            json['current_status'] ??
            json['orderState'] ??
            json['state'],
      ),
      priority: json['priority'] != null
          ? OrderPriority.fromString(json['priority'].toString())
          : OrderPriority.normal,
      units: _toInt(json['units'], fallback: 1),
      destination: _toNullableString(json['destination']),
      notes: _toNullableString(json['notes']),
      customerName: _toNullableString(json['customer_name']) ?? 'Unknown',
      customerPhone: _toNullableString(json['customer_phone']),
      totalValue: _toDouble(json['total_value']),
      trackingNumber: _toNullableString(json['tracking_number']),
      assignedBatteryIds: batteryIds,
      assignedDriverId: _toNullableString(
        json['assigned_driver_id'] ??
            json['driver_id'] ??
            json['assignedDriverId'] ??
            assignedDriver?['id'],
      ),
      assignedDriverName: _toNullableString(
        json['assigned_driver_name'] ??
            json['driver_name'] ??
            json['assignedDriverName'] ??
            assignedDriver?['full_name'] ??
            assignedDriver?['name'] ??
            assignedDriver?['display_name'],
      ),
      orderDate:
          _toDateTime(json['order_date']) ??
          _toDateTime(json['created_at']) ??
          DateTime.now(),
      estimatedDelivery: _toDateTime(json['estimated_delivery']),
      dispatchDate: _toDateTime(json['dispatch_date']),
      deliveredAt: _toDateTime(json['delivered_at']),
      updatedAt:
          _toDateTime(json['updated_at']) ??
          _toDateTime(json['order_date']) ??
          DateTime.now(),
      proofOfDeliveryUrl: podImageUrl,
      proofOfDeliveryNotes: podNotes,
      proofOfDeliverySignatureUrl: podSignatureUrl,
      recipientName: podRecipientName,
      proofOfDeliveryCapturedAt: podCapturedAt,
      failureReason: _toNullableString(json['failure_reason']),
      scheduledSlotStart: _toDateTime(json['scheduled_slot_start']),
      scheduledSlotEnd: _toDateTime(json['scheduled_slot_end']),
      isConfirmed: _toBool(json['is_confirmed']),
      confirmationSentAt: _toDateTime(json['confirmation_sent_at']),
      type: _toNullableString(json['type']) ?? 'delivery',
      originalOrderId: _toNullableString(json['original_order_id']),
      refundStatus: _toNullableString(json['refund_status']) ?? 'none',
    );
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsedInt = int.tryParse(value.trim());
      if (parsedInt != null) return parsedInt;
      final parsedDouble = double.tryParse(value.trim());
      if (parsedDouble != null) return parsedDouble.toInt();
    }
    return fallback;
  }

  static double _toDouble(dynamic value, {double fallback = 0}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  static bool _toBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
        return true;
      }
      if (normalized == 'false' || normalized == '0' || normalized == 'no') {
        return false;
      }
    }
    return fallback;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is num) {
      final raw = value.toInt();
      final millis = raw > 1000000000000 ? raw : raw * 1000;
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }
    return null;
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static T? pick<T>(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (!json.containsKey(key)) {
        continue;
      }
      final value = json[key];
      if (value == null) {
        continue;
      }
      if (value is T) {
        return value;
      }
      if (T == String) {
        return value.toString() as T;
      }
      if (T == int && value is num) {
        return value.toInt() as T;
      }
      if (T == double && value is num) {
        return value.toDouble() as T;
      }
    }
    return null;
  }

  static Map<String, dynamic>? pickMap(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final mapped = _toMap(json[key]);
      if (mapped != null) {
        return mapped;
      }
    }
    return null;
  }

  static String? _normalizeUploadPath(String? raw) {
    final value = _toNullableString(raw);
    if (value == null) return null;
    if (value.startsWith('uploads/')) {
      return '/$value';
    }
    return value;
  }

  static Map<String, dynamic>? _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  static OrderStatus _toOrderStatus(dynamic value) {
    if (value is OrderStatus) {
      return value;
    }
    if (value is num) {
      switch (value.toInt()) {
        case 1:
          return OrderStatus.inTransit;
        case 2:
          return OrderStatus.delivered;
        case 3:
          return OrderStatus.failed;
        case 4:
          return OrderStatus.cancelled;
        default:
          return OrderStatus.pending;
      }
    }
    if (value is Map) {
      final nested = _toNullableString(
        value['status'] ?? value['value'] ?? value['name'] ?? value['code'],
      );
      if (nested != null) {
        return OrderStatus.fromString(nested);
      }
    }
    final text = _toNullableString(value);
    if (text == null) {
      return OrderStatus.pending;
    }
    return OrderStatus.fromString(text);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status.apiValue,
    'priority': priority.name,
    'units': units,
    'destination': destination,
    'notes': notes,
    'customer_name': customerName,
    'customer_phone': customerPhone,
    'total_value': totalValue,
    'tracking_number': trackingNumber,
    'assigned_battery_ids': assignedBatteryIds,
    'assigned_driver_id': assignedDriverId,
    'assigned_driver_name': assignedDriverName,
    'order_date': orderDate.toIso8601String(),
    'estimated_delivery': estimatedDelivery?.toIso8601String(),
    'dispatch_date': dispatchDate?.toIso8601String(),
    'delivered_at': deliveredAt?.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'proof_of_delivery_url': proofOfDeliveryUrl,
    'proof_of_delivery_notes': proofOfDeliveryNotes,
    'proof_of_delivery_signature_url': proofOfDeliverySignatureUrl,
    'recipient_name': recipientName,
    'failure_reason': failureReason,
    'scheduled_slot_start': scheduledSlotStart?.toIso8601String(),
    'scheduled_slot_end': scheduledSlotEnd?.toIso8601String(),
    'is_confirmed': isConfirmed,
    'confirmation_sent_at': confirmationSentAt?.toIso8601String(),
    'type': type,
    'original_order_id': originalOrderId,
    'refund_status': refundStatus,
  };

  OrderModel copyWith({
    String? id,
    OrderStatus? status,
    OrderPriority? priority,
    int? units,
    String? destination,
    String? notes,
    String? customerName,
    String? customerPhone,
    double? totalValue,
    String? trackingNumber,
    List<String>? assignedBatteryIds,
    String? assignedDriverId,
    String? assignedDriverName,
    DateTime? orderDate,
    DateTime? estimatedDelivery,
    DateTime? dispatchDate,
    DateTime? deliveredAt,
    DateTime? updatedAt,
    String? proofOfDeliveryUrl,
    String? proofOfDeliveryNotes,
    String? proofOfDeliverySignatureUrl,
    String? recipientName,
    DateTime? proofOfDeliveryCapturedAt,
    String? failureReason,
    DateTime? scheduledSlotStart,
    DateTime? scheduledSlotEnd,
    bool? isConfirmed,
    DateTime? confirmationSentAt,
    String? type,
    String? originalOrderId,
    String? refundStatus,
  }) {
    return OrderModel(
      id: id ?? this.id,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      units: units ?? this.units,
      destination: destination ?? this.destination,
      notes: notes ?? this.notes,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      totalValue: totalValue ?? this.totalValue,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      assignedBatteryIds: assignedBatteryIds ?? this.assignedBatteryIds,
      assignedDriverId: assignedDriverId ?? this.assignedDriverId,
      assignedDriverName: assignedDriverName ?? this.assignedDriverName,
      orderDate: orderDate ?? this.orderDate,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      dispatchDate: dispatchDate ?? this.dispatchDate,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      updatedAt: updatedAt ?? this.updatedAt,
      proofOfDeliveryUrl: proofOfDeliveryUrl ?? this.proofOfDeliveryUrl,
      proofOfDeliveryNotes: proofOfDeliveryNotes ?? this.proofOfDeliveryNotes,
      proofOfDeliverySignatureUrl:
          proofOfDeliverySignatureUrl ?? this.proofOfDeliverySignatureUrl,
      recipientName: recipientName ?? this.recipientName,
      proofOfDeliveryCapturedAt:
          proofOfDeliveryCapturedAt ?? this.proofOfDeliveryCapturedAt,
      failureReason: failureReason ?? this.failureReason,
      scheduledSlotStart: scheduledSlotStart ?? this.scheduledSlotStart,
      scheduledSlotEnd: scheduledSlotEnd ?? this.scheduledSlotEnd,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      confirmationSentAt: confirmationSentAt ?? this.confirmationSentAt,
      type: type ?? this.type,
      originalOrderId: originalOrderId ?? this.originalOrderId,
      refundStatus: refundStatus ?? this.refundStatus,
    );
  }

  @override
  List<Object?> get props => [
    id,
    status,
    priority,
    units,
    orderDate,
    totalValue,
    assignedDriverId,
    assignedDriverName,
    proofOfDeliveryUrl,
    failureReason,
    scheduledSlotStart,
    scheduledSlotEnd,
    isConfirmed,
    confirmationSentAt,
    type,
    originalOrderId,
    refundStatus,
  ];
}
