import 'package:equatable/equatable.dart';

enum ManifestItemStatus {
  pending,
  scanned,
  missing,
  damaged,
  extra;

  String get label {
    switch (this) {
      case ManifestItemStatus.pending:
        return 'Pending';
      case ManifestItemStatus.scanned:
        return 'Scanned';
      case ManifestItemStatus.missing:
        return 'Missing';
      case ManifestItemStatus.damaged:
        return 'Damaged';
      case ManifestItemStatus.extra:
        return 'Extra';
    }
  }
}

class ManifestItem extends Equatable {
  final String batteryId; // Expected Battery ID
  final String? serialNumber;
  final String type; // e.g., 'Li-ion 48V'
  final ManifestItemStatus status;
  final String? damageReport; // If damaged
  final String? damagePhotoPath; // Local path to damage photo
  final String? assignedLocation; // If assigned

  const ManifestItem({
    required this.batteryId,
    this.serialNumber,
    required this.type,
    this.status = ManifestItemStatus.pending,
    this.damageReport,
    this.damagePhotoPath,
    this.assignedLocation,
  });

  ManifestItem copyWith({
    String? batteryId,
    String? serialNumber,
    String? type,
    ManifestItemStatus? status,
    String? damageReport,
    String? damagePhotoPath,
    String? assignedLocation,
  }) {
    return ManifestItem(
      batteryId: batteryId ?? this.batteryId,
      serialNumber: serialNumber ?? this.serialNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      damageReport: damageReport ?? this.damageReport,
      damagePhotoPath: damagePhotoPath ?? this.damagePhotoPath,
      assignedLocation: assignedLocation ?? this.assignedLocation,
    );
  }

  factory ManifestItem.fromJson(Map<String, dynamic> json) {
    return ManifestItem(
      batteryId: json['battery_id'] as String,
      serialNumber: json['serial_number'] as String?,
      type: json['type'] as String,
      status: ManifestItemStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String).toLowerCase(),
        orElse: () => ManifestItemStatus.pending,
      ),
      damageReport: json['damage_report'] as String?,
      damagePhotoPath: json['damage_photo_path'] as String?,
      assignedLocation: json['assigned_location'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'battery_id': batteryId,
        'serial_number': serialNumber,
        'type': type,
        'status': status.name,
        'damage_report': damageReport,
        'damage_photo_path': damagePhotoPath,
        'assigned_location': assignedLocation,
      };

  @override
  List<Object?> get props =>
      [batteryId, serialNumber, type, status, damageReport, damagePhotoPath, assignedLocation];
}

class ManifestModel extends Equatable {
  final String id;
  final String source; // e.g., 'Factory A', 'Supplier X'
  final DateTime date;
  final List<ManifestItem> items;
  final String status; // 'In Transit', 'Received', 'Partial'

  const ManifestModel({
    required this.id,
    required this.source,
    required this.date,
    required this.items,
    required this.status,
  });

  factory ManifestModel.fromJson(Map<String, dynamic> json) {
    return ManifestModel(
      id: json['id'] as String,
      source: json['source'] as String,
      date: DateTime.parse(json['date'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => ManifestItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': source,
        'date': date.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
        'status': status,
      };

  /// Helper to get counts
  int get totalItems => items.length;
  int get scannedCount =>
      items.where((i) => i.status == ManifestItemStatus.scanned).length;
  int get pendingCount =>
      items.where((i) => i.status == ManifestItemStatus.pending).length;
  int get issueCount => items
      .where((i) =>
          i.status == ManifestItemStatus.damaged ||
          i.status == ManifestItemStatus.missing ||
          i.status == ManifestItemStatus.extra)
      .length;

  double get progress => totalItems == 0 ? 0 : scannedCount / totalItems;

  ManifestModel copyWith({
    String? id,
    String? source,
    DateTime? date,
    List<ManifestItem>? items,
    String? status,
  }) {
    return ManifestModel(
      id: id ?? this.id,
      source: source ?? this.source,
      date: date ?? this.date,
      items: items ?? this.items,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, source, date, items, status];
}
