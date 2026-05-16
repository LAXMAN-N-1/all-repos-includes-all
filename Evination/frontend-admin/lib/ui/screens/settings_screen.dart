import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF5A623),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your application preferences',
            style: GoogleFonts.inter(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          
          Expanded(
            child: ListView(
              children: [
                _SectionHeader(title: 'General'),
                Card(
                  surfaceTintColor: Colors.white,
                  color: Colors.white,
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Dark Mode'),
                        subtitle: const Text('Enable dark theme for the application'),
                        value: _darkMode,
                        onChanged: (val) => setState(() => _darkMode = val),
                      ),
                      const Divider(height: 1),
                       ListTile(
                        title: const Text('Language'),
                         subtitle: const Text('English (US)'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                 _SectionHeader(title: 'Notifications'),
                Card(
                  surfaceTintColor: Colors.white,
                  color: Colors.white,
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Email Notifications'),
                        subtitle: const Text('Receive emails about new bids and events'),
                        value: _emailNotifications,
                        onChanged: (val) => setState(() => _emailNotifications = val),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Push Notifications'),
                        subtitle: const Text('Receive push notifications on mobile'),
                        value: _pushNotifications,
                        onChanged: (val) => setState(() => _pushNotifications = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                _SectionHeader(title: 'Security'),
                Card(
                  surfaceTintColor: Colors.white,
                  color: Colors.white,
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Change Password'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Two-Factor Authentication'),
                        subtitle: const Text('Disabled'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                 const SizedBox(height: 24),
                 
                 SizedBox(
                   width: double.infinity,
                   child: ElevatedButton(
                     onPressed: () {},
                     style: ElevatedButton.styleFrom(
                       backgroundColor: const Color(0xFFF5A623),
                       padding: const EdgeInsets.symmetric(vertical: 16),
                       foregroundColor: Colors.white,
                     ),
                     child: const Text('Save Changes'),
                   ),
                 ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
