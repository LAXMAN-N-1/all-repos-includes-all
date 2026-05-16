import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class MISDashboardScreen extends StatefulWidget {
  const MISDashboardScreen({super.key});

  @override
  State<MISDashboardScreen> createState() => _MISDashboardScreenState();
}

class _MISDashboardScreenState extends State<MISDashboardScreen> {
  String _dateRange = 'month';

  // Mock Data
  final revenueData = [
    {'month': 'Jan', 'revenue': 450000.0, 'expenses': 280000.0, 'profit': 170000.0, 'target': 500000.0},
    {'month': 'Feb', 'revenue': 520000.0, 'expenses': 310000.0, 'profit': 210000.0, 'target': 500000.0},
    {'month': 'Mar', 'revenue': 480000.0, 'expenses': 290000.0, 'profit': 190000.0, 'target': 500000.0},
    {'month': 'Apr', 'revenue': 610000.0, 'expenses': 340000.0, 'profit': 270000.0, 'target': 550000.0},
    {'month': 'May', 'revenue': 580000.0, 'expenses': 320000.0, 'profit': 260000.0, 'target': 550000.0},
    {'month': 'Jun', 'revenue': 720000.0, 'expenses': 380000.0, 'profit': 340000.0, 'target': 600000.0},
  ];

  final eventPerformanceData = [
    {'category': 'Corporate Events', 'count': 45, 'revenue': 1250000.0, 'avgRevenue': 27777.0},
    {'category': 'Weddings', 'count': 38, 'revenue': 1520000.0, 'avgRevenue': 40000.0},
    {'category': 'Social Events', 'count': 52, 'revenue': 890000.0, 'avgRevenue': 17115.0},
    {'category': 'Conferences', 'count': 28, 'revenue': 980000.0, 'avgRevenue': 35000.0},
    {'category': 'Exhibitions', 'count': 22, 'revenue': 760000.0, 'avgRevenue': 34545.0},
  ];

  final vendorPerformanceData = [
    {'name': 'Catering', 'revenue': 1450000.0, 'count': 85, 'rating': 4.7},
    {'name': 'Venues', 'revenue': 1230000.0, 'count': 62, 'rating': 4.6},
    {'name': 'Decoration', 'revenue': 890000.0, 'count': 78, 'rating': 4.5},
    {'name': 'Photography', 'revenue': 720000.0, 'count': 65, 'rating': 4.8},
    {'name': 'Entertainment', 'revenue': 560000.0, 'count': 48, 'rating': 4.6},
    {'name': 'Transportation', 'revenue': 380000.0, 'count': 42, 'rating': 4.4},
  ];

  final regionalData = [
    {'region': 'North', 'events': 68, 'revenue': 1850000.0, 'growth': 12.5, 'color': const Color(0xFFFDB913)},
    {'region': 'South', 'events': 52, 'revenue': 1420000.0, 'growth': 8.3, 'color': const Color(0xFF10B981)},
    {'region': 'East', 'events': 45, 'revenue': 1120000.0, 'growth': 15.2, 'color': const Color(0xFF3B82F6)},
    {'region': 'West', 'events': 60, 'revenue': 1610000.0, 'growth': 10.1, 'color': const Color(0xFFA855F7)},
  ];

  // Radar Chart Data
  final customerSatisfactionData = [
    {'aspect': 'Service Quality', 'score': 4.7, 'fullMark': 5.0},
    {'aspect': 'Vendor Coordination', 'score': 4.5, 'fullMark': 5.0},
    {'aspect': 'Value for Money', 'score': 4.3, 'fullMark': 5.0},
    {'aspect': 'Communication', 'score': 4.6, 'fullMark': 5.0},
    {'aspect': 'Timeliness', 'score': 4.4, 'fullMark': 5.0},
    {'aspect': 'Problem Resolution', 'score': 4.2, 'fullMark': 5.0},
  ];

