import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../config/app_navigator.dart';
import '../../utils/app_haptics.dart';

import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/theme_toggle.dart';
import '../../core/theme_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../features/auth/providers/auth_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _scannerVibration = true;
  bool _continuousScan = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      useSafeArea: false,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: const Text('Settings'), centerTitle: false),
          SliverPadding(
            padding: AppSpacing.screenPadding,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader(context, 'Appearance'),
                _buildAppearanceSection(context, isDark),
                AppSpacing.gapH24,

                _buildSectionHeader(context, 'Notifications'),
                _buildNotificationsSection(context),
                AppSpacing.gapH24,

                _buildSectionHeader(context, 'Scanner'),
                _buildScannerSection(context),
                AppSpacing.gapH24,

                _buildSectionHeader(context, 'Account'),
                _buildAccountSection(context),
                AppSpacing.gapH24,

                _buildAboutSection(context),
                const SizedBox(height: 40),

                Center(
                  child: Text(
                    'Wezu Logistics v$_appVersion',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
                  ),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, bool isDark) {
    final amoledMode = ref.watch(amoledModeProvider);

    return AppCard(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme Mode'),
            trailing: const ThemeToggle(),
          ),
          if (isDark) ...[
            const Divider(height: 1, indent: 56),
            SwitchListTile(
              secondary: const Icon(Icons.brightness_2_outlined),
              title: const Text('AMOLED Mode'),
              subtitle: const Text('Use true black for OLED screens'),
              value: amoledMode,
              onChanged: (val) =>
                  ref.read(amoledModeProvider.notifier).toggle(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Push Notifications'),
            value: _pushNotifications,
            onChanged: (val) => setState(() => _pushNotifications = val),
          ),
          const Divider(height: 1, indent: 56),
          SwitchListTile(
            secondary: const Icon(Icons.email_outlined),
            title: const Text('Email Updates'),
            value: _emailNotifications,
            onChanged: (val) => setState(() => _emailNotifications = val),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerSection(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text('Haptic Feedback'),
            subtitle: const Text('Vibrate on successful scan'),
            value: _scannerVibration,
            onChanged: (val) {
              AppHaptics.selection();
              setState(() => _scannerVibration = val);
            },
          ),
          const Divider(height: 1, indent: 56),
          SwitchListTile(
            secondary: const Icon(Icons.repeat),
            title: const Text('Continuous Scan'),
            subtitle: const Text('Keep scanner open after scan'),
            value: _continuousScan,
            onChanged: (val) {
              AppHaptics.selection();
              setState(() => _continuousScan = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              AppHaptics.impact();
              AppNavigator.toEditProfile(context);
            },
          ),

          const Divider(height: 1, indent: 56),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () async {
              AppHaptics.impact();

              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(authStateProvider.notifier).logout();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return AppCard(
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: const Text('About Wezu Logistics'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          AppHaptics.tap();
          showAboutDialog(
            context: context,
            applicationName: 'Wezu Logistics',
            applicationVersion: _appVersion,
            applicationIcon: const Icon(
              Icons.battery_charging_full,
              size: 48,
              color: AppColors.primary,
            ),
            children: const [
              Text(
                'Batteries as a Service (BaaS) logistics management platform.',
              ),
            ],
          );
        },
      ),
    );
  }
}
