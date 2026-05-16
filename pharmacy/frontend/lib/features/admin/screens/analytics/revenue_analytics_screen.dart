import 'package:flutter/material.dart';
import 'package:frontend/features/admin/screens/admin_layout.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_analytics.dart';
import 'package:google_fonts/google_fonts.dart';

class RevenueAnalyticsScreen extends StatelessWidget {
  const RevenueAnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text("Revenue Analytics", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
             const SizedBox(height: 24),
             
             // Top Cards
             Row(
               children: [
                 _buildMetricCard("MRR", "\$62,000", "+10%", Colors.green),
                 const SizedBox(width: 20),
                 _buildMetricCard("ARR", "\$744,000", "+8%", Colors.green),
                 const SizedBox(width: 20),
                 _buildMetricCard("ARPU", "\$436", "+2%", Colors.blue),
                 const SizedBox(width: 20),
                 _buildMetricCard("Churn Revenue", "-\$1,200", "-0.5%", Colors.red),
               ],
             ),
             
             const SizedBox(height: 32),
             
             // Chart Area (Mock Visual)
             Expanded(
               child: Container(
                 padding: const EdgeInsets.all(24),
                 decoration: BoxDecoration(
                   color: AuraColors.surface,
                   borderRadius: BorderRadius.circular(16),
                   border: Border.all(color: AuraColors.glassBorder),
                 ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text("Revenue Growth (6 Months)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 24),
                     Expanded(
                       child: Row(
                         crossAxisAlignment: CrossAxisAlignment.end,
                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                         children: mockRevenueTrend.map((data) {
                           return Column(
                             mainAxisAlignment: MainAxisAlignment.end,
                             children: [
                               Container(
                                 width: 40,
                                 height: (data.revenue / 62000) * 300, // Scale height mock
                                 decoration: BoxDecoration(
                                   color: AuraColors.primary,
                                   borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                   gradient: LinearGradient(
                                     begin: Alignment.bottomCenter,
                                     end: Alignment.topCenter,
                                     colors: [AuraColors.primary.withOpacity(0.5), AuraColors.primary],
                                   )
                                 ),
                               ),
                               const SizedBox(height: 8),
                               Text(data.month, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                             ],
                           );
                         }).toList(),
                       ),
                     ),
                   ],
                 ),
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String change, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AuraColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AuraColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(change, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
