import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result.dart';
import '../../../../models/manifest_model.dart';
import '../../../../utils/battery_identity.dart';
import '../../repository/inventory_repository.dart';
import '../../repository/warehouse_repository.dart';
import '../../providers/inventory_providers.dart';
import '../../providers/warehouse_providers.dart';

class ReceiveStockState {
  final bool isLoading;
  final ManifestModel? manifest;
  final String? error;
  final List<TransferWarehouse> availableWarehouses;
  final int? selectedWarehouseId;

  const ReceiveStockState({
    this.isLoading = false,
    this.manifest,
    this.error,
    this.availableWarehouses = const [],
    this.selectedWarehouseId,
  });

  ReceiveStockState copyWith({
    bool? isLoading,
    ManifestModel? manifest,
    String? error,
    List<TransferWarehouse>? availableWarehouses,
    int? selectedWarehouseId,
    bool clearManifest = false,
    bool clearError = false,
    bool clearWarehouses = false,
    bool clearSelectedWarehouse = false,
  }) {
    return ReceiveStockState(
      isLoading: isLoading ?? this.isLoading,
      manifest: clearManifest ? null : (manifest ?? this.manifest),
      error: clearError ? null : (error ?? this.error),
      availableWarehouses: clearWarehouses
          ? const []
          : (availableWarehouses ?? this.availableWarehouses),
      selectedWarehouseId: clearSelectedWarehouse
          ? null
          : (selectedWarehouseId ?? this.selectedWarehouseId),
    );
  }
}

class ReceiveStockNotifier extends StateNotifier<ReceiveStockState> {
  final InventoryRepository _repository;
  final WarehouseRepository _warehouseRepository;

  ReceiveStockNotifier(this._repository, this._warehouseRepository)
    : super(const ReceiveStockState());

  Future<void> loadManifest(String manifestId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.fetchManifest(manifestId);

    if (result.isFailure) {
      state = state.copyWith(isLoading: false, error: result.error);
      return;
    }

    final manifest = result.dataOrNull;
    if (manifest == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Manifest payload is empty',
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      manifest: manifest,
      clearError: true,
    );
    await _loadReceivingWarehouses();
  }

  Future<void> scanCode(String code) async {
    final normalizedCode = code.trim();
    if (normalizedCode.isEmpty) return;

    // 1. If no manifest loaded, try to load as manifest
    if (state.manifest == null) {
      await loadManifest(normalizedCode);
      return;
    }

    // 2. If manifest loaded, treat as battery ID
    _processBatteryScan(normalizedCode);
  }

  void _processBatteryScan(String batteryId) {
    if (state.manifest == null) return;

    final items = List<ManifestItem>.from(state.manifest!.items);
    final normalizedId = normalizeBatterySerial(batteryId);
    final index = items.indexWhere(
      (item) => normalizeBatterySerial(item.batteryId) == normalizedId,
    );

    if (index != -1) {
      // Expected item
      final item = items[index];
      if (item.status == ManifestItemStatus.pending ||
          item.status == ManifestItemStatus.missing) {
        items[index] = item.copyWith(status: ManifestItemStatus.scanned);
        state = state.copyWith(
          manifest: state.manifest!.copyWith(items: items),
        );
      } else {
        // Already scanned or other status
        // TODO: Handle user feedback
      }
    } else {
      // Extra item
      // Check if already in extras
      final extraIndex = items.indexWhere(
        (item) =>
            normalizeBatterySerial(item.batteryId) == normalizedId &&
            item.status == ManifestItemStatus.extra,
      );
      if (extraIndex == -1) {
        items.add(
          ManifestItem(
            batteryId: normalizedId,
            type: 'Unknown', // Could fetch details if needed
            status: ManifestItemStatus.extra,
          ),
        );
        state = state.copyWith(
          manifest: state.manifest!.copyWith(items: items),
        );
      }
    }
  }

  // Assign Location
  void assignLocation(String batteryId, String location) {
    if (state.manifest == null) return;

    final items = List<ManifestItem>.from(state.manifest!.items);
    final normalizedBatteryId = normalizeBatterySerial(batteryId);
    final index = items.indexWhere(
      (item) => normalizeBatterySerial(item.batteryId) == normalizedBatteryId,
    );

    if (index != -1) {
      items[index] = items[index].copyWith(assignedLocation: location);
      state = state.copyWith(manifest: state.manifest!.copyWith(items: items));
    }
  }

