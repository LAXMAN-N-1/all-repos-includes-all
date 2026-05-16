
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/colors.dart';
import '../models/station_state.dart';
import '../providers/station_detail_provider.dart';
import '../widgets/station_health_gauge.dart';
import '../../../core/utils/time_utils.dart';

// ══════════════════════════════════════════════════════════
// STATION OVERVIEW TAB — Premium two-column dashboard
// ══════════════════════════════════════════════════════════

class StationOverviewTab extends ConsumerStatefulWidget {
  final StationDto station;
  final Function(int tabIndex)? onTabChange;

  const StationOverviewTab({super.key, required this.station, this.onTabChange});

  @override
  ConsumerState<StationOverviewTab> createState() => _StationOverviewTabState();
}

class _StationOverviewTabState extends ConsumerState<StationOverviewTab> with SingleTickerProviderStateMixin {
  late AnimationController _entryAnim;
  bool _alertsExpanded = true;

  StationDto get s => widget.station;

  @override
  void initState() {
    super.initState();
    _entryAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
  }

  @override
  void dispose() { _entryAnim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _entryAnim,
      builder: (_, __) => Opacity(
        opacity: _entryAnim.value,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Alerts Panel (if active alerts) ──
          if (s.faultyBatteries > 0 || s.status.toUpperCase() == 'OFFLINE')
            _alertsPanel(),

          // ── Two-Column Layout ──
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Left column (58%)
            Expanded(flex: 58, child: Column(children: [
              _batteryDistributionCard(),
              const SizedBox(height: 14),
              _liveActivityFeedCard(),
              const SizedBox(height: 14),
              _recentTransactionsCard(),
            ])),

            const SizedBox(width: 16),

            // Right column (42%)
            Expanded(flex: 42, child: Column(children: [
              _healthScoreCard(),
              const SizedBox(height: 14),
              _operatingHoursCard(),
              const SizedBox(height: 14),
              _stationInfoCard(),
            ])),
          ]),
        ]),
      ),
    );
  }

  // ═════════════════════════════════════════════════
  // ALERTS PANEL
  // ═════════════════════════════════════════════════
  Widget _alertsPanel() {
    final alerts = <Map<String, dynamic>>[];
    if (s.status.toUpperCase() == 'OFFLINE') {
      alerts.add({'severity': 'critical', 'type': 'Station Offline', 'message': 'Station has been offline', 'time': '3h 42m ago'});
    }
    if (s.faultyBatteries > 0) {
      alerts.add({'severity': 'warning', 'type': 'Battery Fault', 'message': '${s.faultyBatteries} batteries with faults detected', 'time': '1h ago'});
    }
    if (s.availableBatteries <= s.lowStockThreshold) {
      alerts.add({'severity': 'warning', 'type': 'Low Stock', 'message': 'Available batteries below threshold (${s.availableBatteries}/${s.lowStockThreshold.toInt()})', 'time': '30m ago'});
    }

    if (alerts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.25)),
      ),
      child: Column(children: [
        // Header
        InkWell(
          onTap: () => setState(() => _alertsExpanded = !_alertsExpanded),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Icon(LucideIcons.bellRing, size: 16, color: AppColors.amber),
              const SizedBox(width: 8),
              const Text('Active Alerts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.amber)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                child: Text('${alerts.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.amber)),
              ),
              const Spacer(),
              Icon(_alertsExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 16, color: AppColors.amber),
            ]),
          ),
        ),
        if (_alertsExpanded) ...[
          const Divider(height: 1, color: AppColors.border),
          ...alerts.map((a) => _alertRow(a)),
          Padding(
            padding: const EdgeInsets.only(left: 14, bottom: 10),
            child: GestureDetector(
              onTap: () {},
              child: const Text('View All Alerts →', style: TextStyle(fontSize: 11, color: AppColors.amber, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _alertRow(Map<String, dynamic> a) {
    final isCritical = a['severity'] == 'critical';
    final color = isCritical ? AppColors.red : AppColors.amber;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(children: [
        Icon(isCritical ? LucideIcons.alertTriangle : LucideIcons.alertCircle, size: 14, color: color),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
          child: Text(a['type'], style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(a['message'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        Text(a['time'], style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        const SizedBox(width: 10),
        _miniButton('Resolve', color),
      ]),
    );
  }

  // ═════════════════════════════════════════════════
  // BATTERY STATUS DISTRIBUTION
  // ═════════════════════════════════════════════════
  Widget _batteryDistributionCard() {
    final total = s.availableBatteries + s.ongoingRentals + s.chargingBatteries + s.faultyBatteries;
    final categories = [
      _BatteryCat('Available', s.availableBatteries, AppColors.primary, LucideIcons.batteryFull),
      _BatteryCat('Rented', s.ongoingRentals, AppColors.cyan, LucideIcons.userCheck),
      _BatteryCat('Charging', s.chargingBatteries, AppColors.amber, LucideIcons.zap),
      _BatteryCat('Faulty', s.faultyBatteries, AppColors.red, LucideIcons.alertTriangle),
    ];

    return _card('Battery Status Distribution', child: Column(children: [
      const SizedBox(height: 8),
      // Segmented bar
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(height: 14, child: Row(
          children: total == 0
              ? [Expanded(child: Container(color: AppColors.border))]
              : categories.where((c) => c.count > 0).map((c) =>
                  Expanded(
                    flex: (c.count / total * 100).round().clamp(1, 100),
                    child: Tooltip(
                      message: '${c.label}: ${c.count} (${(c.count / total * 100).toStringAsFixed(0)}%)',
                      child: Container(
                        color: c.color,
                        margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      ),
                    ),
                  ),
                ).toList(),
        )),
      ),
      const SizedBox(height: 16),

      // Legend chips (clickable)
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: categories.map((c) {
        final pct = total > 0 ? (c.count / total * 100).toStringAsFixed(0) : '0';
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => widget.onTabChange?.call(1), // Go to Batteries tab
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: c.color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: c.color.withValues(alpha: 0.12)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(c.icon, size: 12, color: c.color),
                const SizedBox(width: 6),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c.label, style: TextStyle(fontSize: 10, color: c.color, fontWeight: FontWeight.w600)),
                  Text('${c.count} ($pct%)', style: const TextStyle(fontSize: 9, color: AppColors.textTertiary)),
                ]),
              ]),
            ),
          ),
        );
      }).toList()),

      const SizedBox(height: 12),
      // Summary line
      Text(
        '${s.availableBatteries} of $total batteries available · ${s.ongoingRentals} rented · ${s.chargingBatteries} charging · ${s.faultyBatteries} faulty',
        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
      ),
    ]));
  }

  // ═════════════════════════════════════════════════
  // LIVE ACTIVITY FEED
  // ═════════════════════════════════════════════════
  Widget _liveActivityFeedCard() {
    final activityAsync = ref.watch(stationActivityProvider(s.id));

    return _card(null, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('Live Activity Feed', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const Spacer(),
        _pulsingLiveDot(),
      ]),
      const SizedBox(height: 14),

      activityAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No recent activity', style: TextStyle(color: AppColors.textMuted))),
            );
          }
          final displayList = activities.take(7).toList();
          return Column(
            children: displayList.asMap().entries.map((entry) {
              final e = entry.value;
              return TweenAnimationBuilder<double>(
                key: ValueKey('activity_${e.id}'),
                tween: Tween(begin: entry.key < 2 ? 0.0 : 1.0, end: 1.0),
                duration: Duration(milliseconds: 300 + entry.key * 100),
                curve: Curves.easeOut,
                builder: (_, val, child) => Opacity(opacity: val, child: Transform.translate(offset: Offset(0, (1 - val) * -8), child: child)),
                child: _activityRow(e),
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(strokeWidth: 2))),
        error: (err, _) => const Padding(padding: EdgeInsets.all(10), child: Text('Failed to load activity', style: TextStyle(color: AppColors.red))),
      ),

      const SizedBox(height: 8),
      GestureDetector(
        onTap: () => widget.onTabChange?.call(2), // Go to Swaps Activity tab
        child: const Text('View All Activity →', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
      ),
    ]));
  }

  Widget _activityRow(ActivityEventDto e) {
    final color = switch (e.eventType) {
      'completed' || 'return' => AppColors.primary,
      'rental' || 'start' => AppColors.cyan,
      'warning' || 'low_stock' => AppColors.amber,
      'fault' || 'alert' => AppColors.red,
      _ => AppColors.textSecondary,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.06)),
      ),
      child: Row(children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(
          color: color, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 4)],
        )),
        const SizedBox(width: 10),
        Expanded(child: Text(e.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3))),
        Text(_timeAgo(e.createdAt), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ]),
    );
  }

  // ═════════════════════════════════════════════════
  // RECENT TRANSACTIONS
  // ═════════════════════════════════════════════════
  Widget _recentTransactionsCard() {
    final txAsync = ref.watch(stationTransactionsProvider(s.id));

    return _card('Recent Transactions', child: Column(children: [
      txAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No recent transactions', style: TextStyle(color: AppColors.textMuted))),
            );
          }
          return Column(
            children: transactions.take(5).map((t) => _transactionRow(t)).toList(),
          );
        },
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(strokeWidth: 2))),
        error: (err, _) => const Padding(padding: EdgeInsets.all(10), child: Text('Failed to load transactions', style: TextStyle(color: AppColors.red))),
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: () => widget.onTabChange?.call(4), // Go to Analytics tab
        child: const Text('View All in Analytics →', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
      ),
    ]));
  }

  Widget _transactionRow(TransactionDto t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Container(
        width: 30, height: 30,
        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: const Icon(LucideIcons.indianRupee, size: 13, color: AppColors.primary),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('₹${t.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.amber)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: AppColors.cyan.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(t.type, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.cyan)),
          ),
        ]),
        Text(t.customer, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
      ])),
      Text(_timeAgo(t.time), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
    ]),
  );

  // ═════════════════════════════════════════════════
  // HEALTH SCORE
  // ═════════════════════════════════════════════════
  Widget _healthScoreCard() {
    final score = _computeHealthScore();
    final factors = [
      {'name': 'Battery Health Avg', 'value': '98.5%', 'fraction': 0.985},
      {'name': 'Utilization Rate', 'value': '${s.utilizationPercent.toStringAsFixed(0)}%', 'fraction': s.utilizationPercent / 100},
      {'name': 'Alert Count (inv)', 'value': '${s.faultyBatteries} faults', 'fraction': 1.0 - (s.faultyBatteries / 10).clamp(0.0, 1.0)},
      {'name': 'Rating', 'value': s.rating.toStringAsFixed(1), 'fraction': s.rating / 5.0},
    ];

    return _card('Station Health Score', child: Column(children: [
      const SizedBox(height: 8),
      Center(child: StationHealthGauge(score: score, size: 160)),
      const SizedBox(height: 16),
      const Text('Health Score', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
      const SizedBox(height: 16),
      // Contributing factors
      ...factors.map((f) => _healthFactor(f['name'] as String, f['value'] as String, f['fraction'] as double)),
    ]));
  }

  Widget _healthFactor(String name, String value, double fraction) {
    final color = fraction > 0.7 ? AppColors.primary : fraction > 0.4 ? AppColors.amber : AppColors.red;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(name, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary))),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ]),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(height: 4, child: LinearProgressIndicator(
            value: fraction.clamp(0.0, 1.0),
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(color),
          )),
        ),
      ]),
    );
  }

  // ═════════════════════════════════════════════════
  // OPERATING HOURS
  // ═════════════════════════════════════════════════
  Widget _operatingHoursCard() {
    return _card(null, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('Operating Hours', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const Spacer(),
        GestureDetector(
          onTap: () => widget.onTabChange?.call(5), // Go to Settings tab
          child: const Text('Edit Hours', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
        ),
      ]),
      const SizedBox(height: 14),
      if (s.is24x7) ...[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
          ),
          child: Row(children: [
            Icon(LucideIcons.checkCircle, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Open 24 hours, 7 days a week', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ]),
        ),
      ] else ...[
        _hourRow('Monday', '08:00 — 22:00', true),
        _hourRow('Tuesday', '08:00 — 22:00', true),
        _hourRow('Wednesday', '08:00 — 22:00', true),
        _hourRow('Thursday', '08:00 — 22:00', true),
        _hourRow('Friday', '08:00 — 22:00', true),
        _hourRow('Saturday', '09:00 — 20:00', true),
        _hourRow('Sunday', 'Closed', false),
      ],
    ]));
  }

  Widget _hourRow(String day, String time, bool isOpen) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      SizedBox(width: 80, child: Text(day, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary))),
      const Spacer(),
      Text(time, style: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600,
        color: isOpen ? AppColors.textPrimary : AppColors.red,
      )),
    ]),
  );

  // ═════════════════════════════════════════════════
  // STATION INFO
  // ═════════════════════════════════════════════════
  Widget _stationInfoCard() {
    return _card('Station Details', child: Column(children: [
      _detailRow('Station Code', s.stationCode ?? 'STN-${s.id}', isMono: true, copyable: true),
      _detailDivider(),
      _detailRow('Type', s.stationType, isBadge: true),
      _detailDivider(),
      _detailRow('Address', s.city.isNotEmpty ? '${s.address}, ${s.city}' : s.address, copyable: true),
      if (s.city.isNotEmpty) ...[_detailDivider(), _detailRow('City', s.city)],
      if (s.pinCode != null) ...[_detailDivider(), _detailRow('PIN Code', s.pinCode!)],
      if (s.contactName != null) ...[_detailDivider(), _detailRow('Contact', s.contactName!)],
      if (s.contactPhone != null) ...[_detailDivider(), _detailRow('Phone', s.contactPhone!, isPhone: true)],
      _detailDivider(),
      _detailRow('Registered', _formatDate(s.createdAt)),
      _detailDivider(),
      _detailRow('Coordinates', '${s.latitude.toStringAsFixed(4)}, ${s.longitude.toStringAsFixed(4)}'),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: () async {
          final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${s.latitude},${s.longitude}');
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          }
        },
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(LucideIcons.mapPin, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          const Text('View on Map', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
        ]),
      ),
    ]));
  }

  Widget _detailRow(String label, String value, {bool isMono = false, bool isBadge = false, bool copyable = false, bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary))),
        Expanded(child: isBadge
            ? Row(children: [Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
              )])
            : Text(value, style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: isMono ? AppColors.cyan : isPhone ? AppColors.primary : AppColors.textPrimary,
                fontFamily: isMono ? 'monospace' : null,
              )),
        ),
        if (copyable)
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Copied to clipboard'), backgroundColor: AppColors.primary,
                duration: Duration(seconds: 1),
              ));
            },
            child: const Icon(LucideIcons.copy, size: 12, color: AppColors.textMuted),
          ),
      ]),
    );
  }

  Widget _detailDivider() => Container(height: 1, color: AppColors.border.withValues(alpha: 0.5));

  // ═════════════════════════════════════════════════
  // HELPERS
  // ═════════════════════════════════════════════════
  Widget _card(String? title, {required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.cardBg, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (title != null) ...[
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 14),
      ],
      child,
    ]),
  );

  Widget _pulsingLiveDot() => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.3, end: 1.0),
    duration: const Duration(milliseconds: 1200),
    builder: (_, val, __) => Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 6, height: 6, decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: val),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: val * 0.3), blurRadius: 4)],
      )),
      const SizedBox(width: 4),
      const Text('Live', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary)),
    ]),
  );

  Widget _miniButton(String text, Color color) => GestureDetector(
    onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Alert resolved'), backgroundColor: color)),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
    ),
  );

  double _computeHealthScore() {
    final batteryHealth = 0.985;
    final utilization = s.utilizationPercent / 100;
    final alertPenalty = 1.0 - (s.faultyBatteries / 10).clamp(0.0, 1.0);
    final ratingFactor = s.rating / 5.0;
    return ((batteryHealth * 30 + utilization * 25 + alertPenalty * 25 + ratingFactor * 20)).clamp(0, 100);
  }

  String _formatDate(String iso) => TimeUtils.dateOnly(iso);

  String _timeAgo(String isoStr) => TimeUtils.timeAgo(isoStr);
}

class _BatteryCat {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  _BatteryCat(this.label, this.count, this.color, this.icon);
}
