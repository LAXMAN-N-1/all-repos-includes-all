import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/analytics_provider.dart';
import '../models/analytics_state.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  String _period = '30d';

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _stagger(int i, {required Widget child}) {
    final begin = i * 0.12;
    final end = (begin + 0.4).clamp(0.0, 1.0);
    return AnimatedBuilder(
        animation: _c,
        builder: (c, _) {
          final t = Curves.easeOut
              .transform(((_c.value - begin) / (end - begin)).clamp(0.0, 1.0));
          return Opacity(
              opacity: t,
              child:
                  Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child));
        });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analyticsProvider);
    final overview = state.overview;
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Period selector + Refresh
        _stagger(0,
            child: Row(children: [
              const Text('Analytics Dashboard',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const Spacer(),
              ...['7d', '30d', '90d'].map((p) {
                final sel = _period == p;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _period = p);
                      ref.read(analyticsProvider.notifier).refresh();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.cyan.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: sel
                                ? AppColors.cyan.withValues(alpha: 0.3)
                                : AppColors.border),
                      ),
                      child: Text(p,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  sel ? FontWeight.w600 : FontWeight.w400,
                              color: sel
                                  ? AppColors.cyan
                                  : AppColors.textSecondary)),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(LucideIcons.refreshCw,
                    size: 16, color: AppColors.textTertiary),
                tooltip: 'Refresh',
                onPressed: () => ref.read(analyticsProvider.notifier).refresh(),
              ),
              const SizedBox(width: 4),
              OutlinedButton.icon(
                  icon: const Icon(LucideIcons.download, size: 14),
                  label: const Text('Export', style: TextStyle(fontSize: 12)),
                  onPressed: () {}),
            ])),
        const SizedBox(height: 20),

        // Error banner
        if (state.error != null)
          _stagger(0,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  const Icon(LucideIcons.alertTriangle,
                      size: 16, color: AppColors.red),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(state.error!,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.red))),
                  TextButton(
                    onPressed: () =>
                        ref.read(analyticsProvider.notifier).refresh(),
                    child: const Text('Retry',
                        style: TextStyle(color: AppColors.red, fontSize: 12)),
                  ),
                ]),
              )),

        // KPI Cards
        _stagger(1,
            child: state.isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary))
                : Row(children: [
                    Expanded(
                        child: _KpiCard(
                            label: 'REVENUE',
                            value:
                                currency.format(overview?.revenue.toInt() ?? 0),
                            icon: LucideIcons.indianRupee,
                            accent: AppColors.primary)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _KpiCard(
                            label: 'TOTAL SWAPS',
                            value: '${overview?.totalSwaps ?? 0}',
                            icon: LucideIcons.repeat,
                            accent: AppColors.cyan)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _KpiCard(
                            label: 'AVG SWAP DURATION',
                            value:
                                '${overview?.avgSwapDurationHrs.toStringAsFixed(1) ?? 0}h',
                            icon: LucideIcons.clock,
                            accent: AppColors.amber)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _KpiCard(
                            label: 'SATISFACTION',
                            value:
                                '${overview?.customerSatisfaction.toStringAsFixed(1) ?? 0} / 5',
                            icon: LucideIcons.star,
                            accent: AppColors.purple)),
                  ])),
        const SizedBox(height: 20),

        // Charts Row 1 — Revenue Trend + Swap Volume
        _stagger(2,
            child: Row(children: [
              Expanded(
                  child: _ChartContainer(
                title: 'Revenue Trend',
                icon: LucideIcons.trendingUp,
                child: _LiveBarChart(
                  color: AppColors.primary,
                  data: overview?.revenueChartData ?? [],
                  currency: true,
                ),
              )),
              const SizedBox(width: 14),
              Expanded(
                  child: _ChartContainer(
                title: 'Swap Volume',
                icon: LucideIcons.barChart2,
                child: _LiveBarChart(
                  color: AppColors.cyan,
                  data: overview?.swapChartData ?? [],
                  currency: false,
                ),
              )),
            ])),
        const SizedBox(height: 14),

        // Charts Row 2 — Station Utilization + Battery Health
        _stagger(3,
            child: Row(children: [
              Expanded(
                  child: _ChartContainer(
                title: 'Station Utilization',
                icon: LucideIcons.activity,
                child: _LiveHorizontalBarChart(
                    data: overview?.stationUtilization ?? []),
              )),
              const SizedBox(width: 14),
              Expanded(
                  child: _ChartContainer(
                title: 'Battery Health Distribution',
                icon: LucideIcons.batteryCharging,
                child: _LiveDonutChart(health: overview?.batteryHealth),
              )),
            ])),
        const SizedBox(height: 14),

        // Peak Hours Heatmap
        _stagger(4,
            child: _ChartContainer(
          title: 'Peak Hours',
          icon: LucideIcons.clock,
          child: _LivePeakHoursGrid(
              hourlyData: overview?.peakHoursData ?? []),
        )),
      ]),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// LIVE BAR CHART — uses real data, falls back to empty state
