import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/battery.dart';
import '../models/rental_receipt.dart';
import 'rental_success_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/rental_providers.dart';
import '../../payment/services/wallet_service.dart';
import '../../payment/models/transaction.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';
import '../../../core/network/dio_provider.dart';

class RentalConfirmationScreen extends ConsumerStatefulWidget {
  final Battery battery;

  const RentalConfirmationScreen({super.key, required this.battery});

  @override
  ConsumerState<RentalConfirmationScreen> createState() =>
      _RentalConfirmationScreenState();
}

class _RentalConfirmationScreenState
    extends ConsumerState<RentalConfirmationScreen> {
  int _durationDays = 1;
  bool _termsAccepted = false;
  bool _isConfirming = false;

  final TextEditingController _promoController = TextEditingController();
  double _discountAmount = 0.0;
  String? _promoError;
  bool _isPromoApplied = false;

  PaymentMethod _selectedPaymentMethod = PaymentMethod.wallet;
  double _walletBalance = 0.0;
  bool _isLoadingBalance = true;

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    final walletService = WalletService(ref.read(authenticatedDioProvider));
    final balance = await walletService.getBalance();
    if (mounted) {
      setState(() {
        _walletBalance = balance;
        _isLoadingBalance = false;
      });
    }
  }

  // Constants for pricing calculation
  // In real app, these should come from backend configuration or calculatePrice API
  static const double serviceFee = 49.0;
  static const double gstRate = 0.18;

  double get securityDeposit => widget.battery.damageDepositAmount;
  double get rentalFee => widget.battery.rentalPricePerDay * _durationDays;
  double get gstAmount => (rentalFee + serviceFee - _discountAmount) * gstRate;
  double get totalAmount =>
      (rentalFee + serviceFee + gstAmount + securityDeposit) - _discountAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Confirm Rental'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBatterySummary(),
              const SizedBox(height: 32),
              _buildDurationSelector(),
              const SizedBox(height: 32),
              _buildPricingBreakdown(),
              const SizedBox(height: 24),
              _buildPromoCodeField(),
              const SizedBox(height: 32),
              _buildPaymentMethodSelector(),
              const SizedBox(height: 32),
              _buildLateFeePolicy(),
              const SizedBox(height: 32),
              _buildTermsCheckbox(),
              const SizedBox(height: 48),
              _buildConfirmButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBatterySummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://placehold.co/600x400/1E3A8A/FFFFFF.png?text=${widget.battery.type.replaceAll(' ', '+')}',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.battery.modelNumber,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${widget.battery.serialNumber}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildSummaryTag(
                        Icons.flash_on, '${widget.battery.capacityAh}Ah'),
                    const SizedBox(width: 8),
                    _buildSummaryTag(Icons.health_and_safety,
                        '${widget.battery.healthPercentage.toInt()}%'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: AppTheme.primaryBlue),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Rental Duration',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$_durationDays Days',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.primaryBlue,
            inactiveTrackColor: AppTheme.surfaceDark,
            thumbColor: Colors.white,
            overlayColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
            valueIndicatorColor: AppTheme.primaryBlue,
            valueIndicatorTextStyle: const TextStyle(color: Colors.white),
          ),
          child: Slider(
            value: _durationDays.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            label: '$_durationDays Days',
            onChanged: (value) {
              setState(() {
                _durationDays = value.toInt();
              });
            },
          ),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1 Day',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            Text('30 Days',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pricing Breakdown',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              _buildPriceRow(
                  'Daily Rental Rate', widget.battery.rentalPricePerDay),
              _buildPriceRow('Rental Duration', '$_durationDays Days'),
              const Divider(color: Colors.white10, height: 24),
              _buildPriceRow('Subtotal (Rate × Duration)', rentalFee),
              _buildPriceRow('Refundable Damage Deposit', securityDeposit),
              _buildPriceRow('Service & Platform Fee', serviceFee),
              if (_isPromoApplied)
                _buildPriceRow('Promo Discount', -_discountAmount,
                    valueColor: AppTheme.accentGreen),
              _buildPriceRow('GST (18%)', gstAmount),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: Colors.white10),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text(
                    '₹${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCodeField() {
    // ... [Same logic as before, abbreviated for brevity in thinking]
    // Re-implementing fully below
    return Column(
      children: [
        // ... (Header)
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _promoController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter code (try WEZU50)',
                  hintStyle: const TextStyle(color: Colors.white24),
                  fillColor: AppTheme.surfaceDark,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  errorText: _promoError,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _isPromoApplied ? _removePromo : _applyPromo,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPromoApplied
                    ? Colors.red.withValues(alpha: 0.1)
                    : AppTheme.primaryBlue,
                foregroundColor: _isPromoApplied ? Colors.red : Colors.white,
                minimumSize: const Size(100, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_isPromoApplied ? 'REMOVE' : 'APPLY'),
            ),
          ],
        ),
      ],
    );
  }

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    if (code == 'WEZU50') {
      setState(() {
        _discountAmount = 50.0;
        _isPromoApplied = true;
        _promoError = null;
      });
    } else if (code.isEmpty) {
      setState(() => _promoError = 'Please enter a code');
    } else {
      setState(() => _promoError = 'Invalid promo code');
    }
  }

  void _removePromo() {
    setState(() {
      _discountAmount = 0.0;
      _isPromoApplied = false;
      _promoController.clear();
      _promoError = null;
    });
  }

  Widget _buildLateFeePolicy() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'Late Return Policy',
                style: TextStyle(
                    color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'A grace period of 2 hours is provided. Post that, a late fee of ₹100 per hour will be applicable and deducted from the damage deposit.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, dynamic value, {Color? valueColor}) {
    String valueStr = value is double
        ? '₹${value.abs().toStringAsFixed(2)}'
        : value.toString();
    if (value is double && value < 0) valueStr = '- $valueStr';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 14))),
          Text(
            valueStr,
            style: TextStyle(
                color: valueColor ?? Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () => setState(() => _termsAccepted = !_termsAccepted),
      child: Row(
        children: [
          Checkbox(
            value: _termsAccepted,
            onChanged: (value) => setState(() => _termsAccepted = value!),
            activeColor: AppTheme.primaryBlue,
            side: const BorderSide(color: AppTheme.textSecondary),
          ),
          const Expanded(
            child: Text.rich(
              TextSpan(
                text: 'I accept the ',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                children: [
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Battery Usage Policy',
                    style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    final bool canConfirm = _termsAccepted && !_isConfirming;

    return ElevatedButton(
      onPressed: canConfirm ? _handleConfirmation : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryBlue,
        disabledBackgroundColor: AppTheme.surfaceDark,
        minimumSize: const Size(double.infinity, 64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: _isConfirming
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'CONFIRM & RENT NOW',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildPaymentOption(
          method: PaymentMethod.wallet,
          icon: Icons.account_balance_wallet,
          label: 'Wallet Balance',
          subtitle: _isLoadingBalance
              ? 'Loading...'
              : 'Available: ₹${_walletBalance.toStringAsFixed(2)}',
          isEnabled: _walletBalance >= totalAmount,
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          method: PaymentMethod.upi,
          icon: Icons.qr_code_scanner,
          label: 'UPI (PhonePe, GPay)',
          subtitle: 'Pay via any UPI app',
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          method: PaymentMethod.creditCard,
          icon: Icons.credit_card,
          label: 'Credit / Debit Card',
          subtitle: 'Secure checkout via Razorpay',
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required PaymentMethod method,
    required IconData icon,
    required String label,
    required String subtitle,
    bool isEnabled = true,
  }) {
    final bool isSelected = _selectedPaymentMethod == method;

    return InkWell(
      onTap: isEnabled
          ? () => setState(() => _selectedPaymentMethod = method)
          : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                : AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryBlue
                  : Colors.white.withValues(alpha: 0.05),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : AppTheme.textSecondary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle,
                    color: AppTheme.primaryBlue, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleConfirmation() async {
    if (_selectedPaymentMethod == PaymentMethod.wallet &&
        _walletBalance < totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Insufficient wallet balance. Please top up.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isConfirming = true);

    try {
      final rentalRepo = ref.read(rentalRepositoryProvider);

      // 1. Initiate Rental on backend
      final rental = await rentalRepo.initiateRental(
        batteryId: widget.battery.id,
        stationId: 1, // This should normally be passed from the previous screen
        durationDays: _durationDays,
        promoCode: _isPromoApplied ? _promoController.text : null,
      );

      // 2. Process Payment
      bool paymentSuccess = false;
      String paymentRef = 'pay_${DateTime.now().millisecondsSinceEpoch}';

      if (_selectedPaymentMethod == PaymentMethod.wallet) {
        final walletService = WalletService(ref.read(authenticatedDioProvider));
        paymentSuccess = await walletService.pay(totalAmount,
            description: 'Rental: ${widget.battery.modelNumber}');
      } else {
        // Here you would integrate Razorpay/other SDK
        // For simulation, we'll assume success
        await Future.delayed(const Duration(seconds: 2));
        paymentSuccess = true;
      }

      if (paymentSuccess) {
        // 3. Confirm Rental on backend
        await rentalRepo.confirmRental(rental.id, paymentRef);

        if (mounted) {
          final receipt = RentalReceipt.generate(
            batteryId: widget.battery.id.toString(),
            batteryModel: widget.battery.modelNumber,
            durationDays: _durationDays,
            dailyRate: widget.battery.rentalPricePerDay,
            subtotal: rentalFee,
            deposit: securityDeposit,
            serviceFee: serviceFee,
            gst: gstAmount,
            discount: _discountAmount,
            totalAmount: totalAmount,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RentalSuccessScreen(
                battery: widget.battery,
                receipt: receipt,
              ),
            ),
          );
        }
      } else {
        throw Exception('Payment failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isConfirming = false);
      }
    }
  }
}