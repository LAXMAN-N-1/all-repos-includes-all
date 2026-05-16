import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class PayoutManagementScreen extends StatelessWidget {
  const PayoutManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payout Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Track and process vendor payouts', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text('Export Report'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Summary Cards
            Row(
              children: [
                _buildSummaryCard(context, 'Total Payable', '₹12,45,000', Colors.orange),
                const SizedBox(width: 16),
                _buildSummaryCard(context, 'Processed Today', '₹4,20,000', Colors.green),
                const SizedBox(width: 16),
                _buildSummaryCard(context, 'Pending Requests', '23', Colors.blue),
              ],
            ),
            const SizedBox(height: 24),

            // Payout Table
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                columns: const [
                  DataColumn(label: Text('Vendor ID')),
                  DataColumn(label: Text('Vendor Name')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Bank Details')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Action')),
                ],
                rows: [
                  _buildRow('V-1023', 'Elegant Caterers', '₹45,000', 'HDFC **** 1234', 'Pending'),
                  _buildRow('V-1045', 'Royal Decor', '₹22,500', 'SBI **** 5678', 'Processing'),
                  _buildRow('V-1089', 'Click Studio', '₹15,000', 'ICICI **** 9012', 'Pending'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  DataRow _buildRow(String id, String name, String amount, String bank, String status) {
    return DataRow(cells: [
      DataCell(Text(id)),
      DataCell(Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(amount)),
      DataCell(Text(bank, style: TextStyle(color: Colors.grey[600], fontSize: 12))),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: status == 'Pending' ? Colors.orange[50] : Colors.blue[50],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(status, style: TextStyle(color: status == 'Pending' ? Colors.orange : Colors.blue, fontSize: 12)),
      )),
      DataCell(TextButton(onPressed: (){}, child: const Text('Pay Now'))),
    ]);
  }
}
