import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/colors.dart';
import '../models/station_state.dart';

class KpiCardsRow extends StatelessWidget {
  final List<StationDto> stations;

  const KpiCardsRow({super.key, required this.stations});

  @override
  Widget build(BuildContext context) {
    // KPI calculations
    final totalStations = stations.length;
    final activeStations = stations.where((s) => s.status.toUpperCase() == 'OPERATIONAL').length;
    final maintenanceStations = stations.where((s) => s.status.toUpperCase() == 'MAINTENANCE').length;
    final avgUtilization = stations.isEmpty ? 0.0 : stations.fold<double>(0, (sum, s) => sum + s.utilizationPercent) / stations.length;
    final avgRating = stations.isEmpty ? 0.0 : stations.fold<double>(0, (sum, s) => sum + s.rating) / stations.length;

    return Row(children: [
      Expanded(child: _KpiCard(label: 'TOTAL STATIONS', value: '$totalStations', accent: AppColors.primary, icon: LucideIcons.mapPin)),
      const SizedBox(width: 12),
      Expanded(child: _KpiCard(label: 'ACTIVE', value: '$activeStations', accent: AppColors.primary, icon: LucideIcons.checkCircle)),
      const SizedBox(width: 12),
      Expanded(child: _KpiCard(label: 'MAINTENANCE', value: '$maintenanceStations', accent: AppColors.amber, icon: LucideIcons.wrench)),
      const SizedBox(width: 12),
      Expanded(child: _KpiCard(label: 'AVG UTILIZATION', value: '${avgUtilization.toStringAsFixed(1)}%', accent: AppColors.cyan, icon: LucideIcons.activity)),
      const SizedBox(width: 12),
      Expanded(child: _KpiCard(label: 'AVG RATING', value: avgRating.toStringAsFixed(1), accent: AppColors.purple, icon: LucideIcons.star)),
    ]);
  }
}

class _KpiCard extends StatefulWidget {
  final String label, value;
  final Color accent;
  final IconData icon;

  const _KpiCard({required this.label, required this.value, required this.accent, required this.icon});

  @override
  State<_KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<_KpiCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.cardBgHover : AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _hovered ? widget.accent.withValues(alpha: 0.5) : AppColors.border),
          boxShadow: _hovered ? [BoxShadow(color: widget.accent.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))] : [],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 3,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: widget.accent,
              borderRadius: BorderRadius.circular(1.5),
              boxShadow: [BoxShadow(color: widget.accent.withValues(alpha: 0.4), blurRadius: 6)]
            )
          ),
          Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: widget.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: Icon(widget.icon, size: 16, color: widget.accent),
            ),
            const SizedBox(width: 10),
            Text(widget.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.6)),
          ]),
          const SizedBox(height: 12),
          Text(widget.value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
        ]),
      ),
    );
  }
}
