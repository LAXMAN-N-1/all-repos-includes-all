import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class TransactionReportScreen extends StatefulWidget {
  const TransactionReportScreen({super.key});

  @override
  State<TransactionReportScreen> createState() => _TransactionReportScreenState();
}

class _TransactionReportScreenState extends State<TransactionReportScreen> {
  String _dateRange = 'last30';
  String _searchTerm = '';

  // Mock Data
  final chartData = [
    {'date': 'Jan 1', 'amount': 45000.0, 'count': 12},
    {'date': 'Jan 5', 'amount': 52000.0, 'count': 15},
    {'date': 'Jan 10', 'amount': 48000.0, 'count': 13},
    {'date': 'Jan 15', 'amount': 61000.0, 'count': 18},
    {'date': 'Jan 20', 'amount': 55000.0, 'count': 16},
    {'date': 'Jan 25', 'amount': 67000.0, 'count': 20},
    {'date': 'Jan 30', 'amount': 72000.0, 'count': 22},
    {'date': 'Feb 1', 'amount': 58000.0, 'count': 17},
  ];

  final transactions = [
    {'id': 'TXN-1234', 'date': 'Feb 1, 2025', 'event': 'Annual Tech Summit 2025', 'vendor': 'Elegant Caterers Inc.', 'amount': 62500, 'type': 'Deposit', 'status': 'Completed', 'method': 'Wire Transfer'},
    {'id': 'TXN-1233', 'date': 'Jan 30, 2025', 'event': 'Smith & Jones Wedding', 'vendor': 'Picture Perfect Studios', 'amount': 22500, 'type': 'Deposit', 'status': 'Completed', 'method': 'Credit Card'},
    {'id': 'TXN-1232', 'date': 'Jan 28, 2025', 'event': 'Charity Gala 2025', 'vendor': 'Bloom & Decor', 'amount': 32500, 'type': 'Deposit', 'status': 'Completed', 'method': 'ACH'},
    {'id': 'TXN-1231', 'date': 'Jan 25, 2025', 'event': 'Q2 Corporate Retreat', 'vendor': 'Grand Vista Venues', 'amount': 90000, 'type': 'Full Payment', 'status': 'Completed', 'method': 'Wire Transfer'},
    {'id': 'TXN-1230', 'date': 'Jan 22, 2025', 'event': 'Tech Innovation Workshop', 'vendor': 'DJ Sound Waves', 'amount': 4000, 'type': 'Deposit', 'status': 'Pending', 'method': 'Credit Card'},
  ];

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'Completed': return Colors.green[50]!;
      case 'Pending': return Colors.orange[50]!;
      case 'Failed': return Colors.red[50]!;
      default: return Colors.grey[100]!;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed': return Colors.green[700]!;
      case 'Pending': return Colors.orange[700]!;
      case 'Failed': return Colors.red[700]!;
      default: return Colors.grey[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = transactions.where((t) {
      final term = _searchTerm.toLowerCase();
      return (t['id'] as String).toLowerCase().contains(term) ||
             (t['event'] as String).toLowerCase().contains(term) ||
             (t['vendor'] as String).toLowerCase().contains(term);
    }).toList();

    final totalRevenue = transactions.fold(0, (sum, t) => sum + (t['amount'] as int));
    final avgTransaction = transactions.isNotEmpty ? totalRevenue / transactions.length : 0;
    final pendingCount = transactions.where((t) => t['status'] == 'Pending').length;

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
                    Text('Transaction Reports', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Track and analyze all financial transactions', style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13)),
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
            GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              children: [
                _StatCard(title: 'Total Revenue', value: '₹${(totalRevenue / 1000).toStringAsFixed(0)}K', icon: Icons.attach_money, color: Colors.green, bgColor: Colors.green[50]!),
                _StatCard(title: 'Transactions', value: '${transactions.length}', icon: Icons.description, color: const Color(0xFFFDB913), bgColor: const Color(0xFFFEF9E7)),
                _StatCard(title: 'Avg Transaction', value: '₹${(avgTransaction / 1000).toStringAsFixed(0)}K', icon: Icons.trending_up, color: const Color(0xFFFDB913), bgColor: const Color(0xFFFEF9E7)),
                _StatCard(title: 'Pending', value: '$pendingCount', icon: Icons.calendar_today, color: Colors.orange, bgColor: Colors.orange[50]!),
              ],
            ),
            const SizedBox(height: 24),

            // Chart
            Container(
              height: 350,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Transaction Trends', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                    DropdownButtonHideUnderline(
                         child: DropdownButton<String>(
                           value: _dateRange,
                           items: const [
                             DropdownMenuItem(value: 'last7', child: Text('Last 7 Days')),
                             DropdownMenuItem(value: 'last30', child: Text('Last 30 Days')),
                             DropdownMenuItem(value: 'last90', child: Text('Last 90 Days')),
                             DropdownMenuItem(value: 'year', child: Text('This Year')),
                           ],
                           onChanged: (v) => setState(() => _dateRange = v!),
                           style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[800]),
                         ),
                       ),
                  ]),
                  const SizedBox(height: 24),
                   Expanded(
                     child: LineChart(
                       LineChartData(
                         gridData: FlGridData(show: true, drawVerticalLine: false),
                         titlesData: FlTitlesData(
                           leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, _) => Text('${val ~/ 1000}k', style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                           bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (val, _) {
                             if (val.toInt() >= 0 && val.toInt() < chartData.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(chartData[val.toInt()]['date'] as String, style: const TextStyle(fontSize: 10, color: Colors.grey)));
                             return const SizedBox();
                           })),
                           topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                           rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                         ),
                         lineBarsData: [
                            LineChartBarData(
                              spots: chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['amount'] as double)).toList(),
                              color: const Color(0xFFFDB913), isCurved: true, dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: const Color(0xFFFDB913), strokeWidth: 0)),
                            ),
                          ],
                       ),
                     ),
                   ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Filter & Search
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search transactions...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: (v) => setState(() => _searchTerm = v),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _FilterDropdown('All Types'),
                const SizedBox(width: 16),
                _FilterDropdown('All Status'),
              ],
            ),
            const SizedBox(height: 24),

            // Table
             Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Table(
                     defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                     columnWidths: const {0: FlexColumnWidth(1.2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1.5), 3: FlexColumnWidth(1.2), 4: FlexColumnWidth(1), 5: FlexColumnWidth(1), 6: FlexColumnWidth(1), 7: FlexColumnWidth(1)},
                     children: [
                       TableRow(decoration: BoxDecoration(color: Colors.grey[50]), children: [
                         _Header('Transaction ID'), _Header('Date'), _Header('Event'), _Header('Vendor'), _Header('Type'), _Header('Method'), _Header('Amount'), _Header('Status')
                       ]),
                       ...filteredTransactions.map((t) => TableRow(
                         decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
                         children: [
                           Padding(padding: const EdgeInsets.all(16), child: Text(t['id'] as String, style: const TextStyle(color: Color(0xFFFDB913), fontWeight: FontWeight.w500))),
                           Padding(padding: const EdgeInsets.all(16), child: Text(t['date'] as String, style: const TextStyle(color: Colors.grey, fontSize: 13))),
                           Padding(padding: const EdgeInsets.all(16), child: Text(t['event'] as String, style: const TextStyle(fontSize: 13))),
                           Padding(padding: const EdgeInsets.all(16), child: Text(t['vendor'] as String, style: const TextStyle(fontSize: 13, color: Colors.grey))),
                           Padding(padding: const EdgeInsets.all(16), child: Text(t['type'] as String, style: const TextStyle(fontSize: 13))),
                           Padding(padding: const EdgeInsets.all(16), child: Text(t['method'] as String, style: const TextStyle(fontSize: 13, color: Colors.grey))),
                           Padding(padding: const EdgeInsets.all(16), child: Text('₹${((t['amount'] as int)).toLocaleString()}', style: const TextStyle(color: Colors.green))),
                           Padding(padding: const EdgeInsets.all(16), child: Container(
                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                             decoration: BoxDecoration(color: _getStatusBgColor(t['status'] as String), borderRadius: BorderRadius.circular(8)),
                             child: Text(t['status'] as String, style: TextStyle(color: _getStatusColor(t['status'] as String), fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                           )),
                         ],
                       )),
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

extension IntExt on int {
  String toLocaleString() {
    return toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color, required this.bgColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[100]!), boxShadow: AppTheme.cardDecoration.boxShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
             const SizedBox(width: 12),
             Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
               Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
               Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
             ]),
          ]),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  const _FilterDropdown(this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: label,
          items: [DropdownMenuItem(value: label, child: Text(label))],
          onChanged: (v) {},
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[800]),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(16), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)));
  }
}
