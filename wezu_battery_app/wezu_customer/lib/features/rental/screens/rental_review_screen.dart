import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../models/battery.dart';
import '../providers/rental_providers.dart';
import './payment_success_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';

class RentalReviewScreen extends ConsumerStatefulWidget {
  final Battery battery;
  final int stationId;

  const RentalReviewScreen(
      {super.key, required this.battery, required this.stationId});

  @override
  ConsumerState<RentalReviewScreen> createState() => _RentalReviewScreenState();
}

class _RentalReviewScreenState extends ConsumerState<RentalReviewScreen> {
  String _paymentMethod = "gpay";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              "Review & Payment",
              style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            Text(
              "Step 3 of 4",
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildOrderSummary(isDark),
                  const SizedBox(height: 32),
                  Text("Itemized Receipt",
                      style: GoogleFonts.outfit(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildItemizedReceipt(isDark),
                  const SizedBox(height: 32),
                  Text("Payment Method",
                      style: GoogleFonts.outfit(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildPaymentGrid(isDark),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildBottomPayButton(context, isDark),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                    "https://images.unsplash.com/photo-1617788138017-80ad40651399?w=100",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pro Lithium 200",
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Rental for 1 Day",
                        style: GoogleFonts.inter(
                            fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: Colors.white12)),
          _summaryRow(LucideIcons.calendar, "Pickup Date", "16 Feb, 2024"),
          const SizedBox(height: 12),
          _summaryRow(LucideIcons.mapPin, "Fulfillment", "Self Pickup"),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryBlue),
        const SizedBox(width: 12),
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
        const Spacer(),
        Text(value,
            style:
                GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }

  Widget _buildItemizedReceipt(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _receiptRow("Base Rental (1 Day)", "₹149"),
          _receiptRow("Fulfillment Fee", "₹0"),
          _receiptRow("Insurance Add-on", "₹49"),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Colors.white10)),
          _receiptRow("Refundable Deposit", "₹5,000", isDim: true),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Amount",
                  style: GoogleFonts.outfit(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text("₹5,198",
                  style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool isDim = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  color:
                      isDim ? Colors.grey : (isDim ? Colors.white70 : null))),
          Text(value,
              style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: isDim ? FontWeight.normal : FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPaymentGrid(bool isDark) {
    final methods = [
      ("gpay", "Google Pay", LucideIcons.smartphone, Colors.blue),
      ("card", "Credit Card", LucideIcons.creditCard, Colors.orange),
      ("net", "Net Banking", LucideIcons.building, Colors.green),
    ];
    return Column(
      children: methods.map((m) {
        final isSelected = _paymentMethod == m.$1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => setState(() => _paymentMethod = m.$1),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppTheme.primaryBlue : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)), width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: m.$4.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Icon(m.$3, color: m.$4, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Text(m.$2,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  if (isSelected)
                    const Icon(LucideIcons.checkCircle,
                        color: AppTheme.primaryBlue, size: 20),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomPayButton(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      color: isDark ? AppTheme.backgroundDark : Colors.white,
      child: ElevatedButton(
        onPressed: _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          minimumSize: const Size(double.infinity, 64),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 12,
          shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.lock, size: 18, color: Colors.white),
            const SizedBox(width: 12),
            Text("Pay ₹5,198 Securely",
                style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePayment() async {
    try {
      // 1. Initiate Rental (Pending Payment)
      final rentalRepository = ref.read(rentalRepositoryProvider);
      final rental = await rentalRepository.initiateRental(
        batteryId: widget.battery.id,
        stationId: widget.stationId,
        durationDays: 1, // Simplifying to 1 day for now as per UI summary
      );

      // 2. Confirm Rental (Simulating payment success)
      final confirmedRental = await rentalRepository.confirmRental(
        rental.id,
        "TXN-${DateTime.now().millisecondsSinceEpoch}"
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(rental: confirmedRental),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error: ${e.toString()}"),
              backgroundColor: Colors.red),
        );
      }
    }
  }
}