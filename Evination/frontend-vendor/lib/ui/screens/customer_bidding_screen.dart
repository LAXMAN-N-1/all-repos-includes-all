import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../logic/providers/bid_provider.dart';
import '../../data/models/customer_view_model.dart';
import '../../data/models/bid_model.dart';
import '../../theme/app_theme.dart';

class CustomerBiddingScreen extends ConsumerStatefulWidget {
  final int eventId;
  const CustomerBiddingScreen({super.key, required this.eventId});

  @override
  ConsumerState<CustomerBiddingScreen> createState() => _CustomerBiddingScreenState();
}

class _CustomerBiddingScreenState extends ConsumerState<CustomerBiddingScreen> {
  @override
  Widget build(BuildContext context) {
    final customerViewAsync = ref.watch(customerViewProvider(widget.eventId));

    return Scaffold(
      body: customerViewAsync.when(
        data: (data) => _buildContent(context, data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Error loading customer view: $err'),
             const SizedBox(height: 16),
            TextButton(onPressed: () => context.go('/admin/bidding'), child: const Text('Back to Dashboard'))
          ],
        )),
      ),
    );
  }

  Widget _buildContent(BuildContext context, CustomerViewResponse data) {
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
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.people, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 24),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer View', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Vendor bidding results for your event', style: TextStyle(color: Colors.white70, fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Event Info
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.eventName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _infoBadge(Icons.calendar_today, 'Event Date', data.eventDate != null ? DateFormat.yMMMd().format(data.eventDate!) : 'Date TBD'),
                    const SizedBox(width: 16),
                    _infoBadge(Icons.location_on, 'Venue', data.eventVenue ?? 'N/A'),
                    const SizedBox(width: 16),
                    _infoBadge(Icons.people, 'Guests', '${data.eventGuests ?? 0}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Assigned Vendor Section
          if (data.assignedBid != null) ...[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.green[50]!, Colors.green[100]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
                border: Border.all(color: Colors.green[300]!, width: 2),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                       gradient: const LinearGradient(colors: [Color(0xFF16A34A), Color(0xFF22C55E)]),
                       borderRadius: const BorderRadius.vertical(top: Radius.circular(14)), // match border rad minus width roughly
                    ),
                    child: Row(
                      children: [
                        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.star, color: Colors.white, size: 28)),
                        const SizedBox(width: 16),
                        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Selected Vendor', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), Text('Your assigned vendor for this event', style: TextStyle(color: Colors.white70))]),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(12)), child: Icon(Icons.check_circle, color: Colors.green[700], size: 32)),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data.assignedBid!.vendorName ?? 'Unknown Vendor', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Row(children: [
                                      const Icon(Icons.star, size: 20, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text('${data.assignedBid!.vendorRating ?? 4.5}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      Text('• ${data.assignedBid!.completedEvents ?? 0} projects', style: TextStyle(color: Colors.grey[500])),
                                    ]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Stats
                          Row(
                            children: [
                              _simpleStatBox('Experience', data.assignedBid!.vendorExperience ?? 'N/A'),
                              const SizedBox(width: 16),
                              _simpleStatBox('Team Size', '${data.assignedBid!.vendorTeamSize ?? "N/A"} members'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Contact
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Contact Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 12),
                              _contactRow(Icons.phone, data.assignedBid!.vendorPhone ?? 'N/A', Colors.blue),
                              const SizedBox(height: 8),
                              _contactRow(Icons.email, data.assignedBid!.vendorEmail ?? 'N/A', Colors.green),
                              const SizedBox(height: 8),
                              _contactRow(Icons.location_on, data.assignedBid!.vendorLocation ?? 'N/A', Colors.amber),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Bid Summary Box
                          Container(
                             padding: const EdgeInsets.all(24),
                             decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFDB913), Color(0xFFE5A711)]), borderRadius: BorderRadius.circular(16)),
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                   const Text('Winning Bid Amount', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                   const SizedBox(height: 4),
                                   Text(currencyFmt.format(data.assignedBid!.amount), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                                 ]),
                                 Container(
                                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                   decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                                   child: Row(children: [const Icon(Icons.access_time, color: Colors.white, size: 16), const SizedBox(width: 8), Text('Timeline: ${data.assignedBid!.timelineDays ?? "N/A"} days', style: const TextStyle(color: Colors.white))]),
                                 ),
                               ],
                             ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.green[50], border: Border.all(color: Colors.green[200]!), borderRadius: BorderRadius.circular(12)),
                            child: Row(children: [Icon(Icons.check_circle, color: Colors.green[600]), const SizedBox(width: 8), Text('This vendor has been confirmed for your event', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w500))]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Top vendors list
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFEF9E7), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.trending_up, color: Color(0xFFFDB913))),
                  const SizedBox(width: 16),
                  const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Top 3 Vendor Bids', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), Text('Best vendors who submitted proposals', style: TextStyle(color: Colors.grey))]),
                ]),
                const SizedBox(height: 24),
                
                // Grid of cards
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: data.topBids.length,
                  itemBuilder: (context, index) {
                    final bid = data.topBids[index];
                    final isAssigned = data.assignedBid?.id == bid.id;
                    return _VendorRankCard(bid: bid, rank: index + 1, isAssigned: isAssigned);
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          // Info Box
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.blue[50], border: Border.all(color: Colors.blue[100]!), borderRadius: BorderRadius.circular(16)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
               Icon(Icons.info, color: Colors.blue[700]), 
               const SizedBox(width: 16), 
               Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                 Text('About This View', style: TextStyle(color: Colors.blue[900], fontSize: 18, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 8),
                 Text('This is the customer view showing the top vendors who submitted bids for your event. The selected vendor has been highlighted and confirmed. You can contact them directly using the contact information provided above.', style: TextStyle(color: Colors.blue[800], height: 1.5)),
               ]))
            ]),
          ),
        ],
      ),
    );
  }

  Widget _infoBadge(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey[50], border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFDB913), size: 20),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)), Text(value, style: const TextStyle(fontWeight: FontWeight.w500))]),
          ],
        ),
      ),
    );
  }

  Widget _simpleStatBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey[50], border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)), const SizedBox(height: 4), Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))]),
      ),
    );
  }

  Widget _contactRow(IconData icon, String value, Color color) {
    return Row(children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: color)),
      const SizedBox(width: 12),
      Text(value, style: TextStyle(color: Colors.grey[800], fontSize: 15)),
    ]);
  }
}

