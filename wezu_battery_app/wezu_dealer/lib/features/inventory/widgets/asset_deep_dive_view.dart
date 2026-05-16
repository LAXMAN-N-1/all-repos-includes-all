import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/colors.dart';
import '../models/inventory_state.dart';
import '../providers/inventory_provider.dart';

/// Asset Deep-Dive View — shown in the right panel when a battery row is selected.
/// Contains: Asset Header, Tab Navigation (Telemetry & Health / Lifecycle Log).
class AssetDeepDiveView extends ConsumerStatefulWidget {
  final BatteryItemDto battery;

  const AssetDeepDiveView({super.key, required this.battery});

  @override
  ConsumerState<AssetDeepDiveView> createState() => _AssetDeepDiveViewState();
}

class _AssetDeepDiveViewState extends ConsumerState<AssetDeepDiveView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _healthColor(double pct) {
    if (pct >= 90) return AppColors.primary;
    if (pct >= 80) return AppColors.amber;
    return AppColors.red;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AppColors.primary;
      case 'reserved':
      case 'rented':
        return const Color(0xFF1A73E8);
      case 'maintenance':
      case 'charging':
        return AppColors.amber;
      case 'retired':
      case 'damaged':
        return AppColors.red;
      default:
        return AppColors.textTertiary;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Available';
      case 'reserved':
        return 'Reserved';
      case 'rented':
        return 'Rented';
      case 'maintenance':
        return 'Maintenance';
      case 'charging':
        return 'Charging';
      case 'retired':
        return 'Damaged';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.battery;
    final sohColor = _healthColor(b.health.percentage);
    final stColor = _statusColor(b.currentStatus);

    return Column(
      children: [
        // Asset Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.pageBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    ref.read(selectedBatteryProvider.notifier).state = null;
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      LucideIcons.x,
                      size: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),

              // Large battery SVG-style graphic
              _LargeBatteryGraphic(
                socPercent: b.charge.percentage,
                color: sohColor,
              ),
              const SizedBox(height: 12),

              // Battery ID
              Text(
                b.serialNumber,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'monospace',
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: stColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: stColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _statusLabel(b.currentStatus),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: stColor,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Three action buttons
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _DeepDiveActionBtn(
                    icon: LucideIcons.xCircle,
                    label: 'Defective',
                    color: AppColors.red,
                    onTap: () {},
                  ),
                  _DeepDiveActionBtn(
                    icon: LucideIcons.userPlus,
                    label: 'Assign',
                    color: const Color(0xFF1A73E8),
                    onTap: () {},
                    enabled: b.currentStatus.toLowerCase() == 'available',
                  ),
                  _DeepDiveActionBtn(
                    icon: LucideIcons.activity,
                    label: 'IoT Feed',
                    color: AppColors.primary,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),

        // Tab bar
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 0.5),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textTertiary,
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 2,
            dividerHeight: 0,
            tabs: const [
              Tab(text: 'Telemetry & Health'),
              Tab(text: 'Lifecycle Log'),
            ],
          ),
        ),

        // Tab views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _TelemetryTab(battery: b),
              _LifecycleLogTab(battery: b),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tab 1 — Telemetry & Health
