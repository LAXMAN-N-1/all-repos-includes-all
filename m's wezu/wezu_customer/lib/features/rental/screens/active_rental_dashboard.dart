import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/rental.dart';
import 'dart:async';
import '../../../core/theme/app_theme.dart';
import '../providers/rental_providers.dart';
import 'live_tracking_screen.dart';
import 'health_monitor_screen.dart';
import 'late_fee_screen.dart';
import '../widgets/extend_rental_sheet.dart';
import '../widgets/waiver_request_sheet.dart';
import '../widgets/issue_report_sheet.dart';

class ActiveRentalDashboard extends ConsumerStatefulWidget {
  final Rental rental;
  const ActiveRentalDashboard({super.key, required this.rental});

  @override
  ConsumerState<ActiveRentalDashboard> createState() => _ActiveRentalDashboardState();
}

class _ActiveRentalDashboardState extends ConsumerState<ActiveRentalDashboard> {
  double _soc = 82.0;
  bool _isLocked = true;
  Timer? _timer;

  // Rental action state
  late String _rentalStatus; // 'active', 'paused'
  late DateTime _endTime;
  String _waiverStatus = 'none'; // 'none', 'pending', 'approved', 'rejected'
  bool _issueReported = false;
  String? _ticketId;

  // Late fee state
  double _lateFeeTotal = 0.0;
  double _lateFeeRate = 5.0;
  int _hoursOverdue = 0;
  bool _lateFeeExpanded = false;

