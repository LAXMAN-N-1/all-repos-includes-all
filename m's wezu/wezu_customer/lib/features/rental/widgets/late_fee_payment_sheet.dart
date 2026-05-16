import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/dio_provider.dart';

class LateFeePaymentSheet extends ConsumerStatefulWidget {
  final double amount;
  final String rentalId;

  const LateFeePaymentSheet({
    super.key,
    required this.amount,
    required this.rentalId,
  });

  @override
  ConsumerState<LateFeePaymentSheet> createState() => _LateFeePaymentSheetState();
}

class _LateFeePaymentSheetState extends ConsumerState<LateFeePaymentSheet> {
  bool _isProcessing = false;
  bool _isSuccess = false;

  Future<void> _handlePayment() async {
    setState(() => _isProcessing = true);

    try {
      final dio = ref.read(authenticatedDioProvider);
      
      final response = await dio.post('/rentals/${widget.rentalId}/late-fees/pay', data: {
        'amount': widget.amount,
        'payment_method': 'card', // Assuming default method for now
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Late fee paid successfully. Invoice ID: ${response.data['invoice_id'] ?? 'Unknown'}");
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _isSuccess = true;
          });
        }
      } else {
        throw Exception('Payment failed');
      }
    } catch (e) {
      debugPrint('Error processing late fee: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment failed. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isSuccess) ...[
            const Text(
              'Clear Overdue Fees',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Account balance for Rental ${widget.rentalId}',
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Text('TOTAL DUE',
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text(
                    '\$${widget.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _isProcessing
                ? const CircularProgressIndicator(color: AppTheme.accentGreen)
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: _handlePayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGreen,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('PAY NOW',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CANCEL',
                            style: TextStyle(color: AppTheme.textSecondary)),
                      ),
                    ],
                  ),
          ] else ...[
            const Icon(Icons.check_circle,
                color: AppTheme.accentGreen, size: 80),
            const SizedBox(height: 24),
            const Text('Payment Successful!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'Your overdue fees have been cleared. A digital invoice has been generated and sent to your email.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surfaceDark,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                side: const BorderSide(color: Colors.white10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('DONE'),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
