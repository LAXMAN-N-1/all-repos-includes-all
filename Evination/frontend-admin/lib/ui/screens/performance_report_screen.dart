import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../logic/providers/report_provider.dart';
import '../../data/models/reports/report_models.dart';

class PerformanceReportScreen extends ConsumerStatefulWidget {
  const PerformanceReportScreen({super.key});

  @override
  ConsumerState<PerformanceReportScreen> createState() => _PerformanceReportScreenState();
}

class _PerformanceReportScreenState extends ConsumerState<PerformanceReportScreen> {
  String _dateRange = 'year';

  @override
  Widget build(BuildContext context) {
    // Watch providers
    final chartsAsync = ref.watch(dashboardChartsProvider);
    final performanceAsync = ref.watch(performanceReportProvider);
    final profitLossAsync = ref.watch(profitLossProvider);

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
                      child: Text('Performance Reports', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const SizedBox(height: 4),
                    Text('Detailed performance metrics and KPI tracking', style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _dateRange,
                      items: const [
                        DropdownMenuItem(value: 'month', child: Text('This Month')),
                        DropdownMenuItem(value: 'quarter', child: Text('This Quarter')),
                        DropdownMenuItem(value: 'year', child: Text('This Year')),
                      ],
                      onChanged: (v) => setState(() => _dateRange = v!),
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[800]),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // KPI Grid (Using ProfitLoss Data)
            profitLossAsync.when(
              data: (pl) => GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.8,
                children: [
                  _StatCard(title: 'Gross Revenue', value: '₹${(pl.grossTransactionValue/100000).toStringAsFixed(2)}L', subText: 'Total Transaction Value', growth: '+12%', icon: Icons.monetization_on, color: const Color(0xFFFDB913), bgColor: const Color(0xFFFEF9E7)),
                  _StatCard(title: 'Net Profit', value: '₹${(pl.netProfit/1000).toStringAsFixed(1)}K', subText: 'Platform Profit', growth: '+8%', icon: Icons.account_balance_wallet, color: Colors.green, bgColor: Colors.green[50]!),
                  _StatCard(title: 'Profit Margin', value: '${pl.profitMargin.toStringAsFixed(1)}%', subText: 'Net / Gross Profit', growth: '+2%', icon: Icons.pie_chart, color: Colors.blue, bgColor: Colors.blue[50]!),
                  _StatCard(title: 'Vendor Payouts', value: '₹${(pl.vendorPayoutsEstimated/100000).toStringAsFixed(2)}L', subText: 'Estimated Payouts', growth: '+15%', icon: Icons.people, color: Colors.amber, bgColor: Colors.amber[50]!),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error loading KPIs: $e')),
            ),
            
            const SizedBox(height: 24),

            // Revenue Chart
             Container(
              height: 400,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
              child: chartsAsync.when(
                data: (charts) {
                   // Transform monthlyRevenue for chart
                   final data = charts.monthlyRevenue;
                   return Column(
                    children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text('Monthly Revenue Trends', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                         ],
                       ),
                       const SizedBox(height: 24),
                       Expanded(
                         child: data.isEmpty 
                           ? const Center(child: Text("No financial data available yet.")) 
                           : BarChart(
                           BarChartData(
                             gridData: FlGridData(show: true, drawVerticalLine: false),
                             titlesData: FlTitlesData(
                               leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, _) => Text('${val ~/ 1000}k', style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                               bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, _) {
                                 if (val.toInt() >= 0 && val.toInt() < data.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(data[val.toInt()].label, style: const TextStyle(fontSize: 10, color: Colors.grey)));
                                 return const SizedBox();
                               })),
                               topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                               rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                             ),
                             barGroups: data.asMap().entries.map((e) {
                               return BarChartGroupData(
                                 x: e.key,
                                 barRods: [
                                   BarChartRodData(toY: e.value.value, color: const Color(0xFFFDB913), width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                                 ],
                               );
                             }).toList(),
                           ),
                         ),
                       ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => const Center(child: Text('Error loading charts')),
              ),
            ),
            
            const SizedBox(height: 24),

            // Top Vendors Table (Replacing Team Performance)
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Padding(padding: const EdgeInsets.all(16), child: Text('Top Performing Vendors', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold))),
                   const Divider(height: 1),
                   performanceAsync.when(
                     data: (report) {
                       if (report.topVendors.isEmpty) return const Padding(padding: EdgeInsets.all(24), child: Center(child: Text("No vendor performance data.")));
                       
                       return Table(
                         defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                         // Adjust column widths
                         columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1)},
                         children: [
                           TableRow(decoration: BoxDecoration(color: Colors.grey[50]), children: [
                             _Header('Vendor Name'), _Header('Completed Orders'), _Header('Total Revenue'), _Header('Status')
                           ]),
                           ...report.topVendors.map((v) => TableRow(
                             decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
                             children: [
                               Padding(
                                 padding: const EdgeInsets.all(16),
                                 child: Row(children: [
                                   Container(
                                     width: 32, height: 32,
                                     decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFFFDB913), Color(0xFFE5A711)])),
                                     alignment: Alignment.center,
                                     child: Text(v.name.isNotEmpty ? v.name[0] : '?', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                   ),
                                   const SizedBox(width: 12),
                                   Expanded(child: Text(v.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                                 ]),
                               ),
                               Padding(padding: const EdgeInsets.all(16), child: Text('${v.orders}')),
                               Padding(padding: const EdgeInsets.all(16), child: Text('₹${v.value.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFFFDB913)))),
                               Padding(padding: const EdgeInsets.all(16), child: Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                 decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                                 child: Text('Top Rated', style: TextStyle(color: Colors.green[700], fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                               )),
                             ],
                           )),
                         ],
                       );
                     },
                     loading: () => const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
                     error: (e, s) => Padding(padding: const EdgeInsets.all(20), child: Text('Error: $e')),
                   ),
                ],
              ),
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

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(16), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)));
  }
}
