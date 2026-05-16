import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../providers/commissions_provider.dart';
import '../models/commissions_state.dart';
import '../../../core/utils/export_helper.dart';

final commissionPeriodProvider = StateProvider<String>((ref) => 'This Month');

class SettlementCommandCenter extends ConsumerWidget {
  const SettlementCommandCenter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commissionsState = ref.watch(commissionsProvider);
    final selectedPeriod = ref.watch(commissionPeriodProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Commission Summary (60%)
              Expanded(
                flex: 6,
                child: _CommissionBreakdown(
                    state: commissionsState, selectedPeriod: selectedPeriod),
              ),
              const SizedBox(width: 32),
              // Vertical Divider
              Container(width: 1, height: 400, color: AppColors.border),
              const SizedBox(width: 32),
              // Right: Payout Schedule (40%)
              Expanded(
                flex: 4,
                child: _PayoutSchedule(state: commissionsState),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildBankFooter(context, commissionsState),
        ],
      ),
    );
  }

  Widget _buildBankFooter(BuildContext context, CommissionsState state) {
    if (state.payouts.isEmpty) return const SizedBox.shrink();
    final payout = state.payouts.first;
    final bankName = (payout.bankName?.trim().isNotEmpty ?? false)
        ? payout.bankName!
        : 'Bank details unavailable';
    final accountMask = (payout.accountMask?.trim().isNotEmpty ?? false)
        ? payout.accountMask!
        : '—';
    final ifsc = (payout.ifsc?.trim().isNotEmpty ?? false) ? payout.ifsc! : '—';
    final verifiedLabel = payout.isVerified == null
        ? 'Unknown'
        : (payout.isVerified! ? 'Verified' : 'Pending');
    final verifiedColor =
        payout.isVerified == true ? Colors.green : AppColors.amber;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.pageBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.landmark,
              size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 12),
          Text(
            'Settlement Account: $bankName • $accountMask • $ifsc',
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: verifiedColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.shieldCheck, size: 12, color: verifiedColor),
                SizedBox(width: 4),
                Text(
                  verifiedLabel,
                  style: TextStyle(
                    color: verifiedColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () => _openBankDetails(context, payout),
            child: const Text('Update Bank Details',
                style: TextStyle(color: AppColors.primary, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _CommissionBreakdown extends ConsumerWidget {
  final CommissionsState state;
  final String selectedPeriod;
  const _CommissionBreakdown(
      {required this.state, required this.selectedPeriod});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    // Filtering logic based on period
    final now = DateTime.now();
    final commissions = state.commissions.where((c) {
      final date = DateTime.tryParse(c.createdAt) ?? now;
      if (selectedPeriod == 'This Month') {
        return date.month == now.month && date.year == now.year;
      } else if (selectedPeriod == 'Last Month') {
        final lastMonth = now.month == 1 ? 12 : now.month - 1;
        final lastYear = now.month == 1 ? now.year - 1 : now.year;
        return date.month == lastMonth && date.year == lastYear;
      } else if (selectedPeriod == 'Last Quarter') {
        final quarterStart =
            DateTime(now.year, ((now.month - 1) ~/ 3) * 3 - 2, 1);
        final quarterEnd =
            DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1, 0);
        return date.isAfter(quarterStart.subtract(const Duration(days: 1))) &&
            date.isBefore(quarterEnd.add(const Duration(days: 1)));
      }
      return true;
    }).toList();

    // Aggregating stats for the period
    double gross = commissions.fold(0.0, (sum, c) => sum + c.grossRevenue);
    double fees = commissions.fold(0.0, (sum, c) => sum + c.platformFees);
    double commission = commissions.fold(0.0, (sum, c) => sum + c.amount);

    double net = gross - fees - commission;
    final currentRate = state.summary?.currentCommissionRate ?? 0.0;
    final effectiveRate = currentRate > 0
        ? currentRate
        : (state.commissions.isNotEmpty ? state.commissions.first.rate : 0.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Commission Summary',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            _buildPeriodSelector(ref),
          ],
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            _buildMetricTile(
                'Gross Revenue', currency.format(gross), Colors.white),
            _buildMetricTile(
                'Platform Fees', '- ${currency.format(fees)}', AppColors.red),
            _buildMetricTile('Commission Earned', currency.format(commission),
                AppColors.cyan),
            _buildMetricTile('Net Payout', currency.format(net), Colors.green),
          ],
        ),
        const SizedBox(height: 32),
        const Text('Revenue Split',
            style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildStackedProgressBar(gross, fees, commission),
        const SizedBox(height: 24),
        _buildRateCard(context, effectiveRate),
      ],
    );
  }

  Widget _buildPeriodSelector(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: AppColors.pageBg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: ['This Month', 'Last Month', 'Last Quarter'].map((e) {
          final isSelected = e == selectedPeriod;
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () =>
                  ref.read(commissionPeriodProvider.notifier).state = e,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.cardBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(e,
                    style: TextStyle(
                        color:
                            isSelected ? Colors.white : AppColors.textTertiary,
                        fontSize: 12)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pageBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style:
                  const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStackedProgressBar(
      double gross, double fees, double commission) {
    if (gross == 0) gross = 1;
    final feesPercent = fees / gross;
    final commPercent = commission / gross;
    final netPercent = 1.0 - feesPercent - commPercent;

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 12,
        child: Row(
          children: [
            Expanded(
                flex: (netPercent * 100).toInt(),
                child: Container(color: Colors.green)),
            Expanded(
                flex: (commPercent * 100).toInt(),
                child: Container(color: AppColors.cyan)),
            Expanded(
                flex: (feesPercent * 100).toInt(),
                child: Container(color: AppColors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildRateCard(BuildContext context, double currentRate) {
    final hasRateData = currentRate > 0;
    final rateText = hasRateData
        ? '${(currentRate * 100).toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '')}%'
        : '—';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cyan.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Commission Rate',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                rateText,
                style: const TextStyle(
                  color: AppColors.cyan,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  hasRateData ? 'Live Rate' : 'No rate data',
                  style: const TextStyle(
                    color: AppColors.cyan,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _openRateHistory(context, state.commissions),
                child: const Text('Rate History',
                    style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                        decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayoutSchedule extends StatelessWidget {
  final CommissionsState state;
  const _PayoutSchedule({required this.state});

  DateTime? _parseDate(String? value) => DateTime.tryParse(value ?? '');
  String _bankLabel(PayoutDto payout) =>
      (payout.bankName?.trim().isNotEmpty ?? false)
          ? payout.bankName!
          : 'Bank details unavailable';
  String _relativeDateLabel(DateTime? date) {
    if (date == null) return 'Date unavailable';
    final today = DateTime.now();
    final localDate = date.toLocal();
    final localToday = DateTime(today.year, today.month, today.day);
    final payoutDay = DateTime(localDate.year, localDate.month, localDate.day);
    final days = payoutDay.difference(localToday).inDays;
    if (days == 0) return 'Today';
    if (days > 0) return 'In $days day${days == 1 ? '' : 's'}';
    final ago = days.abs();
    return '$ago day${ago == 1 ? '' : 's'} ago';
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    if (state.payouts.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payout Schedule',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                Icon(LucideIcons.calendarX,
                    size: 48, color: AppColors.textTertiary),
                SizedBox(height: 16),
                Text('No payouts scheduled yet',
                    style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      );
    }

    final sortedPayouts = [...state.payouts]..sort((a, b) {
        final aDate =
            _parseDate(a.date) ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            _parseDate(b.date) ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
    final nextPayout = sortedPayouts.firstWhere(
      (p) {
        final status = p.status.toUpperCase();
        return status != 'COMPLETED' && status != 'PAID' && status != 'FAILED';
      },
      orElse: () => sortedPayouts.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payout Schedule',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _buildNextPayoutCard(context, nextPayout, currency),
        const SizedBox(height: 24),
        const Text('Settlement History',
            style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...sortedPayouts.map((p) => _buildPayoutEntry(context, p, currency)),
      ],
    );
  }

  Widget _buildNextPayoutCard(
      BuildContext context, PayoutDto payout, NumberFormat currency) {
    final payoutDate = _parseDate(payout.date);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Next Payout',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              Text(
                _relativeDateLabel(payoutDate),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(currency.format(payout.amount),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(LucideIcons.banknote,
                  size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 8),
              Text(
                _bankLabel(payout),
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _openBankDetails(context, payout),
                child: const Text('View Bank Account',
                    style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                        decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutEntry(
      BuildContext context, PayoutDto payout, NumberFormat currency) {
    Color statusColor;
    bool isPulsing = false;
    final parsedDate = _parseDate(payout.date);
    switch (payout.status.toUpperCase()) {
      case 'COMPLETED':
        statusColor = Colors.green;
        break;
      case 'PROCESSING':
        statusColor = AppColors.cyan;
        isPulsing = true;
        break;
      case 'FAILED':
        statusColor = AppColors.red;
        break;
      default:
        statusColor = AppColors.textTertiary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showPayoutDetail(context, payout),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parsedDate != null
                        ? DateFormat('MMM dd, yyyy').format(parsedDate)
                        : 'Date unavailable',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                  Text(
                    parsedDate != null
                        ? DateFormat('HH:mm').format(parsedDate)
                        : '—',
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 11),
                  ),
                ],
              ),
              const Spacer(),
              Text(currency.format(payout.amount),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              _buildStatusBadge(payout.status, statusColor, isPulsing),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  ExportHelper.exportPayoutToCsv(
                      payout, 'settlement_${payout.id}.csv');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text("Downloading settlement ${payout.id} receipt"),
                        backgroundColor: Colors.green),
                  );
                },
                icon: const Icon(LucideIcons.download,
                    size: 14, color: AppColors.textTertiary),
                splashRadius: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color, bool pulsing) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          if (pulsing) ...[
            _PulsingDot(color: color),
            const SizedBox(width: 6),
          ],
          Text(status,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color:
              widget.color.withValues(alpha: 0.5 + (0.5 * _controller.value)),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

void _openBankDetails(BuildContext context, PayoutDto? payout) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => _BankDetailsDrawer(payout: payout),
  );
}

void _openRateHistory(BuildContext context, List<CommissionDto> commissions) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => _RateHistoryDrawer(commissions: commissions),
  );
}

void _showPayoutDetail(BuildContext context, PayoutDto payout) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => _PayoutDetailDrawer(payout: payout),
  );
}

class _PayoutDetailDrawer extends StatelessWidget {
  final PayoutDto payout;
  const _PayoutDetailDrawer({required this.payout});

  DateTime? _parseDate(String? value) => DateTime.tryParse(value ?? '');
  String _safeValue(String? value) =>
      (value?.trim().isNotEmpty ?? false) ? value! : '—';

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final parsedDate = _parseDate(payout.date);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Settlement Detail',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon:
                      const Icon(LucideIcons.x, color: AppColors.textTertiary)),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow('Settlement ID', 'PAY-${payout.id}'),
          _buildInfoRow('Amount', currency.format(payout.amount),
              valueColor: Colors.green),
          _buildInfoRow(
            'Date',
            parsedDate != null
                ? DateFormat('dd MMM yyyy, HH:mm').format(parsedDate)
                : '—',
          ),
          _buildInfoRow('Status', payout.status,
              valueColor: payout.status == 'COMPLETED'
                  ? Colors.green
                  : AppColors.amber),
          _buildInfoRow('Bank', _safeValue(payout.bankName)),
          _buildInfoRow('Account', _safeValue(payout.accountMask)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ExportHelper.exportPayoutToCsv(
                    payout, 'settlement_${payout.id}.csv');
                Navigator.pop(context);
              },
              icon: const Icon(LucideIcons.download, size: 16),
              label: const Text('Download Receipt'),
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: AppColors.textTertiary, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _BankDetailsDrawer extends ConsumerStatefulWidget {
  final PayoutDto? payout;
  const _BankDetailsDrawer({this.payout});

  @override
  ConsumerState<_BankDetailsDrawer> createState() => _BankDetailsDrawerState();
}

class _BankDetailsDrawerState extends ConsumerState<_BankDetailsDrawer> {
  String _safeValue(String? value) =>
      (value?.trim().isNotEmpty ?? false) ? value! : '—';

  @override
  Widget build(BuildContext context) {
    final statusLabel = widget.payout?.isVerified == null
        ? 'Unknown'
        : (widget.payout!.isVerified! ? 'Verified' : 'Pending');
    final statusColor =
        widget.payout?.isVerified == true ? Colors.green : AppColors.amber;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Bank Account Details',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x,
                        color: AppColors.textTertiary)),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow('Bank Name', _safeValue(widget.payout?.bankName)),
            _buildInfoRow(
                'Account Number', _safeValue(widget.payout?.accountMask)),
            _buildInfoRow('IFSC Code', _safeValue(widget.payout?.ifsc)),
            _buildInfoRow('Account Holder', '—'),
            _buildInfoRow('Status', statusLabel, valueColor: statusColor),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Manage bank details from Settings > Bank & Payouts.',
                      ),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.5),
                ),
                child: const Text('Manage in Settings',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: AppColors.textTertiary, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _RateHistoryEntry {
  final String month;
  final String rateLabel;
  const _RateHistoryEntry({required this.month, required this.rateLabel});
}

class _RateHistoryDrawer extends StatelessWidget {
  final List<CommissionDto> commissions;
  const _RateHistoryDrawer({required this.commissions});

  String _formatRate(double rate) =>
      '${(rate * 100).toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '')}%';

  List<_RateHistoryEntry> _buildEntries() {
    final sorted = [...commissions]..sort((a, b) {
        final ad = DateTime.tryParse(a.createdAt) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bd = DateTime.tryParse(b.createdAt) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bd.compareTo(ad);
      });
    final seen = <String>{};
    final entries = <_RateHistoryEntry>[];
    for (final c in sorted) {
      final date = DateTime.tryParse(c.createdAt);
      if (date == null || c.rate <= 0) continue;
      final month = DateFormat('MMM yyyy').format(date);
      final rateLabel = _formatRate(c.rate);
      final key = '$month|$rateLabel';
      if (!seen.add(key)) continue;
      entries.add(_RateHistoryEntry(month: month, rateLabel: rateLabel));
      if (entries.length >= 12) break;
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final entries = _buildEntries();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Commission Rate History',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon:
                      const Icon(LucideIcons.x, color: AppColors.textTertiary)),
            ],
          ),
          const SizedBox(height: 24),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'No commission rate history available yet.',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
              ),
            ),
          if (entries.isNotEmpty)
            ...entries.map(
                (entry) => _buildHistoryItem(entry.month, entry.rateLabel)),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String month, String rate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(month,
              style: const TextStyle(color: Colors.white, fontSize: 13)),
          const Spacer(),
          Text(rate,
              style: const TextStyle(
                  color: AppColors.cyan, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
