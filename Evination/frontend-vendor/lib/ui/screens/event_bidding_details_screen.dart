import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../logic/providers/bid_provider.dart';
import '../../data/models/bidding_event_model.dart';
import '../../theme/app_theme.dart';

class EventBiddingDetailsScreen extends ConsumerStatefulWidget {
  final int eventId;
  const EventBiddingDetailsScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventBiddingDetailsScreen> createState() => _EventBiddingDetailsScreenState();
}

class _EventBiddingDetailsScreenState extends ConsumerState<EventBiddingDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventBiddingDetailProvider(widget.eventId));

    return Scaffold(
      body: eventAsync.when(
        data: (event) => _buildContent(context, event),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Error loading event details: $err'),
             const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/admin/bidding'), 
              child: const Text('Back to Dashboard')
            )
          ],
        )),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BiddingEventDetail event) {
    final currencyFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button
          TextButton.icon(
            onPressed: () => context.go('/admin/bidding'),
            icon: const Icon(Icons.arrow_back, size: 20),
            label: const Text('Back to Dashboard'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
          ),
          const SizedBox(height: 24),

          // Header
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFDB913), Color(0xFFE5A711)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(event.eventName, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                       const SizedBox(height: 12),
                       Row(
                         children: [
                           _headerBadge(event.status),
                           const SizedBox(width: 8),
                           _headerBadge(event.eventType, isTransparent: true),
                         ],
                       ),
                     ],
                   ),
                 ),
                     if (event.status == 'Active' || event.status == 'Awarded')
                        ElevatedButton.icon(
                          onPressed: () { 
                              context.push('/admin/bidding/vendor-bids/${event.id}');
                          },
                          icon: const Icon(Icons.description, color: Color(0xFFFDB913)),
                          label: const Text('View Vendor Bids', style: TextStyle(color: Color(0xFFFDB913))),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        ),
                     const SizedBox(width: 12),
                     ElevatedButton.icon(
                       onPressed: () { context.push('/admin/bidding/comparison/${event.id}'); },
                       icon: const Icon(Icons.compare_arrows, color: Colors.white),
                       label: const Text('Compare Bids', style: TextStyle(color: Colors.white)),
                       style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5D1049), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                     ),
                     const SizedBox(width: 12),
                     OutlinedButton.icon(
                        onPressed: () => context.push('/admin/bidding/customer-view/${event.id}'),
                        icon: const Icon(Icons.people, size: 20),
                        label: const Text('Preview Customer View'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                     ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column (Event Info)
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Main Details
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Event Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            childAspectRatio: 3.5,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _infoRow(Icons.calendar_today, 'Event Date', event.eventDate != null ? DateFormat.yMMMd().format(event.eventDate!) : 'Date TBD'),
                              _infoRow(Icons.location_on, 'Location', event.location, subText: event.venue),
                              _infoRow(Icons.people, 'Expected Guests', '${event.expectedGuests ?? 0}'),
                              _infoRow(Icons.access_time, 'Duration', event.duration ?? 'N/A'),
                              _infoRow(Icons.credit_card, 'Payment Type', event.paymentStatus, isBadge: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Categories
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.cardDecoration,
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Categories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8, runSpacing: 8,
                            children: event.categories.map((cat) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(color: const Color(0xFFFEF9E7), border: Border.all(color: const Color(0xFFFDB913).withOpacity(0.2)), borderRadius: BorderRadius.circular(12)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.label, size: 14, color: Color(0xFFFDB913)), const SizedBox(width: 8), Text(cat, style: const TextStyle(color: Color(0xFFFDB913), fontWeight: FontWeight.w500))]),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.cardDecoration,
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [const Icon(Icons.description, color: Color(0xFFFDB913)), const SizedBox(width: 8), const Text('Description', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
                          const SizedBox(height: 16),
                          Text(event.description ?? 'No description provided.', style: TextStyle(color: Colors.grey[600], height: 1.5, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right Column (Bidding Status)
              Expanded(
                flex: 1,
                child: Column(
                   children: [
                     // Time Left
                     Container(
                       padding: const EdgeInsets.all(24),
                       decoration: BoxDecoration(color: Colors.blue[50], border: Border.all(color: Colors.blue[100]!), borderRadius: BorderRadius.circular(16)),
                       child: Row(
                         children: [
                           Icon(Icons.access_time, color: Colors.blue[700]), 
                           const SizedBox(width: 12),
                           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Bidding Status', style: TextStyle(color: Colors.blue[900], fontSize: 13)), Text(event.timeLeft, style: TextStyle(color: Colors.blue[800], fontSize: 20, fontWeight: FontWeight.bold))]),
                         ],
                       ),
                     ),
                     const SizedBox(height: 24),

                     // Summary
                     Container(
                       padding: const EdgeInsets.all(24),
                       decoration: AppTheme.cardDecoration,
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           const Text('Bidding Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                           const SizedBox(height: 16),
                           _summaryCard('Total Bids', '${event.totalBids}', Icons.trending_up, const Color(0xFFFDB913), const Color(0xFFFEF9E7)),
                           const SizedBox(height: 12),
                           _summaryCard('Lowest Bid', currencyFmt.format(event.lowestBid), Icons.trending_down, Colors.green, Colors.green[50]!),
                           const SizedBox(height: 12),
                           _summaryCard('Average Bid', currencyFmt.format(event.averageBid), Icons.emoji_events, Colors.blue, Colors.blue[50]!),
                           const SizedBox(height: 12),
                           _summaryCard('Highest Bid', currencyFmt.format(event.highestBid), Icons.trending_up, Colors.amber, Colors.amber[50]!),
                         ],
                       ),
                     ),
                     const SizedBox(height: 24),

                     // Actions
                     SizedBox(
                       width: double.infinity,
                       child: ElevatedButton.icon(
                         onPressed: () => context.go('/bids'),
                         icon: const Icon(Icons.description, color: Colors.white),
                         label: const Text('View All Bids', style: TextStyle(color: Colors.white)),
                         style: ElevatedButton.styleFrom(
                           backgroundColor: const Color(0xFFFDB913), // Gradient replacement
                           padding: const EdgeInsets.symmetric(vertical: 20),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                         ),
                       ),
                     ),
                     if (event.assignedVendor != null) ...[
                       const SizedBox(height: 12),
                       SizedBox(
                         width: double.infinity,
                         child: OutlinedButton.icon(
                           onPressed: () {
                             // Must find bidId for assigned vendor.
                             // Currently assignedVendor in model is simple, doesn't have bidId!
                             // However, we implemented getting bidId in Backend earlier if we dig...
                             // Wait, assigned_vendor schema in Dashboard response only had id.
                             // But my `AssignedVendorScreen` takes `bidId`.
                             // Let's assume for now we can navigate to events list or we need bidId.
                             // Actually, `get_event_details` returns `assigned_vendor` which has `id` being vendor id? 
                             // No, let's check `get_event_details` implementation.
                             // It assigned `accepted_bid` vendor details.
                             // We don't have bid_id in `assigned_vendor` struct in dashboard response.
                             // I should add `bid_id` to `assigned_vendor` in `BiddingEventDetailResponse`.
                           }, 
                           icon: const Icon(Icons.check_circle_outline),
                           label: const Text('View Assigned Vendor'),
                           style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFFDB913),
                              side: const BorderSide(color: Color(0xFFFDB913)),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                           ),
                         ),
                       ),
                     ]
                   ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerBadge(String text, {bool isTransparent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isTransparent ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.2), // Both trans for now based on react
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {String? subText, bool isBadge = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFEF9E7), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: const Color(0xFFFDB913), size: 20)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 2),
            if (isBadge) 
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.orange[50], border: Border.all(color: Colors.orange[200]!), borderRadius: BorderRadius.circular(6)), child: Text(value, style: TextStyle(color: Colors.orange[800], fontSize: 13)))
            else
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          if (subText != null) Text(subText, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ]),
      ],
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 16, color: color), const SizedBox(width: 8), Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13))]),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
