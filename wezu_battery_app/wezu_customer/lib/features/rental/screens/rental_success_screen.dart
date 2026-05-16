import 'package:flutter/material.dart';
import '../models/rental_receipt.dart';
import '../models/battery.dart';
import '../models/rental.dart';
import 'active_rental_dashboard.dart'; // This is now RentalDetailsScreen
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';

class RentalSuccessScreen extends StatefulWidget {
  final Battery battery;
  final RentalReceipt receipt;

  const RentalSuccessScreen({
    super.key,
    required this.battery,
    required this.receipt,
  });

  @override
  State<RentalSuccessScreen> createState() => _RentalSuccessScreenState();
}

class _RentalSuccessScreenState extends State<RentalSuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _simulateDownload() async {
    setState(() => _isDownloading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receipt saved to Downloads/WZ-Receipt.pdf'),
          backgroundColor: AppTheme.accentGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              _buildSuccessAnimation(),
              const SizedBox(height: 24),
              const Text(
                'Rental Success!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Receipt sent to registered email & SMS',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 40),
              _buildReceiptCard(),
              const SizedBox(height: 32),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.accentGreen.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentGreen.withValues(alpha: 0.2),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: const Icon(
          Icons.check_circle,
          color: AppTheme.accentGreen,
          size: 100,
        ),
      ),
    );
  }

  Widget _buildReceiptCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('RENTAL ID', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
              Text(
                widget.receipt.rentalId,
                style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 32),
          _buildItemRow('Battery Model', widget.receipt.batteryModel),
          _buildItemRow('Duration', '${widget.receipt.durationDays} Days'),
          _buildItemRow('Pickup Date', DateFormat('MMM dd, yyyy').format(widget.receipt.timestamp)),
          const Divider(color: Colors.white10, height: 32),
          _buildPriceRow('Rental Fee', widget.receipt.subtotal),
          _buildPriceRow('Security Deposit', widget.receipt.deposit),
          _buildPriceRow('Service Fee', widget.receipt.serviceFee),
          if (widget.receipt.discount > 0)
            _buildPriceRow('Promo Discount', -widget.receipt.discount, valueColor: AppTheme.accentGreen),
          _buildPriceRow('GST (18%)', widget.receipt.gst),
          const Divider(color: Colors.white10, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Final Total', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                '₹${widget.receipt.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double value, {Color? valueColor}) {
    String valueStr = '₹${value.abs().toStringAsFixed(2)}';
    if (value < 0) valueStr = '- $valueStr';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          Text(valueStr, style: TextStyle(color: valueColor ?? Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _isDownloading ? null : _simulateDownload,
          icon: _isDownloading 
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue))
            : const Icon(Icons.file_download_outlined),
          label: Text(_isDownloading ? 'DOWNLOADING...' : 'DOWNLOAD RECEIPT (PDF)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
            foregroundColor: AppTheme.primaryBlue,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            final rental = Rental(
              id: int.parse(widget.receipt.rentalId.replaceAll(RegExp(r'[^0-9]'), '')),
              userId: 0,
              battery: widget.battery,
              pickupStationId: 0,
              status: 'active',
              startTime: widget.receipt.timestamp,
              totalAmount: widget.receipt.totalAmount,
              dailyRate: widget.receipt.subtotal / widget.receipt.durationDays,
              damageDeposit: widget.receipt.deposit,
              discountAmount: widget.receipt.discount,
              durationDays: widget.receipt.durationDays,
            );

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => ActiveRentalDashboard(rental: rental)),
              (route) => route.isFirst,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('GO TO DASHBOARD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            // Simulate Share
          },
          child: const Text('SHARE RECEIPT', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}