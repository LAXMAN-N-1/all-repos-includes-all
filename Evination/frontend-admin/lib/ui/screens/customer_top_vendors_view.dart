import 'package:flutter/material.dart';

class CustomerTopVendorsView extends StatelessWidget {
  final int eventId;
  const CustomerTopVendorsView({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Vendors')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            const Text('Top Vendors for User Selection', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Event ID: $eventId', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            const Text('Customer can view and select top 3 vendors here.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
