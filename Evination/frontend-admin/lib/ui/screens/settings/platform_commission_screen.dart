import 'package:flutter/material.dart';

class PlatformCommissionScreen extends StatelessWidget {
  const PlatformCommissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Commission Configuration', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            const Text('Default Commission Rates (Company Vendors)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildRateRow('Basic Tier', '20.00'),
                    _buildRateRow('Standard Tier', '18.00'),
                    _buildRateRow('Premium Tier', '15.00'),
                    _buildRateRow('Elite Tier', '12.00'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Category-Wise Overrides', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
             Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                   children: [
                     _buildOverrideRow('Weddings', 'Default'),
                     _buildOverrideRow('Corporate', '12.00%'),
                     _buildOverrideRow('Birthday', 'Default'),
                   ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateRow(String tier, String rate) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(child: Text(tier)),
          SizedBox(
            width: 100,
            child: TextField(
              decoration: InputDecoration(
                hintText: rate, 
                suffixText: '%', 
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverrideRow(String category, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(category),
          Text(val, style: TextStyle(color: val == 'Default' ? Colors.grey : Colors.blue, fontWeight: val != 'Default' ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
