import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class CollectionReportScreen extends StatefulWidget {
  const CollectionReportScreen({super.key});

  @override
  State<CollectionReportScreen> createState() => _CollectionReportScreenState();
}

class _CollectionReportScreenState extends State<CollectionReportScreen> {
  String _dateRange = 'month';

  // Mock Data
  final monthlyData = [
    {'month': 'Jan', 'collected': 185000.0, 'pending': 45000.0},
    {'month': 'Feb', 'collected': 220000.0, 'pending': 30000.0},
    {'month': 'Mar', 'collected': 195000.0, 'pending': 55000.0},
    {'month': 'Apr', 'collected': 240000.0, 'pending': 20000.0},
    {'month': 'May', 'collected': 210000.0, 'pending': 40000.0},
    {'month': 'Jun', 'collected': 265000.0, 'pending': 15000.0},
  ];

  final categoryData = [
    {'name': 'Catering', 'value': 450000.0, 'percentage': 35, 'color': const Color(0xFFFDB913)},
    {'name': 'Venues', 'value': 380000.0, 'percentage': 30, 'color': const Color(0xFFE5A711)},
    {'name': 'Decoration', 'value': 200000.0, 'percentage': 15, 'color': const Color(0xFF10B981)},
    {'name': 'Photography', 'value': 150000.0, 'percentage': 12, 'color': const Color(0xFFF59E0B)},
    {'name': 'Entertainment', 'value': 100000.0, 'percentage': 8, 'color': const Color(0xFFEF4444)},
  ];

