import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:admin_panel/logic/providers/vendor_provider.dart';
import 'package:admin_panel/data/models/vendor/vendor_admin_model.dart';
import 'package:admin_panel/theme/app_theme.dart';
import 'package:admin_panel/ui/widgets/common_input.dart';
import 'package:admin_panel/ui/widgets/common_button.dart';

class VendorListScreen extends ConsumerStatefulWidget {
  final int initialTab;
  final int? categoryId;
  const VendorListScreen({super.key, this.initialTab = 0, this.categoryId});

  @override
  ConsumerState<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends ConsumerState<VendorListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchTerm = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: widget.initialTab);
    _tabController.addListener(_handleTabChange);
    
    // Load data based on initial tab
    String initialStatus;
    switch (widget.initialTab) {
      case 0: initialStatus = 'all'; break;
      case 1: initialStatus = 'pending'; break;
      case 2: initialStatus = 'active'; break;
      case 3: initialStatus = 'suspended'; break;
      default: initialStatus = 'all';
    }
    
    Future.microtask(() => ref.read(vendorProvider.notifier).loadVendors(initialStatus, categoryId: widget.categoryId)); 
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      String status;
      switch (_tabController.index) {
        case 0: status = 'all'; break; // Backend needs update for this, or we rely on 'all' returning something specific. Assuming 'pending' for now to be safe, or I will update backend to ignore status filter if 'all'.
        case 1: status = 'pending'; break;
        case 2: status = 'active'; break;
        case 3: status = 'suspended'; break;
        default: status = 'pending';
      }
      ref.read(vendorProvider.notifier).loadVendors(status, categoryId: widget.categoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendorState = ref.watch(vendorProvider);
    final vendors = vendorState.vendors;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vendor Directory', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Manage all your service providers', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/admin/vendors/add'), 
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Vendor'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary500, foregroundColor: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Tabs
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppTheme.primary600,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppTheme.primary600,
                  tabAlignment: TabAlignment.start,
                  tabs: const [
                    Tab(text: 'All Vendors'),
                    Tab(text: 'Pending Approvals'),
                    Tab(text: 'Active'),
                    Tab(text: 'Inactive/Suspended'),
                  ],
                  onTap: (index) {
                      // Handled by listener, or safe to call here too? 
                      // Listener covers swipes and taps usually.
                  },
                ),
              ],
            ),
          ),
          
           // Filters Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              color: Colors.grey.shade50,
            ),
            child: Row(
              children: [
                 Expanded(
                  child: CommonInput(
                    placeholder: 'Search by ID, Name or Email...',
                    prefixIcon: const Icon(Icons.search),
                    onChanged: (val) => setState(() => searchTerm = val),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.filter_list, size: 16), label: const Text('Filter')),
                const SizedBox(width: 8),
                OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.download, size: 16), label: const Text('Export')),
              ],
            ),
          ),
          
          if (widget.categoryId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              color: Colors.grey.shade50,
              child: Row(
                children: [
                  Chip(
                    label: Text('Category ID: ${widget.categoryId}', style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppTheme.primary50,
                    side: BorderSide(color: AppTheme.primary200),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () => context.push('/admin/vendors/list'),
                  ),
                  const SizedBox(width: 8),
                  Text('Showing filtered results', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
          
          // Content
          Expanded(
             child: vendorState.isLoading 
               ? const Center(child: CircularProgressIndicator())
               : _buildVendorTable(context, vendors, isPending: _tabController.index == 1),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorTable(BuildContext context, List<AdminVendorModel> vendors, {bool isPending = false}) {
    if (vendors.isEmpty) {
       return const Center(child: Text("No vendors found."));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
            columns: const [
              DataColumn(label: Text('Vendor')),
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Tier')),
              DataColumn(label: Text('Status')), 
              DataColumn(label: Text('Contact')),
              DataColumn(label: Text('Actions')),
            ],
            rows: vendors.map((v) {
              return DataRow(
                cells: [
                  DataCell(
                    InkWell(
                      onTap: () {
                         context.push('/admin/vendors/details/${v.id}');
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                             radius: 16,
                             backgroundColor: AppTheme.primary100,
                             child: Text((v.displayName.isNotEmpty ? v.displayName[0] : '?').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(v.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('ID: #V-${v.id}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(Text(v.vendorType ?? '-')), 
                  DataCell(Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                     decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(4)),
                     child: Text(v.tier ?? 'Bronze', style: TextStyle(fontSize: 11, color: Colors.amber[800])),
                  )),
                  DataCell(_StatusBadge(status: v.status)),
                  DataCell(Text(v.phone ?? v.email ?? '-')),
                  DataCell(
                    isPending 
                    ? CommonButton(
                        text: 'Review', 
                        onPressed: () => ref.read(vendorProvider.notifier).approveVendor(v.id),
                        size: ButtonSize.sm,
                      )
                    : IconButton(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onPressed: (){},
                      ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    
    switch (status.toLowerCase()) {
      case 'pending': case 'pending_approval': color = Colors.orange[700]!; bg = Colors.orange[50]!; break;
      case 'active': case 'approved': color = Colors.green[700]!; bg = Colors.green[50]!; break;
      case 'suspended': color = Colors.red[700]!; bg = Colors.red[50]!; break;
      default: color = Colors.grey[700]!; bg = Colors.grey[50]!; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(status.toUpperCase().replaceAll('_', ' '), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