// ──────────────────────────────────────────────────────────────

class _LiveBarChart extends StatelessWidget {
  final Color color;
  final List<AnalyticsTrendPoint> data;
  final bool currency;
  const _LiveBarChart(
      {required this.color, required this.data, this.currency = false});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(LucideIcons.barChart2,
                size: 28, color: AppColors.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 8),
            const Text('No data available',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ]),
        ),
      );
    }

    final maxVal =
        data.map((e) => e.value).reduce(math.max).clamp(1.0, double.infinity);

    return SizedBox(
      height: 180,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: data.asMap().entries.map((entry) {
            final i = entry.key;
            final point = entry.value;
            final h = point.value / maxVal;
            return Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 400 + i * 60),
                      height: h * 140,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [color, color.withValues(alpha: 0.5)]),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                              color: color.withValues(alpha: 0.18),
                              blurRadius: 6,
                              offset: const Offset(0, 2))
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      point.label.length > 3
                          ? point.label.substring(0, 3)
                          : point.label,
                      style: const TextStyle(
                          fontSize: 9, color: AppColors.textTertiary),
                    ),
                  ]),
            );
          }).toList()),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// LIVE HORIZONTAL BAR CHART — station utilization
// ──────────────────────────────────────────────────────────────

class _LiveHorizontalBarChart extends StatelessWidget {
  final List<AnalyticsStationUtilization> data;
  const _LiveHorizontalBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: Text('No station data',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ),
      );
    }
    return Column(
        children: data.map((s) {
      final pct = s.utilization.clamp(0.0, 1.0);
      final color = pct >= 0.8
          ? AppColors.primary
          : pct >= 0.5
              ? AppColors.cyan
              : AppColors.amber;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          SizedBox(
              width: 140,
              child: Text(
                s.name.length > 20 ? '${s.name.substring(0, 18)}…' : s.name,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
              )),
          Expanded(
              child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
                height: 10,
                child: Stack(children: [
                  Container(
                      decoration: BoxDecoration(
                          color: AppColors.pageBg,
                          borderRadius: BorderRadius.circular(4))),
                  FractionallySizedBox(
                    widthFactor: pct,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [color, color.withValues(alpha: 0.6)]),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ])),
          )),
          const SizedBox(width: 10),
          Text('${(pct * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ]),
      );
    }).toList());
  }
}

// ──────────────────────────────────────────────────────────────
// LIVE DONUT CHART — battery health
// ──────────────────────────────────────────────────────────────

class _LiveDonutChart extends StatelessWidget {
  final AnalyticsBatteryHealth? health;
  const _LiveDonutChart({this.health});

