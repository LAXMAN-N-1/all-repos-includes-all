import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'wallet_view_model.dart';

/// Dedicated page that shows transactions filtered by [filter].
/// Each row taps through to TransactionDetailScreen via named route.
class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key, required this.filter});

  final TransactionFilter filter;

  // ── Label helpers ──────────────────────────────────────────────────────────
  static const _titles = {
    TransactionFilter.all: 'All Transactions',
    TransactionFilter.pending: 'Pending Transactions',
    TransactionFilter.approved: 'Approved Transactions',
    TransactionFilter.rejected: 'Rejected Transactions',
    TransactionFilter.credits: 'Credit Transactions',
  };

  static const _subtitles = {
    TransactionFilter.all: 'Every transaction in your wallet history.',
    TransactionFilter.pending: 'Withdrawals waiting for admin approval.',
    TransactionFilter.approved:
        'Withdrawals that have been approved and are being processed.',
    TransactionFilter.rejected:
        'Withdrawals that were declined. Contact support if needed.',
    TransactionFilter.credits:
        'Money added to your wallet from deliveries and bonuses.',
  };

  static const _emptyMessages = {
    TransactionFilter.all: 'No transactions yet.',
    TransactionFilter.pending: 'No pending withdrawals.',
    TransactionFilter.approved: 'No approved withdrawals yet.',
    TransactionFilter.rejected: 'No rejected withdrawals.',
    TransactionFilter.credits: 'No credit transactions yet.',
  };

  // ── Filter logic ──────────────────────────────────────────────────────────
  List<WalletTransaction> _filter(List<WalletTransaction> all) {
    switch (filter) {
      case TransactionFilter.all:
        return all;
      case TransactionFilter.pending:
        return all.where((t) => t.status == TransactionStatus.pending).toList();
      case TransactionFilter.approved:
        return all
            .where((t) => t.status == TransactionStatus.approved)
            .toList();
      case TransactionFilter.rejected:
        return all
            .where((t) => t.status == TransactionStatus.rejected)
            .toList();
      case TransactionFilter.credits:
        return all.where((t) => t.type == TransactionType.credit).toList();
    }
  }

  // ── Status colour per filter ───────────────────────────────────────────────
  Color _headerColor() {
    switch (filter) {
      case TransactionFilter.pending:
        return const Color(0xFFFFA726);
      case TransactionFilter.approved:
        return const Color(0xFF1565C0);
      case TransactionFilter.rejected:
        return const Color(0xFFC62828);
      case TransactionFilter.credits:
        return const Color(0xFF2E7D32);
      case TransactionFilter.all:
        return const Color(0xFF233D4C);
    }
  }

  IconData _headerIcon() {
    switch (filter) {
      case TransactionFilter.pending:
        return Icons.hourglass_top_rounded;
      case TransactionFilter.approved:
        return Icons.verified_rounded;
      case TransactionFilter.rejected:
        return Icons.cancel_rounded;
      case TransactionFilter.credits:
        return Icons.arrow_downward_rounded;
      case TransactionFilter.all:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WalletViewModel>();
    final transactions = _filter(vm.transactions);
    final color = _headerColor();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(_titles[filter]!),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF233D4C),
        elevation: 0.5,
      ),
      body: CustomScrollView(
        slivers: [
          // ── Coloured header banner ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: _HeaderBanner(
              title: _titles[filter]!,
              subtitle: _subtitles[filter]!,
              color: color,
              icon: _headerIcon(),
              count: transactions.length,
            ),
          ),

          // ── Transaction list ───────────────────────────────────────────────
          if (transactions.isEmpty)
            SliverFillRemaining(
              child: _EmptyState(
                message: _emptyMessages[filter]!,
                icon: _headerIcon(),
                color: color,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final txn = transactions[i];
                  return _TransactionRow(
                    txn: txn,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/transaction-detail',
                      arguments: txn,
                    ),
                  );
                }, childCount: transactions.length),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Header Banner ────────────────────────────────────────────────────────────

class _HeaderBanner extends StatelessWidget {
  const _HeaderBanner({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.count,
  });

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count transaction${count == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Transaction Row ──────────────────────────────────────────────────────────

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.txn, required this.onTap});

  final WalletTransaction txn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCredit = txn.type == TransactionType.credit;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: txn.isWithdrawal ? const Color(0xFFFFF8F2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              if (txn.isWithdrawal) Container(width: 4, color: txn.statusColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  child: Row(
                    children: [
                      // Leading icon circle
                      _TxnIcon(txn: txn),
                      const SizedBox(width: 12),

                      // Title + date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              txn.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF233D4C),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              txn.formattedDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Status chip
                            _StatusChip(status: txn.status),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Amount + chevron
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            txn.formattedAmount,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isCredit
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFC62828),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Icon circle ──────────────────────────────────────────────────────────────

class _TxnIcon extends StatelessWidget {
  const _TxnIcon({required this.txn});
  final WalletTransaction txn;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color bg;
    final Color fg;

    if (txn.isWithdrawal) {
      icon = Icons.account_balance_rounded;
      bg = txn.statusColor.withValues(alpha: 0.12);
      fg = txn.statusColor;
    } else if (txn.type == TransactionType.credit) {
      icon = Icons.arrow_downward_rounded;
      bg = Colors.green[50]!;
      fg = Colors.green;
    } else {
      icon = Icons.arrow_upward_rounded;
      bg = Colors.red[50]!;
      fg = Colors.red;
    }

    return CircleAvatar(
      radius: 22,
      backgroundColor: bg,
      child: Icon(icon, size: 20, color: fg),
    );
  }
}

// ─── Status Chip ─────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final TransactionStatus status;

  static const _labels = {
    TransactionStatus.pending: 'PENDING',
    TransactionStatus.approved: 'APPROVED',
    TransactionStatus.completed: 'COMPLETED',
    TransactionStatus.rejected: 'REJECTED',
    TransactionStatus.failed: 'FAILED',
  };

  static const _colors = {
    TransactionStatus.pending: Color(0xFFFFA726),
    TransactionStatus.approved: Color(0xFF1565C0),
    TransactionStatus.completed: Color(0xFF2E7D32),
    TransactionStatus.rejected: Color(0xFFC62828),
    TransactionStatus.failed: Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[status] ?? Colors.grey;
    final label = _labels[status] ?? status.name.toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
    required this.icon,
    required this.color,
  });

  final String message;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 52, color: color),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF233D4C),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Pull down to refresh your transaction history.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
