import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class RevenueManagementScreen extends StatelessWidget {
  const RevenueManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Consistent background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
             // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Revenue Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                OutlinedButton(onPressed: (){}, child: const Text('Export Report')),
              ],
            ),
             const SizedBox(height: 24),
             
             // Breakdown Table
             Card(
               elevation: 0,
               child: Padding(
                 padding: const EdgeInsets.all(24.0),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     const Text('Revenue Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                     const SizedBox(height: 16),
                     Table(
                       border: TableBorder(horizontalInside: BorderSide(color: Colors.grey.shade200)),
                       children: const [
                         TableRow(children: [
                           Padding(padding: EdgeInsets.all(8.0), child: Text('SOURCE', style: TextStyle(fontWeight: FontWeight.bold))),
                           Padding(padding: EdgeInsets.all(8.0), child: Text('AMOUNT', style: TextStyle(fontWeight: FontWeight.bold))),
                           Padding(padding: EdgeInsets.all(8.0), child: Text('% TOTAL', style: TextStyle(fontWeight: FontWeight.bold))),
                         ]),
                         TableRow(children: [
                           Padding(padding: EdgeInsets.all(8.0), child: Text('Booking Commissions')),
                           Padding(padding: EdgeInsets.all(8.0), child: Text('₹18.5 L')),
                           Padding(padding: EdgeInsets.all(8.0), child: Text('78.2%')),
                         ]),
                          TableRow(children: [
                           Padding(padding: EdgeInsets.all(8.0), child: Text('Service Fees')),
                           Padding(padding: EdgeInsets.all(8.0), child: Text('₹3.2 L')),
                           Padding(padding: EdgeInsets.all(8.0), child: Text('13.5%')),
                         ]),
                       ],
                     ),
                   ],
                 ),
               ),
             ),
             const SizedBox(height: 24),
             
             // Forecasting
             Container(
               padding: const EdgeInsets.all(24),
               decoration: BoxDecoration(color: AppTheme.primary500, borderRadius: BorderRadius.circular(12)),
               child: const Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text('Projected Revenue (Next Month)', style: TextStyle(color: Colors.white70, fontSize: 14)),
                       SizedBox(height: 4),
                       Text('₹32.8 L', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                     ],
                   ),
                    Icon(Icons.trending_up, color: Colors.white, size: 48),
                 ],
               ),
             ),
          ],
        ),
      ),
    );
  }
}
