import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../theme/app_theme.dart';

class PaymentsManagementScreen extends StatelessWidget {
  const PaymentsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payments & Earnings',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track your revenue, escrow, and payouts.',
                    style: TextStyle(color: AppTheme.gray600, fontSize: 16),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(LucideIcons.downloadCloud, size: 18),
                label: const Text('Export History'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.emeraldGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Top Stats Grid
          _buildStatsGrid(context),
          const SizedBox(height: 32),

          // Main Content Section
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildTransactionHistory(context)),
                    const SizedBox(width: 24),
                    Expanded(flex: 1, child: _buildBankSettings(context)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildTransactionHistory(context),
                    const SizedBox(height: 24),
                    _buildBankSettings(context),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        _buildStatCard(
          context,
          'Total Earned',
          '₹12,45,000',
          '+12% vs last month',
          LucideIcons.banknote,
          AppTheme.success,
        ),
        _buildStatCard(
          context,
          'In Escrow',
          '₹2,84,500',
          'Held for active orders',
          LucideIcons.lock,
          AppTheme.emeraldGreen,
        ),
        _buildStatCard(
          context,
          'Next Payout',
          '₹85,000',
          'Scheduled for Jan 15',
          LucideIcons.calendar,
          AppTheme.info,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final cardWidth = (MediaQuery.of(context).size.width - 48 - (2 * 24)) / 3;
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      width: isMobile ? double.infinity : cardWidth.clamp(280, 500),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray200),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: AppTheme.gray600, fontSize: 14)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: AppTheme.gray600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Transaction History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => const Divider(height: 1, color: AppTheme.gray100),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.gray50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        index % 2 == 0 ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
                        color: index % 2 == 0 ? AppTheme.success : AppTheme.warning,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            index % 2 == 0 ? 'Payment from EVE NATION' : 'Payout to Bank',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text('Jan ${10 - index}, 2026', style: TextStyle(color: AppTheme.gray600, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text(
                      index % 2 == 0 ? '+₹45,000' : '-₹30,000',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: index % 2 == 0 ? AppTheme.success : AppTheme.gray900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text('View All Transactions →', style: TextStyle(color: AppTheme.emeraldGreen, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payout Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.gray50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.gray200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.landmark, color: AppTheme.gray600, size: 20),
                    const SizedBox(width: 12),
                    const Text('Bank Account', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('PRIMARY', style: TextStyle(color: AppTheme.success, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('HDFC Bank •••• 8492', style: TextStyle(color: AppTheme.gray900, fontSize: 14)),
                Text('Current Account', style: TextStyle(color: AppTheme.gray600, fontSize: 12)),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  child: const Text('Edit Details'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Withdraw Funds', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text(
            'Minimum withdrawal amount is ₹5,000. Funds will be credited within 24 hours.',
            style: TextStyle(color: AppTheme.gray600, fontSize: 12),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Withdraw ₹2,84,500'),
          ),
        ],
      ),
    );
  }
}
