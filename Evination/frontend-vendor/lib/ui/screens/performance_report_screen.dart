import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class PerformanceReportScreen extends StatefulWidget {
  const PerformanceReportScreen({super.key});

  @override
  State<PerformanceReportScreen> createState() => _PerformanceReportScreenState();
}

class _PerformanceReportScreenState extends State<PerformanceReportScreen> {
  String _dateRange = 'quarter';
  String _department = 'all';

  // Mock Data
  final teamPerformance = [
    {'name': 'Sarah Johnson', 'role': 'Event Manager', 'eventsHandled': 28, 'revenue': 1250000, 'satisfaction': 4.8, 'onTimeDelivery': 96, 'status': 'Excellent'},
    {'name': 'Michael Chen', 'role': 'Event Manager', 'eventsHandled': 24, 'revenue': 980000, 'satisfaction': 4.6, 'onTimeDelivery': 92, 'status': 'Good'},
    {'name': 'Emma Williams', 'role': 'Vendor Coordinator', 'eventsHandled': 35, 'revenue': 760000, 'satisfaction': 4.7, 'onTimeDelivery': 94, 'status': 'Excellent'},
    {'name': 'David Brown', 'role': 'Finance Manager', 'eventsHandled': 18, 'revenue': 520000, 'satisfaction': 4.5, 'onTimeDelivery': 88, 'status': 'Good'},
    {'name': 'Lisa Anderson', 'role': 'Event Coordinator', 'eventsHandled': 22, 'revenue': 680000, 'satisfaction': 4.4, 'onTimeDelivery': 85, 'status': 'Average'},
  ];

  final monthlyComparison = [
    {'month': 'Jan', 'target': 500000.0, 'achieved': 485000.0, 'efficiency': 87},
    {'month': 'Feb', 'target': 500000.0, 'achieved': 525000.0, 'efficiency': 90},
    {'month': 'Mar', 'target': 550000.0, 'achieved': 510000.0, 'efficiency': 88},
    {'month': 'Apr', 'target': 550000.0, 'achieved': 595000.0, 'efficiency': 92},
    {'month': 'May', 'target': 600000.0, 'achieved': 580000.0, 'efficiency': 89},
    {'month': 'Jun', 'target': 600000.0, 'achieved': 720000.0, 'efficiency': 95},
  ];

  final departmentPerformance = [
    {'department': 'Events', 'kpi': 92, 'target': 90, 'variance': 2},
    {'department': 'Vendors', 'kpi': 88, 'target': 85, 'variance': 3},
    {'department': 'Finance', 'kpi': 95, 'target': 90, 'variance': 5},
    {'department': 'Operations', 'kpi': 87, 'target': 90, 'variance': -3},
    {'department': 'Customer Service', 'kpi': 91, 'target': 88, 'variance': 3},
  ];

