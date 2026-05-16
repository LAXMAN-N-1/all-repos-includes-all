import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../providers/inventory_provider.dart';

/// Zone 2 — KPI Metric Banner
/// 5 animated, clickable metric cards that act as table filters.
class KpiMetricBanner extends ConsumerStatefulWidget {
  const KpiMetricBanner({super.key});

  @override
  ConsumerState<KpiMetricBanner> createState() => _KpiMetricBannerState();
}

class _KpiMetricBannerState extends ConsumerState<KpiMetricBanner>
    with TickerProviderStateMixin {
  late final AnimationController _staggerController;
  late final AnimationController _countController;
  String? _activeFilter;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _countController.dispose();
    super.dispose();
  }

  void _onCardTap(String? filterStatus) {
    setState(() => _activeFilter = filterStatus);
    ref.read(inventoryBatteriesProvider.notifier).setFilter(filterStatus);
  }

  @override
  Widget build(BuildContext context) {
    final metricsState = ref.watch(inventoryMetricsProvider);
    final m = metricsState.data;

    // Calculate health warning & critical from the battery list
    final batteries = ref.watch(inventoryBatteriesProvider);
    final healthWarning = batteries.items
        .where((b) =>
            b.health.percentage >= 70 && b.health.percentage < 85)
        .length;
    final critical = batteries.items
        .where((b) => b.health.percentage < 70)
        .length;

    final cards = <_KpiCardData>[
      _KpiCardData(
        label: 'TOTAL FLEET',
        value: m.totalStock,
        icon: LucideIcons.layers,
        accent: Colors.white54,
        filterKey: null,
      ),
      _KpiCardData(
        label: 'AVAILABLE',
        value: m.available,
        icon: LucideIcons.checkCircle2,
        accent: AppColors.primary,
        filterKey: 'available',
      ),
      _KpiCardData(
        label: 'RESERVED',
        value: m.reserved + m.rented,
        icon: LucideIcons.clock,
        accent: const Color(0xFF1A73E8),
        filterKey: 'reserved',
      ),
      _KpiCardData(
        label: 'HEALTH WARNING',
        value: healthWarning > 0 ? healthWarning : m.maintenance,
        icon: LucideIcons.alertTriangle,
        accent: AppColors.amber,
        filterKey: 'maintenance',
        pulseWhenPositive: true,
        pulseDuration: const Duration(seconds: 2),
      ),
      _KpiCardData(
        label: 'CRITICAL',
        value: critical > 0 ? critical : m.damaged,
        icon: LucideIcons.xCircle,
        accent: AppColors.red,
        filterKey: 'retired',
        pulseWhenPositive: true,
        pulseDuration: const Duration(milliseconds: 1500),
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: metricsState.isLoading
          ? Row(
              children: List.generate(
                5,
                (i) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < 4 ? 12 : 0),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Row(
              children: List.generate(cards.length, (i) {
                final data = cards[i];
                final isActive = _activeFilter == data.filterKey;

                // Stagger animation
                final staggerBegin = i * 0.12;
                final staggerEnd = (staggerBegin + 0.4).clamp(0.0, 1.0);

                return Expanded(
                  child: AnimatedBuilder(
                    animation: _staggerController,
                    builder: (context, child) {
                      final progress = Curves.easeOut.transform(
                        ((_staggerController.value - staggerBegin) /
                                (staggerEnd - staggerBegin))
                            .clamp(0.0, 1.0),
                      );
                      return Opacity(
                        opacity: progress,
                        child: Transform.translate(
                          offset: Offset(0, 12 * (1 - progress)),
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 4 ? 12 : 0),
                      child: _AnimatedKpiCard(
                        data: data,
                        isActive: isActive,
                        countAnimation: _countController,
                        onTap: () => _onCardTap(data.filterKey),
                      ),
                    ),
                  ),
                );
              }),
            ),
    );
  }
}

class _KpiCardData {
  final String label;
  final int value;
  final IconData icon;
  final Color accent;
  final String? filterKey;
  final bool pulseWhenPositive;
  final Duration pulseDuration;

  const _KpiCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.filterKey,
    this.pulseWhenPositive = false,
    this.pulseDuration = const Duration(seconds: 2),
  });
}

class _AnimatedKpiCard extends StatefulWidget {
  final _KpiCardData data;
  final bool isActive;
  final Animation<double> countAnimation;
  final VoidCallback onTap;

  const _AnimatedKpiCard({
    required this.data,
    required this.isActive,
    required this.countAnimation,
    required this.onTap,
  });

  @override
  State<_AnimatedKpiCard> createState() => _AnimatedKpiCardState();
}

class _AnimatedKpiCardState extends State<_AnimatedKpiCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  AnimationController? _pulseController;

  @override
  void initState() {
    super.initState();
    if (widget.data.pulseWhenPositive && widget.data.value > 0) {
      _pulseController = AnimationController(
        vsync: this,
        duration: widget.data.pulseDuration,
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final shouldPulse =
        data.pulseWhenPositive && data.value > 0 && _pulseController != null;

    Widget card = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.diagonal3Values(
            widget.isActive ? 1.03 : (_hovered ? 1.01 : 1.0),
            widget.isActive ? 1.03 : (_hovered ? 1.01 : 1.0),
            1.0,
          ),
          transformAlignment: Alignment.center,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: data.pulseWhenPositive && data.value > 0
                ? data.accent.withValues(alpha: 0.04)
                : (_hovered ? AppColors.cardBgHover : AppColors.cardBg),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isActive
                  ? data.accent.withValues(alpha: 0.8)
                  : (_hovered
                      ? data.accent.withValues(alpha: 0.3)
                      : AppColors.border),
              width: widget.isActive ? 1.5 : 1,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: data.accent.withValues(alpha: 0.15),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top colored accent bar
              Container(
                height: 3,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: data.accent,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: data.accent.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              // Icon + Label row
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: data.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      data.icon,
                      size: 12,
                      color: data.accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data.label,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                        letterSpacing: 0.6,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Animated count number
              AnimatedBuilder(
                animation: widget.countAnimation,
                builder: (context, _) {
                  final animatedValue =
                      (data.value * widget.countAnimation.value).round();
                  return Text(
                    '$animatedValue',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );

    // Wrap with pulse animation for warning/critical cards
    if (shouldPulse) {
      card = AnimatedBuilder(
        animation: _pulseController!,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: data.accent.withValues(
                    alpha: 0.08 + 0.08 * _pulseController!.value,
                  ),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: child,
          );
        },
        child: card,
      );
    }

    return Tooltip(
      message: data.filterKey == null
          ? 'Click to show all batteries'
          : 'Click to filter: ${data.label.toLowerCase()}',
      child: card,
    );
  }
}
