import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'settings_theme.dart';
import 'settings_common_widgets.dart';

import '../models/settings_extra_models.dart';
import 'package:intl/intl.dart';

class SecuritySection extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final Map<String, String> initialValues;
  final Map<String, bool> toggles;
  final Function(String, bool) onToggle;
  final VoidCallback onForceLogout;
  final SessionsState sessionsState;
  final Function(int) onRevokeSession;
  final VoidCallback onToggleSort;
  final VoidCallback onRefresh;

  const SecuritySection({
    super.key,
    required this.controllers,
    required this.initialValues,
    required this.toggles,
    required this.onToggle,
    required this.onForceLogout,
    required this.sessionsState,
    required this.onRevokeSession,
    required this.onToggleSort,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── CHANGE PASSWORD ──────────────────────────────────────────
        SettingsCard(
          title: 'Change Password',
          accentColor: SettingsTheme.primaryGreen,
          dataStatus: 'Real-time Data',
          children: [
            SettingsFieldRow(
              label: 'Current Password',
              controller: controllers['current_password'],
              isModified: controllers['current_password']?.text != initialValues['current_password'],
              obscureText: true,
              placeholder: 'Enter current password',
            ),
            SettingsFieldRow(
              label: 'New Password',
              controller: controllers['new_password'],
              isModified: controllers['new_password']?.text != initialValues['new_password'],
              obscureText: true,
              placeholder: 'Enter new password',
            ),
            ValueListenableBuilder(
              valueListenable: controllers['new_password']!,
              builder: (context, value, child) {
                return PasswordStrengthIndicator(password: value.text);
              },
            ),
            SettingsFieldRow(
              label: 'Confirm New Password',
              controller: controllers['confirm_password'],
              isModified: controllers['confirm_password']?.text != initialValues['confirm_password'],
              obscureText: true,
              placeholder: 'Re-type new password',
            ),
          ],
        ),
        const SizedBox(height: 32),

        // ── TWO-FACTOR AUTHENTICATION ────────────────────────────────
        SettingsCard(
          title: 'Two-Factor Authentication',
          accentColor: SettingsTheme.primaryCyan,
          dataStatus: 'Pending Configuration',
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Secure your account with 2FA', style: SettingsTheme.body),
                      const SizedBox(height: 4),
                      Text(
                        'Add an extra layer of security to your account by requiring a code from your phone.',
                        style: SettingsTheme.subline,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: toggles['2fa_enabled'] ?? false,
                  onChanged: (val) => onToggle('2fa_enabled', val),
                  activeThumbColor: SettingsTheme.primaryCyan,
                ),
              ],
            ),
            if (toggles['2fa_enabled'] == true) ...[
              const SizedBox(height: 24),
              const Divider(color: SettingsTheme.borderSubtle),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: SettingsTheme.primaryCyan.withValues(alpha: 0.2),
                          blurRadius: 20,
                        )
                      ],
                    ),
                    // In a real app, this would be a dynamic QR widget.
                    // Using the generated image path here.
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/two_fa_qr_placeholder.png', // Temporary placeholder for UI
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(LucideIcons.qrCode, size: 60, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Scan this QR code', style: SettingsTheme.h3),
                        const SizedBox(height: 8),
                        Text(
                          'Scan this code with your authenticator app (Google Authenticator, Authy, etc.)',
                          style: SettingsTheme.subline,
                        ),
                        const SizedBox(height: 16),
                        Text('Or enter manually', style: SettingsTheme.h3),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: SettingsTheme.backgroundDark,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: SettingsTheme.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              Text('JBSWY3DPEHPK3PXP', style: SettingsTheme.mono),
                              const Spacer(),
                              const Icon(LucideIcons.copy, size: 14, color: SettingsTheme.mutedGray),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {}, // Mock download action
                icon: const Icon(LucideIcons.download, size: 16),
                label: const Text('Download Backup Codes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SettingsTheme.surfaceDark,
                  foregroundColor: SettingsTheme.textHigh,
                  side: const BorderSide(color: SettingsTheme.borderSubtle),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 32),

        // ── ACTIVE SESSIONS ─────────────────────────────────────────
        SettingsCard(
          title: 'Active Sessions',
          accentColor: SettingsTheme.primaryCyan,
          dataStatus: 'Real-time Data',
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 500;
                
                Widget buildSortButton({bool isMobile = false}) => TextButton.icon(
                  onPressed: onToggleSort,
                  icon: Icon(
                    sessionsState.isAscending ? LucideIcons.arrowUpAZ : LucideIcons.arrowDownAZ,
                    size: isMobile ? 14 : 16,
                    color: SettingsTheme.primaryCyan,
                  ),
                  label: Text(
                    sessionsState.isAscending ? 'Oldest First' : 'Newest First',
                    style: SettingsTheme.subline.copyWith(
                      color: SettingsTheme.primaryCyan, 
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 11 : 12,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 12, vertical: isMobile ? 6 : 8),
                    backgroundColor: SettingsTheme.primaryCyan.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );

                Widget buildRefreshButton({bool isMobile = false}) => IconButton(
                  onPressed: onRefresh,
                  tooltip: 'Refresh Sessions',
                  icon: Icon(
                    LucideIcons.rotateCcw,
                    size: isMobile ? 14 : 16,
                    color: SettingsTheme.primaryCyan,
                  ),
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.all(isMobile ? 6 : 8),
                    backgroundColor: SettingsTheme.primaryCyan.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage your active login sessions across devices.',
                        style: SettingsTheme.subline,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildSortButton(isMobile: true),
                          buildRefreshButton(isMobile: true),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Manage your active login sessions across devices. You can terminate individual sessions if you don\'t recognize them.',
                        style: SettingsTheme.subline,
                      ),
                    ),
                    const SizedBox(width: 16),
                    buildSortButton(),
                    const SizedBox(width: 8),
                    buildRefreshButton(),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Text('LOGGED IN DEVICES', style: SettingsTheme.subline.copyWith(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(width: 8),
                Expanded(child: Divider(color: SettingsTheme.borderSubtle.withValues(alpha: 0.5))),
              ],
            ),
            const SizedBox(height: 16),
            if (sessionsState.isLoading && sessionsState.sessions.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: SettingsTheme.primaryCyan,
                  minHeight: 2,
                ),
              ),
            if (sessionsState.isLoading && sessionsState.sessions.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(color: SettingsTheme.primaryCyan, strokeWidth: 2),
              ))
            else if (sessionsState.error != null && sessionsState.sessions.isEmpty)
              Column(
                children: [
                   ErrorPanel(message: sessionsState.error!),
                   const SizedBox(height: 16),
                   ElevatedButton.icon(
                     onPressed: onRefresh,
                     icon: const Icon(LucideIcons.refreshCw, size: 16),
                     label: const Text('Retry Loading Sessions'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: SettingsTheme.surfaceDark,
                       foregroundColor: SettingsTheme.primaryCyan,
                       side: const BorderSide(color: SettingsTheme.primaryCyan),
                     ),
                   ),
                ],
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sessionsState.sessions.length,
                separatorBuilder: (context, index) => const Divider(color: SettingsTheme.borderSubtle, height: 32),
                itemBuilder: (context, index) {
                  final session = sessionsState.sessions[index];
                  return SessionListItem(
                    session: session,
                    onRevoke: () => onRevokeSession(session.id),
                    revokingSessionId: sessionsState.revokingSessionId,
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 32),

        // ── SESSION MANAGEMENT ───────────────────────────────────────
        SettingsCard(
          title: 'Session Management',
          accentColor: SettingsTheme.secondaryAmber,
          dataStatus: 'Pending Configuration',
          children: [
            SettingsDropdown(
              label: 'Session Timeout',
              value: initialValues['session_timeout'] ?? '4 hrs',
              items: const ['30 min', '1 hr', '4 hrs', '24 hrs', 'Never'],
              onChanged: (val) {}, // Mock change
              isModified: false,
            ),
            const SizedBox(height: 16),
            const Divider(color: SettingsTheme.borderSubtle),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Global Logout', style: SettingsTheme.h3.copyWith(color: SettingsTheme.errorRed)),
                      const SizedBox(height: 4),
                      Text(
                        'Forcefully logout all active sessions across all devices.',
                        style: SettingsTheme.subline,
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: onForceLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SettingsTheme.errorRed.withValues(alpha: 0.1),
                    foregroundColor: SettingsTheme.errorRed,
                    side: const BorderSide(color: SettingsTheme.errorRed, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Force Logout All', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class SessionListItem extends StatelessWidget {
  final SessionDto session;
  final VoidCallback onRevoke;
  final int? revokingSessionId;

  const SessionListItem({
    super.key,
    required this.session,
    required this.onRevoke,
    required this.revokingSessionId,
  });

  IconData _getDeviceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'mobile':
      case 'phone':
      case 'smartphone':
        return LucideIcons.smartphone;
      case 'tablet':
        return LucideIcons.tablet;
      case 'desktop':
      case 'laptop':
        return LucideIcons.laptop;
      default:
        return LucideIcons.monitor;
    }
  }

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now().toUtc();
    final difference = now.difference(dateTime.toUtc());

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (session.isCurrent ? SettingsTheme.primaryCyan : SettingsTheme.mutedGray).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getDeviceIcon(session.deviceType),
                color: session.isCurrent ? SettingsTheme.primaryCyan : SettingsTheme.mutedGray,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          session.deviceName ?? 'Unknown Device',
                          style: SettingsTheme.body.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (session.isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: SettingsTheme.primaryCyan.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: SettingsTheme.primaryCyan.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'THIS DEVICE',
                            style: SettingsTheme.subline.copyWith(
                              color: SettingsTheme.primaryCyan,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _SessionInfoBadge(label: session.ipAddress ?? 'Unknown IP'),
                      if (session.location != null) _SessionInfoBadge(label: session.location!),
                      _SessionInfoBadge(label: 'Active: ${_getRelativeTime(session.lastActiveAt)}'),
                    ],
                  ),
                ],
              ),
            ),
            if (!session.isCurrent)
              IconButton(
                onPressed: (revokingSessionId != null) ? null : onRevoke,
                icon: (revokingSessionId == session.id || revokingSessionId == -1)
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: SettingsTheme.errorRed),
                      )
                    : const Icon(LucideIcons.x, color: SettingsTheme.errorRed, size: 20),
                tooltip: 'Terminate Session',
              ),
          ],
        );
      },
    );
  }
}

class _SessionInfoBadge extends StatelessWidget {
  final String label;
  const _SessionInfoBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: SettingsTheme.subline.copyWith(fontSize: 11),
    );
  }
}
