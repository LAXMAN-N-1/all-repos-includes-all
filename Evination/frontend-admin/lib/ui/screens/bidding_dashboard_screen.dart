import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../logic/providers/bid_provider.dart';
import '../../data/models/bidding_event_model.dart';
import '../../theme/app_theme.dart';

class BiddingDashboardScreen extends ConsumerStatefulWidget {
  const BiddingDashboardScreen({super.key});

  @override
  ConsumerState<BiddingDashboardScreen> createState() => _BiddingDashboardScreenState();
}

class _BiddingDashboardScreenState extends ConsumerState<BiddingDashboardScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(dashboardEventsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFFFDB913), Color(0xFFE5A711)]).createShader(bounds),
            child: const Text('Bidding Dashboard', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Text('Monitor and manage vendor bidding for events', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),

          eventsAsync.when(
            data: (events) {
              // Stats
              // Calculate dynamic stats
              final activeBiddings = events.where((e) => e.status == 'Active').length;
              final totalBids = events.fold(0, (sum, e) => sum + e.totalBids);
              final allBids = events.expand((e) => [e.lowestBid, e.averageBid, e.highestBid]).toList();
              final avgBidValue = allBids.isEmpty ? 0.0 : allBids.reduce((a, b) => a + b) / allBids.length;
              final awarded = events.where((e) => e.status == 'Awarded').length;

              final currencyFmt = NumberFormat.compactSimpleCurrency(locale: 'en_IN');

              // Filter logic
              final filteredEvents = events.where((e) {
                final matchesSearch = e.eventName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    e.eventType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    e.location.toLowerCase().contains(_searchQuery.toLowerCase());
                final matchesStatus = _statusFilter == 'all' || e.status == _statusFilter;
                return matchesSearch && matchesStatus;
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Stats Row
                   Row(
                     children: [
                       _StatCard(label: 'Active Biddings', value: '$activeBiddings', sub: 'Events open for bids', icon: Icons.gavel, color: Colors.amber, isGradient: true),
                       const SizedBox(width: 16),
                       _StatCard(label: 'Total Bids', value: '$totalBids', sub: 'Across all events', icon: Icons.people, color: Colors.amber),
                       const SizedBox(width: 16),
                       _StatCard(label: 'Avg Bid Value', value: currencyFmt.format(avgBidValue), sub: 'Average across bids', icon: Icons.emoji_events, color: Colors.amber),
                       const SizedBox(width: 16),
                       _StatCard(label: 'Awarded', value: '$awarded', sub: 'Vendors assigned', icon: Icons.trending_up, color: Colors.green, iconBgColor: Colors.green[50]),
                     ],
                   ),
                   const SizedBox(height: 24),
                   
                   // Filters
                   Container(
                     padding: const EdgeInsets.all(24),
                     decoration: AppTheme.cardDecoration,
                     child: Row(
                       children: [
                         Expanded(
                           child: TextField(
                             onChanged: (v) => setState(() => _searchQuery = v),
                             decoration: InputDecoration(
                               hintText: 'Search events...',
                               prefixIcon: const Icon(Icons.search),
                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                             ),
                           ),
                         ),
                         const SizedBox(width: 16),
                         Expanded(
                           child: DropdownButtonFormField<String>(
                             value: _statusFilter,
                             decoration: InputDecoration(
                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                               prefixIcon: const Icon(Icons.filter_list),
                             ),
                             items: const [
                               DropdownMenuItem(value: 'all', child: Text('All Status')),
                               DropdownMenuItem(value: 'Active', child: Text('Active')),
                               DropdownMenuItem(value: 'Closed', child: Text('Closed')),
                               DropdownMenuItem(value: 'Awarded', child: Text('Awarded')),
                             ],
                             onChanged: (v) => setState(() => _statusFilter = v!),
                           ),
                         ),
                       ],
                     ),
                   ),
                   const SizedBox(height: 24),
                   
                   if (filteredEvents.isEmpty)
                     const Center(child: Padding(padding: EdgeInsets.all(48), child: Column(children: [Icon(Icons.gavel, size: 64, color: Colors.grey), SizedBox(height: 16), Text('No events found', style: TextStyle(fontSize: 18, color: Colors.grey))]))),

                   // Events Grid
                   if (filteredEvents.isNotEmpty)
                     GridView.builder(
                       shrinkWrap: true,
                       physics: const NeverScrollableScrollPhysics(),
                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                         crossAxisCount: 2,
                         childAspectRatio: 1.3, // Adjust based on your card content
                         mainAxisSpacing: 24,
                         crossAxisSpacing: 24,
                       ),
                       itemCount: filteredEvents.length,
                       itemBuilder: (context, index) => _EventCard(event: filteredEvents[index]),
                     ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final Color color;
  final bool isGradient;
  final Color? iconBgColor;

  const _StatCard({required this.label, required this.value, required this.sub, required this.icon, required this.color, this.isGradient = false, this.iconBgColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: isGradient 
            ? BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFDB913), Color(0xFFE5A711)]), borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.cardShadow)
            : AppTheme.cardDecoration,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                   crossAxisAlignment: CrossAxisAlignment.start, 
                   children: [
                     Text(label, style: TextStyle(color: isGradient ? Colors.white70 : Colors.grey[600], fontSize: 13)),
                     const SizedBox(height: 4),
                     Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isGradient ? Colors.white : Colors.black)),
                     const SizedBox(height: 4),
                     Text(sub, style: TextStyle(color: isGradient ? Colors.white60 : Colors.grey[500], fontSize: 11)),
                   ]
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isGradient ? Colors.white.withOpacity(0.2) : (iconBgColor ?? const Color(0xFFFEF9E7)),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Icon(icon, color: isGradient ? Colors.white : color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final BiddingEvent event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.compactSimpleCurrency(locale: 'en_IN');
    Color statusColor = Colors.grey;
    Color statusBg = Colors.grey[100]!;
    if (event.status == 'Active') { statusColor = Colors.green[700]!; statusBg = Colors.green[100]!; }
    else if (event.status == 'Awarded') { statusColor = const Color(0xFFFDB913); statusBg = const Color(0xFFFEF9E7); }

    return Container(
      decoration: AppTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.eventName, maxLines: 1, overflow: TextOverflow.ellipsis,
                           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: statusColor.withOpacity(0.2))), child: Text(event.status, style: TextStyle(color: statusColor, fontSize: 12))),
                          const SizedBox(width: 8),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber[100]!)), child: Text(event.eventType, style: TextStyle(color: Colors.amber[700], fontSize: 12))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _iconText(Icons.calendar_today, DateFormat.yMMMd().format(event.eventDate)),
                _iconText(Icons.location_on, event.location),
                _iconText(Icons.account_balance_wallet, event.paymentStatus, color: _paymentColor(event.paymentStatus)),
              ],
            ),
            const SizedBox(height: 12),
            
            // Cats
            Wrap(
              spacing: 8,
              children: event.categories.take(3).map((c) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFEF9E7), borderRadius: BorderRadius.circular(8)), child: Text(c, style: const TextStyle(fontSize: 11, color: Color(0xFFE5A711))))).toList(),
            ),
            const SizedBox(height: 12),
            
            // Time Left
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.access_time, size: 14, color: Colors.blue), const SizedBox(width: 8), Text(event.timeLeft, style: TextStyle(color: Colors.blue[800], fontSize: 12))])),
            const SizedBox(height: 12),
            
            // Stats Grid
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statCol('Total Bids', '${event.totalBids}', Colors.amber),
                  _statCol('Lowest', currencyFmt.format(event.lowestBid), Colors.green),
                  _statCol('Average', currencyFmt.format(event.averageBid), Colors.blue),
                  _statCol('Highest', currencyFmt.format(event.highestBid), Colors.amber),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Actions
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: (){ context.go('/admin/bidding/events/${event.id}'); }, 
                  icon: const Icon(Icons.visibility, size: 16), 
                  label: const Text('View Details'), 
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12))
                )),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton.icon(
                  onPressed: (){ context.go('/admin/bidding/vendor-bids/${event.id}'); }, 
                  icon: const Icon(Icons.description, size: 16, color: Colors.white), 
                  label: const Text('View Bids', style: TextStyle(color: Colors.white)), 
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFDB913), padding: const EdgeInsets.symmetric(vertical: 12))
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconText(IconData icon, String text, {Color? color}) {
    return Row(children: [
      Icon(icon, size: 14, color: color ?? Colors.grey),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(fontSize: 12, color: color ?? Colors.grey[600])),
    ]);
  }

  Widget _statCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Color _paymentColor(String status) {
    switch (status) {
      case 'Completed': return Colors.green;
      case 'Advance Paid': return Colors.blue;
      case 'Initial Payment': return Colors.amber;
      case 'Payment After Event': return Colors.amber;
      case 'Pending': return Colors.orange;
      default: return Colors.grey;
    }
  }
}
