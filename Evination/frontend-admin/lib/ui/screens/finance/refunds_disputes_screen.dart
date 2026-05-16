import 'package:flutter/material.dart';

class RefundsDisputesScreen extends StatelessWidget {
  const RefundsDisputesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Refunds & Disputes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // Pending Refunds
            const Text('Pending Refund Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              color: Colors.red[50], // Alert color
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.red.shade200)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('REFUND #REF-12345', style: TextStyle(fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                          child: const Text('HIGH PRIORITY', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Refund Amount: ₹2,41,000 (70% Policy)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Reason: Event Cancelled by Customer', style: TextStyle(color: Colors.grey[800])),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('Approve', style: TextStyle(color: Colors.white))),
                        const SizedBox(width: 8),
                        OutlinedButton(onPressed: (){}, child: const Text('Reject')),
                        const SizedBox(width: 8),
                        TextButton(onPressed: (){}, child: const Text('View Details')),
                      ],
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
}
