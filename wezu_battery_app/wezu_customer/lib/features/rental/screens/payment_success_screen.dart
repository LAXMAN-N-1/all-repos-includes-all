import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../models/rental.dart';
import './active_rental_dashboard.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final Rental rental;

  const PaymentSuccessScreen({super.key, required this.rental});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Celebration (subtle)
          Positioned(
            top: -100,
            right: -100,
            child: Container(width: 300, height: 300, decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.05), shape: BoxShape.circle)),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Success Badge
                _buildSuccessBadge(),
                const SizedBox(height: 24),
                Text("Rental Confirmed!",
                    style: GoogleFonts.outfit(
                        fontSize: 28, fontWeight: FontWeight.bold)),
                Text("Order #WEZ-${rental.id}",
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),

                const SizedBox(height: 48),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildFulfillmentStatus(isDark),
                        const SizedBox(height: 24),
                        _buildHandoverInstructions(isDark),
                        const SizedBox(height: 24),
                        _buildOrderDetailsSummary(isDark),
                      ],
                    ),
                  ),
                ),

                _buildActionButton(context, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBadge() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.green.withValues(alpha: 0.2), width: 4),
      ),
      child: const Center(
        child: Icon(LucideIcons.check, color: Colors.green, size: 48),
      ),
    );
  }

  Widget _buildFulfillmentStatus(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Fulfillment Status",
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text("Prepping", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _statusStep(true, "Order"),
              _statusLine(true),
              _statusStep(true, "Paid"),
              _statusLine(false),
              _statusStep(false, "Ready"),
            ],
          ),
          const SizedBox(height: 24),
          Text(
              "We're preparing your ${rental.battery.modelNumber} for collection. It will be ready in 15 mins.",
              style: GoogleFonts.inter(
                  fontSize: 13, color: Colors.grey, height: 1.5)),
        ],
      ),
    );
  }

  Widget _statusStep(bool isDone, String label) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isDone ? AppTheme.primaryBlue : Colors.grey.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(isDone ? Icons.check : Icons.circle,
              size: 12, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _statusLine(bool isDone) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isDone ? AppTheme.primaryBlue : Colors.grey.withValues(alpha: 0.1),
      ),
    );
  }

  Widget _buildHandoverInstructions(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withValues(alpha: 0.8)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Text("Handover PIN",
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text("8 2 9 1",
              style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8)),
          const SizedBox(height: 16),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, color: Colors.white24)),
          const SizedBox(height: 8),
          Text("Show this PIN to the station officer or delivery partner to collect your battery.", textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsSummary(bool isDark) {
    return Column(
      children: [
        _orderDetailRow(isDark, LucideIcons.calendar, "Duration",
            "${rental.durationDays} Day${rental.durationDays > 1 ? 's' : ''}"),
        const SizedBox(height: 12),
        _orderDetailRow(isDark, LucideIcons.mapPin, "Pickup at",
            "Station #${rental.pickupStationId}"),
      ],
    );
  }

  Widget _orderDetailRow(
      bool isDark, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          Text(label,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ActiveRentalDashboard(rental: rental)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: Text("Go to Rental Dashboard",
                style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: Text("Back to Home",
                style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}