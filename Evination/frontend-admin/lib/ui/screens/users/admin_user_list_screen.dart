import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class AdminUserListScreen extends StatelessWidget {
  const AdminUserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header stats
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Admin Users', '12', Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Active Now', '5', Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Super Admins', '2', Colors.purple)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Dept Heads', '5', Colors.orange)),
              ],
            ),
             const SizedBox(height: 24),
             
             // Actions
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 const Text('Admin Users', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                 Row(
                   children: [
                     OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.file_upload, size: 16), label: const Text('Import')),
                     const SizedBox(width: 12),
                     OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.download, size: 16), label: const Text('Export')),
                     const SizedBox(width: 12),
                     ElevatedButton.icon(
                       onPressed: () {}, // Navigate to Add User
                       icon: const Icon(Icons.add, size: 16),
                       label: const Text('Add New Admin'),
                       style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary600, foregroundColor: Colors.white),
                     ),
                   ],
                 ),
               ],
             ),
             const SizedBox(height: 24),
             
             // Filters
             Row(
               children: [
                 _buildFilterChip('Role: All'),
                 const SizedBox(width: 8),
                 _buildFilterChip('Status: All'),
                 const SizedBox(width: 8),
                 _buildFilterChip('Department: All'),
                 const Spacer(),
                 SizedBox(width: 250, child: TextField(decoration: InputDecoration(hintText: 'Search...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)))),
               ],
             ),
             const SizedBox(height: 24),

            // User Cards List
            _buildUserCard(
              'ADMIN-001', 'Rajesh Kumar', 'SUPER ADMINISTRATOR',
              'rajesh.kumar@evination.com', '+91-98765-43210', 'Management',
              'Super Administrator (Full Access)', true,
              'Today, 9:30 AM', '103.xxx.xxx.xxx', 'Windows 11, Chrome 120',
              '1-Jan-2023', '456', 'Active', Colors.green
            ),
            const SizedBox(height: 16),
            _buildUserCard(
              'ADMIN-002', 'Priya Shah', 'ADMIN MANAGER',
              'priya.shah@evination.com', '+91-99887-66554', 'Operations',
              'Admin Manager', true,
              'Today, 2:15 PM', '103.xxx.xxx.xxx', '-',
              '15-Mar-2023', '312', 'Active', Colors.green
            ),
             const SizedBox(height: 16),
            _buildUserCard(
              'ADMIN-004', 'Sneha Reddy', 'SUPPORT MANAGER',
              'sneha.reddy@evination.com', '+91-96543-21000', 'Customer Support',
              'Support Manager', true,
              '3-Feb-2024', '-', '-',
              '10-Aug-2023', '150', 'Inactive (Leave)', Colors.orange
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      deleteIcon: const Icon(Icons.arrow_drop_down),
      onDeleted: () {}, // Just for visual arrow
    );
  }

  Widget _buildUserCard(
    String id, String name, String roleBadge, String email, String phone, String dept,
    String roleDesc, bool is2FA, String lastLogin, String ip, String device,
    String joined, String logins, String status, Color statusColor
  ) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(backgroundColor: AppTheme.primary50, child: Text(name.substring(0,1), style: const TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('$id | $name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(roleBadge, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(email, style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text('$phone • $dept', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12))),
            ],
          ),
          const Divider(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ROLE & PERMISSIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text('• Role: $roleDesc'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ACCOUNT STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                     const SizedBox(height: 8),
                     Text('• Last Login: $lastLogin'),
                     Text('• IP: $ip'),
                     Text('• Device: $device'),
                     Text('• 2FA: ${is2FA ? "Enabled" : "Disabled"}'),
                  ],
                ),
              ),
               Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ACTIVITY SUMMARY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                     const SizedBox(height: 8),
                     Text('• Joined: $joined'),
                     Text('• Logins: $logins'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: (){}, child: const Text('View Profile')),
              const SizedBox(width: 12),
              OutlinedButton(onPressed: (){}, child: const Text('Edit')),
              const SizedBox(width: 12),
              OutlinedButton(onPressed: (){}, child: const Text('Change Role')),
            ],
          ),
        ],
      ),
    );
  }
}
