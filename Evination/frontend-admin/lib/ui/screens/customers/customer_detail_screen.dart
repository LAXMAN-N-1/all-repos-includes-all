import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_theme.dart';
import '../../../../logic/providers/customer_admin_provider.dart';
import '../../../../data/models/customer/customer_admin_model.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  final String customerId; // Keeping as String from route param, but provider needs int
  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  ConsumerState<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int id = int.tryParse(widget.customerId) ?? -1;
    final customerAsync = ref.watch(customerDetailProvider(id));

    return Scaffold(
      backgroundColor: Colors.white,
      body: customerAsync.when(
        data: (customer) => _buildContent(context, customer),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, CustomerDetailModel customer) {
    return Column(
        children: [
           // Breadcrumb & Back
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
             decoration: BoxDecoration(
               border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
             ),
             child: Row(
               children: [
                 InkWell(onTap: () => context.pop(), child: const Icon(Icons.arrow_back, size: 20)),
                 const SizedBox(width: 8),
                 Text('Customers', style: TextStyle(color: Colors.grey[600])),
                 const Text(' / ', style: TextStyle(color: Colors.grey)),
                 Text('#${customer.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
               ],
             ),
           ),

           // Header Profile Card
           Container(
             padding: const EdgeInsets.all(24),
             decoration: BoxDecoration(
               color: Colors.grey.shade50,
               border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
             ),
             child: Row(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 CircleAvatar(
                   radius: 40,
                   backgroundColor: AppTheme.primary100,
                   child: Text(customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 32, color: AppTheme.primary800)),
                 ),
                 const SizedBox(width: 24),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         children: [
                           Text(customer.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                           const SizedBox(width: 12),
                           Container(
                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                             decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)),
                             child: Text(customer.tier.toUpperCase(), style: TextStyle(color: Colors.blue[700], fontSize: 10, fontWeight: FontWeight.bold)),
                           ),
                           const SizedBox(width: 8),
                           Container(
                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                             decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(4)),
                             child: Row(
                               children: [
                                 Icon(Icons.circle, size: 8, color: Colors.green[700]),
                                 const SizedBox(width: 4),
                                 Text(customer.status.toUpperCase(), style: TextStyle(color: Colors.green[700], fontSize: 10, fontWeight: FontWeight.bold)),
                               ],
                             ),
                           ),
                         ],
                       ),
                       const SizedBox(height: 8),
                       Text('Member Since: ${customer.joinDate.toString().split(' ')[0]} • Last Active: ${customer.lastActive?.toString().split(' ')[0] ?? "Never"}', style: TextStyle(color: Colors.grey[600])),
                       const SizedBox(height: 16),
                       Row(
                         children: [
                            OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.edit, size: 16), label: const Text('Edit Profile')),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.message, size: 16), label: const Text('Message')),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: (){}, 
                              icon: const Icon(Icons.star, size: 16), 
                              label: const Text('Upgrade Tier'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary500, foregroundColor: Colors.white),
                            ),
                         ],
                       ),
                     ],
                   ),
                 ),
                 // LTV Stats
                 Container(
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                   child: Column(
                     children: [
                       Text('Lifetime Value', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                       const SizedBox(height: 4),
                       Text('₹${customer.totalSpent}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                     ],
                   ),
                 ),
               ],
             ),
           ),

           // Tabs
           Container(
             decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
             child: TabBar(
               controller: _tabController,
               isScrollable: true,
               labelColor: AppTheme.primary600,
               unselectedLabelColor: Colors.grey,
               indicatorColor: AppTheme.primary600,
               tabAlignment: TabAlignment.start,
               padding: const EdgeInsets.symmetric(horizontal: 24),
               tabs: const [
                 Tab(text: 'Overview'),
                 Tab(text: 'Booking History'),
                 Tab(text: 'Payment History'),
                 Tab(text: 'Support Tickets'),
                 Tab(text: 'Activity Log'),
               ],
             ),
           ),

           // Content
           Expanded(
             child: TabBarView(
               controller: _tabController,
               children: [
                 _buildOverviewTab(customer),
                 const Center(child: Text('Booking History Content')),
                 const Center(child: Text('Payment History Content')),
                 const Center(child: Text('Support Content')),
                 const Center(child: Text('Activity Content')),
               ],
             ),
           ),
        ],
    );
  }

  Widget _buildOverviewTab(CustomerDetailModel customer) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column (Info)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildSectionCard('Personal Information', 
                  Column(
                    children: [
                      _buildInfoRow('Email', customer.email, verified: true),
                      _buildInfoRow('Phone', customer.phone ?? 'N/A', verified: true),
                      _buildInfoRow('Location', customer.location ?? 'N/A'),
                      const Divider(height: 32),
                      _buildInfoRow('Gender', customer.gender ?? 'N/A'),
                      _buildInfoRow('Anniversary', customer.anniversary?.toString().split(' ')[0] ?? 'N/A'),
                    ],
                  )
                ),
                const SizedBox(height: 24),
                _buildSectionCard('Account Preferences',
                   Column(
                     children: [
                       _buildInfoRow('Language', 'English'), // Mock
                       _buildInfoRow('Communication', 'Email ✓  SMS ✓  WhatsApp ✓'),
                     ],
                   )
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right Column (Stats & Alerts)
          Expanded(
            flex: 1,
            child: Column(
              children: [
                 _buildSectionCard('Tier Status', 
                   Column(
                     children: [
                       const LinearProgressIndicator(value: 0.4, minHeight: 8, backgroundColor: Colors.grey),
                       const SizedBox(height: 8),
                       const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                         Text('Standard', style: TextStyle(fontSize: 12)),
                         Text('Premium', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                       ]),
                       const SizedBox(height: 16),
                       Text('Spend ₹2.22L more to upgrade', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                     ],
                   )
                 ),
                 const SizedBox(height: 24),
                 _buildSectionCard('Admin Notes',
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(customer.adminNotes != null ? "\"${customer.adminNotes}\"" : "No notes yet.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700])),
                       const SizedBox(height: 8),
                       const Text('- System', style: TextStyle(fontSize: 11, color: Colors.grey)),
                       const SizedBox(height: 12),
                       OutlinedButton(onPressed: (){}, child: const Text('Add Note', style: TextStyle(fontSize: 12))),
                     ],
                   )
                 ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool verified = false}) {
     return Padding(
       padding: const EdgeInsets.only(bottom: 12.0),
       child: Row(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           SizedBox(width: 120, child: Text(label, style: TextStyle(color: Colors.grey[600]))),
           Expanded(
             child: Row(
               children: [
                 Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
                 if (verified) ...[
                   const SizedBox(width: 8),
                   const Icon(Icons.verified, size: 14, color: Colors.green),
                 ],
               ],
             ),
           ),
         ],
       ),
     );
  }
}
