import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_spacing.dart';
import '../../../widgets/app_card.dart';
import '../../../config/app_text_styles.dart';

class InventorySummaryCards extends StatelessWidget {
  final Map<String, int> stats;

  const InventorySummaryCards({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          _SummaryCard(
            label: 'Total',
            count: stats['total'] ?? 0,
            color: AppColors.primary,
            icon: Icons.inventory_2_outlined,
          ),
          AppSpacing.gapW12,
          _SummaryCard(
            label: 'Ready',
            count: stats['available'] ?? 0,
            color: AppColors.success,
            icon: Icons.check_circle_outline_rounded,
          ),
          AppSpacing.gapW12,
          _SummaryCard(
            label: 'Charging',
            count: stats['charging'] ?? 0,
            color: AppColors.warning,
            icon: Icons.battery_charging_full_rounded,
          ),
          AppSpacing.gapW12,
          _SummaryCard(
            label: 'Faulty',
            count: stats['faulty'] ?? 0,
            color: AppColors.error,
            icon: Icons.report_problem_outlined,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: 110,
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(16),
      borderColor: Theme.of(context).brightness == Brightness.light
          ? AppColors.border
          : AppColors.borderDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          AppSpacing.gapH12,
          Text(
            count.toString(),
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
