import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wezu_customer_app/core/theme/app_theme.dart';
import 'package:wezu_customer_app/core/theme/theme_provider.dart';

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
  bool _rentalAlerts = true;
  bool _walletUpdates = true;
  bool _promotions = false;
  bool _securityAlerts = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = ref.read(sharedPrefsProvider);
    setState(() {
      _rentalAlerts = prefs.getBool('notif_rental_alerts') ?? true;
      _walletUpdates = prefs.getBool('notif_wallet_updates') ?? true;
      _promotions = prefs.getBool('notif_promotions') ?? false;
      _securityAlerts = prefs.getBool('notif_security_alerts') ?? true;
      _loading = false;
    });
  }

  Future<void> _save(String key, bool value) async {
    await ref.read(sharedPrefsProvider).setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _switchTile(
                  context,
                  title: 'Rental Alerts',
                  subtitle: 'Reservation, pickup, return reminders',
                  value: _rentalAlerts,
                  onChanged: (value) async {
                    setState(() => _rentalAlerts = value);
                    await _save('notif_rental_alerts', value);
                  },
                ),
                const SizedBox(height: 12),
                _switchTile(
                  context,
                  title: 'Wallet Updates',
                  subtitle: 'Balance, recharge, and transaction updates',
                  value: _walletUpdates,
                  onChanged: (value) async {
                    setState(() => _walletUpdates = value);
                    await _save('notif_wallet_updates', value);
                  },
                ),
                const SizedBox(height: 12),
                _switchTile(
                  context,
                  title: 'Offers and Promotions',
                  subtitle: 'Discounts, cashback campaigns, partner offers',
                  value: _promotions,
                  onChanged: (value) async {
                    setState(() => _promotions = value);
                    await _save('notif_promotions', value);
                  },
                ),
                const SizedBox(height: 12),
                _switchTile(
                  context,
                  title: 'Security Alerts',
                  subtitle: 'Login, password, and device activity alerts',
                  value: _securityAlerts,
                  onChanged: (value) async {
                    setState(() => _securityAlerts = value);
                    await _save('notif_security_alerts', value);
                  },
                ),
              ],
            ),
    );
  }

  Widget _switchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.shadowLight,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppTheme.primaryBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