  @override
  void initState() {
    super.initState();
    _rentalStatus = widget.rental.status == 'paused' ? 'paused' : 'active';
    _endTime = widget.rental.endTime ??
        widget.rental.startTime.add(Duration(days: widget.rental.durationDays));

    // Simulate battery drain & update time remaining
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_soc > 1 && timer.tick % 10 == 0) _soc -= 0.1;
          // Update late fee if overdue
          if (widget.rental.isOverdue || DateTime.now().isAfter(_endTime)) {
            final overdueDuration = DateTime.now().difference(_endTime);
            _hoursOverdue = overdueDuration.inHours;
            _lateFeeTotal = (overdueDuration.inMinutes / 60.0) * _lateFeeRate;
          }
        });
      }
    });

    // Fetch late fee data if overdue
    if (widget.rental.isOverdue) {
      _fetchLateFees();
    }
  }

  Future<void> _fetchLateFees() async {
    try {
      final repo = ref.read(rentalRepositoryProvider);
      final data = await repo.getLateFees(widget.rental.id);
      if (mounted) {
        setState(() {
          _lateFeeTotal = (data['total_fee'] as num?)?.toDouble() ?? _lateFeeTotal;
          _lateFeeRate = (data['rate_per_hour'] as num?)?.toDouble() ?? _lateFeeRate;
          _hoursOverdue = data['hours_overdue'] ?? _hoursOverdue;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOverdue = widget.rental.isOverdue || DateTime.now().isAfter(_endTime);
    final isPaused = _rentalStatus == 'paused';

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Active Rental", style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.moreVertical, color: isDark ? Colors.white : Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // === LATE FEE BANNER ===
            if (isOverdue && _waiverStatus != 'approved') ...[
              _buildLateFeeBanner(isDark),
              const SizedBox(height: 16),
            ],
            // === PAUSED BANNER ===
            if (isPaused) ...[
              _buildPausedBanner(isDark),
              const SizedBox(height: 16),
            ],
            // === WAIVER STATUS BANNER ===
            if (_waiverStatus == 'approved') ...[
              _buildWaiverApprovedBanner(isDark),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 12),
            _buildMainBatteryCard(isDark),
            const SizedBox(height: 24),
            _buildQuickActions(isDark),
            const SizedBox(height: 24),
            // === RENTAL ACTION BUTTONS ===
            _buildRentalActionButtons(isDark),
            const SizedBox(height: 32),
            _buildTelemetryGrid(isDark),
            const SizedBox(height: 32),
            _buildUsageSummary(isDark),
            const SizedBox(height: 24),
            // === REPORT A PROBLEM ===
            _buildReportProblemLink(isDark),
            const SizedBox(height: 24),
            _buildRentalControl(isDark),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // === BANNER WIDGETS ===

  Widget _buildLateFeeBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(LucideIcons.alertTriangle, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Late Fee Accruing", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.red)),
                    Text("₹${_lateFeeTotal.toStringAsFixed(2)} (₹$_lateFeeRate/hr × $_hoursOverdue hrs)",
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.red.shade300)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LateFeeScreen(rental: widget.rental))),
                child: Text("Details", style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showWaiverSheet(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("Request Waiver", style: GoogleFonts.inter(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LateFeeScreen(rental: widget.rental))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("Pay Now", style: GoogleFonts.inter(fontSize: 12, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPausedBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.pauseCircle, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rental Paused", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.orange)),
                Text("Your rental timer is paused", style: GoogleFonts.inter(fontSize: 12, color: Colors.orange.shade300)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _handleResumeRental(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Resume", style: GoogleFonts.inter(fontSize: 12, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildWaiverApprovedBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.checkCircle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Late Fee Waived", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.green)),
                Text("Your waiver request was approved", style: GoogleFonts.inter(fontSize: 12, color: Colors.green.shade300)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === MAIN BATTERY CARD ===

  Widget _buildMainBatteryCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.rental.battery.modelNumber, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    Text("ID: ${widget.rental.battery.serialNumber}", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _rentalStatus == 'paused' ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _rentalStatus.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: _rentalStatus == 'paused' ? Colors.orange : Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildSoCCircle(isDark),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: _simpleStat("Temp", "34°C", LucideIcons.thermometer, Colors.blue)),
              Expanded(child: _simpleStat("Voltage", "${widget.rental.battery.voltage}V", LucideIcons.zap, Colors.amber)),
              Expanded(child: _simpleStat("Health", "${widget.rental.battery.healthPercentage.toInt()}%", LucideIcons.heart, Colors.red)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSoCCircle(bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: CircularProgressIndicator(
            value: _soc / 100,
            strokeWidth: 12,
            backgroundColor: isDark ? Colors.white12 : Colors.grey[200],
            color: _soc > 20 ? AppTheme.primaryBlue : Colors.red,
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          children: [
            Text("${_soc.toStringAsFixed(1)}%", style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold)),
            Text("State of Charge", style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _simpleStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  // === QUICK ACTIONS ===

  Widget _buildQuickActions(bool isDark) {
    return Row(
      children: [
        _quickAction(
          LucideIcons.lock,
          "Lock",
          isDark,
          onTap: () => _handleLockControl(true),
          isActive: _isLocked,
        ),
        const SizedBox(width: 12),
        _quickAction(
          LucideIcons.unlock,
          "Unlock",
          isDark,
          onTap: () => _handleLockControl(false),
          isActive: !_isLocked,
        ),
        const SizedBox(width: 12),
        _quickAction(
          LucideIcons.map,
          "Track",
          isDark,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LiveTrackingScreen(rental: widget.rental))),
        ),
        const SizedBox(width: 12),
        _quickAction(
          LucideIcons.heartPulse,
          "Health",
          isDark,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HealthMonitorScreen(rental: widget.rental))),
        ),
      ],
    );
  }

  void _handleLockControl(bool tryLock) {
    if (tryLock) {
      if (_isLocked) {
        _showStatusMessage("Battery is already locked");
      } else {
        setState(() => _isLocked = true);
        _showStatusMessage("Battery locked successfully");
      }
    } else {
      if (!_isLocked) {
        _showStatusMessage("Battery is not locked");
      } else {
        setState(() => _isLocked = false);
        _showStatusMessage("Battery unlocked successfully");
      }
    }
  }

  void _showStatusMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, bool isDark, {required VoidCallback onTap, bool isActive = false}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primaryBlue.withOpacity(0.1)
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? AppTheme.primaryBlue
                  : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? AppTheme.primaryBlue : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? AppTheme.primaryBlue : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === RENTAL ACTION BUTTONS ===

  Widget _buildRentalActionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: LucideIcons.timerReset,
            label: "Extend",
            color: AppTheme.primaryBlue,
            isDark: isDark,
            onTap: () => _showExtendSheet(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            icon: _rentalStatus == 'paused' ? LucideIcons.play : LucideIcons.pause,
            label: _rentalStatus == 'paused' ? "Resume" : "Pause",
            color: Colors.orange,
            isDark: isDark,
            onTap: () => _rentalStatus == 'paused' ? _handleResumeRental() : _handlePauseRental(),
          ),
        ),
      ],
    );
  }

  Widget _actionButton({required IconData icon, required String label, required Color color, required bool isDark, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  // === TELEMETRY GRID ===

  Widget _buildTelemetryGrid(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Detailed Telemetry", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
            _telemetryItem(LucideIcons.activity, "Current", "12.4 A", isDark),
            _telemetryItem(LucideIcons.batteryCharging, "Cycle", "${widget.rental.battery.cycleCount}", isDark),
            _telemetryItem(LucideIcons.shield, "BMS Status", "Healthy", isDark),
            _telemetryItem(LucideIcons.cpu, "Firmware", "v2.1.0", isDark),
          ],
        ),
      ],
    );
  }

  Widget _telemetryItem(IconData icon, String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
              Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // === USAGE SUMMARY ===

  Widget _buildUsageSummary(bool isDark) {
    final isOverdue = widget.rental.isOverdue || DateTime.now().isAfter(_endTime);
    final remaining = _endTime.difference(DateTime.now());
    final remainingText = remaining.isNegative
        ? "Overdue"
        : "${remaining.inHours}h ${remaining.inMinutes % 60}m remaining";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isOverdue
            ? Colors.red.withOpacity(0.05)
            : AppTheme.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOverdue
              ? Colors.red.withOpacity(0.3)
              : AppTheme.primaryBlue.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOverdue ? LucideIcons.alertTriangle : LucideIcons.clock,
            color: isOverdue ? Colors.red : AppTheme.primaryBlue,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOverdue ? "Rental Expired" : "Rental Remaining",
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  remainingText,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isOverdue ? Colors.red : (isDark ? Colors.white : Colors.black),
                  ),
                ),
              ],
            ),
          ),
          if (isOverdue)
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LateFeeScreen(rental: widget.rental))),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text("PAY FEES", style: GoogleFonts.outfit(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
            )
          else
            ElevatedButton(
              onPressed: () => _showExtendSheet(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text("EXTEND", style: GoogleFonts.outfit(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  // === REPORT PROBLEM LINK ===

  Widget _buildReportProblemLink(bool isDark) {
    return InkWell(
      onTap: () => _showIssueReportSheet(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.alertCircle, size: 18, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _issueReported ? "Issue Reported (Ticket: $_ticketId)" : "Report a Problem",
                style: GoogleFonts.inter(fontSize: 14, color: _issueReported ? Colors.green : (isDark ? Colors.white70 : Colors.black87)),
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // === RENTAL CONTROL (RETURN) ===

  Widget _buildRentalControl(bool isDark) {
    return ElevatedButton(
      onPressed: () => _showStatusMessage("Return process initiated. Please follow in-app guide."),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.withOpacity(0.1),
        foregroundColor: Colors.red,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: Text("Initiate Battery Return", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
    );
  }

  // === ACTION HANDLERS ===

  void _showExtendSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExtendRentalSheet(
        rentalId: widget.rental.id,
        onExtended: (newEndTime, amountCharged, hours) {
          setState(() => _endTime = newEndTime);
          _showStatusMessage("Rental extended by $hours hours");
        },
      ),
    );
  }

  void _showWaiverSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WaiverRequestSheet(
        rentalId: widget.rental.id,
        currentFee: _lateFeeTotal,
        onSubmitted: (waiverStatus, waiverId) {
          setState(() => _waiverStatus = waiverStatus);
          _showStatusMessage("Waiver request submitted");
        },
      ),
    );
  }

  void _showIssueReportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => IssueReportSheet(
        rentalId: widget.rental.id,
        onReported: (ticketId) {
          setState(() {
            _issueReported = true;
            _ticketId = ticketId;
          });
          _showStatusMessage("Issue reported successfully");
        },
      ),
    );
  }

  void _handlePauseRental() async {
    try {
      final repo = ref.read(rentalRepositoryProvider);
      await repo.pauseRental(widget.rental.id);
      setState(() => _rentalStatus = 'paused');
      _showStatusMessage("Rental paused");
    } catch (e) {
      _showStatusMessage("Failed to pause rental");
    }
  }

  void _handleResumeRental() async {
    try {
      final repo = ref.read(rentalRepositoryProvider);
      await repo.resumeRental(widget.rental.id);
      setState(() => _rentalStatus = 'active');
      _showStatusMessage("Rental resumed");
    } catch (e) {
      _showStatusMessage("Failed to resume rental");
    }
  }
}
