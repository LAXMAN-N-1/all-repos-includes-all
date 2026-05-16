import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vendor_app/data/models/bidding_event_model.dart';
import 'package:vendor_app/logic/providers/bid_provider.dart';
import '../../../theme/app_theme.dart';

class VendorEventDetailsScreen extends ConsumerStatefulWidget {
  final int eventId;
  const VendorEventDetailsScreen({super.key, required this.eventId});

  @override
  ConsumerState<VendorEventDetailsScreen> createState() => _VendorEventDetailsScreenState();
}

class _VendorEventDetailsScreenState extends ConsumerState<VendorEventDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final marketplaceAsync = ref.watch(marketplaceEventsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: marketplaceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (events) {
          final event = events.firstWhere((e) => e.id == widget.eventId, orElse: () => BiddingEvent(
              id: 0,
              eventName: 'Event Not Found',
              location: '',
              eventDate: DateTime.now(),
              timeLeft: '',
              services: [],
              categories: [],
              lowestBid: 0,
              highestBid: 0,
              eventType: '',
              status: '',
            )
          );

          if (event.id == 0) return const Center(child: Text('Event not found'));

          return _buildContent(context, event);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, BiddingEvent event) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Header Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.gray200),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        event.eventType.toLowerCase().contains('corporate') ? LucideIcons.briefcase : LucideIcons.gem,
                        color: AppTheme.darkGold,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Text(event.eventName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                               Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.timer, size: 14, color: AppTheme.error),
                                    const SizedBox(width: 4),
                                    Text(event.timeLeft, style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                               ),
                            ],
                          ),
                          const SizedBox(height: 8),
                           Row(
                            children: [
                              Icon(LucideIcons.mapPin, size: 16, color: AppTheme.gray600),
                              const SizedBox(width: 4),
                              Text(event.location, style: TextStyle(color: AppTheme.gray600)),
                              const SizedBox(width: 16),
                              Icon(LucideIcons.calendar, size: 16, color: AppTheme.gray600),
                              const SizedBox(width: 4),
                              Text(event.eventDate != null ? DateFormat('EEEE, MMM d, y').format(event.eventDate!) : 'Date TBD', style: TextStyle(color: AppTheme.gray600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                 const Text('About this Event', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 8),
                 Text('This is a prestigious event looking for high-quality vendors. Please review the services below and place your bids.', style: TextStyle(color: AppTheme.gray600)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Services Section
          const Text('Requested Services', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: event.services.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final service = event.services[index];
              final isBidPlaced = service.hasPlacedBid;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isBidPlaced ? AppTheme.success.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isBidPlaced ? AppTheme.success : AppTheme.gray200,
                    width: isBidPlaced ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(service.category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        if (isBidPlaced)
                           Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: AppTheme.success, borderRadius: BorderRadius.circular(20)),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle, size: 14, color: Colors.white),
                                SizedBox(width: 4),
                                Text('Bid Placed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          )
                        else
                           Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppTheme.gray100, borderRadius: BorderRadius.circular(4)),
                            child: const Text('Pending', style: TextStyle(color: AppTheme.gray600, fontSize: 11, fontWeight: FontWeight.bold)),
                          )
                      ],
                    ),
                    if (service.description != null) ...[
                      const SizedBox(height: 8),
                      Text(service.description!, style: TextStyle(color: AppTheme.gray600, fontSize: 14)),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: isBidPlaced ? Colors.white : AppTheme.gray100, borderRadius: BorderRadius.circular(4)),
                          child: Text('Budget: ₹${NumberFormat('#,##,0').format(service.lowestBid)} - ₹${NumberFormat('#,##,0').format(service.highestBid)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ),
                        const SizedBox(width: 12),
                         Text('${service.bidsCount} Bids', style: TextStyle(fontSize: 12, color: AppTheme.gray500)),
                         const Spacer(),
                         if (!isBidPlaced)
                           ElevatedButton(
                            onPressed: () {
                              context.push('/vendor/bidding/bid-service/${widget.eventId}', extra: service);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.emeraldGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              visualDensity: VisualDensity.compact,
                            ),
                            child: const Text('Bid Now'),
                           ),
                      ],
                    ),
                    if (isBidPlaced) ...[
                       const SizedBox(height: 12),
                       const Divider(),
                       const SizedBox(height: 8),
                       const Row(
                         children: [
                            Icon(LucideIcons.info, size: 14, color: AppTheme.gray500),
                            SizedBox(width: 6),
                            Text('You can modify your bid until the event closes.', style: TextStyle(fontSize: 11, color: AppTheme.gray500)),
                         ],
                       )
                    ]
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
