import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_spacing.dart';
import '../../../models/warehouse_model.dart';
import '../../../widgets/app_loader.dart';
import '../providers/warehouse_providers.dart';
import 'warehouse_grid.dart';

class WarehouseView extends ConsumerWidget {
  const WarehouseView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehouseState = ref.watch(warehouseGraphProvider);

    return warehouseState.when(
      initial: () => const Center(child: AppLoader()),
      loading: () => const Center(child: AppLoader()),
      loaded: (warehouse) => Column(
        children: [
          _buildLegend(context),
          Expanded(
            child: WarehouseGrid(
              warehouse: warehouse,
              onShelfTap: (shelf) => _showShelfDetails(context, shelf),
            ),
          ),
        ],
      ),
      error: (msg) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            AppSpacing.gapH16,
            Text('Failed to load warehouse layout: $msg', style: Theme.of(context).textTheme.bodyMedium),
            AppSpacing.gapH8,
            TextButton(
              onPressed: () => ref.refresh(warehouseGraphProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendItem(color: AppColors.success, label: 'Empty'),
          AppSpacing.gapW16,
          _LegendItem(color: AppColors.warning, label: 'Partial'),
          AppSpacing.gapW16,
          _LegendItem(color: AppColors.error, label: 'Full'),
        ],
      ),
    );
  }

  void _showShelfDetails(BuildContext context, ShelfModel shelf) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ShelfDetailSheet(shelf: shelf),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        AppSpacing.gapW8,
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

// Temporary placeholder for the detail sheet
class _ShelfDetailSheet extends StatelessWidget {
  final ShelfModel shelf;

  const _ShelfDetailSheet({required this.shelf});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shelf ${shelf.name}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          AppSpacing.gapH8,
          Text(
            'Capacity: ${shelf.batteryIds.length}/${shelf.capacity}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Divider(height: 32),
          if (shelf.batteryIds.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No batteries in this shelf')),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: shelf.batteryIds.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.battery_std),
                  title: Text(shelf.batteryIds[index]),
                  trailing: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement move
                    },
                    child: const Text('Move'),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
