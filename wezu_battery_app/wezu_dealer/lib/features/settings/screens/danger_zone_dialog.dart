import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'settings_theme.dart';

class DangerZoneDialog extends StatefulWidget {
  final String title;
  final String description;
  final String actionLabel;
  final String requiredBusinessName;
  final Function(String password) onConfirm;

  const DangerZoneDialog({
    super.key,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.requiredBusinessName,
    required this.onConfirm,
  });

  @override
  State<DangerZoneDialog> createState() => _DangerZoneDialogState();
}

class _DangerZoneDialogState extends State<DangerZoneDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isNameMatched = false;
  bool _isPasswordEntered = false;
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() => _isNameMatched = _nameController.text.trim() == widget.requiredBusinessName);
    });
    _passController.addListener(() {
      setState(() => _isPasswordEntered = _passController.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canProceed = _isNameMatched && _isPasswordEntered;

    return Dialog(
      backgroundColor: SettingsTheme.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.alertTriangle, color: SettingsTheme.errorRed, size: 24),
                const SizedBox(width: 12),
                Expanded(child: Text(widget.title, style: SettingsTheme.h2)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x, color: SettingsTheme.mutedGray, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(widget.description, style: SettingsTheme.body),
            const SizedBox(height: 32),
            
            // 🏷️ Step 1: Business Name
            Text(
              'To confirm, type your business name: "${widget.requiredBusinessName}"',
              style: SettingsTheme.subline.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              style: SettingsTheme.body,
              decoration: InputDecoration(
                hintText: 'Enter business name',
                hintStyle: TextStyle(color: SettingsTheme.mutedGray.withValues(alpha: 0.5)),
                filled: true,
                fillColor: SettingsTheme.backgroundDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 🔑 Step 2: Password
            Text(
              'Enter your account password to authorize:',
              style: SettingsTheme.subline.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passController,
              obscureText: _isObscured,
              style: SettingsTheme.body,
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(color: SettingsTheme.mutedGray.withValues(alpha: 0.5)),
                filled: true,
                fillColor: SettingsTheme.backgroundDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: IconButton(
                  icon: Icon(_isObscured ? LucideIcons.eyeOff : LucideIcons.eye, color: SettingsTheme.mutedGray, size: 18),
                  onPressed: () => setState(() => _isObscured = !_isObscured),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: SettingsTheme.mutedGray)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: canProceed ? () => widget.onConfirm(_passController.text) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SettingsTheme.errorRed,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: SettingsTheme.errorRed.withValues(alpha: 0.2),
                      disabledForegroundColor: Colors.white.withValues(alpha: 0.3),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(widget.actionLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
