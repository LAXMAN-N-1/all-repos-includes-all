import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/colors.dart';
import '../providers/inventory_provider.dart';
import 'asset_deep_dive_view.dart';

/// Zone 5 — Smart Right Panel (30% Pane)
/// Two states: Fleet Intelligence (default) and Asset Deep-Dive (row selected).
class SmartRightPanel extends ConsumerWidget {
  final VoidCallback? onRequestStock;
  const SmartRightPanel({super.key, this.onRequestStock});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBattery = ref.watch(selectedBatteryProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: selectedBattery == null
            ? _FleetIntelligencePanel(
                key: const ValueKey('fleet-intel'),
                onRequestStock: onRequestStock,
              )
            : AssetDeepDiveView(
                key: ValueKey('deep-dive-${selectedBattery.batteryId}'),
                battery: selectedBattery,
              ),
      ),
    );
  }
}

/// Fleet Intelligence State — Default panel when no row is selected
class _FleetIntelligencePanel extends ConsumerWidget {
  final VoidCallback? onRequestStock;
  const _FleetIntelligencePanel({super.key, this.onRequestStock});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsState = ref.watch(inventoryMetricsProvider);
    final m = metricsState.data;
    final batteries = ref.watch(inventoryBatteriesProvider);

    // Compute health distribution from loaded batteries
    int excellent = 0, good = 0, fair = 0, poor = 0;
    for (final b in batteries.items) {
      final hp = b.health.percentage;
      if (hp >= 90) {
        excellent++;
      } else if (hp >= 70) {
        good++;
      } else if (hp >= 50) {
        fair++;
      } else {
        poor++;
      }
    }
    final total = excellent + good + fair + poor;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Title
        const Text(
          'Fleet Intelligence',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Overview of your fleet health and predictive analytics',
          style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 20),

        // FI-1: Fleet Health Donut Chart
        Center(
          child: SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: total == 0
                        ? [
                            PieChartSectionData(
                              value: 1,
                              color: AppColors.border,
                              radius: 14,
                              showTitle: false,
                            ),
                          ]
                        : [
                            if (excellent > 0)
                              PieChartSectionData(
                                value: excellent.toDouble(),
                                color: AppColors.primary,
                                radius: 14,
                                showTitle: false,
                              ),
                            if (good > 0)
                              PieChartSectionData(
                                value: good.toDouble(),
                                color: AppColors.cyan,
                                radius: 14,
                                showTitle: false,
                              ),
                            if (fair > 0)
                              PieChartSectionData(
                                value: fair.toDouble(),
                                color: AppColors.amber,
                                radius: 14,
                                showTitle: false,
                              ),
                            if (poor > 0)
                              PieChartSectionData(
                                value: poor.toDouble(),
                                color: AppColors.red,
                                radius: 14,
                                showTitle: false,
                              ),
                          ],
                    centerSpaceRadius: 42,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: AppColors.primary, label: 'Good $excellent'),
            const SizedBox(width: 10),
            _LegendDot(color: AppColors.amber, label: 'Fair $fair'),
            const SizedBox(width: 10),
            _LegendDot(color: AppColors.red, label: 'Poor $poor'),
          ],
        ),
        const SizedBox(height: 24),

        // FI-2: Predictive Maintenance Alert
        _IntelCard(
          borderColor: AppColors.amber,
          icon: LucideIcons.alertTriangle,
          iconColor: AppColors.amber,
          title:
              '${m.maintenance} batteries may need maintenance',
          subtitle:
              'Based on health degradation trends and cycle counts',
          actionLabel: 'View affected',
          onAction: () {
            ref.read(inventoryBatteriesProvider.notifier).setFilter('maintenance');
          },
        ),
        const SizedBox(height: 12),

        // FI-3: Low Stock Warning
        if (m.damaged > 0 || m.available < 10)
          _IntelCard(
            borderColor: AppColors.red,
            icon: LucideIcons.packageMinus,
            iconColor: AppColors.red,
            title: 'Low stock alert',
            subtitle:
                '${m.available} batteries available — consider restocking',
            actionLabel: 'Request Stock',
            onAction: onRequestStock,
          ),
        const SizedBox(height: 12),

        // FI-4: Utilization summary
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.pageBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FLEET UTILIZATION',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      label: 'Rented',
                      value: '${m.rented}',
                      color: const Color(0xFF1A73E8),
                    ),
                  ),
                  Expanded(
                    child: _MiniStat(
                      label: 'Charge',
                      value: '${m.charging}',
                      color: AppColors.cyan,
                    ),
                  ),
                  Expanded(
                    child: _MiniStat(
                      label: 'Maint.',
                      value: '${m.maintenance}',
                      color: AppColors.amber,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // FI-6: Instructions prompt
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.arrowRight,
                size: 14,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Select any battery row to see detailed telemetry and lifecycle data',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}

class _IntelCard extends StatelessWidget {
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback? onAction;

  const _IntelCard({
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: borderColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: borderColor, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
          if (onAction != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: borderColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
