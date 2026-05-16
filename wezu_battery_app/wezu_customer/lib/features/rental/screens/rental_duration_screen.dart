import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../models/battery.dart';
import './pickup_method_screen.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';

class RentalDurationScreen extends StatefulWidget {
  final Battery battery;
  final int stationId;

  const RentalDurationScreen({super.key, required this.battery, required this.stationId});

  @override
  State<RentalDurationScreen> createState() => _RentalDurationScreenState();
}

class _RentalDurationScreenState extends State<RentalDurationScreen> {
  String _selectedDuration = "1d";
  bool _insuranceEnabled = false;
  bool _emergencySupportEnabled = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              "Rental Configuration",
              style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "Step 1 of 4",
              style: GoogleFonts.inter(fontSize: 12, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
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
                  _buildBatterySummary(isDark),
                  const SizedBox(height: 32),
                  Text("Select Rental Duration", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildDurationChips(isDark),
                  const SizedBox(height: 32),
                  Text("Select Pickup Date", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildDatePickerRow(isDark, "Pickup Date", "Today, 16 Feb", LucideIcons.calendar),
                  const SizedBox(height: 16),
                  _buildDatePickerRow(isDark, "Return Date", "Tomorrow, 17 Feb", LucideIcons.calendar),
                  const SizedBox(height: 32),
                  Text("Value Added Services", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildAddonCard(
                    isDark,
                    title: "Insurance Coverage",
                    price: "₹49",
                    icon: LucideIcons.shieldCheck,
                    isSelected: _insuranceEnabled,
                    onToggle: (v) => setState(() => _insuranceEnabled = v),
                  ),
                  const SizedBox(height: 12),
                  _buildAddonCard(
                    isDark,
                    title: "Emergency Support",
                    price: "₹29",
                    icon: LucideIcons.helpCircle,
                    isSelected: _emergencySupportEnabled,
                    onToggle: (v) => setState(() => _emergencySupportEnabled = v),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildBottomSummary(context, isDark),
        ],
      ),
    );
  }

  Widget _buildBatterySummary(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              "https://images.unsplash.com/photo-1617788138017-80ad40651399?w=100",
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Pro Lithium 200", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(widget.battery.type, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationChips(bool isDark) {
    final durations = [("1d", "1 Day"), ("3d", "3 Days"), ("1w", "1 Week"), ("1m", "1 Month")];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: durations.map((d) {
        final isSelected = _selectedDuration == d.$1;
        return InkWell(
          onTap: () => setState(() => _selectedDuration = d.$1),
          child: Container(
            width: (MediaQuery.of(context).size.width - 80) / 4,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryBlue : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.transparent),
            ),
            child: Column(
              children: [
                Text(
                  d.$1.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                  ),
                ),
                Text(
                  d.$2.split(" ").last,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: isSelected ? Colors.white70 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePickerRow(bool isDark, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
              Text(value, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          const Icon(LucideIcons.chevronDown, color: Colors.grey, size: 18),
        ],
      ),
    );
  }

  Widget _buildAddonCard(bool isDark, {required String title, required String price, required IconData icon, required bool isSelected, required Function(bool) onToggle}) {
    return InkWell(
      onTap: () => onToggle(!isSelected),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppTheme.primaryBlue : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05))),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(price, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.primaryBlue, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Checkbox(
              value: isSelected,
              onChanged: (v) => onToggle(v ?? false),
              activeColor: AppTheme.primaryBlue,

              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummary(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
        border: Border(top: BorderSide(color: isDark ? Colors.white12 : Colors.black12)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("₹149", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
              Text("Total for 1 day", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PickupMethodScreen(
                    battery: widget.battery,
                    stationId: widget.stationId,
                  )),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text("Next Step →", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}