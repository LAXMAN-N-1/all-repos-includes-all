import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../../../core/theme/app_theme.dart';

class SubscriptionManagementScreen extends ConsumerStatefulWidget {
  const SubscriptionManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends ConsumerState<SubscriptionManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'My Subscription',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0,
      ),
      body: subscriptionState.activeSubscription == null
          ? _buildNoSubscriptionView(isDark)
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(subscriptionNotifierProvider.notifier)
                    .refetchActiveSubscription();
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSubscriptionCard(
                              subscriptionState.activeSubscription!, isDark),
                          const SizedBox(height: 24),
                          _buildSubscriptionDetails(
                              subscriptionState.activeSubscription!, isDark),
                          const SizedBox(height: 24),
                          _buildManagementSection(
                              subscriptionState.activeSubscription!, isDark),
                          const SizedBox(height: 24),
                          _buildCancellationSection(isDark),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNoSubscriptionView(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryBlue.withOpacity(0.1),
            ),
            child: Icon(
              LucideIcons.infinity,
              size: 40,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Active Subscription',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Subscribe to Wezu Pass and enjoy unlimited battery swaps',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Browse Plans',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(Subscription subscription, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryBlue.withOpacity(0.7),
          ],
        ),
      ),
      padding: const EdgeInsets.all(24),
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
                    subscription.planName,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      subscription.statusDisplay,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Icon(
                subscription.isActive
                    ? LucideIcons.checkCircle
                    : LucideIcons.xCircle,
                color: Colors.white,
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildCardRow(
            'Valid Until',
            '${subscription.endDate.day}/${subscription.endDate.month}/${subscription.endDate.year}',
          ),
          const SizedBox(height: 12),
          _buildCardRow(
            'Days Remaining',
            '${subscription.daysRemainingCount} days',
          ),
          if (!subscription.isUnlimited) ...[
            const SizedBox(height: 12),
            _buildCardRow(
              'Swaps Used',
              '${subscription.swapsUsed}/${subscription.swapsLimit}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionDetails(Subscription subscription, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subscription Details',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 16),
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
              _buildDetailRow(
                  'Start Date',
                  '${subscription.startDate.day}/${subscription.startDate.month}/${subscription.startDate.year}',
                  isDark),
              const SizedBox(height: 12),
              _buildDetailRow(
                  'End Date',
                  '${subscription.endDate.day}/${subscription.endDate.month}/${subscription.endDate.year}',
                  isDark),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Swaps Included',
                subscription.isUnlimited
                    ? 'Unlimited'
                    : '${subscription.swapsLimit}',
                isDark,
              ),
              if (subscription.nextRenewalDate != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Next Renewal',
                  '${subscription.nextRenewalDate!.day}/${subscription.nextRenewalDate!.month}/${subscription.nextRenewalDate!.year}',
                  isDark,
                  isHighlight: subscription.renewsSoon,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark,
      {bool isHighlight = false}) {
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
            color: isHighlight
                ? Colors.orange
                : (isDark ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildManagementSection(Subscription subscription, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage Subscription',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark ? Colors.grey[850] : Colors.white,
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Auto-Renewal',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subscription.autoRenew ? 'Enabled' : 'Disabled',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Switch(
                value: subscription.autoRenew,
                onChanged: (value) {
                  ref
                      .read(subscriptionNotifierProvider.notifier)
                      .updateAutoRenewal(
                        subscription.id,
                        value,
                      );
                },
                activeColor: AppTheme.primaryBlue,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (subscription.renewsSoon)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.orange.withOpacity(0.1),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  LucideIcons.alertCircle,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your subscription renews in ${subscription.daysRemainingCount} days',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCancellationSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danger Zone',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _showCancellationDialog,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Cancel Subscription',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCancellationDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String? selectedReason;
    String feedbackText = '';

    final reasons = [
      'Too expensive',
      'Not using the service',
      'Found a better alternative',
      'Technical issues',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isDark ? Colors.grey[900] : Colors.white,
              title: Text(
                'Cancel Subscription',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'We\'d like to know why you\'re leaving:',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...reasons.map((reason) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: RadioListTile(
                          value: reason,
                          groupValue: selectedReason,
                          onChanged: (value) {
                            setState(() => selectedReason = value);
                          },
                          title: Text(
                            reason,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppTheme.primaryBlue,
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) => feedbackText = value,
                      maxLines: 3,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Additional feedback (optional)',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Keep Subscription',
                    style: GoogleFonts.poppins(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: selectedReason != null
                      ? () async {
                          Navigator.pop(context);
                          _processCancel(selectedReason ?? '', feedbackText);
                        }
                      : null,
                  child: Text(
                    'Cancel Subscription',
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _processCancel(String reason, String feedback) async {
    final subscription =
        ref.read(subscriptionNotifierProvider).activeSubscription;
    if (subscription != null) {
      final success = await ref
          .read(subscriptionNotifierProvider.notifier)
          .cancelSubscription(
            subscriptionId: subscription.id,
            reason: reason,
            feedback: feedback,
          );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription cancelled successfully')),
        );
        Navigator.pop(context);
      }
    }
  }
}
