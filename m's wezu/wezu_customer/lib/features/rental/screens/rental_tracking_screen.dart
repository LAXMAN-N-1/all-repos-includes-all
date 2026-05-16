import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/battery_gps_data.dart';
import '../services/gps_tracking_service.dart';
import '../models/battery_health.dart';
import '../services/battery_health_service.dart';
import '../models/rental_timer.dart';
import '../services/rental_timer_service.dart';
import '../widgets/swap_notification_overlay.dart';
import '../widgets/swap_confirmation_sheet.dart';
import '../widgets/late_fee_payment_sheet.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/time_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RentalTrackingScreen extends StatefulWidget {
  final String batteryId;
  final DateTime? rentalExpiry;

  const RentalTrackingScreen({
    super.key,
    required this.batteryId,
    this.rentalExpiry,
  });

  @override
  State<RentalTrackingScreen> createState() => _RentalTrackingScreenState();
}

class _RentalTrackingScreenState extends State<RentalTrackingScreen> {
  final GpsTrackingService _gpsService = GpsTrackingService();
  final BatteryHealthService _healthService = BatteryHealthService();
  final RentalTimerService _timerService = RentalTimerService();
  // Use actual rental expiry passed in; fall back to 5h only if not provided
  late final DateTime _rentalExpiry;

  GoogleMapController? _mapController;
  BatteryGpsData? _currentData;
  BatteryHealth? _currentHealth;
  RentalTimer? _currentTimer;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _showHistory = false;
  bool _showHealthDetails = false;
  bool _showOverlay = false;
  String _overlayTitle = '';
  String _overlayMessage = '';
  final Set<int> _notifiedMarkers =
      {}; // Keep track of already notified hours to avoid repeats

