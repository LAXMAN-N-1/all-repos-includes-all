import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../models/sales_state.dart';
import '../../../core/utils/export_helper.dart';

class TransactionDetailDrawer extends StatelessWidget {
  final TransactionDto tx;

  const TransactionDetailDrawer({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final isIncome = tx.transactionType != 'REFUND';
    final amountColor = isIncome ? Colors.green : AppColors.red;

    return Drawer(
      width: 480,
      backgroundColor: AppColors.cardBg,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(currency, amountColor),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Customer Information'),
                  _buildDetailRow('Name', tx.customerName ?? 'Unknown', isLink: true),
                  _buildDetailRow('Phone', tx.customerPhone ?? 'N/A'),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Technical Details'),
                  _buildDetailRow('Battery ID', tx.batteryId ?? 'N/A', isLink: true),
                  _buildDetailRow('Station', tx.stationName ?? 'N/A'),
                  _buildDetailRow('Terminal', tx.terminalNumber ?? 'N/A'),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Rental Details'),
                  _buildDetailRow('Start Time', tx.createdAt),
                  _buildDetailRow('End Time', tx.expectedSettlementDate ?? 'Ongoing'),
                  _buildDetailRow('Duration', tx.duration ?? 'N/A'),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Financial Breakdown'),
                  _buildDetailRow('Gross Amount', currency.format(tx.amount)),
                  _buildDetailRow('Platform Fee', '- ${currency.format(tx.platformFee)}', valueColor: AppColors.red),
                  _buildDetailRow('Commission Rate', '${(tx.commissionRate * 100).toStringAsFixed(0)}%'),
                  _buildDetailRow('Commission Amt', currency.format(tx.commissionAmount), valueColor: AppColors.cyan),
                  const Divider(color: AppColors.border, height: 24),
                  _buildDetailRow('Net to Dealer', currency.format(tx.netAmount), isBold: true, valueColor: Colors.green),
                  _buildDetailRow('Payment Method', tx.paymentMethod ?? 'UPI'),
                  _buildDetailRow('Gateway Ref', 'PG-${tx.id}001', isCopyable: true),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Settlement info'),
                  _buildDetailRow('Status', tx.settlementStatus ?? 'Pending'),
                  _buildDetailRow('Expected Date', tx.expectedSettlementDate ?? 'TBD'),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Transaction Lifecycle'),
                  const SizedBox(height: 16),
                  _buildEnhancedTimeline(),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 48, 24, 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Transaction Details', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('TXN-${tx.id}', style: const TextStyle(color: AppColors.cyan, fontFamily: 'monospace', fontSize: 13)),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  ExportHelper.exportTransactionsToCsv([tx], 'transaction_${tx.id}.csv');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Receipt downloaded for TXN-${tx.id}"), backgroundColor: Colors.green),
                  );
                },
                icon: const Icon(LucideIcons.download, size: 20, color: AppColors.textTertiary),
                tooltip: 'Download Receipt',
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(LucideIcons.x, color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(NumberFormat currency, Color amountColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.pageBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(currency.format(tx.amount), style: TextStyle(color: amountColor, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge(tx.status, _getStatusColor(tx.status)),
              const SizedBox(width: 12),
              _buildBadge(tx.transactionType, AppColors.textSecondary, isOutline: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLink = false, bool isBold = false, Color? valueColor, bool isCopyable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: isLink ? AppColors.primary : (valueColor ?? Colors.white),
                  fontSize: 13,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  decoration: isLink ? TextDecoration.underline : null,
                ),
              ),
              if (isCopyable) ...[
                const SizedBox(width: 8),
                const Icon(LucideIcons.copy, size: 12, color: AppColors.textTertiary),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color, {bool isOutline = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOutline ? Colors.transparent : color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEnhancedTimeline() {
    final stages = [
      'Rental Started',
      'Payment Initiated',
      'Payment Captured',
      'Commission Calculated',
      'Settlement Queued',
      'Settlement Completed',
    ];

    int currentStage = 0;
    if (tx.status == 'SUCCESS') currentStage = 2;
    if (tx.settlementStatus == 'QUEUED') currentStage = 4;
    if (tx.settlementStatus == 'COMPLETED') currentStage = 5;

    return Column(
      children: List.generate(stages.length, (index) {
        final isCompleted = index <= currentStage;
        final isLast = index == stages.length - 1;
        return _TimelineItem(
          title: stages[index],
          timestamp: isCompleted ? 'Today, 10:45' : 'Pending',
          isCompleted: isCompleted,
          isLast: isLast,
          isPulsing: index == currentStage + 1,
        );
      }),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                ExportHelper.exportTransactionsToPdf([tx], 'receipt_${tx.id}.pdf');
              },
              icon: const Icon(LucideIcons.fileText, size: 16),
              label: const Text('Download Receipt', style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.alertTriangle, size: 16),
              label: const Text('Raise Dispute', style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.amber,
                side: BorderSide(color: AppColors.amber.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.externalLink, size: 16),
              label: const Text('Linked Ticket', style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cyan,
                side: BorderSide(color: AppColors.cyan.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED': case 'SUCCESS': return Colors.green;
      case 'PENDING': return AppColors.amber;
      case 'FAILED': return AppColors.red;
      case 'REFUNDED': return Colors.orange;
      default: return AppColors.textTertiary;
    }
  }
}

class _TimelineItem extends StatefulWidget {
  final String title;
  final String timestamp;
  final bool isCompleted;
  final bool isLast;
  final bool isPulsing;

  const _TimelineItem({
    required this.title,
    required this.timestamp,
    required this.isCompleted,
    required this.isLast,
    this.isPulsing = false,
  });

  @override
  State<_TimelineItem> createState() => _TimelineItemState();
}

class _TimelineItemState extends State<_TimelineItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (widget.isPulsing)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: AppColors.amber.withOpacity(0.3 + (0.7 * _controller.value)),
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.amber.withOpacity(0.2 * _controller.value),
                          blurRadius: 8 * _controller.value,
                          spreadRadius: 2 * _controller.value,
                        ),
                      ],
                    ),
                  );
                },
              )
            else
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: widget.isCompleted ? Colors.green : Colors.transparent,
                  border: Border.all(color: widget.isCompleted ? Colors.green : AppColors.border, width: 2),
                  shape: BoxShape.circle,
                ),
              ),
            if (!widget.isLast)
              Container(
                width: 2,
                height: 40,
                color: widget.isCompleted ? Colors.green.withOpacity(0.3) : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: widget.isCompleted ? FontWeight.bold : FontWeight.normal)),
            const SizedBox(height: 4),
            Text(widget.timestamp, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
