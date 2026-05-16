import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/providers/role_provider.dart';
import '../../data/models/role_model.dart';
import '../../theme/app_theme.dart';
import 'role_form_dialog.dart';

class RoleManagementScreen extends ConsumerStatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  ConsumerState<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends ConsumerState<RoleManagementScreen> {
  // Stats
  // We calculate stats from the roles list.
  
  @override
  Widget build(BuildContext context) {
    final rolesAsync = ref.watch(rolesProvider);

    return Scaffold(
      body: rolesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (roles) {
          final totalRoles = roles.length;
          final totalUsers = roles.fold(0, (sum, r) => sum + r.usersCount);
          final permissionCategories = 6; // Hardcoded for now as per React, or dynamic if we fetch categories

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFFDB913), Color(0xFFE5A711)],
                          ).createShader(bounds),
                          child: const Text('Role Management', style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white
                          )),
                        ),
                        const SizedBox(height: 8),
                         Text('Define roles and assign permissions for your team', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => showDialog(context: context, builder: (_) => const RoleFormDialog()), 
                      icon: const Icon(Icons.add),
                      label: const Text('Create Role'),
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
                  crossAxisCount: 3,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.0,
                  children: [
                    _StatCard('Total Roles', '$totalRoles'),
                    _StatCard('Total Users', '$totalUsers'),
                    _StatCard('Permission Categories', '$permissionCategories'),
                  ],
                ),
                const SizedBox(height: 32),

                // Roles List (Grid)
                if (roles.isEmpty)
                   const Center(child: Text('No roles found.'))
                else
                   GridView.builder(
                     shrinkWrap: true,
                     physics: const NeverScrollableScrollPhysics(),
                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                       crossAxisCount: 2,
                       crossAxisSpacing: 24,
                       mainAxisSpacing: 24,
                       childAspectRatio: 1.5,
                     ),
                     itemCount: roles.length,
                     itemBuilder: (context, index) {
                       return _RoleCard(role: roles[index]);
                     },
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

class _RoleCard extends ConsumerWidget {
  final Role role;
  const _RoleCard({required this.role});

  Color _getColor(String color) {
    switch (color.toLowerCase()) {
      case 'red': return Colors.red;
      case 'purple': return Colors.amber;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'orange': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _getColor(role.color);
    
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.security, color: color, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(role.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(role.description ?? 'No description', style: TextStyle(color: Colors.grey[600], fontSize: 13), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18), 
                    color: Colors.grey[600],
                    onPressed: () => showDialog(context: context, builder: (_) => RoleFormDialog(role: role)),
                  ),
                  if (role.id != 1) // Prevent deleting Super Admin (assuming ID 1)
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red), 
                    onPressed: () => _confirmDelete(context, ref),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Text('Permissions:', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (role.roleRights ?? []).take(4).map((r) => 
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                 decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                 child: Text(r.menu?.name ?? 'Permission', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
               )
            ).toList(),
          ),
          if ((role.roleRights?.length ?? 0) > 4)
             Padding(padding: const EdgeInsets.only(top: 8), child: Text('+ ${(role.roleRights!.length - 4)} more', style: TextStyle(color: Colors.grey[500], fontSize: 11))),

          const Spacer(),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${role.usersCount} users assigned', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              TextButton(onPressed: () {}, child: const Text('View Users →', style: TextStyle(color: Color(0xFFFDB913)))),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Role'),
        content: Text('Are you sure you want to delete "${role.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
               ref.read(rolesProvider.notifier).removeRole(role.id);
               Navigator.pop(context);
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
