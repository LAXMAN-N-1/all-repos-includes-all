import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';

/// Four tappable metric cards + auto-refresh sweep bar
class QuickStatsBar extends StatefulWidget {
  final int availableBatteries;
  final int ongoingRentals;
  final int currentSwaps;
  final double avgRating;
  final int stationCount;
  final VoidCallback onBatteriesTap;
  final VoidCallback onRentalsTap;
  final VoidCallback onSwapsTap;
  final VoidCallback onRatingsTap;
  final VoidCallback? onRefresh;

  const QuickStatsBar({
    super.key,
    required this.availableBatteries,
    required this.ongoingRentals,
    required this.currentSwaps,
    required this.avgRating,
    required this.stationCount,
    required this.onBatteriesTap,
    required this.onRentalsTap,
    required this.onSwapsTap,
    required this.onRatingsTap,
    this.onRefresh,
  });

  @override
  State<QuickStatsBar> createState() => _QuickStatsBarState();
}

class _QuickStatsBarState extends State<QuickStatsBar> with SingleTickerProviderStateMixin {
  late final AnimationController _refreshController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(vsync: this, duration: const Duration(seconds: 60));
    _startRefreshCycle();
  }

  void _startRefreshCycle() {
    _refreshController.forward(from: 0);
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      widget.onRefresh?.call();
      _refreshController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Refresh sweep bar
      AnimatedBuilder(
        animation: _refreshController,
        builder: (_, __) => Container(
          height: 2,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(1)),
          child: LinearProgressIndicator(
            value: _refreshController.value,
            backgroundColor: AppColors.border.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            minHeight: 2,
          ),
        ),
      ),
      const SizedBox(height: 16),
      // Cards
      Row(children: [
        Expanded(child: _QuickStatCard(
          label: 'Available Batteries',
          value: '${widget.availableBatteries}',
          subLabel: 'across ${widget.stationCount} stations',
          accent: AppColors.primary,
          icon: LucideIcons.batteryFull,
          onTap: widget.onBatteriesTap,
        )),
        const SizedBox(width: 12),
        Expanded(child: _QuickStatCard(
          label: 'Ongoing Rentals',
          value: '${widget.ongoingRentals}',
          subLabel: 'active rentals right now',
          accent: AppColors.cyan,
          icon: LucideIcons.userCheck,
          onTap: widget.onRentalsTap,
        )),
        const SizedBox(width: 12),
        Expanded(child: _QuickStatCard(
          label: 'Current Swaps',
          value: '${widget.currentSwaps}',
          subLabel: 'in progress',
          accent: AppColors.amber,
          icon: LucideIcons.refreshCw,
          onTap: widget.onSwapsTap,
        )),
        const SizedBox(width: 12),
        Expanded(child: _QuickStatCard(
          label: 'Avg Station Rating',
          value: widget.avgRating.toStringAsFixed(1),
          subLabel: '${widget.stationCount} stations rated',
          accent: AppColors.purple,
          icon: LucideIcons.star,
          onTap: widget.onRatingsTap,
          showStars: true,
          starRating: widget.avgRating,
        )),
      ]),
    ]);
  }
}

class _QuickStatCard extends StatefulWidget {
  final String label, value, subLabel;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;
  final bool showStars;
  final double starRating;

  const _QuickStatCard({
    required this.label,
    required this.value,
    required this.subLabel,
    required this.accent,
    required this.icon,
    required this.onTap,
    this.showStars = false,
    this.starRating = 0,
  });

  @override
  State<_QuickStatCard> createState() => _QuickStatCardState();
}

class _QuickStatCardState extends State<_QuickStatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.cardBgHover : AppColors.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered ? widget.accent.withValues(alpha: 0.4) : AppColors.border,
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: widget.accent.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 4))]
                : [],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Top accent line
            Container(
              height: 3,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: widget.accent,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [BoxShadow(color: widget.accent.withValues(alpha: 0.5), blurRadius: 8)],
              ),
            ),
            // Icon + label
            Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: widget.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, size: 16, color: widget.accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(widget.label, style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary, letterSpacing: 0.3,
                )),
              ),
            ]),
            const SizedBox(height: 14),
            // Value
            Text(widget.value, style: const TextStyle(
              fontSize: 28, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary, letterSpacing: -0.5,
            )),
            const SizedBox(height: 4),
            // Sub-label or stars
            if (widget.showStars) ...[
              Row(children: List.generate(5, (i) {
                final filled = widget.starRating >= i + 1;
                final half = widget.starRating > i && widget.starRating < i + 1;
                return Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Icon(
                    filled ? LucideIcons.star : (half ? LucideIcons.star : LucideIcons.star),
                    size: 13,
                    color: filled || half ? AppColors.amber : AppColors.textMuted,
                  ),
                );
              })),
            ] else
              Text(widget.subLabel, style: const TextStyle(
                fontSize: 11, color: AppColors.textMuted,
              )),
            const SizedBox(height: 4),
            // Arrow hint
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              AnimatedOpacity(
                opacity: _hovered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('View All', style: TextStyle(
                    fontSize: 10, color: widget.accent, fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(width: 2),
                  Icon(LucideIcons.arrowRight, size: 11, color: widget.accent),
                ]),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
