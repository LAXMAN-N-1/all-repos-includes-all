import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../data/models/user_model.dart';
import '../../logic/providers/user_provider.dart';
import '../../logic/providers/role_provider.dart';
import '../../theme/app_theme.dart';
import 'user_form_dialog.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  String _searchTerm = '';
  String _roleFilter = 'All Roles';
  int? _menuOpenId;

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Super Admin': return Colors.red;
      case 'Event Manager': return Colors.amber;
      case 'Vendor Coordinator': return Colors.blue;
      case 'Finance Manager': return Colors.green;
      case 'Staff': return Colors.grey;
      default: return Colors.grey;
    }
  }
  
  Color _getRoleBgColor(String role) {
     return _getRoleColor(role).withOpacity(0.1);
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);
    final rolesAsync = ref.watch(rolesProvider); // For filter dropdown

    return Scaffold(
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (users) {
           final filteredUsers = users.where((u) {
             final matchesSearch = u.fullName.toLowerCase().contains(_searchTerm.toLowerCase()) || 
                                   u.email.toLowerCase().contains(_searchTerm.toLowerCase());
             final matchesRole = _roleFilter == 'All Roles' || (u.role?.name == _roleFilter);
             return matchesSearch && matchesRole;
           }).toList();
           
           // Stats
           final totalUsers = users.length;
           final activeUsers = users.where((u) => u.isActive).length;
           final admins = users.where((u) => u.role?.name == 'Super Admin').length;
           final staff = users.where((u) => u.role?.name == 'Staff').length;

           return SingleChildScrollView(
             padding: const EdgeInsets.all(24),
             child: Column(
               children: [
                 // Header
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFFFDB913), Color(0xFFE5A711)]).createShader(bounds),
                            child: const Text('Users & Staff', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                         ),
                         const SizedBox(height: 8),
                         Text('Manage team members and their role assignments', style: TextStyle(color: Colors.grey[600])),
                       ],
                     ),
                     ElevatedButton.icon(
                       onPressed: () => showDialog(context: context, builder: (_) => const UserFormDialog()),
                       icon: const Icon(Icons.add),
                       label: const Text('Add User'),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFFFDB913),
                         foregroundColor: Colors.white,
                         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                       ),
                     ),
                   ],
                 ),
                 const SizedBox(height: 32),
                 
                 // Stats Grid
                 GridView.count(
                   crossAxisCount: 4,
                   crossAxisSpacing: 24,
                   mainAxisSpacing: 24,
                   shrinkWrap: true,
                   physics: const NeverScrollableScrollPhysics(),
                   childAspectRatio: 1.5,
                   children: [
                      _StatCard('Total Users', '$totalUsers'),
                      _StatCard('Active Users', '$activeUsers'),
                      _StatCard('Admins', '$admins'),
                      _StatCard('Staff Members', '$staff'),
                   ],
                 ),
                 const SizedBox(height: 32),
                 
                 // Filters
                 Row(
                   children: [
                     Expanded(
                       child: TextField(
                         onChanged: (v) => setState(() => _searchTerm = v),
                         decoration: InputDecoration(
                           hintText: 'Search users...',
                           prefixIcon: const Icon(Icons.search),
                           filled: true,
                           fillColor: Colors.white,
                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                           enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                         ),
                       ),
                     ),
                     const SizedBox(width: 16),
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 16),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(12),
                         border: Border.all(color: Colors.grey[300]!),
                       ),
                       child: DropdownButtonHideUnderline(
                         child: DropdownButton<String>(
                           value: _roleFilter,
                           items: [
                             const DropdownMenuItem(value: 'All Roles', child: Text('All Roles')),
                             if (rolesAsync.hasValue) ...rolesAsync.value!.map((r) => DropdownMenuItem(value: r.name, child: Text(r.name))),
                           ],
                           onChanged: (v) => setState(() => _roleFilter = v!),
                         ),
                       ),
                     ),
                   ],
                 ),
                 const SizedBox(height: 24),
                 
                 // Table
                 Card(
                   elevation: 0,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!)),
                   child: Table(
                     columnWidths: const {
                       0: FlexColumnWidth(2), // User
                       1: FlexColumnWidth(2), // Contact
                       2: FlexColumnWidth(1), // Role
                       3: FlexColumnWidth(1.5), // Branch
                       4: FlexColumnWidth(1), // Status
                       5: FlexColumnWidth(1), // Last Active
                       6: FlexColumnWidth(0.5), // Actions
                     },
                     defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                     children: [
                       // Header
                       const TableRow(
                         decoration: BoxDecoration(color: Color(0xFFFAFAFA), borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                         children: [
                            Padding(padding: EdgeInsets.all(16), child: Text('User', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                            Padding(padding: EdgeInsets.all(16), child: Text('Contact', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                            Padding(padding: EdgeInsets.all(16), child: Text('Role', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                            Padding(padding: EdgeInsets.all(16), child: Text('Branch', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                            Padding(padding: EdgeInsets.all(16), child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                            Padding(padding: EdgeInsets.all(16), child: Text('Last Active', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                            Padding(padding: EdgeInsets.all(16), child: Text('')),
                         ],
                       ),
                       // Rows
                       ...filteredUsers.map((user) {
                         final roleName = user.role?.name ?? 'No Role';
                         return TableRow(
                           decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
                           children: [
                             Padding(
                               padding: const EdgeInsets.all(16),
                               child: Row(
                                 children: [
                                   CircleAvatar(
                                     backgroundColor: const Color(0xFFFFF8E1),
                                     child: Text(
                                       user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                                       style: const TextStyle(color: Color(0xFFFDB913), fontWeight: FontWeight.bold),
                                     ),
                                   ),
                                   const SizedBox(width: 12),
                                   Expanded(child: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w600))),
                                 ],
                               ),
                             ),
                             Padding(
                               padding: const EdgeInsets.all(16),
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Row(children: [const Icon(Icons.email_outlined, size: 14, color: Colors.grey), const SizedBox(width: 4), Expanded(child: Text(user.email, style: const TextStyle(fontSize: 13, color: Colors.grey), overflow: TextOverflow.ellipsis))]),
                                   if (user.phone != null)
                                   Row(children: [const Icon(Icons.phone_outlined, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(user.phone!, style: const TextStyle(fontSize: 13, color: Colors.grey))]),
                                 ],
                               ),
                             ),
                             Padding(
                               padding: const EdgeInsets.all(16),
                               child: Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                 decoration: BoxDecoration(color: _getRoleBgColor(roleName), borderRadius: BorderRadius.circular(8)),
                                 child: Text(roleName, style: TextStyle(color: _getRoleColor(roleName), fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                               ),
                             ),
                             Padding(
                               padding: const EdgeInsets.all(16),
                               child: Text(user.branch?.name ?? 'Headquarters', style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis),
                             ),
                             Padding(
                               padding: const EdgeInsets.all(16),
                               child: Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                 decoration: BoxDecoration(
                                   color: user.isActive ? Colors.green[50] : Colors.grey[100],
                                   borderRadius: BorderRadius.circular(6),
                                 ),
                                 child: Text(
                                   user.isActive ? 'Active' : 'Inactive',
                                   style: TextStyle(color: user.isActive ? Colors.green[700] : Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold),
                                   textAlign: TextAlign.center,
                                 ),
                               ),
                             ),
                             Padding(
                               padding: const EdgeInsets.all(16),
                               child: Text(
                                 user.lastLoginAt != null ? timeago.format(user.lastLoginAt!) : 'Never',
                                 style: const TextStyle(color: Colors.grey, fontSize: 13),
                               ),
                             ),
                             Padding(
                               padding: const EdgeInsets.all(16),
                               child: PopupMenuButton(
                                 icon: const Icon(Icons.more_vert, color: Colors.grey),
                                 itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Edit User')])),
                                    const PopupMenuItem(value: 'role', child: Row(children: [Icon(Icons.security, size: 16), SizedBox(width: 8), Text('Change Role')])),
                                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                                 ],
                                 onSelected: (val) {
                                    if (val == 'edit') showDialog(context: context, builder: (_) => UserFormDialog(user: user));
                                 },
                               ),
                             ),
                           ],
                         );
                       }),
                     ],
                   ),
                 ),
               ],
             ),
           );
        },
      ),
    );
  }
}


class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: AppTheme.cardDecoration.boxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 4),
          ShaderMask(
             shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFFFDB913), Color(0xFFE5A711)]).createShader(bounds),
             child: Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
