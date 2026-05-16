import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../logic/providers/order_provider.dart';
import '../../data/models/order_model.dart';
import '../../theme/app_theme.dart';

class OrderDashboardScreen extends ConsumerStatefulWidget {
  const OrderDashboardScreen({super.key});

  @override
  ConsumerState<OrderDashboardScreen> createState() => _OrderDashboardScreenState();
}

class _OrderDashboardScreenState extends ConsumerState<OrderDashboardScreen> {
  Order? selectedOrder;

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);
    final stats = ref.watch(orderStatsProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppTheme.emeraldGreen, AppTheme.mintWhisper],
              ).createShader(bounds),
              child: const Text(
                'Order Management',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            Text('Track and manage your event fulfillment pipeline.', style: TextStyle(color: AppTheme.gray600)),
            const SizedBox(height: 24),
            
            // Stats Row
            Row(
              children: [
                _StatCard(title: 'Total Orders', value: '${stats['total']}', icon: Icons.inventory_2_outlined, color: AppTheme.emeraldGreen),
                const SizedBox(width: 16),
                _StatCard(title: 'Pending', value: '${stats['pending']}', icon: Icons.schedule, color: AppTheme.warning),
                const SizedBox(width: 16),
                _StatCard(title: 'Completed', value: '${stats['completed']}', icon: Icons.check_circle_outline, color: AppTheme.success),
                const SizedBox(width: 16),
                _StatCard(title: 'Total Value', value: '₹${(stats['totalValue']/1000).toStringAsFixed(0)}K', icon: Icons.account_balance_wallet_outlined, color: AppTheme.info),
              ],
            ),
            const SizedBox(height: 24),

            // Filter Bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                       prefixIcon: const Icon(Icons.search),
                       hintText: 'Search orders or events...',
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) => ref.read(orderSearchFilterProvider.notifier).update(val),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: ref.watch(orderStatusFilterProvider),
                      items: ['All Status', 'Pending', 'In Progress', 'Completed', 'Cancelled'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => ref.read(orderStatusFilterProvider.notifier).update(val!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Order List
            ordersAsync.when(
              data: (orders) => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                separatorBuilder: (c, i) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                   final order = orders[index];
                   return _OrderCard(
                     order: order, 
                     onViewDetails: () => setState(() => selectedOrder = order),
                   );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
      // Detail Modal (Custom implementation overlay)
      bottomSheet: selectedOrder != null ? _OrderDetailsModal(
        order: selectedOrder!, 
        onClose: () => setState(() => selectedOrder = null)
      ) : null,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.cardDecoration,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
           Row(children: [
             Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
             const SizedBox(width: 12),
             Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
               Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
               Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
             ])),
           ]),
        ]),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onViewDetails;
  
  const _OrderCard({required this.order, required this.onViewDetails});
  
  Color _getStatusColor(String status) {
     switch(status.toLowerCase()) {
       case 'pending': return Colors.orange;
       case 'in progress': return Colors.blue;
       case 'completed': return Colors.green;
       case 'cancelled': return Colors.red;
       case 'refunded': return Colors.amber;
       default: return Colors.grey;
     }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    
    return Container(
       padding: const EdgeInsets.all(24),
       decoration: AppTheme.cardDecoration,
       child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
             Expanded(
               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text('Order #${order.orderRef}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Row(children: [
                        Icon(Icons.circle, size: 8, color: statusColor),
                        const SizedBox(width: 6),
                        Text(order.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12))
                      ]),
                    )
                  ]),
                  const SizedBox(height: 8),
                  Text(order.eventName ?? 'Unknown Event', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Row(children: [
                     Icon(Icons.storefront, size: 16, color: Colors.grey[400]),
                     const SizedBox(width: 4),
                     Text(order.vendorName ?? 'Unknown Vendor', style: const TextStyle(fontSize: 13)),
                     const SizedBox(width: 16),
                     Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
                     const SizedBox(width: 4),
                     Text('Ordered: ${DateFormat('MMM dd, yyyy').format(order.createdAt)}', style: const TextStyle(fontSize: 13)),
                  ]),
               ]),
             ),
             Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('Order Amount', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text(currency.format(order.amount), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                 ElevatedButton.icon(
                   onPressed: onViewDetails,
                   icon: const Icon(Icons.remove_red_eye, size: 16, color: Colors.white),
                   label: const Text('View Details', style: TextStyle(color: Colors.white)),
                   style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emeraldGreen),
                )
             ]),
          ]),
          if (order.status.toLowerCase() != 'cancelled') ...[
             const SizedBox(height: 16),
             const Divider(),
             const SizedBox(height: 16),
             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                   const Text('Progress', style: TextStyle(color: Colors.grey)),
                   const SizedBox(width: 8),
                   Text('${order.progress ?? 0}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
                if (order.deliveryDate != null)
                Row(children: [
                   const Icon(Icons.event, size: 16, color: Colors.grey),
                   const SizedBox(width: 4),
                   Text('Due: ${DateFormat('MMM dd, yyyy').format(order.deliveryDate!)}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ]),
             ]),
             const SizedBox(height: 8),
             ClipRRect(
               borderRadius: BorderRadius.circular(4),
               child: LinearProgressIndicator(
                  value: (order.progress ?? 0) / 100, 
                  backgroundColor: AppTheme.gray100, 
                  valueColor: const AlwaysStoppedAnimation(AppTheme.emeraldGreen),
                  minHeight: 8,
               ),
             ),
          ]
       ]),
    );
  }
}

