import 'package:equatable/equatable.dart';

/// Status of a battery in the logistics system.
enum BatteryStatus {
  available,
  deployed,
  charging,
  faulty,
  maintenance,
  reserved,
  inTransit,
  newBattery,
  retired;

  String get label {
    switch (this) {
      case BatteryStatus.available:
        return 'Available';
      case BatteryStatus.deployed:
        return 'Deployed';
      case BatteryStatus.charging:
        return 'Charging';
      case BatteryStatus.faulty:
        return 'Faulty';
      case BatteryStatus.maintenance:
        return 'Maintenance';
      case BatteryStatus.reserved:
        return 'Reserved';
      case BatteryStatus.inTransit:
        return 'In Transit';
      case BatteryStatus.newBattery:
        return 'New';
      case BatteryStatus.retired:
        return 'Retired';
    }
  }

  /// Canonical value expected by backend APIs.
  String get apiValue {
    switch (this) {
      case BatteryStatus.inTransit:
        return 'in_transit';
      case BatteryStatus.newBattery:
        return 'new';
      default:
        return name;
    }
  }

  /// Parse from API string.
  static BatteryStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'deployed':
        return BatteryStatus.deployed;
      case 'charging':
        return BatteryStatus.charging;
      case 'faulty':
        return BatteryStatus.faulty;
      case 'maintenance':
        return BatteryStatus.maintenance;
      case 'reserved':
        return BatteryStatus.reserved;
      case 'in_transit':
      case 'in-transit':
      case 'intransit':
        return BatteryStatus.inTransit;
      case 'new':
      case 'new_battery':
      case 'ready':
        return BatteryStatus.newBattery;
      case 'retired':
        return BatteryStatus.retired;
      case 'available':
      default:
        return BatteryStatus.available;
    }
  }
}

/// Represents a single battery in the logistics system.
class BatteryModel extends Equatable {
  final String id;
  final String serialNumber;
  final String model;
  final String manufacturer;
  final BatteryStatus status;
  final int chargePercentage;
  final int healthPercentage;
  final int capacity; // mAh
  final int cycleCount;
  final double voltage;
  final double? temperature;
  final String? location;
  final int? locationId;
  final String? assignedTo;
  final DateTime? lastCharged;
  final DateTime? warrantyExpiry;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<BatteryEvent> history;

  const BatteryModel({
    required this.id,
    required this.serialNumber,
    required this.model,
    required this.manufacturer,
    required this.status,
    required this.chargePercentage,
    required this.healthPercentage,
    required this.capacity,
    required this.cycleCount,
    required this.voltage,
    this.temperature,
    this.location,
    this.locationId,
    this.assignedTo,
    this.lastCharged,
    this.warrantyExpiry,
    required this.createdAt,
    required this.updatedAt,
    this.history = const [],
  });

  /// Whether this battery's health is considered low (< 70%).
  bool get isLowHealth => healthPercentage < 70;

  /// Whether the warranty is expiring within the next 30 days.
  bool get isWarrantyExpiring {
    if (warrantyExpiry == null) return false;
    return warrantyExpiry!.difference(DateTime.now()).inDays < 30;
  }

  factory BatteryModel.fromJson(Map<String, dynamic> json) {
    // Extract nested spec data for fallback values
    final spec = json['spec'] as Map<String, dynamic>?;

    return BatteryModel(
      id: json['id']?.toString() ?? '',
      serialNumber: (json['serial_number'] as String? ?? '')
          .trim()
          .toUpperCase(),
      model: json['model'] as String? ?? spec?['name'] as String? ?? 'Unknown',
      manufacturer:
          json['manufacturer'] as String? ??
          spec?['manufacturer'] as String? ??
          'Unknown',
      status: BatteryStatus.fromString(
        json['status'] as String? ?? 'available',
      ),
      chargePercentage:
          (json['current_charge'] as num?)?.toInt() ??
          json['charge_percentage'] as int? ??
          0,
      healthPercentage: (json['health_percentage'] as num?)?.toInt() ?? 100,
      capacity: (json['capacity_mah'] as num?)?.toInt() ?? 4000,
      cycleCount: json['cycle_count'] as int? ?? 0,
      voltage:
          (json['nominal_voltage'] as num?)?.toDouble() ??
          (json['voltage'] as num?)?.toDouble() ??
          spec?['voltage'] as double? ??
          48.0,
      temperature: (json['temperature'] as num?)?.toDouble(),
      location: json['location_type'] as String? ?? json['location'] as String?,
      locationId: (json['location_id'] as num?)?.toInt(),
      assignedTo:
          json['current_holder_id']?.toString() ??
          json['assigned_to'] as String?,
      lastCharged: json['last_charged'] != null
          ? DateTime.tryParse(json['last_charged'] as String)
          : null,
      warrantyExpiry: json['warranty_expiry'] != null
          ? DateTime.tryParse(json['warranty_expiry'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : (json['created_at'] != null
                ? DateTime.parse(json['created_at'] as String)
                : DateTime.now()),
      history:
          (json['lifecycle_events'] as List<dynamic>?)
              ?.map((e) => BatteryEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'serial_number': serialNumber,
    'model': model,
    'manufacturer': manufacturer,
    'status': status.apiValue,
    'charge_percentage': chargePercentage,
    'health_percentage': healthPercentage,
    'cycle_count': cycleCount,
    'voltage': voltage,
    'temperature': temperature,
    'location': location,
    'location_id': locationId,
    'assigned_to': assignedTo,
    'last_charged': lastCharged?.toIso8601String(),
    'warranty_expiry': warrantyExpiry?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  BatteryModel copyWith({
    String? id,
    String? serialNumber,
    String? model,
    String? manufacturer,
    BatteryStatus? status,
    int? chargePercentage,
    int? healthPercentage,
    int? capacity,
    int? cycleCount,
    double? voltage,
    double? temperature,
    String? location,
    int? locationId,
    String? assignedTo,
    DateTime? lastCharged,
    DateTime? warrantyExpiry,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<BatteryEvent>? history,
  }) {
    return BatteryModel(
      id: id ?? this.id,
      serialNumber: serialNumber ?? this.serialNumber,
      model: model ?? this.model,
      manufacturer: manufacturer ?? this.manufacturer,
      status: status ?? this.status,
      chargePercentage: chargePercentage ?? this.chargePercentage,
      healthPercentage: healthPercentage ?? this.healthPercentage,
      capacity: capacity ?? this.capacity,
      cycleCount: cycleCount ?? this.cycleCount,
      voltage: voltage ?? this.voltage,
      temperature: temperature ?? this.temperature,
      location: location ?? this.location,
      locationId: locationId ?? this.locationId,
      assignedTo: assignedTo ?? this.assignedTo,
      lastCharged: lastCharged ?? this.lastCharged,
      warrantyExpiry: warrantyExpiry ?? this.warrantyExpiry,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [
    id,
    serialNumber,
    model,
    status,
    chargePercentage,
    healthPercentage,
    capacity,
    cycleCount,
    location,
    locationId,
    assignedTo,
  ];
}

class BatteryEvent extends Equatable {
  final int id;
  final String eventType;
  final String? description;
  final DateTime timestamp;

  const BatteryEvent({
    required this.id,
    required this.eventType,
    this.description,
    required this.timestamp,
  });

  factory BatteryEvent.fromJson(Map<String, dynamic> json) {
    return BatteryEvent(
      id: json['id'] as int? ?? 0,
      eventType: json['event_type'] as String? ?? 'unknown',
      description: json['description'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, eventType, timestamp];
}