  @override
  Widget build(BuildContext context) {
    final h = health;
    // Use API data or empty placeholders
    final List<(String, double, Color)> segments = h != null
        ? [
            ('Good', h.good, AppColors.primary),
            ('Degraded', h.degraded, AppColors.amber),
            ('Critical', h.critical, AppColors.red),
          ]
        : [
            ('Good', 0.0, AppColors.primary),
            ('Degraded', 0.0, AppColors.amber),
            ('Critical', 0.0, AppColors.red),
          ];

    final total = segments.fold(0.0, (s, e) => s + e.$2);
    final hasData = total > 0;

    return SizedBox(
      height: 180,
      child: Row(children: [
        Expanded(
            child: hasData
                ? CustomPaint(painter: _DonutPainter(segments))
                : Center(
                    child: Text('No health data',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)))),
        const SizedBox(width: 20),
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: segments
                .map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(children: [
                        Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: s.$3)),
                        const SizedBox(width: 8),
                        Text(
                            '${s.$1}: ${hasData ? s.$2.toStringAsFixed(0) : 0}%',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                      ]),
                    ))
                .toList()),
      ]),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<(String, double, Color)> segments;
  _DonutPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 10;
    const startAngle = -math.pi / 2;
    var sweepStart = startAngle;
    final total = segments.fold(0.0, (s, e) => s + e.$2);
    if (total == 0) return;

    for (final (_, pct, color) in segments) {
      final sweepAngle = (pct / total) * 2 * math.pi;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          sweepStart, sweepAngle - 0.04, false, paint);
      sweepStart += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

// ──────────────────────────────────────────────────────────────
// LIVE PEAK HOURS GRID — uses real hourly data
// ──────────────────────────────────────────────────────────────

class _LivePeakHoursGrid extends StatelessWidget {
  final List<double> hourlyData;
  const _LivePeakHoursGrid({required this.hourlyData});

  @override
  Widget build(BuildContext context) {
    final hours = List.generate(24, (i) => i);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Use API data if available (24 values = one per hour, flat)
    // If 24 values → same for all days. If 7*24 = 168 → per-day per-hour.
    double _intensity(int dayIdx, int hour) {
      if (hourlyData.length == 24) {
        // Single row — normalize
        final maxVal = hourlyData.reduce(math.max).clamp(1.0, double.infinity);
        return (hourlyData[hour] / maxVal).clamp(0.05, 1.0);
      } else if (hourlyData.length >= 168) {
        final idx = dayIdx * 24 + hour;
        final maxVal = hourlyData.reduce(math.max).clamp(1.0, double.infinity);
        return (hourlyData[idx] / maxVal).clamp(0.05, 1.0);
      } else {
        // Fallback heuristic
        return ((hour >= 7 && hour <= 10) || (hour >= 17 && hour <= 20))
            ? 0.8
            : (hour >= 11 && hour <= 16)
                ? 0.5
                : 0.12;
      }
    }

    return Column(children: [
      Row(children: [
        const SizedBox(width: 40),
        ...hours
            .where((h) => h % 3 == 0)
            .map((h) => Expanded(
                child: Text('${h}:00',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 9, color: AppColors.textTertiary)))),
      ]),
      ...days.asMap().entries.map((dayEntry) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              SizedBox(
                  width: 40,
                  child: Text(dayEntry.value,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textTertiary))),
              ...hours
                  .where((h) => h % 3 == 0)
                  .map((h) {
                    final intensity = _intensity(dayEntry.key, h);
                    return Expanded(
                        child: Container(
                      height: 20,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: intensity),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ));
                  })
                  .toList(),
            ]),
          )),
    ]);
  }
}

// ──────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ──────────────────────────────────────────────────────────────

class _ChartContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _ChartContainer(
      {required this.title, required this.icon, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 18),
        child,
      ]),
    );
  }
}

class _KpiCard extends StatefulWidget {
  final String label, value;
  final IconData icon;
  final Color accent;
  const _KpiCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.accent});
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
          border: Border.all(
              color: _hovered
                  ? widget.accent.withValues(alpha: 0.2)
                  : AppColors.border),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                      color: widget.accent.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              height: 2,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                  color: widget.accent,
                  borderRadius: BorderRadius.circular(1),
                  boxShadow: [
                    BoxShadow(
                        color: widget.accent.withValues(alpha: 0.4),
                        blurRadius: 6)
                  ])),
          Row(children: [
            Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: widget.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(widget.icon, size: 14, color: widget.accent)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(widget.label,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                        letterSpacing: 0.6))),
          ]),
          const SizedBox(height: 12),
          Text(widget.value,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5)),
        ]),
      ),
    );
  }
}
