import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_spacing.dart';
import '../../../config/app_text_styles.dart';
import '../../../widgets/app_card.dart';
import '../../../models/warehouse_model.dart';

class ShelfWidget extends StatelessWidget {
  final ShelfModel shelf;
  final VoidCallback? onTap;

  const ShelfWidget({
    super.key,
    required this.shelf,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: _getBackgroundColor(context),
      borderRadius: BorderRadius.circular(4),
      borderColor: _getBorderColor(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            shelf.name,
            style: AppTextStyles.labelSmall.copyWith(
              color: _getTextColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              '${shelf.batteryIds.length}/${shelf.capacity}',
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: _getTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (shelf.status) {
      case ShelfStatus.empty:
        return (isDark ? AppColors.success : AppColors.success).withValues(alpha: 0.15);
      case ShelfStatus.partial:
        return (isDark ? AppColors.warning : AppColors.warning).withValues(alpha: 0.15);
      case ShelfStatus.full:
        return (isDark ? AppColors.error : AppColors.error).withValues(alpha: 0.15);
    }
  }

  Color _getBorderColor(BuildContext context) {
    switch (shelf.status) {
      case ShelfStatus.empty:
        return AppColors.success;
      case ShelfStatus.partial:
        return AppColors.warning;
      case ShelfStatus.full:
        return AppColors.error;
    }
  }

  Color _getTextColor(BuildContext context) {
    // For now, using standard text color or could match border
    return Theme.of(context).textTheme.bodySmall!.color!;
  }
}
