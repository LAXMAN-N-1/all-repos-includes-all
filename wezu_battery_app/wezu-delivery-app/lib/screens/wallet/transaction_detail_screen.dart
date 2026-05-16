import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'wallet_view_model.dart';
import '../../services/invoice_service.dart';
import 'invoice_viewer_screen.dart';

/// Full-detail view for a single wallet transaction.
/// Includes status timeline, breakdown, and receipt download/share.
class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({super.key, required this.transaction});

  final WalletTransaction transaction;

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  static const _charcoal = Color(0xFF233D4C);

  bool _isDownloading = false;
  bool _isSharing = false;
  File? _cachedFile;
  // Single reused service instance — disposed in dispose()
  final _invoiceService = InvoiceService();

  WalletTransaction get txn => widget.transaction;

  @override
  void dispose() {
    _invoiceService.dispose();
    super.dispose();
  }

  // ─── Receipt download ───────────────────────────────────────────────────────

  Future<File?> _ensureNativeFile() async {
    if (kIsWeb) return null;
    _cachedFile ??= await _invoiceService.downloadInvoice(
      id: txn.id,
      type: InvoiceType.order,
    );
    return _cachedFile;
  }

  Future<void> _downloadReceipt() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      if (kIsWeb) {
        // Fires a dart:html Blob download — browser saves to Downloads folder.
        await _invoiceService.downloadInvoice(
          id: txn.id,
          type: InvoiceType.order,
        );
      } else {
        final file = await _ensureNativeFile();
        if (mounted && file != null) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InvoiceViewerScreen(
                pdfFile: file,
                invoiceTitle: 'Receipt – ${txn.id}',
              ),
            ),
          );
        }
      }
    } on UnsupportedError catch (e) {
      // 'web_download_triggered' means the browser download was started — success.
      if (mounted) {
        if (e.message == 'web_download_triggered') {
          _showSnack('Receipt saved to Downloads folder.', green: true);
        } else {
          _showSnack('Download not supported on this platform.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnack(
          e.toString().contains('MissingPluginException')
              ? 'Plugin not ready. Please do a full app restart.'
              : 'Download failed. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _shareReceipt() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      if (kIsWeb) {
        // Web Share API for File blobs is unreliable; download instead.
        await _invoiceService.shareInvoice(
          null,
          subject: 'Wezu Receipt – ${txn.id}',
          id: txn.id,
          type: InvoiceType.order,
        );
        if (mounted) {
          _showSnack('Receipt saved to Downloads folder.', green: true);
        }
      } else {
        final file = await _ensureNativeFile();
        if (mounted && file != null) {
          await _invoiceService.shareInvoice(
            file,
            subject: 'Wezu Receipt – ${txn.id}',
            id: txn.id,
            type: InvoiceType.order,
          );
        }
      }
    } on UnsupportedError {
      if (mounted) {
        _showSnack('Sharing is not supported on this platform.');
      }
    } catch (e) {
      if (mounted) {
        _showSnack(
          e.toString().contains('MissingPluginException')
              ? 'Plugin not ready. Please restart the app and try again.'
              : 'Share failed. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _showSnack(String msg, {bool green = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: green ? Colors.green[700] : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isCredit = txn.type == TransactionType.credit;
    final amountColor = isCredit
        ? const Color(0xFF2E7D32)
        : const Color(0xFFC62828);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: Colors.white,
        foregroundColor: _charcoal,
        elevation: 0.5,
        actions: [
          // Copy transaction ID
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 20),
            tooltip: 'Copy Transaction ID',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: txn.id));
              _showSnack('Transaction ID copied', green: true);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero amount card ──────────────────────────────────────────────
            _AmountHeroCard(txn: txn, amountColor: amountColor),
            const SizedBox(height: 20),

            // ── Status timeline (only for withdrawals) ────────────────────────
            if (txn.isWithdrawal) ...[
              _StatusTimeline(status: txn.status),
              const SizedBox(height: 20),
            ],

            // ── Details table ─────────────────────────────────────────────────
            _DetailTable(txn: txn),
            const SizedBox(height: 20),

            // ── Destination details (bank / UPI) ─────────────────────────────
            if (txn.isWithdrawal) ...[
              _DestinationCard(txn: txn),
              const SizedBox(height: 20),
            ],

            // ── Receipt actions ───────────────────────────────────────────────
            _ReceiptActions(
              isDownloading: _isDownloading,
              isSharing: _isSharing,
              onDownload: _downloadReceipt,
              onShare: _shareReceipt,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Hero amount card ─────────────────────────────────────────────────────────

class _AmountHeroCard extends StatelessWidget {
  const _AmountHeroCard({required this.txn, required this.amountColor});

  final WalletTransaction txn;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    final isWithdrawal = txn.isWithdrawal;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isWithdrawal
            ? Border.all(
                color: txn.statusColor.withValues(alpha: 0.35),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon circle
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isWithdrawal
                  ? txn.statusColor.withValues(alpha: 0.12)
                  : (txn.type == TransactionType.credit
                        ? Colors.green[50]
                        : Colors.red[50]),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isWithdrawal
                  ? Icons.account_balance_rounded
                  : (txn.type == TransactionType.credit
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded),
              size: 28,
              color: isWithdrawal
                  ? txn.statusColor
                  : (txn.type == TransactionType.credit
                        ? Colors.green
                        : Colors.red),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            txn.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF233D4C),
            ),
          ),
          const SizedBox(height: 6),

          // Amount
          Text(
            txn.formattedAmount,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
          const SizedBox(height: 12),

          // Status chip
          _BigStatusChip(label: txn.statusLabel, color: txn.statusColor),
        ],
      ),
    );
  }
}

