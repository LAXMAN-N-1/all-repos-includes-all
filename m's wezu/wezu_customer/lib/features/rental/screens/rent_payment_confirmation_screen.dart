import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wezu_customer_app/core/theme/app_theme.dart';
import 'package:wezu_customer_app/features/maps/models/station.dart';
import 'package:wezu_customer_app/features/rental/models/battery.dart';
import 'package:wezu_customer_app/features/rental/providers/rental_providers.dart';
import 'package:wezu_customer_app/features/rental/screens/rent_success_screen.dart';

class RentPaymentConfirmationScreen extends ConsumerStatefulWidget {
  const RentPaymentConfirmationScreen({
    super.key,
    required this.station,
    required this.battery,
    required this.durationDays,
  });

  final Station station;
  final Battery battery;
  final int durationDays;

  @override
  ConsumerState<RentPaymentConfirmationScreen> createState() =>
      _RentPaymentConfirmationScreenState();
}

class _RentPaymentConfirmationScreenState
    extends ConsumerState<RentPaymentConfirmationScreen> {
  bool _isSubmitting = false;
  bool _loadingPrice = true;
  String? _priceError;

  double _modelRate = 0;
  double _swapFee = 0;
  double _totalPayable = 0;

  @override
  void initState() {
    super.initState();
    _fetchPricing();
  }

  Future<void> _fetchPricing() async {
    try {
      final repository = ref.read(rentalRepositoryProvider);
      final swapService = ref.read(swapRequestServiceProvider);

      final results = await Future.wait([
        repository.calculatePrice(
          batteryId: widget.battery.id,
          durationDays: widget.durationDays,
        ),
        swapService
            .getSwapFee(widget.station.id)
            .then((fee) => {'swap_fee': fee}),
      ]);

      final priceResult = results[0];
      final swapResult = results[1];

      final modelRate = (priceResult['daily_rate'] as num?)?.toDouble() ?? 0;
      final swapFee = (swapResult['swap_fee'] as num?)?.toDouble() ?? 0;

      setState(() {
        _modelRate = modelRate;
        _swapFee = swapFee;
        _totalPayable = modelRate + swapFee;
        _loadingPrice = false;
      });
    } catch (e) {
      setState(() {
        _priceError = e.toString().replaceFirst('Exception: ', '');
        _loadingPrice = false;
      });
    }
  }

  Future<void> _confirmRental() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(rentalRepositoryProvider);
      final initiatedRental = await repository.initiateRental(
        batteryId: widget.battery.id,
        stationId: widget.station.id,
        durationDays: widget.durationDays,
      );

      final confirmedRental = await repository.confirmRental(
        initiatedRental.id,
        'PAY-${DateTime.now().millisecondsSinceEpoch}',
      );

      ref.invalidate(activeRentalsProvider);
      ref.invalidate(rentalHistoryProvider);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RentSuccessScreen(
            rentalId: confirmedRental.id,
            batteryName: widget.battery.modelNumber,
            stationName: widget.station.name,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Payment Confirmation',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loadingPrice
          ? const Center(child: CircularProgressIndicator())
          : _priceError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_priceError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent)),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppTheme.shadowLight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _lineItem('Station', widget.station.name),
                          _lineItem('Battery', widget.battery.modelNumber),
                          _lineItem('Battery SOC',
                              '${widget.battery.currentCharge.toStringAsFixed(0)}%'),
                          _lineItem('Model Rate',
                              '₹${_modelRate.toStringAsFixed(2)}'),
                          _lineItem(
                              'Swap Fee',
                              _swapFee > 0
                                  ? '₹${_swapFee.toStringAsFixed(2)}'
                                  : 'Free'),
                          const Divider(height: 24),
                          _lineItem(
                            'Total Payable',
                            '₹${_totalPayable.toStringAsFixed(2)}',
                            emphasize: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _confirmRental,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Confirm Rental'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed:
                            _isSubmitting ? null : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _lineItem(String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(color: Colors.grey.shade600),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
              fontSize: emphasize ? 18 : 15,
            ),
          ),
        ],
      ),
    );
  }
}
