/// WEZU Dealer Portal — Inventory Data Models
/// Plain Dart classes (no Freezed codegen needed).

class BatteryHealthDto {
  final double percentage;
  final int cycles;
  final String condition;
  final String? lastTestDate;

  const BatteryHealthDto({
    this.percentage = 100.0,
    this.cycles = 0,
    this.condition = 'excellent',
    this.lastTestDate,
  });

  factory BatteryHealthDto.fromJson(Map<String, dynamic> json) {
    return BatteryHealthDto(
      percentage: (json['percentage'] as num?)?.toDouble() ?? 100.0,
      cycles: (json['cycles'] as num?)?.toInt() ?? 0,
      condition: json['condition']?.toString() ?? 'excellent',
      lastTestDate: json['last_test_date']?.toString(),
    );
  }
}

class BatteryChargeDto {
  final double percentage;
  final String? lastChargeTime;

  const BatteryChargeDto({
    this.percentage = 100.0,
    this.lastChargeTime,
  });

  factory BatteryChargeDto.fromJson(Map<String, dynamic> json) {
    return BatteryChargeDto(
      percentage: (json['percentage'] as num?)?.toDouble() ?? 100.0,
      lastChargeTime: json['last_charge_time']?.toString(),
    );
  }
}

class BatteryLocationDto {
  final int? stationId;
  final String stationName;

  const BatteryLocationDto({
    this.stationId,
    this.stationName = '',
  });

  factory BatteryLocationDto.fromJson(Map<String, dynamic> json) {
    return BatteryLocationDto(
      stationId: (json['station_id'] as num?)?.toInt(),
      stationName: json['station_name']?.toString() ?? '',
    );
  }
}

class BatteryItemDto {
  final int batteryId;
  final String serialNumber;
  final int? modelId;
  final String modelName;
  final BatteryHealthDto health;
  final String currentStatus;
  final String? faultReason;
  final BatteryLocationDto location;
  final BatteryChargeDto charge;
  final String? batteryType;
  final int cycleCount;
  final List<String> tags;
  final String? notes;
  final String? updatedAt;

  const BatteryItemDto({
    required this.batteryId,
    required this.serialNumber,
    this.modelId,
    this.modelName = '',
    required this.health,
    required this.currentStatus,
    this.faultReason,
    required this.location,
    required this.charge,
    this.batteryType,
    this.cycleCount = 0,
    this.tags = const [],
    this.notes,
    this.updatedAt,
  });

  factory BatteryItemDto.fromJson(Map<String, dynamic> json) {
    return BatteryItemDto(
      batteryId: (json['battery_id'] as num?)?.toInt() ?? 0,
      serialNumber: json['serial_number']?.toString() ?? '',
      modelId: (json['model_id'] as num?)?.toInt(),
      modelName: json['model_name']?.toString() ?? '',
      health: BatteryHealthDto.fromJson(
          json['health'] is Map<String, dynamic> ? json['health'] : {}),
      currentStatus: json['current_status']?.toString() ?? 'available',
      faultReason: json['fault_reason']?.toString(),
      location: BatteryLocationDto.fromJson(
          json['location'] is Map<String, dynamic> ? json['location'] : {}),
      charge: BatteryChargeDto.fromJson(
          json['charge'] is Map<String, dynamic> ? json['charge'] : {}),
      batteryType: json['battery_type']?.toString(),
      cycleCount: (json['cycle_count'] as num?)?.toInt() ?? 0,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      notes: json['notes']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  BatteryItemDto copyWith({
    String? currentStatus,
    String? faultReason,
  }) {
    return BatteryItemDto(
      batteryId: batteryId,
      serialNumber: serialNumber,
      modelId: modelId,
      modelName: modelName,
      health: health,
      currentStatus: currentStatus ?? this.currentStatus,
      faultReason: faultReason ?? this.faultReason,
      location: location,
      charge: charge,
      batteryType: batteryType,
      cycleCount: cycleCount,
      tags: tags,
      notes: notes,
      updatedAt: updatedAt,
    );
  }
}

class InventoryMetricsDto {
  final int totalStock;
  final int available;
  final int reserved;
  final int rented;
  final int maintenance;
  final int charging;
  final int damaged;
  final int lowStockCount;

  const InventoryMetricsDto({
    this.totalStock = 0,
    this.available = 0,
    this.reserved = 0,
    this.rented = 0,
    this.maintenance = 0,
    this.charging = 0,
    this.damaged = 0,
    this.lowStockCount = 0,
  });

  InventoryMetricsDto copyWith({
    int? damaged,
  }) {
    return InventoryMetricsDto(
      totalStock: totalStock,
      available: available,
      reserved: reserved,
      rented: rented,
      maintenance: maintenance,
      charging: charging,
      damaged: damaged ?? this.damaged,
      lowStockCount: lowStockCount,
    );
  }
}

class TelemetryPointDto {
  final DateTime timestamp;
  final double soc;
  final double temperature;

  const TelemetryPointDto({
    required this.timestamp,
    required this.soc,
    required this.temperature,
  });
}

class AuditLogDto {
  final int id;
  final String eventType;
  final DateTime timestamp;
  final String actor;
  final String description;

  const AuditLogDto({
    required this.id,
    required this.eventType,
    required this.timestamp,
    required this.actor,
    required this.description,
  });
}

// ── State classes ──

class InventoryListState {
  final bool isLoading;
  final String? error;
  final List<BatteryItemDto> items;
  final int page;
  final int total;

  const InventoryListState({
    this.isLoading = true,
    this.error,
    this.items = const [],
    this.page = 1,
    this.total = 0,
  });

  InventoryListState copyWith({
    bool? isLoading,
    String? error,
    List<BatteryItemDto>? items,
    int? page,
    int? total,
  }) {
    return InventoryListState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      items: items ?? this.items,
      page: page ?? this.page,
      total: total ?? this.total,
    );
  }
}

class InventoryMetricsState {
  final bool isLoading;
  final String? error;
  final InventoryMetricsDto data;

  const InventoryMetricsState({
    this.isLoading = true,
    this.error,
    this.data = const InventoryMetricsDto(),
  });

  InventoryMetricsState copyWith({
    bool? isLoading,
    String? error,
    InventoryMetricsDto? data,
  }) {
    return InventoryMetricsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      data: data ?? this.data,
    );
  }
}