class _VendorRankCard extends StatelessWidget {
  final Bid bid;
  final int rank;
  final bool isAssigned;

  const _VendorRankCard({required this.bid, required this.rank, required this.isAssigned});

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Container(
      decoration: BoxDecoration(
        color: isAssigned ? Colors.green[50] : Colors.white,
        border: Border.all(color: isAssigned ? Colors.green[300]! : Colors.grey[200]!, width: isAssigned ? 2 : 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isAssigned ? [const BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))] : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isAssigned)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.green[600],
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.star, color: Colors.white, size: 16), SizedBox(width: 8), Text('Selected Vendor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isAssigned ? Colors.green[200] : const Color(0xFFFEF9E7), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.emoji_events, color: isAssigned ? Colors.green[800] : const Color(0xFFFDB913))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(bid.vendorName ?? 'Vendor', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Row(children: [const Icon(Icons.star, size: 14, color: Colors.amber), const SizedBox(width: 4), Text('${bid.vendorRating ?? 4.5}', style: const TextStyle(fontSize: 13))]),
                        ])),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(color: isAssigned ? Colors.white : const Color(0xFFFEF9E7), border: Border.all(color: isAssigned ? Colors.transparent : const Color(0xFFFDB913).withOpacity(0.2)), borderRadius: BorderRadius.circular(12)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Bid Amount', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(currencyFmt.format(bid.amount), style: TextStyle(color: isAssigned ? Colors.green[700] : const Color(0xFFFDB913), fontSize: 20, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Timeline', style: TextStyle(fontSize: 10, color: Colors.grey)), Text('${bid.timelineDays ?? 30} days', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]))),
                        const SizedBox(width: 12),
                        Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Experience', style: TextStyle(fontSize: 10, color: Colors.grey)), Text(bid.vendorExperience ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: isAssigned ? 48 : 16, // Adjust for top bar
            right: 16,
            child: Container(
              width: 32, height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: rank == 1 ? [Colors.amber, Colors.orange] : (rank == 2 ? [Colors.grey[300]!, Colors.grey[500]!] : [Colors.orange[300]!, Colors.deepOrange])),
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Text('$rank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