// ─── Status Timeline ──────────────────────────────────────────────────────────

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.status});

  final TransactionStatus status;

  @override
  Widget build(BuildContext context) {
    // Steps: Submitted → Under Review → Approved/Rejected → Completed
    final steps = [
      _TimelineStep(
        label: 'Submitted',
        done: true,
        active: status == TransactionStatus.pending,
      ),
      _TimelineStep(
        label: 'Under Review',
        done: status != TransactionStatus.pending,
        active: status == TransactionStatus.pending,
      ),
      _TimelineStep(
        label: status == TransactionStatus.rejected ? 'Rejected' : 'Approved',
        done:
            status == TransactionStatus.approved ||
            status == TransactionStatus.completed ||
            status == TransactionStatus.rejected,
        active: status == TransactionStatus.approved,
        isRejected: status == TransactionStatus.rejected,
      ),
      _TimelineStep(
        label: 'Completed',
        done: status == TransactionStatus.completed,
        active: status == TransactionStatus.completed,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Withdrawal Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF233D4C),
            ),
          ),
          const SizedBox(height: 16),
          _buildTimeline(steps),
        ],
      ),
    );
  }

  Widget _buildTimeline(List<_TimelineStep> steps) {
    return Column(
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        final isLast = i == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dot + line
            Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.isRejected
                        ? const Color(0xFFC62828)
                        : step.done
                        ? const Color(0xFF2E7D32)
                        : Colors.grey[300],
                    border: Border.all(
                      color: step.isRejected
                          ? const Color(0xFFC62828)
                          : step.done
                          ? const Color(0xFF2E7D32)
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    step.isRejected
                        ? Icons.close_rounded
                        : step.done
                        ? Icons.check_rounded
                        : Icons.circle,
                    size: step.done || step.isRejected ? 14 : 8,
                    color: step.done || step.isRejected
                        ? Colors.white
                        : Colors.grey[400],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 28,
                    color: step.done
                        ? const Color(0xFF2E7D32)
                        : Colors.grey[200],
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 28),
              child: Text(
                step.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: step.active || step.done
                      ? FontWeight.w700
                      : FontWeight.normal,
                  color: step.isRejected
                      ? const Color(0xFFC62828)
                      : step.done
                      ? const Color(0xFF233D4C)
                      : Colors.grey[500],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _TimelineStep {
  final String label;
  final bool done;
  final bool active;
  final bool isRejected;
  const _TimelineStep({
    required this.label,
    required this.done,
    required this.active,
    this.isRejected = false,
  });
}

// ─── Detail Table ─────────────────────────────────────────────────────────────

class _DetailTable extends StatelessWidget {
  const _DetailTable({required this.txn});

  final WalletTransaction txn;

  @override
  Widget build(BuildContext context) {
    final rows = <_TableRow>[
      _TableRow(label: 'Transaction ID', value: txn.id),
      _TableRow(label: 'Date & Time', value: txn.formattedDate),
      _TableRow(
        label: 'Type',
        value: txn.isWithdrawal
            ? 'Withdrawal'
            : (txn.type == TransactionType.credit ? 'Credit' : 'Debit'),
      ),
      if (txn.isWithdrawal && txn.withdrawalMethod != null)
        _TableRow(
          label: 'Method',
          value: txn.withdrawalMethod == 'upi'
              ? 'UPI Transfer'
              : 'Bank Transfer',
        ),
      _TableRow(label: 'Status', value: txn.statusLabel),
      _TableRow(label: 'Amount', value: txn.formattedAmount),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction Info',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF233D4C),
            ),
          ),
          const SizedBox(height: 12),
          ...rows.asMap().entries.map((e) {
            final isLast = e.key == rows.length - 1;
            return Column(
              children: [
                _buildRow(e.value),
                if (!isLast) Divider(color: Colors.grey[100], height: 16),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRow(_TableRow row) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            row.label,
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            row.value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF233D4C),
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _TableRow {
  final String label;
  final String value;
  const _TableRow({required this.label, required this.value});
}

// ─── Receipt Actions ─────────────────────────────────────────────────────────

class _ReceiptActions extends StatelessWidget {
  const _ReceiptActions({
    required this.isDownloading,
    required this.isSharing,
    required this.onDownload,
    required this.onShare,
  });

  final bool isDownloading;
  final bool isSharing;
  final VoidCallback onDownload;
  final VoidCallback onShare;

  static const _accent = Color(0xFFFD802E);
  static const _charcoal = Color(0xFF233D4C);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Receipt',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _charcoal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Download or share this transaction receipt as a PDF.',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Download
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isDownloading ? null : onDownload,
                  icon: isDownloading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.download_rounded, size: 18),
                  label: Text(isDownloading ? 'Downloading…' : 'Download'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Share
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSharing ? null : onShare,
                  icon: isSharing
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.grey[600],
                          ),
                        )
                      : const Icon(Icons.share_rounded, size: 18),
                  label: Text(isSharing ? 'Sharing…' : 'Share'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _charcoal,
                    side: const BorderSide(color: Color(0xFFDDE1E7)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Big Status Chip ─────────────────────────────────────────────────────────

class _BigStatusChip extends StatelessWidget {
  const _BigStatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Destination Card (Bank / UPI) ────────────────────────────────────────────

class _DestinationCard extends StatelessWidget {
  const _DestinationCard({required this.txn});
  final WalletTransaction txn;

  @override
  Widget build(BuildContext context) {
    final isUpi = txn.withdrawalMethod == 'upi';

    final rows = <_TableRow>[
      if (txn.accountHolder != null)
        _TableRow(label: 'Account Holder', value: txn.accountHolder!),
      if (isUpi && txn.upiId != null)
        _TableRow(label: 'UPI ID', value: txn.upiId!),
      if (!isUpi && txn.bankName != null)
        _TableRow(label: 'Bank', value: txn.bankName!),
      if (!isUpi && txn.accountNumber != null)
        _TableRow(label: 'Account No.', value: txn.accountNumber!),
      if (!isUpi && txn.ifscCode != null)
        _TableRow(label: 'IFSC Code', value: txn.ifscCode!),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isUpi
                      ? const Color(0xFFE3F2FD)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isUpi
                      ? Icons.account_balance_wallet_rounded
                      : Icons.account_balance_rounded,
                  size: 18,
                  color: isUpi
                      ? const Color(0xFF1565C0)
                      : const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isUpi ? 'UPI Destination' : 'Bank Destination',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF233D4C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey[100], height: 1),
          const SizedBox(height: 12),
          // Detail rows
          ...rows.asMap().entries.map((e) {
            final isLast = e.key == rows.length - 1;
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        e.value.label,
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        e.value.value,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF233D4C),
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                if (!isLast) Divider(color: Colors.grey[100], height: 16),
              ],
            );
          }),
        ],
      ),
    );
  }
}
