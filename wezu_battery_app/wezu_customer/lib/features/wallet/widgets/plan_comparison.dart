import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/subscription_plan.dart';
import '../../../core/theme/app_theme.dart';

class PlanComparisonTable extends StatefulWidget {
  final List<SubscriptionPlan> plans;
  final Function(SubscriptionPlan) onSelectPlan;

  const PlanComparisonTable({
    Key? key,
    required this.plans,
    required this.onSelectPlan,
  }) : super(key: key);

  @override
  State<PlanComparisonTable> createState() => _PlanComparisonTableState();
}

class _PlanComparisonTableState extends State<PlanComparisonTable> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Compare Plans',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 380,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.plans.length,
            itemBuilder: (context, index) {
              final plan = widget.plans[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildComparisonCard(plan, isDark),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonCard(SubscriptionPlan plan, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Colors.grey[900] : Colors.white,
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.name,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    plan.displayPrice,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    plan.durationDisplay,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildFeatureRow(
                'Swaps',
                plan.unlimitedSwaps ? 'Unlimited' : '${plan.swapsIncluded}',
                isDark,
              ),
              const SizedBox(height: 8),
              _buildFeatureRow(
                'Duration',
                '${plan.durationDays} days',
                isDark,
              ),
              const SizedBox(height: 8),
              _buildFeatureRow(
                'Station Priority',
                plan.isPopular ? 'Yes' : 'No',
                isDark,
              ),
              const SizedBox(height: 8),
              _buildFeatureRow(
                'Support',
                '24/7',
                isDark,
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onSelectPlan(plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Choose ${plan.name}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String feature, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          feature,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[200] : Colors.black,
          ),
        ),
      ],
    );
  }
}
