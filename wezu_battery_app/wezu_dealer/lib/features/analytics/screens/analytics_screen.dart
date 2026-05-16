import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  String _period = '30d';

  @override
  void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward(); }
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  Widget _stagger(int i, {required Widget child}) {
    final begin = i * 0.12; final end = (begin + 0.4).clamp(0.0, 1.0);
    return AnimatedBuilder(animation: _c, builder: (c, _) {
      final t = Curves.easeOut.transform(((_c.value - begin) / (end - begin)).clamp(0.0, 1.0));
      return Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child));
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
        // Period selector + Export
        _stagger(0, child: Row(children: [
          const Text('Analytics Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const Spacer(),
          ...['7d', '30d', '90d'].map((p) {
            final sel = _period == p;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => setState(() => _period = p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.cyan.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: sel ? AppColors.cyan.withValues(alpha: 0.3) : AppColors.border),
                  ),
                  child: Text(p, style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? AppColors.cyan : AppColors.textSecondary)),
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
          OutlinedButton.icon(icon: const Icon(LucideIcons.download, size: 14), label: const Text('Export', style: TextStyle(fontSize: 12)), onPressed: () {}),
        ])),
        const SizedBox(height: 20),

        // KPI Cards
        _stagger(1, child: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(children: [
              Expanded(child: _KpiCard(label: 'REVENUE', value: currency.format(overview?.revenue ?? 0), icon: LucideIcons.indianRupee, accent: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: _KpiCard(label: 'TOTAL SWAPS', value: '${overview?.totalSwaps ?? 0}', icon: LucideIcons.repeat, accent: AppColors.cyan)),
              const SizedBox(width: 12),
              Expanded(child: _KpiCard(label: 'AVG SWAP DURATION', value: '${overview?.avgSwapDurationHrs ?? 0}h', icon: LucideIcons.clock, accent: AppColors.amber)),
              const SizedBox(width: 12),
              Expanded(child: _KpiCard(label: 'SATISFACTION', value: '${overview?.customerSatisfaction ?? 0} / 5', icon: LucideIcons.star, accent: AppColors.purple)),
            ]),
        ),
        const SizedBox(height: 20),

        // Charts Row 1 — Revenue Trend + Swap Volume
        _stagger(2, child: Row(children: [
          Expanded(child: _ChartContainer(
            title: 'Revenue Trend',
            icon: LucideIcons.trendingUp,
            child: _BarChartWidget(color: AppColors.primary),
          )),
          const SizedBox(width: 14),
          Expanded(child: _ChartContainer(
            title: 'Swap Volume',
            icon: LucideIcons.barChart2,
            child: _BarChartWidget(color: AppColors.cyan),
          )),
        ])),
        const SizedBox(height: 14),

        // Charts Row 2 — Station Utilization + Battery Health
        _stagger(3, child: Row(children: [
          Expanded(child: _ChartContainer(
            title: 'Station Utilization',
            icon: LucideIcons.activity,
            child: _HorizontalBarChart(),
          )),
          const SizedBox(width: 14),
          Expanded(child: _ChartContainer(
            title: 'Battery Health Distribution',
            icon: LucideIcons.batteryCharging,
            child: _DonutChart(),
          )),
        ])),
        const SizedBox(height: 14),

        // Peak Hours Heatmap
        _stagger(4, child: _ChartContainer(
          title: 'Peak Hours',
          icon: LucideIcons.clock,
          child: _PeakHoursGrid(),
        )),
      ]),
    );
  }
}

// Custom chart widgets using CustomPaint

class _BarChartWidget extends StatelessWidget {
  final Color color;
  const _BarChartWidget({required this.color});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        ...List.generate(7, (i) {
          final h = [0.6, 0.8, 0.5, 0.9, 0.7, 0.85, 0.75][i];
          final day = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i];
          return Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 500 + i * 100),
                height: h * 140,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [color, color.withValues(alpha: 0.5)]),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 2))],
                ),
              ),
              const SizedBox(height: 8),
              Text(day, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
            ]),
          );
        }),
      ]),
    );
  }
}