  final collections = [
    {'id': 1, 'event': 'Annual Tech Summit 2025', 'totalAmount': 125000, 'collected': 62500, 'pending': 62500, 'dueDate': 'Mar 8, 2025', 'status': 'Partial'},
    {'id': 2, 'event': 'Smith & Jones Wedding', 'totalAmount': 75000, 'collected': 75000, 'pending': 0, 'dueDate': 'Apr 15, 2025', 'status': 'Paid'},
    {'id': 3, 'event': 'Q2 Corporate Retreat', 'totalAmount': 180000, 'collected': 180000, 'pending': 0, 'dueDate': 'May 3, 2025', 'status': 'Paid'},
    {'id': 4, 'event': 'Charity Gala 2025', 'totalAmount': 100000, 'collected': 50000, 'pending': 50000, 'dueDate': 'May 29, 2025', 'status': 'Partial'},
    {'id': 5, 'event': 'Tech Innovation Workshop', 'totalAmount': 25000, 'collected': 0, 'pending': 25000, 'dueDate': 'Mar 1, 2025', 'status': 'Overdue'},
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid': return Colors.green[700]!;
      case 'Partial': return const Color(0xFFFDB913);
      case 'Pending': return Colors.orange[700]!;
      case 'Overdue': return Colors.red[700]!;
      default: return Colors.grey;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'Paid': return Colors.green[50]!;
      case 'Partial': return const Color(0xFFFEF9E7); // Light Gold
      case 'Pending': return Colors.orange[50]!;
      case 'Overdue': return Colors.red[50]!;
      default: return Colors.grey[100]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCollected = collections.fold(0.0, (sum, c) => sum + (c['collected'] as int));
    final totalPending = collections.fold(0.0, (sum, c) => sum + (c['pending'] as int));
    final collectionRate = (totalCollected / (totalCollected + totalPending)) * 100;

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
                    Text('Collection Reports', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Monitor payment collections and outstanding amounts', style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
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
            const SizedBox(height: 24),

            // Stats
            Row(
              children: [
                _StatCard(
                  title: 'Total Collected',
                  value: '₹${(totalCollected / 1000).toStringAsFixed(0)}K',
                  icon: Icons.attach_money,
                  iconColor: Colors.green,
                  bgColor: Colors.green[50]!,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  title: 'Pending',
                  value: '₹${(totalPending / 1000).toStringAsFixed(0)}K',
                  icon: Icons.calendar_today,
                  iconColor: Colors.orange,
                  bgColor: Colors.orange[50]!,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  title: 'Collection Rate',
                  value: '${collectionRate.toStringAsFixed(0)}%',
                  icon: Icons.trending_up,
                  iconColor: const Color(0xFFFDB913),
                  bgColor: const Color(0xFFFEF9E7),
                ),
                const SizedBox(width: 16),
                _StatCard(
                  title: 'Overdue',
                  value: '${collections.where((c) => c['status'] == 'Overdue').length}',
                  icon: Icons.warning_amber_rounded,
                  iconColor: Colors.red,
                  bgColor: Colors.red[50]!,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Charts
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bar Chart
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 400,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Monthly Collections', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _dateRange,
                                items: const [
                                  DropdownMenuItem(value: 'month', child: Text('Last 6 Months')),
                                  DropdownMenuItem(value: 'year', child: Text('This Year')),
                                ],
                                onChanged: (v) => setState(() => _dateRange = v!),
                                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[800]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: BarChart(
                            BarChartData(
                              gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[200]!, strokeWidth: 1)),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, meta) => Text('${val ~/ 1000}k', style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, meta) {
                                  if (val.toInt() >= 0 && val.toInt() < monthlyData.length) {
                                      return Padding(padding: const EdgeInsets.only(top: 8), child: Text(monthlyData[val.toInt()]['month'] as String, style: const TextStyle(fontSize: 10, color: Colors.grey)));
                                  }
                                  return const Text('');
                                })),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: monthlyData.asMap().entries.map((e) {
                                final index = e.key;
                                final data = e.value;
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(toY: data['collected'] as double, color: const Color(0xFF10B981), width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                                    BarChartRodData(toY: data['pending'] as double, color: const Color(0xFFF59E0B), width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                                  ],
                                  barsSpace: 4,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             _ChartLegend(color: const Color(0xFF10B981), label: 'Collected'),
                             const SizedBox(width: 16),
                             _ChartLegend(color: const Color(0xFFF59E0B), label: 'Pending'),
                           ],
                         )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Pie Chart
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 400,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Collections by Category', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: categoryData.map((d) => PieChartSectionData(
                                color: d['color'] as Color,
                                value: d['value'] as double,
                                title: '${d['percentage']}%',
                                radius: 80,
                                titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                              )).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          runSpacing: 8,
                          spacing: 8,
                          children: categoryData.map((d) => _ChartLegend(color: d['color'] as Color, label: d['name'] as String)).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Table
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Payment Collections', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const Divider(height: 1),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2), // Event
                      1: FlexColumnWidth(1), // Total
                      2: FlexColumnWidth(1), // Collected
                      3: FlexColumnWidth(1), // Pending
                      4: FlexColumnWidth(1), // Due Date
                      5: FlexColumnWidth(1.5), // Progress
                      6: FlexColumnWidth(1), // Status
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                     children: [
                       // Header
                       TableRow(
                         decoration: BoxDecoration(color: Colors.grey[50]),
                         children: [
                           _HeaderCell('Event'),
                           _HeaderCell('Total Amount'),
                           _HeaderCell('Collected'),
                           _HeaderCell('Pending'),
                           _HeaderCell('Due Date'),
                           _HeaderCell('Progress'),
                           _HeaderCell('Status'),
                         ],
                       ),
                       ...collections.map((c) {
                          final collected = c['collected'] as int;
                          final total = c['totalAmount'] as int;
                          final progress = total > 0 ? collected / total : 0.0;
                         return TableRow(
                            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
                           children: [
                             Padding(padding: const EdgeInsets.all(16), child: Text(c['event'] as String, style: const TextStyle(fontWeight: FontWeight.w500))),
                             Padding(padding: const EdgeInsets.all(16), child: Text('₹${total}', style: const TextStyle(color: Colors.black87))),
                             Padding(padding: const EdgeInsets.all(16), child: Text('₹${collected}', style: const TextStyle(color: Colors.green))),
                             Padding(padding: const EdgeInsets.all(16), child: Text('₹${c['pending']}', style: const TextStyle(color: Colors.orange))),
                             Padding(padding: const EdgeInsets.all(16), child: Text(c['dueDate'] as String, style: const TextStyle(color: Colors.grey, fontSize: 13))),
                             Padding(
                               padding: const EdgeInsets.all(16),
                               child: Row(
                                 children: [
                                   Expanded(
                                     child: LinearProgressIndicator(
                                       value: progress,
                                       backgroundColor: Colors.grey[200],
                                       color: const Color(0xFFFDB913),
                                       minHeight: 8,
                                       borderRadius: BorderRadius.circular(4),
                                     ),
                                   ),
                                   const SizedBox(width: 8),
                                   Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 12)),
                                 ],
                               ),
                             ),
                             Padding(
                               padding: const EdgeInsets.all(16),
                               child: Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                 decoration: BoxDecoration(color: _getStatusBgColor(c['status'] as String), borderRadius: BorderRadius.circular(8)),
                                 child: Text(c['status'] as String, style: TextStyle(color: _getStatusColor(c['status'] as String), fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                               ),
                             ),
                           ],
                         );
                       }),
                     ],
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
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  
  const _StatCard({required this.title, required this.value, required this.icon, required this.iconColor, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
               Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                 child: Icon(icon, color: iconColor, size: 20),
               ),
               const SizedBox(width: 12),
               Expanded(child: Text(title, style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13))),
            ]),
            const SizedBox(height: 12),
            Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
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

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(16), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)));
  }
}
