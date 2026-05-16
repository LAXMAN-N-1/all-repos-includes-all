import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/subscription_plan.dart';

import '../providers/subscription_provider.dart';
import '../../../core/theme/app_theme.dart';

class SubscriptionPurchaseScreen extends ConsumerStatefulWidget {
  final SubscriptionPlan selectedPlan;

  const SubscriptionPurchaseScreen({
    Key? key,
    required this.selectedPlan,
  }) : super(key: key);

  @override
  ConsumerState<SubscriptionPurchaseScreen> createState() =>
      _SubscriptionPurchaseScreenState();
}

class _SubscriptionPurchaseScreenState
    extends ConsumerState<SubscriptionPurchaseScreen> {
  int _currentStep = 0;
  bool _autoRenewEnabled = true;
  String? _selectedPaymentMethod;

  final List<String> _paymentMethods = [
    'Credit/Debit Card',
    'UPI',
    'Wallet',
    'Net Banking',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subscriptionState = ref.watch(subscriptionNotifierProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Subscribe Now',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Stepper/Progress
                _buildProgressIndicator(isDark),
                const SizedBox(height: 32),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildStepContent(isDark, subscriptionState),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildActionButtons(isDark, subscriptionState),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepIndicator(
                0,
                'Plan',
                _currentStep >= 0,
                isDark,
              ),
              Container(
                height: 2,
                width: 40,
                color:
                    _currentStep > 0 ? AppTheme.primaryBlue : Colors.grey[300],
              ),
              _buildStepIndicator(
                1,
                'Payment',
                _currentStep >= 1,
                isDark,
              ),
              Container(
                height: 2,
                width: 40,
                color:
                    _currentStep > 1 ? AppTheme.primaryBlue : Colors.grey[300],
              ),
              _buildStepIndicator(
                2,
                'Confirm',
                _currentStep >= 2,
                isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _getStepTitle(_currentStep),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getStepDescription(_currentStep),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
    int step,
    String label,
    bool isActive,
    bool isDark,
  ) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppTheme.primaryBlue : Colors.grey[300],
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : Colors.grey[600],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent(bool isDark, SubscriptionState state) {
    switch (_currentStep) {
      case 0:
        return _buildPlanReview(isDark);
      case 1:
        return _buildPaymentSelection(isDark);
      case 2:
        return _buildConfirmation(isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPlanReview(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark ? Colors.grey[850] : Colors.white,
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.selectedPlan.name,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.selectedPlan.description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.selectedPlan.displayPrice,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: isDark ? Colors.grey[700] : Colors.grey[200]),
              const SizedBox(height: 20),
              _buildPlanDetail(
                  'Validity', '${widget.selectedPlan.durationDays} days'),
              const SizedBox(height: 12),
              _buildPlanDetail(
                'Swaps Included',
                widget.selectedPlan.unlimitedSwaps
                    ? 'Unlimited'
                    : '${widget.selectedPlan.swapsIncluded}',
              ),
              const SizedBox(height: 12),
              _buildPlanDetail(
                  'Auto-Renewal', _autoRenewEnabled ? 'Enabled' : 'Disabled'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.primaryBlue.withOpacity(0.1),
            border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                LucideIcons.info,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your subscription will auto-renew on ${_calculateRenewalDate()}. You can cancel anytime.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        CheckboxListTile(
          value: _autoRenewEnabled,
          onChanged: (value) {
            setState(() {
              _autoRenewEnabled = value ?? true;
            });
          },
          title: Text(
            'Enable auto-renewal',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildPaymentSelection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Payment Method',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        ..._paymentMethods.map((method) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = method;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedPaymentMethod == method
                          ? AppTheme.primaryBlue
                          : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
                      width: _selectedPaymentMethod == method ? 2 : 1,
                    ),
                    color: _selectedPaymentMethod == method
                        ? AppTheme.primaryBlue.withOpacity(0.1)
                        : (isDark ? Colors.grey[850] : Colors.white),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedPaymentMethod == method
                                ? AppTheme.primaryBlue
                                : Colors.grey[400]!,
                          ),
                        ),
                        child: _selectedPaymentMethod == method
                            ? Center(
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        method,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark ? Colors.grey[850] : Colors.white,
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildPriceRow(
                'Subscription Price',
                widget.selectedPlan.displayPrice,
                isDark,
              ),
              const SizedBox(height: 12),
              _buildPriceRow(
                'Taxes & Fees',
                '+₹0',
                isDark,
              ),
              Divider(color: isDark ? Colors.grey[700] : Colors.grey[200]),
              const SizedBox(height: 12),
              _buildPriceRow(
                'Total',
                widget.selectedPlan.displayPrice,
                isDark,
                isBold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmation(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.1),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.check,
                color: Colors.green,
                size: 40,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Subscription Confirmed!',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Your ${widget.selectedPlan.name} is now active',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark ? Colors.grey[850] : Colors.white,
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildConfirmationRow('Plan', widget.selectedPlan.name, isDark),
              const SizedBox(height: 12),
              _buildConfirmationRow(
                'Valid Until',
                _calculateExpiryDate(),
                isDark,
              ),
              const SizedBox(height: 12),
              _buildConfirmationRow(
                'Auto-Renewal',
                _autoRenewEnabled ? 'Enabled' : 'Disabled',
                isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark, SubscriptionState state) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.isLoading ? null : _handleNextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: state.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _currentStep == 2 ? 'Done' : 'Continue',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        if (_currentStep > 0) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _handlePreviousStep,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Back',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlanDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[900],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, bool isDark,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  void _handleNextStep() {
    if (_currentStep == 0) {
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (_selectedPaymentMethod == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a payment method')),
        );
        return;
      }
      _processPurchase();
    } else if (_currentStep == 2) {
      Navigator.pop(context);
    }
  }

  void _handlePreviousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _processPurchase() async {
    final notifier = ref.read(subscriptionNotifierProvider.notifier);
    final success = await notifier.purchaseSubscription(
      planId: widget.selectedPlan.id,
      paymentMethodId: _selectedPaymentMethod ?? '',
      autoRenew: _autoRenewEnabled,
    );

    if (success) {
      setState(() => _currentStep = 2);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment failed. Please try again.')),
        );
      }
    }
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Review Your Plan';
      case 1:
        return 'Choose Payment Method';
      case 2:
        return 'Subscription Activated';
      default:
        return '';
    }
  }

  String _getStepDescription(int step) {
    switch (step) {
      case 0:
        return 'Review plan details before proceeding to payment';
      case 1:
        return 'Select your preferred payment method';
      case 2:
        return 'Your subscription is now active';
      default:
        return '';
    }
  }

  String _calculateRenewalDate() {
    final renewal =
        DateTime.now().add(Duration(days: widget.selectedPlan.durationDays));
    return '${renewal.day}/${renewal.month}/${renewal.year}';
  }

  String _calculateExpiryDate() {
    final expiry =
        DateTime.now().add(Duration(days: widget.selectedPlan.durationDays));
    return '${expiry.day}/${expiry.month}/${expiry.year}';
  }
}