class _HorizontalBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stations = [
      ('Madhapur SwapHub', 0.85, AppColors.primary),
      ('Gachibowli EnergyPoint', 0.72, AppColors.cyan),
      ('Kukatpally Power Center', 0.91, AppColors.primary),
      ('Banjara Hills Station', 0.45, AppColors.amber),
      ('Hitech City Hub', 0.30, AppColors.amber),
    ];

    return Column(children: stations.map((s) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        SizedBox(width: 160, child: Text(s.$1, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        Expanded(child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(height: 10, child: Stack(children: [
            Container(decoration: BoxDecoration(color: AppColors.pageBg, borderRadius: BorderRadius.circular(4))),
            FractionallySizedBox(
              widthFactor: s.$2,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [s.$3, s.$3.withValues(alpha: 0.6)]),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ])),
        )),
        const SizedBox(width: 10),
        Text('${(s.$2 * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: s.$3)),
      ]),
    )).toList());
  }
}

class _DonutChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final segments = [
      ('Good', 65.0, AppColors.primary),
      ('Degraded', 25.0, AppColors.amber),
      ('Critical', 10.0, AppColors.red),
    ];

    return SizedBox(
      height: 180,
      child: Row(children: [
        Expanded(child: CustomPaint(painter: _DonutPainter(segments))),
        const SizedBox(width: 20),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: segments.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: s.$3)),
            const SizedBox(width: 8),
            Text('${s.$1}: ${s.$2.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ]),
        )).toList()),
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
    const startAngle = -1.5708; // -90 degrees in radians
    var sweepStart = startAngle;

    for (final (_, pct, color) in segments) {
      final sweepAngle = (pct / 100) * 2 * 3.14159;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), sweepStart, sweepAngle - 0.04, false, paint);
      sweepStart += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _PeakHoursGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hours = List.generate(24, (i) => i);
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(children: [
      Row(children: [
        const SizedBox(width: 40),
        ...hours.where((h) => h % 3 == 0).map((h) => Expanded(child: Text('${h}:00', textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: AppColors.textTertiary)))),
      ]),
      ...days.map((day) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: [
          SizedBox(width: 40, child: Text(day, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary))),
          ...hours.where((h) => h % 3 == 0).map((h) {
            final intensity = ((h >= 7 && h <= 10) || (h >= 17 && h <= 20)) ? 0.8 : (h >= 11 && h <= 16) ? 0.5 : 0.15;
            return Expanded(child: Container(
              height: 20, margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: intensity),
                borderRadius: BorderRadius.circular(3),
              ),
            ));
          }),
        ]),
      )),
    ]);
  }
}

class _ChartContainer extends StatelessWidget {
  final String title; final IconData icon; final Widget child;
  const _ChartContainer({required this.title, required this.icon, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ]),
        const SizedBox(height: 18),
        child,
      ]),
    );
  }
}

class _KpiCard extends StatefulWidget {
  final String label, value; final IconData icon; final Color accent;
  const _KpiCard({required this.label, required this.value, required this.icon, required this.accent});
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
          border: Border.all(color: _hovered ? widget.accent.withValues(alpha: 0.2) : AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 2, margin: const EdgeInsets.only(bottom: 14), decoration: BoxDecoration(color: widget.accent, borderRadius: BorderRadius.circular(1), boxShadow: [BoxShadow(color: widget.accent.withValues(alpha: 0.4), blurRadius: 6)])),
          Row(children: [
            Container(width: 28, height: 28, decoration: BoxDecoration(color: widget.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: Icon(widget.icon, size: 14, color: widget.accent)),
            const SizedBox(width: 10),
            Expanded(child: Text(widget.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.6))),
          ]),
          const SizedBox(height: 12),
          Text(widget.value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5)),
        ]),
      ),
    );
  }
}
