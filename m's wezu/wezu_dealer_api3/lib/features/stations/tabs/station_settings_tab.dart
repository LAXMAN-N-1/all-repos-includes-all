import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_response.dart';
import '../../../core/theme/colors.dart';
import '../models/station_state.dart';

// ══════════════════════════════════════════════════════════
// STATION SETTINGS TAB — Full configuration panel
// ══════════════════════════════════════════════════════════

class StationSettingsTab extends ConsumerStatefulWidget {
  final StationDto station;
  const StationSettingsTab({super.key, required this.station});
  @override
  ConsumerState<StationSettingsTab> createState() => _StationSettingsTabState();
}

class _StationSettingsTabState extends ConsumerState<StationSettingsTab> {
  // Controllers
  late final TextEditingController _nameC;
  late final TextEditingController _addressC;
  late final TextEditingController _address2C;
  late final TextEditingController _cityC;
  late final TextEditingController _pinC;
  late final TextEditingController _phoneC;
  late final TextEditingController _emailC;
  late final TextEditingController _contactNameC;
  late final TextEditingController _capacityC;
  late final TextEditingController _thresholdC;
  late final TextEditingController _descC;

  // State
  String _stationType = 'automated';
  String _automationMode = 'Automated';
  String _selectedState = 'Andhra Pradesh';
  bool _is24x7 = false;
  bool _basicModified = false;
  bool _locationModified = false;
  bool _opsModified = false;

  // Notification toggles
  final Map<String, bool> _notifs = {
    'low_stock': true,
    'fault': true,
    'offline': true,
    'utilization': false,
    'maintenance': true,
    'email': true,
    'sms': false,
  };

  // Expanded notification configs
  final Set<String> _expandedNotifs = {};

  // Operating hours
  final Map<String, bool> _dayOpen = {
    'Monday': true,
    'Tuesday': true,
    'Wednesday': true,
    'Thursday': true,
    'Friday': true,
    'Saturday': true,
    'Sunday': false,
  };

  final Map<String, List<String>> _dayTimes = {
    'Monday': ['08:00', '22:00'],
    'Tuesday': ['08:00', '22:00'],
    'Wednesday': ['08:00', '22:00'],
    'Thursday': ['08:00', '22:00'],
    'Friday': ['08:00', '22:00'],
    'Saturday': ['08:00', '22:00'],
    'Sunday': ['08:00', '22:00'],
  };

  bool _isSaving = false;

