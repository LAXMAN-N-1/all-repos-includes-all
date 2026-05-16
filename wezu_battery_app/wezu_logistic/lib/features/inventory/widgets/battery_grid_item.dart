import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_spacing.dart';
import '../../../config/app_text_styles.dart';
import '../../../models/battery_model.dart';
import '../utils/battery_status_style.dart';
import '../../../widgets/app_card.dart';

class BatteryGridItem extends StatelessWidget {
  const BatteryGridItem({super.key, required this.battery, this.onTap});

  final BatteryModel battery;
  final VoidCallback? onTap;

  Color get _chargeColor {
    if (battery.chargePercentage >= 80) return AppColors.batteryFull;
    if (battery.chargePercentage >= 40) return AppColors.batteryMedium;
    if (battery.chargePercentage >= 20) return AppColors.batteryLow;
    return AppColors.batteryCritical;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = BatteryStatusStyle.foreground(battery.status);
    final statusBgColor = BatteryStatusStyle.background(
      context,
      battery.status,
    );

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  battery.status.label,
                  style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
              Icon(
                battery.status == BatteryStatus.charging
                    ? Icons.bolt_rounded
                    : Icons.battery_std_rounded,
                color: statusColor,
                size: 20,
              ),
            ],
          ),
          AppSpacing.gapH12,
          Hero(
            tag: 'battery_id_${battery.id}',
            child: Text(
              battery.id,
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            battery.model,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          // Charge Level
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: battery.chargePercentage / 100,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                        ? AppColors.surfaceVariant
                        : AppColors.surfaceVariantDark,
                    valueColor: AlwaysStoppedAnimation(_chargeColor),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${battery.chargePercentage}%',
                style: AppTextStyles.caption.copyWith(
                  color: _chargeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.gapH8,
          // Location & Time (Compact)
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 12,
                color: AppColors.textHint,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  battery.location ?? 'Unknown',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textHint,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
