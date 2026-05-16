import 'package:flutter/material.dart';

class SystemLogScreen extends StatelessWidget {
  const SystemLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('System Logs'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.black,
            tabs: [
              Tab(text: 'Error Logs (Critical)'),
              Tab(text: 'API Logs'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Error Logs Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildErrorCard(
                    'CRITICAL ERROR', 'DB_CONNECTION_TIMEOUT', '5-Feb 1:15 PM',
                    'Database connection timed out after 30 seconds.',
                    'Main Database (PostgreSQL)',
                    'Auto-reconnected, queries resumed.',
                    Colors.red
                  ),
                  const SizedBox(height: 16),
                  _buildErrorCard(
                    'HIGH PRIORITY', 'PAYMENT_GATEWAY_ERROR', '5-Feb 12:30 PM',
                    'Razorpay API returned 503 Service Unavailable.',
                    'Gateway: Razorpay',
                    'Automatically retried with Paytm. Success on 2nd attempt.',
                    Colors.orange
                  ),
                ],
              ),
            ),
            
            // API Logs Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('TIME')),
                  DataColumn(label: Text('ENDPOINT')),
                  DataColumn(label: Text('METHOD')),
                  DataColumn(label: Text('STATUS')),
                  DataColumn(label: Text('LATENCY')),
                ],
                rows: [
                  _buildApiRow('2:45:23 PM', '/api/v1/vendors/1234', 'GET', '200', '45ms'),
                  _buildApiRow('2:45:18 PM', '/api/v1/bookings', 'POST', '201', '234ms'),
                  _buildApiRow('2:45:12 PM', '/api/v1/payments', 'POST', '200', '1.2s'),
                   _buildApiRow('2:44:56 PM', '/api/v1/quotations', 'GET', '200', '89ms'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String level, String code, String time, String  msg, String detail1, String detail2, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(border: Border.all(color: color.withOpacity(0.3)), color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [Icon(Icons.warning_amber, color: color), const SizedBox(width: 8), Text(level, style: TextStyle(color: color, fontWeight: FontWeight.bold))]),
              Text(time, style: TextStyle(color: Colors.grey[700])),
            ],
          ),
          const SizedBox(height: 12),
          Text(code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(msg),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• $detail1'),
                Text('• $detail2'),
              ],
            ),
          )
        ],
      ),
    );
  }

  DataRow _buildApiRow(String time, String endpoint, String method, String status, String latency) {
    return DataRow(cells: [
      DataCell(Text(time)),
      DataCell(Text(endpoint, style: const TextStyle(fontFamily: 'monospace'))),
      DataCell(Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)), child: Text(method, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)))),
      DataCell(Text(status, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
       DataCell(Text(latency)),
    ]);
  }
}