class _OrderDetailsModal extends StatelessWidget {
  final Order order;
  final VoidCallback onClose;

  const _OrderDetailsModal({required this.order, required this.onClose});

  @override
  Widget build(BuildContext context) {
    // Basic modal implementation for quick turn around. 
    // In production this might be a Dialog or dedicated Screen.
    return Container(
      color: Colors.black54, // Dim background
      alignment: Alignment.center,
      child: Container(
        width: 800,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                   ShaderMask(shaderCallback: (r) => const LinearGradient(colors: [AppTheme.emeraldGreen, AppTheme.mintWhisper]).createShader(r), child: const Text('Order Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
                   Text('Order #${order.orderRef}', style: const TextStyle(color: Colors.grey)),
                ]),
                IconButton(icon: const Icon(Icons.close), onPressed: onClose),
              ]),
            ),
            const Divider(height: 1),
            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _InfoSection(title: 'Event Information', icon: Icons.description_outlined, children: [
                       _InfoRow('Event Name', order.eventName ?? '-'),
                       _InfoRow('Location', order.eventLocation ?? '-'),
                       _InfoRow('Event Date', order.eventDate != null ? DateFormat('MMM dd, yyyy').format(order.eventDate!) : '-'),
                    ]),
                    const SizedBox(height: 24),
                    _InfoSection(title: 'Customer Information', icon: Icons.person_outline, children: [
                       _InfoRow('Name', order.customerName ?? '-'),
                       _InfoRow('Email', order.customerEmail ?? '-'),
                       _InfoRow('Phone', order.customerPhone ?? '-'),
                    ]),
                    const SizedBox(height: 24),
                    _InfoSection(title: 'Vendor Information', icon: Icons.store_outlined, children: [
                       _InfoRow('Vendor', order.vendorName ?? '-'),
                       _InfoRow('Email', order.vendorEmail ?? '-'),
                       _InfoRow('Contact', order.vendorContact ?? '-'),
                       _InfoRow('Description', order.serviceDescription ?? '-', fullWidth: true),
                    ]),
                 ],
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[200]!))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                   OutlinedButton(onPressed: onClose, child: const Text('Close')),
                   const SizedBox(width: 16),
                   ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emeraldGreen, foregroundColor: Colors.white), child: const Text('Download Invoice')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _InfoSection({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
         Row(children: [Icon(icon, color: AppTheme.emeraldGreen), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
         const SizedBox(height: 16),
         Wrap(runSpacing: 16, spacing: 24, children: children),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool fullWidth;
  const _InfoRow(this.label, this.value, {this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : 200,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
         Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
         const SizedBox(height: 4),
         Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