  final bookingTrendsData = [
    {'week': 'Week 1', 'bookings': 18.0, 'cancellations': 2.0, 'conversions': 16.0},
    {'week': 'Week 2', 'bookings': 22.0, 'cancellations': 1.0, 'conversions': 21.0},
    {'week': 'Week 3', 'bookings': 25.0, 'cancellations': 3.0, 'conversions': 22.0},
    {'week': 'Week 4', 'bookings': 28.0, 'cancellations': 2.0, 'conversions': 26.0},
  ];

  final paymentDistribution = [
    {'name': 'Advance Received', 'value': 2450000.0, 'percentage': 45, 'color': const Color(0xFF10B981)},
    {'name': 'Final Payments', 'value': 2180000.0, 'percentage': 40, 'color': const Color(0xFFFDB913)},
    {'name': 'Pending', 'value': 680000.0, 'percentage': 12, 'color': const Color(0xFFF59E0B)},
    {'name': 'Overdue', 'value': 160000.0, 'percentage': 3, 'color': const Color(0xFFEF4444)},
  ];

  @override
  Widget build(BuildContext context) {
    final totalRevenue = revenueData.fold(0.0, (sum, item) => sum + (item['revenue'] as double));
    final totalProfit = revenueData.fold(0.0, (sum, item) => sum + (item['profit'] as double));
    final profitMargin = ((totalProfit / totalRevenue) * 100).toStringAsFixed(1);
    final revenueGrowth = (((revenueData.last['revenue'] as double) - (revenueData.first['revenue'] as double)) / (revenueData.first['revenue'] as double) * 100).toStringAsFixed(1);
    final totalEvents = eventPerformanceData.fold(0, (sum, item) => sum + (item['count'] as int));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFFFDB913), Color(0xFFE5A711)]).createShader(bounds),
                      child: Text('MIS Dashboard', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const SizedBox(height: 4),
                    Text('Comprehensive management information and analytics', style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _dateRange,
                          items: const [
                            DropdownMenuItem(value: 'week', child: Text('Last Week')),
                            DropdownMenuItem(value: 'month', child: Text('Last Month')),
                            DropdownMenuItem(value: 'quarter', child: Text('Last Quarter')),
                            DropdownMenuItem(value: 'year', child: Text('This Year')),
                          ],
                          onChanged: (v) => setState(() => _dateRange = v!),
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[800]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                     ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Export'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFDB913),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // KPI Grid
            GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.8,
              children: [
                _StatCard(title: 'Total Revenue', value: '₹${(totalRevenue / 100000).toStringAsFixed(1)}L', subText: 'Last 6 months', growth: '+$revenueGrowth%', icon: Icons.currency_rupee, color: const Color(0xFFFDB913), bgColor: const Color(0xFFFEF9E7)),
                _StatCard(title: 'Net Profit', value: '₹${(totalProfit / 100000).toStringAsFixed(1)}L', subText: 'Margin: $profitMargin%', growth: '$profitMargin%', icon: Icons.trending_up, color: Colors.green, bgColor: Colors.green[50]!),
                _StatCard(title: 'Total Events', value: '$totalEvents', subText: 'This period', growth: '+8.2%', icon: Icons.calendar_today, color: Colors.blue, bgColor: Colors.blue[50]!),
                _StatCard(title: 'Active Clients', value: '342', subText: 'Client base growth', growth: '+12.5%', icon: Icons.people, color: Colors.amber, bgColor: Colors.amber[50]!),
              ],
            ),
            const SizedBox(height: 24),

            // Annual Revenue & Payment Distribution
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 400,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Revenue & Profit Trends', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        Expanded(
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true, drawVerticalLine: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, _) => Text('${val ~/ 1000}k', style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, _) {
                                  if (val.toInt() >= 0 && val.toInt() < revenueData.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(revenueData[val.toInt()]['month'] as String, style: const TextStyle(fontSize: 10, color: Colors.grey)));
                                  return const SizedBox();
                                })),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: revenueData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['revenue'] as double)).toList(),
                                  color: const Color(0xFFFDB913), isCurved: true, dotData: FlDotData(show: false),
                                  belowBarData: BarAreaData(show: true, color: const Color(0xFFFDB913).withOpacity(0.1)),
                                ),
                                LineChartBarData(
                                  spots: revenueData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['profit'] as double)).toList(),
                                  color: const Color(0xFF10B981), isCurved: true, dotData: FlDotData(show: false),
                                  belowBarData: BarAreaData(show: true, color: const Color(0xFF10B981).withOpacity(0.1)),
                                ),
                              ],
                            ),
                          ),
                        ),
                         const SizedBox(height: 8),
                        const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          _ChartLegend(color: Color(0xFFFDB913), label: 'Revenue'),
                          SizedBox(width: 16),
                          _ChartLegend(color: Color(0xFF10B981), label: 'Profit'),
                        ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 400,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment Distribution', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2, centerSpaceRadius: 40,
                              sections: paymentDistribution.map((d) => PieChartSectionData(color: d['color'] as Color, value: d['value'] as double, title: '${d['percentage']}%', radius: 80, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white))).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: paymentDistribution.map((d) => _ChartLegend(color: d['color'] as Color, label: d['name'] as String)).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
             // Event Performance
            Container(
              height: 400,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Event Performance by Category', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        gridData: FlGridData(show: true, drawVerticalLine: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, _) => Text('${val.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, _) {
                            if (val.toInt() >= 0 && val.toInt() < eventPerformanceData.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(eventPerformanceData[val.toInt()]['category'] as String, style: const TextStyle(fontSize: 10, color: Colors.grey)));
                            return const SizedBox();
                          })),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                           rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        barGroups: eventPerformanceData.asMap().entries.map((e) {
                          // Simple bar for count. Could use dual bar for revenue.
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(toY: (e.value['count'] as int).toDouble(), color: const Color(0xFF3B82F6), width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
             const SizedBox(height: 24),
            
            // Vendors & Regional
             Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Top Vendor Categories', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                         const SizedBox(height: 16),
                        ...vendorPerformanceData.map((v) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text(v['name'] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
                                Row(children: [
                                   Text('${v['count']} vendors', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                   const SizedBox(width: 8),
                                    Text('₹${(v['revenue'] as double) ~/ 1000}K', style: const TextStyle(color: Color(0xFFFDB913), fontWeight: FontWeight.bold, fontSize: 13)),
                                ]),
                              ]),
                               const SizedBox(height: 8),
                              LinearProgressIndicator(value: (v['revenue'] as double) / 1500000, backgroundColor: Colors.grey[100], color: const Color(0xFFFDB913), minHeight: 6, borderRadius: BorderRadius.circular(3)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text('Regional Performance', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                         ...regionalData.map((r) => Container(
                           margin: const EdgeInsets.only(bottom: 12),
                           padding: const EdgeInsets.all(16),
                           decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                           child: Row(
                             children: [
                               Container(
                                 width: 40, height: 40,
                                 decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [(r['color'] as Color), (r['color'] as Color).withOpacity(0.7)]),
                                    borderRadius: BorderRadius.circular(8),
                                 ),
                                 alignment: Alignment.center,
                                 child: Text((r['region'] as String)[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                               ),
                               const SizedBox(width: 16),
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text('${r['region']} Region', style: const TextStyle(fontWeight: FontWeight.w600)),
                                     Text('${r['events']} events', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                   ],
                                 ),
                               ),
                               Column(
                                 crossAxisAlignment: CrossAxisAlignment.end,
                                 children: [
                                   Text('₹${(r['revenue'] as double) ~/ 100000}L', style: const TextStyle(color: Color(0xFFFDB913), fontWeight: FontWeight.bold)),
                                   Row(children: [
                                     const Icon(Icons.trending_up, color: Colors.green, size: 14),
                                     Text(' +${r['growth']}%', style: const TextStyle(color: Colors.green, fontSize: 12)),
                                   ]),
                                 ],
                               ),
                             ],
                           ),
                         )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
             const SizedBox(height: 24),
            
            // Satisfaction & Trends
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                   child: Container(
                    height: 400,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Text('Customer Satisfaction', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: RadarChart(
                            RadarChartData(
                              radarShape: RadarShape.polygon,
                              dataSets: [
                                RadarDataSet(
                                   dataEntries: customerSatisfactionData.map((d) => RadarEntry(value: d['score'] as double)).toList(),
                                   borderColor: const Color(0xFFFDB913),
                                   fillColor: const Color(0xFFFDB913).withOpacity(0.2),
                                   borderWidth: 2,
                                ),
                              ],
                              tickCount: 5,
                              ticksTextStyle: const TextStyle(color: Colors.transparent),
                              gridBorderData: BorderSide(color: Colors.grey[300]!, width: 1),
                               getTitle: (index, angle) => RadarChartTitle(text: customerSatisfactionData[index]['aspect'] as String, angle: angle),
                               titlePositionPercentageOffset: 0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                 const SizedBox(width: 24),
                Expanded(
                  child: Container(
                    height: 400,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text('Booking Trends', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                         const SizedBox(height: 24),
                         Expanded(
                           child: LineChart(
                             LineChartData(
                               gridData: FlGridData(show: true, drawVerticalLine: false),
                               titlesData: FlTitlesData(
                                 leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (val, meta) => Text(val.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                                 bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, meta) {
                                   if (val.toInt() >= 0 && val.toInt() < bookingTrendsData.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(bookingTrendsData[val.toInt()]['week'] as String, style: const TextStyle(fontSize: 10, color: Colors.grey)));
                                    return const SizedBox();
                                 })),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                               ),
                               lineBarsData: [
                                 LineChartBarData(spots: bookingTrendsData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['bookings'] as double)).toList(), color: Colors.blue, isCurved: true, dotData: FlDotData(show: true)),
                                 LineChartBarData(spots: bookingTrendsData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['conversions'] as double)).toList(), color: Colors.green, isCurved: true, dotData: FlDotData(show: true)),
                                 LineChartBarData(spots: bookingTrendsData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['cancellations'] as double)).toList(), color: Colors.red, isCurved: true, dotData: FlDotData(show: true)),
                               ],
                             ),
                           ),
                         ),
                          const SizedBox(height: 8),
                         const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                           _ChartLegend(color: Colors.blue, label: 'Bookings'),
                           SizedBox(width: 16),
                            _ChartLegend(color: Colors.green, label: 'Conversions'),
                           SizedBox(width: 16),
                            _ChartLegend(color: Colors.red, label: 'Cancellations'),
                         ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Quick Insights
            GridView.count(
               crossAxisCount: 4,
               crossAxisSpacing: 24,
               mainAxisSpacing: 24,
               shrinkWrap: true,
               physics: const NeverScrollableScrollPhysics(),
               childAspectRatio: 2.0,
               children: [
                 _InsightCard(title: 'Average Event Value', value: '₹34K', type: 'Info', color: Colors.blue),
                 _InsightCard(title: 'Conversion Rate', value: '87.5%', type: 'Success', color: Colors.green),
                 _InsightCard(title: 'Repeat Clients', value: '64%', type: 'Growth', color: Colors.amber),
                  _InsightCard(title: 'Target Achievement', value: '92%', type: 'Target', color: Colors.amber),
               ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subText;
  final String growth;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatCard({required this.title, required this.value, required this.subText, required this.growth, required this.icon, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: AppTheme.cardDecoration.boxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
             Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
             Row(children: [
               Icon(Icons.trending_up, size: 14, color: Colors.green[700]),
               Text(growth, style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold)),
             ]),
          ]),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          ShaderMask(shaderCallback: (r) => LinearGradient(colors: [color, color.withOpacity(0.8)]).createShader(r), child: Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold))),
          const SizedBox(height: 4),
          Text(subText, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String value;
  final String type;
  final Color color;
  const _InsightCard({required this.title, required this.value, required this.type, required this.color});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.05), color.withOpacity(0.15)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
             Icon(Icons.lightbulb, color: color, size: 20),
             Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Text(type, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: color.withOpacity(0.9), fontSize: 12)),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ChartLegend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ]);
  }
}
