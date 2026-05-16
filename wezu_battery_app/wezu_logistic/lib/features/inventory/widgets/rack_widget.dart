import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_spacing.dart';
import '../../../config/app_text_styles.dart';
import '../../../../widgets/app_card.dart';
import '../../../models/warehouse_model.dart';
import 'shelf_widget.dart';

class RackWidget extends StatelessWidget {
  final RackModel rack;
  final Function(ShelfModel) onShelfTap;

  const RackWidget({
    super.key,
    required this.rack,
    required this.onShelfTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: 140, // Fixed width for rack
      margin: const EdgeInsets.only(right: 16),
      padding: EdgeInsets.zero,
      borderColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.border
              : AppColors.borderDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Text(
              rack.name,
              style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Shelves
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: rack.shelves.map((shelf) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: ShelfWidget(
                    shelf: shelf,
                    onTap: () => onShelfTap(shelf),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Footer / Capacity Summary
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Text(
              '${rack.currentCount}/${rack.totalCapacity} Batteries',
              style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
