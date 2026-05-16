import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_theme.dart';
import '../../widgets/common_input.dart';
import '../../../../logic/providers/customer_admin_provider.dart';
import '../../../../data/models/customer/customer_admin_model.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged(String value) {
      // Debounce logic could be added here
      if (value.isNotEmpty) {
          setState(() {
              _searchQuery = value;
          });
      } else {
          setState(() {
              _searchQuery = null;
          });
      }
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider with search query
    final customersAsync = ref.watch(customerListProvider(_searchQuery));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Stats
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer Directory', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Manage customer profiles and interactions', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {}, // Add Customer
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Add Customer'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary500, foregroundColor: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Stats Row (Mock for now, could be aggregated from list or separate API)
                Row(
                  children: [
                    _buildStatItem('Total Customers', '...', Colors.blue), // Placeholder
                    _buildStatItem('Active Users', '...', Colors.green),
                    _buildStatItem('New (This Month)', '...', Colors.purple),
                  ],
                ),
                const SizedBox(height: 24),

                // Filters
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CommonInput(
                        controller: _searchController,
                        placeholder: 'Search Name, Email, Phone...',
                        prefixIcon: const Icon(Icons.search),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildDropdown('Tier: All'),
                    const SizedBox(width: 16),
                    _buildDropdown('Status: All'),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.download, size: 16), label: const Text('Export')),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Tabs
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppTheme.primary600,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppTheme.primary600,
                  tabAlignment: TabAlignment.start,
                  tabs: const [
                    Tab(text: 'All Customers'),
                    Tab(text: 'Standard'),
                    Tab(text: 'Premium 💎'),
                    Tab(text: 'VIP 👑'),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: customersAsync.when(
              data: (customers) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCustomerTable(customers), // All
                      _buildCustomerTable(customers.where((c) => c.tier == 'Standard').toList()),
                      _buildCustomerTable(customers.where((c) => c.tier == 'Premium').toList()),
                      _buildCustomerTable(customers.where((c) => c.tier == 'VIP').toList()),
                    ],
                  );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.people, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildCustomerTable(List<CustomerStatModel> customers) {
    if (customers.isEmpty) return const Center(child: Text("No customers found."));
    
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      child: Card(
         elevation: 0,
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
         child: DataTable(
           headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
           dataRowMaxHeight: 80,
           columns: const [
             DataColumn(label: Text('Customer')),
             DataColumn(label: Text('Tier')),
             DataColumn(label: Text('Bookings')),
             DataColumn(label: Text('Total The Spent')), 
             DataColumn(label: Text('Join Date')),
             DataColumn(label: Text('Actions')),
           ],
           rows: customers.map((c) {
             return DataRow(
               cells: [
                 DataCell(
                   InkWell(
                     onTap: () => context.push('/admin/customers/${c.id}'),
                     child: Padding(
                       padding: const EdgeInsets.symmetric(vertical: 8.0),
                       child: Row(
                         children: [
                           CircleAvatar(
                             backgroundColor: AppTheme.primary100,
                             child: Text(c.name.isNotEmpty ? c.name[0].toUpperCase() : '?', style: const TextStyle(color: AppTheme.primary800, fontWeight: FontWeight.bold)),
                           ),
                           const SizedBox(width: 12),
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                               Text('${c.location ?? "Unknown"} • ${c.phone ?? "N/A"}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                             ],
                           ),
                         ],
                       ),
                     ),
                   ),
                 ),
                 DataCell(_TierBadge(tier: c.tier)),
                 DataCell(Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Text('${c.totalBookings} Total', style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text('${c.activeBookings} Active', style: TextStyle(color: Colors.green[700], fontSize: 11)),
                   ],
                 )),
                 DataCell(Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Text('₹${c.totalSpent}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Avg: ₹${c.avgSpent.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                   ],
                 )),
                 DataCell(Text(c.joinDate.toString().split(' ')[0], style: TextStyle(color: Colors.grey[600]))),
                 DataCell(Row(
                   children: [
                     IconButton(icon: const Icon(Icons.remove_red_eye, size: 18), onPressed: () => context.push('/admin/customers/${c.id}')),
                     IconButton(icon: const Icon(Icons.more_vert, size: 18), onPressed: (){}),
                   ],
                 )),
               ],
             );
           }).toList(),
         ),
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  final String tier;
  const _TierBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    IconData? icon;

    switch (tier) {
      case 'VIP': color = Colors.purple; bg = Colors.purple.shade50; icon = Icons.diamond; break;
      case 'Premium': color = Colors.amber.shade800; bg = Colors.amber.shade50; icon = Icons.star; break;
      default: color = Colors.blue; bg = Colors.blue.shade50; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: color), const SizedBox(width: 4)],
          Text(tier.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
