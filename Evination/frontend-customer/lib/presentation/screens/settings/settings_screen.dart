import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:evination_customer_app/core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _bookingUpdates = true;
  bool _specialOffers = true;
  bool _eventReminders = true;
  bool _marketing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
         child: Column(
           children: [
             // 1. Hero
             Container(
               width: double.infinity,
               color: AppColors.primaryBlack,
               padding: const EdgeInsets.fromLTRB(24, 60, 24, 60),
               child: Column(
                 children: [
                    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.crimsonSilk, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.settings_outlined, size: 32, color: AppColors.white)),
                    const SizedBox(height: 24),
                    Text('Settings', style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 12),
                    Text('Customize your EVE NATION experience', style: GoogleFonts.inter(fontSize: 16, color: Colors.white70)),
                 ],
               ),
             ),
             
             Transform.translate(
               offset: const Offset(0, -20),
               child: Container(
                 decoration: const BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                   boxShadow: [
                     BoxShadow(
                       color: Colors.black12,
                       blurRadius: 10,
                       offset: Offset(0, -2),
                     )
                   ]
                 ),
                 child: Padding(
                   padding: const EdgeInsets.all(24),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       
                       // Notifications Section
                       _buildSectionHeader(Icons.notifications_outlined, 'Notifications', 'Manage your notification preferences'),
                       const SizedBox(height: 24),
                       _buildToggleTile('Booking Updates', 'Get notified about your event bookings', _bookingUpdates, (v) => setState(() => _bookingUpdates = v)),
                       const SizedBox(height: 16),
                       _buildToggleTile('Special Offers', 'Exclusive deals from verified vendors', _specialOffers, (v) => setState(() => _specialOffers = v)),
                       const SizedBox(height: 16),
                       _buildToggleTile('Event Reminders', 'Reminders for upcoming events', _eventReminders, (v) => setState(() => _eventReminders = v)),
                       const SizedBox(height: 16),
                       _buildToggleTile('Marketing Communications', 'Newsletter and promotional content', _marketing, (v) => setState(() => _marketing = v)),

                       const SizedBox(height: 40),
                       
                       // Account & Privacy
                       _buildSectionHeader(Icons.shield_outlined, 'Account & Privacy', 'Manage security and privacy settings'),
                       const SizedBox(height: 24),
                       _buildNavTile(Icons.credit_card, 'Payment Methods', 'Manage saved cards and payment options'),
                       const SizedBox(height: 16),
                       _buildNavTile(Icons.lock_outline, 'Security & Password', 'Change password and security settings'),
                       const SizedBox(height: 16),
                       _buildNavTile(Icons.privacy_tip_outlined, 'Privacy Policy', 'Read our privacy and data policy'),
                       const SizedBox(height: 16),
                       _buildNavTile(Icons.help_outline, 'Help & Support', 'Get help and contact support'),

                       const SizedBox(height: 40),
                       
                       // App Preferences
                       _buildSectionHeader(Icons.smartphone, 'App Preferences', 'Customize your app experience'),
                       const SizedBox(height: 24),
                       _buildNavTile(Icons.language, 'Language', 'Choose your preferred language'),
                       const SizedBox(height: 16),
                       _buildNavTile(Icons.dark_mode_outlined, 'Dark Mode', 'Coming soon'),

                       const SizedBox(height: 60),

                       // Logout
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () {},
                             icon: const Icon(Icons.logout, color: Colors.red),
                             label: const Text('Logout from EVE NATION', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        const Center(child: Text('EVE NATION v1.0.0', style: TextStyle(fontWeight: FontWeight.bold))),
                        Center(child: Text('Premium Event Management Platform', style: TextStyle(color: Colors.grey[600], fontSize: 12))),
                         const SizedBox(height: 40),

                     ],
                   ),
                 ),
               ),
             ),
           ],
         ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, String subtitle) {
     return Row(
       children: [
         Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.crimsonSilk, borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 24, color: AppColors.white)),
         const SizedBox(width: 16),
         Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)), Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 14))]),
       ],
     );
  }

  Widget _buildToggleTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.crimsonSilk.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.notifications_active_outlined, color: AppColors.crimsonSilk, size: 20)),
             const SizedBox(width: 16),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                 ],
               ),
             ),
             Switch(
               value: value,
               onChanged: onChanged,
               activeColor: AppColors.crimsonSilk,
             ),
         ],
      ),
    );
  }

  Widget _buildNavTile(IconData icon, String title, String subtitle) {
     return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primaryBlack, size: 20)),
             const SizedBox(width: 16),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                 ],
               ),
             ),
             Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
         ],
      ),
    );
  }
}
