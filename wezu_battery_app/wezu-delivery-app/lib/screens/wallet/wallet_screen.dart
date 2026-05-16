import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'wallet_view_model.dart';
import 'bank_accounts_screen.dart';
import 'withdraw_to_bank_screen.dart';
import '../../services/invoice_service.dart';
import 'invoice_viewer_screen.dart';
import 'cashback_offers_carousel.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  static const _charcoal = Color(0xFF233D4C);
  static const _accent = Color(0xFFFD802E);

  @override
  void initState() {
    super.initState();
    // Kick off offers fetch once (idempotent — offersLoading guard inside).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletViewModel>().fetchOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Wallet',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF233D4C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<WalletViewModel>(
        builder: (context, vm, _) {
          return RefreshIndicator(
            color: _accent,
            onRefresh: vm.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBalanceCard(context, vm),
                  const SizedBox(height: 24),
                  if (vm.offers.isNotEmpty || vm.offersLoading) ...[
                    const Text(
                      'Special Offers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF233D4C),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CashbackOffersCarousel(
                      offers: vm.offers,
                      isLoading: vm.offersLoading,
                    ),
                    const SizedBox(height: 24),
                  ],
                  _buildScratchCardSection(),
                  const SizedBox(height: 24),
                  _buildBankAccountsSection(context, vm),
                  const SizedBox(height: 24),
                  _buildTransactionsSection(context, vm),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Balance Card ──────────────────────────────────────────────────────────

  Widget _buildBalanceCard(BuildContext context, WalletViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF233D4C), Color(0xFF1A2E39)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Available Balance',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${vm.balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/payout-request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Request Payout'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: vm,
                      child: const WithdrawToBankScreen(),
                    ),
                  ),
                ),
                icon: const Icon(Icons.account_balance_rounded, size: 18),
                label: const Text('Withdraw'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _charcoal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/peer-transfer'),
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Send'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _charcoal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Daily Scratch Card ────────────────────────────────────────────────────

  Widget _buildScratchCardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daily Scratch Card',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '1 remaining today',
                style: TextStyle(
                  color: _accent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Scratch to reveal your reward!',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFD802E), Color(0xFFFF6B35)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _accent.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, color: Colors.white, size: 36),
              const SizedBox(height: 8),
              const Text(
                'Scratch Here!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'New card available tomorrow',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Bank Accounts ─────────────────────────────────────────────────────────

  Widget _buildBankAccountsSection(BuildContext context, WalletViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bank Accounts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: vm,
                    child: const BankAccountsScreen(),
                  ),
                ),
              ),
              child: const Text('Manage'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (vm.bankAccounts.isEmpty)
          const Text('No bank accounts linked.')
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance, color: _charcoal),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vm.bankAccounts.first.bankName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      vm.bankAccounts.first.accountNumber,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const Spacer(),
                if (vm.bankAccounts.first.isPrimary)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PRIMARY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  // ─── Transactions ──────────────────────────────────────────────────────────

  Widget _buildTransactionsSection(BuildContext context, WalletViewModel vm) {
    // Show the 5 most recent as a quick preview on the wallet screen
    final recent = vm.transactions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header + View All
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transaction History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(
                context,
                '/transaction-list',
                arguments: TransactionFilter.all,
              ),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Filter navigation chips — each opens a dedicated list page
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _NavChip(
                label: 'All',
                icon: Icons.receipt_long_rounded,
                color: const Color(0xFF233D4C),
                count: vm.transactions.length,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/transaction-list',
                  arguments: TransactionFilter.all,
                ),
              ),
              _NavChip(
                label: 'Pending',
                icon: Icons.hourglass_top_rounded,
                color: const Color(0xFFFFA726),
                count: vm.transactions
                    .where((t) => t.status == TransactionStatus.pending)
                    .length,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/transaction-list',
                  arguments: TransactionFilter.pending,
                ),
              ),
              _NavChip(
                label: 'Approved',
                icon: Icons.verified_rounded,
                color: const Color(0xFF1565C0),
                count: vm.transactions
                    .where((t) => t.status == TransactionStatus.approved)
                    .length,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/transaction-list',
                  arguments: TransactionFilter.approved,
                ),
              ),
              _NavChip(
                label: 'Rejected',
                icon: Icons.cancel_rounded,
                color: const Color(0xFFC62828),
                count: vm.transactions
                    .where((t) => t.status == TransactionStatus.rejected)
                    .length,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/transaction-list',
                  arguments: TransactionFilter.rejected,
                ),
              ),
              _NavChip(
                label: 'Credits',
                icon: Icons.arrow_downward_rounded,
                color: const Color(0xFF2E7D32),
                count: vm.transactions
                    .where((t) => t.type == TransactionType.credit)
                    .length,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/transaction-list',
                  arguments: TransactionFilter.credits,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Recent preview
        if (recent.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No transactions yet',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          )
        else ...[
          const Text(
            'Recent',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF233D4C),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          ...recent.map(
            (txn) => GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                '/transaction-detail',
                arguments: txn,
              ),
              child: _TransactionCard(txn: txn),
            ),
          ),
          if (vm.transactions.length > 5)
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/transaction-list',
                  arguments: TransactionFilter.all,
                ),
                icon: const Icon(Icons.expand_more_rounded),
                label: Text('See all ${vm.transactions.length} transactions'),
              ),
            ),
        ],
      ],
    );
  }
}

