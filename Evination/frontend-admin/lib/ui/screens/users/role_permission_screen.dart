import 'package:flutter/material.dart';

class RolePermissionScreen extends StatelessWidget {
  const RolePermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Roles & Permissions'), elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Permissions Matrix', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(onPressed: (){}, icon: const Icon(Icons.add), label: const Text('Create Custom Role')),
              ],
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                columns: const [
                   DataColumn(label: Text('MODULE/FEATURE', style: TextStyle(fontWeight: FontWeight.bold))),
                   DataColumn(label: Text('Super Admin', style: TextStyle(fontWeight: FontWeight.bold))),
                   DataColumn(label: Text('Admin Mgr', style: TextStyle(fontWeight: FontWeight.bold))),
                   DataColumn(label: Text('Finance Mgr', style: TextStyle(fontWeight: FontWeight.bold))),
                   DataColumn(label: Text('Support Mgr', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: [
                  _buildPermissionRow('DASHBOARD', 'Overview', true, true, true, true),
                  _buildPermissionRow('DASHBOARD', 'Analytics', true, true, true, false),
                  
                  _buildPermissionRow('VENDORS', 'View List', true, true, true, true),
                  _buildPermissionRow('VENDORS', 'Approve/Reject', true, true, false, false),
                  _buildPermissionRow('VENDORS', 'Performance', true, true, true, false),

                  _buildPermissionRow('FINANCE', 'View Revenue', true, false, true, false),
                  _buildPermissionRow('FINANCE', 'Process Payouts', true, false, true, false),
                  _buildPermissionRow('FINANCE', 'Tax Mgmt', true, false, true, false),

                  _buildPermissionRow('SUPPORT', 'View Tickets', true, true, true, true),
                  _buildPermissionRow('SUPPORT', 'Resolve Tickets', true, false, false, true),
                  
                  _buildPermissionRow('SETTINGS', 'Platform Config', true, false, false, false),
                  _buildPermissionRow('SETTINGS', 'User Mgmt', true, false, false, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildPermissionRow(String module, String feature, bool superAdmin, bool adminMgr, bool financeMgr, bool supportMgr) {
    return DataRow(cells: [
      DataCell(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(module, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          Text(feature, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      )),
      DataCell(_buildCheck(superAdmin)),
      DataCell(_buildCheck(adminMgr)),
      DataCell(_buildCheck(financeMgr)),
      DataCell(_buildCheck(supportMgr)),
    ]);
  }

  Widget _buildCheck(bool hasAccess) {
    return Icon(
      hasAccess ? Icons.check_circle : Icons.cancel,
      color: hasAccess ? Colors.green : Colors.grey[300],
      size: 20,
    );
  }
}
