import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../rental/models/rental.dart';
import '../../../core/constants/app_colors.dart';
import 'dart:async';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';

class LateFeeScreen extends ConsumerStatefulWidget {
  final Rental rental;

  const LateFeeScreen({super.key, required this.rental});

  @override
  ConsumerState<LateFeeScreen> createState() => _LateFeeScreenState();
}

class _LateFeeScreenState extends ConsumerState<LateFeeScreen> {
  late Timer _timer;
  double _accumulatedFee = 0.0;
  Duration _timeOverdue = Duration.zero;
  final double _hourlyRate = 15.0;
  final double _dailyCap = 300.0;

  @override
  void initState() {
    super.initState();
    _calculateFee();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (mounted) {
        setState(() {
          _calculateFee();
        });
      }
    });
  }

  void _calculateFee() {
    final now = DateTime.now();
    // Use rental.endTime or start+duration if endTime is null (active rental logic)
    // If status is 'active' and past end time, it's overdue.
    // For demo, we might force overdue state if rental.isOverdue is true.

    DateTime deadline = widget.rental.endTime ??
        widget.rental.startTime.add(Duration(days: widget.rental.durationDays));

    if (widget.rental.isOverdue && now.isBefore(deadline)) {
      // Logic fix for demo: if backend says overdue but local clock says not,
      // assume deadline was in past (e.g., mock rental created with past start time).
      // Or just respect user's request to see this screen.
    }

    if (now.isAfter(deadline)) {
      _timeOverdue = now.difference(deadline);
      double hoursLate = _timeOverdue.inMinutes / 60.0;

      // Apply daily cap logic (simplified)
      int daysLate = _timeOverdue.inDays;
      double remainderFee = (hoursLate - (daysLate * 24)) * _hourlyRate;
      if (remainderFee > _dailyCap) remainderFee = _dailyCap;

      _accumulatedFee = (daysLate * _dailyCap) + remainderFee;
    } else {
      _timeOverdue = Duration.zero;
      _accumulatedFee = 0.0;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Late Fee Status"),
        backgroundColor: Colors.red[50],
        foregroundColor: Colors.red[900],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.red[50],
            child: Column(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 48, color: Colors.red[700]),
                const SizedBox(height: 16),
                const Text(
                  "Rental Overdue",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
                const SizedBox(height: 8),
                Text(
                  "Your rental period has ended. Accumulated fees apply.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[900]),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTickerCard(),
                  const SizedBox(height: 32),
                  _buildBreakdown(),
                ],
              ),
            ),
          ),
          _buildPayButton(context),
        ],
      ),
    );
  }

  Widget _buildTickerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.red.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: Column(
        children: [
          const Text("TOTAL LATE FEE",
              style: TextStyle(color: Colors.grey, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Text(
            "₹${_accumulatedFee.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Courier', // Monospace for ticker feel
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Late by: ${_formatDuration(_timeOverdue)}",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _buildBreakdown() {
    return Column(
      children: [
        _buildRow("Hourly Rate", "₹${_hourlyRate.toInt()}/hr"),
        const Divider(),
        _buildRow("Daily Cap", "₹${_dailyCap.toInt()}/day"),
        const Divider(),
        _buildRow("Applicable Tax (18%)",
            "₹${(_accumulatedFee * 0.18).toStringAsFixed(2)}"),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Total Payable Now",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              "₹${(_accumulatedFee * 1.18).toStringAsFixed(2)}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPayButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            // Initiate generic payment flow
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Redirecting to Payment Gateway...")),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child:
              const Text("Clear Dues & Return", style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}