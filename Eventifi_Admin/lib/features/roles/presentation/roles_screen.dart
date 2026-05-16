import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eventifi_admin/features/roles/presentation/role_controller.dart';
import 'package:eventifi_admin/features/roles/presentation/widgets/role_form_dialog.dart';

class RolesScreen extends ConsumerWidget {
  const RolesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(roleControllerProvider);

    return Padding(
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
                   Text(
                    'Role Management',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                   Text(
                    'Define roles and assign permissions for your team',
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                    ),
                  ),
                 ],
               ),
              ElevatedButton.icon(
                onPressed: () {
                    showDialog(context: context, builder: (_) => const RoleFormDialog());
                }, 
                icon: const Icon(Icons.add),
                label: const Text('Create Role'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[600],
                  foregroundColor: Colors.white,
                ),
              )
            ],
          ),
          const SizedBox(height: 32),
          // Stats Row (Mock for now, or derive from list)
          if (rolesAsync.value != null)
          Row(
            children: [
              _StatCard(title: 'Total Roles', value: '${rolesAsync.value!.length}'),
            ],
          ),
          const SizedBox(height: 32),
           Expanded(
             child: rolesAsync.when(
               loading: () => const Center(child: CircularProgressIndicator()),
               error: (err, stack) => Center(child: Text('Error: $err')),
               data: (roles) {
                 if (roles.isEmpty) {
                   return const Center(child: Text('No roles found.'));
                 }
                 return GridView.builder(
                   gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                     maxCrossAxisExtent: 400,
                     childAspectRatio: 1.5,
                     crossAxisSpacing: 16,
                     mainAxisSpacing: 16,
                   ),
                   itemCount: roles.length,
                   itemBuilder: (context, index) {
                     final role = roles[index];
                     return Card(
                       elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                       child: Padding(
                         padding: const EdgeInsets.all(16.0),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 Text(role.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
                                 PopupMenuButton(
                                   itemBuilder: (context) => [
                                     PopupMenuItem(
                                       value: 'edit',
                                       child: const Text('Edit'),
                                       onTap: () {
                                          // Delay to allow menu to close
                                          Future.delayed(Duration.zero, () {
                                            if (context.mounted) {
                                              showDialog(context: context, builder: (_) => RoleFormDialog(role: role));
                                            }
                                          });
                                       },
                                     ),
                                     PopupMenuItem(
                                       value: 'delete',
                                       child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                       onTap: () {
                                          ref.read(roleControllerProvider.notifier).deleteRole(role.id);
                                       },
                                     ),
                                   ],
                                   child: const Icon(Icons.more_vert, color: Colors.grey),
                                 )
                               ],
                             ),
                             const SizedBox(height: 8),
                             Text(role.code, style: TextStyle(fontFamily: 'monospace', color: Colors.grey[600], fontSize: 12)),
                             const SizedBox(height: 8),
                             Text(
                               role.description ?? 'No description',
                               overflow: TextOverflow.ellipsis,
                               maxLines: 2,
                               style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
                             ),
                             const Spacer(),
                             Divider(color: Colors.grey[200]),
                             Row(
                               children: [
                                 Icon(Icons.shield_outlined, size: 16, color: Colors.amber[700]),
                                 const SizedBox(width: 8),
                                 Text('${role.rights.length} Permissions', style: GoogleFonts.inter(fontSize: 12)),
                               ],
                             )
                           ],
                         ),
                       ),
                     );
                   },
                 );
               },
             )
           )
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.05),
               blurRadius: 10,
               offset: const Offset(0, 4),
             )
          ]
        ),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text(title, style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13)),
             const SizedBox(height: 8),
             Text(value, style: GoogleFonts.outfit(color: Colors.amber[700], fontSize: 32, fontWeight: FontWeight.normal)),
           ],
         ),
      ),
    );
  }
}
