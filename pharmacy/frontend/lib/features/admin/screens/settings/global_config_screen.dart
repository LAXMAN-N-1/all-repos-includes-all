import 'package:flutter/material.dart';

import 'package:frontend/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class GlobalConfigScreen extends StatefulWidget {
  const GlobalConfigScreen({Key? key}) : super(key: key);

  @override
  State<GlobalConfigScreen> createState() => _GlobalConfigScreenState();
}

class _GlobalConfigScreenState extends State<GlobalConfigScreen> {
  // Mock form state
  final TextEditingController _appNameController = TextEditingController(text: "AuraMed SaaS");
  final TextEditingController _supportEmailController = TextEditingController(text: "support@auramed.com");
  bool _maintenanceMode = false;
  String _selectedLanguage = "English (US)";

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Global Configuration", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),
            
            // General Settings Card
            _buildSectionCard(
              title: "General Information",
              children: [
                _buildTextField("Platform Name", _appNameController),
                const SizedBox(height: 16),
                _buildTextField("Support Email", _supportEmailController),
                const SizedBox(height: 16),
                _buildDropdown("Default Language", ["English (US)", "Spanish", "French", "German"]),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // System Control Card
            _buildSectionCard(
              title: "System Control",
              children: [
                SwitchListTile(
                  title: const Text("Maintenance Mode", style: TextStyle(color: Colors.white)),
                  subtitle: const Text("Prevent non-admin users from logging in", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  value: _maintenanceMode,
                  onChanged: (val) => setState(() => _maintenanceMode = val),
                  activeColor: Colors.red,
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(color: Colors.white12),
                SwitchListTile(
                  title: const Text("Allow New Registrations", style: TextStyle(color: Colors.white)),
                  subtitle: const Text("Pause onboarding wizard for public", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  value: true,
                  onChanged: (val) {},
                  activeColor: AuraColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AuraColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AuraColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AuraColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items) {
    return DropdownButtonFormField<String>(
      value: _selectedLanguage,
      dropdownColor: AuraColors.surface,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
      onChanged: (val) => setState(() => _selectedLanguage = val!),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
      ),
    );
  }
}
