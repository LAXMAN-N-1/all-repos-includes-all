import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:evination_customer_app/core/constants/app_colors.dart';
import 'package:evination_customer_app/logic/providers/booking_provider.dart';

class ConfirmBookingScreen extends ConsumerWidget {
  final String bookingId;

  const ConfirmBookingScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(myBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      body: bookingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.sunflowerYellow)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.darkCharcoal))),
        data: (bookings) {
           final booking = bookings.firstWhere(
            (b) => b.id.toString() == bookingId,
            orElse: () => bookings.isNotEmpty ? bookings.first : throw Exception('Booking not found'),
          );
          
          final totalAmount = 250000.0;
          final initialPayment = totalAmount * 0.30;

          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(LucideIcons.arrowLeft, color: AppColors.darkCharcoal),
                onPressed: () => context.pop(),
              ),
              title: Text('CONFIRM BOOKING', style: GoogleFonts.cormorantGaramond(color: AppColors.darkCharcoal, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(booking, totalAmount),
                  const SizedBox(height: 24),
                  _buildPaymentBreakdown(totalAmount, initialPayment),
                  const SizedBox(height: 32),
                  _buildPaymentMethod(),
                ],
              ),
            ),
            bottomNavigationBar: _buildBottomBar(context, initialPayment),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(dynamic booking, double total) {
    final eventName = (booking.toJson()['event_name'] as String?) ?? 'Wedding Event';
    final eventDate = (booking.toJson()['event_date'] as String?) ?? 'Date TBD';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(color: AppColors.sunflowerYellow.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                 child: const Icon(LucideIcons.calendar, color: AppColors.sunflowerYellow),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(eventName, style: GoogleFonts.cormorantGaramond(color: AppColors.darkCharcoal, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(eventDate, style: GoogleFonts.outfit(color: AppColors.greyMedium, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 16),
          _buildRow('Total Service Value', '₹${total.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildRow('Platform Fee', '₹0', isMuted: true),
        ],
      ),
    );
  }

  Widget _buildPaymentBreakdown(double total, double initial) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PAYMENT SCHEDULE', style: GoogleFonts.outfit(color: AppColors.greyMedium, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(
            children: [
              _buildRow('Initial Deposit (30%)', '₹${initial.toStringAsFixed(0)}', isBold: true, color: AppColors.sunflowerYellow),
              const SizedBox(height: 12),
              _buildRow('Due 2 Weeks Before', '₹${(total * 0.5).toStringAsFixed(0)}', isMuted: true),
              const SizedBox(height: 12),
              _buildRow('Due on Completion', '₹${(total * 0.2).toStringAsFixed(0)}', isMuted: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PAYMENT METHOD', style: GoogleFonts.outfit(color: AppColors.greyMedium, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.emerald.withOpacity(0.3)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.creditCard, color: AppColors.greyDark),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('UPI / Net Banking', style: GoogleFonts.outfit(color: AppColors.darkCharcoal, fontWeight: FontWeight.bold)),
                  Text('Secure Payment Gateway', style: GoogleFonts.outfit(color: AppColors.greyMedium, fontSize: 11)),
                ],
              ),
              const Spacer(),
              const Icon(LucideIcons.checkCircle, color: AppColors.emerald),
            ],
          ),
        ),
      ],
     );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, bool isMuted = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: isMuted ? AppColors.greyMedium : AppColors.greyDark, fontSize: 13)),
        Text(value, style: GoogleFonts.outfit(color: color ?? (isMuted ? AppColors.greyMedium : AppColors.darkCharcoal), fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, double amount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Container(
           width: double.infinity,
           height: 56,
           decoration: BoxDecoration(
            gradient: AppColors.luxuryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.sunflowerYellow.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))],
          ),
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Redirecting to Payment Gateway...')));
              Future.delayed(const Duration(seconds: 2), () {
                 if (context.mounted) context.go('/bookings'); 
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.lock, size: 16),
                const SizedBox(width: 12),
                Text('PAY ₹${amount.toStringAsFixed(0)} SECURELY', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
