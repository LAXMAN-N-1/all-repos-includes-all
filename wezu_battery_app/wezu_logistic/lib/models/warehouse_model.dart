import 'package:equatable/equatable.dart';

/// Represents the filling status of a shelf.
enum ShelfStatus {
  empty,
  partial,
  full;

  String get label {
    switch (this) {
      case ShelfStatus.empty:
        return 'Empty';
      case ShelfStatus.partial:
        return 'Partial';
      case ShelfStatus.full:
        return 'Full';
    }
  }
}

/// A specific storage unit within a rack.
class ShelfModel extends Equatable {
  final String id;
  final String name;
  final int capacity;
  final List<String> batteryIds;

  const ShelfModel({
    required this.id,
    required this.name,
    required this.capacity,
    this.batteryIds = const [],
  });

  /// Computed status based on capacity and current usage.
  ShelfStatus get status {
    if (batteryIds.isEmpty) return ShelfStatus.empty;
    if (batteryIds.length >= capacity) return ShelfStatus.full;
    return ShelfStatus.partial;
  }

  /// Returns the occupancy percentage (0.0 to 1.0).
  double get occupancyPercentage {
    if (capacity == 0) return 0.0;
    return batteryIds.length / capacity;
  }

  ShelfModel copyWith({
    String? id,
    String? name,
    int? capacity,
    List<String>? batteryIds,
  }) {
    return ShelfModel(
      id: id ?? this.id,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      batteryIds: batteryIds ?? this.batteryIds,
    );
  }

  @override
  List<Object?> get props => [id, name, capacity, batteryIds];
}

/// A vertical collection of shelves.
class RackModel extends Equatable {
  final String id;
  final String name;
  final List<ShelfModel> shelves;

  const RackModel({
    required this.id,
    required this.name,
    required this.shelves,
  });

  /// Total capacity of the rack.
  int get totalCapacity => shelves.fold(0, (sum, shelf) => sum + shelf.capacity);

  /// Total number of batteries currently in the rack.
  int get currentCount => shelves.fold(0, (sum, shelf) => sum + shelf.batteryIds.length);

  RackModel copyWith({
    String? id,
    String? name,
    List<ShelfModel>? shelves,
  }) {
    return RackModel(
      id: id ?? this.id,
      name: name ?? this.name,
      shelves: shelves ?? this.shelves,
    );
  }

  @override
  List<Object?> get props => [id, name, shelves];
}

/// The entire warehouse structure.
class WarehouseModel extends Equatable {
  final String id;
  final String name;
  final List<RackModel> racks;

  const WarehouseModel({
    required this.id,
    required this.name,
    required this.racks,
  });

  /// Total capacity of the warehouse.
  int get totalCapacity => racks.fold(0, (sum, rack) => sum + rack.totalCapacity);

  /// Total number of batteries in the warehouse.
  int get currentCount => racks.fold(0, (sum, rack) => sum + rack.currentCount);

  WarehouseModel copyWith({
    String? id,
    String? name,
    List<RackModel>? racks,
  }) {
    return WarehouseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      racks: racks ?? this.racks,
    );
  }

  @override
  List<Object?> get props => [id, name, racks];
}
