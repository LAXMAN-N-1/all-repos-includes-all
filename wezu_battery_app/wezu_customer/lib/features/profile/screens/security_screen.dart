import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/security_provider.dart';
import '../../auth/providers/auth_provider.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(securityProvider.notifier).loadDevices());
  }

  Future<void> _toggleBiometrics(bool value) async {
    try {
      if (value) {
        await ref.read(authProvider.notifier).enableBiometric();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Biometric Login Enabled')));
        }
      } else {
        await ref.read(authProvider.notifier).disableBiometric();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Biometric Login Disabled')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final securityState = ref.watch(securityProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC);

    return Scaffold(
      appBar: AppBar(
        title: Text("Security",
            style: GoogleFonts.outfit(
                color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      backgroundColor: bgColor,
      body: securityState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Authentication", isDark),
                  const SizedBox(height: 16),
                  if (!kIsWeb) ...[
                    _buildSwitchTile(
                      title: "Biometric Login",
                      subtitle: "Use FaceID or Fingerprint to log in",
                      value: ref.watch(authProvider).isBiometricEnabled,
                      onChanged: _toggleBiometrics,
                      icon: Icons.fingerprint,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildActionTile(
                    title: "Change Password",
                    subtitle: "Update your account password",
                    onTap: () =>
                        Navigator.pushNamed(context, '/change-password'),
                    icon: Icons.lock_outline,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildSwitchTile(
                    title: "Two-Factor Authentication",
                    subtitle:
                        "When enabled, you'll be asked to verify your identity with a one-time code every time you log in.",
                    value: securityState.is2FAEnabled,
                    statusText:
                        securityState.is2FAEnabled ? "Active" : "Disabled",
                    statusColor:
                        securityState.is2FAEnabled ? Colors.green : Colors.grey,
                    onChanged: (value) {
                      if (value) {
                        _showEnable2FAConfirmation(context);
                      } else {
                        _showDisable2FAConfirmation(context);
                      }
                    },
                    icon: Icons.security,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle("Active Devices", isDark),
                  const SizedBox(height: 16),
                  if (securityState.devices.isEmpty)
                    Text("No active devices found (or not implemented)",
                        style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey)),
                  ...securityState.devices
                      .map((device) => _buildDeviceTile(device)),
                ],
              ),
            ),
    );
  }

  void _showDisable2FAConfirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(builder: (context, ref, child) {
          final state = ref.watch(securityProvider);
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange[700], size: 28),
                const SizedBox(width: 8),
                Text("Disable 2FA?",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    )),
              ],
            ),
            content: Text(
              "Disabling 2FA will make your account less secure. Are you sure?",
              style: GoogleFonts.outfit(
                color: isDark ? Colors.grey[400] : Colors.blueGrey[700],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Keep Enabled",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    )),
              ),
              ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () {
                        ref
                            .read(securityProvider.notifier)
                            .requestDisable2FAOTP()
                            .then((_) {
                          if (!context.mounted) return;
                          Navigator.pop(context); // Close dialog
                          Navigator.pushNamed(
                            context,
                            AppRoutes.twoFactorSetupOtp,
                            arguments: {'isEnabling': false},
                          );
                        }).catchError((e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())));
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: state.isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.red))
                    : Text("Disable",
                        style: GoogleFonts.outfit(
                            color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
      },
    );
  }

  void _showEnable2FAConfirmation(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          return Consumer(builder: (context, ref, child) {
            final state = ref.watch(securityProvider);
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 24,
                  right: 24,
                  top: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.blue[50], shape: BoxShape.circle),
                      child: const Icon(Icons.security,
                          color: Colors.blue, size: 40),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text("Enable Two-Factor Authentication?",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text(
                      "We will send a verification code to your registered contact.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            ref
                                .read(securityProvider.notifier)
                                .request2FAOTP()
                                .then((_) {
                              if (!context.mounted) return;
                              Navigator.pop(context); // Close bottom sheet
                              Navigator.pushNamed(
                                context,
                                AppRoutes.twoFactorSetupOtp,
                              ); // Navigate to new OTP input screen
                            }).catchError((e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())));
                            });
                          },
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.primaryBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: state.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text("Send Code",
                            style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel",
                        style: GoogleFonts.outfit(
                            color: Colors.grey[600], fontSize: 16)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          });
        });
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(title,
        style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.grey[800]));
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool)? onChanged,
    required IconData icon,
    String? statusText,
    Color? statusColor,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withOpacity(0.02), blurRadius: 5),
              ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.primaryBlue.withOpacity(0.2)
                  : Colors.blue[50],
              shape: BoxShape.circle),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title,
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle,
                style: GoogleFonts.outfit(
                    color: isDark ? Colors.grey[400] : Colors.grey,
                    fontSize: 13)),
            if (statusText != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor ?? Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    statusText,
                    style: GoogleFonts.outfit(
                      color: statusColor ?? Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppTheme.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02), blurRadius: 5),
              ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.primaryBlue.withValues(alpha: 0.2)
                  : Colors.blue[50],
              shape: BoxShape.circle),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title,
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black)),
        subtitle: Text(subtitle,
            style: GoogleFonts.outfit(
                color: isDark ? Colors.grey[400] : Colors.grey, fontSize: 13)),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            size: 16, color: isDark ? Colors.grey[600] : Colors.grey),
      ),
    );
  }

  Widget _buildDeviceTile(dynamic device) {
    // Assuming device object structure
    final name = device['name'] ?? 'Unknown Device';
    final lastActive = device['last_active'] ?? 'Unknown';
    final id = device['id'].toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.phone_android),
        title: Text(name),
        subtitle: Text("Last active: $lastActive"),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            ref.read(securityProvider.notifier).revokeDevice(id);
          },
        ),
      ),
    );
  }
}
