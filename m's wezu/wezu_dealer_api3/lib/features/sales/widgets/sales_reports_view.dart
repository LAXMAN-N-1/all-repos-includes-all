import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/colors.dart';

class SalesReportsView extends StatelessWidget {
  final bool showMonthly;
  const SalesReportsView({super.key, this.showMonthly = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),
        if (!showMonthly) _buildWeeklyReport() else _buildMonthlyReport(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(
            showMonthly ? LucideIcons.calendarDays : LucideIcons.calendarRange,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Text(
            showMonthly ? 'Monthly Revenue Report' : 'Weekly Revenue Report',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Exporting ${showMonthly ? 'monthly' : 'weekly'} report as CSV..."),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(LucideIcons.download, size: 14),
            label: const Text('Export Report', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildWeeklyReport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildReportMetric('Total Revenue', '₹84,250', Colors.white),
            const SizedBox(width: 24),
            _buildReportMetric('Net Revenue', '₹76,100', Colors.green),
            const SizedBox(width: 24),
            _buildReportMetric('Total TXNs', '142', AppColors.cyan),
          ],
        ),
        const SizedBox(height: 32),
        _buildWeeklyChart(),
        const SizedBox(height: 32),
        _buildWeeklyTable(),
      ],
    );
  }

  Widget _buildMonthlyReport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildReportMetric('Monthly Revenue', '₹3,42,100', Colors.white),
            const SizedBox(width: 24),
            _buildReportMetric('Average Daily', '₹11,403', AppColors.cyan),
            const SizedBox(width: 24),
            _buildReportMetric('Growth', '+12.5%', Colors.green),
          ],
        ),
        const SizedBox(height: 32),
        _buildMonthlyChart(),
        const SizedBox(height: 32),
        _buildMonthlyTable(),
      ],
    );
  }

  Widget _buildReportMetric(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor, fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
      height: 240,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 20000,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(days[value.toInt()], style: const TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            _makeGroupData(0, 12000),
            _makeGroupData(1, 15000),
            _makeGroupData(2, 18000, isHighest: true),
            _makeGroupData(3, 14000),
            _makeGroupData(4, 9000),
            _makeGroupData(5, 11000),
            _makeGroupData(6, 13000),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, {bool isHighest = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isHighest ? AppColors.primary : AppColors.primary.withOpacity(0.3),
          width: 22,
          borderRadius: BorderRadius.circular(4),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20000,
            color: AppColors.pageBg,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyChart() {
    return Container(
      height: 240,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(color: AppColors.border.withOpacity(0.5), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (v, m) => Text('${v.toInt()}', style: const TextStyle(color: AppColors.textTertiary, fontSize: 10)),
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(1, 10000), FlSpot(5, 12000), FlSpot(10, 11000), FlSpot(15, 15000), FlSpot(20, 13000), FlSpot(25, 18000), FlSpot(30, 14000),
              ],
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.1)),
            ),
            LineChartBarData(
              spots: const [FlSpot(1, 13500), FlSpot(30, 13500)],
              dashArray: [5, 5],
              color: AppColors.textTertiary.withOpacity(0.5),
              barWidth: 1,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyTable() {
    return _buildReportTable(
      columns: ['Day', 'Gross Revenue', 'TXNs', 'Refunds', 'Commission', 'Net Revenue', ''],
      rows: [
        ['Monday', '₹12,000', '21', '₹0', '₹600', '₹11,400'],
        ['Tuesday', '₹15,000', '25', '₹500', '₹750', '₹13,750'],
        ['Wednesday', '₹18,000', '32', '₹0', '₹900', '₹17,100'],
        ['Thursday', '₹14,000', '24', '₹0', '₹700', '₹13,300'],
        ['Friday', '₹9,000', '16', '₹1,000', '₹450', '₹7,550'],
        ['Saturday', '₹11,000', '12', '₹0', '₹550', '₹10,450'],
        ['Sunday', '₹13,000', '12', '₹0', '₹650', '₹12,350'],
      ].map((r) => [...r, 'view']).toList(),
      totals: ['Total', '₹84,250', '142', '₹1,500', '₹4,213', '₹76,100', ''],
    );
  }

  Widget _buildMonthlyTable() {
    return _buildReportTable(
      columns: ['Week', 'Gross Revenue', 'TXNs', 'Refunds', 'Commission', 'Net Revenue', ''],
      rows: [
        ['Week 1', '₹72,000', '122', '₹2,000', '₹3,600', '₹66,400'],
        ['Week 2', '₹84,250', '142', '₹1,500', '₹4,213', '₹76,100'],
        ['Week 3', '₹91,000', '156', '₹3,000', '₹4,550', '₹83,450'],
        ['Week 4', '₹94,850', '168', '₹1,000', '₹4,743', '₹89,107'],
      ].map((r) => [...r, 'view']).toList(),
      totals: ['Month Total', '₹3,42,100', '588', '₹7,500', '₹17,106', '₹315,057', ''],
    );
  }

  Widget _buildReportTable({required List<String> columns, required List<List<String>> rows, required List<String> totals}) {
    return Container(
      constraints: const BoxConstraints(minWidth: 800),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.pageBg),
            columns: columns.map((c) => DataColumn(label: Text(c, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12, fontWeight: FontWeight.bold)))).toList(),
            rows: [
              ...rows.map((row) => DataRow(
                cells: [
                  ...row.sublist(0, row.length - 1).map((cell) => DataCell(Text(cell, style: const TextStyle(color: Colors.white, fontSize: 13)))),
                  DataCell(
                    Builder(builder: (context) {
                      return IconButton(
                        onPressed: () => _showDayDetail(context, row[0]),
                        icon: const Icon(LucideIcons.eye, size: 14, color: AppColors.textTertiary),
                      );
                    }),
                  ),
                ],
              )),
              DataRow(
                color: WidgetStateProperty.all(AppColors.primary.withOpacity(0.05)),
                cells: [
                   ...totals.sublist(0, totals.length - 1).map((t) => DataCell(Text(t, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)))),
                   const DataCell(SizedBox.shrink()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDayDetail(BuildContext context, String day) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DailySummaryDrawer(day: day),
    );
  }
}

class _DailySummaryDrawer extends StatelessWidget {
  final String day;
  const _DailySummaryDrawer({required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Summary for $day', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x, color: AppColors.textTertiary)),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow('Morning Sessions', '₹4,500 (12 rentals)'),
          _buildInfoRow('Afternoon Sessions', '₹5,200 (15 rentals)'),
          _buildInfoRow('Evening Sessions', '₹2,300 (5 rentals)'),
          _buildInfoRow('Top Performing Station', 'Station A-12 (Dwarka)'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
