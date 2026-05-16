import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class FinancialAnalysisScreen extends StatefulWidget {
  const FinancialAnalysisScreen({super.key});

  @override
  State<FinancialAnalysisScreen> createState() => _FinancialAnalysisScreenState();
}

class _FinancialAnalysisScreenState extends State<FinancialAnalysisScreen> {
  String _timeframe = 'quarter';

  // Mock Data
  final cashFlowData = [
    {'month': 'Jan', 'inflow': 450000.0, 'outflow': 320000.0, 'net': 130000.0},
    {'month': 'Feb', 'inflow': 520000.0, 'outflow': 365000.0, 'net': 155000.0},
    {'month': 'Mar', 'inflow': 480000.0, 'outflow': 340000.0, 'net': 140000.0},
    {'month': 'Apr', 'inflow': 610000.0, 'outflow': 385000.0, 'net': 225000.0},
    {'month': 'May', 'inflow': 580000.0, 'outflow': 360000.0, 'net': 220000.0},
    {'month': 'Jun', 'inflow': 720000.0, 'outflow': 420000.0, 'net': 300000.0},
  ];
  
  final expenseBreakdown = [
    {'category': 'Vendor Payments', 'amount': 1250000.0, 'percentage': 42, 'color': const Color(0xFFFDB913)},
    {'category': 'Staff Salaries', 'amount': 850000.0, 'percentage': 29, 'color': const Color(0xFF10B981)},
    {'category': 'Marketing', 'amount': 320000.0, 'percentage': 11, 'color': const Color(0xFF3B82F6)},
    {'category': 'Operations', 'amount': 280000.0, 'percentage': 9, 'color': const Color(0xFFF59E0B)},
    {'category': 'Technology', 'amount': 180000.0, 'percentage': 6, 'color': const Color(0xFF8B5CF6)},
    {'category': 'Other', 'amount': 90000.0, 'percentage': 3, 'color': const Color(0xFFEF4444)},
  ];

  final profitabilityData = [
    {'month': 'Jan', 'grossProfit': 180000.0, 'netProfit': 130000.0, 'margin': 28.9},
    {'month': 'Feb', 'grossProfit': 210000.0, 'netProfit': 155000.0, 'margin': 29.8},
    {'month': 'Mar', 'grossProfit': 195000.0, 'netProfit': 140000.0, 'margin': 29.2},
    {'month': 'Apr', 'grossProfit': 260000.0, 'netProfit': 225000.0, 'margin': 36.9},
    {'month': 'May', 'grossProfit': 240000.0, 'netProfit': 220000.0, 'margin': 37.9},
    {'month': 'Jun', 'grossProfit': 350000.0, 'netProfit': 300000.0, 'margin': 41.7},
  ];

  final revenueStreams = [
    {'source': 'Corporate Events', 'q1': 380000, 'q2': 420000, 'growth': 10.5},
    {'source': 'Weddings', 'q1': 520000, 'q2': 580000, 'growth': 11.5},
    {'source': 'Social Events', 'q1': 280000, 'q2': 310000, 'growth': 10.7},
    {'source': 'Conferences', 'q1': 320000, 'q2': 360000, 'growth': 12.5},
    {'source': 'Vendor Commission', 'q1': 125000, 'q2': 145000, 'growth': 16.0},
  ];
  
  final arAging = [
    {'category': 'Current (0-30 days)', 'amount': 820000, 'count': 28, 'percentage': 62, 'color': const Color(0xFF10B981)},
    {'category': '31-60 days', 'amount': 320000, 'count': 12, 'percentage': 24, 'color': const Color(0xFFFDB913)},
    {'category': '61-90 days', 'amount': 125000, 'count': 5, 'percentage': 9, 'color': const Color(0xFFF59E0B)},
    {'category': 'Over 90 days', 'amount': 65000, 'count': 3, 'percentage': 5, 'color': const Color(0xFFEF4444)},
  ];

  final budgetComparison = [
    {'category': 'Revenue', 'budget': 3200000, 'actual': 3360000, 'variance': 5.0},
    {'category': 'Direct Costs', 'budget': 1800000, 'actual': 1750000, 'variance': -2.8},
    {'category': 'Operating Expenses', 'budget': 850000, 'actual': 920000, 'variance': 8.2},
    {'category': 'Marketing', 'budget': 300000, 'actual': 320000, 'variance': 6.7},
    {'category': 'Technology', 'budget': 150000, 'actual': 180000, 'variance': 20.0},
  ];

