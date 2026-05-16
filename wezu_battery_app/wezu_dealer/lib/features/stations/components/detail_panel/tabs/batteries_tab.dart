import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../../core/theme/colors.dart';
import '../../../models/station_state.dart';

class BatteriesTab extends StatelessWidget {
  final List<BatteryDto> batteries;

  const BatteriesTab({
    super.key,
    required this.batteries,
  });

  @override
  Widget build(BuildContext context) {
    if (batteries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.battery, size: 48, color: AppColors.textTertiary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text('No batteries found in this station.', 
              style: TextStyle(color: AppColors.textTertiary, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: batteries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final b = batteries[index];
        return _BatteryItem(battery: b);
      },
    );
  }
}

class _BatteryItem extends StatelessWidget {
  final BatteryDto battery;

  const _BatteryItem({required this.battery});

  @override
  Widget build(BuildContext context) {
    final healthColor = battery.healthPercentage >= 90
        ? AppColors.primary
        : battery.healthPercentage >= 70
            ? AppColors.amber
            : AppColors.red;
    final healthLabel = battery.healthPercentage >= 90
        ? 'GOOD'
        : battery.healthPercentage >= 70
            ? 'DEGRADED'
            : 'POOR';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pageBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Icon & Slot
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(LucideIcons.battery, 
                size: 32, 
                color: _getChargeColor(battery.chargePercentage).withValues(alpha: 0.2)),
              Text('#${battery.id}', 
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(width: 16),

          // Battery Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(battery.serialNumber, 
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: healthColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(healthLabel,
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: healthColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CHARGE', style: TextStyle(fontSize: 9, color: AppColors.textTertiary)),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: battery.chargePercentage / 100,
                            minHeight: 4,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation(_getChargeColor(battery.chargePercentage)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('HEALTH', style: TextStyle(fontSize: 9, color: AppColors.textTertiary)),
                        const SizedBox(height: 2),
                        Text('${battery.healthPercentage.toStringAsFixed(0)}%', 
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CYCLES', style: TextStyle(fontSize: 9, color: AppColors.textTertiary)),
                        const SizedBox(height: 2),
                        Text('${battery.cycleCount}', 
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  Color _getChargeColor(double charge) {
    if (charge > 80) return AppColors.primary;
    if (charge > 20) return AppColors.amber;
    return AppColors.red;
  }
}
