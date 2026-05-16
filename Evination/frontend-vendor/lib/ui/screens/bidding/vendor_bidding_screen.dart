import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vendor_app/data/models/bid_model.dart';
import 'package:vendor_app/data/models/bidding_event_model.dart';
import 'package:vendor_app/logic/providers/bid_provider.dart';
import '../../../theme/app_theme.dart';

class VendorBiddingScreen extends ConsumerStatefulWidget {
  const VendorBiddingScreen({super.key});

  @override
  ConsumerState<VendorBiddingScreen> createState() => _VendorBiddingScreenState();
}

enum SortOption { dueDate, eventType, serviceCount, dateRaised }

class _VendorBiddingScreenState extends ConsumerState<VendorBiddingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SortOption _sortOption = SortOption.dateRaised; // Default sorting

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myBids = ref.watch(vendorBidsProvider);
    final marketplace = ref.watch(marketplaceEventsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bidding Center',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track your active bids and discover new event opportunities.',
                  style: TextStyle(color: AppTheme.gray600, fontSize: 16),
                ),
                const SizedBox(height: 24),
                
                // Tabs
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.gray100.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppTheme.emeraldGreen,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppTheme.gray600,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: const [
                       Tab(text: 'My Bids'),
                       Tab(text: 'Marketplace'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyBidsTab(context, myBids),
                _buildMarketplaceTab(context, marketplace),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyBidsTab(BuildContext context, AsyncValue<List<Bid>> bidsAsync) {
    return bidsAsync.when(
      data: (bids) => bids.isEmpty 
          ? _buildEmptyState('No bids submitted yet.')
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: bids.length,
              itemBuilder: (context, index) {
                final bid = bids[index];
                return _buildBidCard(
                  context,
                  bid.eventName ?? 'Unknown Event',
                  '₹${NumberFormat('#,##,###').format(bid.amount)}',
                  bid.status.toUpperCase(),
                  'Submitted on ${bid.submittedAt != null ? DateFormat('MMM d, y').format(bid.submittedAt!) : 'N/A'}',
                  LucideIcons.clock,
                  _getStatusColor(bid.status),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildMarketplaceTab(BuildContext context, AsyncValue<List<BiddingEvent>> eventsAsync) {
    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) return _buildEmptyState('No new opportunities found.');

        // Sorting Logic
        var sortedEvents = List<BiddingEvent>.from(events);
        switch (_sortOption) {
          case SortOption.dueDate:
             // Proxy: using eventDate (assuming earlier event date = sooner due)
             sortedEvents.sort((a, b) => (a.eventDate ?? DateTime.now()).compareTo(b.eventDate ?? DateTime.now()));
             break;
          case SortOption.eventType:
             sortedEvents.sort((a, b) => a.eventType.compareTo(b.eventType));
             break;
          case SortOption.serviceCount:
             sortedEvents.sort((a, b) => b.services.length.compareTo(a.services.length)); // Descending
             break;
          case SortOption.dateRaised:
             // Proxy: using ID as proxy for creation time (descending)
             sortedEvents.sort((a, b) => b.id.compareTo(a.id));
             break;
        }

        return Column(
          children: [
            // Filter / Sort Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  const Text('Sort By:', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.gray600)),
                  const SizedBox(width: 12),
                  _buildSortChip('Date Raised', SortOption.dateRaised),
                  _buildSortChip('Due Date', SortOption.dueDate),
                  _buildSortChip('Event Type', SortOption.eventType),
                  _buildSortChip('No. of Services', SortOption.serviceCount),
                ],
              ),
            ),
            
            // Event List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: sortedEvents.length,
                itemBuilder: (context, index) {
                   return _buildMarketEventCard(context, sortedEvents[index]);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildSortChip(String label, SortOption option) {
    final isSelected = _sortOption == option;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          if (selected) {
            setState(() {
              _sortOption = option;
            });
          }
        },
        backgroundColor: Colors.white,
        selectedColor: AppTheme.mintWhisper,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.emeraldGreen : AppTheme.gray600,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        checkmarkColor: AppTheme.emeraldGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppTheme.emeraldGreen : AppTheme.gray300,
            width: 1,
          ),
        ),
      ),
    );
  }



  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.inbox, size: 64, color: AppTheme.gray300),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: AppTheme.gray500, fontSize: 16)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted': return AppTheme.success;
      case 'rejected': return AppTheme.error;
      case 'pending': return AppTheme.warning;
      default: return AppTheme.info;
    }
  }

  Widget _buildBidCard(
    BuildContext context,
    String title,
    String amount,
    String status,
    String date,
    IconData icon,
    Color statusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray200),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.gray50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.gavel, color: AppTheme.emeraldGreen, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(date, style: TextStyle(color: AppTheme.gray600, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketEventCard(
    BuildContext context,
    BiddingEvent event,
  ) {
    final totalServices = event.services.length;
    final bidsPlaced = event.services.where((s) => s.hasPlacedBid).length;
    final isFullyBid = totalServices > 0 && bidsPlaced == totalServices;


    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer / Event Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.royalAmethyst.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.user, color: AppTheme.royalAmethyst, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.eventName, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textPrimary)
                    ),
                    const SizedBox(height: 4),
                     Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.gray100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(event.eventType, style: const TextStyle(fontSize: 11, color: AppTheme.gray700, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Icon(LucideIcons.calendar, size: 12, color: AppTheme.gray500),
                          const SizedBox(width: 4),
                          Text(
                            event.eventDate != null ? DateFormat('MMM d, y').format(event.eventDate!) : 'Date TBD', 
                            style: TextStyle(color: AppTheme.gray600, fontSize: 12)
                          ),
                        ],
                     ),
                  ],
                ),
              ),
              // Time Left Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.timer, size: 14, color: AppTheme.error),
                    const SizedBox(width: 4),
                    Text(event.timeLeft, style: const TextStyle(color: AppTheme.error, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Service Count & Value
          Row(
            children: [
               Icon(LucideIcons.layers, size: 16, color: AppTheme.gray600),
               const SizedBox(width: 6),
               Text(
                 '$totalServices Services Requested',
                 style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.gray700, fontSize: 14),
               ),
               const Spacer(),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.end,
                 children: [
                   Text('Budget Range', style: TextStyle(color: AppTheme.gray500, fontSize: 10)),
                   Text('₹${NumberFormat('#,##,###').format(event.lowestBid)} - ₹${NumberFormat('#,##,###').format(event.highestBid)}', 
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen)),
                 ],
               ),
            ],
          ),

          const SizedBox(height: 16),
          
          // Progress Bar (if active)
          if (bidsPlaced > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: totalServices > 0 ? bidsPlaced / totalServices : 0,
                backgroundColor: AppTheme.gray200,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.emeraldGreen),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$bidsPlaced of $totalServices bids placed', 
              style: const TextStyle(fontSize: 11, color: AppTheme.gray600)
            ),
            const SizedBox(height: 16),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showGroupedServicesDialog(context, event),
              style: ElevatedButton.styleFrom(
                backgroundColor: isFullyBid ? AppTheme.gray700 : AppTheme.emeraldGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                isFullyBid ? 'Manage Your Bids' : 'View $totalServices Services & Bid',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGroupedServicesDialog(BuildContext context, BiddingEvent event) {
    context.push('/vendor/bidding/bid-event-details/${event.id}');
  }
}
