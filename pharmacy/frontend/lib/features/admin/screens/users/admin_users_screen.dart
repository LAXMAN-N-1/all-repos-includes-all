import 'package:flutter/material.dart';

import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_users.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:frontend/features/admin/services/users_service.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/storage_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late UsersService _usersService;
  List<AdminUser> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _usersService = UsersService(ApiClient(StorageService()));
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await _usersService.getAdminUsers();
    if (mounted) setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Admin Users", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text("Manage platform administrators and staff", style: TextStyle(color: Colors.white60)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person_add),
                  label: const Text("Invite Admin"),
                  style: ElevatedButton.styleFrom(backgroundColor: AuraColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: AuraColors.primary))
                  : Container(
                decoration: BoxDecoration(
                  color: AuraColors.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AuraColors.glassBorder),
                ),
                child: SingleChildScrollView(
                  child: DataTable(
                    headingTextStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                    dataTextStyle: const TextStyle(color: Colors.white),
                    columns: const [
                       DataColumn(label: Text("User")),
                       DataColumn(label: Text("Role")),
                       DataColumn(label: Text("Status")),
                       DataColumn(label: Text("Last Login")),
                       DataColumn(label: Text("Actions")),
                    ],
                    rows: _users.map((user) => DataRow(
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AuraColors.primary.withOpacity(0.2),
                                child: Text(user.name.isNotEmpty ? user.name[0] : '?', style: const TextStyle(color: AuraColors.primary, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(user.email, style: const TextStyle(fontSize: 11, color: Colors.white54)),
                                ],
                              ),
                            ],
                          )
                        ),
                        DataCell(Text(user.role)),
                        DataCell(_buildStatusBadge(user.status)),
                        DataCell(Text(DateFormat('MMM dd, hh:mm a').format(user.lastLogin))),
                        DataCell(Row(
                          children: [
                            IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.white30), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent), onPressed: () {}),
                          ],
                        )),
                      ],
                    )).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == "Active" ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
