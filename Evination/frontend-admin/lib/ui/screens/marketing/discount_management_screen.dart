import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class DiscountManagementScreen extends StatelessWidget {
  const DiscountManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 const Text('Discount Coupons', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                 ElevatedButton.icon(onPressed: (){}, icon: const Icon(Icons.add), label: const Text('Create Coupon')),
               ],
             ),
             const SizedBox(height: 24),
             
             // List
             _buildCouponCard('VALENTINE24', '10% Off', 'Active (9 days left)', 67, 500),
             const SizedBox(height: 16),
             _buildCouponCard('FIRST50', 'Flat ₹5000', 'Active (Evergreen)', 156, null),
             const SizedBox(height: 16),
             _buildCouponCard('BDAYBASH24', 'Flat ₹2000', 'Active', 45, 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponCard(String code, String value, String status, int used, int? limit) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid)),
            child: Text(code, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(status, style: TextStyle(color: Colors.green[700], fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$used uses', style: const TextStyle(fontWeight: FontWeight.bold)),
              if (limit != null) Text('of $limit limit', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          const SizedBox(width: 16),
          IconButton(onPressed: (){}, icon: const Icon(Icons.edit)),
        ],
      ),
    );
  }
}
