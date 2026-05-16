import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../logic/providers/bid_provider.dart';
import '../../data/models/bid_model.dart';
import '../../data/models/bidding_event_model.dart';
import '../../theme/app_theme.dart';

class BidComparisonScreen extends ConsumerStatefulWidget {
  final int eventId;
  const BidComparisonScreen({super.key, required this.eventId});

  @override
  ConsumerState<BidComparisonScreen> createState() => _BidComparisonScreenState();
}

class _BidComparisonScreenState extends ConsumerState<BidComparisonScreen> {
  int? _selectedBidId;

  // Mock Timeline Data
  final List<Map<String, dynamic>> _timeline = [
    {'date': 'Feb 1', 'event': 'Bidding Opened', 'status': 'completed'},
    {'date': 'Feb 15', 'event': 'Bids Received', 'status': 'completed'},
    {'date': 'Feb 20', 'event': 'Review in Progress', 'status': 'active'},
    {'date': 'Feb 25', 'event': 'Winner Selection', 'status': 'pending'},
    {'date': 'Mar 1', 'event': 'Contract Signing', 'status': 'pending'},
  ];

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventBiddingDetailProvider(widget.eventId));
    final bidsAsync = ref.watch(eventBidsProvider(widget.eventId));

    return Scaffold(
      body: eventAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading event: $err')),
        data: (event) {
          return bidsAsync.when(
             loading: () => const Center(child: CircularProgressIndicator()),
             error: (err, stack) => Center(child: Text('Error loading bids: $err')),
             data: (bids) => _buildContent(context, event, bids),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, BiddingEventDetail event, List<Bid> bids) {
    final currencyFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    // Stats Calculations - handle empty list
    final amounts = bids.map((b) => b.amount).toList();
    final lowest = amounts.isEmpty ? 0.0 : amounts.reduce((a, b) => a < b ? a : b);
    final highest = amounts.isEmpty ? 0.0 : amounts.reduce((a, b) => a > b ? a : b);
    final average = amounts.isEmpty ? 0.0 : amounts.reduce((a, b) => a + b) / amounts.length;
    final recommendedCount = bids.where((b) => b.isRecommended == true).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           // Back Button
          TextButton.icon(
            onPressed: () => context.go('/admin/bidding/events/${widget.eventId}'),
            icon: const Icon(Icons.arrow_back, size: 20),
            label: const Text('Back to Event Details'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
          ),
           const SizedBox(height: 24),

          // Header
          Container(
             padding: const EdgeInsets.all(24),
             decoration: AppTheme.cardDecoration,
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(event.eventName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 8),
                     Row(children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(DateFormat.yMMMd().format(event.eventDate), style: const TextStyle(color: Colors.grey)),
                        const SizedBox(width: 16),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)), child: Text(event.eventType, style: TextStyle(color: Colors.grey[800], fontSize: 12))),
                        const SizedBox(width: 16),
                        Text(event.timeLeft, style: const TextStyle(color: Colors.orange)),
                     ]),
                   ],
                 ),
                 Text('${bids.length} Bids', style: const TextStyle(fontSize: 20)),
               ],
             ),
          ),
          const SizedBox(height: 24),

          // Stats
          Row(
            children: [
               _statBox('Lowest Bid', currencyFmt.format(lowest), Colors.green),
               const SizedBox(width: 16),
               _statBox('Average Bid', currencyFmt.format(average), Colors.black),
               const SizedBox(width: 16),
               _statBox('Highest Bid', currencyFmt.format(highest), Colors.red),
               const SizedBox(width: 16),
               _statBox('Recommended', '$recommendedCount', Colors.black),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // Bids List
               Expanded(
                 flex: 2,
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     const Text('Submitted Bids', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 16),
                     ...bids.map((bid) => _buildBidCard(bid, currencyFmt)).toList(),
                   ],
                 ),
               ),
               const SizedBox(width: 24),

               // Timeline Sidebar
               Expanded(
                 flex: 1,
                 child: Container(
                   padding: const EdgeInsets.all(24),
                   decoration: AppTheme.cardDecoration,
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       const Text('Bid Timeline', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                       const SizedBox(height: 24),
                       ListView.builder(
                         shrinkWrap: true,
                         physics: const NeverScrollableScrollPhysics(),
                         itemCount: _timeline.length,
                         itemBuilder: (ctx, idx) => _buildTimelineItem(_timeline[idx], idx == _timeline.length - 1),
                       ),
                     ],
                   ),
                 ),
               ),
            ],
          )
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.cardDecoration,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
           Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
           const SizedBox(height: 4),
           Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  Widget _buildBidCard(Bid bid, NumberFormat fmt) {
    final isSelected = _selectedBidId == bid.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedBidId = bid.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(16),
           border: Border.all(color: isSelected ? const Color(0xFFFDB913) : Colors.grey[200]!, width: isSelected ? 2 : 1),
           boxShadow: isSelected ? [BoxShadow(color: const Color(0xFFFDB913).withOpacity(0.1), blurRadius: 8)] : AppTheme.cardDecoration.boxShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             if (bid.isRecommended == true)
               Padding(
                 padding: const EdgeInsets.only(bottom: 12),
                 child: Row(children: [const Icon(Icons.verified, size: 16, color: Color(0xFFFDB913)), const SizedBox(width: 4), const Text('Recommended Bid', style: TextStyle(color: Color(0xFFFDB913), fontSize: 12, fontWeight: FontWeight.bold))]),
               ),
             Row(
               crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                     Text(bid.vendorName ?? 'Unknown', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 8),
                     Row(children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        Text(' ${bid.vendorRating ?? 0} '),
                        Text('• ${bid.vendorCategory ?? "General"}', style: TextStyle(color: Colors.grey[600])),
                        Text(' • Submitted ${DateFormat.MMMd().format(bid.submittedAt ?? DateTime.now())}', style: TextStyle(color: Colors.grey[500])),
                     ]),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                     Text('Bid Amount', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                     Text(fmt.format(bid.amount), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                  ]),
               ],
             ),
             const SizedBox(height: 16),
             Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
               child: Row(
                 children: [
                    Expanded(child: Row(children: [const Icon(Icons.access_time, size: 16, color: Colors.grey), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Timeline', style: TextStyle(fontSize: 10, color: Colors.grey)), Text('${bid.timelineDays ?? "N/A"} days')])])),
                    Expanded(child: Row(children: [const Icon(Icons.calendar_today, size: 16, color: Colors.grey), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Proposed Date', style: TextStyle(fontSize: 10, color: Colors.grey)), Text(bid.proposedDate != null ? DateFormat.yMMMd().format(bid.proposedDate!) : 'N/A')])])),
                 ],
               ),
             ),
             const SizedBox(height: 16),
             const Text('Key Advantages:', style: TextStyle(color: Colors.grey)),
             const SizedBox(height: 8),
             Column(children: (bid.advantages ?? ['Standard Service']).take(3).map((adv) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [const Icon(Icons.check, size: 16, color: Colors.green), const SizedBox(width: 8), Text(adv)]))).toList()),
             const SizedBox(height: 16),
             const Divider(),
             const SizedBox(height: 16),
             Row(
               children: [
                 Expanded(child: ElevatedButton(onPressed: () { 
                    // Accept logic (navigate to assigned with bidId)
                    // We need bid id. 
                    if (bid.id != 0) context.push('/admin/bidding/assigned/${bid.id}');
                 }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFDB913), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Accept Bid'))),
                 const SizedBox(width: 12),
                 Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Request Changes'))),
                 const SizedBox(width: 12),
                 Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Reject'))),
               ],
             )
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> item, bool isLast) {
    final isCompleted = item['status'] == 'completed';
    final isActive = item['status'] == 'active';
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green[100] : (isActive ? Colors.amber[100] : Colors.grey[100]),
                  shape: BoxShape.circle,
                ),
                child: Center(
                   child: isCompleted ? const Icon(Icons.check, size: 16, color: Colors.green) : (isActive ? const Icon(Icons.access_time, size: 16, color: Colors.amber) : const SizedBox()),
                ),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: isCompleted ? Colors.green : Colors.grey[200], margin: const EdgeInsets.symmetric(vertical: 4))),
            ],
          ),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(item['date'], style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                 Text(item['event'], style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