  // Report Damage
  void reportDamage(String batteryId, String report, {String? imagePath}) {
    if (state.manifest == null) return;

    final items = List<ManifestItem>.from(state.manifest!.items);
    final normalizedBatteryId = normalizeBatterySerial(batteryId);
    final index = items.indexWhere(
      (item) => normalizeBatterySerial(item.batteryId) == normalizedBatteryId,
    );

    if (index != -1) {
      items[index] = items[index].copyWith(
        status: ManifestItemStatus.damaged,
        damageReport: report,
        damagePhotoPath: imagePath,
      );
      state = state.copyWith(manifest: state.manifest!.copyWith(items: items));
    }
  }

  void reset() {
    state = const ReceiveStockState();
  }

  Future<void> _loadReceivingWarehouses() async {
    final result = await _repository.fetchActiveWarehouses();
    if (result.isFailure) {
      state = state.copyWith(
        availableWarehouses: const [],
        clearSelectedWarehouse: true,
        clearError: true,
      );
      return;
    }

    final warehouses = result.dataOrNull ?? const <TransferWarehouse>[];
    int? selectedWarehouseId = state.selectedWarehouseId;
    if (!warehouses.any((warehouse) => warehouse.id == selectedWarehouseId)) {
      selectedWarehouseId = warehouses.length == 1 ? warehouses.first.id : null;
    }

    state = state.copyWith(
      availableWarehouses: warehouses,
      selectedWarehouseId: selectedWarehouseId,
      clearError: true,
    );
  }

  void selectWarehouse(int? warehouseId) {
    final previousWarehouseId = state.selectedWarehouseId;
    if (previousWarehouseId == warehouseId) {
      state = state.copyWith(
        selectedWarehouseId: warehouseId,
        clearError: true,
      );
      return;
    }

    final manifest = state.manifest;
    if (manifest == null) {
      state = state.copyWith(
        selectedWarehouseId: warehouseId,
        clearError: true,
      );
      return;
    }

    final clearedItems = manifest.items
        .map((item) => item.copyWith(assignedLocation: null))
        .toList();
    state = state.copyWith(
      selectedWarehouseId: warehouseId,
      manifest: manifest.copyWith(items: clearedItems),
      clearError: true,
    );
  }

