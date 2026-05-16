import 'package:dio/dio.dart';

import '../../../core/api_exception.dart';
import '../../../core/result.dart';
import '../../../models/warehouse_model.dart';
import '../../../services/api/api_client.dart';
import '../../../services/api/idempotency_key.dart';
import '../../../utils/battery_identity.dart';

/// Repository for warehouse data operations.
/// Connects to the real backend API with full rack/shelf support.
class WarehouseRepository {
  final ApiClient _api;

  WarehouseRepository({required ApiClient api}) : _api = api;

  /// Fetch the warehouse layout with real rack/shelf data.
  Future<Result<WarehouseModel>> getWarehouseLayout({
    int? preferredWarehouseId,
    String? batterySerialHint,
  }) async {
    try {
      try {
        final allResponse = await _api.get<Map<String, dynamic>>(
          '/warehouse/all',
          queryParameters: {'active_only': true},
        );
        final allData = allResponse['data'];
        if (allData is List) {
          final warehouses = allData
              .whereType<Map<String, dynamic>>()
              .map(_mapWarehouseResponse)
              .toList();
          final selected = _selectWarehouseLayout(
            warehouses,
            preferredWarehouseId: preferredWarehouseId,
            batterySerialHint: batterySerialHint,
          );
          if (selected != null) {
            return Result.success(selected);
          }
        }
      } on ApiException {
        // Fallback to legacy/single warehouse endpoint below.
      }

      final response = await _api.get<Map<String, dynamic>>(
        '/warehouse/',
        queryParameters: preferredWarehouseId != null
            ? {'warehouse_id': preferredWarehouseId}
            : null,
      );
      final warehouseJson = response['data'] as Map<String, dynamic>?;
      if (warehouseJson == null) {
        return Result.success(
          const WarehouseModel(id: 'default', name: 'No Warehouse', racks: []),
        );
      }

      final warehouse = _mapWarehouseResponse(warehouseJson);
      return Result.success(warehouse);
    } on ApiException catch (_) {
      return Result.success(
        const WarehouseModel(
          id: 'default',
          name: 'Warehouse (unavailable)',
          racks: [],
        ),
      );
    } catch (_) {
      return Result.success(
        const WarehouseModel(
          id: 'default',
          name: 'Warehouse (unavailable)',
          racks: [],
        ),
      );
    }
  }

  WarehouseModel? _selectWarehouseLayout(
    List<WarehouseModel> warehouses, {
    int? preferredWarehouseId,
    String? batterySerialHint,
  }) {
    if (warehouses.isEmpty) return null;

    if (preferredWarehouseId != null) {
      final preferred = warehouses.where(
        (warehouse) => warehouse.id == preferredWarehouseId.toString(),
      );
      if (preferred.isNotEmpty) return preferred.first;
    }

    final normalizedSerial = batterySerialHint?.trim();
    if (normalizedSerial != null && normalizedSerial.isNotEmpty) {
      final lookupSerial = normalizeBatterySerial(normalizedSerial);
      for (final warehouse in warehouses) {
        for (final rack in warehouse.racks) {
          for (final shelf in rack.shelves) {
            final matches = shelf.batteryIds.any(
              (batteryId) => normalizeBatterySerial(batteryId) == lookupSerial,
            );
            if (matches) {
              return warehouse;
            }
          }
        }
      }
    }

    return warehouses.first;
  }

  /// Move a battery from one shelf to another.
  Future<Result<bool>> moveBattery({
    required String batteryId,
    required String fromShelfId,
    required String toShelfId,
  }) async {
    // The backend handles the "move" logic when improved to a new shelf.
    // We reuse the assignment logic.
    return assignBatteryToShelf(batteryId: batteryId, shelfId: toShelfId);
  }

  /// Assign a battery to a specific warehouse shelf.
  Future<Result<bool>> assignBatteryToShelf({
    required String batteryId,
    required String shelfId,
  }) async {
    try {
      await _api.post<Map<String, dynamic>>(
        '/warehouse/shelves/$shelfId/batteries',
        data: {'battery_id': batteryId},
        options: Options(
          headers: buildIdempotencyHeaders(
            'warehouse_assign_${shelfId}_$batteryId',
          ),
        ),
      );
      return Result.success(true);
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to assign battery to shelf: $e');
    }
  }

  /// Map backend warehouse JSON (with real rack/shelf data) to frontend model.
  WarehouseModel _mapWarehouseResponse(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final name = json['name'] as String? ?? 'Warehouse';

    final racksJson = json['racks'] as List<dynamic>? ?? [];
    final racks = racksJson.map((rackJson) {
      final rack = rackJson as Map<String, dynamic>;
      final shelvesJson = rack['shelves'] as List<dynamic>? ?? [];
      final shelves = shelvesJson.map((shelfJson) {
        final shelf = shelfJson as Map<String, dynamic>;
        final batteryIds =
            (shelf['battery_ids'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        return ShelfModel(
          id: shelf['id']?.toString() ?? '',
          name: shelf['name'] as String? ?? '',
          capacity: shelf['capacity'] as int? ?? 20,
          batteryIds: batteryIds,
        );
      }).toList();

      return RackModel(
        id: rack['id']?.toString() ?? '',
        name: rack['name'] as String? ?? '',
        shelves: shelves,
      );
    }).toList();

    return WarehouseModel(id: id, name: name, racks: racks);
  }
}
