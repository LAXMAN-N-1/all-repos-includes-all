import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wezu_customer_app/core/theme/app_theme.dart';
import 'package:wezu_customer_app/features/dashboard/widgets/main_layout.dart';

class RentalReturnSuccessScreen extends StatelessWidget {
  const RentalReturnSuccessScreen({
    super.key,
    required this.rentalId,
    required this.stationName,
    this.swapSessionId,
    this.swapFee,
    this.swapError,
    this.newRentalId,
  });

  final int rentalId;
  final String stationName;
  final int? swapSessionId;
  final double? swapFee;
  final String? swapError;
  final int? newRentalId;

  bool get _swapDone => swapSessionId != null && swapError == null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Icon
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withValues(alpha: 0.15),
                ),
                child: const Icon(LucideIcons.checkCircle2,
                    color: Colors.green, size: 64),
              ),
              const SizedBox(height: 22),

              Text(
                _swapDone ? 'Return & Swap Complete!' : 'Return Successful',
                style: GoogleFonts.outfit(
                    fontSize: 28, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _swapDone
                    ? 'Old battery returned. New charged battery is yours.'
                    : 'Battery returned and removed from active rentals.',
                style: GoogleFonts.inter(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Return details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.shadowLight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detail('Rental ID', '#$rentalId'),
                    _detail('Returned To', stationName),
                    _detail('Return Status', 'COMPLETED'),
                    if (_swapDone) ...[
                      const Divider(height: 20),
                      _detail('Swap Session', '#$swapSessionId'),
                      _detail(
                        'Swap Fee',
                        swapFee != null && swapFee! > 0
                            ? '₹${swapFee!.toStringAsFixed(2)}'
                            : 'Free',
                      ),
                      _detail('New Battery', 'Assigned to you'),
                      if (newRentalId != null)
                        _detail('New Rental', '#$newRentalId'),
                    ],
                  ],
                ),
              ),

              // Swap error banner (return succeeded but swap failed)
              if (swapError != null && !_swapDone) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.orange, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Swap not completed',
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange.shade800)),
                            Text(swapError!,
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.orange.shade700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) => const MainLayout(initialIndex: 3)),
                    (route) => false,
                  ),
                  child: const Text('Back To Rentals'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detail(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              child: Text(key, style: GoogleFonts.inter(color: Colors.grey))),
          Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
