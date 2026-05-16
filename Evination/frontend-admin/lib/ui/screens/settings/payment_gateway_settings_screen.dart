import 'package:flutter/material.dart';

class PaymentGatewaySettingsScreen extends StatelessWidget {
  const PaymentGatewaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Gateway Configuration', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            _buildGatewayCard('Razorpay', true, true, '2.0% + ₹0'),
            const SizedBox(height: 16),
            _buildGatewayCard('Paytm', true, false, '1.99% + ₹0'),
            const SizedBox(height: 16),
            _buildGatewayCard('PhonePe', false, false, '-'),

            const SizedBox(height: 32),
            const Text('Routing Rules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
             Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                 child: Column(
                   children: [
                     _buildSettingRow('Primary Gateway', 'Razorpay'),
                     _buildSettingRow('Fallback Gateway', 'Paytm'),
                     const Divider(),
                     SwitchListTile(value: true, onChanged: (v){}, title: const Text('Smart Routing'), subtitle: const Text('Automatically route based on success rate')),
                   ],
                 ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGatewayCard(String name, bool enabled, bool primary, String fee) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: enabled ? Colors.green.shade200 : Colors.grey.shade300, width: enabled ? 1.5 : 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 40, height: 40, color: Colors.grey[200], child: const Icon(Icons.payment)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        if (primary) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)), child: const Text('PRIMARY', style: TextStyle(fontSize: 10, color: Colors.blue)))]
                      ],
                    ),
                    Text(enabled ? 'Active • Fee: $fee' : 'Disabled', style: TextStyle(color: enabled ? Colors.green : Colors.grey)),
                  ],
                ),
              ),
              Switch(value: enabled, onChanged: (v){}),
            ],
          ),
          if (enabled) ...[
             const SizedBox(height: 16),
             const TextField(obscureText: true, decoration: InputDecoration(labelText: 'API Secret', border: OutlineInputBorder(), isDense: true)),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
