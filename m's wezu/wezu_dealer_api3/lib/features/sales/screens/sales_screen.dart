import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/sales_provider.dart';
import '../providers/commissions_provider.dart';
import '../models/sales_state.dart';
import '../../../core/utils/export_helper.dart';
import '../../../core/utils/time_utils.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});
  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  TransactionDto? _selectedTransaction;
  bool _isLoadingDetail = false;
  String? _detailError;

  @override
  void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward(); }
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  Widget _stagger(int i, {required Widget child}) {
    final begin = i * 0.12; final end = (begin + 0.4).clamp(0.0, 1.0);
    return AnimatedBuilder(animation: _c, builder: (c, _) {
      final t = Curves.easeOut.transform(((_c.value - begin) / (end - begin)).clamp(0.0, 1.0));
      return Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child));
    });
  }

  Future<void> _selectTransaction(TransactionDto tx) async {
    setState(() {
      _selectedTransaction = tx;
      _isLoadingDetail = true;
      _detailError = null;
    });

    final detail =
        await ref.read(salesProvider.notifier).fetchTransactionDetail(tx.id);
    if (!mounted) return;

    if (detail == null) {
      setState(() {
        _isLoadingDetail = false;
        _detailError = 'Unable to load full transaction details.';
      });
      return;
    }

    setState(() {
      _selectedTransaction = _mergeTransaction(tx, detail);
      _isLoadingDetail = false;
    });
  }

  TransactionDto _mergeTransaction(TransactionDto base, TransactionDto detail) {
    return base.copyWith(
      transactionType: detail.transactionType.isNotEmpty
          ? detail.transactionType
          : base.transactionType,
      amount: detail.amount > 0 ? detail.amount : base.amount,
      status: detail.status.isNotEmpty ? detail.status : base.status,
      createdAt: detail.createdAt.isNotEmpty ? detail.createdAt : base.createdAt,
      description: detail.description ?? base.description,
      customerName: detail.customerName ?? base.customerName,
      customerPhone: detail.customerPhone ?? base.customerPhone,
      batteryId: detail.batteryId ?? base.batteryId,
      stationName: detail.stationName ?? base.stationName,
      terminalNumber: detail.terminalNumber ?? base.terminalNumber,
      duration: detail.duration ?? base.duration,
      platformFee: detail.platformFee > 0 ? detail.platformFee : base.platformFee,
      commissionRate:
          detail.commissionRate > 0 ? detail.commissionRate : base.commissionRate,
      commissionAmount:
          detail.commissionAmount > 0 ? detail.commissionAmount : base.commissionAmount,
      netAmount: detail.netAmount > 0 ? detail.netAmount : base.netAmount,
      paymentMethod: detail.paymentMethod ?? base.paymentMethod,
      settlementStatus: detail.settlementStatus ?? base.settlementStatus,
      expectedSettlementDate:
          detail.expectedSettlementDate ?? base.expectedSettlementDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final salesState = ref.watch(salesProvider);
    final commissionState = ref.watch(commissionsProvider);
    final summary = commissionState.summary;
    
    double todayRevenue = 0;
    double monthRevenue = 0;
    double pendingRevenue = summary?.pendingPayouts ?? 0;
    int successCount = 0;
    int failedCount = 0;

    final now = DateTime.now();
    for (var tx in salesState.transactions) {
      if (tx.status.toUpperCase() == 'PENDING') continue;
      if (tx.status.toUpperCase() == 'FAILED') {
        failedCount++;
        continue;
      }
      if (tx.amount > 0 && tx.status.toUpperCase() == 'SUCCESS') {
        successCount++;
        final txDate = TimeUtils.parseLocal(tx.createdAt) ?? now;
        final diffDays = now.difference(txDate).inDays;
        if (diffDays == 0 && now.day == txDate.day) todayRevenue += tx.amount;
        if (diffDays <= 30) monthRevenue += tx.amount;
      }
    }

    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait<void>([
          ref.read(salesProvider.notifier).refresh(),
          ref.read(commissionsProvider.notifier).refresh(),
        ]);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // KPI Cards
            _stagger(0, child: Row(children: [
              Expanded(child: _RevenueKpi(title: 'TODAY SALES', value: currency.format(todayRevenue), sub: 'Gross earnings', accent: AppColors.amber, icon: LucideIcons.sun)),
              const SizedBox(width: 12),
              Expanded(child: _RevenueKpi(title: 'NET REVENUE', value: currency.format(summary?.totalCommissionEarned ?? monthRevenue * 0.05), sub: 'Commission earned', accent: AppColors.primary, icon: LucideIcons.trendingUp)),
              const SizedBox(width: 12),
              Expanded(child: _RevenueKpi(title: 'TOTAL EARNINGS', value: currency.format(summary?.totalEarnings ?? monthRevenue), sub: 'Settlement snapshot', accent: AppColors.cyan, icon: LucideIcons.wallet)),
              const SizedBox(width: 12),
              Expanded(child: _RevenueKpi(title: 'PENDING PAYOUT', value: currency.format(pendingRevenue), sub: 'Awaiting transfer', accent: AppColors.amber, icon: LucideIcons.clock)),
            ])),
            const SizedBox(height: 16),

            // Quick stats row
            _stagger(1, child: Row(children: [
              Expanded(child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(LucideIcons.checkCircle, size: 16, color: AppColors.primary)),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('$successCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const Text('Successful', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                  ]),
                ]),
              )),
              const SizedBox(width: 12),
              Expanded(child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(LucideIcons.xCircle, size: 16, color: AppColors.red)),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('$failedCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const Text('Failed', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                  ]),
                ]),
              )),
              const SizedBox(width: 12),
              Expanded(child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.purple.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(LucideIcons.receipt, size: 16, color: AppColors.purple)),
                  const SizedBox(width: 12),
                  Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${salesState.transactions.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const Text('Total Txns', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                  ])),
                ]),
              )),
              const Spacer(),
              OutlinedButton.icon(
                icon: const Icon(LucideIcons.download, size: 14),
                label: const Text('Export Statement', style: TextStyle(fontSize: 12)),
                onPressed: () {
                  final now = DateTime.now();
                  ExportHelper.exportTransactionsToCsv(salesState.transactions, 'sales_report_${DateFormat('yyyyMMdd').format(now)}.csv');
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sales report downloaded'), backgroundColor: AppColors.primary));
                },
              ),
            ])),
            const SizedBox(height: 16),

            // Transactions Table + Detail Panel
            _stagger(2, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: _selectedTransaction != null ? 3 : 1, child: Container(
                decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(padding: const EdgeInsets.all(18), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Recent Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    TextButton.icon(
                      icon: const Icon(LucideIcons.refreshCw, size: 14),
                      label: const Text('Refresh', style: TextStyle(fontSize: 12)),
                      onPressed: () => ref.read(salesProvider.notifier).refresh(),
                    )
                  ])),
                  const Divider(height: 1),
                  ClipRRect(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)), child: salesState.isLoading
                    ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
                    : salesState.error != null
                      ? Padding(padding: const EdgeInsets.all(40), child: Center(child: Text('Error: ${salesState.error}', style: const TextStyle(color: AppColors.red))))
                      : salesState.transactions.isEmpty
                        ? const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('No transactions found', style: TextStyle(color: AppColors.textSecondary))))
                        : SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
                            headingRowColor: WidgetStateProperty.all(AppColors.pageBg.withValues(alpha: 0.5)),
                            columns: const [
                              DataColumn(label: Text('TXN ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                              DataColumn(label: Text('LOCAL TIME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                              DataColumn(label: Text('CUSTOMER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                              DataColumn(label: Text('STATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                              DataColumn(label: Text('TYPE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                              DataColumn(label: Text('AMOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                              DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                              DataColumn(label: Text('', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            ],
                            rows: salesState.transactions.map((tx) {
                              final dateStr = TimeUtils.longDateTime(tx.createdAt);
                              final isCredit = tx.amount >= 0 && tx.transactionType != 'REFUND';
                              final amtStr = isCredit ? '+ ${currency.format(tx.amount)}' : '- ${currency.format(tx.amount.abs())}';
                              final statusUpper = tx.status.toUpperCase();
                              final statusColor = statusUpper == 'SUCCESS' ? AppColors.primary : statusUpper == 'FAILED' ? AppColors.red : AppColors.amber;
                              final isSelected = _selectedTransaction?.id == tx.id;

                              return DataRow(
                                selected: isSelected,
                                color: WidgetStateProperty.resolveWith((states) => isSelected ? AppColors.primary.withValues(alpha: 0.06) : null),
                                onSelectChanged: (_) {
                                  _selectTransaction(tx);
                                },
                                cells: [
                                  DataCell(Text('TXN-${tx.id}', style: const TextStyle(fontFamily: 'monospace', color: AppColors.textTertiary, fontSize: 12))),
                                  DataCell(Text(dateStr, style: const TextStyle(fontSize: 12))),
                                  DataCell(Text(_displayText(tx.customerName), style: const TextStyle(fontSize: 12))),
                                  DataCell(Text(_displayText(tx.stationName), style: const TextStyle(fontSize: 12))),
                                  DataCell(Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: AppColors.cyan.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(4)),
                                    child: Text(tx.transactionType.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.cyan, fontWeight: FontWeight.w600)),
                                  )),
                                  DataCell(Text(amtStr, style: TextStyle(color: isCredit ? AppColors.primary : AppColors.red, fontWeight: FontWeight.w700))),
                                  DataCell(Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: statusColor.withValues(alpha: 0.3))),
                                    child: Text(statusUpper, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
                                  )),
                                  const DataCell(Icon(LucideIcons.chevronRight, size: 14, color: AppColors.textMuted)),
                                ],
                              );
                            }).toList(),
                          )),
                  ),
                ]),
              )),

              // Detail Side Panel
              if (_selectedTransaction != null) ...[
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _isLoadingDetail
                      ? _buildDetailLoading()
                      : _detailError != null
                          ? _buildDetailError(_detailError!)
                          : _buildTransactionDetailPanel(_selectedTransaction!, currency),
                ),
              ],
            ])),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionDetailPanel(TransactionDto tx, NumberFormat currency) {
    final dateStr = TimeUtils.longDateTime(tx.createdAt);
    final isCredit = tx.amount >= 0 && tx.transactionType != 'REFUND';
    final amtStr = isCredit ? '+ ${currency.format(tx.amount)}' : '- ${currency.format(tx.amount.abs())}';
    final statusUpper = tx.status.toUpperCase();
    final statusColor = statusUpper == 'SUCCESS' ? AppColors.primary : statusUpper == 'FAILED' ? AppColors.red : AppColors.amber;

    return Container(
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppColors.pageBg, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: (isCredit ? AppColors.primary : AppColors.amber).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(isCredit ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight, size: 16, color: isCredit ? AppColors.primary : AppColors.amber),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Transaction #${tx.id}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Text(dateStr, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
            ])),
            IconButton(icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textTertiary), onPressed: () => setState(() => _selectedTransaction = null)),
          ]),
        ),
        const Divider(height: 1),

        // Body
        Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('AMOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(amtStr, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: isCredit ? AppColors.primary : AppColors.red)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: statusColor.withValues(alpha: 0.3))),
              child: Text(statusUpper, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 24),
          
          const Text('TRANSACTION DETAILS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          _infoRow('Customer', tx.customerName ?? 'N/A'),
          _infoRow('Type', tx.transactionType.toUpperCase()),
          _infoRow('Station', tx.stationName ?? 'N/A'),
          _infoRow('Battery ID', tx.batteryId ?? 'N/A'),
          _infoRow('Phone', _displayText(tx.customerPhone)),
          _infoRow('Terminal', _displayText(tx.terminalNumber)),
          _infoRow('Duration', _displayText(tx.duration)),
          const SizedBox(height: 10),
          _infoRow('Fee/Commission', currency.format(tx.platformFee)),
          _infoRow('Net to Dealer', currency.format(tx.netAmount)),
          _infoRow('Payment Method', _displayText(tx.paymentMethod)),
          _infoRow('Settlement Status', _displayText(tx.settlementStatus)),
          _infoRow('Expected Settlement', tx.expectedSettlementDate != null ? TimeUtils.longDateTime(tx.expectedSettlementDate) : '—'),
          const SizedBox(height: 10),
          _infoRow('Description', _displayText(tx.description, fallback: 'No description')),
          const SizedBox(height: 24),

          // Actions
          if (statusUpper == 'SUCCESS')
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              icon: const Icon(LucideIcons.download, size: 14),
              label: const Text('Download Receipt', style: TextStyle(fontSize: 12)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt downloaded'), backgroundColor: AppColors.primary));
              },
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            )),
          if (statusUpper == 'PENDING')
             SizedBox(width: double.infinity, child: ElevatedButton.icon(
              icon: const Icon(LucideIcons.refreshCw, size: 14),
              label: const Text('Check Status', style: TextStyle(fontSize: 12)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status checked'), backgroundColor: AppColors.primary));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 12)),
            )),
        ])),
      ]),
    );
  }

  Widget _buildDetailLoading() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildDetailError(String message) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.alertTriangle,
                  color: AppColors.amber, size: 20),
              const SizedBox(height: 10),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      const SizedBox(width: 16),
      Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
    ]);
  }

  String _displayText(String? value, {String fallback = '—'}) {
    final text = value?.trim();
    if (text == null || text.isEmpty || text.toLowerCase() == 'null') {
      return fallback;
    }
    return text;
  }
}

class _RevenueKpi extends StatefulWidget {
  final String title, value, sub; final Color accent; final IconData icon;
  const _RevenueKpi({required this.title, required this.value, required this.sub, required this.accent, required this.icon});
  @override
  State<_RevenueKpi> createState() => _RevenueKpiState();
}

class _RevenueKpiState extends State<_RevenueKpi> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.cardBgHover : AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _hovered ? widget.accent.withValues(alpha: 0.2) : AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 2, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: widget.accent, borderRadius: BorderRadius.circular(1), boxShadow: [BoxShadow(color: widget.accent.withValues(alpha: 0.4), blurRadius: 6)])),
          Row(children: [
            Container(width: 28, height: 28, decoration: BoxDecoration(color: widget.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: Icon(widget.icon, size: 14, color: widget.accent)),
            const SizedBox(width: 8),
            Text(widget.title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.8)),
          ]),
          const SizedBox(height: 12),
          Text(widget.value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.8)),
          const SizedBox(height: 8),
          Text(widget.sub, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: widget.accent)),
        ]),
      ),
    );
  }
}