// ─── Nav Chip ─────────────────────────────────────────────────────────────────

class _NavChip extends StatelessWidget {
  const _NavChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.count,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios_rounded, size: 10, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Transaction Card ─────────────────────────────────────────────────────────

class _TransactionCard extends StatefulWidget {
  const _TransactionCard({required this.txn});
  final WalletTransaction txn;

  @override
  State<_TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<_TransactionCard> {
  bool _isDownloading = false;
  static const _accent = Color(0xFFFD802E);

  Future<void> _downloadInvoice() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    final service = InvoiceService();
    try {
      if (kIsWeb) {
        await service.downloadInvoice(
          id: widget.txn.id,
          type: InvoiceType.order,
        );
      } else {
        final file = await service.downloadInvoice(
          id: widget.txn.id,
          type: InvoiceType.order,
        );
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InvoiceViewerScreen(
                pdfFile: file,
                invoiceTitle: widget.txn.title,
              ),
            ),
          );
        }
      }
    } on UnsupportedError catch (e) {
      if (mounted) {
        final isWebDownload = e.message == 'web_download_triggered';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isWebDownload
                  ? 'Receipt downloaded to your browser Downloads folder.'
                  : 'Could not open invoice on this platform.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not download invoice. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      service.dispose();
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final txn = widget.txn;
    final isCredit = txn.type == TransactionType.credit;
    final isWithdrawal = txn.isWithdrawal;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isWithdrawal
            ? const Color(0xFFFFF8F2) // warm tint for withdrawals
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            if (isWithdrawal) Container(width: 4, color: txn.statusColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Leading icon
                    _TxnIcon(txn: txn),
                    const SizedBox(width: 12),

                    // Title + date + (withdrawal badge)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  txn.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isWithdrawal) ...[
                                const SizedBox(width: 6),
                                _methodBadge(txn.withdrawalMethod),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            txn.formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Amount + status chip
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          txn.formattedAmount,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isCredit
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFC62828),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _StatusChip(status: txn.status),
                      ],
                    ),

                    // Download button
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: _isDownloading
                          ? const Padding(
                              padding: EdgeInsets.all(6),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _accent,
                              ),
                            )
                          : IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.download_rounded,
                                size: 20,
                                color: _accent,
                              ),
                              tooltip: 'Download Invoice',
                              onPressed: _downloadInvoice,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _methodBadge(String? method) {
    if (method == null) return const SizedBox.shrink();
    final isUpi = method == 'upi';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isUpi ? const Color(0xFFE3F2FD) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isUpi ? 'UPI' : 'BANK',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isUpi ? const Color(0xFF1565C0) : const Color(0xFF2E7D32),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _TxnIcon extends StatelessWidget {
  const _TxnIcon({required this.txn});
  final WalletTransaction txn;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color bg;
    Color fg;

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
      radius: 20,
      backgroundColor: bg,
      child: Icon(icon, size: 18, color: fg),
    );
  }
}

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
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
