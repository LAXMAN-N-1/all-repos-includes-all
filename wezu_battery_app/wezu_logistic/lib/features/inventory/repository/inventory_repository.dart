import 'package:dio/dio.dart';

import '../../../core/api_exception.dart';
import '../../../core/result.dart';
import '../../../models/battery_model.dart';
import '../../../models/manifest_model.dart';
import '../../../models/transfer_model.dart';
import '../../../services/api/api_client.dart';
import '../../../services/api/idempotency_key.dart';
import '../../../services/offline_service.dart';
import '../../../utils/battery_identity.dart';

class TransferDestination {
  final int id;
  final String name;

  const TransferDestination({required this.id, required this.name});
}

class TransferWarehouse {
  final int id;
  final String name;

  const TransferWarehouse({required this.id, required this.name});
}

class TransferLocationData {
  final List<TransferWarehouse> warehouses;
  final List<TransferDestination> destinations;

  const TransferLocationData({
    required this.warehouses,
    required this.destinations,
  });

  TransferWarehouse? get defaultWarehouse =>
      warehouses.isEmpty ? null : warehouses.first;
}

/// Repository for inventory / battery data operations.
/// Connects to the real backend API for battery CRUD operations.
class InventoryRepository {
  final ApiClient _api;
  static const Set<String> _validTransferStatuses = {
    'pending',
    'in_transit',
    'completed',
    'cancelled',
  };
  static const Set<String> _validLocationTypes = {
    'warehouse',
    'station',
    'shelf',
  };

  InventoryRepository({required ApiClient api}) : _api = api;

