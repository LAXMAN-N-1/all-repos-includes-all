import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _nightMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        children: [
          const _SettingsSectionTitle('Account'),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Manage account',
            onTap: () => _showInfo(
              'Manage account',
              'Update your name, phone, and profile details from your linked partner account.',
            ),
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Privacy',
            onTap: () => _showInfo(
              'Privacy',
              'Manage data sharing preferences and privacy controls for your driver account.',
            ),
          ),
          _SettingsTile(
            icon: Icons.edit_location_alt_outlined,
            title: 'Edit address',
            onTap: () => _showInfo(
              'Edit address',
              'Contact support to update your registered address and verification documents.',
            ),
          ),
          const SizedBox(height: 20),
          const _SettingsSectionTitle('General'),
          _SettingsTile(
            icon: Icons.accessibility_new_outlined,
            title: 'Accessibility',
            onTap: () => _showInfo(
              'Accessibility',
              'Accessibility preferences help you improve readability and touch navigation.',
            ),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Night mode',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
            secondary: const Icon(
              Icons.dark_mode_outlined,
              color: Colors.black,
            ),
            value: _nightMode,
            onChanged: (value) => setState(() => _nightMode = value),
            activeTrackColor: Colors.black,
          ),
          const Divider(height: 1, color: Color(0xFFEAEAEA)),
          _SettingsTile(
            icon: Icons.keyboard_voice_outlined,
            title: 'Voice commands',
            onTap: () => _showInfo(
              'Voice commands',
              'Voice commands are currently limited and may vary by device support.',
            ),
          ),
          _SettingsTile(
            icon: Icons.navigation_outlined,
            title: 'Navigation',
            onTap: () => _showInfo(
              'Navigation',
              'Choose map and route behavior for delivery navigation prompts.',
            ),
          ),
          _SettingsTile(
            icon: Icons.volume_up_outlined,
            title: 'Sounds & voice',
            onTap: () => _showInfo(
              'Sounds & voice',
              'Set notification volume and voice guidance preferences.',
            ),
          ),
        ],
      ),
    );
  }

  void _showInfo(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  final String title;

  const _SettingsSectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 37,
          letterSpacing: -1,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: Colors.black),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Color(0xFFA9A9A9)),
          onTap: onTap,
        ),
        const Divider(height: 1, color: Color(0xFFEAEAEA)),
      ],
    );
  }
}
