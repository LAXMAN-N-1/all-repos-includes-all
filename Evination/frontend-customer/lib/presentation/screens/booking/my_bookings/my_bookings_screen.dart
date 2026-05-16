import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:evination_customer_app/logic/providers/booking_provider.dart';
import 'package:evination_customer_app/presentation/providers/booking_provider.dart';
import 'package:evination_customer_app/core/constants/app_colors.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  @override
  Widget build(BuildContext context) {
    // Watch the API provider
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bordeauxGradient),
        child: bookingsAsync.when(
          data: (bookings) => _buildContent(bookings),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.crimsonSilk)),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.rubyRed),
                const SizedBox(height: 16),
                Text('Error retrieving bookings', style: GoogleFonts.cormorantGaramond(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.softBlush)),
                const SizedBox(height: 8),
                Text(error.toString(), style: GoogleFonts.outfit(color: Colors.white38)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.refresh(myBookingsProvider),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.crimsonSilk),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<Booking> bookings) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. Hero Section
           Container(
             width: double.infinity,
             padding: const EdgeInsets.fromLTRB(24, 80, 24, 60),
             child: Column(
               children: [
                 Container(
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     gradient: AppColors.luxuryGradient,
                     borderRadius: BorderRadius.circular(20),
                     boxShadow: [
                       BoxShadow(
                         color: AppColors.crimsonSilk.withValues(alpha: 0.3),
                         blurRadius: 15,
                         offset: const Offset(0, 8),
                       )
                     ],
                   ),
                   child: const Icon(Icons.calendar_month_outlined, size: 36, color: Colors.white),
                 ),
                 const SizedBox(height: 32),
                 Text('MY RESERVATIONS', style: GoogleFonts.cormorantGaramond(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.softBlush, letterSpacing: 2.0)),
                 const SizedBox(height: 12),
                 Text('Manage and track your private event engagements', style: GoogleFonts.outfit(fontSize: 15, color: Colors.white54)),
               ],
             ),
           ).animate().fadeIn(duration: 800.ms),
           
           // 2. Content
           Padding(
             padding: const EdgeInsets.symmetric(horizontal: 24),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  // Summary Card
                  _buildSummaryCard(bookings.length),
                  const SizedBox(height: 48),
                  
                  if (bookings.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48.0),
                        child: Column(
                          children: [
                            Icon(Icons.event_busy, size: 64, color: Colors.white.withValues(alpha: 0.05)),
                            const SizedBox(height: 24),
                            Text('No reservations found', style: GoogleFonts.cormorantGaramond(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.softBlush)),
                            const SizedBox(height: 12),
                            Text('Begin by exploring our hand-selected artisan services.', textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.white38)),
                            const SizedBox(height: 40),
                            Container(
                              width: 200,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: AppColors.luxuryGradient,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ElevatedButton(
                                onPressed: () => context.go('/home'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Text('EXPLORE', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms)
                  else
                    ...bookings.map((booking) => _buildDetailedBookingCard(context, ref, booking)).toList(),
               ],
             ),
           ),
           const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int count) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 40, offset: const Offset(0, 20))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppColors.luxuryGradient, 
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(count.toString(), style: GoogleFonts.cormorantGaramond(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.softBlush, height: 1.0)),
              Text('ACTIVE ENGAGEMENTS', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedBookingCard(BuildContext context, WidgetRef ref, Booking booking) {
    final isAwaiting = booking.status == 'Awaiting Payment' || booking.status == 'Pending';
    final statusColor = isAwaiting ? AppColors.crimsonSilk : AppColors.emerald;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(booking.category.toUpperCase(), style: GoogleFonts.cormorantGaramond(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.softBlush, letterSpacing: 1.0)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        booking.status.toUpperCase(),
                        style: GoogleFonts.outfit(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  booking.services.join(' • ').toUpperCase(),
                  style: GoogleFonts.outfit(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                   const Icon(Icons.bookmark_outline, size: 14, color: AppColors.crimsonSilk),
                   const SizedBox(width: 10),
                   Text('ENTRY ID: ', style: GoogleFonts.outfit(color: Colors.white12, fontSize: 11, fontWeight: FontWeight.bold)),
                   Text(booking.refId, style: GoogleFonts.outfit(color: AppColors.softBlush, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5)),
                  ],
                ),
                
                 const SizedBox(height: 32),
                 
                 Row(
                   children: [
                     Expanded(child: _buildInfoItem(Icons.event_outlined, 'DATE', DateFormat('d MMM yyyy').format(booking.date).toUpperCase())),
                     Expanded(child: _buildInfoItem(Icons.schedule_outlined, 'TIME', '18:00')),
                   ],
                 ),
                 const SizedBox(height: 24),
                 Row(
                   children: [
                     Expanded(child: _buildInfoItem(Icons.location_on_outlined, 'VENU', booking.location.isEmpty ? 'TBD' : booking.location.toUpperCase())),
                     Expanded(child: _buildInfoItem(Icons.people_outline, 'GUEST', '${booking.guests} ATTENDEES')),
                   ],
                 ),
              ],
            ),
          ),
          
          Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
          
          Padding(
             padding: const EdgeInsets.all(24),
             child: Row(
               children: [
                 Expanded(
                   child: Container(
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(16),
                       border: Border.all(color: AppColors.crimsonSilk.withValues(alpha: 0.3)),
                     ),
                     child: TextButton(
                       onPressed: () {
                         context.push('/bids/${booking.id}');
                       },
                       style: TextButton.styleFrom(
                         padding: const EdgeInsets.symmetric(vertical: 18),
                         foregroundColor: AppColors.softBlush,
                       ),
                       child: Text('REVIEW BIDS', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                     ),
                   ),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: Container(
                     decoration: BoxDecoration(
                        gradient: AppColors.luxuryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: AppColors.crimsonSilk.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))
                        ]
                     ),
                     child: ElevatedButton(
                       onPressed: () {
                           _showConfirmationDialog(context, ref, booking.id);
                       },
                       style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                       ),
                       child: Text('CONFIRM', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                     ),
                   ),
                 ),
               ],
             ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.crimsonSilk.withValues(alpha: 0.4), size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.outfit(color: Colors.white12, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
              const SizedBox(height: 4),
              Text(
                value, 
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.softBlush, letterSpacing: 0.5),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showConfirmationDialog(BuildContext context, WidgetRef ref, String bookingId) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Order Confirmed',
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, a1, a2) => const SizedBox(),
      transitionBuilder: (context, a1, a2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: a1, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: a1,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                   width: 360,
                   padding: const EdgeInsets.all(40),
                   decoration: BoxDecoration(
                     gradient: AppColors.bordeauxGradient,
                     borderRadius: BorderRadius.circular(32),
                     border: Border.all(color: AppColors.crimsonSilk.withValues(alpha: 0.3)),
                     boxShadow: [BoxShadow(color: Colors.black, blurRadius: 40)]
                   ),
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppColors.luxuryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 32),
                        Text('EXCELLENCE SECURED', style: GoogleFonts.cormorantGaramond(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.softBlush, letterSpacing: 1.5)),
                        const SizedBox(height: 16),
                        Text(
                          'Your reservation has been confirmed with our artisans.', 
                          textAlign: TextAlign.center, 
                          style: GoogleFonts.outfit(color: Colors.white38, fontSize: 14)
                        ),
                        const SizedBox(height: 40),
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppColors.luxuryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ElevatedButton(
                            onPressed: () => context.pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text('CLOSE', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          ),
                        ),
                     ],
                   ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
