import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wezu_customer_app/core/constants/api_constants.dart';
import 'package:wezu_customer_app/core/utils/time_utils.dart';
import 'package:wezu_customer_app/core/network/dio_provider.dart';
import 'package:wezu_customer_app/core/theme/app_theme.dart';

class PurchaseHistoryScreen extends ConsumerStatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  ConsumerState<PurchaseHistoryScreen> createState() =>
      _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends ConsumerState<PurchaseHistoryScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _orders = const [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dio = ref.read(authenticatedDioProvider);
      final response = await dio.get('/catalog/orders');
      final data = _extractListData(response.data);
      setState(() {
        _orders = data;
        _loading = false;
      });
    } on DioException catch (e) {
      final detail = e.response?.data is Map
          ? (e.response?.data['detail'] ?? e.message)
          : e.message;
      setState(() {
        _loading = false;
        _error = detail?.toString() ?? 'Failed to load orders';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _showOrderDetails(int orderId) async {
    try {
      final dio = ref.read(authenticatedDioProvider);
      final response = await dio.get('/catalog/orders/$orderId');
      final data = _extractMapData(response.data);
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          final items = (data['items'] is List)
              ? List<Map<String, dynamic>>.from(data['items'])
              : const <Map<String, dynamic>>[];
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ${data['order_number'] ?? '#$orderId'}',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Status: ${data['status'] ?? '-'}',
                    style: GoogleFonts.outfit(color: Colors.grey),
                  ),
                  Text(
                    'Payment: ${data['payment_status'] ?? '-'}',
                    style: GoogleFonts.outfit(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  if (items.isEmpty)
                    Text(
                      'No items found for this order.',
                      style: GoogleFonts.outfit(color: Colors.grey),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 16),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final qty = item['quantity'] ?? 0;
                          final unit = _asDouble(item['unit_price']);
                          final total = _asDouble(item['total_price']);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['product_name']?.toString() ?? 'Item',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Qty: $qty • Unit: ₹${unit.toStringAsFixed(2)} • Total: ₹${total.toStringAsFixed(2)}',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load order details: $e')),
      );
    }
  }

  Future<void> _cancelOrder(int orderId) async {
    try {
      final dio = ref.read(authenticatedDioProvider);
      await dio.post('/catalog/orders/$orderId/cancel');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order cancelled successfully')),
      );
      await _loadOrders();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to cancel order: $e')),
      );
    }
  }

  Future<void> _copyInvoiceLink(int orderId) async {
    final url = '${ApiConstants.apiBaseUrl}/catalog/orders/$orderId/invoice';
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice link copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          'My Purchases',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Icon(Icons.wifi_off_rounded, size: 52, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Center(
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: ElevatedButton(
              onPressed: _loadOrders,
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }
    if (_orders.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Icon(Icons.shopping_bag_outlined,
              size: 54, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'No purchases yet',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final order = _orders[index];
        final id = (order['id'] as num?)?.toInt() ?? 0;
        final orderNumber = order['order_number']?.toString() ?? '#$id';
        final status = order['status']?.toString() ?? 'unknown';
        final paymentStatus = order['payment_status']?.toString() ?? 'unknown';
        final amount = _asDouble(order['total_amount']);
        final createdAt = _parseDate(order['created_at']?.toString());
        final canCancel = status.toLowerCase() == 'pending';

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E293B)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppTheme.shadowLight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      orderNumber,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _statusChip(status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Amount: ₹${amount.toStringAsFixed(2)}',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
              Text(
                'Payment: $paymentStatus',
                style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey),
              ),
              if (createdAt != null)
                Text(
                  'Created: ${TimeUtils.longDateFromDt(createdAt)}',
                  style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey),
                ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () => _showOrderDetails(id),
                    child: const Text('Details'),
                  ),
                  OutlinedButton(
                    onPressed: () => _copyInvoiceLink(id),
                    child: const Text('Invoice'),
                  ),
                  if (canCancel)
                    ElevatedButton(
                      onPressed: () => _cancelOrder(id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cancel'),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusChip(String status) {
    final normalized = status.toLowerCase();
    final color = switch (normalized) {
      'completed' => Colors.green,
      'shipped' => Colors.blue,
      'delivered' => Colors.green,
      'cancelled' => Colors.red,
      'pending' => Colors.orange,
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  static List<Map<String, dynamic>> _extractListData(dynamic payload) {
    if (payload is Map && payload['data'] is List) {
      return List<Map<String, dynamic>>.from(payload['data'] as List);
    }
    if (payload is List) {
      return List<Map<String, dynamic>>.from(payload);
    }
    return const [];
  }

  static Map<String, dynamic> _extractMapData(dynamic payload) {
    if (payload is Map && payload['data'] is Map) {
      return Map<String, dynamic>.from(payload['data'] as Map);
    }
    if (payload is Map) {
      return Map<String, dynamic>.from(payload);
    }
    return const {};
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toLocal();
  }
}
