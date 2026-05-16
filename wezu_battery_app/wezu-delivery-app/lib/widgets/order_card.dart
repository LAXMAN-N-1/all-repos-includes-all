import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/invoice_service.dart';
import '../screens/wallet/invoice_viewer_screen.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatefulWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool _isDownloading = false;
  static const _accent = Color(0xFFFD802E);

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.pickingUp:
        return Colors.purple;
      case OrderStatus.delivering:
        return const Color(0xFFFD802E); // Pumpkin
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pickingUp:
        return 'Picking Up';
      default:
        return status.name[0].toUpperCase() + status.name.substring(1);
    }
  }

  Future<void> _downloadInvoice() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      final service = InvoiceService();
      final file = await service.downloadInvoice(
        id: widget.order.id,
        type: InvoiceType.rental,
      );
      service.dispose();
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InvoiceViewerScreen(
              pdfFile: file,
              invoiceTitle: 'Order #${widget.order.id}',
            ),
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
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.order.status);
    final isDelivered = widget.order.status == OrderStatus.delivered;
    final isHistory =
        isDelivered || widget.order.status == OrderStatus.cancelled;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(widget.order.status),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '₹${widget.order.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF233D4C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildLocationRow(
                Icons.ev_station,
                widget.order.pickupName,
                widget.order.pickupAddress,
                isHistory,
              ),
              const SizedBox(height: 12),
              _buildLocationRow(
                Icons.directions_car,
                widget.order.dropoffName,
                widget.order.dropoffAddress,
                isHistory,
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: ${widget.order.id}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  Text(
                    DateFormat('MMM d, h:mm a').format(widget.order.timestamp),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  // Download invoice — only for delivered orders
                  if (isDelivered)
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: _isDownloading
                          ? const Padding(
                              padding: EdgeInsets.all(5),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _accent,
                              ),
                            )
                          : IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.download_rounded,
                                size: 19,
                                color: _accent,
                              ),
                              tooltip: 'Download Invoice',
                              onPressed: _downloadInvoice,
                            ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRow(
    IconData icon,
    String title,
    String subtitle,
    bool isHistory,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF233D4C),
                ),
              ),
              if (!isHistory) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
