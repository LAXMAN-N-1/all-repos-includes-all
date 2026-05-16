import 'package:flutter/material.dart';

import '../../widgets/common_input.dart';

class PaymentManagementScreen extends StatelessWidget {
  const PaymentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
         padding: const EdgeInsets.all(24),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              const Text('Payment Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              // Key Stats
              Row(
                children: [
                  _buildStatusCard('Total Received', '₹8.5 L', Colors.green),
                  const SizedBox(width: 16),
                  _buildStatusCard('Pending', '₹2.3 L', Colors.orange),
                  const SizedBox(width: 16),
                  _buildStatusCard('Failed', '₹50 K', Colors.red),
                ],
              ),
              const SizedBox(height: 24),
              
              // Filters
              Row(
                children: [
                  Expanded(child: CommonInput(placeholder: 'Search Transaction ID...', prefixIcon: const Icon(Icons.search))),
                  const SizedBox(width: 16),
                  OutlinedButton(onPressed: (){}, child: const Text('Filter')),
                ],
              ),
              const SizedBox(height: 16),

              // Transactions
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                     return ListTile(
                       contentPadding: const EdgeInsets.all(16),
                       leading: CircleAvatar(
                         backgroundColor: i == 1 ? Colors.orange[50] : (i == 2 ? Colors.red[50] : Colors.green[50]),
                         child: Icon(
                           i == 1 ? Icons.access_time : (i == 2 ? Icons.error_outline : Icons.check),
                           color: i == 1 ? Colors.orange : (i == 2 ? Colors.red : Colors.green),
                           size: 20,
                         ),
                       ),
                       title: Text('#PAY-44556${6-i}', style: const TextStyle(fontWeight: FontWeight.bold)),
                       subtitle: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           const SizedBox(height: 4),
                           Text(i==0 ? 'Customer: Rajesh Kumar' : (i==1 ? 'Customer: Priya Shah' : 'Customer: Amit Verma')),
                           Text('Booking #BK-987${7+i} • Razorpay', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                         ],
                       ),
                       trailing: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         crossAxisAlignment: CrossAxisAlignment.end,
                         children: [
                           Text(i==0 ? '₹7,78,050' : (i==1 ? '₹3,45,000' : '₹1,20,000'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                           Text(i==0 ? 'Success' : (i==1 ? 'Pending' : 'Failed'), style: TextStyle(color: i==0 ? Colors.green : (i==1 ? Colors.orange : Colors.red), fontSize: 12, fontWeight: FontWeight.bold)),
                         ],
                       ),
                     );
                  },
                ),
              ),
           ],
         ),
      ),
    );
  }

  Widget _buildStatusCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
