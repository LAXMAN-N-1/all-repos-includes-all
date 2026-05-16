import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eventifi_admin/features/vendors/presentation/vendor_controller.dart';
import 'package:eventifi_admin/features/vendors/presentation/widgets/vendor_form_dialog.dart';

class VendorsScreen extends ConsumerWidget {
  const VendorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorsAsync = ref.watch(vendorControllerProvider);

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
                    'Vendor Management',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                   Text(
                    'Manage vendor profiles and applications',
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                    ),
                  ),
                 ],
               ),
              ElevatedButton.icon(
                onPressed: () {
                    showDialog(context: context, builder: (_) => const VendorFormDialog());
                }, 
                icon: const Icon(Icons.add),
                label: const Text('Add Vendor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[600],
                  foregroundColor: Colors.white,
                ),
              )
            ],
          ),
          const SizedBox(height: 32),
           Expanded(
             child: vendorsAsync.when(
               loading: () => const Center(child: CircularProgressIndicator()),
               error: (err, stack) => Center(child: Text('Error: $err')),
               data: (vendors) {
                 if (vendors.isEmpty) {
                   return const Center(child: Text('No vendors found.'));
                 }
                 return ListView.separated(
                   separatorBuilder: (_, __) => const SizedBox(height: 16),
                   itemCount: vendors.length,
                   itemBuilder: (context, index) {
                     final vendor = vendors[index];
                     return Card(
                       elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                       child: ListTile(
                         contentPadding: const EdgeInsets.all(16),
                         leading: CircleAvatar(
                           backgroundColor: Colors.purple[100],
                           foregroundColor: Colors.purple[800],
                           child: Text(vendor.firstName[0]),
                         ),
                         title: Text('${vendor.firstName} ${vendor.lastName} (${vendor.companyName ?? 'Independent'})', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                         subtitle: Text(vendor.email),
                         trailing: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Chip(label: Text(vendor.status), backgroundColor: vendor.status == 'Active' ? Colors.green[50] : Colors.orange[50], labelStyle: TextStyle(color: vendor.status == 'Active' ? Colors.green[800] : Colors.orange[800])),
                             const SizedBox(width: 8),
                             IconButton(
                               icon: const Icon(Icons.edit, size: 20),
                               onPressed: () {
                                 showDialog(context: context, builder: (_) => VendorFormDialog(vendor: vendor));
                               },
                             ),
                             IconButton(
                               icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                               onPressed: () {
                                 ref.read(vendorControllerProvider.notifier).deleteVendor(vendor.id);
                               },
                             ),
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
