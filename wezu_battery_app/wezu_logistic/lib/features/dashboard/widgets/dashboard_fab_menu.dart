import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../utils/app_haptics.dart';
import '../../../../config/app_text_styles.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/scroll_morph_fab.dart';

class DashboardFloatingActionMenu extends StatefulWidget {
  const DashboardFloatingActionMenu({
    super.key,
    this.collapseProgress = 0,
    required this.onReceiveStock,
    required this.onDispatchStock,
    required this.onViewInventory,
    required this.onGenerateReport,
    required this.onScanQR,
  });

  final double collapseProgress;
  final VoidCallback onReceiveStock;
  final VoidCallback onDispatchStock;
  final VoidCallback onViewInventory;
  final VoidCallback onGenerateReport;
  final VoidCallback onScanQR;

  @override
  State<DashboardFloatingActionMenu> createState() =>
      _DashboardFloatingActionMenuState();
}

class _DashboardFloatingActionMenuState
    extends State<DashboardFloatingActionMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;

  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    AppHaptics.impact();
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isOpen) ...[
          _buildAction(
            label: 'Scan QR Code',
            icon: Icons.qr_code_scanner_rounded,
            color: AppColors.info,
            onTap: widget.onScanQR,
            index: 4,
          ),
          const SizedBox(height: 16),
          _buildAction(
            label: 'Generate Report',
            icon: Icons.assessment_rounded,
            color: isDark
                ? theme.colorScheme.onSurface
                : AppColors.textSecondary,
            onTap: widget.onGenerateReport,
            index: 3,
          ),
          const SizedBox(height: 16),
          _buildAction(
            label: 'View Inventory',
            icon: Icons.inventory_2_rounded,
            color: isDark
                ? theme.colorScheme.onSurface
                : AppColors.textSecondary,
            onTap: widget.onViewInventory,
            index: 2,
          ),
          const SizedBox(height: 16),
          _buildAction(
            label: 'Dispatch Stock',
            icon: Icons.upload_rounded,
            color: AppColors.warning,
            onTap: widget.onDispatchStock,
            index: 1,
          ),
          const SizedBox(height: 16),
          _buildAction(
            label: 'Receive Stock',
            icon: Icons.download_rounded,
            color: AppColors.primary,
            onTap: widget.onReceiveStock,
            index: 0,
          ),
          const SizedBox(height: 16),
        ],
        ScrollMorphFab(
          progress: _isOpen
              ? 1
              : widget.collapseProgress.clamp(0.0, 1.0).toDouble(),
          onPressed: _toggle,
          backgroundColor: _isOpen
              ? theme.colorScheme.surfaceContainerHigh
              : theme.colorScheme.primaryContainer,
          foregroundColor: _isOpen
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onPrimaryContainer,
          icon: RotationTransition(
            turns: _rotateAnimation.drive(Tween(begin: 0.0, end: 0.125)),
            child: Icon(
              _isOpen ? Icons.add : Icons.grid_view_rounded,
              size: 28,
            ),
          ),
          label: 'Actions',
        ),
      ],
    );
  }

  Widget _buildAction({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required int index,
  }) {
    final theme = Theme.of(context);

    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.0,
          1.0 - index * 0.1 / 2.0, // Staggered slightly
          curve: Curves.easeOut,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            borderRadius: BorderRadius.circular(8),
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.small(
            onPressed: () {
              AppHaptics.selection();
              _toggle();
              onTap();
            },
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20),
          ),
        ],
      ),
    );
  }
}
