import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'settings_theme.dart';
import 'settings_common_widgets.dart';

class NotificationsSection extends StatefulWidget {
  final Map<String, bool> toggles;
  final Function(String, bool) onToggle;

  const NotificationsSection({
    super.key,
    required this.toggles,
    required this.onToggle,
  });

  @override
  State<NotificationsSection> createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<NotificationsSection> {
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChannelGrid(context, _activeTabIndex == 0 ? 'email' : 'sms'),
      ],
    );
  }

  Widget _buildTabItem(int index, String label) {
    final isActive = _activeTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTabIndex = index),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? SettingsTheme.backgroundDark : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? SettingsTheme.primaryGreen.withValues(alpha: 0.3) : Colors.transparent,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: SettingsTheme.h3.copyWith(
                color: isActive ? SettingsTheme.primaryGreen : SettingsTheme.mutedGray,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChannelGrid(BuildContext context, String channel) {
    final events = [
      ('New Ticket', 'new_ticket', LucideIcons.ticket),
      ('Status Change', 'status_change', LucideIcons.refreshCw),
      ('Low Inventory', 'low_inventory', LucideIcons.package),
      ('Maintenance Alert', 'maintenance', LucideIcons.wrench),
      ('Payout', 'payout', LucideIcons.banknote),
      ('Registration', 'registration', LucideIcons.userPlus),
      ('Role Change', 'role_change', LucideIcons.shield),
    ];

    return SettingsCard(
      title: '${channel[0].toUpperCase()}${channel.substring(1)} Notifications',
      accentColor: channel == 'email' ? SettingsTheme.primaryGreen : SettingsTheme.primaryCyan,
      dataStatus: 'Real-time Data',
      children: [
        // ── TAB SELECTOR (Now Inside Card) ──────────────────────────
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: SettingsTheme.backgroundDark.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SettingsTheme.borderSubtle),
          ),
          child: Row(
            children: [
              _buildTabItem(0, 'Email Channel'),
              _buildTabItem(1, 'SMS Channel'),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Notification toggles listed directly (removed inner container)
        for (int i = 0; i < events.length; i++) ...[
          _NotificationTile(
            label: events[i].$1,
            icon: events[i].$3,
            isOn: widget.toggles['notify_${events[i].$2}_$channel'] ?? false,
            onChanged: (val) => widget.onToggle('notify_${events[i].$2}_$channel', val),
          ),
          if (i < events.length - 1)
            const Divider(height: 1, thickness: 1, color: SettingsTheme.borderSubtle, indent: 52, endIndent: 16),
        ],
        const SizedBox(height: 48),
        
        // ── CREDIT BALANCE (SMS ONLY) ─────────────────────────
        if (channel == 'sms') ...[
          _buildSmsCreditSection(),
          const SizedBox(height: 48),
        ],

        // ── TEST BUTTON ───────────────────────────────────────
        Center(
          child: Column(
            children: [
              Text('Test these settings on your ${channel == 'email' ? 'inbox' : 'phone'}.', style: SettingsTheme.subline),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Test ${channel.toUpperCase()} sent to your verified ${channel == 'email' ? 'email' : 'number'}.'),
                      backgroundColor: SettingsTheme.primaryGreen,
                    ),
                  );
                },
                icon: const Icon(LucideIcons.send, size: 16),
                label: Text('Send Test ${channel.toUpperCase()}'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SettingsTheme.textHigh,
                  side: const BorderSide(color: SettingsTheme.borderSubtle),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmsCreditSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SettingsTheme.backgroundDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SettingsTheme.borderSubtle),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('SMS Credit Balance', style: SettingsTheme.subline),
                  const SizedBox(width: 8),
                  const DataStatusTag(status: 'Pending Configuration', isSmall: true),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('2,450', style: SettingsTheme.h2.copyWith(color: SettingsTheme.primaryCyan)),
                  const SizedBox(width: 8),
                  Text('Credits', style: SettingsTheme.subline.copyWith(fontSize: 12)),
                ],
              ),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: const Row(
              children: [
                Text('Buy Credits', style: TextStyle(color: SettingsTheme.primaryCyan, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(LucideIcons.externalLink, size: 14, color: SettingsTheme.primaryCyan),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _NotificationTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isOn;
  final Function(bool) onChanged;

  const _NotificationTile({
    required this.label,
    required this.icon,
    required this.isOn,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (isOn ? SettingsTheme.primaryGreen : SettingsTheme.mutedGray).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: isOn ? SettingsTheme.primaryGreen : SettingsTheme.mutedGray),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: SettingsTheme.body),
          ),
          Switch(
            value: isOn,
            onChanged: onChanged,
            activeThumbColor: SettingsTheme.primaryGreen,
            activeTrackColor: SettingsTheme.primaryGreen.withValues(alpha: 0.2),
            inactiveThumbColor: SettingsTheme.mutedGray,
            inactiveTrackColor: SettingsTheme.borderSubtle,
          ),
        ],
      ),
    );
  }
}

// ── LOCAL UI COMPONENTS ───────────────────────────────────────
