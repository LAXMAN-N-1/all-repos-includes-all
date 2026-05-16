import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/providers/vendor_provider.dart';
import '../../data/models/vendor/vendor_admin_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/providers/vendor_provider.dart';
import '../../data/models/vendor/vendor_admin_model.dart';

class VendorManagementScreen extends ConsumerStatefulWidget {
  const VendorManagementScreen({super.key});

  @override
  ConsumerState<VendorManagementScreen> createState() => _VendorManagementScreenState();
}

class _VendorManagementScreenState extends ConsumerState<VendorManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vendorProvider.notifier).loadVendors('pending');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      // Wait for animation to settle or load immediately? 
      // Loading immediately feels snappier but might jank animation.
      // Let's load.
      final status = _getStatusFromIndex(_tabController.index);
      ref.read(vendorProvider.notifier).loadVendors(status);
    }
  }

  String _getStatusFromIndex(int index) {
    switch (index) {
      case 0: return 'pending';
      case 1: return 'active';
      case 2: return 'inactive';
      default: return 'pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendorState = ref.watch(vendorProvider);
    final vendors = vendorState.vendors;

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

          // Tabs
          Container(
            width: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFF5A623),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFF5A623),
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Active'),
                Tab(text: 'Inactive'),
              ],
              onTap: (index) {
                 final status = _getStatusFromIndex(index);
                 ref.read(vendorProvider.notifier).loadVendors(status);
              },
            ),
          ),
          const SizedBox(height: 24),

          // Filters (Optional search)
          // ... (Can keep existing search bar if needed, omitting for brevity/focus on tabs) ...

          // List
          Expanded(
            child: Card(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              child: vendorState.isLoading 
                ? const Center(child: CircularProgressIndicator())
                : vendorState.error != null
                  ? Center(child: Text('Error: ${vendorState.error}'))
                  : vendors.isEmpty 
                    ? const Center(child: Text("No vendors found with this status."))
                    : ListView.separated(
                      itemCount: vendors.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final vendor = vendors[index];
                        return _VendorListItem(vendor: vendor);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VendorListItem extends ConsumerWidget {
  final AdminVendorModel vendor;

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
              (vendor.companyName ?? "?").substring(0, 1).toUpperCase(),
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
                  vendor.companyName ?? "Unknown",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                Text(
                  vendor.vendorType ?? 'General Vendor',
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
                color: vendor.status == 'approved' || vendor.status == 'active' ? Colors.green[50] : (vendor.status == 'pending' ? Colors.orange[50] : Colors.red[50]),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                (vendor.status ?? 'Unknown').toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: vendor.status == 'approved' || vendor.status == 'active' ? Colors.green : (vendor.status == 'pending' ? Colors.orange : Colors.red),
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
                  onPressed: () => ref.read(vendorProvider.notifier).approveVendor(vendor.id),
                  child: const Text('Approve', style: TextStyle(color: Colors.green)),
                ),
                TextButton(
                  onPressed: () => {}, // Not implemented
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
