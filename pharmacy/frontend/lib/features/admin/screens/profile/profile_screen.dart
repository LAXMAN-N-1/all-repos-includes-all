import 'package:flutter/material.dart';

import 'package:frontend/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AuraColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AuraColors.glassBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: AuraColors.primary,
                child: Text("SA", style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              Text("Super Admin", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const Text("super.admin@auramed.com", style: TextStyle(color: Colors.white54, fontSize: 16)),
              const SizedBox(height: 32),
              
              const Divider(color: Colors.white12),
              
              _buildProfileOption(Icons.lock, "Change Password"),
              _buildProfileOption(Icons.security, "Two-Factor Authentication (2FA)", isEnabled: true),
              _buildProfileOption(Icons.notifications, "Email Notifications", isEnabled: true),
              _buildProfileOption(Icons.language, "Language", value: "English (US)"),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await context.read<AuthService>().logout();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Sign Out"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.2),
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, {bool? isEnabled, String? value}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: value != null 
          ? Text(value, style: const TextStyle(color: Colors.white54))
          : (isEnabled != null 
              ? Switch(value: isEnabled, onChanged: (v) {}, activeColor: AuraColors.primary)
              : const Icon(Icons.chevron_right, color: Colors.white24)),
    );
  }
}
