import 'package:flutter/material.dart';

class AlertSettingsScreen extends StatefulWidget {
  const AlertSettingsScreen({super.key});

  @override
  State<AlertSettingsScreen> createState() => _AlertSettingsScreenState();
}

class _AlertSettingsScreenState extends State<AlertSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('System Alerts Configuration'), elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAlertGroup('CRITICAL ALERTS (Always Enabled)', [
              _buildAlertItem('Payment Gateway Down', 'Notify: Super Admin, Finance', true),
              _buildAlertItem('Database Connection Lost', 'Notify: Tech Team', true),
              _buildAlertItem('Security Breach Detected', 'Notify: All Admins', true),
            ], color: Colors.red),

            const SizedBox(height: 24),
            _buildAlertGroup('HIGH PRIORITY', [
              _buildAlertItem('Daily Revenue Drop >20%', 'Notify: Finance Manager', true),
              _buildAlertItem('Refund Request >₹50K', 'Notify: Finance Manager', true),
              _buildAlertItem('Vendor Rating < 3.5', 'Notify: Vendor Mgr', true),
            ], color: Colors.orange),

             const SizedBox(height: 24),
            _buildAlertGroup('MEDIUM PRIORITY', [
              _buildAlertItem('Vendor App Pending > 3 Days', 'Notify: Admin Mgr', true),
              _buildAlertItem('Monthly Target < 70%', 'Notify: Dept Heads', true),
              _buildAlertItem('Website Traffic Drop', 'Notify: Marketing', false),
            ], color: Colors.amber),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertGroup(String title, List<Widget> children, {required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(Icons.circle, size: 12, color: color), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))]),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(12)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildAlertItem(String title, String subtitle, bool value) {
    return SwitchListTile(
      value: value, 
      onChanged: (v){},
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
    );
  }
}
