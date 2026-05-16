import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../models/station_state.dart';

// ══════════════════════════════════════════════════════════
// SWAP PORT MODALS — Interactive dialogs for port actions
// ══════════════════════════════════════════════════════════

class SwapPortModals {
  // ── Active Swap Detail Modal ────────────────────────────
  static void showActiveSwapModal(BuildContext context, SwapPortDto port, String stationName, {VoidCallback? onComplete}) {
    final elapsed = port.swapStartedAt != null
        ? DateTime.now().difference(DateTime.parse(port.swapStartedAt!).toLocal())
        : Duration.zero;

    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.refreshCw, color: AppColors.amber, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Active Swap — Port #${port.portNumber}', style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
              )),
              Text(stationName, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
            ])),
            IconButton(
              icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
              onPressed: () => Navigator.pop(ctx),
            ),
          ]),
          const SizedBox(height: 24),

          // Info rows
          _infoRow('Customer', port.customerName ?? 'Unknown', LucideIcons.user),
          _infoRow('Customer ID', port.customerId ?? '—', LucideIcons.hash),
          const SizedBox(height: 8),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          _infoRow('Old Battery (In)', port.batteryCode ?? '—', LucideIcons.batteryLow),
          _infoRow('New Battery (Out)', port.newBatteryCode ?? '—', LucideIcons.batteryFull),
          const SizedBox(height: 8),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          _infoRow('Swap Started', port.swapStartedAt != null
              ? _formatTime(DateTime.parse(port.swapStartedAt!).toLocal())
              : '—', LucideIcons.clock),
          _infoRow('Duration', '${elapsed.inMinutes}m ${elapsed.inSeconds % 60}s', LucideIcons.timer),

          const SizedBox(height: 24),

          // Pulsing status indicator
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.amber.withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(
                color: AppColors.amber, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.amber.withValues(alpha: 0.5), blurRadius: 6)],
              )),
              const SizedBox(width: 10),
              const Expanded(child: Text('Swap in progress — awaiting battery exchange completion',
                style: TextStyle(fontSize: 12, color: AppColors.amber),
              )),
            ]),
          ),

          const SizedBox(height: 20),

          // Action button
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            icon: const Icon(LucideIcons.checkCircle, size: 16),
            label: const Text('Mark Swap Complete'),
            onPressed: () {
              onComplete?.call();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          )),
        ]),
      ),
    ));
  }

  // ── Fault Port Detail Modal ────────────────────────────
  static void showFaultModal(BuildContext context, SwapPortDto port, String stationName, {
    VoidCallback? onMarkFixed,
    VoidCallback? onScheduleMaintenance,
  }) {
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.alertTriangle, color: AppColors.red, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Fault — Port #${port.portNumber}', style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.red,
              )),
              Text(stationName, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
            ])),
            IconButton(
              icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
              onPressed: () => Navigator.pop(ctx),
            ),
          ]),
          const SizedBox(height: 24),

          // Fault details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.red.withValues(alpha: 0.15)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(LucideIcons.alertCircle, size: 14, color: AppColors.red),
                const SizedBox(width: 8),
                Text(port.faultCode ?? 'UNKNOWN ERROR', style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.red, letterSpacing: 0.5,
                )),
              ]),
              const SizedBox(height: 8),
              Text('Battery health: ${port.healthPercentage.toStringAsFixed(0)}%', style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary,
              )),
              if (port.batteryCode != null)
                Text('Battery: ${port.batteryCode}', style: const TextStyle(
                  fontSize: 12, color: AppColors.textTertiary,
                )),
            ]),
          ),
          const SizedBox(height: 20),

          _infoRow('Fault Type', port.faultCode ?? 'Unknown', LucideIcons.alertTriangle),
          _infoRow('Health', '${port.healthPercentage.toStringAsFixed(0)}%', LucideIcons.heartPulse),
          _infoRow('Port', '#${port.portNumber}', LucideIcons.hash),

          const SizedBox(height: 24),

          // Action buttons
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              icon: const Icon(LucideIcons.wrench, size: 14),
              label: const Text('Schedule Maintenance', style: TextStyle(fontSize: 12)),
              onPressed: () {
                onScheduleMaintenance?.call();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Maintenance request logged'),
                  backgroundColor: AppColors.amber,
                ));
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.amber,
                side: const BorderSide(color: AppColors.amber),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton.icon(
              icon: const Icon(LucideIcons.checkCircle, size: 14),
              label: const Text('Mark as Fixed', style: TextStyle(fontSize: 12)),
              onPressed: () {
                onMarkFixed?.call();
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )),
          ]),
        ]),
      ),
    ));
  }

  // ── Ready Port Actions Modal ────────────────────────────
  static void showReadyPortModal(BuildContext context, SwapPortDto port, String stationName, {
    VoidCallback? onMarkOffline,
    Function(String minutes)? onReserve,
  }) {
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.batteryFull, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Port #${port.portNumber} — Ready', style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary,
              )),
              Text(stationName, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
            ])),
            IconButton(
              icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
              onPressed: () => Navigator.pop(ctx),
            ),
          ]),
          const SizedBox(height: 20),

          if (port.lastUsedAt != null)
            _infoRow('Last Used', _timeAgo(DateTime.parse(port.lastUsedAt!).toLocal()), LucideIcons.clock),

          const SizedBox(height: 20),

          // Reserve button
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            icon: const Icon(LucideIcons.lock, size: 14),
            label: const Text('Reserve for 15 minutes'),
            onPressed: () {
              onReserve?.call('15');
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Port reserved for 15 minutes'),
                backgroundColor: AppColors.purple,
              ));
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.purple,
              side: const BorderSide(color: AppColors.purple),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          )),
          const SizedBox(height: 10),

          // Offline button
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            icon: const Icon(LucideIcons.powerOff, size: 14),
            label: const Text('Mark as Offline'),
            onPressed: () {
              onMarkOffline?.call();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Port marked as offline'),
                backgroundColor: AppColors.textMuted,
              ));
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textMuted,
              side: const BorderSide(color: AppColors.textMuted),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          )),
        ]),
      ),
    ));
  }

  // ── Helpers ───────────────────────────────────────────────
  static Widget _infoRow(String label, String value, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Icon(icon, size: 14, color: AppColors.textTertiary),
      const SizedBox(width: 10),
      SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
    ]),
  );

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
