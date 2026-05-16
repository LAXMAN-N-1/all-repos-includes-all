import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:evination_customer_app/presentation/providers/booking_provider.dart';
import 'package:evination_customer_app/app/routes.dart';
import 'package:evination_customer_app/core/constants/app_colors.dart';

class BookingConfirmationScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const BookingConfirmationScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends ConsumerState<BookingConfirmationScreen> {
  bool _isSuccess = false;
  String _selectedPaymentMethod = '';

  void _confirmBooking() async {
    if (_selectedPaymentMethod.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a payment method')));
      return;
    }

    setState(() {
      _isSuccess = true;
    });

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      ref.read(bookingProvider.notifier).updateStatus(widget.bookingId, 'Confirmed');
      context.go(AppRouter.bookings);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.bordeauxGradient),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(LucideIcons.check, size: 64, color: AppColors.emerald),
                ).animate().scale(curve: Curves.elasticOut, duration: 800.ms).fadeIn(),
                const SizedBox(height: 48),
                Text('SELECTION SECURED', style: GoogleFonts.cormorantGaramond(color: AppColors.softBlush, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
                const SizedBox(height: 16),
                Text('YOUR CURATED JOURNEY BEGINS NOW', style: GoogleFonts.outfit(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 32),
                const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.crimsonSilk, strokeWidth: 2)),
              ],
            ),
          ),
        ),
      );
    }

    final bookings = ref.watch(bookingProvider);
    final booking = bookings.firstWhere((b) => b.id == widget.bookingId);
    
    // Calculate totals
    double totalCost = 0;
    if (booking.selectedVendors.isNotEmpty) {
      totalCost = booking.selectedVendors.values.fold(0.0, (sum, item) => sum + (item['price'] as double));
    }
    // Mock savings
    double totalSavings = totalCost * 0.12; 

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bordeauxGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Modal Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SECURE CHECKOUT', style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                        const SizedBox(height: 4),
                        Text('Complete Booking', style: GoogleFonts.cormorantGaramond(color: AppColors.softBlush, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: Colors.white24, size: 20), 
                      onPressed: () => context.pop(),
                      style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.05)),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Order Summary Card (Glassmorphism)
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ORDER SUMMARY', style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                            const SizedBox(height: 32),
                            
                            // Dynamic List
                            ...booking.selectedVendors.entries.map((e) => _buildSummaryRow(e.key, e.value['vendor'], (e.value['price'] as num).toDouble())),
                            
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('TOTAL INVESTMENT', style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                Text('₹${totalCost.toStringAsFixed(0)}', style: GoogleFonts.outfit(color: AppColors.softBlush, fontSize: 28, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Divider(color: Colors.white10),
                            const SizedBox(height: 24),
                            Text('PAYMENT SCHEDULE', style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                            const SizedBox(height: 16),
                            _buildPaymentRow('Initial Deposit (30%)', '₹${(totalCost * 0.3).toStringAsFixed(0)}', isBold: true, color: AppColors.softBlush),
                            _buildPaymentRow('Balance Due (70%)', '₹${(totalCost * 0.7).toStringAsFixed(0)}', isMuted: true),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      
                      const SizedBox(height: 40),
                      
                      // Payment Methods
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('SELECT PAYMENT METHOD', style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      ),
                      const SizedBox(height: 24),
                      
                      _buildPaymentMethod('PREMIUM CARD', 'Visa, Mastercard, Amex, Elite Cards', LucideIcons.creditCard),
                      _buildPaymentMethod('DIGITAL WALLET', 'Google Pay, Apple Pay, Luxury Wallets', LucideIcons.smartphone),
                      _buildPaymentMethod('PRIVATE BANKING', 'All major global banks supported', LucideIcons.landmark),
                      
                      const SizedBox(height: 32),
                       Container(
                         padding: const EdgeInsets.all(20),
                         decoration: BoxDecoration(
                           color: Colors.white.withValues(alpha: 0.02),
                           borderRadius: BorderRadius.circular(20),
                           border: Border.all(color: AppColors.crimsonSilk.withValues(alpha: 0.1)),
                         ),
                         child: Row(
                           children: [
                             const Icon(LucideIcons.lock, color: AppColors.crimsonSilk, size: 18),
                             const SizedBox(width: 16),
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text('ENCRYPTED TRANSACTION', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5)),
                                   Text('256-bit SSL secured. Your data remains private.', style: GoogleFonts.outfit(color: Colors.white24, fontSize: 11)),
                                 ],
                               ),
                             )
                           ],
                         ),
                       ),
                      
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),

              // Bottom Action Bar
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => context.pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white24,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text('BACK', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppColors.luxuryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: AppColors.crimsonSilk.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))],
                        ),
                        child: ElevatedButton(
                          onPressed: _confirmBooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text('COMPLETE BOOKING', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 13)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String title, String subtitle, IconData icon) {
    final isSelected = _selectedPaymentMethod == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.crimsonSilk : Colors.white.withValues(alpha: 0.05), width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.crimsonSilk.withValues(alpha: 0.1), blurRadius: 15)] : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.crimsonSilk : Colors.white24, size: 20),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(color: isSelected ? AppColors.softBlush : Colors.white70, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5)),
                  Text(subtitle, style: GoogleFonts.outfit(color: Colors.white24, fontSize: 11)),
                ],
              ),
            ),
            if (isSelected) const Icon(LucideIcons.checkCircle, color: AppColors.crimsonSilk, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isBold = false, bool isMuted = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: isMuted ? Colors.white24 : Colors.white70, fontSize: 13)),
          Text(value, style: GoogleFonts.outfit(color: color ?? (isMuted ? Colors.white24 : Colors.white), fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String category, String vendor, double price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(category.toUpperCase(), style: GoogleFonts.outfit(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0)), 
               Text('₹${(price as double).toStringAsFixed(0)}', style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          Text(vendor, style: GoogleFonts.cormorantGaramond(color: AppColors.softBlush, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
        ],
      ),
    );
  }
}