  @override
  void initState() {
    super.initState();
    _rentalExpiry =
        widget.rentalExpiry ?? DateTime.now().add(const Duration(hours: 5));
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // ignore: deprecated_member_use
    _mapController?.setMapStyle(AppTheme.mapStyleDark);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          StreamBuilder<BatteryGpsData>(
            stream: _gpsService.getLiveLocation(widget.batteryId),
            builder: (context, gpsSnapshot) {
              if (gpsSnapshot.hasData) {
                _currentData = gpsSnapshot.data;
                _updateMapEssentials();
              }

              return StreamBuilder<BatteryHealth>(
                stream: _healthService.getHealthTelemetry(widget.batteryId),
                builder: (context, healthSnapshot) {
                  if (healthSnapshot.hasData) {
                    _currentHealth = healthSnapshot.data;
                  }

                  return StreamBuilder<RentalTimer>(
                    stream: _timerService.getCountdown(
                        widget.batteryId, _rentalExpiry),
                    builder: (context, timerSnapshot) {
                      if (timerSnapshot.hasData) {
                        _currentTimer = timerSnapshot.data;
                        _checkAndShowNotification(_currentTimer!);
                      }

                      return GoogleMap(
                        initialCameraPosition: CameraPosition(
                            target: GpsTrackingService.centerPoint, zoom: 14),
                        onMapCreated: _onMapCreated,
                        markers: _markers,
                        polylines: _polylines,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        circles: {
                          Circle(
                            circleId: const CircleId('geofence'),
                            center: GpsTrackingService.centerPoint,
                            radius: GpsTrackingService.geofenceRadiusKm * 1000,
                            fillColor:
                                AppTheme.primaryBlue.withValues(alpha: 0.05),
                            strokeColor:
                                AppTheme.primaryBlue.withValues(alpha: 0.2),
                            strokeWidth: 2,
                          ),
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
          _buildHeader(),
          _buildBottomCard(),
          if (_currentData != null && !_currentData!.isInsideGeofence)
            _buildGeofenceAlert(),
          if (_currentHealth != null &&
              _currentHealth!.tempState != TempState.normal)
            _buildTemperatureAlert(),
          if (_currentHealth != null && _currentHealth!.isHealthCritical)
            _buildHealthCriticalAlert(),
          _buildRentalExpiryAlert(),
          _buildSwapNowButton(),
          _buildLateFeeBanner(),
          if (_showOverlay)
            SwapNotificationOverlay(
              title: _overlayTitle,
              message: _overlayMessage,
              onDismiss: () => setState(() => _showOverlay = false),
              onAction: () => _showSwapFlow(),
            ),
        ],
      ),
    );
  }

  void _checkAndShowNotification(RentalTimer timer) {
    if (timer.isExpired) {
      return;
    }

    final hours = timer.remainingDuration.inHours;
    final mins = timer.remainingDuration.inMinutes;

    if (hours == 24 && !_notifiedMarkers.contains(24)) {
      _triggerOverlay(
        "24H EXPIRY WARNING",
        "Nearby swap stations are available.",
      );
      _notifiedMarkers.add(24);
    } else if (hours == 12 && !_notifiedMarkers.contains(12)) {
      _triggerOverlay(
        "12H EXPIRY WARNING",
        "Plan your swap soon to avoid late fees.",
      );
      _notifiedMarkers.add(12);
    } else if (hours <= 1 &&
        hours >= 0 &&
        mins <= 60 &&
        !_notifiedMarkers.contains(1)) {
      _triggerOverlay(
        "FINAL HOUR WARNING",
        "Immediate swap is recommended at the nearest station.",
      );
      _notifiedMarkers.add(1);
    }
  }

  void _triggerOverlay(String title, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _overlayTitle = title;
        _overlayMessage = message;
        _showOverlay = true;
      });
    });
  }

  void _updateMapEssentials() {
    if (_currentData == null) {
      return;
    }

    final marker = Marker(
      markerId: MarkerId(widget.batteryId),
      position: _currentData!.location,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(title: 'Active Battery: ${widget.batteryId}'),
    );

    _markers = {marker};

    if (_showHistory) {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('path'),
          points: _currentData!.history,
          color: AppTheme.accentGreen,
          width: 3,
        ),
      };
    } else {
      _polylines = {};
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(_currentData!.location),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: AppTheme.accentGreen, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                const Text('LIVE TRACKING',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCard() {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showHealthDetails) ...[
              _buildHealthDashboard(),
              const Divider(color: Colors.white10, height: 40),
            ],
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    LucideIcons.battery,
                    'Charge (SOC)',
                    _currentHealth != null ? '${_currentHealth!.soc}%' : '--',
                    iconColor: _getSocColor(),
                  ),
                ),
                const VerticalDivider(color: Colors.white10),
                Expanded(
                  child: _buildInfoItem(
                    LucideIcons.thermometer,
                    'Temperature',
                    _currentHealth != null
                        ? '${_currentHealth!.temperature.toStringAsFixed(1)}°C'
                        : '--',
                    iconColor: _getTempColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    onPressed: () =>
                        setState(() => _showHistory = !_showHistory),
                    icon:
                        _showHistory ? LucideIcons.eyeOff : LucideIcons.history,
                    label: _showHistory ? 'HIDE PATH' : 'TRACKING',
                    isActive: _showHistory,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    onPressed: () => setState(
                        () => _showHealthDetails = !_showHealthDetails),
                    icon: LucideIcons.activity,
                    label: _showHealthDetails ? 'SUMMARY' : 'HEALTH',
                    isActive: _showHealthDetails,
                    activeColor: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthDashboard() {
    if (_currentHealth == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Battery Diagnostics',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _currentHealth!.isHealthCritical
                    ? Colors.red.withValues(alpha: 0.1)
                    : AppTheme.accentGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Health: ${_currentHealth!.soh}%',
                style: TextStyle(
                  color: _currentHealth!.isHealthCritical
                      ? Colors.redAccent
                      : AppTheme.accentGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildDiagnosticItem(
                    'Voltage',
                    '${_currentHealth!.voltage.toStringAsFixed(1)}V',
                    'Range: 48-54V')),
            const SizedBox(width: 20),
            Expanded(
              child: _buildDiagnosticItem(
                'Time Left',
                _currentTimer?.formattedRemaining ?? '--',
                'Expires: ${TimeUtils.shortDateFromDt(_rentalExpiry)}',
                valueColor: _currentTimer?.isCriticalState == true
                    ? Colors.redAccent
                    : (_currentTimer?.isWarningState == true
                        ? Colors.orangeAccent
                        : Colors.white),
              ),
            ),
          ],
        ),
        if (_currentTimer?.isWarningState == true) ...[
          const Divider(color: Colors.white10, height: 32),
          _buildRecommendedStations(),
        ],
        if (_currentTimer?.isOverdue == true) ...[
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showLateFeeFlow(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('PAY OVERDUE FEES',
                style:
                    TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ],
      ],
    );
  }

  void _showLateFeeFlow() {
    if (_currentTimer == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LateFeePaymentSheet(
        amount: _currentTimer!.lateFeeAmount,
        rentalId: widget.batteryId,
      ),
    );
  }

  Widget _buildLateFeeBanner() {
    if (_currentTimer == null || !_currentTimer!.isOverdue) {
      return const SizedBox();
    }

    return Positioned(
      top: 120, // Below header
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)
          ],
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.alertTriangle,
                color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'RENTAL OVERDUE',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1),
              ),
            ),
            Text(
              'Accrued: \$${_currentTimer!.lateFeeAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedStations() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.mapPin, color: AppTheme.primaryBlue, size: 16),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Live station recommendations are loaded when you tap Swap Now.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwapNowButton() {
    if (_currentTimer == null || !_currentTimer!.isWarningState) {
      return const SizedBox();
    }

    return Positioned(
      bottom: 240, // Above the bottom card
      right: 20,
      child: FloatingActionButton.extended(
        onPressed: _showSwapFlow,
        label: const Text('SWAP NOW',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        icon: const Icon(LucideIcons.zap),
        backgroundColor: AppTheme.accentGreen,
        foregroundColor: Colors.black,
      ),
    );
  }

  void _showSwapFlow() {
    setState(() => _showOverlay = false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SwapConfirmationSheet(batteryId: widget.batteryId),
    );
  }

  Widget _buildRentalExpiryAlert() {
    if (_currentTimer == null || !_currentTimer!.isWarningState) {
      return const SizedBox();
    }

    final bool isCritical = _currentTimer!.isCriticalState;
    return Positioned(
      top: 290, // Positioned below other alerts
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isCritical ? Colors.redAccent : Colors.orangeAccent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: (isCritical ? Colors.red : Colors.orange)
                    .withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 5))
          ],
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.clock, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      isCritical
                          ? 'RENTAL EXPIRING SOON'
                          : 'RENTAL EXPIRY WARNING',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  Text(
                      isCritical
                          ? 'Final hour remaining! Swap now to avoid shutdown.'
                          : 'Less than 24 hours left. Please plan your next swap.',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticItem(String label, String value, String subValue,
      {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: valueColor ?? Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        Text(subValue,
            style: const TextStyle(color: Colors.white30, fontSize: 10)),
      ],
    );
  }

  Widget _buildActionButton(
      {required VoidCallback onPressed,
      required IconData icon,
      required String label,
      required bool isActive,
      Color? activeColor}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive
            ? (activeColor ?? AppTheme.accentGreen)
            : Colors.white.withValues(alpha: 0.05),
        foregroundColor: isActive ? Colors.black : Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    );
  }

  Color _getSocColor() {
    if (_currentHealth == null) return AppTheme.primaryBlue;
    if (_currentHealth!.soc < 20) return Colors.redAccent;
    if (_currentHealth!.soc < 50) return Colors.orangeAccent;
    return AppTheme.primaryBlue;
  }

  Color _getTempColor() {
    if (_currentHealth == null) return AppTheme.textSecondary;
    if (_currentHealth!.tempState == TempState.warning) {
      return Colors.orangeAccent;
    }
    if (_currentHealth!.tempState == TempState.critical) {
      return Colors.redAccent;
    }
    return AppTheme.accentGreen;
  }

  Widget _buildInfoItem(IconData icon, String label, String value,
      {Color? iconColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor ?? AppTheme.primaryBlue, size: 14),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
      ],
    );
  }

  Widget _buildTemperatureAlert() {
    final bool isCritical = _currentHealth!.tempState == TempState.critical;
    return Positioned(
      top: 130,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isCritical ? Colors.redAccent : Colors.orangeAccent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: (isCritical ? Colors.red : Colors.orange)
                    .withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 5))
          ],
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.thermometer, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      isCritical
                          ? 'CRITICAL TEMPERATURE'
                          : 'TEMPERATURE WARNING',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  Text(
                      isCritical
                          ? 'Battery shutdown imminent. Please stop use.'
                          : 'Battery is running hot. Avoid heavy load.',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCriticalAlert() {
    return Positioned(
      top: 210, // Offset to not overlap with temp alert if both active
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5))
          ],
        ),
        child: const Row(
          children: [
            Icon(LucideIcons.heartPulse, color: Colors.redAccent),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HEALTH DEGRADATION',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  Text('Battery health is below 80%. Maintenance required.',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeofenceAlert() {
    return Positioned(
      top: 130,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.red.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 5))
          ],
        ),
        child: const Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: Colors.white),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('GEOFENCE BREACH',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  Text('Battery is outside the 5KM safety zone!',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
