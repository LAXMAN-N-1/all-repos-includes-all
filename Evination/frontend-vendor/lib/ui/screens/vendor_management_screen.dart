import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/providers/vendor_provider.dart';
import '../../data/models/vendor_model.dart';

class VendorManagementScreen extends ConsumerWidget {
  const VendorManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorsAsync = ref.watch(vendorsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
           Text(
            'Vendor Management',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF5A623),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Approve and manage service providers',
            style: GoogleFonts.inter(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Filters
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search vendors...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
               DropdownButtonHideUnderline(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                  child: DropdownButton(hint: const Text("Status"), items: const [], onChanged: (val){}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // List
          Expanded(
            child: Card(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              child: vendorsAsync.when(
                data: (vendors) => ListView.separated(
                  itemCount: vendors.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final vendor = vendors[index];
                    return _VendorListItem(vendor: vendor);
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VendorListItem extends ConsumerWidget {
  final Vendor vendor;

  const _VendorListItem({required this.vendor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue[50],
            child: Text(
              vendor.companyName.substring(0, 1).toUpperCase(),
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.companyName,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                Text(
                  vendor.businessType ?? 'General Vendor',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
           Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(vendor.city ?? 'Unknown', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700])),
              ],
            ),
          ),
           Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: vendor.status == 'approved' ? Colors.green[50] : (vendor.status == 'pending' ? Colors.orange[50] : Colors.red[50]),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                vendor.status.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: vendor.status == 'approved' ? Colors.green : (vendor.status == 'pending' ? Colors.orange : Colors.red),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Actions
          if (vendor.status == 'pending')
            Row(
              children: [
                TextButton(
                  onPressed: () => ref.read(vendorsProvider.notifier).updateStatus(vendor.id, 'approved'),
                  child: const Text('Approve', style: TextStyle(color: Colors.green)),
                ),
                TextButton(
                  onPressed: () => ref.read(vendorsProvider.notifier).updateStatus(vendor.id, 'rejected'),
                  child: const Text('Reject', style: TextStyle(color: Colors.red)),
                ),
              ],
            )
          else
             IconButton(icon: const Icon(Icons.more_vert, color: Colors.grey), onPressed: (){}),
        ],
      ),
    );
  }
}
