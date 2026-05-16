import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';

class BatteryMonitoringScreen extends ConsumerStatefulWidget {
  final String rentalId;
  const BatteryMonitoringScreen({super.key, required this.rentalId});

  @override
  ConsumerState<BatteryMonitoringScreen> createState() => _BatteryMonitoringScreenState();
}

class _BatteryMonitoringScreenState extends ConsumerState<BatteryMonitoringScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          children: [
            Text("Battery Monitor", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text("Live Connection", style: GoogleFonts.inter(fontSize: 10, color: Colors.green)),
              ],
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // 1. Core Metrics Grid
            _buildMetricsGrid(context, isDark),
            const SizedBox(height: 32),
            
            // 2. Historical Charts
            _buildChartSection(context, "Charge History (%)", AppTheme.primaryBlue, isDark),
            const SizedBox(height: 24),
            _buildChartSection(context, "Temperature (°C)", Colors.orange, isDark),
            const SizedBox(height: 32),

            // 3. Alerts Section
            _buildAlertsSection(context, isDark),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: Responsive.gridColumns(context),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _metricCard("Charge", "75%", LucideIcons.batteryCharging, Colors.blue, isDark),
        _metricCard("Health", "95%", LucideIcons.heartPulse, Colors.green, isDark),
        _metricCard("Temp", "28°C", LucideIcons.thermometer, Colors.orange, isDark),
        _metricCard("Voltage", "12.4V", LucideIcons.zap, Colors.purple, isDark),
      ],
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.shadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildChartSection(BuildContext context, String title, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.shadowLight,
          ),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 70),
                    const FlSpot(1, 72),
                    const FlSpot(2, 71),
                    const FlSpot(3, 75),
                    const FlSpot(4, 73),
                    const FlSpot(5, 75),
                  ],
                  isCurved: true,
                  color: color,
                  barWidth: 4,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Recent Alerts", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Clear All", style: GoogleFonts.inter(fontSize: 12, color: AppTheme.primaryBlue)),
          ],
        ),
        const SizedBox(height: 16),
        _alertItem("High temperature detected", "28 Oct, 3:45 PM", LucideIcons.alertTriangle, Colors.orange, isDark),
        const SizedBox(height: 12),
        _alertItem("Low battery warning (20%)", "28 Oct, 1:20 PM", LucideIcons.batteryLow, Colors.red, isDark),
      ],
    );
  }

  Widget _alertItem(String msg, String time, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.shadowLight,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(msg, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(time, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}