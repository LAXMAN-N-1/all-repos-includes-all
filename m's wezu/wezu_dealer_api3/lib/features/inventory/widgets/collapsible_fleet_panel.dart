import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../providers/inventory_provider.dart';

/// Collapsible side panel for Fleet Intelligence.
/// Sits beside the table. Default expanded at 300px.
/// Collapses to 48px to give table more breathing room.
class CollapsibleFleetPanel extends ConsumerStatefulWidget {
  final VoidCallback onRequestStock;
  final VoidCallback? onReceiveStock;

  const CollapsibleFleetPanel(
      {super.key, required this.onRequestStock, this.onReceiveStock});

  @override
  ConsumerState<CollapsibleFleetPanel> createState() =>
      _CollapsibleFleetPanelState();
}

class _CollapsibleFleetPanelState extends ConsumerState<CollapsibleFleetPanel> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final metricsState = ref.watch(inventoryMetricsProvider);
    final batteries = ref.watch(inventoryBatteriesProvider);
    final m = metricsState.data;

    // Calculate score for donut from current loaded dataset (approximation of health distribution)
    int excellent = 0, good = 0, fair = 0, poor = 0;
    for (final b in batteries.items) {
      final hp = b.health.percentage;
      if (hp >= 90)
        excellent++;
      else if (hp >= 70)
        good++;
      else if (hp >= 50)
        fair++;
      else
        poor++;
    }
    // For totals, use real metrics from DB
    final totalFleet = m.totalStock;
    final hasAlerts = m.maintenance > 0 || m.damaged > 0 || poor > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.ease,
      width: _isExpanded ? 300 : 48,
      decoration: const BoxDecoration(
        color: AppColors.pageBg,
        border: Border(left: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        children: [
          // Header / Toggle
          Container(
            height: 48,
            decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        _isExpanded
                            ? LucideIcons.chevronRight
                            : LucideIcons.chevronLeft,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                if (_isExpanded)
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        'Fleet Intelligence',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Body content
          Expanded(
            child: _isExpanded
                ? SizedBox(
                    width: 300,
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: _buildExpandedView(
                          excellent,
                          good,
                          fair,
                          poor,
                          totalFleet,
                          m.maintenance,
                          m.damaged,
                          m.rented,
                          m.charging),
                    ),
                  )
                : SizedBox(
                    width: 48,
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child:
                          _buildCollapsedView(totalFleet, hasAlerts, m, poor),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedView(int total, bool hasAlerts, dynamic m, int poor) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Donut score indicator
        Tooltip(
          message: 'Total Fleet: $total',
          child: GestureDetector(
            onTap: () => setState(() => _isExpanded = true),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                color: Colors.transparent, // Ensures tap area is solid
              ),
              alignment: Alignment.center,
              child: Text(
                '$total',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Active Alerts Indicator
        Tooltip(
          message: hasAlerts ? 'Active Alerts' : 'No Alerts',
          child: GestureDetector(
            onTap: () {
              if (hasAlerts) {
                _showAlertsPopover(context, m, poor);
              } else {
                setState(() => _isExpanded = true);
              }
            },
            child: Stack(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.bell,
                      size: 16, color: AppColors.amber),
                ),
                if (hasAlerts)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: AppColors.red, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Utilization Indicator
        Tooltip(
          message: 'Fleet Utilization',
          child: GestureDetector(
            onTap: () => _showUtilizationPopover(context, m),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.zap,
                  size: 16, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  void _showAlertsPopover(BuildContext context, dynamic m, int poor) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.05),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, _, __) {
        return Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 64),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 280,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pageBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ACTIVE ALERTS',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textTertiary,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    if (m.maintenance > 0)
                      _AlertCard(
                        icon: LucideIcons.alertTriangle,
                        iconColor: AppColors.amber,
                        title: '${m.maintenance} need service',
                        subtitle: 'Based on cycles',
                      ),
                    if (m.damaged > 0 || poor > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _AlertCard(
                          icon: LucideIcons.heartPulse,
                          iconColor: AppColors.red,
                          title: '${m.damaged + poor} critical health',
                          subtitle: 'Action required immediately',
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showUtilizationPopover(BuildContext context, dynamic m) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.05),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, _, __) {
        return Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 64),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 250,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pageBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('UTILIZATION',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textTertiary,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: _MiniStat(
                                label: 'Rented',
                                value: '${m.rented}',
                                color: const Color(0xFF1A73E8))),
                        Expanded(
                            child: _MiniStat(
                                label: 'Charge',
                                value: '${m.charging}',
                                color: AppColors.cyan)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                            child: _MiniStat(
                                label: 'Maint.',
                                value: '${m.maintenance}',
                                color: AppColors.amber)),
                        Expanded(
                            child: _MiniStat(
                                label: 'Damaged',
                                value: '${m.damaged}',
                                color: AppColors.red)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedView(int excellent, int good, int fair, int poor,
      int total, int maintenance, int damaged, int rented, int charging) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Donut Chart
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
                                  radius: 20,
                                  showTitle: false)
                            ]
                          : [
                              if (excellent > 0)
                                PieChartSectionData(
                                    value: excellent.toDouble(),
                                    color: AppColors.primary,
                                    radius: 20,
                                    showTitle: false),
                              if (good > 0)
                                PieChartSectionData(
                                    value: good.toDouble(),
                                    color: AppColors.cyan,
                                    radius: 20,
                                    showTitle: false),
                              if (fair > 0)
                                PieChartSectionData(
                                    value: fair.toDouble(),
                                    color: AppColors.amber,
                                    radius: 20,
                                    showTitle: false),
                              if (poor > 0)
                                PieChartSectionData(
                                    value: poor.toDouble(),
                                    color: AppColors.red,
                                    radius: 20,
                                    showTitle: false),
                            ],
                      centerSpaceRadius: 50,
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
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary),
                      ),
                      const Text('Total',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textTertiary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(
                  color: AppColors.primary, label: 'Good ${excellent + good}'),
              const SizedBox(width: 12),
              _LegendDot(color: AppColors.amber, label: 'Fair $fair'),
              const SizedBox(width: 12),
              _LegendDot(color: AppColors.red, label: 'Poor $poor'),
            ],
          ),
          const SizedBox(height: 32),

          const Text('ALERTS',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5)),
          const SizedBox(height: 12),

          if (maintenance > 0)
            _AlertCard(
              icon: LucideIcons.alertTriangle,
              iconColor: AppColors.amber,
              title: '$maintenance need service',
              subtitle: 'Based on cycles',
            ),
          if (damaged > 0 || poor > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _AlertCard(
                icon: LucideIcons.heartPulse,
                iconColor: AppColors.red,
                title: '${damaged + poor} critical health',
                subtitle: 'Action required immediately',
              ),
            ),
          if (maintenance == 0 && damaged == 0 && poor == 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No active alerts',
                  style:
                      TextStyle(color: AppColors.textTertiary, fontSize: 13)),
            ),

          const SizedBox(height: 32),
          const Text('UTILIZATION',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.5)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _MiniStat(
                      label: 'Rented',
                      value: '$rented',
                      color: const Color(0xFF1A73E8))),
              Expanded(
                  child: _MiniStat(
                      label: 'Charge',
                      value: '$charging',
                      color: AppColors.cyan)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _MiniStat(
                      label: 'Maint.',
                      value: '$maintenance',
                      color: AppColors.amber)),
              Expanded(
                  child: _MiniStat(
                      label: 'Damaged',
                      value: '$damaged',
                      color: AppColors.red)),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),
          // Quick actions
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onRequestStock,
              icon: const Icon(LucideIcons.packagePlus, size: 16),
              label: const Text('Request Batteries'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onReceiveStock,
              icon: const Icon(LucideIcons.packageCheck, size: 16),
              label: const Text('Receive Stock'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(LucideIcons.download, size: 16),
              label: const Text('Export CSV'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.border),
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                try {
                  final state = ref.read(inventoryBatteriesProvider);
                  if (state.items.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('No inventory to export')));
                    return;
                  }

                  final csvData = StringBuffer();
                  // CSV Header
                  csvData.writeln(
                      'Serial Number,Status,Charge (%),SOH (%),Cycles,Station,Battery Type,Model,Fault Reason,Last Updated');

                  // CSV Rows — escape fields that may contain commas
                  for (var b in state.items) {
                    final updated = b.updatedAt ?? 'N/A';
                    final station = b.location.stationName.isNotEmpty
                        ? b.location.stationName
                        : 'Unassigned';
                    final fault = b.faultReason ?? '';
                    csvData.writeln(
                        '"${b.serialNumber}","${b.currentStatus}","${b.charge.percentage.toStringAsFixed(1)}","${b.health.percentage.toStringAsFixed(1)}","${b.cycleCount}","$station","${b.batteryType ?? ''}","${b.modelName}","$fault","$updated"');
                  }

                  // Web-native download using dart:html
                  final bytes = utf8.encode(csvData.toString());
                  final blob = html.Blob([bytes], 'text/csv');
                  final url = html.Url.createObjectUrlFromBlob(blob);
                  html.AnchorElement(href: url)
                    ..setAttribute('download', 'dealer_inventory_export.csv')
                    ..click();
                  html.Url.revokeObjectUrl(url);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              '✓ CSV exported — check your Downloads folder'),
                          backgroundColor: AppColors.primary),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Export failed: $e'),
                        backgroundColor: AppColors.red));
                  }
                }
              },
            ),
          ),
        ],
      ),
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
            decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _AlertCard(
      {required this.icon,
      required this.iconColor,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: iconColor, width: 3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textTertiary)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}
