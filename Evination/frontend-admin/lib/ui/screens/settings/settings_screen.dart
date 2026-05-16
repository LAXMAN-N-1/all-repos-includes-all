import 'package:flutter/material.dart';
import '../../widgets/common_input.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_textarea.dart';
import '../../widgets/common_switch.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String activeTab = 'profile';

  @override
  Widget build(BuildContext context) {
    // Responsive Layout
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 768;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text('Settings', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFfdb913))),
              Text('Manage your account settings and preferences', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 24),

              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 250, child: _buildTabs(isVertical: true)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildContent()),
                  ],
                )
              else
                Column(
                  children: [
                    _buildTabs(isVertical: false),
                    const SizedBox(height: 24),
                    _buildContent(),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabs({required bool isVertical}) {
    final tabs = [
      {'id': 'profile', 'name': 'Profile', 'icon': Icons.person},
      {'id': 'notifications', 'name': 'Notifications', 'icon': Icons.notifications},
      {'id': 'security', 'name': 'Security', 'icon': Icons.lock},
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: isVertical
          ? Column(children: tabs.map((t) => _buildTabItem(t, true)).toList())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: tabs.map((t) => _buildTabItem(t, false)).toList()),
            ),
    );
  }

  Widget _buildTabItem(Map<String, dynamic> tab, bool isVertical) {
    bool isActive = activeTab == tab['id'];
    return InkWell(
      onTap: () => setState(() => activeTab = tab['id']),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: isVertical ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: EdgeInsets.only(bottom: isVertical ? 4 : 0, right: isVertical ? 0 : 4),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFfdb913) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(tab['icon'], color: isActive ? Colors.white : Colors.grey[700], size: 20),
            const SizedBox(width: 12),
            Text(
              tab['name'],
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[700],
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Builder(
        builder: (context) {
          switch (activeTab) {
            case 'notifications':
              return _buildNotificationsTab();
            case 'security':
              return _buildSecurityTab();
            case 'profile':
            default:
              return _buildProfileTab();
          }
        },
      ),
    );
  }

  Widget _buildProfileTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Profile Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Update your personal information and profile details', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 24),

        Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFfdb913), Color(0xFFe5a711)]),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('JD', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonButton(text: 'Change Photo', onPressed: () {}), // Gradient auto-applied usually unless variant used
                const SizedBox(height: 4),
                Text('JPG, PNG or GIF. Max 2MB', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        const Row(
          children: [
            Expanded(child: CommonInput(label: 'First Name', placeholder: 'John')),
            SizedBox(width: 24),
            Expanded(child: CommonInput(label: 'Last Name', placeholder: 'Doe')),
          ],
        ),
        const SizedBox(height: 16),
        const CommonInput(label: 'Email Address', placeholder: 'john.doe@eventunity.com'),
        const SizedBox(height: 16),
        const CommonInput(label: 'Phone Number', placeholder: '+1 (555) 123-4567'),
        const SizedBox(height: 16),
        const CommonTextarea(label: 'Bio', placeholder: 'Experienced event planner...', minLines: 3),
        const SizedBox(height: 24),
        
        const Divider(),
        const SizedBox(height: 24),

        Row(
          children: [
            CommonButton(text: 'Save Changes', icon: Icons.save, onPressed: () {}),
            const SizedBox(width: 16),
            CommonButton(text: 'Cancel', variant: ButtonVariant.outline, onPressed: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Notification Preferences', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Choose how you want to receive notifications', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 24),

        _buildSwitchTile('Email Notifications', 'Receive notifications via email'),
        _buildSwitchTile('Push Notifications', 'Receive push notifications on your device'),
        _buildSwitchTile('Event Reminders', 'Get reminded about upcoming events'),
        _buildSwitchTile('Bid Updates', 'Notifications for new bids and updates'),
        _buildSwitchTile('Order Status', 'Updates on order status changes'),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
        CommonButton(text: 'Save Preferences', onPressed: () {}),
      ],
    );
  }

  Widget _buildSecurityTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Security Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Manage your password and security preferences', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 24),

        const CommonInput(label: 'Current Password', obscureText: true),
        const SizedBox(height: 16),
        const CommonInput(label: 'New Password', obscureText: true),
        const SizedBox(height: 16),
        const CommonInput(label: 'Confirm New Password', obscureText: true),
        const SizedBox(height: 24),

        _buildSwitchTile('Two-Factor Authentication', 'Add an extra layer of security', value: false),
        
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
        CommonButton(text: 'Update Password', onPressed: () {}),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, {bool value = true}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          CommonSwitch(value: value, onChanged: (_) {}),
        ],
      ),
    );
  }
}
