import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/base_notifier.dart';
import '../../../core/providers.dart';
import '../../../core/result.dart';
import '../../../models/warehouse_model.dart';
import '../repository/warehouse_repository.dart';

final warehouseRepositoryProvider = Provider<WarehouseRepository>((ref) {
  return WarehouseRepository(api: ref.read(apiClientProvider));
});

/// Exposes the current state of the warehouse.
final warehouseGraphProvider =
    StateNotifierProvider<WarehouseGraphNotifier, AsyncState<WarehouseModel>>((
      ref,
    ) {
      return WarehouseGraphNotifier(ref.read(warehouseRepositoryProvider));
    });

class WarehouseGraphNotifier extends BaseNotifier<WarehouseModel> {
  final WarehouseRepository _repository;

  WarehouseGraphNotifier(this._repository) {
    loadWarehouse();
  }

  Future<void> loadWarehouse({
    int? preferredWarehouseId,
    String? batterySerialHint,
  }) async {
    execute(
      () => _repository.getWarehouseLayout(
        preferredWarehouseId: preferredWarehouseId,
        batterySerialHint: batterySerialHint,
      ),
    );
  }

  /// Optimistically move battery between shelves.
  Future<void> moveBattery({
    required String batteryId,
    required String fromShelfId,
    required String toShelfId,
  }) async {
    // 1. Optimistic Update
    final currentState = state;
    if (currentState is! AsyncLoaded<WarehouseModel>) return;

    final oldModel = currentState.data;

    // Create new model with moved battery
    final newModel = _moveBatteryInModel(
      oldModel,
      batteryId,
      fromShelfId,
      toShelfId,
    );

    state = AsyncLoaded(newModel);

    // 2. Server Call
    final result = await _repository.moveBattery(
      batteryId: batteryId,
      fromShelfId: fromShelfId,
      toShelfId: toShelfId,
    );

    // 3. Rollback on Failure
    if (result is Failure) {
      state = AsyncLoaded(oldModel);
      // Ideally show error toast here or through a separate error provider
    }
  }

  WarehouseModel _moveBatteryInModel(
    WarehouseModel model,
    String batteryId,
    String fromShelfId,
    String toShelfId,
  ) {
    // Deep copy logic to update the specific shelves
    // This can be complex with immutable structures; often cleaner to just reload
    // but for smooth UX we try to patch.

    return model.copyWith(
      racks: model.racks.map((rack) {
        // If rack doesn't contain either shelf, return as is
        final containsSource = rack.shelves.any((s) => s.id == fromShelfId);
        final containsDest = rack.shelves.any((s) => s.id == toShelfId);

        if (!containsSource && !containsDest) return rack;

        return rack.copyWith(
          shelves: rack.shelves.map((shelf) {
            if (shelf.id == fromShelfId) {
              return shelf.copyWith(
                batteryIds: shelf.batteryIds
                    .where((id) => id != batteryId)
                    .toList(),
              );
            }
            if (shelf.id == toShelfId) {
              return shelf.copyWith(
                batteryIds: [...shelf.batteryIds, batteryId],
              );
            }
            return shelf;
          }).toList(),
        );
      }).toList(),
    );
  }
}
