import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  String _selectedPeriod = 'February 2024';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for analytics
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Business Intelligence Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Period: $_selectedPeriod', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.refresh, size: 16), label: const Text('Refresh')),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {}, 
                      icon: const Icon(Icons.download, size: 16), 
                      label: const Text('Export'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary500, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // KPI Grid
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildKpiCard('Total GMV', '₹1.45 Cr', '+15% MoM', Colors.blue),
                  const SizedBox(width: 16),
                  _buildKpiCard('Platform Revenue', '₹23.7 L', '+12% MoM', Colors.green),
                  const SizedBox(width: 16),
                  _buildKpiCard('Active Users', '4,890', '+8% MoM', Colors.purple),
                  const SizedBox(width: 16),
                  _buildKpiCard('Conversion Rate', '42%', '+3% MoM', Colors.orange),
                   const SizedBox(width: 16),
                  _buildKpiCard('NPS Score', '68', '+3 pts', Colors.teal),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Main Charts Row
            Row(
              children: [
                Expanded(flex: 2, child: _buildRevenueChart()),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildCategoryPieChart()),
              ],
            ),
             const SizedBox(height: 24),

             // Booking Funnel & Geo
             Row(
               children: [
                 Expanded(child: _buildFunnelChart()),
                 const SizedBox(width: 24),
                 Expanded(child: _buildGeoMapPlaceholder()),
               ],
             ),
             const SizedBox(height: 24),

             // Vendor Perf Table
             _buildTopVendorsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, String trend, Color color) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.trending_up, size: 14, color: color),
              const SizedBox(width: 4),
              Text(trend, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Revenue Trend (6 Months)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: const FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 100), FlSpot(1, 120), FlSpot(2, 140), FlSpot(3, 130), FlSpot(4, 160), FlSpot(5, 180)],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Revenue by Source', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(color: Colors.blue, value: 78, title: '78%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: Colors.orange, value: 13, title: '13%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: Colors.green, value: 5, title: '9%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegendItem(Colors.blue, 'Commissions (78%)'),
          _buildLegendItem(Colors.orange, 'Service Fees (13%)'),
          _buildLegendItem(Colors.green, 'Featured & Subs (9%)'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [Container(width: 12, height: 12, color: color), const SizedBox(width: 8), Text(text, style: const TextStyle(fontSize: 12))]),
    );
  }

  Widget _buildFunnelChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Conversion Funnel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          _buildFunnelBar('Site Visits', 100, Colors.grey.shade300),
          _buildFunnelBar('Requests', 32, Colors.blue.shade200),
          _buildFunnelBar('Quotes Sent', 27, Colors.blue.shade400),
          _buildFunnelBar('Bookings', 13.5, Colors.blue.shade700),
        ],
      ),
    );
  }

  Widget _buildFunnelBar(String label, double pct, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 12))),
          Expanded(
            child: Stack(
              children: [
                Container(height: 20, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4))),
                FractionallySizedBox(widthFactor: pct / 100, child: Container(height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('${pct.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGeoMapPlaceholder() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Geographic Distribution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Spacer(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('Revenue Heatmap Placeholder', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildTopVendorsTable() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Top Performing Vendors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton(onPressed: (){}, child: const Text('View All')),
          ]),
          const SizedBox(height: 16),
          Table(
            border: TableBorder(horizontalInside: BorderSide(color: Colors.grey.shade100)),
            children: const [
              TableRow(children: [
                Padding(padding: EdgeInsets.all(8), child: Text('RANK', style: TextStyle(color: Colors.grey, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8), child: Text('VENDOR', style: TextStyle(color: Colors.grey, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8), child: Text('REVENUE', style: TextStyle(color: Colors.grey, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8), child: Text('RATING', style: TextStyle(color: Colors.grey, fontSize: 12))),
              ]),
              TableRow(children: [
                Padding(padding: EdgeInsets.all(12), child: Text('🥇 1')),
                Padding(padding: EdgeInsets.all(12), child: Text('Royal Wedding Co.', style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(padding: EdgeInsets.all(12), child: Text('₹9.5 L')),
                Padding(padding: EdgeInsets.all(12), child: Text('⭐ 4.9')),
              ]),
              TableRow(children: [
                Padding(padding: EdgeInsets.all(12), child: Text('🥈 2')),
                Padding(padding: EdgeInsets.all(12), child: Text('ABC Events', style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(padding: EdgeInsets.all(12), child: Text('₹7.8 L')),
                Padding(padding: EdgeInsets.all(12), child: Text('⭐ 4.8')),
              ]),
              TableRow(children: [
                Padding(padding: EdgeInsets.all(12), child: Text('🥉 3')),
                Padding(padding: EdgeInsets.all(12), child: Text('Dream Events', style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(padding: EdgeInsets.all(12), child: Text('₹6.2 L')),
                Padding(padding: EdgeInsets.all(12), child: Text('⭐ 4.7')),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
