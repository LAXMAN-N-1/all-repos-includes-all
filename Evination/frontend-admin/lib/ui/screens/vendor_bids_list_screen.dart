import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../logic/providers/bid_provider.dart';
import '../../data/models/bid_model.dart';
import '../../data/models/bidding_event_model.dart';
import '../../theme/app_theme.dart';

class VendorBidsListScreen extends ConsumerStatefulWidget {
  final int eventId;
  const VendorBidsListScreen({super.key, required this.eventId});

  @override
  ConsumerState<VendorBidsListScreen> createState() => _VendorBidsListScreenState();
}

class _VendorBidsListScreenState extends ConsumerState<VendorBidsListScreen> {
  // Sorting
  String _sortColumn = 'amount';
  bool _sortAscending = true;
  
  // Filters
  final List<String> _selectedCategories = [];
  String _ratingFilter = 'all';
  String _priceRangeFilter = 'all';
  String _statusFilter = 'all';

  // Selection
  final List<int> _topVendorIds = [];
  Bid? _selectedBidForAssignment;

  @override
  Widget build(BuildContext context) {
    // We need both event details and bids list
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
      floatingActionButton: _topVendorIds.isNotEmpty 
          ? FloatingActionButton.extended(
              onPressed: () {
                // Confirm Top Vendors
                _showTopVendorsConfirmation(context, bidsAsync.asData!.value.where((b) => _topVendorIds.contains(b.id)).toList());
              },
              icon: const Icon(Icons.send),
              label: Text('Push ${_topVendorIds.length} to Customer'),
              backgroundColor: AppTheme.primaryGold,
            )
          : null,
    );
  }

  Widget _buildContent(BuildContext context, BiddingEventDetail event, List<Bid> allBids) {
    final currencyFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    
    // Filter and Sort Logic
    List<Bid> filteredBids = allBids.where((bid) {
      if (_statusFilter != 'all' && bid.status != _statusFilter) return false;
      if (_selectedCategories.isNotEmpty && !_selectedCategories.contains(bid.vendorCategory)) return false;
      if (_ratingFilter != 'all' && (bid.vendorRating ?? 0) < double.parse(_ratingFilter)) return false;
      if (_priceRangeFilter != 'all') {
         if (_priceRangeFilter == 'under2L' && bid.amount >= 200000) return false;
         if (_priceRangeFilter == '2L-5L' && (bid.amount < 200000 || bid.amount > 500000)) return false;
         if (_priceRangeFilter == 'above5L' && bid.amount <= 500000) return false;
      }
      return true;
    }).toList();

    filteredBids.sort((a, b) {
       int cmp = 0;
       switch (_sortColumn) {
         case 'amount': cmp = a.amount.compareTo(b.amount); break;
         case 'rating': cmp = (a.vendorRating ?? 0).compareTo(b.vendorRating ?? 0); break;
         case 'timeline': cmp = (a.timelineDays ?? 0).compareTo(b.timelineDays ?? 0); break;
         case 'status': cmp = a.status.compareTo(b.status); break;
       }
       return _sortAscending ? cmp : -cmp;
    });

    // Unique categories
    final categories = allBids.map((b) => b.vendorCategory ?? 'Other').toSet().toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           // Back Button
          TextButton.icon(
            onPressed: () => context.go('/admin/bidding/dashboard'),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Vendor Bids', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(event.eventName, style: const TextStyle(color: Colors.white70, fontSize: 18)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => context.push('/admin/bidding/events/${event.id}'),
                  icon: const Icon(Icons.visibility, color: Color(0xFFFDB913)),
                  label: const Text('View Event Details', style: TextStyle(color: Color(0xFFFDB913))),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => context.push('/admin/bidding/comparison/${event.id}'),
                  icon: const Icon(Icons.compare_arrows, color: Colors.white),
                  label: const Text('Compare Bids', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5D1049), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats Cards
          Row(
            children: [
              _statCard('Total Bids', '${filteredBids.length}', Icons.description, Colors.blue),
              const SizedBox(width: 16),
              _statCard('Lowest Bid', currencyFmt.format(event.lowestBid), Icons.trending_down, Colors.green),
              const SizedBox(width: 16),
              _statCard('Average Bid', currencyFmt.format(event.averageBid), Icons.emoji_events, Colors.orange), // Orange
            ],
          ),
          const SizedBox(height: 24),

          // Filters
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _filterCard('Categories', 
                  Wrap(spacing: 8, runSpacing: 8, children: categories.map((cat) => FilterChip(
                      selected: _selectedCategories.contains(cat),
                      label: Text(cat), 
                      onSelected: (sel) { setState(() { sel ? _selectedCategories.add(cat) : _selectedCategories.remove(cat); }); },
                      selectedColor: const Color(0xFFFEF9E7),
                      checkmarkColor: const Color(0xFFFDB913),
                      side: BorderSide(color: _selectedCategories.contains(cat) ? const Color(0xFFFDB913) : Colors.grey[300]!),
                  )).toList())
              ),
              const SizedBox(width: 16),
              _filterCard('Rating', 
                  DropdownButton<String>(
                    value: _ratingFilter,
                    isExpanded: true,
                    underline: Container(),
                    items: const [
                       DropdownMenuItem(value: 'all', child: Text('All Ratings')),
                       DropdownMenuItem(value: '4.5', child: Text('4.5+ Stars')),
                       DropdownMenuItem(value: '4.0', child: Text('4.0+ Stars')),
                       DropdownMenuItem(value: '3.5', child: Text('3.5+ Stars')),
                    ],
                    onChanged: (v) => setState(() => _ratingFilter = v!),
                  )
              ),
               const SizedBox(width: 16),
              _filterCard('Price Range', 
                  DropdownButton<String>(
                    value: _priceRangeFilter,
                    isExpanded: true,
                    underline: Container(),
                    items: const [
                       DropdownMenuItem(value: 'all', child: Text('All Prices')),
                       DropdownMenuItem(value: 'under2L', child: Text('Under ₹2L')),
                       DropdownMenuItem(value: '2L-5L', child: Text('₹2L - ₹5L')),
                       DropdownMenuItem(value: 'above5L', child: Text('Above ₹5L')),
                    ],
                    onChanged: (v) => setState(() => _priceRangeFilter = v!),
                  )
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Table
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(12)),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
              columns: [
                 DataColumn(label: const Text('Vendor Details')),
                 _sortableColumn('Bid Amount', 'amount'),
                 _sortableColumn('Timeline', 'timeline'),
                 _sortableColumn('Rating', 'rating'),
                 const DataColumn(label: Text('Documents')),
                 _sortableColumn('Status', 'status'),
                 const DataColumn(label: Text('Action')),
              ],
              rows: filteredBids.map((bid) {
                 final isTop = _topVendorIds.contains(bid.id);
                 return DataRow(
                   cells: [
                     DataCell(Padding(
                       padding: const EdgeInsets.symmetric(vertical: 8.0),
                       child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                         Text(bid.vendorName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                         Text('${bid.vendorLocation ?? ""} • ${bid.completedEvents ?? 0} projects', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                         const SizedBox(height: 4),
                         Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(4)), child: Text(bid.vendorCategory ?? 'General', style: const TextStyle(fontSize: 10, color: Colors.amber))),
                       ]),
                     )),
                     DataCell(Text(currencyFmt.format(bid.amount), style: const TextStyle(color: Color(0xFFFDB913), fontWeight: FontWeight.bold))),
                     DataCell(Row(children: [const Icon(Icons.access_time, size: 14, color: Colors.grey), const SizedBox(width: 4), Text('${bid.timelineDays ?? "N/A"} days')])),
                     DataCell(Row(children: [const Icon(Icons.star, size: 14, color: Colors.amber), const SizedBox(width: 4), Text('${bid.vendorRating ?? 0}')])),
                     DataCell(Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: (bid.vendorDocuments ?? []).take(2).map((d) => Text(d, style: const TextStyle(color: Colors.blue, fontSize: 11))).toList())),
                     DataCell(_statusBadge(bid.status)),
                     DataCell(
                       Row(
                         children: [
                           IconButton(icon: Icon(isTop ? Icons.do_not_disturb_on : Icons.add_circle_outline, color: isTop ? Colors.red : Colors.green), onPressed: () {
                             setState(() {
                               if (isTop) _topVendorIds.remove(bid.id);
                               else if (_topVendorIds.length < 5) _topVendorIds.add(bid.id);
                               else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Max 5 vendors allowed')));
                             });
                           }),
                           IconButton(icon: const Icon(Icons.assignment_turned_in_outlined, color: Colors.blue), onPressed: () {
                             setState(() => _selectedBidForAssignment = bid);
                           }),
                         ],
                       ),
                     ),
                   ]
                 );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
         padding: const EdgeInsets.all(24),
         decoration: AppTheme.cardDecoration,
         child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: Colors.grey[600])), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))]),
               Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
            ],
         ),
      ),
    );
  }

  Widget _filterCard(String title, Widget content) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration,
        height: 160, // Fixed height for alignment
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(child: SingleChildScrollView(child: content)),
          ],
        ),
      ),
    );
  }

  DataColumn _sortableColumn(String label, String key) {
    return DataColumn(
      label: Row(children: [Text(label), if (_sortColumn == key) Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 14)]),
      onSort: (idx, asc) { setState(() { _sortColumn = key; _sortAscending = asc; }); },
    );
  }

  Widget _statusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'accepted' || status == 'Reviewed') color = Colors.green; // Mapping backend status
    if (status == 'pending' || status == 'Pending') color = Colors.orange;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), border: Border.all(color: color.withOpacity(0.3)), borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  void _showTopVendorsConfirmation(BuildContext context, List<Bid> topBids) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Push Selected Bids to Customer'),
      content: SizedBox(
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: topBids.map((b) => ListTile(
            leading: const Icon(Icons.person),
            title: Text(b.vendorName ?? ''),
            subtitle: Text('₹${b.amount} - ${b.vendorRating} stars'),
            trailing: const Icon(Icons.check, color: Colors.green),
          )).toList(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {
          try {
            await ref.read(bidsProvider.notifier).pushBidsToCustomer(widget.eventId, _topVendorIds);
            if (mounted) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bids pushed to customer successfully!')));
              setState(() => _topVendorIds.clear());
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          }
        }, child: const Text('Push to Customer')),
      ],
    ));
  }
}
