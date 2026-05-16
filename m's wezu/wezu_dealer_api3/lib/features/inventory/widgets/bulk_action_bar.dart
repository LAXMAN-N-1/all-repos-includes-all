import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';

/// Zone 6 — Bulk Action Bar
/// Slides up from the bottom when 2+ table checkboxes are selected.
class BulkActionBar extends StatefulWidget {
  final int selectedCount;
  final VoidCallback onDeselectAll;
  final VoidCallback onMoveMaintenance;
  final VoidCallback onReassignStation;
  final VoidCallback onFirmwareUpdate;

  const BulkActionBar({
    super.key,
    required this.selectedCount,
    required this.onDeselectAll,
    required this.onMoveMaintenance,
    required this.onReassignStation,
    required this.onFirmwareUpdate,
  });

  @override
  State<BulkActionBar> createState() => _BulkActionBarState();
}

class _BulkActionBarState extends State<BulkActionBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void didUpdateWidget(BulkActionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCount >= 2 && oldWidget.selectedCount < 2) {
      _slideController.forward();
    } else if (widget.selectedCount < 2 && oldWidget.selectedCount >= 2) {
      _slideController.reverse();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Selected count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${widget.selectedCount} selected',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: widget.onDeselectAll,
              child: const Text(
                'Deselect All',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const Spacer(),

            // Action buttons
            _BulkBtn(
              icon: LucideIcons.wrench,
              label: 'Move to Maintenance',
              color: AppColors.amber,
              onTap: widget.onMoveMaintenance,
            ),
            const SizedBox(width: 8),
            _BulkBtn(
              icon: LucideIcons.mapPin,
              label: 'Reassign Station',
              color: const Color(0xFF1A73E8),
              onTap: widget.onReassignStation,
            ),
            const SizedBox(width: 8),
            _BulkBtn(
              icon: LucideIcons.uploadCloud,
              label: 'Firmware Update',
              color: AppColors.purple,
              onTap: widget.onFirmwareUpdate,
            ),
          ],
        ),
      ),
    );
  }
}

class _BulkBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BulkBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_BulkBtn> createState() => _BulkBtnState();
}

class _BulkBtnState extends State<_BulkBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.color.withValues(alpha: 0.15)
                : widget.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: widget.color),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
