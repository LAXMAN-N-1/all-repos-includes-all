import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../logic/providers/bid_provider.dart';
import '../../data/models/bid_model.dart';
import '../../theme/app_theme.dart';
import 'admin_bid_details_dialog.dart';
import 'admin_bid_action_dialog.dart';

class AdminBiddingScreen extends ConsumerStatefulWidget {
  const AdminBiddingScreen({super.key});

  @override
  ConsumerState<AdminBiddingScreen> createState() => _AdminBiddingScreenState();
}

class _AdminBiddingScreenState extends ConsumerState<AdminBiddingScreen> {
  String _searchQuery = '';
  String _selectedEvent = 'all';
  String _selectedStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final bidsAsync = ref.watch(bidsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
           Text('Vendor Bidding Management', style: AppTheme.heading),
           const SizedBox(height: 8),
           Text('Review and manage vendor bids for events', style: AppTheme.subHeading),
          const SizedBox(height: 24),
          
          bidsAsync.when(
            data: (bids) {
              // Filtering Logic
              final filteredBids = bids.where((bid) {
                final matchesSearch = (bid.vendorName?.toLowerCase() ?? '').contains(_searchQuery.toLowerCase()) ||
                                      (bid.eventName?.toLowerCase() ?? '').contains(_searchQuery.toLowerCase());
                final matchesEvent = _selectedEvent == 'all' || bid.eventName == _selectedEvent;
                final matchesStatus = _selectedStatus == 'all' || bid.status == _selectedStatus;
                return matchesSearch && matchesEvent && matchesStatus;
              }).toList();

              final uniqueEvents = bids.map((e) => e.eventName).where((e) => e != null).toSet().toList();

              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats
                    _buildStatsRow(bids),
                    const SizedBox(height: 24),

                    // Filters
                    _buildFiltersRow(uniqueEvents),
                    const SizedBox(height: 24),

                    // List
                    Expanded(
                      child: ListView.separated(
                        itemCount: filteredBids.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) => _BidCard(bid: filteredBids[index]),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(List<Bid> bids) {
    return Row(
      children: [
        _StatCard(
           label: 'Total Bids', 
           value: bids.length.toString(), 
           icon: Icons.trending_up, 
           color: Colors.amber
        ),
        const SizedBox(width: 16),
        _StatCard(
           label: 'Pending Review', 
           value: bids.where((b) => b.status == 'pending').length.toString(), 
           icon: Icons.access_time, 
           color: Colors.orange // Yellow in React, Orange in Flutter is safer contrast
        ),
        const SizedBox(width: 16),
        _StatCard(
           label: 'Accepted', 
           value: bids.where((b) => b.status == 'accepted').length.toString(), 
           icon: Icons.check_circle, 
           color: Colors.green
        ),
        const SizedBox(width: 16),
        _StatCard(
           label: 'Rejected', 
           value: bids.where((b) => b.status == 'rejected').length.toString(), 
           icon: Icons.cancel, 
           color: Colors.red
        ),
      ],
    );
  }

  Widget _buildFiltersRow(List<String?> events) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search bids...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedEvent,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                prefixIcon: const Icon(Icons.filter_list),
              ),
              items: [
                const DropdownMenuItem(value: 'all', child: Text('All Events')),
                ...events.map((e) => DropdownMenuItem(value: e, child: Text(e!))),
              ],
              onChanged: (v) => setState(() => _selectedEvent = v!),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Status')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
              ],
              onChanged: (v) => setState(() => _selectedStatus = v!),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final MaterialColor color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.cardDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color[50], borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _BidCard extends StatelessWidget {
  final Bid bid;
  const _BidCard({required this.bid});

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.cardDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Vendor & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Row(
                           children: [
                             Text(bid.vendorName ?? 'Unknown', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                             const SizedBox(width: 12),
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                               decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(8)),
                               child: Row(
                                 children: [
                                   const Icon(Icons.star, size: 14, color: Colors.amber),
                                   const SizedBox(width: 4),
                                   Text(bid.vendorRating?.toString() ?? 'N/A', style: TextStyle(color: Colors.amber[900], fontSize: 12)),
                                 ],
                               ),
                             ),
                           ],
                         ),
                         const SizedBox(height: 4),
                         Text(bid.eventName ?? 'Unknown Event', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(currencyFmt.format(bid.amount), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber[700])),
                        const Text('Bid Amount', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Info Grid
                Row(
                  children: [
                    _infoItem(Icons.calendar_today, 'Event Date', bid.eventDate != null ? DateFormat.yMMMd().format(bid.eventDate!) : 'N/A'),
                    const SizedBox(width: 24),
                    _infoItem(Icons.access_time, 'Submitted', bid.submittedAt != null ? DateFormat.yMMMd().format(bid.submittedAt!) : 'N/A'),
                    const SizedBox(width: 24),
                    _infoItem(Icons.work_outline, 'Experience', '15 years'), // Mock or add field
                    const SizedBox(width: 24),
                    _infoItem(Icons.check_circle_outline, 'Completed', '250 events'), // Mock or add field
                  ],
                ),
                const SizedBox(height: 16),
                
                // Proposal Summary
                 const Text('Proposal Summary:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                 const SizedBox(height: 4),
                 Text(bid.proposal ?? 'No proposal details.', style: TextStyle(color: Colors.grey[600], fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                 
                 const SizedBox(height: 16),
                 if (bid.includes != null && bid.includes!.isNotEmpty) ...[
                    const Text('Includes:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: bid.includes!.map((item) => 
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check, size: 12, color: Colors.green[700]),
                              const SizedBox(width: 4),
                              Text(item.toString(), style: TextStyle(color: Colors.green[700], fontSize: 12)),
                            ],
                          ),
                        )
                      ).toList(),
                    ),
                 ],
              ],
            ),
          ),
          
          // Right Actions Column
          const SizedBox(width: 24),
          SizedBox(
            width: 180,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => showDialog(context: context, builder: (_) => AdminBidDetailsDialog(bid: bid)),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (bid.status == 'pending') ...[
                   SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => showDialog(context: context, builder: (_) => AdminBidActionDialog(bid: bid, actionType: 'accept')),
                      icon: const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
                      label: const Text('Accept Bid', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => showDialog(context: context, builder: (_) => AdminBidActionDialog(bid: bid, actionType: 'reject')),
                      icon: const Icon(Icons.cancel_outlined, size: 18, color: Colors.white),
                      label: const Text('Reject Bid', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ] else if (bid.status == 'accepted') ...[
                   Container(
                     padding: const EdgeInsets.symmetric(vertical: 12),
                     width: double.infinity,
                     decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green[100]!)),
                     child: Column(
                       children: [
                         Icon(Icons.check_circle, color: Colors.green[600]),
                         const SizedBox(height: 4),
                         Text('Bid Accepted', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
                       ],
                     ),
                   )
                ] else ...[
                   Container(
                     padding: const EdgeInsets.symmetric(vertical: 12),
                     width: double.infinity,
                     decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red[100]!)),
                     child: Column(
                       children: [
                         Icon(Icons.cancel, color: Colors.red[600]),
                         const SizedBox(height: 4),
                         Text('Bid Rejected', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
                       ],
                     ),
                   )
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.amber[600]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}
