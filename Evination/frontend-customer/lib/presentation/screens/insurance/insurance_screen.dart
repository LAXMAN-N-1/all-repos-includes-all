import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:evination_customer_app/core/constants/app_colors.dart';
import '../../providers/insurance/insurance_provider.dart';

class InsuranceScreen extends ConsumerWidget {
  const InsuranceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insuranceListAsync = ref.watch(insuranceListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Hero Section
            Container(
              color: AppColors.primaryBlack,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 60),
              child: Column(
                children: [
                   Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: AppColors.crimsonSilk,
                       borderRadius: BorderRadius.circular(16),
                     ),
                     child: const Icon(Icons.shield_outlined, size: 32, color: AppColors.primaryBlack),
                   ),
                   const SizedBox(height: 24),
                  Text(
                    'Event Protection',
                    style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Secure your special moments with our comprehensive coverage plans',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
             
             // 2. Plans List
             Padding(
                padding: const EdgeInsets.all(24),
                child: insuranceListAsync.when(
                  data: (plans) => Column(
                    children: plans.map((plan) => _buildPlanCard(plan)).toList(),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.crimsonSilk)),
                  error: (e, _) => Text('Error: $e'),
                ),
             )
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(dynamic plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primaryBlack.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(plan.title, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.crimsonSilk.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text('₹${plan.premiumAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(plan.description, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          // Features
          ...plan.features.map<Widget>((f) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                const SizedBox(width: 8),
                Text(f),
              ],
            ),
          )).toList(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlack,
                foregroundColor: AppColors.crimsonSilk,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Select Plan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
