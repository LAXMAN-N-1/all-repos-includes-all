import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/station_state.dart';
import '../providers/station_detail_provider.dart';
import '../../../core/theme/colors.dart';

class BatteryListScreen extends ConsumerStatefulWidget {
  final String? stationId;
  const BatteryListScreen({super.key, this.stationId});
  @override
  ConsumerState<BatteryListScreen> createState() => _BatteryListScreenState();
}

class _BatteryListScreenState extends ConsumerState<BatteryListScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final _searchC = TextEditingController();
  List<BatteryDto> _latestBatteries = const [];

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sid =
        widget.stationId != null ? int.tryParse(widget.stationId!) : null;
    final batteriesAsync = ref.watch(dealerBatteriesProvider(sid));
    final scope = sid != null ? 'Station #$sid' : 'All Stations';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Back
        GestureDetector(
          onTap: () => context.go('/stations'),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(LucideIcons.arrowLeft, size: 16, color: AppColors.primary),
            SizedBox(width: 6),
            Text('Back to Stations',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500)),
          ]),
        ),
        const SizedBox(height: 18),

        // Header
        Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(LucideIcons.batteryFull,
                size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Battery Inventory',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                Text(scope,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textTertiary)),
              ])),
          OutlinedButton.icon(
            icon: const Icon(LucideIcons.download, size: 14),
            label: const Text('Export CSV', style: TextStyle(fontSize: 12)),
            onPressed: _handleExport,
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border)),
          ),
        ]),
        const SizedBox(height: 20),

        batteriesAsync.when(
          data: (batteries) {
            _latestBatteries = batteries;
            return _buildContent(batteries);
          },
          loading: () => const Center(
              child: Padding(
                  padding: EdgeInsets.all(60),
                  child: CircularProgressIndicator(color: AppColors.primary))),
          error: (e, _) => Center(
              child: Text('Error: $e',
                  style: const TextStyle(color: AppColors.red))),
        ),
      ]),
    );
  }

  Widget _buildContent(List<BatteryDto> all) {
    final filters = ['All', 'available', 'rented', 'maintenance', 'retired'];
    final filtered = _selectedFilter == 'All'
        ? all
        : all.where((b) => b.status == _selectedFilter).toList();
    final searched = _searchQuery.isEmpty
        ? filtered
        : filtered
            .where((b) =>
                b.serialNumber.toLowerCase().contains(_searchQuery) ||
                b.stationName.toLowerCase().contains(_searchQuery))
            .toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Search + Filter
      Row(children: [
        SizedBox(
            width: 260,
            child: TextField(
              controller: _searchC,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search batteries...',
                prefixIcon: const Icon(LucideIcons.search, size: 15),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border)),
              ),
            )),
        const SizedBox(width: 16),
        ...filters.map((f) {
          final count =
              f == 'All' ? all.length : all.where((b) => b.status == f).length;
          final sel = _selectedFilter == f;
          final color = _statusColor(f);
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = f),
              child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel
                          ? color.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: sel
                              ? color.withValues(alpha: 0.4)
                              : AppColors.border),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                          f == 'All'
                              ? 'All'
                              : f[0].toUpperCase() + f.substring(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                            color: sel ? color : AppColors.textSecondary,
                          )),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text('$count',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: color)),
                      ),
                    ]),
                  )),
            ),
          );
        }),
      ]),
      const SizedBox(height: 16),

      // Table
      Container(
        decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
        child: searched.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                    child: Text('No batteries found',
                        style: TextStyle(color: AppColors.textSecondary))))
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('BATTERY CODE')),
                        DataColumn(label: Text('STATION')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('CHARGE')),
                        DataColumn(label: Text('HEALTH')),
                        DataColumn(label: Text('CYCLES')),
                        DataColumn(label: Text('TYPE')),
                        DataColumn(label: Text('CUSTOMER')),
                      ],
                      rows: searched.map((b) {
                        final color = _statusColor(b.status);
                        return DataRow(cells: [
                          DataCell(Text(b.serialNumber,
                              style: const TextStyle(
                                  fontFamily: 'monospace',
                                  color: AppColors.cyan,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600))),
                          DataCell(Text(b.stationName,
                              style: const TextStyle(fontSize: 12))),
                          DataCell(_badge(b.status, color)),
                          DataCell(_chargeBar(b.chargePercentage)),
                          DataCell(_healthText(b.healthPercentage)),
                          DataCell(Text('${b.cycleCount}',
                              style: const TextStyle(fontSize: 12))),
                          DataCell(Text(b.batteryType,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary))),
                          DataCell(Text(b.currentCustomer ?? '—',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary))),
                        ]);
                      }).toList(),
                    ))),
      ),
    ]);
  }

  Widget _badge(String status, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Text(status.toUpperCase(),
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w600)),
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

  Future<void> _handleExport() async {
    if (_latestBatteries.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No battery data to export')),
      );
      return;
    }

    final header = [
      'battery_id',
      'serial_number',
      'station_name',
      'status',
      'charge_percentage',
      'health_percentage',
      'cycle_count',
      'battery_type',
      'current_customer',
      'days_idle',
    ];
    final rows = _latestBatteries
        .map(
          (b) => [
            b.id.toString(),
            b.serialNumber,
            b.stationName,
            b.status,
            b.chargePercentage.toStringAsFixed(1),
            b.healthPercentage.toStringAsFixed(1),
            b.cycleCount.toString(),
            b.batteryType,
            b.currentCustomer ?? '',
            b.daysIdle.toString(),
          ],
        )
        .toList(growable: false);
    final csv = _buildCsv(header, rows);

    try {
      final uri =
          Uri.parse('data:text/csv;charset=utf-8,${Uri.encodeComponent(csv)}');
      final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      if (!launched) {
        await Clipboard.setData(ClipboardData(text: csv));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV copied to clipboard (download not supported)'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Export error: $e');
    }
  }

  String _buildCsv(List<String> header, List<List<String>> rows) {
    final buffer = StringBuffer();
    buffer.writeln(header.map(_escapeCsv).join(','));
    for (final row in rows) {
      buffer.writeln(row.map(_escapeCsv).join(','));
    }
    return buffer.toString();
  }

  String _escapeCsv(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }
}
