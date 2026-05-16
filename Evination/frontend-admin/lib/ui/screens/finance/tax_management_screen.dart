import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class TaxManagementScreen extends StatelessWidget {
  const TaxManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tax Management & Compliance', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            // Compliance Status
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppTheme.primary50, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.primary200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Compliance Status: Feb 2024', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildComplianceItem('GST Returns Filed (Jan 2024)', true),
                  _buildComplianceItem('Next GST Filing Due: 20-Feb', false, isWarning: true),
                  _buildComplianceItem('TDS Deducted & Deposited', true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // GST Summary
            const Text('GST Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
             const SizedBox(height: 16),
             Row(
               children: [
                 Expanded(child: _buildTaxCard('Output GST', '₹4,26,600', Colors.blue)),
                 const SizedBox(width: 16),
                 Expanded(child: _buildTaxCard('Input GST', '₹1,22,400', Colors.orange)),
                 const SizedBox(width: 16),
                 Expanded(child: _buildTaxCard('Net Payable', '₹3,04,200', Colors.red)),
               ],
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceItem(String text, bool isDone, {bool isWarning = false}) {
     return Padding(
       padding: const EdgeInsets.only(bottom: 8.0),
       child: Row(
         children: [
           Icon(isDone ? Icons.check_circle : (isWarning ? Icons.warning : Icons.circle), color: isDone ? Colors.green : (isWarning ? Colors.orange : Colors.grey)),
           const SizedBox(width: 8),
           Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
         ],
       ),
     );
  }

  Widget _buildTaxCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