  StationDto get s => widget.station;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: s.name);
    _addressC = TextEditingController(text: s.address);
    _address2C = TextEditingController();
    _cityC = TextEditingController(text: s.city);
    _pinC = TextEditingController(text: s.pinCode ?? '');
    _phoneC = TextEditingController(text: s.contactPhone ?? '');
    _emailC = TextEditingController(text: s.contactEmail ?? '');
    _contactNameC = TextEditingController(text: s.contactName ?? '');
    _capacityC = TextEditingController(
        text: '${s.maxCapacity > 0 ? s.maxCapacity : s.totalSlots}');
    _thresholdC =
        TextEditingController(text: s.lowStockThreshold.toStringAsFixed(0));
    _descC = TextEditingController(text: s.description ?? '');
    _stationType = s.stationType;
    _automationMode = s.automationMode ?? 'Automated';
    _is24x7 = s.is24x7;
  }

  @override
  void dispose() {
    for (final c in [
      _nameC,
      _addressC,
      _address2C,
      _cityC,
      _pinC,
      _phoneC,
      _emailC,
      _contactNameC,
      _capacityC,
      _thresholdC,
      _descC
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _basicInfoSection(),
      const SizedBox(height: 28),
      _locationSection(),
      const SizedBox(height: 28),
      _operationalConfigSection(),
      const SizedBox(height: 28),
      _notificationSection(),
      const SizedBox(height: 28),
      _dangerZoneSection(),
    ]);
  }

  // ═════════════════════════════════════════════════
  // SECTION 1 — BASIC INFORMATION
  // ═════════════════════════════════════════════════
  Widget _basicInfoSection() {
    return _section('Basic Information', LucideIcons.info, children: [
      Row(children: [
        Expanded(
            child: _editableField(_nameC, 'Station Name', LucideIcons.building,
                onChanged: () => setState(() => _basicModified = true))),
        const SizedBox(width: 12),
        Expanded(
            child: _dropdownField(
          'Station Type',
          _stationType,
          ['automated', 'Hub', 'Express', 'Point', 'Kiosk'],
          (v) => setState(() {
            _stationType = v;
            _basicModified = true;
          }),
        )),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: _readOnlyField(
                'Station Code', s.stationCode ?? 'STN-${s.id}',
                isMono: true)),
        const SizedBox(width: 12),
        Expanded(child: _automationToggle()),
      ]),
      const SizedBox(height: 12),
      _editableField(_descC, 'Description', LucideIcons.fileText,
          maxLines: 3, onChanged: () => setState(() => _basicModified = true)),
      if (_basicModified)
        _saveDiscardRow(() => _save('Basic information'),
            () => setState(() => _basicModified = false)),
    ]);
  }

  Widget _automationToggle() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.pageBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          const Icon(LucideIcons.cpu, size: 14, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          const Expanded(
              child: Text('Automation Mode',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textTertiary))),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _togglePill(
                  'Automated',
                  _automationMode == 'Automated',
                  () => setState(() {
                        _automationMode = 'Automated';
                        _basicModified = true;
                      })),
              _togglePill(
                  'Staffed',
                  _automationMode == 'Staffed',
                  () => setState(() {
                        _automationMode = 'Staffed';
                        _basicModified = true;
                      })),
            ]),
          ),
        ]),
      );

  Widget _togglePill(String text, bool active, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? AppColors.primary : AppColors.textMuted,
              )),
        ),
      );

  // ═════════════════════════════════════════════════
  // SECTION 2 — LOCATION
  // ═════════════════════════════════════════════════
  Widget _locationSection() {
    return _section('Location', LucideIcons.mapPin, children: [
      _editableField(_addressC, 'Address Line 1', LucideIcons.home,
          onChanged: () => setState(() => _locationModified = true)),
      const SizedBox(height: 12),
      _editableField(_address2C, 'Address Line 2 (optional)', LucideIcons.home,
          onChanged: () => setState(() => _locationModified = true)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: _editableField(_cityC, 'City', LucideIcons.building2,
                onChanged: () => setState(() => _locationModified = true))),
        const SizedBox(width: 12),
        Expanded(
            child: _dropdownField(
          'State',
          _selectedState,
          [
            'Andhra Pradesh',
            'Telangana',
            'Karnataka',
            'Tamil Nadu',
            'Kerala',
            'Maharashtra'
          ],
          (v) => setState(() {
            _selectedState = v;
            _locationModified = true;
          }),
        )),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: _editableField(_pinC, 'PIN Code', LucideIcons.hash,
                onChanged: () => setState(() => _locationModified = true))),
        const SizedBox(width: 12),
        const Expanded(child: SizedBox.shrink()),
      ]),
      const SizedBox(height: 16),

      // Map placeholder
      Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.pageBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(children: [
          Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.map, size: 32, color: AppColors.textMuted),
            const SizedBox(height: 8),
            Text(
                '${s.latitude.toStringAsFixed(4)}, ${s.longitude.toStringAsFixed(4)}',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    fontFamily: 'monospace')),
          ])),
          Positioned(
              bottom: 8,
              right: 8,
              child: ElevatedButton.icon(
                icon: const Icon(LucideIcons.move, size: 12),
                label: const Text('Reposition', style: TextStyle(fontSize: 10)),
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardBg,
                  foregroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
              )),
        ]),
      ),
      const SizedBox(height: 16),

      // Contact
      Row(children: [
        Expanded(
            child: _editableField(
                _contactNameC, 'Contact Name', LucideIcons.user,
                onChanged: () => setState(() => _locationModified = true))),
        const SizedBox(width: 12),
        Expanded(
            child: _editableField(_phoneC, 'Contact Phone', LucideIcons.phone,
                onChanged: () => setState(() => _locationModified = true))),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: _editableField(_emailC, 'Contact Email', LucideIcons.mail,
                onChanged: () => setState(() => _locationModified = true))),
        const Expanded(child: SizedBox.shrink()),
      ]),
      if (_locationModified)
        _saveDiscardRow(() => _save('Location'),
            () => setState(() => _locationModified = false)),
    ]);
  }

  // ═════════════════════════════════════════════════
  // SECTION 3 — OPERATIONAL CONFIGURATION
  // ═════════════════════════════════════════════════
  Widget _operationalConfigSection() {
    return _section('Operational Configuration', LucideIcons.sliders,
        children: [
          // Capacity + threshold
          Row(children: [
            Expanded(
                child: _numberStepper(
              _capacityC,
              'Max Battery Capacity',
              'You cannot register more than this number of batteries.',
              () => setState(() => _opsModified = true),
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _numberStepper(
              _thresholdC,
              'Low Stock Alert Threshold',
              'Alert triggers when available batteries drop below this number.',
              () => setState(() => _opsModified = true),
            )),
          ]),
          const SizedBox(height: 6),
          Text(
              'Currently ${s.availableBatteries} of ${_capacityC.text} registered',
              style:
                  const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
          const SizedBox(height: 20),

          // 24/7 toggle
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _is24x7
                  ? AppColors.primary.withValues(alpha: 0.04)
                  : AppColors.pageBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: _is24x7
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.border),
            ),
            child: Row(children: [
              Icon(LucideIcons.clock,
                  size: 16,
                  color: _is24x7 ? AppColors.primary : AppColors.textTertiary),
              const SizedBox(width: 10),
              const Expanded(
                  child: Text('24/7 Operation',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary))),
              Switch(
                value: _is24x7,
                onChanged: (v) => setState(() {
                  _is24x7 = v;
                  _opsModified = true;
                }),
                activeColor: AppColors.primary,
              ),
            ]),
          ),
          const SizedBox(height: 14),

          // Weekly schedule
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _is24x7 ? 0.3 : 1.0,
            child: IgnorePointer(
              ignoring: _is24x7,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.pageBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(children: [
                  if (_is24x7)
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Open all day, every day',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.primary)),
                    )
                  else ...[
                    ..._dayOpen.entries.map((e) => _dayRow(e.key, e.value)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(() {
                        for (final d in [
                          'Tuesday',
                          'Wednesday',
                          'Thursday',
                          'Friday'
                        ]) {
                          _dayOpen[d] = _dayOpen['Monday']!;
                          _dayTimes[d] = List.from(_dayTimes['Monday']!);
                        }
                        _opsModified = true;
                      }),
                      child: const Text('Copy Mon hours to all weekdays',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ]),
              ),
            ),
          ),
          if (_opsModified)
            _saveDiscardRow(() => _save('Operational config'),
                () => setState(() => _opsModified = false)),
        ]);
  }

  Widget _dayRow(String day, bool isOpen) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          SizedBox(
              width: 80,
              child: Text(day,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textTertiary))),
          Switch(
            value: isOpen,
            onChanged: (v) => setState(() {
              _dayOpen[day] = v;
              _opsModified = true;
            }),
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 8),
          if (isOpen) ...[
            _timeChip(day, 0),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text('—', style: TextStyle(color: AppColors.textMuted))),
            _timeChip(day, 1),
          ] else
            const Text('Closed',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.red,
                    fontWeight: FontWeight.w500)),
        ]),
      );

  Widget _timeChip(String day, int index) {
    final timeStr = _dayTimes[day]![index];
    return GestureDetector(
      onTap: () async {
        final pts = timeStr.split(':');
        final initTime =
            TimeOfDay(hour: int.parse(pts[0]), minute: int.parse(pts[1]));
        final picked =
            await showTimePicker(context: context, initialTime: initTime);
        if (picked != null) {
          setState(() {
            _dayTimes[day]![index] =
                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
            _opsModified = true;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(timeStr,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ),
    );
  }

  // ═════════════════════════════════════════════════
  // SECTION 4 — NOTIFICATION SETTINGS
  // ═════════════════════════════════════════════════
  Widget _notificationSection() {
    return _section('Notification Settings', LucideIcons.bell, children: [
      _notifRow('low_stock', 'Low Battery Stock Alert',
          'Get notified when available batteries drop below threshold',
          hasConfig: true, configWidget: _thresholdConfig()),
      _notifRow('fault', 'Battery Fault Detected',
          'Alert when a battery fault is detected at this station'),
      _notifRow('offline', 'Station Offline Alert',
          'Notify when station goes offline',
          hasConfig: true, configWidget: _offlineDurationConfig()),
      _notifRow('utilization', 'High Utilization Warning',
          'Alert at high utilization rates',
          hasConfig: true, configWidget: _utilizationConfig()),
      _notifRow('maintenance', 'Maintenance Due Reminder',
          'Remind before scheduled maintenance'),
      const SizedBox(height: 16),
      Container(height: 1, color: AppColors.border),
      const SizedBox(height: 16),
      const Text('Delivery Channels',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary)),
      const SizedBox(height: 8),
      _channelToggle('email', 'Email Notifications', LucideIcons.mail),
      _channelToggle('sms', 'SMS Notifications', LucideIcons.messageSquare),
    ]);
  }

  Widget _notifRow(String key, String title, String desc,
      {bool hasConfig = false, Widget? configWidget}) {
    final isExpanded = _expandedNotifs.contains(key);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: _notifs[key]!
            ? AppColors.primary.withValues(alpha: 0.02)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(children: [
            if (hasConfig)
              GestureDetector(
                onTap: () => setState(() {
                  if (isExpanded)
                    _expandedNotifs.remove(key);
                  else
                    _expandedNotifs.add(key);
                }),
                child: Icon(
                    isExpanded
                        ? LucideIcons.chevronDown
                        : LucideIcons.chevronRight,
                    size: 14,
                    color: AppColors.textMuted),
              ),
            if (!hasConfig) const SizedBox(width: 14),
            const SizedBox(width: 4),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textPrimary)),
                  Text(desc,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textTertiary)),
                ])),
            Switch(
              value: _notifs[key]!,
              onChanged: (v) => setState(() => _notifs[key] = v),
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ]),
        ),
        if (isExpanded && hasConfig && configWidget != null)
          Padding(
            padding: const EdgeInsets.only(left: 32, right: 12, bottom: 8),
            child: configWidget,
          ),
      ]),
    );
  }

  Widget _thresholdConfig() => Row(children: [
        const Text('Threshold: ',
            style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        SizedBox(
            width: 60,
            child: TextField(
              controller: _thresholdC,
              keyboardType: TextInputType.number,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.pageBg,
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppColors.border)),
              ),
            )),
        const Text(' batteries',
            style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
      ]);

  Widget _offlineDurationConfig() => Row(children: [
        const Text('Notify after offline for: ',
            style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        SizedBox(
            width: 50,
            child: TextField(
              controller: TextEditingController(text: '30'),
              keyboardType: TextInputType.number,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.pageBg,
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppColors.border)),
              ),
            )),
        const Text(' minutes',
            style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
      ]);

  Widget _utilizationConfig() => Row(children: [
        const Text('Warn above: ',
            style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        SizedBox(
            width: 50,
            child: TextField(
              controller: TextEditingController(text: '90'),
              keyboardType: TextInputType.number,
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.pageBg,
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppColors.border)),
              ),
            )),
        const Text(' % utilization',
            style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
      ]);

  Widget _channelToggle(String key, String label, IconData icon) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: [
          Icon(icon, size: 14, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textPrimary))),
          Switch(
            value: _notifs[key]!,
            onChanged: (v) => setState(() => _notifs[key] = v),
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ]),
      );

  // ═════════════════════════════════════════════════
  // SECTION 5 — DANGER ZONE
  // ═════════════════════════════════════════════════
  Widget _dangerZoneSection() {
    final hasBatteries = (s.availableBatteries +
            s.ongoingRentals +
            s.chargingBatteries +
            s.faultyBatteries) >
        0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(LucideIcons.alertTriangle, size: 16, color: AppColors.red),
          const SizedBox(width: 8),
          const Text('Danger Zone',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.red)),
        ]),
        const SizedBox(height: 20),

        // Maintenance mode
        _dangerAction(
          'Put in Maintenance Mode',
          'Station will show as under maintenance. No new rentals or swaps can be initiated.',
          'Enter Maintenance Mode',
          AppColors.amber,
          LucideIcons.wrench,
          () => _showMaintenanceModal(),
        ),
        Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 14),
            color: AppColors.red.withValues(alpha: 0.1)),

        // Take offline
        _dangerAction(
          'Take Station Offline',
          'Station will be completely offline. Active rentals continue but no new rentals can start.',
          'Take Offline',
          AppColors.red,
          LucideIcons.powerOff,
          () => _showOfflineModal(),
        ),
        Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 14),
            color: AppColors.red.withValues(alpha: 0.1)),

        // Decommission
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Decommission Station',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.red)),
          const SizedBox(height: 4),
          const Text(
              'This action permanently removes the station from your account. Batteries must be transferred or retired first.',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.red,
                  fontWeight: FontWeight.w500)),
          if (hasBatteries) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.amber.withValues(alpha: 0.15)),
              ),
              child: Row(children: [
                const Icon(LucideIcons.alertCircle,
                    size: 14, color: AppColors.amber),
                const SizedBox(width: 8),
                Text(
                    'You still have ${s.availableBatteries + s.ongoingRentals + s.chargingBatteries + s.faultyBatteries} batteries registered.',
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.amber)),
              ]),
            ),
          ],
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(LucideIcons.trash2, size: 13),
            label: const Text('Decommission Station',
                style: TextStyle(fontSize: 12)),
            onPressed: hasBatteries ? null : () => _showDecommissionModal(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.red,
              side: BorderSide(
                  color: hasBatteries ? AppColors.textMuted : AppColors.red),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _dangerAction(String title, String desc, String btnText, Color color,
      IconData icon, VoidCallback onTap) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(desc,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
      ])),
      const SizedBox(width: 16),
      OutlinedButton.icon(
        icon: Icon(icon, size: 13),
        label: Text(btnText, style: const TextStyle(fontSize: 11)),
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ]);
  }

  // ── Modals ──
  void _showMaintenanceModal() {
    final reasonC = TextEditingController();
    showDialog(
        context: context,
        builder: (ctx) => Dialog(
              backgroundColor: AppColors.cardBg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                  width: 420,
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Row(children: [
                      Icon(LucideIcons.wrench,
                          size: 18, color: AppColors.amber),
                      const SizedBox(width: 8),
                      const Text('Enter Maintenance Mode',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                    ]),
                    const SizedBox(height: 16),
                    TextField(
                      controller: reasonC,
                      maxLines: 2,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                          labelText: 'Maintenance Reason',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showToast(
                              'Station in maintenance mode', AppColors.amber);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.amber),
                        child: const Text('Confirm'),
                      ),
                    ]),
                  ])),
            ));
  }

  void _showOfflineModal() {
    showDialog(
        context: context,
        builder: (ctx) => Dialog(
              backgroundColor: AppColors.cardBg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                  width: 420,
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Row(children: [
                      const Icon(LucideIcons.powerOff,
                          size: 18, color: AppColors.red),
                      const SizedBox(width: 8),
                      const Text('Take Station Offline',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.red)),
                    ]),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      dropdownColor: AppColors.cardBg,
                      decoration: const InputDecoration(
                          labelText: 'Reason', border: OutlineInputBorder()),
                      items: [
                        'Technical Issue',
                        'No Stock',
                        'Relocation',
                        'Other'
                      ]
                          .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r,
                                  style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 12),
                    const TextField(
                        maxLines: 2,
                        decoration: InputDecoration(
                            labelText: 'Brief Note',
                            border: OutlineInputBorder())),
                    const SizedBox(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showToast('Station taken offline', AppColors.red);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red),
                        child: const Text('Take Offline'),
                      ),
                    ]),
                  ])),
            ));
  }

  void _showDecommissionModal() {
    final confirmC = TextEditingController();
    showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
            builder: (ctx, setD) => Dialog(
                  backgroundColor: AppColors.cardBg,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Container(
                      width: 420,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(LucideIcons.alertTriangle,
                                  size: 18, color: AppColors.red),
                              const SizedBox(width: 8),
                              const Text('Decommission Station',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.red)),
                            ]),
                            const SizedBox(height: 16),
                            Text(
                                'Type the station code "${s.stationCode ?? 'STN-${s.id}'}" to confirm:',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary)),
                            const SizedBox(height: 10),
                            TextField(
                              controller: confirmC,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'monospace'),
                              decoration: InputDecoration(
                                  hintText: s.stationCode ?? 'STN-${s.id}',
                                  border: const OutlineInputBorder()),
                              onChanged: (_) => setD(() {}),
                            ),
                            const SizedBox(height: 16),
                            const Text('⚠️ This action cannot be undone.',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.red)),
                            const SizedBox(height: 16),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel')),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: confirmC.text ==
                                            (s.stationCode ?? 'STN-${s.id}')
                                        ? () {
                                            Navigator.pop(ctx);
                                            _showToast('Station decommissioned',
                                                AppColors.red);
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.red),
                                    child: const Text('Decommission'),
                                  ),
                                ]),
                          ])),
                )));
  }

  // ═════════════════════════════════════════════════
  // SHARED HELPERS
  // ═════════════════════════════════════════════════
  Widget _section(String title, IconData icon,
      {required List<Widget> children}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 0.3)),
      ]),
      const SizedBox(height: 4),
      Container(height: 1, color: AppColors.border),
      const SizedBox(height: 16),
      ...children,
    ]);
  }

  Widget _editableField(TextEditingController c, String label, IconData icon,
      {int maxLines = 1, VoidCallback? onChanged}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      onChanged: (_) => onChanged?.call(),
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: AppColors.textTertiary, fontSize: 12),
        prefixIcon: Icon(icon, size: 15, color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.pageBg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
    );
  }

  Widget _readOnlyField(String label, String value, {bool isMono = false}) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.pageBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          const Icon(LucideIcons.lock, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textTertiary)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isMono ? AppColors.cyan : AppColors.textPrimary,
                  fontFamily: isMono ? 'monospace' : null,
                )),
          ]),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              _showToast('Copied!', AppColors.primary);
            },
            child: const Icon(LucideIcons.copy,
                size: 13, color: AppColors.textMuted),
          ),
        ]),
      );

  Widget _dropdownField(String label, String value, List<String> items,
      Function(String) onChanged) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : items.first,
      dropdownColor: AppColors.cardBg,
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: AppColors.textTertiary, fontSize: 12),
        filled: true,
        fillColor: AppColors.pageBg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
      items:
          items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }

  Widget _numberStepper(TextEditingController c, String label, String helper,
      VoidCallback onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(
        controller: c,
        keyboardType: TextInputType.number,
        onChanged: (_) => onChanged(),
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(color: AppColors.textTertiary, fontSize: 12),
          filled: true,
          fillColor: AppColors.pageBg,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(
              icon: const Icon(LucideIcons.minus, size: 14),
              iconSize: 14,
              onPressed: () {
                final v = int.tryParse(c.text) ?? 0;
                c.text = '${(v - 1).clamp(1, 999)}';
                onChanged();
              },
            ),
            IconButton(
              icon: const Icon(LucideIcons.plus, size: 14),
              iconSize: 14,
              onPressed: () {
                final v = int.tryParse(c.text) ?? 0;
                c.text = '${v + 1}';
                onChanged();
              },
            ),
          ]),
        ),
      ),
      const SizedBox(height: 4),
      Text(helper,
          style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
    ]);
  }

  Widget _saveDiscardRow(VoidCallback onSave, VoidCallback onDiscard) =>
      Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          GestureDetector(
            onTap: _isSaving ? null : onDiscard,
            child: Text('Discard',
                style: TextStyle(
                    fontSize: 12,
                    color: _isSaving
                        ? AppColors.textMuted
                        : AppColors.textTertiary,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 14),
          ElevatedButton.icon(
            icon: _isSaving
                ? const SizedBox(
                    width: 13,
                    height: 13,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(LucideIcons.save, size: 13),
            label: Text(_isSaving ? 'Saving...' : 'Save Changes',
                style: const TextStyle(fontSize: 12)),
            onPressed: _isSaving ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ]),
      );

  Future<void> _save(String section) async {
    setState(() => _isSaving = true);
    try {
      final dio = ref.read(dioProvider);

      // Build payload based on modified section
      final payload = <String, dynamic>{};
      if (section.contains('Basic')) {
        payload['name'] = _nameC.text;
      }
      if (section.contains('Location')) {
        payload['address'] = _addressC.text;
        payload['contact_phone'] = _phoneC.text;
      }
      if (section.contains('Operational')) {
        payload['is_24x7'] = _is24x7;
        payload['total_slots'] = int.tryParse(_capacityC.text) ?? s.totalSlots;

        // Build JSON representation of hours
        final hoursMap = <String, dynamic>{};
        for (final entry in _dayOpen.entries) {
          hoursMap[entry.key] = {
            'is_open': entry.value,
            'open_time': _dayTimes[entry.key]![0],
            'close_time': _dayTimes[entry.key]![1],
          };
        }
        payload['operating_hours'] = jsonEncode(hoursMap);
      }

      await dio.put('${ApiConstants.dealerStationBase}/${s.id}', data: payload);

      _showToast('$section saved successfully', AppColors.primary);
      setState(() {
        _basicModified = false;
        _locationModified = false;
        _opsModified = false;
      });
    } catch (e) {
      final message = ApiResponse.errorMessage(
        e,
        fallback: 'Failed to save station settings',
      );
      _showToast('Failed to save: $message', AppColors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
    ));
  }
}