class _TelemetryTab extends ConsumerWidget {
  final BatteryItemDto battery;
  const _TelemetryTab({required this.battery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telemetryAsync = ref.watch(batteryTelemetryProvider(battery.batteryId));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // T1-1: SOC Over Time Line Chart
        const Text(
          'SOC & Temperature — 72 Hours',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 160,
          child: telemetryAsync.when(
            data: (points) => _SocChart(points: points),
            loading: () => const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
            error: (e, _) => Center(
              child: Text(
                'Failed to load telemetry',
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // T1-3: Live Metrics Row (2x2)
        const Text(
          'LIVE METRICS',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                label: 'Voltage',
                value: '48.2V',
                icon: LucideIcons.zap,
                status: 'normal',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                label: 'Temperature',
                value: '32°C',
                icon: LucideIcons.thermometer,
                status: 'normal',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                label: 'Resistance',
                value: '12mΩ',
                icon: LucideIcons.radio,
                status: 'normal',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                label: 'SOC',
                value: '${battery.charge.percentage.toStringAsFixed(0)}%',
                icon: LucideIcons.battery,
                status: battery.charge.percentage > 20 ? 'normal' : 'warning',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // T1-4: Key Dates
        const Text(
          'KEY DATES',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _DateItem(
                label: 'Commissioned',
                value: battery.updatedAt ?? '—',
              ),
            ),
            Expanded(
              child: _DateItem(
                label: 'Last Maint.',
                value: battery.health.lastTestDate ?? '—',
              ),
            ),
            Expanded(
              child: _DateItem(
                label: 'Next Maint.',
                value: '—',
                isWarning: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// SOC Line Chart using fl_chart
class _SocChart extends StatelessWidget {
  final List<TelemetryPointDto> points;
  const _SocChart({required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(
        child: Text(
          'No telemetry data available',
          style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
        ),
      );
    }

    final socSpots = <FlSpot>[];
    final tempSpots = <FlSpot>[];

    for (int i = 0; i < points.length; i++) {
      socSpots.add(FlSpot(i.toDouble(), points[i].soc));
      tempSpots.add(FlSpot(i.toDouble(), points[i].temperature));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.border.withValues(alpha: 0.3),
            strokeWidth: 0.5,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 25,
              getTitlesWidget: (val, meta) => Text(
                '${val.toInt()}%',
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 10,
              getTitlesWidget: (val, meta) => Text(
                '${val.toInt()}°',
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.amber,
                ),
              ),
            ),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          // SOC line
          LineChartBarData(
            spots: socSpots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          // Temperature line
          LineChartBarData(
            spots: tempSpots,
            isCurved: true,
            color: AppColors.amber.withValues(alpha: 0.6),
            barWidth: 1.5,
            dotData: const FlDotData(show: false),
            dashArray: [4, 3],
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.cardBg,
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final isSoc = spot.barIndex == 0;
                return LineTooltipItem(
                  isSoc
                      ? 'SOC: ${spot.y.toStringAsFixed(1)}%'
                      : 'Temp: ${spot.y.toStringAsFixed(1)}°C',
                  TextStyle(
                    color: isSoc ? AppColors.primary : AppColors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
      duration: const Duration(milliseconds: 800),
    );
  }
}

/// Tab 2 — Lifecycle Log
class _LifecycleLogTab extends StatelessWidget {
  final BatteryItemDto battery;
  const _LifecycleLogTab({required this.battery});

  IconData _eventIcon(String type) {
    switch (type) {
      case 'swap_out':
        return LucideIcons.arrowLeftRight;
      case 'swap_in':
        return LucideIcons.hand;
      case 'firmware_update':
        return LucideIcons.uploadCloud;
      case 'maintenance':
        return LucideIcons.wrench;
      case 'created':
      case 'received':
        return LucideIcons.package;
      case 'status_changed_to_retired':
      case 'defective':
        return LucideIcons.xCircle;
      case 'repaired':
        return LucideIcons.checkCircle;
      default:
        return LucideIcons.clock;
    }
  }

  Color _eventColor(String type) {
    switch (type) {
      case 'swap_out':
        return AppColors.primary;
      case 'swap_in':
        return const Color(0xFF1A73E8);
      case 'firmware_update':
        return AppColors.purple;
      case 'maintenance':
        return AppColors.amber;
      case 'created':
      case 'received':
        return AppColors.textSecondary;
      case 'status_changed_to_retired':
      case 'defective':
        return AppColors.red;
      case 'repaired':
        return AppColors.primary;
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build events dynamically from real battery state fields
    final events = <Map<String, String>>[];

    final status = battery.currentStatus.toLowerCase();

    if (status == 'retired' || status == 'defective') {
      events.add({
        'type': 'defective',
        'time': battery.updatedAt ?? '',
        'actor': 'System',
        'desc': battery.faultReason ?? 'Battery flagged for inspection',
      });
    } else if (status == 'maintenance') {
      events.add({
        'type': 'maintenance',
        'time': battery.updatedAt ?? '',
        'actor': 'System',
        'desc': battery.notes ?? 'Scheduled maintenance in progress',
      });
    } else if (status == 'rented') {
      events.add({
        'type': 'swap_out',
        'time': battery.updatedAt ?? '',
        'actor': 'System',
        'desc': 'Battery currently rented to a customer',
      });
    } else if (status == 'charging') {
      events.add({
        'type': 'firmware_update',
        'time': battery.updatedAt ?? '',
        'actor': 'Station',
        'desc': 'Battery is currently charging at ${battery.location.stationName.isNotEmpty ? battery.location.stationName : "station"}',
      });
    }

    if (battery.cycleCount > 0) {
      events.add({
        'type': 'swap_in',
        'time': battery.updatedAt ?? '',
        'actor': 'BMS',
        'desc': '${battery.cycleCount} charge/discharge cycles recorded',
      });
    }

    if (battery.notes != null && battery.notes!.isNotEmpty && status != 'maintenance') {
      events.add({
        'type': 'received',
        'time': battery.updatedAt ?? '',
        'actor': 'System',
        'desc': battery.notes!,
      });
    }

    if (events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.clock, size: 36, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text(
              'No lifecycle events recorded yet',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, i) {
        final event = events[i];
        final type = event['type'] ?? '';
        final color = _eventColor(type);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline line + icon
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        _eventIcon(type),
                        size: 12,
                        color: color,
                      ),
                    ),
                    if (i < events.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: AppColors.border,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Event content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['desc'] ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            event['actor'] ?? '',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            event['time'] ?? '',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Large Battery Graphic with dynamic SOC fill
class _LargeBatteryGraphic extends StatelessWidget {
  final double socPercent;
  final Color color;

  const _LargeBatteryGraphic({
    required this.socPercent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 80,
      child: CustomPaint(
        painter: _LargeBatteryPainter(
          socPercent: socPercent,
          fillColor: color,
        ),
      ),
    );
  }
}

class _LargeBatteryPainter extends CustomPainter {
  final double socPercent;
  final Color fillColor;

  _LargeBatteryPainter({
    required this.socPercent,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = AppColors.textTertiary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Battery tip (top)
    final tipWidth = size.width * 0.35;
    final tipLeft = (size.width - tipWidth) / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tipLeft, 0, tipWidth, 6),
        const Radius.circular(2),
      ),
      borderPaint..style = PaintingStyle.fill,
    );

    // Battery body
    final bodyTop = 6.0;
    final bodyHeight = size.height - bodyTop;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, bodyTop, size.width, bodyHeight),
      const Radius.circular(6),
    );
    canvas.drawRRect(bodyRect, borderPaint..style = PaintingStyle.stroke);

    // Fill from bottom
    final fillHeight = bodyHeight * (socPercent / 100).clamp(0.0, 1.0);
    if (fillHeight > 0) {
      final fillRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(
          2,
          bodyTop + bodyHeight - fillHeight + 2,
          size.width - 4,
          fillHeight - 4,
        ),
        bottomLeft: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
        topLeft: Radius.circular(fillHeight > bodyHeight * 0.9 ? 4 : 0),
        topRight: Radius.circular(fillHeight > bodyHeight * 0.9 ? 4 : 0),
      );

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            fillColor.withValues(alpha: 0.7),
            fillColor,
          ],
        ).createShader(fillRect.outerRect);

      canvas.drawRRect(fillRect, fillPaint);

      // Glow effect
      canvas.drawRRect(
        fillRect,
        Paint()
          ..color = fillColor.withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LargeBatteryPainter oldDelegate) =>
      oldDelegate.socPercent != socPercent ||
      oldDelegate.fillColor != fillColor;
}

/// Compact action button used in the deep-dive header
class _DeepDiveActionBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  const _DeepDiveActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });

  @override
  State<_DeepDiveActionBtn> createState() => _DeepDiveActionBtnState();
}

class _DeepDiveActionBtnState extends State<_DeepDiveActionBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        widget.enabled ? widget.color : AppColors.textMuted;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _hovered
                ? effectiveColor.withValues(alpha: 0.12)
                : effectiveColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: effectiveColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 12, color: effectiveColor),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: effectiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Metric tile in the telemetry tab (2x2 grid)
class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String status; // 'normal', 'warning', 'critical'

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = status == 'normal'
        ? AppColors.primary
        : (status == 'warning' ? AppColors.amber : AppColors.red);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pageBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: AppColors.textTertiary),
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                  boxShadow: [
                    BoxShadow(
                      color: dotColor.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
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
      ),
    );
  }
}

/// Date item for key dates row
class _DateItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isWarning;

  const _DateItem({
    required this.label,
    required this.value,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    String displayVal = value;
    if (value != '—') {
      try {
        final dt = DateTime.parse(value);
        displayVal =
            '${dt.day}/${dt.month}/${dt.year}';
      } catch (_) {}
    }

    return Column(
      children: [
        Text(
          displayVal,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isWarning ? AppColors.amber : AppColors.textPrimary,
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