  final processEfficiency = [
    {'process': 'Event Planning', 'avgTime': 5.2, 'target': 6.0, 'efficiency': 87},
    {'process': 'Vendor Onboarding', 'avgTime': 3.5, 'target': 4.0, 'efficiency': 88},
    {'process': 'Quote Generation', 'avgTime': 1.8, 'target': 2.0, 'efficiency': 90},
    {'process': 'Contract Processing', 'avgTime': 2.5, 'target': 3.0, 'efficiency': 83},
    {'process': 'Payment Processing', 'avgTime': 1.2, 'target': 1.5, 'efficiency': 80},
  ];

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'Excellent': return Colors.green[50]!;
      case 'Good': return Colors.blue[50]!;
      case 'Average': return Colors.amber[50]!;
      default: return Colors.red[50]!;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Excellent': return Colors.green[700]!;
      case 'Good': return Colors.blue[700]!;
      case 'Average': return Colors.amber[700]!;
      default: return Colors.red[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final overallEfficiency = monthlyComparison.fold(0, (sum, m) => sum + (m['efficiency'] as int)) / monthlyComparison.length;
    final totalTarget = monthlyComparison.fold(0.0, (sum, m) => sum + (m['target'] as double));
    final totalAchieved = monthlyComparison.fold(0.0, (sum, m) => sum + (m['achieved'] as double));
    final targetAchievement = (totalAchieved / totalTarget) * 100;

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
                Row(
                  children: [
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

            // KPI Grid
            GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.8,
              children: [
                _StatCard(title: 'Target Achievement', value: '${targetAchievement.toStringAsFixed(1)}%', subText: 'Above target', growth: '+5.2%', icon: Icons.track_changes, color: const Color(0xFFFDB913), bgColor: const Color(0xFFFEF9E7)),
                _StatCard(title: 'Overall Efficiency', value: '${overallEfficiency.toStringAsFixed(0)}%', subText: 'Performance score', growth: 'Excellent', icon: Icons.military_tech, color: Colors.green, bgColor: Colors.green[50]!),
                _StatCard(title: 'On-Time Delivery', value: '91%', subText: 'Punctuality rate', growth: '+3.8%', icon: Icons.check_circle, color: Colors.blue, bgColor: Colors.blue[50]!),
                _StatCard(title: 'Team Satisfaction', value: '4.6', subText: 'Out of 5.0', growth: '+2.5%', icon: Icons.group, color: Colors.amber, bgColor: Colors.amber[50]!),
              ],
            ),
            const SizedBox(height: 24),

            // Target vs Achievement Chart
            Container(
              height: 400,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text('Target vs Achievement Analysis', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                       DropdownButtonHideUnderline(
                         child: DropdownButton<String>(
                           value: _department,
                           items: const [
                             DropdownMenuItem(value: 'all', child: Text('All Departments')),
                             DropdownMenuItem(value: 'events', child: Text('Events')),
                             DropdownMenuItem(value: 'vendors', child: Text('Vendors')),
                             DropdownMenuItem(value: 'finance', child: Text('Finance')),
                           ],
                           onChanged: (v) => setState(() => _department = v!),
                           style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[800]),
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 24),
                   Expanded(
                     child: BarChart(
                       BarChartData(
                         gridData: FlGridData(show: true, drawVerticalLine: false),
                         titlesData: FlTitlesData(
                           leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, _) => Text('${val ~/ 1000}k', style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                           bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, _) {
                             if (val.toInt() >= 0 && val.toInt() < monthlyComparison.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(monthlyComparison[val.toInt()]['month'] as String, style: const TextStyle(fontSize: 10, color: Colors.grey)));
                             return const SizedBox();
                           })),
                           topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                           rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                         ),
                         barGroups: monthlyComparison.asMap().entries.map((e) {
                           final data = e.value;
                           return BarChartGroupData(
                             x: e.key,
                             barRods: [
                               BarChartRodData(toY: data['target'] as double, color: Colors.grey[400], width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                               BarChartRodData(toY: data['achieved'] as double, color: const Color(0xFFFDB913), width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                             ],
                             barsSpace: 4,
                           );
                         }).toList(),
                       ),
                     ),
                   ),
                   const SizedBox(height: 8),
                    const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _ChartLegend(color: Colors.grey, label: 'Target'),
                      SizedBox(width: 16),
                      _ChartLegend(color: Color(0xFFFDB913), label: 'Achieved'),
                    ]),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Team Performance Table
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Padding(padding: const EdgeInsets.all(16), child: Text('Team Performance Metrics', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold))),
                   const Divider(height: 1),
                   Table(
                     defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                     columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1.5), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1), 4: FlexColumnWidth(1), 5: FlexColumnWidth(1), 6: FlexColumnWidth(1.2)},
                     children: [
                       TableRow(decoration: BoxDecoration(color: Colors.grey[50]), children: [
                         _Header('Team Member'), _Header('Role'), _Header('Events'), _Header('Revenue'), _Header('Rating'), _Header('On-Time %'), _Header('Status')
                       ]),
                       ...teamPerformance.map((m) => TableRow(
                         decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
                         children: [
                           Padding(
                             padding: const EdgeInsets.all(16),
                             child: Row(children: [
                               Container(
                                 width: 32, height: 32,
                                 decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFFFDB913), Color(0xFFE5A711)])),
                                 alignment: Alignment.center,
                                 child: Text((m['name'] as String).split(' ').map((n) => n[0]).join(''), style: const TextStyle(color: Colors.white, fontSize: 12)),
                               ),
                               const SizedBox(width: 12),
                               Expanded(child: Text(m['name'] as String, style: const TextStyle(fontWeight: FontWeight.w500))),
                             ]),
                           ),
                           Padding(padding: const EdgeInsets.all(16), child: Text(m['role'] as String, style: const TextStyle(fontSize: 13, color: Colors.grey))),
                           Padding(padding: const EdgeInsets.all(16), child: Text('${m['eventsHandled']}')),
                           Padding(padding: const EdgeInsets.all(16), child: Text('₹${(m['revenue'] as int) ~/ 1000}K', style: const TextStyle(color: Color(0xFFFDB913)))),
                           Padding(padding: const EdgeInsets.all(16), child: Row(children: [const Icon(Icons.star, color: Colors.amber, size: 14), const SizedBox(width: 4), Text('${m['satisfaction']}')])),
                           Padding(padding: const EdgeInsets.all(16), child: Row(children: [
                             Expanded(child: LinearProgressIndicator(value: (m['onTimeDelivery'] as int) / 100.0, backgroundColor: Colors.grey[200], color: const Color(0xFF10B981), minHeight: 6, borderRadius: BorderRadius.circular(3))),
                             const SizedBox(width: 8),
                             Text('${m['onTimeDelivery']}%', style: const TextStyle(fontSize: 12)),
                           ])),
                           Padding(padding: const EdgeInsets.all(16), child: Container(
                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                             decoration: BoxDecoration(color: _getStatusBgColor(m['status'] as String), borderRadius: BorderRadius.circular(8)),
                             child: Text(m['status'] as String, style: TextStyle(color: _getStatusColor(m['status'] as String), fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                           )),
                         ],
                       )),
                     ],
                   ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Dept & Process
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
                        Text('Department KPIs', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ...departmentPerformance.map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                 Text(d['department'] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
                                 Row(children: [
                                   Text('Target: ${d['target']}%  ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                   Text('${d['kpi']}%', style: TextStyle(fontWeight: FontWeight.bold, color: (d['variance'] as int) >= 0 ? Colors.green : Colors.red)),
                                 ]),
                              ]),
                              const SizedBox(height: 8),
                              Row(children: [
                                Expanded(child: LinearProgressIndicator(value: (d['kpi'] as int) / 100.0, backgroundColor: Colors.grey[100], color: (d['kpi'] as int) >= (d['target'] as int) ? const Color(0xFF10B981) : Colors.amber, minHeight: 8, borderRadius: BorderRadius.circular(4))),
                                const SizedBox(width: 8),
                                Icon((d['variance'] as int) >= 0 ? Icons.trending_up : Icons.trending_down, color: (d['variance'] as int) >= 0 ? Colors.green : Colors.red, size: 16),
                              ]),
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
                         Text('Process Efficiency (Days)', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                         const SizedBox(height: 16),
                         ...processEfficiency.map((p) => Container(
                           margin: const EdgeInsets.only(bottom: 12),
                           padding: const EdgeInsets.all(12),
                           decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                           child: Column(
                             children: [
                               Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                 Row(children: [const Icon(Icons.access_time, size: 14, color: Colors.grey), const SizedBox(width: 8), Text(p['process'] as String, style: const TextStyle(fontWeight: FontWeight.w500))]),
                                 Row(children: [
                                   Text('Target: ${p['target']}d  ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                   Text('${p['avgTime']}d', style: const TextStyle(color: Color(0xFFFDB913), fontWeight: FontWeight.bold)),
                                 ]),
                               ]),
                               const SizedBox(height: 8),
                               LinearProgressIndicator(value: (p['efficiency'] as int) / 100.0, backgroundColor: Colors.grey[200], color: const Color(0xFFFDB913), minHeight: 6, borderRadius: BorderRadius.circular(3)),
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
