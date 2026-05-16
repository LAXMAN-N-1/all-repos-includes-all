import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 260,
      child: Container(
        color: AppColors.secondary,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Logo Area
              const Text(
                'WEZU',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Delivery Partner',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white24, height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    _buildSectionLabel('Operational'),
                    _buildMenuItem(context, 0, Icons.dashboard_rounded, 'Dashboard'),
                    _buildMenuItem(context, 1, Icons.swap_horiz_rounded, 'Swap Station'),
                    _buildMenuItem(context, 2, Icons.notifications_active_rounded, 'Order Request'),
                    _buildMenuItem(context, 3, Icons.electric_bolt_rounded, 'Active Delivery'),
                    _buildMenuItem(context, 4, Icons.verified_rounded, 'Delivery Verification'),
                    _buildMenuItem(context, 5, Icons.list_alt_rounded, 'Orders'),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Divider(color: Colors.white12, height: 1),
                    ),
                    _buildSectionLabel('Account & Settings'),
                    _buildMenuItem(context, 6, Icons.bar_chart_rounded, 'Earnings'),
                    _buildMenuItem(context, 7, Icons.account_balance_wallet_rounded, 'Wallet'),
                    _buildMenuItem(context, 8, Icons.shopping_cart_rounded, 'Cart'),
                    _buildMenuItem(context, 9, Icons.person_rounded, 'Account'),
                    _buildMenuItem(context, 10, Icons.history_rounded, 'Order History'),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Divider(color: Colors.white12, height: 1),
                    ),
                    _buildMenuItem(context, 11, Icons.settings_rounded, 'Settings'),
                    _buildMenuItem(context, 12, Icons.help_rounded, 'Help & Support'),
                    _buildMenuItem(context, 13, Icons.notifications_rounded, 'Notifications'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    int index,
    IconData icon,
    String title,
  ) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onItemSelected(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
