import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_theme.dart';
import '../../../../logic/providers/event_provider.dart';
import '../../../../logic/providers/admin_bidding_provider.dart'; // Import Admin Bidding Provider
import '../../../../data/models/event_model.dart';
import '../../../../data/models/bidding/admin_bid_model.dart';

class EventRequestDetailScreen extends ConsumerStatefulWidget {
  final String requestId;
  const EventRequestDetailScreen({super.key, required this.requestId});

  @override
  ConsumerState<EventRequestDetailScreen> createState() => _EventRequestDetailScreenState();
}

class _EventRequestDetailScreenState extends ConsumerState<EventRequestDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final int eventId = int.tryParse(widget.requestId) ?? -1;
    final eventAsync = ref.watch(eventDetailProvider(eventId));
    final bidsAsync = ref.watch(requestBidsProvider(eventId));

    return Scaffold(
      body: eventAsync.when(
        data: (event) => _buildContent(context, event, bidsAsync),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading event: $e')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Event event, AsyncValue<List<AdminBidModel>> bidsAsync) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Column(
      children: [
        // Header / Breadcrumb
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
                children: [
                  InkWell(onTap: () => context.pop(), child: const Icon(Icons.arrow_back, size: 20)),
                  const SizedBox(width: 8),
                  Text('Event Requests', style: TextStyle(color: Colors.grey[600])),
                  const Text(' / ', style: TextStyle(color: Colors.grey)),
                  Text('#REQ-${event.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(color: AppTheme.primary50, borderRadius: BorderRadius.circular(8)),
                         child: const Icon(Icons.event, color: AppTheme.primary600),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          Text('Requested by: ${event.eventManager?.firstName ?? "Unknown"} • ${dateFormat.format(event.eventDate)}', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (event.status == 'Pending') ...[
                          OutlinedButton(onPressed: (){}, child: const Text('Reject')),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: (){}, 
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary500, foregroundColor: Colors.white),
                            child: const Text('Approve Request'),
                          ),
                      ]
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Status Bar / Progress
              Row(
                children: [
                  _buildStatusStep('Request Received', true),
                  _buildLine(true),
                  _buildStatusStep('Consultation', event.status != 'Pending'),
                  _buildLine(event.status != 'Pending'),
                  _buildStatusStep('Quotation', event.status == 'Planning' || event.status == 'Converted', isActive: event.status == 'Planning'),
                  _buildLine(event.status == 'Converted' || event.status == 'Completed'),
                  _buildStatusStep('Confirmed', event.status == 'Confirmed' || event.status == 'Completed'),
                ],
              ),
              const SizedBox(height: 24),

              // Tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppTheme.primary600,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppTheme.primary600,
                tabAlignment: TabAlignment.start,
                tabs: const [
                  Tab(text: 'Overview & Details'),
                  Tab(text: 'Customer Info'),
                  Tab(text: 'Quotations'),
                  Tab(text: 'Timeline & Tasks'),
                  Tab(text: 'Files & Contracts'),
                ],
              ),
            ],
          ),
        ),
        
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(event),
              const Center(child: Text('Customer Info Tab Content')),
              bidsAsync.when(
                  data: (bids) => _buildQuotationsTab(bids, event.id),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error loading bids: $e'))
              ),
              const Center(child: Text('Timeline Tab Content')),
              const Center(child: Text('Files Tab Content')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(Event event) {
      return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text("Event Details", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _buildRow("Event Type", "Wedding (ID: ${event.eventTypeId})"), // Map ID to string if needed
                  _buildRow("Budget", "₹${event.budget ?? 'N/A'}"),
                  _buildRow("Guests", "${event.expectedAttendees}"),
                  _buildRow("Location", "${event.venue ?? ''}, ${event.city ?? ''}, ${event.state ?? ''}"),
                  _buildRow("Description", event.description ?? 'No description'),
              ],
          ),
      );
  }
  
  Widget _buildQuotationsTab(List<AdminBidModel> bids, int eventId) {
      if (bids.isEmpty) return const Center(child: Text("No bids received yet."));
      
      return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: bids.length,
          separatorBuilder: (c, i) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
              final bid = bids[index];
              return Card(
                  child: ListTile(
                      title: Text(bid.vendorName ?? 'Vendor #${bid.vendorId}'),
                      subtitle: Text('Bid: ₹${bid.amount} - ${bid.status}'),
                      trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                              Text(bid.proposal, style: const TextStyle(color: Colors.grey)),
                              const SizedBox(width: 8),
                              if (bid.status == 'pending') ...[
                                    IconButton(
                                      icon: const Icon(Icons.check, color: Colors.green), 
                                      onPressed: () {
                                           ref.read(curationProvider.notifier).curate(bid.id, "approve");
                                      }
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red), 
                                      onPressed: () {
                                           // Reject logic
                                      }
                                    ),
                              ]
                          ],
                      ),
                      onTap: () {
                          // View Bid Details
                          context.push('/admin/bids/${bid.id}');
                      },
                  ),
              );
          },
      );
  }

  Widget _buildRow(String label, String value) {
      return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
              children: [
                  SizedBox(width: 150, child: Text(label, style: const TextStyle(color: Colors.grey))),
                  Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
              ],
          ),
      );
  }

  Widget _buildStatusStep(String label, bool isCompleted, {bool isActive = false}) {
     Color color = isCompleted ? Colors.green : (isActive ? AppTheme.primary500 : Colors.grey);
     return Row(
       children: [
         Icon(isCompleted ? Icons.check_circle : Icons.circle, color: color, size: 16),
         const SizedBox(width: 6),
         Text(label, style: TextStyle(color: color, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
       ],
     );
  }

  Widget _buildLine(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isActive ? Colors.green : Colors.grey[300],
    );
  }
}
