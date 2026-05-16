import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/theme/app_theme.dart';
import '../services/wallet_service.dart';
import '../models/transaction.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/widgets/responsive_wrapper.dart';
import '../../../core/network/dio_provider.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen> {
  late final WalletService _walletService = WalletService(ref.read(authenticatedDioProvider));
  List<Transaction> _transactions = [];
  String _selectedFilter = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final txns = await _walletService.getTransactionHistory();
    if (mounted) {
      setState(() {
        _transactions = txns;
        _isLoading = false;
      });
    }
  }

  List<Transaction> get _filteredTransactions {
    if (_selectedFilter == 'All') return _transactions;
    return _transactions.where((txn) {
      switch (_selectedFilter) {
        case 'Rentals':
          return txn.type == TransactionType.rental;
        case 'Withdrawals':
          return txn.type == TransactionType.withdrawal;
        case 'Purchases':
          return txn.type == TransactionType.purchase;
        case 'Refunds':
          return txn.type == TransactionType.refund;
        case 'Wallet':
          return txn.type == TransactionType.walletTopUp;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Transaction History',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search),
            onPressed: () {}, // Search placeholder
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentGreen))
          : Column(
              children: [
                _buildFilterBar(),
                Expanded(
                  child: _filteredTransactions.isEmpty
                      ? Center(
                          child: Text('No transactions found',
                              style: TextStyle(color: AppTheme.textSecondary)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: _filteredTransactions.length,
                          itemBuilder: (context, index) =>
                              _buildTransactionCard(
                                  _filteredTransactions[index]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('All'),
          _buildFilterChip('Rentals'),
          _buildFilterChip('Withdrawals'),
          _buildFilterChip('Purchases'),
          _buildFilterChip('Refunds'),
          _buildFilterChip('Wallet'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedFilter = label);
          }
        },
        backgroundColor: AppTheme.surfaceDark,
        selectedColor: AppTheme.primaryBlue,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction txn) {
    final isWithdrawal = txn.type == TransactionType.withdrawal;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isWithdrawal
              ? Colors.redAccent.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          width: isWithdrawal ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildLargeIcon(txn),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(txn.description,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      TimeUtils.longDateFromDt(txn.date),
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(txn.status),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                txn.method.name.toUpperCase(),
                style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                '\$${txn.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (txn.status == TransactionStatus.success)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final path = await _walletService
                          .downloadTransactionInvoice(txn.id);
                      if (path != null) {
                        await OpenFilex.open(path);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Failed to download invoice')),
                        );
                      }
                    },
                    icon: const Icon(LucideIcons.download, size: 14),
                    label:
                        const Text('RECEIPT', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBlue,
                      side: const BorderSide(color: AppTheme.primaryBlue),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.helpCircle, size: 14),
                  label: const Text('SUPPORT', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: Colors.white10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLargeIcon(Transaction txn) {
    IconData iconData;
    Color color;

    switch (txn.type) {
      case TransactionType.rental:
        iconData = LucideIcons.batteryCharging;
        color = AppTheme.primaryBlue;
        break;
      case TransactionType.purchase:
        iconData = LucideIcons.shoppingBag;
        color = AppTheme.accentGreen;
        break;
      case TransactionType.walletTopUp:
        iconData = LucideIcons.wallet;
        color = Colors.purpleAccent;
        break;
      case TransactionType.refund:
        iconData = LucideIcons.refreshCcw;
        color = Colors.orangeAccent;
        break;
      case TransactionType.withdrawal:
        iconData = LucideIcons.arrowUpRight;
        color = Colors.redAccent;
        break;
      default:
        iconData = LucideIcons.receipt;
        color = Colors.white70;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(iconData, color: color, size: 24),
    );
  }

  Widget _buildStatusBadge(TransactionStatus status) {
    Color color;
    String label;

    switch (status) {
      case TransactionStatus.success:
        color = AppTheme.accentGreen;
        label = 'SUCCESS';
        break;
      case TransactionStatus.approved:
        color = Colors.blueAccent;
        label = 'APPROVED';
        break;
      case TransactionStatus.rejected:
        color = Colors.redAccent;
        label = 'REJECTED';
        break;
      case TransactionStatus.failed:
        color = Colors.redAccent;
        label = 'FAILED';
        break;
      case TransactionStatus.refunded:
        color = Colors.orangeAccent;
        label = 'REFUNDED';
        break;
      case TransactionStatus.processing:
        color = AppTheme.primaryBlue;
        label = 'PENDING';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

}