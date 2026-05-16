import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../models/station_state.dart';

/// Station card for station list — shows header, mini metrics, utilization bar, actions
class StationCard extends StatefulWidget {
  final StationDto station;
  final VoidCallback onTap;
  final VoidCallback onViewBatteries;
  final bool isExpanded; // Single station = expanded

  const StationCard({
    super.key,
    required this.station,
    required this.onTap,
    required this.onViewBatteries,
    this.isExpanded = false,
  });

  @override
  State<StationCard> createState() => _StationCardState();
}

class _StationCardState extends State<StationCard> {
  bool _hovered = false;

  Color get _statusColor {
    switch (widget.station.status.toUpperCase()) {
      case 'OPERATIONAL': return AppColors.primary;
      case 'OFFLINE': return AppColors.red;
      case 'MAINTENANCE': return AppColors.amber;
      default: return AppColors.textMuted;
    }
  }

  String get _statusLabel => widget.station.status.toUpperCase();

  @override
  Widget build(BuildContext context) {
    final s = widget.station;
    final utilizationColor = s.utilizationPercent > 80
        ? AppColors.red
        : s.utilizationPercent > 60
            ? AppColors.amber
            : AppColors.primary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.cardBgHover : AppColors.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 16)]
                : [],
          ),
          child: Stack(children: [
            // Left accent on hover
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              left: 0,
              top: 12,
              bottom: 12,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: _hovered ? 3 : 0,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // ── Header ──
                Row(children: [
                  // Status icon
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(LucideIcons.radio, size: 16, color: _statusColor),
                  ),
                  const SizedBox(width: 14),
                  // Name & address
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Flexible(child: Text(s.name, style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                      ))),
                      const SizedBox(width: 8),
                      if (s.is24x7) _pill('24/7', AppColors.primary),
                      if (s.stationType.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        _pill(s.stationType, AppColors.textTertiary),
                      ],
                    ]),
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(LucideIcons.mapPin, size: 11, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        s.city.isNotEmpty ? '${s.address}, ${s.city}' : s.address,
                        style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                      ),
                    ]),
                  ])),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(_statusLabel, style: TextStyle(
                      color: _statusColor, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5,
                    )),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(LucideIcons.settings, size: 16, color: AppColors.textTertiary),
                    onPressed: widget.onTap,
                    tooltip: 'Settings',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  Icon(LucideIcons.chevronRight, size: 16, color: _hovered ? AppColors.primary : AppColors.textMuted),
                ]),

                const SizedBox(height: 18),

                // ── Mini Metrics Strip ──
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.pageBg.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    _metric(LucideIcons.batteryFull, '${s.maxCapacity}', 'Total', AppColors.primary),
                    _divider(),
                    _metric(LucideIcons.checkCircle, '${s.availableBatteries}', 'Available', AppColors.cyan),
                    _divider(),
                    _metric(LucideIcons.userCheck, '${s.ongoingRentals}', 'Rented', AppColors.amber),
                    _divider(),
                    _ratingMetric(s.rating),
                  ]),
                ),

                const SizedBox(height: 14),

                // ── Utilization Bar ──
                Row(children: [
                  const Text('Utilization', style: TextStyle(
                    fontSize: 10, color: AppColors.textTertiary, fontWeight: FontWeight.w500,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: SizedBox(
                      height: 6,
                      child: LinearProgressIndicator(
                        value: (s.utilizationPercent / 100).clamp(0.0, 1.0),
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation(utilizationColor),
                      ),
                    ),
                  )),
                  const SizedBox(width: 8),
                  Text('${s.utilizationPercent.toStringAsFixed(0)}%', style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: utilizationColor,
                  )),
                ]),

                const SizedBox(height: 16),

                // ── Footer Actions ──
                Row(children: [
                  Expanded(child: OutlinedButton.icon(
                    icon: const Icon(LucideIcons.eye, size: 13),
                    label: const Text('View Details', style: TextStyle(fontSize: 12)),
                    onPressed: widget.onTap,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: OutlinedButton.icon(
                    icon: const Icon(LucideIcons.batteryFull, size: 13),
                    label: const Text('View Batteries', style: TextStyle(fontSize: 12)),
                    onPressed: widget.onViewBatteries,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  )),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(text, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
  );

  Widget _metric(IconData icon, String value, String label, Color color) => Expanded(
    child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
      ]),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
    ]),
  );

  Widget _ratingMetric(double rating) => Expanded(
    child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(LucideIcons.star, size: 13, color: AppColors.purple),
        const SizedBox(width: 5),
        Text(rating.toStringAsFixed(1), style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.purple,
        )),
      ]),
      const SizedBox(height: 3),
      const Text('Rating', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
    ]),
  );

  Widget _divider() => Container(
    width: 1, height: 30,
    margin: const EdgeInsets.symmetric(horizontal: 4),
    color: AppColors.border,
  );
}
