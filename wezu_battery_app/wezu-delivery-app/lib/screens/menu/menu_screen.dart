import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../repositories/auth_repository.dart';
import '../auth/login_screen.dart';
import '../dashboard/dashboard_view_model.dart';
import '../wallet/wallet_view_model.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthRepository>().currentUser;
    final dashboard = context.watch<DashboardViewModel>();

    final displayName = (user?.name.trim().isNotEmpty ?? false)
        ? user!.name.trim()
        : 'Delivery Partner';
    final displayEmail = (user?.email.trim().isNotEmpty ?? false)
        ? user!.email.trim()
        : 'partner@wezu.app';
    final displayPhone = (user?.phone.trim().isNotEmpty ?? false)
        ? user!.phone.trim()
        : 'Phone not available';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            _ProfileHeader(
              name: displayName,
              subtitle: displayPhone,
              rating: dashboard.rating <= 0 ? 4.95 : dashboard.rating,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.help_outline,
                    label: 'Help',
                    onTap: () => Navigator.pushNamed(context, '/help-support'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.shield_outlined,
                    label: 'Safety',
                    onTap: () => _openInfo(
                      context,
                      'Safety',
                      'In case of emergency, use in-app support and local emergency contacts. Keep your phone charged and share your live route when needed.',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionTitle('More ways to earn'),
            _MenuTile(
              icon: Icons.local_activity_outlined,
              title: 'Opportunities',
              onTap: () => _openInfo(
                context,
                'Opportunities',
                'Go online during peak demand windows to get more delivery requests and better incentives.',
              ),
            ),
            _MenuTile(
              icon: Icons.card_giftcard_outlined,
              title: 'Refer friends',
              onTap: () => _openInfo(
                context,
                'Refer friends',
                'Invite other delivery partners and earn referral rewards when they complete their first milestone.',
              ),
            ),
            const SizedBox(height: 18),
            const _SectionTitle('Manage'),
            _MenuTile(
              icon: Icons.description_outlined,
              title: 'Documents',
              onTap: () => Navigator.pushNamed(context, '/document-center'),
            ),
            _MenuTile(
              icon: Icons.umbrella_outlined,
              title: 'Insurance',
              onTap: () => _openInfo(
                context,
                'Insurance',
                'Your insurance coverage details, policy number, and support steps are available here for active partners.',
              ),
            ),
            const SizedBox(height: 18),
            const _SectionTitle('Money'),
            _MenuTile(
              icon: Icons.calculate_outlined,
              title: 'Tax info',
              onTap: () => _openInfo(
                context,
                'Tax info',
                'Download monthly and yearly earning summaries from Earnings activity for filing purposes. For official documents, contact support.',
              ),
            ),
            _MenuTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Payout methods',
              onTap: () => Navigator.pushNamed(context, '/payment-methods'),
            ),
            const SizedBox(height: 18),
            const _SectionTitle('Resources'),
            _MenuTile(
              icon: Icons.menu_book_outlined,
              title: 'Tips & info',
              onTap: () => Navigator.pushNamed(context, '/help-support'),
            ),
            _MenuTile(
              icon: Icons.info_outline,
              title: 'About',
              onTap: () => _openInfo(
                context,
                'About Wezu Delivery',
                'Wezu Delivery Partner helps drivers manage real-time battery deliveries with transparent earnings, secure verification, and reliable partner support.',
              ),
            ),
            const SizedBox(height: 18),
            const _SectionTitle('Account'),
            _MenuTile(
              icon: Icons.switch_account_outlined,
              title: 'Switch account',
              onTap: () => _openInfo(
                context,
                'Switch account',
                'To switch accounts, sign out from this device and sign in with the other delivery partner number.',
              ),
            ),
            _MenuTile(
              icon: Icons.logout,
              title: 'Sign out',
              subtitle: displayEmail,
              isDanger: true,
              onTap: () => _confirmLogout(context),
            ),
          ],
        ),
      ),
    );
  }

  void _openInfo(BuildContext context, String title, String description) {
    Navigator.pushNamed(
      context,
      '/menu-info',
      arguments: <String, String>{'title': title, 'description': description},
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    context.read<WalletViewModel>().resetForLogout();
    await context.read<AuthRepository>().logout();
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String subtitle;
  final double rating;

  const _ProfileHeader({
    required this.name,
    required this.subtitle,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.4),
                ),
                child: const Icon(Icons.person_outline, color: Colors.black),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF777777),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 17, color: Colors.black),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7E7E7)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 18,
          color: Colors.black,
          letterSpacing: -0.3,
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDanger;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isDanger = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isDanger ? const Color(0xFFB00020) : Colors.black;

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: titleColor),
          title: Text(
            title,
            style: TextStyle(color: titleColor, fontWeight: FontWeight.w500),
          ),
          subtitle: subtitle == null
              ? null
              : Text(
                  subtitle!,
                  style: const TextStyle(
                    color: Color(0xFF7A7A7A),
                    fontSize: 13,
                  ),
                ),
          trailing: Icon(
            Icons.chevron_right,
            color: isDanger ? const Color(0xFFB00020) : const Color(0xFFAAAAAA),
          ),
          onTap: onTap,
        ),
        const Divider(height: 1, color: Color(0xFFEAEAEA)),
      ],
    );
  }
}
