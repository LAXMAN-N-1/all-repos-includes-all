import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/export_helper.dart';
import '../models/station_state.dart';
import '../providers/station_detail_provider.dart';
import '../../../core/utils/time_utils.dart';

// ══════════════════════════════════════════════════════════
// STATION BATTERIES TAB — Enhanced inventory management
// ══════════════════════════════════════════════════════════

class StationBatteriesTab extends ConsumerStatefulWidget {
  final StationDto station;
  const StationBatteriesTab({super.key, required this.station});
  @override
  ConsumerState<StationBatteriesTab> createState() =>
      _StationBatteriesTabState();
}

class _StationBatteriesTabState extends ConsumerState<StationBatteriesTab> {
  String _activeFilter = 'All';
  String _searchQuery = '';
  int _selectedBatteryIndex = -1;
  int _page = 0;
  int _rowsPerPage = 25;
  final _searchC = TextEditingController();

  StationDto get s => widget.station;

  static const _filters = [
    _FilterDef('All', null, LucideIcons.layoutGrid, AppColors.textSecondary),
    _FilterDef(
        'available', 'Available', LucideIcons.batteryFull, AppColors.primary),
    _FilterDef('rented', 'Rented', LucideIcons.userCheck, AppColors.cyan),
    _FilterDef('charging', 'Charging', LucideIcons.zap, AppColors.amber),
    _FilterDef('maintenance', 'Maintenance', LucideIcons.wrench, AppColors.red),
    _FilterDef('retired', 'Retired', LucideIcons.history, AppColors.textMuted),
  ];

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final batteriesAsync = ref.watch(dealerBatteriesProvider(s.id));
    return batteriesAsync.when(
      data: (batteries) => _buildContent(batteries),
      loading: () => const Center(
          child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: AppColors.primary))),
      error: (e, _) => Center(
          child:
              Text('Error: $e', style: const TextStyle(color: AppColors.red))),
    );
  }

  Widget _buildContent(List<BatteryDto> allBatteries) {
    // Filter
    final filtered = _activeFilter == 'All'
        ? allBatteries
        : allBatteries.where((b) => b.status == _activeFilter).toList();
    final searched = _searchQuery.isEmpty
        ? filtered
        : filtered
            .where((b) => b.serialNumber.toLowerCase().contains(_searchQuery))
            .toList();

    // Paginate
    final totalPages = (searched.length / _rowsPerPage).ceil().clamp(1, 999);
    final pageItems =
        searched.skip(_page * _rowsPerPage).take(_rowsPerPage).toList();

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Main content
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Search + Add Battery Header ──
        Row(children: [
          // Search
          SizedBox(
              width: 260,
              child: TextField(
                controller: _searchC,
                onChanged: (v) => setState(() {
                  _searchQuery = v.toLowerCase();
                  _page = 0;
                }),
                style:
                    const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search battery code...',
                  hintStyle:
                      const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  prefixIcon: const Icon(LucideIcons.search,
                      size: 14, color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.pageBg,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
              )),
          const Spacer(),
          ElevatedButton.icon(
            icon: const Icon(LucideIcons.plus, size: 14),
            label: const Text('Add Battery'),
            onPressed: () => _showAddBatteryModal(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ]),
        const SizedBox(height: 16),

        // ── Filter Pills ──
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              children: _filters.map((f) {
            final count = f.key == 'All'
                ? allBatteries.length
                : allBatteries.where((b) => b.status == f.key).length;
            final isActive = _activeFilter == f.key;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => setState(() {
                    _activeFilter = f.key;
                    _page = 0;
                    _selectedBatteryIndex = -1;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isActive
                          ? f.color.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: isActive
                              ? f.color.withValues(alpha: 0.4)
                              : AppColors.border),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(f.icon,
                          size: 14,
                          color: isActive ? f.color : AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(f.label ?? f.key,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w400,
                            color: isActive ? f.color : AppColors.textSecondary,
                          )),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: f.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text('$count',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: f.color)),
                      ),
                    ]),
                  ),
                ),
              ),
            );
          }).toList()),
        ),
        const SizedBox(height: 16),

        // ── Battery Table ──
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: searched.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(50),
                  child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(LucideIcons.batteryWarning,
                        size: 32, color: AppColors.textMuted),
                    SizedBox(height: 12),
                    Text('No batteries found',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    SizedBox(height: 4),
                    Text('Try changing the filter or search query',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textTertiary)),
                  ])))
              : Column(children: [
                  // Table header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.pageBg.withValues(alpha: 0.3),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Row(children: [
                      _colHeader('BATTERY CODE', flex: 3),
                      _colHeader('STATUS', flex: 2),
                      _colHeader('CHARGE', flex: 2),
                      _colHeader('HEALTH', flex: 2),
                      _colHeader('CYCLES', flex: 1),
                      _colHeader('TYPE', flex: 2),
                      if (_activeFilter == 'rented')
                        _colHeader('CUSTOMER', flex: 2),
                      if (_activeFilter == 'available')
                        _colHeader('IDLE', flex: 1),
                      if (_activeFilter == 'charging')
                        _colHeader('EST. FULL', flex: 2),
                      if (_activeFilter == 'maintenance')
                        _colHeader('FAULT', flex: 2),
                      const SizedBox(width: 30), // Chevron space
                    ]),
                  ),
                  // Rows
                  ...pageItems
                      .asMap()
                      .entries
                      .map((entry) => _batteryRow(entry.value, entry.key)),
                ]),
        ),
        const SizedBox(height: 14),

        // ── Footer ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            Text(
              'Showing ${_page * _rowsPerPage + 1}–${(_page * _rowsPerPage + pageItems.length)} of ${searched.length} batteries',
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textTertiary),
            ),
            const Spacer(),
            // Pagination
            Row(mainAxisSize: MainAxisSize.min, children: [
              _pageBtn(LucideIcons.chevronLeft, _page > 0,
                  () => setState(() => _page--)),
              ...List.generate(
                  totalPages.clamp(0, 5),
                  (i) => GestureDetector(
                        onTap: () => setState(() => _page = i),
                        child: Container(
                          width: 28,
                          height: 28,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: _page == i
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                              child: Text('${i + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _page == i
                                        ? Colors.white
                                        : AppColors.textTertiary,
                                  ))),
                        ),
                      )),
              _pageBtn(LucideIcons.chevronRight, _page < totalPages - 1,
                  () => setState(() => _page++)),
            ]),
            const SizedBox(width: 16),
            // Rows per page
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('Rows: ',
                  style:
                      TextStyle(fontSize: 10, color: AppColors.textTertiary)),
              DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                value: _rowsPerPage,
                isDense: true,
                dropdownColor: AppColors.cardBg,
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                items: [10, 25, 50]
                    .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                    .toList(),
                onChanged: (v) => setState(() {
                  _rowsPerPage = v!;
                  _page = 0;
                }),
              )),
            ]),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                final fileName =
                    'batteries_${s.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';
                ExportHelper.exportBatteriesToCsv(searched, fileName);
              },
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(LucideIcons.download,
                    size: 12, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                const Text('Export CSV',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500)),
              ]),
            ),
          ]),
        ),
      ])),

      // ── Battery Detail Drawer ──
      if (_selectedBatteryIndex >= 0 &&
          _selectedBatteryIndex < pageItems.length) ...[
        const SizedBox(width: 14),
        _batteryDrawer(pageItems[_selectedBatteryIndex]),
      ],
    ]);
  }

  // ── Table row ──
  Widget _batteryRow(BatteryDto b, int index) {
    final color = _statusColor(b.status);
    final isSelected = _selectedBatteryIndex == index;
    final customer = b.currentCustomer ?? '—';
    final initial = customer != '—' ? customer[0].toUpperCase() : '—';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () =>
            setState(() => _selectedBatteryIndex = isSelected ? -1 : index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.04) : null,
            border: Border(
              left: BorderSide(
                  color: isSelected ? color : Colors.transparent, width: 3),
              bottom:
                  BorderSide(color: AppColors.border.withValues(alpha: 0.4)),
            ),
          ),
          child: Row(children: [
            // Battery code
            Expanded(
                flex: 3,
                child: Text(b.serialNumber,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: AppColors.cyan,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ))),
            // Status
            Expanded(flex: 2, child: _statusBadge(b.status, color)),
            // Charge
            Expanded(flex: 2, child: _chargeBar(b.chargePercentage)),
            // Health
            Expanded(flex: 2, child: _healthText(b.healthPercentage)),
            // Cycles
            Expanded(
                flex: 1,
                child: Text('${b.cycleCount}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textTertiary))),
            // Type
            Expanded(
                flex: 2,
                child: Text(b.batteryType,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textTertiary))),
            // Context columns
            if (_activeFilter == 'rented')
              Expanded(
                  flex: 2,
                  child: Row(children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: AppColors.cyan.withValues(alpha: 0.15),
                      child: Text(initial,
                          style: const TextStyle(
                              fontSize: 9, color: AppColors.cyan)),
                    ),
                    const SizedBox(width: 6),
                    Text(customer,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis),
                  ])),
            if (_activeFilter == 'available')
              Expanded(
                  flex: 1,
                  child: Text('${b.daysIdle}d',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: b.daysIdle > 7
                            ? AppColors.amber
                            : AppColors.textTertiary,
                      ))),
            if (_activeFilter == 'charging')
              Expanded(
                  flex: 2,
                  child: Text('~${(100 - b.chargePercentage) ~/ 5 + 1}h',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.cyan))),
            if (_activeFilter == 'maintenance')
              Expanded(
                  flex: 2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4)),
                    child: Text(
                        b.faultDescription?.isNotEmpty == true
                            ? b.faultDescription!
                            : 'FAULT',
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.red),
                        overflow: TextOverflow.ellipsis),
                  )),
            // Chevron
            SizedBox(
                width: 30,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: isSelected ? 1.0 : 0.3,
                  child: Icon(LucideIcons.chevronRight, size: 14, color: color),
                )),
          ]),
        ),
      ),
    );
  }

  // ── Battery Detail Drawer ──
  Widget _batteryDrawer(BatteryDto b) {
    final color = _statusColor(b.status);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 380,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            Expanded(
                child: Text(b.serialNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      color: AppColors.cyan,
                    ))),
            _statusBadge(b.status, color),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _selectedBatteryIndex = -1),
              child: const Icon(LucideIcons.x,
                  size: 16, color: AppColors.textMuted),
            ),
          ]),
          const SizedBox(height: 20),

          // Gauges row
          Row(children: [
            Expanded(
                child: _miniGauge(
                    'Charge',
                    b.chargePercentage,
                    b.chargePercentage > 60
                        ? AppColors.primary
                        : b.chargePercentage > 30
                            ? AppColors.amber
                            : AppColors.red)),
            const SizedBox(width: 12),
            Expanded(
                child: _miniGauge(
                    'Health',
                    b.healthPercentage,
                    b.healthPercentage > 80
                        ? AppColors.primary
                        : b.healthPercentage > 50
                            ? AppColors.amber
                            : AppColors.red)),
            const SizedBox(width: 12),
            Expanded(child: _statBox('Cycles', '${b.cycleCount}')),
          ]),
          const SizedBox(height: 20),

          // Details
          const Text('Details',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          _drawerDetail('Battery Type', b.batteryType),
          _drawerDetail('Status', b.status.toUpperCase()),
          _drawerDetail('Created', _formatDate(b.createdAt ?? '')),
          if (b.faultDescription != null && b.faultDescription!.isNotEmpty)
            _drawerDetail('Fault', b.faultDescription!),
          const SizedBox(height: 16),

          // Last Rental
          const Text('Last Rental',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          if (b.lastRental != null && b.lastRental!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.pageBg.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.border.withValues(alpha: 0.4)),
              ),
              child: Row(children: [
                const Icon(LucideIcons.clock,
                    size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(_formatDate(b.lastRental!),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary))),
              ]),
            )
          else
            Text('No rental history',
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 20),

          // Actions
          const Text('Actions',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          ..._getActionsForStatus(b),
        ]),
      ),
    );
  }

  Widget _miniGauge(String label, double value, Color color) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.12)),
        ),
        child: Column(children: [
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(
                value: value / 100,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(color),
                strokeWidth: 4,
              ),
              Text('${value.toStringAsFixed(0)}%',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w800, color: color)),
            ]),
          ),
          const SizedBox(height: 6),
          Text(label,
              style:
                  const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
        ]),
      );

  Widget _statBox(String label, String value) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.pageBg.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(children: [
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Text(label,
              style:
                  const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
        ]),
      );

  Widget _drawerDetail(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          SizedBox(
              width: 90,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textTertiary))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary))),
        ]),
      );

  List<Widget> _getActionsForStatus(BatteryDto b) {
    switch (b.status.toLowerCase()) {
      case 'available':
        return [
          _actionBtn(
              'Mark as Maintenance', LucideIcons.wrench, AppColors.amber),
          const SizedBox(height: 6),
          _actionBtn('Transfer to Station', LucideIcons.arrowRightLeft,
              AppColors.cyan),
        ];
      case 'rented':
        return [
          _actionBtn('View Active Rental', LucideIcons.eye, AppColors.cyan),
          const SizedBox(height: 6),
          _actionBtn('Contact Customer', LucideIcons.phone, AppColors.primary),
        ];
      case 'maintenance':
        return [
          _actionBtn(
              'Mark as Fixed', LucideIcons.checkCircle, AppColors.primary),
          const SizedBox(height: 6),
          _actionBtn('Retire Battery', LucideIcons.trash2, AppColors.red),
        ];
      default:
        return [
          _actionBtn('View Details', LucideIcons.eye, AppColors.primary,
              onTap: () => _showBatteryDetailModal(b))
        ];
    }
  }

  Widget _actionBtn(String label, IconData icon, Color color,
          {VoidCallback? onTap}) =>
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: Icon(icon, size: 13),
          label: Text(label, style: const TextStyle(fontSize: 12)),
          onPressed: onTap ??
              () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(label), backgroundColor: color)),
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color.withValues(alpha: 0.3)),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );

  // ── Battery Details Modal ──
  void _showBatteryDetailModal(BatteryDto b) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(LucideIcons.batteryFull,
                        size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                      child: Text('Battery Technical Details',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary))),
                  IconButton(
                      icon: const Icon(LucideIcons.x,
                          size: 16, color: AppColors.textMuted),
                      onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: _statBox('Charge',
                          '${b.chargePercentage.toStringAsFixed(1)}%')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _statBox('Health',
                          '${b.healthPercentage.toStringAsFixed(1)}%')),
                  const SizedBox(width: 10),
                  Expanded(child: _statBox('Cycles', '${b.cycleCount}')),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Hardware Information',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              _drawerDetail('Serial Number', b.serialNumber),
              _drawerDetail('Type/Capacity',
                  b.batteryType.isNotEmpty ? b.batteryType : '48V/30Ah'),
              _drawerDetail('Status', b.status.toUpperCase()),
              _drawerDetail(
                  'Registered At',
                  b.createdAt != null
                      ? TimeUtils.dateOnly(b.createdAt)
                      : 'Unknown'),
              if (b.faultDescription != null && b.faultDescription!.isNotEmpty)
                _drawerDetail('Fault Status', b.faultDescription!),
              if (b.lastChargedAt != null)
                _drawerDetail(
                    'Last Charged', TimeUtils.longDateTime(b.lastChargedAt)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Add Battery Modal ──
  void _showAddBatteryModal(BuildContext context) {
    final codeC = TextEditingController();
    final healthC = TextEditingController(text: '100');
    String selectedType = '48V/30Ah';

    showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
            builder: (ctx, setModal) => Dialog(
                  backgroundColor: AppColors.cardBg,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    width: 480,
                    padding: const EdgeInsets.all(28),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Icon(LucideIcons.batteryFull,
                                  size: 18, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            const Text('Register New Battery',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                            const Spacer(),
                            IconButton(
                                icon: const Icon(LucideIcons.x,
                                    size: 16, color: AppColors.textMuted),
                                onPressed: () => Navigator.pop(ctx)),
                          ]),
                          const SizedBox(height: 24),

                          // Battery Code
                          TextField(
                            controller: codeC,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                                fontFamily: 'monospace'),
                            decoration: InputDecoration(
                              labelText: 'Battery Code',
                              hintText: 'Enter or scan battery code',
                              prefixIcon: const Icon(LucideIcons.scanLine,
                                  size: 16, color: AppColors.textTertiary),
                              suffixIcon: codeC.text.length > 3
                                  ? const Icon(LucideIcons.checkCircle,
                                      size: 16, color: AppColors.primary)
                                  : null,
                              filled: true,
                              fillColor: AppColors.pageBg,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.border)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.border)),
                            ),
                            onChanged: (_) => setModal(() {}),
                          ),
                          const SizedBox(height: 14),

                          // Type dropdown
                          DropdownButtonFormField<String>(
                            value: selectedType,
                            dropdownColor: AppColors.cardBg,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Battery Type',
                              prefixIcon: const Icon(LucideIcons.tag,
                                  size: 16, color: AppColors.textTertiary),
                              filled: true,
                              fillColor: AppColors.pageBg,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.border)),
                            ),
                            items: [
                              '48V/30Ah',
                              '48V/20Ah',
                              '60V/35Ah',
                              '72V/40Ah'
                            ]
                                .map((t) =>
                                    DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (v) => setModal(() => selectedType = v!),
                          ),
                          const SizedBox(height: 14),

                          // Health
                          TextField(
                            controller: healthC,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Initial Health %',
                              prefixIcon: const Icon(LucideIcons.heartPulse,
                                  size: 16, color: AppColors.textTertiary),
                              filled: true,
                              fillColor: AppColors.pageBg,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.border)),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Preview
                          if (codeC.text.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.12)),
                              ),
                              child: Row(children: [
                                const Icon(LucideIcons.eye,
                                    size: 14, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(codeC.text,
                                    style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        color: AppColors.cyan,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(width: 8),
                                _statusBadge('available', AppColors.primary),
                                const SizedBox(width: 8),
                                Text('$selectedType',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textTertiary)),
                              ]),
                            ),
                          const SizedBox(height: 20),

                          SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(LucideIcons.plus, size: 14),
                                label: const Text('Register Battery'),
                                onPressed: codeC.text.length > 3
                                    ? () {
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              'Battery ${codeC.text} registered'),
                                          backgroundColor: AppColors.primary,
                                        ));
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              )),
                        ]),
                  ),
                )));
  }

  // ── Helpers ──
  Widget _colHeader(String text, {int flex = 1}) => Expanded(
        flex: flex,
        child: Text(text,
            style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 0.5)),
      );

  Widget _statusBadge(String status, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Text(status.toUpperCase(),
            style: TextStyle(
                color: color, fontSize: 9, fontWeight: FontWeight.w600)),
      );

  Widget _chargeBar(double pct) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
            width: 40,
            height: 5,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(pct > 60
                      ? AppColors.primary
                      : pct > 30
                          ? AppColors.amber
                          : AppColors.red),
                ))),
        const SizedBox(width: 6),
        Text('${pct.toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ]);

  Widget _healthText(double pct) {
    final color = pct > 80
        ? AppColors.primary
        : pct > 50
            ? AppColors.amber
            : AppColors.red;
    return Text('${pct.toStringAsFixed(0)}%',
        style:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color));
  }

  Widget _pageBtn(IconData icon, bool enabled, VoidCallback onTap) =>
      GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border)),
          child: Icon(icon,
              size: 14,
              color: enabled ? AppColors.textSecondary : AppColors.textMuted),
        ),
      );

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AppColors.primary;
      case 'rented':
        return AppColors.cyan;
      case 'charging':
        return AppColors.amber;
      case 'maintenance':
      case 'damaged':
        return AppColors.red;
      case 'retired':
        return AppColors.textMuted;
      default:
        return AppColors.primary;
    }
  }

  String _formatDate(String iso) => TimeUtils.dateOnly(iso);
}

class _FilterDef {
  final String key;
  final String? label;
  final IconData icon;
  final Color color;
  const _FilterDef(this.key, this.label, this.icon, this.color);
}
