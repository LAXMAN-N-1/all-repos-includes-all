import 'package:flutter/material.dart';

class LoginHistoryScreen extends StatelessWidget {
  const LoginHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CURRENTLY ACTIVE SESSIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),
            
            _buildSessionCard(
              'ADMIN-001 | Rajesh Kumar (Super Admin)', 'Active (Current Session)', Colors.green,
              'Login: 5-Feb, 9:30 AM', 'Mumbai, India', 'Windows 11, Chrome', true
            ),
             const SizedBox(height: 16),
             _buildSessionCard(
              'ADMIN-002 | Priya Shah (Admin Mgr)', 'Active', Colors.green,
              'Login: 5-Feb, 2:15 PM', 'Delhi, India', 'MacBook Pro, Safari', true
            ),

             const SizedBox(height: 32),
             const Text('RECENT LOGIN HISTORY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
             const SizedBox(height: 16),
             
             DataTable(
               columns: const [
                 DataColumn(label: Text('DATE/TIME')),
                 DataColumn(label: Text('USER')),
                 DataColumn(label: Text('STATUS')),
                 DataColumn(label: Text('IP/LOCATION')),
                 DataColumn(label: Text('2FA')),
               ],
               rows: [
                 _buildRow('5-Feb, 2:15 PM', 'ADMIN-002', 'Login', 'Delhi, IN', true),
                 _buildRow('5-Feb, 1:30 PM', 'ADMIN-005', 'Login', 'Mumbai, IN', true),
                 _buildRow('5-Feb, 12:45 PM', 'Unknown', 'Failed', '45.xxx (CN)', false, isFail: true),
                 _buildRow('5-Feb, 12:43 PM', 'Unknown', 'Failed', '45.xxx (CN)', false, isFail: true),
                 _buildRow('5-Feb, 11:00 AM', 'ADMIN-003', 'Login', 'Mumbai, IN', true),
               ],
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(String title, String status, Color color, String login, String loc, String device, bool is2fa) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
               Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('• $login'),
              const SizedBox(width: 16),
               Text('• $loc'),
               const SizedBox(width: 16),
                Text('• $device'),
                const SizedBox(width: 16),
                Text('• ${is2fa ? "2FA Verified" : "No 2FA"}', style: TextStyle(color: is2fa ? Colors.green : Colors.red)),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: (){}, child: const Text('End Session', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  DataRow _buildRow(String time, String user, String status, String loc, bool is2fa, {bool isFail = false}) {
    return DataRow(cells: [
      DataCell(Text(time)),
      DataCell(Text(user)),
      DataCell(Row(children: [Icon(isFail ? Icons.close : Icons.check, size: 16, color: isFail ? Colors.red : Colors.green), const SizedBox(width: 4), Text(status, style: TextStyle(color: isFail ? Colors.red : Colors.green))])),
      DataCell(Text(loc)),
      DataCell(Text(is2fa ? '✓' : '-', style: TextStyle(fontWeight: FontWeight.bold, color: is2fa ? Colors.green : Colors.grey))),
    ]);
  }
}
