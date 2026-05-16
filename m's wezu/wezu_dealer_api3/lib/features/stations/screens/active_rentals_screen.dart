import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/station_state.dart';
import '../providers/station_detail_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/time_utils.dart';

class ActiveRentalsScreen extends ConsumerStatefulWidget {
  final String? stationId;
  const ActiveRentalsScreen({super.key, this.stationId});

  @override
  ConsumerState<ActiveRentalsScreen> createState() =>
      _ActiveRentalsScreenState();
}

class _ActiveRentalsScreenState extends ConsumerState<ActiveRentalsScreen> {
  String _searchQuery = '';
  List<ActiveRentalDto> _latestRentals = const [];

  @override
  Widget build(BuildContext context) {
    final sid =
        widget.stationId != null ? int.tryParse(widget.stationId!) : null;
    final rentalsAsync = ref.watch(activeRentalsProvider(sid));
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
                color: AppColors.cyan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(LucideIcons.userCheck,
                size: 20, color: AppColors.cyan),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Active Rentals',
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

        TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search by Customer or Battery Code...',
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            prefixIcon: const Icon(LucideIcons.search,
                size: 18, color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.cardBg,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary)),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 20),

        rentalsAsync.when(
          data: (rentals) {
            _latestRentals = rentals;
            final filtered = rentals
                .where((r) =>
                    r.customerName
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ||
                    r.batteryCode
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                .toList();
            return _buildTable(filtered);
          },
          loading: () => const Center(
              child: Padding(
                  padding: EdgeInsets.all(60),
                  child: CircularProgressIndicator(color: AppColors.cyan))),
          error: (e, _) => Center(
              child: Text('Error: $e',
                  style: const TextStyle(color: AppColors.red))),
        ),
      ]),
    );
  }

  Widget _buildTable(List<ActiveRentalDto> rentals) {
    if (rentals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(60),
        decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border)),
        child: const Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(LucideIcons.userCheck, size: 32, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text('No active rentals',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ])),
      );
    }

    return Container(
      decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('CUSTOMER')),
                  DataColumn(label: Text('BATTERY')),
                  DataColumn(label: Text('STATION')),
                  DataColumn(label: Text('STARTED')),
                  DataColumn(label: Text('STATUS')),
                  DataColumn(label: Text('AMOUNT')),
                  DataColumn(label: Text('LATE FEE')),
                ],
                rows: rentals.map((r) {
                  final isOverdue = r.status == 'overdue';
                  return DataRow(
                    color: isOverdue
                        ? WidgetStateProperty.all(
                            AppColors.red.withValues(alpha: 0.05))
                        : null,
                    cells: [
                      DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                              color: AppColors.cyan.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(7)),
                          child: Center(
                              child: Text(r.customerInitial,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.cyan))),
                        ),
                        const SizedBox(width: 10),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.customerName,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary)),
                              Text(r.customerPhone,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textTertiary)),
                            ]),
                      ])),
                      DataCell(Text(r.batteryCode,
                          style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: AppColors.cyan,
                              fontWeight: FontWeight.w600))),
                      DataCell(Text(r.stationName,
                          style: const TextStyle(fontSize: 12))),
                      DataCell(Text(_formatTime(r.startTime),
                          style: const TextStyle(fontSize: 12))),
                      DataCell(_statusBadge(r.status,
                          isOverdue ? AppColors.red : AppColors.primary)),
                      DataCell(Text('₹${r.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600))),
                      DataCell(Text(
                        r.lateFee > 0
                            ? '₹${r.lateFee.toStringAsFixed(0)}'
                            : '—',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: r.lateFee > 0
                                ? AppColors.red
                                : AppColors.textTertiary),
                      )),
                    ],
                  );
                }).toList(),
              ))),
    );
  }

  Widget _statusBadge(String status, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Text(status.toUpperCase(),
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w600)),
      );

  String _formatTime(String iso) => TimeUtils.shortDateTime(iso);

  Future<void> _handleExport() async {
    if (_latestRentals.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No rental data to export')),
      );
      return;
    }

    final header = [
      'rental_id',
      'customer_name',
      'customer_phone',
      'battery_code',
      'battery_id',
      'station_name',
      'station_id',
      'start_time',
      'expected_return',
      'status',
      'total_amount',
      'late_fee',
      'duration_minutes',
    ];
    final rows = _latestRentals
        .map(
          (r) => [
            r.id.toString(),
            r.customerName,
            r.customerPhone,
            r.batteryCode,
            r.batteryId.toString(),
            r.stationName,
            r.stationId.toString(),
            r.startTime,
            r.expectedReturn,
            r.status,
            r.totalAmount.toStringAsFixed(2),
            r.lateFee.toStringAsFixed(2),
            r.durationMinutes.toString(),
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
