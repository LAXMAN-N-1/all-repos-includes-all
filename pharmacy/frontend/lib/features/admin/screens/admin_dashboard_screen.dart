import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart'; 
import 'package:provider/provider.dart';

import 'package:frontend/core/services/admin_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await Provider.of<AdminService>(context, listen: false).getDashboardStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      // debugPrint("Error loading stats: $e");
      if (mounted) {
        // Fallback to defaults on error
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine values with fallback
    final mrr = _stats['total_revenue'] != null ? "\$${_stats['total_revenue']}" : "\$0";
    final activeOrgs = _stats['active_orgs']?.toString() ?? "0";
    final totalOrgs = _stats['total_orgs']?.toString() ?? "0";
    // Mock churn for now
    final churnRate = "0.0%";

    return _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AuraColors.primary))
        : SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Header
            Text(
              "Dashboard Overview",
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Real-time platform metrics and insights.",
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 32),

            // KPI Cards Row
            Row(
              children: [
                _buildKpiCard(
                  title: "Monthly Revenue",
                  value: mrr,
                  trend: "Real-time",
                  isPositive: true,
                  icon: Icons.attach_money,
                  color: AuraColors.primary,
                ),
                const SizedBox(width: 24),
                _buildKpiCard(
                  title: "Active Organizations",
                  value: activeOrgs,
                  trend: "of $totalOrgs Total",
                  isPositive: true,
                  icon: Icons.business,
                  color: AuraColors.secondary,
                ),
                const SizedBox(width: 24),
                _buildKpiCard(
                  title: "Churn Rate",
                  value: churnRate,
                  trend: "Stable",
                  isPositive: true,
                  icon: Icons.trending_down,
                  color: Colors.green,
                ),
                const SizedBox(width: 24),
                _buildKpiCard(
                  title: "System Health",
                  value: "100%",
                  trend: "Operational",
                  isPositive: true,
                  icon: Icons.health_and_safety,
                  color: Colors.blue,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Charts Area (Static for now, but layout ready)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 400,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AuraColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AuraColors.glassBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             const Text("Revenue Trend (MRR)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                               decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
                               child: const Text("Last 12 Months", style: TextStyle(color: Colors.white70, fontSize: 12)),
                             ),
                           ],
                         ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 1,
                                getDrawingHorizontalLine: (value) {
                                  return const FlLine(color: Colors.white10, strokeWidth: 1);
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      const style = TextStyle(color: Colors.white54, fontSize: 12);
                                      String text;
                                      switch (value.toInt()) {
                                        case 0: text = 'JAN'; break;
                                        case 2: text = 'MAR'; break;
                                        case 4: text = 'MAY'; break;
                                        case 6: text = 'JUL'; break;
                                        case 8: text = 'SEP'; break;
                                        case 10: text = 'NOV'; break;
                                        default: return Container();
                                      }
                                      return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: style));
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      return Text('\$${value.toInt()}k', style: const TextStyle(color: Colors.white54, fontSize: 10));
                                    },
                                    reservedSize: 42,
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              minX: 0,
                              maxX: 11,
                              minY: 0,
                              maxY: 6,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: const [
                                    FlSpot(0, 3), FlSpot(1, 1), FlSpot(2, 4), FlSpot(3, 2), FlSpot(4, 5),
                                    FlSpot(5, 3), FlSpot(6, 4), FlSpot(7, 4.5), FlSpot(8, 3.5), FlSpot(9, 5),
                                    FlSpot(10, 5.5), FlSpot(11, 4),
                                  ],
                                  isCurved: true,
                                  gradient: const LinearGradient(colors: [AuraColors.primary, AuraColors.secondary]),
                                  barWidth: 4,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        AuraColors.primary.withOpacity(0.3),
                                        AuraColors.secondary.withOpacity(0.0),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Pie Chart / Growth
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 400,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AuraColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AuraColors.glassBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Org Growth", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 24),
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 40,
                              sections: [
                                PieChartSectionData(
                                  color: AuraColors.primary,
                                  value: 40,
                                  title: '40%',
                                  radius: 50,
                                  titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                PieChartSectionData(
                                  color: Colors.orange,
                                  value: 30,
                                  title: '30%',
                                  radius: 50,
                                  titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                PieChartSectionData(
                                  color: Colors.purple,
                                  value: 15,
                                  title: '15%',
                                  radius: 50,
                                  titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                PieChartSectionData(
                                  color: Colors.blue,
                                  value: 15,
                                  title: '15%',
                                  radius: 50,
                                  titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Legend
                        const SizedBox(height: 16),
                        _buildLegendItem("Enterprise", AuraColors.primary),
                        const SizedBox(height: 8),
                        _buildLegendItem("SMB", Colors.orange),
                        const SizedBox(height: 8),
                        _buildLegendItem("Clinics", Colors.purple),
                        const SizedBox(height: 8),
                        _buildLegendItem("Others", Colors.blue),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildKpiCard({required String title, required String value, required String trend, required bool isPositive, required IconData icon, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AuraColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AuraColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isPositive ? Colors.green : Colors.transparent).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(value, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.white60, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
