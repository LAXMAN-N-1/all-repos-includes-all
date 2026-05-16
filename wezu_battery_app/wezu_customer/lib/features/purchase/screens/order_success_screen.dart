import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

import '../services/invoice_service.dart';
import '../models/purchase_invoice.dart';
import 'order_tracking_screen.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';
import '../../../core/widgets/glass_scaffold.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String orderId;
  final double amount;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.amount,
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  bool _invoiceGenerating = true;
  bool _notificationsSent = false;
  PurchaseInvoice? _invoice;

  @override
  void initState() {
    super.initState();
    _processPostOrder();
  }

  Future<void> _processPostOrder() async {
    // Requirement: Invoice generated within 1 second
    _invoice = await InvoiceService.generateInvoice(
      orderId: widget.orderId,
      productName: 'WEZU PowerStream Battery SKU',
      amount: widget.amount,
      transactionId: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
    );

    if (mounted) {
      setState(() => _invoiceGenerating = false);
    }

    // Deliver via Email/SMS
    if (_invoice != null) {
      await InvoiceService.sendNotifications(_invoice!);
      if (mounted) {
        setState(() => _notificationsSent = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveryDate = DateTime.now().add(const Duration(days: 3));
    final formattedDate = DateFormat('EEEE, MMM d').format(deliveryDate);

    return GlassScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buildSuccessAnimation(),
              const SizedBox(height: 32),
              const Text(
                'Order Placed!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your payment of ₹${widget.amount.toInt()} was successful.',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 32),
              _buildInvoiceStatus(),
              const SizedBox(height: 32),
              _buildOrderDetails(formattedDate),
              const Spacer(),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatusBadge(
          _invoiceGenerating ? Icons.sync : Icons.description,
          _invoiceGenerating ? 'Generating Invoice...' : 'Invoice Ready',
          _invoiceGenerating ? AppTheme.textSecondary : AppTheme.accentGreen,
        ),
        const SizedBox(width: 12),
        _buildStatusBadge(
          _notificationsSent ? Icons.mark_email_read : Icons.mail_outline,
          _notificationsSent ? 'Email/SMS Sent' : 'Queued',
          _notificationsSent ? AppTheme.accentGreen : AppTheme.textSecondary,
        ),
      ],
    );
  }

  Widget _buildStatusBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(String deliveryDate) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassDecoration(true).copyWith(
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _buildInfoRow('Order ID', widget.orderId),
          const Divider(color: Colors.white10, height: 32),
          _buildInfoRow('Tax (GST 18%)', 'Included',
              valueColor: Colors.white70),
          const Divider(color: Colors.white10, height: 32),
          _buildInfoRow('Delivery By', deliveryDate),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _invoice == null
              ? null
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading Invoice PDF...')),
                  );
                },
          icon: const Icon(Icons.file_download, size: 20),
          label: const Text('DOWNLOAD INVOICE'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.white10),
            ),
            elevation: 0,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      OrderTrackingScreen(orderId: widget.orderId)),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            minimumSize: const Size(double.infinity, 64),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('TRACK ORDER',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white)),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
          child: const Text(
            'Back to Home',
            style: TextStyle(
                color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 1),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppTheme.accentGreen,
              size: 80,
            ),
          ),
        );
      },
    );
  }
}