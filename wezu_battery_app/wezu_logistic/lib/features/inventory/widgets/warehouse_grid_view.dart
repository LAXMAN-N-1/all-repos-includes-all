import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_text_styles.dart';
import '../../../../models/warehouse_model.dart';

class WarehouseGridView extends StatelessWidget {
  final WarehouseModel warehouse;
  final Function(String locationId)? onLocationSelected;

  const WarehouseGridView({
    super.key,
    required this.warehouse,
    this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Warehouse Map: ${warehouse.name}',
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: warehouse.racks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final rack = warehouse.racks[index];
              return _buildRackSection(context, rack);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRackSection(BuildContext context, RackModel rack) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rack ${rack.name}',
          style: AppTextStyles.labelLarge.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 100, // Ensure min width
            childAspectRatio: 1.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: rack.shelves.length,
          itemBuilder: (context, index) {
            final shelf = rack.shelves[index];
            return _buildShelfCard(context, shelf);
          },
        ),
      ],
    );
  }

  Widget _buildShelfCard(BuildContext context, ShelfModel shelf) {
    final occupancyColor = _getOccupancyColor(shelf);
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: () => onLocationSelected?.call(shelf.id),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: occupancyColor.withValues(alpha: 0.4), // Use withValues for compatibility
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              shelf.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${shelf.batteryIds.length}/${shelf.capacity}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: occupancyColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getOccupancyColor(ShelfModel shelf) {
    if (shelf.status == ShelfStatus.full) return AppColors.error;
    if (shelf.occupancyPercentage > 0.75) return AppColors.warning;
    if (shelf.occupancyPercentage > 0) return AppColors.success;
    return AppColors.textHint;
  }
}
