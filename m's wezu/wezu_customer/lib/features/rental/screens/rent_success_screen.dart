import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wezu_customer_app/core/theme/app_theme.dart';
import 'package:wezu_customer_app/features/dashboard/widgets/main_layout.dart';

class RentSuccessScreen extends StatelessWidget {
  const RentSuccessScreen({
    super.key,
    required this.rentalId,
    required this.batteryName,
    required this.stationName,
  });

  final int rentalId;
  final String batteryName;
  final String stationName;

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
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  LucideIcons.checkCircle2,
                  color: Colors.green,
                  size: 64,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Transaction Successful',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Battery is now active in your rentals.',
                style: GoogleFonts.inter(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
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
                    _detail('Battery', batteryName),
                    _detail('Picked From', stationName),
                    _detail('Status', 'ACTIVE'),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const MainLayout(initialIndex: 3),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('View Active Rentals'),
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
