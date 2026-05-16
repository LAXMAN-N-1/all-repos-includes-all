import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_spacing.dart';
import '../../../../config/app_text_styles.dart';
import '../../../../utils/app_haptics.dart';
import '../../../../widgets/app_card.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({
    super.key,
    required this.onReceiveStock,
    required this.onDispatchStock,
    required this.onViewInventory,
    required this.onGenerateReport,
    required this.onScanQR,
  });

  final VoidCallback onReceiveStock;
  final VoidCallback onDispatchStock;
  final VoidCallback onViewInventory;
  final VoidCallback onGenerateReport;
  final VoidCallback onScanQR;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.gapH12,
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: 'Receive\nStock',
                icon: Icons.inventory_2_rounded,
                color: AppColors.primary,
                onTap: onReceiveStock,
              ),
            ),
            AppSpacing.gapW16,
            Expanded(
              child: _ActionButton(
                label: 'Dispatch\nStock',
                icon: Icons.local_shipping_rounded,
                color: AppColors.warning,
                onTap: onDispatchStock,
              ),
            ),
            AppSpacing.gapW16,
            Expanded(
              child: _ActionButton(
                label: 'Scan\nQR Code',
                icon: Icons.qr_code_scanner_rounded,
                color: AppColors.info,
                onTap: onScanQR,
              ),
            ),
          ],
        ),
        AppSpacing.gapH12,
        Row(
          children: [
            Expanded(
              child: _ActionChip(
                label: 'View All Inventory',
                icon: Icons.warehouse_rounded,
                onTap: onViewInventory,
              ),
            ),
            AppSpacing.gapW16,
            Expanded(
              child: _ActionChip(
                label: 'Generate Report',
                icon: Icons.analytics_outlined,
                onTap: onGenerateReport,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isPrimary = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      color: isPrimary ? color : (isDark ? theme.cardColor : null),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          AppSpacing.gapH12,
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium.copyWith(
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          AppSpacing.gapW8,
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
