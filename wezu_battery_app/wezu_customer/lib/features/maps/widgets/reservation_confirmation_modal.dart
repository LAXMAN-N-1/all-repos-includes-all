import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/station.dart';
import '../../../core/theme/app_theme.dart';

class ReservationConfirmationModal extends StatelessWidget {
  final Station station;
  final VoidCallback onConfirm;

  const ReservationConfirmationModal({
    super.key,
    required this.station,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Confirm Reservation",
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Confirm your battery reservation at this station. You will have 15 minutes to arrive.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          _buildDetailRow("Station", station.name, Icons.ev_station, isDark),
          _buildDetailRow("Battery Type", station.batteryType,
              Icons.battery_charging_full, isDark),
          _buildDetailRow("Duration", "15 Minutes", Icons.timer, isDark),
          _buildDetailRow("Cost", "₹0.00 (Free)", Icons.payments, isDark),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.outfit(
                        color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    onConfirm();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Battery Reserved Successfully!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    "Confirm",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryBlue),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.inter(color: Colors.grey)),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
