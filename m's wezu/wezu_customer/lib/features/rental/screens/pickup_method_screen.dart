import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../models/battery.dart';
import './rental_review_screen.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';

class PickupMethodScreen extends StatefulWidget {
  final Battery battery;
  final int stationId;

  const PickupMethodScreen({super.key, required this.battery, required this.stationId});

  @override
  State<PickupMethodScreen> createState() => _PickupMethodScreenState();
}

class _PickupMethodScreenState extends State<PickupMethodScreen> {
  String _selectedMethod = "pickup"; // pickup or delivery
  String _selectedSlot = "morning"; // morning, afternoon, evening

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
              "Fulfillment Method",
              style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "Step 2 of 4",
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
                  Text("How do you want to get it?", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Select a method for battery handover", style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 32),
                  _buildMethodCard(
                    isDark,
                    id: "pickup",
                    title: "Self Pickup",
                    subtitle: "Collect from Wezu Station",
                    icon: LucideIcons.store,
                    price: "Free",
                  ),
                  const SizedBox(height: 16),
                  _buildMethodCard(
                    isDark,
                    id: "delivery",
                    title: "Home Delivery",
                    subtitle: "Delivered to your doorstep",
                    icon: LucideIcons.truck,
                    price: "+₹99",
                  ),
                  const SizedBox(height: 32),
                  if (_selectedMethod == "pickup") _buildStationInfo(isDark) else _buildDeliveryDetails(isDark),
                  const SizedBox(height: 32),
                  Text("Preferred Time Slot", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildSlotGrid(isDark),
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

  Widget _buildMethodCard(bool isDark, {required String id, required String title, required String subtitle, required IconData icon, required String price}) {
    final isSelected = _selectedMethod == id;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.primaryBlue : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.1) : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100]),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? AppTheme.primaryBlue : Colors.grey, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            Text(price, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: price == "Free" ? Colors.green : AppTheme.primaryBlue)),
          ],
        ),
      ),
    );
  }

  Widget _buildStationInfo(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.mapPin, color: AppTheme.primaryBlue, size: 18),
              const SizedBox(width: 8),
              Text("Pickup Location", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
            ],
          ),
          const SizedBox(height: 12),
          Text("Main Wezu Hub - Sector 62", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
          Text("Plot 12, Electronic City, Noida, UP 201301", style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(LucideIcons.clock, color: Colors.grey, size: 14),
              const SizedBox(width: 4),
              Text("Open 24/7", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetails(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Deliver To", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: Text("Change", style: GoogleFonts.inter(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold))),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.home, color: Colors.grey, size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Home", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    Text("H-152, Sector 22, Noida, Uttar Pradesh", style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlotGrid(bool isDark) {
    final slots = [
      ("morning", "Morning", "08:00 - 12:00", LucideIcons.sun),
      ("afternoon", "Afternoon", "12:00 - 16:00", LucideIcons.cloudSun),
      ("evening", "Evening", "16:00 - 20:00", LucideIcons.moon),
    ];
    return Row(
      children: slots.map((s) {
        final isSelected = _selectedSlot == s.$1;
        return Expanded(
          child: InkWell(
            onTap: () => setState(() => _selectedSlot = s.$1),
            child: Container(
              margin: EdgeInsets.only(right: s.$1 == "evening" ? 0 : 12),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryBlue : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.transparent),
              ),
              child: Column(
                children: [
                  Icon(s.$4, color: isSelected ? Colors.white : Colors.grey, size: 20),
                  const SizedBox(height: 8),
                  Text(s.$2, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black))),
                  Text(s.$3.split(" - ").first, style: GoogleFonts.inter(fontSize: 10, color: isSelected ? Colors.white70 : Colors.grey)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomSummary(BuildContext context, bool isDark) {
    final deliveryFee = _selectedMethod == "delivery" ? 99 : 0;
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
              Text("₹${149 + deliveryFee}", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
              Text("Including fulfilled fee", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RentalReviewScreen(
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
              child: Text("Review Order →", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}