  @override
  Widget build(BuildContext context) {
    final totalInflow = cashFlowData.fold(0.0, (sum, item) => sum + (item['inflow'] as double));
    final totalOutflow = cashFlowData.fold(0.0, (sum, item) => sum + (item['outflow'] as double));
    final netCashFlow = totalInflow - totalOutflow;
    final avgMargin = profitabilityData.fold(0.0, (sum, item) => sum + (item['margin'] as double)) / profitabilityData.length;

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
                      child: Text('Financial Analysis', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const SizedBox(height: 4),
                    Text('Comprehensive financial metrics and analysis', style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _timeframe,
                          items: const [
                            DropdownMenuItem(value: 'month', child: Text('This Month')),
                            DropdownMenuItem(value: 'quarter', child: Text('This Quarter')),
                            DropdownMenuItem(value: 'year', child: Text('This Year')),
                          ],
                          onChanged: (v) => setState(() => _timeframe = v!),
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[800]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Export Report'),
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
            
            // Stats Grid
            GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.8,
              children: [
                _StatCard(title: 'Total Inflow', value: '₹${(totalInflow / 100000).toStringAsFixed(1)}L', subText: 'Last 6 months', icon: Icons.trending_up, color: Colors.green),
                _StatCard(title: 'Total Outflow', value: '₹${(totalOutflow / 100000).toStringAsFixed(1)}L', subText: 'Expenses & costs', icon: Icons.trending_down, color: Colors.red),
                _StatCard(title: 'Net Cash Flow', value: '₹${(netCashFlow / 100000).toStringAsFixed(1)}L', subText: 'Positive cash position', icon: Icons.attach_money, color: Colors.blue),
                _StatCard(title: 'Avg Profit Margin', value: '${avgMargin.toStringAsFixed(1)}%', subText: 'Strong margins', icon: Icons.bar_chart, color: Colors.amber),
              ],
            ),
            const SizedBox(height: 24),

            // Cash Flow Chart (Bar Chart)
            Container(
              height: 400,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [const Icon(Icons.attach_money, size: 20, color: Colors.grey), const SizedBox(width: 8), Text('Cash Flow Analysis', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 24),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        gridData: FlGridData(show: true, drawVerticalLine: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, _) => Text('${val ~/ 1000}k', style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, _) {
                            if (val.toInt() >= 0 && val.toInt() < cashFlowData.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(cashFlowData[val.toInt()]['month'] as String, style: const TextStyle(fontSize: 10, color: Colors.grey)));
                            return const SizedBox();
                          })),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        barGroups: cashFlowData.asMap().entries.map((e) {
                          final data = e.value;
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(toY: data['inflow'] as double, color: const Color(0xFF10B981), width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                              BarChartRodData(toY: data['outflow'] as double, color: const Color(0xFFEF4444), width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                            ],
                            barsSpace: 8,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _ChartLegend(color: Color(0xFF10B981), label: 'Cash Inflow'),
                    SizedBox(width: 16),
                    _ChartLegend(color: Color(0xFFEF4444), label: 'Cash Outflow'),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Expense Breakdown & Profitability
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pie Chart
                Expanded(
                  child: Container(
                    height: 400,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [const Icon(Icons.pie_chart, size: 20, color: Colors.grey), const SizedBox(width: 8), Text('Expense Distribution', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold))]),
                        const SizedBox(height: 24),
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: expenseBreakdown.map((d) => PieChartSectionData(
                                color: d['color'] as Color,
                                value: d['amount'] as double,
                                title: '${d['percentage']}%',
                                radius: 80,
                                titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                              )).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: expenseBreakdown.map((d) => _ChartLegend(color: d['color'] as Color, label: d['category'] as String)).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Line Chart
                Expanded(
                  child: Container(
                    height: 400,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [const Icon(Icons.show_chart, size: 20, color: Colors.grey), const SizedBox(width: 8), Text('Profitability Trends', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold))]),
                        const SizedBox(height: 24),
                        Expanded(
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true, drawVerticalLine: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, _) => Text('${val ~/ 1000}k', style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, _) {
                                  if (val.toInt() >= 0 && val.toInt() < profitabilityData.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(profitabilityData[val.toInt()]['month'] as String, style: const TextStyle(fontSize: 10, color: Colors.grey)));
                                  return const SizedBox();
                                })),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Simplified single axis
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(spots: profitabilityData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['grossProfit'] as double)).toList(), color: const Color(0xFFFDB913), isCurved: true, dotData: FlDotData(show: true)),
                                LineChartBarData(spots: profitabilityData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['netProfit'] as double)).toList(), color: const Color(0xFF10B981), isCurved: true, dotData: FlDotData(show: true)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          _ChartLegend(color: Color(0xFFFDB913), label: 'Gross Profit'),
                          SizedBox(width: 16),
                          _ChartLegend(color: Color(0xFF10B981), label: 'Net Profit'),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Revenue Streams Table
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Revenue Streams Comparison', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1), 4: FlexColumnWidth(1)},
                    children: [
                       TableRow(decoration: BoxDecoration(color: Colors.grey[50]), children: [
                         _Header('Revenue Source'), _Header('Q1'), _Header('Q2'), _Header('Growth'), _Header('Trend')
                       ]),
                       ...revenueStreams.map((s) => TableRow(
                         decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
                         children: [
                           Padding(padding: const EdgeInsets.all(16), child: Text(s['source'] as String, style: const TextStyle(fontWeight: FontWeight.w500))),
                           Padding(padding: const EdgeInsets.all(16), child: Text('₹${(s['q1'] as int) ~/ 1000}K')),
                           Padding(padding: const EdgeInsets.all(16), child: Text('₹${(s['q2'] as int) ~/ 1000}K')),
                           Padding(padding: const EdgeInsets.all(16), child: Text('+${s['growth']}%', style: const TextStyle(color: Colors.green))),
                           Padding(padding: const EdgeInsets.all(16), child: Row(children: [
                             Expanded(child: LinearProgressIndicator(value: (s['growth'] as double) / 20.0, backgroundColor: Colors.grey[200], color: Colors.green, minHeight: 6, borderRadius: BorderRadius.circular(3))),
                             const SizedBox(width: 8),
                             const Icon(Icons.trending_up, color: Colors.green, size: 16),
                           ])),
                         ],
                       ))
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Grid for AR & Budget
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AR Aging
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                           Text('Accounts Receivable Aging', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                           const Icon(Icons.credit_card, color: Colors.grey),
                        ]),
                        const SizedBox(height: 16),
                        ...arAging.map((ar) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text(ar['category'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                Row(children: [
                                   Text('${ar['count']} invoices', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                   const SizedBox(width: 8),
                                   Text('₹${(ar['amount'] as int) ~/ 1000}K', style: const TextStyle(fontSize: 13, color: Color(0xFFFDB913), fontWeight: FontWeight.bold)),
                                ]),
                              ]),
                              const SizedBox(height: 8),
                              Row(children: [
                                Expanded(child: LinearProgressIndicator(value: (ar['percentage'] as int) / 100.0, backgroundColor: Colors.grey[100], color: ar['color'] as Color, minHeight: 8, borderRadius: BorderRadius.circular(4))),
                                const SizedBox(width: 8),
                                Text('${ar['percentage']}%', style: const TextStyle(fontSize: 12)),
                              ]),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Budget
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                           Text('Budget vs Actual', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                           const Icon(Icons.bar_chart, color: Colors.grey),
                        ]),
                        const SizedBox(height: 16),
                        ...budgetComparison.map((b) => Container(
                           margin: const EdgeInsets.only(bottom: 12),
                           padding: const EdgeInsets.all(12),
                           decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                           child: Column(
                             children: [
                               Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                 Text(b['category'] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
                                 Row(children: [
                                    Icon((b['variance'] as double) >= 0 ? Icons.trending_up : Icons.trending_down, size: 16, color: (b['variance'] as double) >= 0 ? Colors.green : Colors.red),
                                    const SizedBox(width: 4),
                                    Text('${(b['variance'] as double) > 0 ? "+" : ""}${b['variance']}%', style: TextStyle(color: (b['variance'] as double) >= 0 ? Colors.green : Colors.red, fontSize: 12)),
                                 ]),
                               ]),
                               const SizedBox(height: 8),
                               Row(children: [
                                 _BudgetDot(Colors.grey, 'Budget: ₹${(b['budget'] as int) ~/ 1000}K'),
                                 const SizedBox(width: 12),
                                 _BudgetDot(const Color(0xFFFDB913), 'Actual: ₹${(b['actual'] as int) ~/ 1000}K'),
                               ]),
                             ],
                           ),
                        )),
                      ],
                    ),
                  ),
                ),
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
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.subText, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
           begin: Alignment.topLeft, end: Alignment.bottomRight,
           colors: [color.withOpacity(0.05), color.withOpacity(0.15)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
             Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
             Icon(Icons.check_circle, color: color, size: 16),
          ]),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: color.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color.withOpacity(0.9), fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subText, style: TextStyle(color: color, fontSize: 11)),
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

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(16), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)));
  }
}

class _BudgetDot extends StatelessWidget {
  final Color color;
  final String text;
  const _BudgetDot(this.color, this.text);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
       Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
       const SizedBox(width: 4),
       Text(text, style: TextStyle(color: color, fontSize: 12)),
    ]);
  }
}
