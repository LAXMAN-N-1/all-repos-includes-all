import 'package:flutter/material.dart';
import '../models/battery.dart';
import '../../../core/theme/app_theme.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import './rental_duration_screen.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';

class BatteryDetailScreen extends StatefulWidget {
  final Battery battery;
  final int stationId;

  const BatteryDetailScreen(
      {super.key, required this.battery, required this.stationId});

  @override
  State<BatteryDetailScreen> createState() => _BatteryDetailScreenState();
}

class _BatteryDetailScreenState extends State<BatteryDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, isDark),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildHeader(isDark),
                      const SizedBox(height: 24),
                      _buildMainStats(isDark),
                      const SizedBox(height: 32),
                      _buildTabs(isDark),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 500, // Fixed height for tab content
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildAboutTab(isDark),
                            _buildSpecsTab(isDark),
                            _buildPerformanceTab(isDark),
                          ],
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildStickyBottomButton(context, isDark),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: isDark ? AppTheme.backgroundDark : Colors.white,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
              color: Colors.black26, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'battery-img-${widget.battery.id}',
              child: Image.network(
                'https://images.unsplash.com/photo-1617788138017-80ad40651399?auto=format&fit=crop&q=80&w=600',
                fit: BoxFit.cover,
              ),
            ),
            Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                  Colors.black26,
                  Colors.transparent,
                  Colors.black45
                ]))),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Pro Lithium 200",
              style:
                  GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Text("98% Healthy", style: GoogleFonts.outfit(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(widget.battery.type,
            style: GoogleFonts.inter(
                fontSize: 16,
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildMainStats(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _mainStatItem(LucideIcons.zap, "72V / 40Ah", "Power System", isDark),
        _mainStatItem(LucideIcons.shieldCheck, "1 Year", "Warranty", isDark),
        _mainStatItem(LucideIcons.refreshCw, "2000+", "Life Cycles", isDark),
      ],
    );
  }

  Widget _mainStatItem(IconData icon, String value, String label, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 24),
        const SizedBox(height: 8),
        Text(value,
            style:
                GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildTabs(bool isDark) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: "About"),
          Tab(text: "Specs"),
          Tab(text: "Features"),
        ],
      ),
    );
  }

  Widget _buildAboutTab(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          "Premium lithium iron phosphate (LiFePO4) battery designed for high-performance electric vehicles. Features advanced BMS, temperature control, and rugged IP67 construction.",
          style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.6),
        ),
        const SizedBox(height: 24),
        Text("Key Benefits:",
            style:
                GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _benefitItem("Ultra-safe LiFePO4 chemistry"),
        _benefitItem("Smart BMS with Bluetooth monitoring"),
        _benefitItem("High energy density, lightweight"),
      ],
    );
  }

  Widget _benefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(LucideIcons.check, color: Colors.green, size: 16),
          const SizedBox(width: 12),
          Text(text, style: GoogleFonts.inter(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSpecsTab(bool isDark) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _specRow("Nominal Voltage", "72V"),
        _specRow("Rated Capacity", "40Ah (2.88kWh)"),
        _specRow("Max Discharge Current", "80A (Continuous)"),
        _specRow("Peak Current", "150A (10 secs)"),
        _specRow("Standard Charge", "10A"),
        _specRow("Fast Charge", "20A"),
        _specRow("Operating Temp", "-20°C to 60°C"),
      ],
    );
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
          Text(value,
              style: GoogleFonts.outfit(
                  fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab(bool isDark) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _specRow("Weight", "18.5 kg"),
        _specRow("Dimensions", "240 x 180 x 160 mm"),
        _specRow("Protection Class", "IP67 (Dust & Water)"),
        _specRow("Certification", "CE, UN38.3, RoHS"),
        _specRow("Casing Material", "Aeronautical Grade Aluminum"),
        _specRow("Life Cycle", "2000 Cycles to 80% DoD"),
      ],
    );
  }

  Widget _buildStickyBottomButton(BuildContext context, bool isDark) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
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
                Text("₹${widget.battery.rentalPricePerDay.toInt()}/day",
                    style: GoogleFonts.outfit(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Refundable deposit extra",
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RentalDurationScreen(
                        battery: widget.battery,
                        stationId: widget.stationId,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                ),
                child: Text("Rent This Battery →",
                    style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}