  Future<Result<ManifestModel>> submitManifest() async {
    final manifest = state.manifest;
    if (manifest == null) {
      const message = 'No manifest loaded';
      state = state.copyWith(error: message, clearManifest: false);
      return Result.failure(message);
    }
    if (state.availableWarehouses.length > 1 &&
        state.selectedWarehouseId == null) {
      const message = 'Select a receiving warehouse before submitting';
      state = state.copyWith(error: message, clearManifest: false);
      return Result.failure(message);
    }

    final resolvedWarehouseId =
        state.selectedWarehouseId ??
        (state.availableWarehouses.length == 1
            ? state.availableWarehouses.first.id
            : null);

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final itemsPayload = manifest.items
          .where(
            (item) =>
                item.status == ManifestItemStatus.scanned ||
                item.status == ManifestItemStatus.damaged ||
                item.status == ManifestItemStatus.missing ||
                item.status == ManifestItemStatus.extra,
          )
          .map((item) {
            return {
              'battery_id': normalizeBatterySerial(item.batteryId),
              'status': item.status.name, // e.g., 'scanned', 'damaged'
              'damage_report': item.damageReport,
              'damage_photo_path': item.damagePhotoPath,
            };
          })
          .toList();

      final result = await _repository.submitManifest(
        manifest.id,
        itemsPayload,
        warehouseId: resolvedWarehouseId,
      );

      if (result.isFailure) {
        final message = result.error ?? 'Failed to submit manifest';
        state = state.copyWith(isLoading: false, error: message);
        return Result.failure(message);
      }

      final updatedManifest = result.dataOrNull;
      if (updatedManifest == null) {
        const message = 'Manifest submission returned an empty response';
        state = state.copyWith(isLoading: false, error: message);
        return Result.failure(message);
      }

      final mergedManifest = _mergeAssignedLocations(
        submittedManifest: manifest,
        apiManifest: updatedManifest,
      );
      final assignmentResult = await _applyShelfAssignments(mergedManifest);
      if (assignmentResult.isFailure) {
        final message =
            assignmentResult.error ?? 'Failed to assign shelf locations';
        state = state.copyWith(
          isLoading: false,
          manifest: mergedManifest,
          error: message,
        );
        return Result.failure(message);
      }

      var finalManifest = mergedManifest;
      if (_canProcessManifest(mergedManifest)) {
        final processResult = await _repository.processManifest(
          mergedManifest.id,
        );
        if (processResult.isFailure) {
          final message =
              processResult.error ??
              'Manifest received but failed to mark as processed';
          state = state.copyWith(
            isLoading: false,
            manifest: mergedManifest,
            error: message,
          );
          return Result.failure(message);
        }

        final processedManifest = processResult.dataOrNull;
        if (processedManifest != null) {
          finalManifest = _mergeAssignedLocations(
            submittedManifest: mergedManifest,
            apiManifest: processedManifest,
          );
        }
      }

      state = state.copyWith(
        isLoading: false,
        manifest: finalManifest,
        clearError: true,
      );
      return Result.success(finalManifest);
    } catch (e) {
      final message = 'Submission failed: $e';
      state = state.copyWith(isLoading: false, error: message);
      return Result.failure(message);
    }
  }

  ManifestModel _mergeAssignedLocations({
    required ManifestModel submittedManifest,
    required ManifestModel apiManifest,
  }) {
    final assignedBySerial = <String, String>{};
    for (final item in submittedManifest.items) {
      final assignedLocation = item.assignedLocation?.trim();
      if (assignedLocation == null || assignedLocation.isEmpty) {
        continue;
      }
      assignedBySerial[normalizeBatterySerial(item.batteryId)] =
          assignedLocation;
    }

    if (assignedBySerial.isEmpty) {
      return apiManifest;
    }

    final mergedItems = apiManifest.items.map((item) {
      final normalizedSerial = normalizeBatterySerial(item.batteryId);
      final assignedLocation = assignedBySerial[normalizedSerial];
      if (assignedLocation == null) {
        return item;
      }
      return item.copyWith(assignedLocation: assignedLocation);
    }).toList();

    return apiManifest.copyWith(items: mergedItems);
  }

  Future<Result<void>> _applyShelfAssignments(ManifestModel manifest) async {
    final assignmentFailures = <String>[];

    for (final item in manifest.items) {
      final assignedLocation = item.assignedLocation?.trim();
      if (assignedLocation == null || assignedLocation.isEmpty) continue;
      if (!_isShelfAssignableStatus(item.status)) continue;

      final result = await _warehouseRepository.assignBatteryToShelf(
        batteryId: normalizeBatterySerial(item.batteryId),
        shelfId: assignedLocation,
      );
      if (result.isFailure) {
        assignmentFailures.add(
          '${normalizeBatterySerial(item.batteryId)} -> shelf #$assignedLocation: '
          '${result.error ?? 'unknown error'}',
        );
      }
    }

    if (assignmentFailures.isEmpty) {
      return Result.success(null);
    }

    final preview = assignmentFailures.take(3).join('; ');
    final message = assignmentFailures.length > 3
        ? 'Manifest received, but ${assignmentFailures.length} shelf assignments failed. '
              '$preview ...'
        : 'Manifest received, but shelf assignment failed: $preview';
    return Result.failure(message);
  }

  bool _isShelfAssignableStatus(ManifestItemStatus status) {
    return status == ManifestItemStatus.scanned ||
        status == ManifestItemStatus.extra ||
        status == ManifestItemStatus.damaged;
  }

  bool _canProcessManifest(ManifestModel manifest) {
    final normalizedStatus = manifest.status.trim().toLowerCase().replaceAll(
      '_',
      ' ',
    );
    if (normalizedStatus != 'received') {
      return false;
    }

    return !manifest.items.any(
      (item) =>
          item.status == ManifestItemStatus.pending ||
          item.status == ManifestItemStatus.missing,
    );
  }
}

final receiveStockProvider =
    StateNotifierProvider<ReceiveStockNotifier, ReceiveStockState>((ref) {
      final repository = ref.read(inventoryRepositoryProvider);
      final warehouseRepository = ref.read(warehouseRepositoryProvider);
      return ReceiveStockNotifier(repository, warehouseRepository);
    });
