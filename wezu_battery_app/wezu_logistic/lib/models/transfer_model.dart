import 'package:equatable/equatable.dart';
import 'dart:convert';

enum TransferStatus {
  pending,
  inTransit,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case TransferStatus.pending:
        return 'Pending';
      case TransferStatus.inTransit:
        return 'In Transit';
      case TransferStatus.completed:
        return 'Completed';
      case TransferStatus.cancelled:
        return 'Cancelled';
    }
  }

  static TransferStatus fromString(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    switch (normalized) {
      case 'in_transit':
        return TransferStatus.inTransit;
      case 'completed':
        return TransferStatus.completed;
      case 'cancelled':
        return TransferStatus.cancelled;
      default:
        return TransferStatus.pending;
    }
  }
}

class TransferModel extends Equatable {
  final int id;
  final String fromLocationType;
  final int fromLocationId;
  final String toLocationType;
  final int toLocationId;
  final TransferStatus status;
  final List<String> items; // List of battery IDs
  final int? driverId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  const TransferModel({
    required this.id,
    required this.fromLocationType,
    required this.fromLocationId,
    required this.toLocationType,
    required this.toLocationId,
    required this.status,
    required this.items,
    this.driverId,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory TransferModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedItems = [];
    if (json['items'] is String) {
      try {
        final decoded = jsonDecode(json['items'] as String);
        if (decoded is List) {
          parsedItems = decoded.map((item) => item.toString()).toList();
        }
      } catch (_) {}
    } else if (json['items'] is List) {
      parsedItems = (json['items'] as List)
          .map((item) => item.toString())
          .toList();
    }

    return TransferModel(
      id: _toInt(json['id']),
      fromLocationType: json['from_location_type']?.toString() ?? '',
      fromLocationId: _toInt(json['from_location_id']),
      toLocationType: json['to_location_type']?.toString() ?? '',
      toLocationId: _toInt(json['to_location_id']),
      status: TransferStatus.fromString(
        json['status']?.toString() ?? TransferStatus.pending.name,
      ),
      items: parsedItems,
      driverId: _toNullableInt(json['driver_id']),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
    );
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) return parsed;
      final parsedDouble = double.tryParse(value.trim());
      if (parsedDouble != null) return parsedDouble.toInt();
    }
    return fallback;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    final parsed = _toInt(value, fallback: -1);
    if (parsed < 0) return null;
    return parsed;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'from_location_type': fromLocationType,
    'from_location_id': fromLocationId,
    'to_location_type': toLocationType,
    'to_location_id': toLocationId,
    'status': status.name, // or proper mapping back to string
    'items': jsonEncode(items),
    'driver_id': driverId,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    fromLocationType,
    fromLocationId,
    toLocationType,
    toLocationId,
    status,
    items,
    driverId,
    createdAt,
    updatedAt,
    completedAt,
  ];
}
