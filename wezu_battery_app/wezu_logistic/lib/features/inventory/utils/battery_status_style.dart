import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';
import '../../../models/battery_model.dart';

class BatteryStatusStyle {
  const BatteryStatusStyle._();

  static Color foreground(BatteryStatus status) {
    switch (status) {
      case BatteryStatus.available:
      case BatteryStatus.newBattery:
        return AppColors.success;
      case BatteryStatus.deployed:
      case BatteryStatus.inTransit:
        return AppColors.info;
      case BatteryStatus.charging:
        return AppColors.warning;
      case BatteryStatus.faulty:
        return AppColors.error;
      case BatteryStatus.maintenance:
      case BatteryStatus.retired:
        return AppColors.textSecondary;
      case BatteryStatus.reserved:
        return AppColors.primary;
    }
  }

  static Color background(BuildContext context, BatteryStatus status) {
    final color = foreground(status);
    if (Theme.of(context).brightness == Brightness.dark) {
      return color.withValues(alpha: 0.15);
    }
    switch (status) {
      case BatteryStatus.available:
      case BatteryStatus.newBattery:
        return AppColors.successLight;
      case BatteryStatus.deployed:
      case BatteryStatus.inTransit:
        return AppColors.infoLight;
      case BatteryStatus.charging:
        return AppColors.warningLight;
      case BatteryStatus.faulty:
        return AppColors.errorLight;
      case BatteryStatus.maintenance:
      case BatteryStatus.retired:
      case BatteryStatus.reserved:
        return AppColors.surfaceVariant;
    }
  }
}
