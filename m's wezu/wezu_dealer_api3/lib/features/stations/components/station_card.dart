import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/colors.dart';
import '../models/station_state.dart';

class StationCard extends StatefulWidget {
  final StationDto station;
  final bool isSelected;
  final VoidCallback onTap;

  const StationCard({
    super.key,
    required this.station,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<StationCard> createState() => _StationCardState();
}

class _StationCardState extends State<StationCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.station;
    final bool isOperational = s.status.toUpperCase() == 'OPERATIONAL';
    final bool isMaintenance = s.status.toUpperCase() == 'MAINTENANCE';
    
    final Color statusColor = isOperational 
        ? AppColors.primary 
        : isMaintenance 
            ? AppColors.amber 
            : AppColors.red;

    final String statusLabel = isOperational 
        ? 'Online' 
        : isMaintenance 
            ? 'Maintenance' 
            : 'Offline';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.isSelected 
                ? statusColor.withValues(alpha: 0.04) 
                : _hovered 
                    ? AppColors.cardBgHover 
                    : AppColors.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isSelected 
                  ? statusColor.withValues(alpha: 0.4) 
                  : _hovered 
                      ? AppColors.border 
                      : AppColors.border.withValues(alpha: 0.6),
              width: widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: _hovered || widget.isSelected
                ? [BoxShadow(color: statusColor.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4))]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: Status + Name + Badge ──
              Row(
                children: [
                  // Status icon with glow
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withValues(alpha: 0.15)),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(LucideIcons.radio, color: statusColor, size: 20),
                        Positioned(
                          bottom: 4, right: 4,
                          child: Container(
                            width: 10, height: 10,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.cardBg, width: 2),
                              boxShadow: [BoxShadow(color: statusColor.withValues(alpha: 0.5), blurRadius: 4)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                s.name,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (s.is24x7) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.purple.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.purple.withValues(alpha: 0.2)),
                                ),
                                child: const Text('24/7', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.purple)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(LucideIcons.mapPin, size: 11, color: AppColors.textTertiary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                s.address.isNotEmpty ? s.address : 'No address',
                                style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: statusColor.withValues(alpha: 0.6), blurRadius: 3)],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ── Row 2: Stats Grid ──
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.pageBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(child: _statItem(LucideIcons.battery, '${s.availableBatteries}', 'Batteries', AppColors.primary)),
                    _divider(),
                    Expanded(child: _statItem(LucideIcons.inbox, '${s.availableSlots}', 'Empty', AppColors.cyan)),
                    _divider(),
                    Expanded(child: _statItem(LucideIcons.repeat, '${s.activeSwaps}', 'Swaps', AppColors.amber)),
                    _divider(),
                    Expanded(child: _statItem(LucideIcons.star, s.rating.toStringAsFixed(1), 'Rating', const Color(0xFFF59E0B))),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Row 3: Utilization Bar ──
              Row(
                children: [
                  const Text('Utilization', style: TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        height: 6,
                        child: LinearProgressIndicator(
                          value: s.utilizationPercent / 100,
                          backgroundColor: AppColors.border.withValues(alpha: 0.5),
                          valueColor: AlwaysStoppedAnimation(
                            s.utilizationPercent > 80 ? AppColors.primary 
                            : s.utilizationPercent > 40 ? AppColors.cyan 
                            : AppColors.amber
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${s.utilizationPercent.toStringAsFixed(0)}%', 
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label, Color accent) {
    return Column(
      children: [
        Icon(icon, size: 14, color: accent.withValues(alpha: 0.7)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: accent)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AppColors.border.withValues(alpha: 0.5),
    );
  }
}
