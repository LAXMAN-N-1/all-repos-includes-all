import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:evination_customer_app/presentation/providers/booking_provider.dart';
import 'package:evination_customer_app/presentation/providers/bid_provider.dart';
import 'package:evination_customer_app/data/services/bid_service.dart';
import 'package:evination_customer_app/core/constants/app_colors.dart';
import 'package:evination_customer_app/logic/providers/booking_provider.dart';

class BidSelectionScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const BidSelectionScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BidSelectionScreen> createState() => _BidSelectionScreenState();
}

class _BidSelectionScreenState extends ConsumerState<BidSelectionScreen> with SingleTickerProviderStateMixin {
  final Map<String, Map<String, dynamic>> _selectedBids = {};
  final Map<String, bool> _acceptedBids = {};
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    // Navigate using the AsyncProvider from logic
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bordeauxGradient),
        child: bookingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.crimsonSilk)),
          error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.rubyRed))),
          data: (bookings) {
            // Find booking safely
            final booking = bookings.firstWhere(
              (b) => b.id.toString() == widget.bookingId.toString(),
              orElse: () => bookings.isNotEmpty ? bookings.first : throw Exception('Booking not found'),
            );

            final eventId = int.tryParse(booking.id.toString()) ?? 1;
            final bidsAsync = ref.watch(pushedBidsStreamProvider(eventId));
            final availableServices = booking.services.isEmpty ? ['Event Services'] : booking.services;

            return DefaultTabController(
              length: availableServices.length,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(LucideIcons.arrowLeft, color: AppColors.softBlush),
                    onPressed: () => context.pop(),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SELECT ARTISANS', style: GoogleFonts.cormorantGaramond(color: AppColors.softBlush, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      Text('${booking.category.toUpperCase()} • ${booking.services.length} SERVICES', style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ],
                  ),
                  bottom: TabBar(
                    isScrollable: true,
                    indicatorColor: AppColors.crimsonSilk,
                    indicatorWeight: 3,
                    labelColor: AppColors.crimsonSilk,
                    unselectedLabelColor: Colors.white24,
                    labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.0),
                    tabs: availableServices.map((service) => Tab(text: service.toUpperCase())).toList(),
                  ),
                ),
                body: bidsAsync.when(
                  data: (data) {
                    final List topBids = data['top_bids'] ?? [];
                    if (topBids.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.hourglass, color: Colors.white10, size: 64),
                            const SizedBox(height: 24),
                            Text('CURATING EXCELLENCE', style: GoogleFonts.cormorantGaramond(color: AppColors.softBlush, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                            const SizedBox(height: 12),
                            Text('Our curators are shortlisting the finest artisans for your event.', style: GoogleFonts.outfit(color: Colors.white24, fontSize: 14)),
                            const SizedBox(height: 32),
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.crimsonSilk.withValues(alpha: 0.3)),
                              ),
                              child: TextButton(
                                onPressed: () => ref.invalidate(pushedBidsStreamProvider(eventId)),
                                child: Text(' REFRESH ', style: GoogleFonts.outfit(color: AppColors.softBlush, fontWeight: FontWeight.bold)),
                              ),
                            )
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('RECOMMENDED ARTISANS', style: GoogleFonts.outfit(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5)),
                              TextButton.icon(
                                icon: const Icon(LucideIcons.columns, size: 14, color: AppColors.crimsonSilk),
                                label: Text('COMPARE ALL', style: GoogleFonts.outfit(color: AppColors.crimsonSilk, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.0)),
                                onPressed: () => _showComparisonTable(context, topBids.cast<Map<String, dynamic>>()),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: availableServices.map((service) {
                              return _buildServiceView(service, topBids.cast<Map<String, dynamic>>());
                            }).toList(),
                          ),
                        ),
                        _buildBottomBar(booking, availableServices.length),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.crimsonSilk)),
                  error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.rubyRed))),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildServiceView(String serviceName, List<Map<String, dynamic>> bids) {
    final selectedBid = _selectedBids[serviceName];
    final isAccepted = _acceptedBids[serviceName] ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ...bids.asMap().entries.map((entry) {
            final index = entry.key;
            final bid = entry.value;
            // Add rank if missing
            final bidWithRank = {...bid, 'rank': index + 1};
            return _buildBidCard(serviceName, bidWithRank);
          }).toList(),
          
          if (selectedBid != null && !isAccepted)
             Container(
               margin: const EdgeInsets.only(top: 24),
               padding: const EdgeInsets.all(24),
               decoration: BoxDecoration(
                 color: Colors.white.withValues(alpha: 0.03),
                 borderRadius: BorderRadius.circular(24),
                 border: Border.all(color: AppColors.crimsonSilk.withValues(alpha: 0.2)),
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     children: [
                       const Icon(LucideIcons.info, color: AppColors.crimsonSilk, size: 18),
                       const SizedBox(width: 12),
                       Text('ACCEPT SELECTION', style: GoogleFonts.outfit(color: AppColors.softBlush, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                     ],
                   ),
                   const SizedBox(height: 16),
                   Text(
                     "You've selected ${selectedBid['vendor_name']} for $serviceName.\nAccept this engagement to lock the terms and proceed.",
                     style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13, height: 1.5),
                   ),
                   const SizedBox(height: 24),
                   Container(
                     width: double.infinity,
                     height: 56,
                     decoration: BoxDecoration(
                       gradient: AppColors.luxuryGradient,
                       borderRadius: BorderRadius.circular(16),
                     ),
                     child: ElevatedButton(
                       onPressed: _isProcessing ? null : () async {
                         setState(() => _isProcessing = true);
                         try {
                           final bidId = selectedBid['id'] as int;
                           await ref.read(bidServiceProvider).acceptBid(bidId);
                           setState(() {
                             _acceptedBids[serviceName] = true;
                             _isProcessing = false;
                           });
                         } catch (e) {
                           setState(() => _isProcessing = false);
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                         }
                       },
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.transparent,
                         foregroundColor: Colors.white,
                         shadowColor: Colors.transparent,
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                       ),
                       child: _isProcessing 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('ACCEPT ENGAGEMENT', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 13)),
                     ),
                   )
                 ],
               ),
             ).animate().fadeIn(),

          if (isAccepted)
            Container(
               margin: const EdgeInsets.only(top: 24),
               padding: const EdgeInsets.all(24),
               decoration: BoxDecoration(
                 color: AppColors.emerald.withValues(alpha: 0.05),
                 borderRadius: BorderRadius.circular(24),
                 border: Border.all(color: AppColors.emerald.withValues(alpha: 0.2)),
               ),
               child: Column(
                 children: [
                    const Icon(LucideIcons.checkCircle, color: AppColors.emerald, size: 32),
                    const SizedBox(height: 16),
                    Text('SELECTION SECURED', style: GoogleFonts.cormorantGaramond(color: AppColors.softBlush, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    const SizedBox(height: 8),
                    Text(
                      "You've accepted the curation from ${selectedBid!['vendor_name']}.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
                    ),
                 ],
               ),
            ).animate().fadeIn(),
        ],
      ),
    );
  }

  Widget _buildBidCard(String serviceName, Map<String, dynamic> bid) {
    final isSelected = _selectedBids[serviceName]?['id'] == bid['id'];
    final rank = bid['rank'] as int;
    final isBest = rank == 1;
    final isAccepted = _acceptedBids[serviceName] ?? false;

    final displayName = bid['vendor_name'] ?? (isBest ? 'ELITE SELECTION' : 'DISTINGUISHED QUOTE $rank');
    final displayColor = AppColors.softBlush;

    return GestureDetector(
      onTap: isAccepted ? null : () {
        setState(() {
          _selectedBids[serviceName] = bid;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? (isAccepted ? AppColors.emerald : AppColors.crimsonSilk) : Colors.white.withValues(alpha: 0.05),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [BoxShadow(color: (isAccepted ? AppColors.emerald : AppColors.crimsonSilk).withValues(alpha: 0.1), blurRadius: 20)] : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 90,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: const Icon(LucideIcons.image, color: Colors.white10, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                           gradient: isBest ? AppColors.luxuryGradient : null,
                           color: isBest ? null : Colors.white.withValues(alpha: 0.05),
                           borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isBest ? '🥇 PREMIER' : (rank == 2 ? '🥈 SECOND' : '🥉 THIRD'),
                          style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0),
                        ),
                      ),
                      if (isBest)
                        Text('ELITE VALUE', style: GoogleFonts.outfit(color: AppColors.emerald, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.0)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(displayName, style: GoogleFonts.cormorantGaramond(color: displayColor, fontWeight: FontWeight.bold, fontSize: 20, height: 1.1)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(LucideIcons.star, size: 12, color: AppColors.crimsonSilk),
                      const SizedBox(width: 6),
                      Text('${bid['vendor_rating'] ?? 4.9}', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(width: 6),
                      Text('• ${bid['vendor_completed_events'] ?? 0} REVIEWS', style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                     children: [
                       _buildTag('VETTED', LucideIcons.check),
                       const SizedBox(width: 12),
                       _buildTag('INSURED', LucideIcons.shieldCheck),
                     ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: Colors.white.withValues(alpha: 0.05)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text('BESPOKE PACKAGE', style: GoogleFonts.outfit(color: Colors.white12, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                           const SizedBox(height: 4),
                           Text('₹${((bid['final_price'] ?? bid['amount']) as num).toStringAsFixed(0)}', style: GoogleFonts.outfit(color: AppColors.softBlush, fontSize: 22, fontWeight: FontWeight.bold)),
                         ],
                       ),
                       if (!isSelected)
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(12),
                             border: Border.all(color: Colors.white10),
                           ),
                           child: Text('SELECT', style: GoogleFonts.outfit(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0)),
                         )
                       else if (isAccepted)
                         Row(
                           children: [
                             Text('ACCEPTED', style: GoogleFonts.outfit(color: AppColors.emerald, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.0)),
                             const SizedBox(width: 8),
                             const Icon(LucideIcons.checkCircle, color: AppColors.emerald, size: 16),
                           ],
                         )
                       else
                         Row(
                           children: [
                             Text('SELECTED', style: GoogleFonts.outfit(color: AppColors.crimsonSilk, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.0)),
                             const SizedBox(width: 8),
                             const Icon(LucideIcons.check, color: AppColors.crimsonSilk, size: 16),
                           ],
                         ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComparisonTable(BuildContext context, List<Map<String, dynamic>> bids) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            gradient: AppColors.bordeauxGradient,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 32),
                Text('CURATION COMPARISON', style: GoogleFonts.cormorantGaramond(color: AppColors.softBlush, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 32),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.white.withValues(alpha: 0.05)),
                    child: DataTable(
                      columnSpacing: 32,
                      headingRowHeight: 60,
                      columns: [
                        DataColumn(label: Text('ATTRIBUTES', style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0))),
                        ...bids.asMap().entries.map((e) => DataColumn(
                          label: Text(
                            'QUOTE ${e.key + 1}', 
                            style: GoogleFonts.outfit(color: e.key == 0 ? AppColors.crimsonSilk : AppColors.softBlush, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)
                          )
                        )),
                      ],
                      rows: [
                        DataRow(cells: [
                          DataCell(Text('ARTISAN', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold))),
                          ...bids.map((b) => DataCell(Text(b['vendor_name'] ?? 'N/A', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)))),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('INVESTMENT', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold))),
                          ...bids.map((b) => DataCell(Text('₹${((b['final_price'] ?? b['amount']) as num).toStringAsFixed(0)}', style: GoogleFonts.outfit(color: AppColors.softBlush, fontWeight: FontWeight.bold, fontSize: 14)))),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('LUXE RATING', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold))),
                          ...bids.map((b) => DataCell(Row(
                            children: [
                              const Icon(LucideIcons.star, size: 10, color: AppColors.crimsonSilk),
                              const SizedBox(width: 6),
                              Text('${b['vendor_rating'] ?? 4.9}', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                            ],
                          ))),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('TIMELINE', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold))),
                          ...bids.map((b) => DataCell(Text('${b['timeline_days'] ?? 7} DAYS', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)))),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('LEGACY', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold))),
                          ...bids.map((b) => DataCell(Text('${b['vendor_experience'] ?? "5 YEARS"}', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)))),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.crimsonSilk.withValues(alpha: 0.6)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)), 
      ],
    );
  }

  Widget _buildBottomBar(Booking booking, int totalServices) {
    final totalAccepted = _acceptedBids.length;
    final totalCost = _selectedBids.values.fold(0.0, (sum, item) => sum + ((item['final_price'] ?? item['amount']) as num).toDouble());
    final allAccepted = totalAccepted == totalServices && totalServices > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ESTIMATED INVESTMENT', style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                const SizedBox(height: 4),
                Text('₹${totalCost.toStringAsFixed(0)}', style: GoogleFonts.outfit(color: AppColors.softBlush, fontSize: 26, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: allAccepted ? AppColors.luxuryGradient : null,
                color: allAccepted ? null : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                boxShadow: allAccepted ? [BoxShadow(color: AppColors.crimsonSilk.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))] : [],
              ),
              child: ElevatedButton(
                onPressed: allAccepted
                  ? () {
                      ref.read(bookingProvider.notifier).updatePrice(booking.id, totalCost);
                      ref.read(bookingProvider.notifier).updateSelectedVendors(booking.id, _selectedBids);
                      context.push('/confirm_booking/${booking.id}');
                    }
                  : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.transparent,
                  disabledForegroundColor: Colors.white10,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  allAccepted ? 'PROCEED' : '${totalServices - totalAccepted} REMAINING',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