  /// Fetch inventory summary statistics from the battery list.
  Future<Result<Map<String, int>>> fetchInventoryStats() async {
    try {
      final response = await _api.get<dynamic>(
        '/batteries/',
        queryParameters: {'skip': 0, 'limit': 500, 'include_pagination': true},
      );

      final batteries = _extractListPayload(response)
          .whereType<Map>()
          .map(
            (item) => BatteryModel.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList();

      final lowHealthCount = batteries.where((b) => b.isLowHealth).length;
      final warrantyExpiring = batteries
          .where((b) => b.isWarrantyExpiring)
          .length;

      return Result.success({
        'total': batteries.length,
        'available': batteries
            .where((b) => b.status == BatteryStatus.available)
            .length,
        'charging': batteries
            .where((b) => b.status == BatteryStatus.charging)
            .length,
        'deployed': batteries
            .where((b) => b.status == BatteryStatus.deployed)
            .length,
        'faulty': batteries
            .where((b) => b.status == BatteryStatus.faulty)
            .length,
        'maintenance': batteries
            .where((b) => b.status == BatteryStatus.maintenance)
            .length,
        'low_health': lowHealthCount,
        'warranty_expiring': warrantyExpiring,
      });
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to load inventory stats: $e');
    }
  }

  /// Fetch batteries with optional filter, search, and sorting.
  /// The backend supports `skip` and `limit` for pagination.
  Future<Result<List<BatteryModel>>> fetchBatteries({
    int page = 1,
    int pageSize = 20,
    BatteryStatus? filter,
    String? searchQuery,
    String sortBy = 'id',
    String sortOrder = 'asc',
    bool? lowHealthOnly,
    bool? warrantyExpiringOnly,
  }) async {
    try {
      final skip = (page - 1) * pageSize;
      final normalizedSearch = (searchQuery ?? '').trim();
      final hasSearch = normalizedSearch.isNotEmpty;
      final requiresFullScan =
          filter != null ||
          lowHealthOnly == true ||
          warrantyExpiringOnly == true ||
          hasSearch ||
          sortBy != 'id' ||
          sortOrder != 'asc';

      final response = await _api.get<dynamic>(
        '/batteries/',
        queryParameters: requiresFullScan
            ? {'skip': 0, 'limit': 500, 'include_pagination': true}
            : {'skip': skip, 'limit': pageSize, 'include_pagination': true},
      );

      final rawItems = _extractListPayload(response);
      var items = rawItems
          .whereType<Map>()
          .map(
            (e) => BatteryModel.fromJson(
              e.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList();

      // Client-side filtering (backend doesn't support these filters)
      if (filter != null) {
        items = items.where((b) => b.status == filter).toList();
      }
      if (lowHealthOnly == true) {
        items = items.where((b) => b.isLowHealth).toList();
      }
      if (warrantyExpiringOnly == true) {
        items = items.where((b) => b.isWarrantyExpiring).toList();
      }
      if (hasSearch) {
        final query = normalizedSearch.toLowerCase();
        items = items
            .where(
              (b) =>
                  b.id.toLowerCase().contains(query) ||
                  b.serialNumber.toLowerCase().contains(query) ||
                  b.model.toLowerCase().contains(query) ||
                  b.manufacturer.toLowerCase().contains(query) ||
                  (b.location?.toLowerCase().contains(query) ?? false),
            )
            .toList();
      }

      // Client-side sorting
      items.sort((a, b) {
        int cmp;
        switch (sortBy) {
          case 'charge':
          case 'charge_percentage':
            cmp = a.chargePercentage.compareTo(b.chargePercentage);
            break;
          case 'health':
          case 'health_percentage':
            cmp = a.healthPercentage.compareTo(b.healthPercentage);
            break;
          case 'cycles':
          case 'cycle_count':
            cmp = a.cycleCount.compareTo(b.cycleCount);
            break;
          case 'voltage':
            cmp = a.voltage.compareTo(b.voltage);
            break;
          case 'created_at':
            cmp = a.createdAt.compareTo(b.createdAt);
            break;
          case 'manufacturer':
            cmp = a.manufacturer.compareTo(b.manufacturer);
            break;
          case 'id':
          default:
            cmp = a.id.compareTo(b.id);
        }
        return sortOrder == 'desc' ? -cmp : cmp;
      });

      final resultList = requiresFullScan
          ? items.skip(skip).take(pageSize).toList()
          : items;
      await OfflineService.cacheInventory(resultList);

      return Result.success(resultList);
    } on ApiException catch (e) {
      final cached = OfflineService.getCachedInventory();
      if (cached.isNotEmpty) return Result.success(cached);
      return Result.failure(e.message);
    } catch (e) {
      final cached = OfflineService.getCachedInventory();
      if (cached.isNotEmpty) return Result.success(cached);
      return Result.failure('Failed to load batteries: $e');
    }
  }

  /// Fetch batteries for a specific location.
  /// Uses backend inventory-location endpoint with optional status filtering.
  Future<Result<List<BatteryModel>>> getLocationBatteries(
    String locationType,
    int locationId, {
    String? status,
    int skip = 0,
    int limit = 500,
  }) async {
    try {
      final normalizedType = locationType.trim().toLowerCase();
      if (!_validLocationTypes.contains(normalizedType)) {
        return Result.failure(
          "Invalid location type '$locationType'. Allowed: ${_validLocationTypes.toList()..sort()}",
        );
      }
      if (locationId <= 0) {
        return Result.failure('locationId must be > 0');
      }
      if (skip < 0) {
        return Result.failure('skip must be >= 0');
      }
      if (limit <= 0 || limit > 500) {
        return Result.failure('limit must be between 1 and 500');
      }

      final normalizedStatus = status?.trim().toLowerCase();
      final payload = await _api.get<dynamic>(
        '/inventory/locations/$normalizedType/$locationId/batteries',
        queryParameters: {
          'skip': skip,
          'limit': limit,
          if (normalizedStatus != null && normalizedStatus.isNotEmpty)
            'status': normalizedStatus,
        },
      );

      final rawItems = _extractListPayload(payload);
      if (rawItems.isEmpty) {
        return Result.failure('Unexpected location batteries response');
      }

      final batteries = rawItems
          .whereType<Map>()
          .map(
            (item) => BatteryModel.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList();

      return Result.success(batteries);
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to load location batteries: $e');
    }
  }

  /// Fetch a single battery by ID.
  Future<Result<BatteryModel>> getBatteryById(String id) async {
    try {
      final data = await _api.get<Map<String, dynamic>>('/batteries/$id');
      return Result.success(BatteryModel.fromJson(data));
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Battery not found: $e');
    }
  }

  /// Update battery status via lifecycle endpoint.
  Future<Result<BatteryModel>> updateBatteryStatus(
    String id,
    BatteryStatus newStatus,
  ) async {
    try {
      final data = await _api.put<Map<String, dynamic>>(
        '/batteries/$id/lifecycle',
        data: {'status': newStatus.apiValue},
      );
      return Result.success(BatteryModel.fromJson(data));
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Update failed: $e');
    }
  }

  /// Get full inventory details.
  Future<Result<List<BatteryModel>>> getInventory({
    String? category = 'all',
  }) async {
    return fetchBatteries(pageSize: 500);
  }

  /// Receive New Stock — creates a battery on the backend.
  Future<Result<bool>> receiveStock(Map<String, dynamic> stockData) async {
    try {
      final payload = Map<String, dynamic>.from(stockData);
      final rawSerial = payload['serial_number'];
      if (rawSerial is String) {
        final normalizedSerial = normalizeBatterySerial(rawSerial);
        if (normalizedSerial.isNotEmpty) {
          payload['serial_number'] = normalizedSerial;
        }
      }
      final rawWarehouseId = payload['warehouse_id'];
      if (rawWarehouseId is String) {
        final trimmed = rawWarehouseId.trim();
        if (trimmed.isEmpty) {
          payload.remove('warehouse_id');
        } else {
          final parsedWarehouseId = int.tryParse(trimmed);
          if (parsedWarehouseId != null && parsedWarehouseId > 0) {
            payload['warehouse_id'] = parsedWarehouseId;
          }
        }
      }
      await _api.post<Map<String, dynamic>>(
        '/batteries/',
        data: payload,
        options: Options(
          headers: buildIdempotencyHeaders('inventory_receive_stock_create'),
        ),
      );
      return Result.success(true);
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to receive stock: $e');
    }
  }

  /// Update Battery Location.
  Future<Result<bool>> updateLocation(
    String batteryId,
    String locationId,
  ) async {
    try {
      final parsedLocationId = int.tryParse(locationId);
      if (parsedLocationId == null || parsedLocationId <= 0) {
        return Result.failure('Invalid location id');
      }
      await _api.put<Map<String, dynamic>>(
        '/batteries/$batteryId/lifecycle',
        data: {'location_type': 'warehouse', 'location_id': parsedLocationId},
      );
      return Result.success(true);
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to update location: $e');
    }
  }

  /// Fetch manifest by ID from backend.
  Future<Result<ManifestModel>> fetchManifest(String id) async {
    try {
      final response = await _api.get<Map<String, dynamic>>('/manifests/$id');
      // Unwrap DataResponse
      final data = response['data'] as Map<String, dynamic>;
      return Result.success(ManifestModel.fromJson(data));
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to fetch manifest: $e');
    }
  }

  /// Create a new manifest (for testing/admin usage).
  Future<Result<ManifestModel>> createManifest(ManifestModel manifest) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/manifests/',
        data: manifest.toJson(),
        options: Options(
          headers: buildIdempotencyHeaders('manifest_create_${manifest.id}'),
        ),
      );
      // Unwrap DataResponse
      final data = response['data'] as Map<String, dynamic>;
      return Result.success(ManifestModel.fromJson(data));
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to create manifest: $e');
    }
  }

  /// Submit manifest items (Process Stock Receipt).
  Future<Result<ManifestModel>> submitManifest(
    String manifestId,
    List<Map<String, dynamic>> items, {
    int? warehouseId,
  }) async {
    try {
      final payload = {
        if (warehouseId != null) 'warehouse_id': warehouseId,
        'items': items,
      };
      final response = await _api.post<Map<String, dynamic>>(
        '/manifests/$manifestId/receive',
        data: payload,
        options: Options(
          headers: buildIdempotencyHeaders('manifest_receive_$manifestId'),
        ),
      );
      final data = response['data'] as Map<String, dynamic>;
      return Result.success(ManifestModel.fromJson(data));
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to submit manifest: $e');
    }
  }

  /// Mark a received manifest as processed.
  Future<Result<ManifestModel>> processManifest(String manifestId) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        '/manifests/$manifestId/process',
        options: Options(
          headers: buildIdempotencyHeaders('manifest_process_$manifestId'),
        ),
      );
      final data = response['data'] as Map<String, dynamic>;
      return Result.success(ManifestModel.fromJson(data));
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to process manifest: $e');
    }
  }

  /// Create a new inventory transfer.
  Future<Result<TransferModel>> createTransfer({
    required String fromType,
    required int fromId,
    required String toType,
    required int toId,
    required List<String> batteryIds,
    int? driverId,
  }) async {
    try {
      final normalizedBatteryIds = normalizeBatterySerials(batteryIds);
      if (normalizedBatteryIds.isEmpty) {
        return Result.failure('Select at least one battery');
      }

      final parsedBatteryIds = normalizedBatteryIds
          .map((id) => int.tryParse(id))
          .toList();
      if (parsedBatteryIds.any((id) => id == null || id <= 0)) {
        return Result.failure(
          'Transfer API expects numeric battery IDs. One or more selected batteries are invalid.',
        );
      }

      TransferModel? lastTransfer;
      for (final batteryId in parsedBatteryIds.whereType<int>()) {
        final payload = {
          'battery_id': batteryId,
          'from_location_type': fromType.trim().toLowerCase(),
          'from_location_id': fromId,
          'to_location_type': toType.trim().toLowerCase(),
          'to_location_id': toId,
          if (driverId != null) 'driver_id': driverId,
        };
        final data = await _api.post<Map<String, dynamic>>(
          '/inventory/transfers',
          data: payload,
          options: Options(
            headers: buildIdempotencyHeaders(
              'inventory_transfer_create_$batteryId',
            ),
          ),
        );
        lastTransfer = TransferModel.fromJson(data);
      }

      if (lastTransfer == null) {
        return Result.failure(
          'Transfer creation returned no response payload.',
        );
      }
      return Result.success(lastTransfer);
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to create transfer: $e');
    }
  }

  /// Fetch transfer history.
  Future<Result<List<TransferModel>>> fetchTransfers({
    String? status,
    int skip = 0,
    int limit = 100,
    int? locationId,
  }) async {
    try {
      if (skip < 0) {
        return Result.failure('skip must be >= 0');
      }
      if (limit <= 0 || limit > 500) {
        return Result.failure('limit must be between 1 and 500');
      }

      final normalizedStatus = _normalizeTransferStatus(status);
      if (status != null && normalizedStatus == null) {
        return Result.failure(
          "Invalid transfer status '$status'. Allowed: ${_validTransferStatuses.toList()..sort()}",
        );
      }

      final query = <String, dynamic>{
        'skip': skip,
        'limit': limit,
        'include_pagination': true,
        if (normalizedStatus != null) 'status': normalizedStatus,
        if (locationId != null) 'location_id': locationId,
      };
      final response = await _api.get<dynamic>(
        '/inventory/transfers',
        queryParameters: query,
      );
      final rawItems = _extractListPayload(response);
      final items = rawItems
          .whereType<Map>()
          .map(
            (e) => TransferModel.fromJson(
              e.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList();
      return Result.success(items);
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to fetch transfers: $e');
    }
  }

  String? _normalizeTransferStatus(String? rawStatus) {
    if (rawStatus == null) return null;
    final normalized = rawStatus
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    if (normalized.isEmpty) return null;
    if (!_validTransferStatuses.contains(normalized)) {
      return null;
    }
    return normalized;
  }

  /// Receive a transfer.
  Future<Result<TransferModel>> receiveTransfer(int transferId) async {
    try {
      final data = await _api.put<Map<String, dynamic>>(
        '/inventory/transfers/$transferId/confirm',
        options: Options(
          headers: buildIdempotencyHeaders(
            'inventory_transfer_receive_$transferId',
          ),
        ),
      );
      return Result.success(TransferModel.fromJson(data));
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to receive transfer: $e');
    }
  }

  /// Cancel an in-progress transfer, releasing batteries back to source.
  Future<Result<TransferModel>> cancelTransfer(int transferId) async {
    try {
      await _api.post<Map<String, dynamic>>(
        '/inventory/transfers/$transferId/cancel',
        options: Options(
          headers: buildIdempotencyHeaders(
            'inventory_transfer_cancel_$transferId',
          ),
        ),
      );
      final detail = await _api.get<Map<String, dynamic>>(
        '/inventory/transfers/$transferId',
      );
      return Result.success(TransferModel.fromJson(detail));
    } on ApiException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 405) {
        return Result.failure(
          'Transfer cancel is not supported by the current backend API.',
        );
      }
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to cancel transfer: $e');
    }
  }

  /// Submit reconciliation data.
  Future<Result<bool>> reconcileInventory({
    required String locationType,
    required int locationId,
    required int physicalCount,
    required List<String> scannedIds,
    String? notes,
  }) async {
    try {
      final payload = {
        'location_type': locationType,
        'location_id': locationId,
        'physical_count': physicalCount,
        'scanned_battery_ids': normalizeBatterySerials(scannedIds),
        'notes': notes,
      };
      await _api.post<Map<String, dynamic>>(
        '/inventory/reconcile',
        data: payload,
        options: Options(
          headers: buildIdempotencyHeaders(
            'inventory_reconcile_${locationType}_$locationId',
          ),
        ),
      );
      return Result.success(true);
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to reconcile: $e');
    }
  }

  Future<Result<TransferLocationData>> fetchTransferLocationData() async {
    try {
      final warehousesResult = await fetchActiveWarehouses();
      if (warehousesResult.isFailure) {
        return Result.failure(
          warehousesResult.error ?? 'Failed to load warehouses',
        );
      }
      final warehouses =
          warehousesResult.dataOrNull ?? const <TransferWarehouse>[];
      if (warehouses.isEmpty) {
        return Result.failure('No active warehouse configured');
      }

      final stationsResponse = await _api.get<dynamic>(
        '/stations/',
        queryParameters: {'skip': 0, 'limit': 200, 'include_pagination': true},
      );
      final destinations = _extractListPayload(stationsResponse)
          .whereType<Map<String, dynamic>>()
          .where((station) {
            final status = (station['status'] as String?)?.toLowerCase();
            return status == null || status == 'active';
          })
          .map((station) {
            final id = station['id'];
            final name = station['name'];
            if (id is int && name is String && name.trim().isNotEmpty) {
              return TransferDestination(id: id, name: name.trim());
            }
            return null;
          })
          .whereType<TransferDestination>()
          .toList();

      return Result.success(
        TransferLocationData(
          warehouses: warehouses,
          destinations: destinations,
        ),
      );
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to load transfer locations: $e');
    }
  }

  Future<Result<List<TransferWarehouse>>> fetchActiveWarehouses() async {
    try {
      try {
        final response = await _api.get<Map<String, dynamic>>(
          '/warehouse/all',
          queryParameters: {'active_only': true},
        );
        final data = response['data'];
        if (data is List) {
          final warehouses = data
              .whereType<Map<String, dynamic>>()
              .map((warehouse) {
                final id = warehouse['id'];
                if (id is! int) return null;
                final rawName = warehouse['name'] as String?;
                final name = (rawName?.trim().isNotEmpty ?? false)
                    ? rawName!.trim()
                    : 'Warehouse #$id';
                return TransferWarehouse(id: id, name: name);
              })
              .whereType<TransferWarehouse>()
              .toList();

          warehouses.sort((a, b) => a.name.compareTo(b.name));
          if (warehouses.isNotEmpty) {
            return Result.success(warehouses);
          }
        }
      } on ApiException {
        // Backward-compatible fallback for single-warehouse backends.
      }

      final singleResponse = await _api.get<Map<String, dynamic>>(
        '/warehouse/',
      );
      final singleData = singleResponse['data'] as Map<String, dynamic>?;
      if (singleData == null) {
        return Result.failure('No active warehouse configured');
      }

      final id = singleData['id'];
      if (id is! int) {
        return Result.failure('Invalid warehouse response: missing id');
      }
      final rawName = singleData['name'] as String?;
      final name = (rawName?.trim().isNotEmpty ?? false)
          ? rawName!.trim()
          : 'Warehouse #$id';
      return Result.success([TransferWarehouse(id: id, name: name)]);
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to load warehouses: $e');
    }
  }

  List<dynamic> _extractListPayload(dynamic payload) {
    dynamic root = payload;
    for (var depth = 0; depth < 4; depth++) {
      if (root is List) return root;
      final mapPayload = _asStringKeyedMap(root);
      if (mapPayload == null) return const <dynamic>[];

      for (final key in const [
        'data',
        'items',
        'batteries',
        'drivers',
        'transfers',
        'orders',
        'stations',
        'results',
        'records',
        'rows',
      ]) {
        final candidate = mapPayload[key];
        if (candidate is List) return candidate;
      }

      root =
          mapPayload['data'] ??
          mapPayload['items'] ??
          mapPayload['results'] ??
          mapPayload['records'];
    }
    return const <dynamic>[];
  }

  Map<String, dynamic>? _asStringKeyedMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }
}
