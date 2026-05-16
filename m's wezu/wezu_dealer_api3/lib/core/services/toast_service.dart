import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/colors.dart';

enum ToastType { success, error, warning, info }

class ToastService {
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    Color borderColor;
    IconData icon;
    Color iconColor;

    switch (type) {
      case ToastType.success:
        borderColor = AppColors.primary;
        icon = LucideIcons.checkCircle2;
        iconColor = AppColors.primary;
        break;
      case ToastType.error:
        borderColor = AppColors.red;
        icon = LucideIcons.xCircle;
        iconColor = AppColors.red;
        break;
      case ToastType.warning:
        borderColor = AppColors.amber;
        icon = LucideIcons.alertTriangle;
        iconColor = AppColors.amber;
        break;
      case ToastType.info:
        borderColor = AppColors.cyan;
        icon = LucideIcons.info;
        iconColor = AppColors.cyan;
        break;
    }

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        borderColor: borderColor,
        icon: icon,
        iconColor: iconColor,
        actionLabel: actionLabel ?? '',
        onAction: onAction != null
            ? () {
                onAction();
                entry.remove();
              }
            : null,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }
}

class _ToastWidget extends StatefulWidget {
  final String message, actionLabel;
  final Color borderColor, iconColor;
  final IconData icon;
  final VoidCallback? onAction, onDismiss;

  const _ToastWidget({
    required this.message,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    this.actionLabel = '',
    this.onAction,
    this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slide = Tween<double>(
      begin: 100,
      end: 0,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slide.value),
              child: Opacity(
                opacity: _c.value,
                child: Container(
                  width: 380,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(color: widget.borderColor, width: 4),
                      top: const BorderSide(color: AppColors.border),
                      right: const BorderSide(color: AppColors.border),
                      bottom: const BorderSide(color: AppColors.border),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(widget.icon, color: widget.iconColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (widget.onAction != null &&
                          widget.actionLabel.isNotEmpty)
                        TextButton(
                          onPressed: widget.onAction,
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            widget.actionLabel,
                            style: TextStyle(
                              color: widget.borderColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      Opacity(
                        opacity: 0.5,
                        child: IconButton(
                          icon: const Icon(LucideIcons.x, size: 16),
                          onPressed: () {
                            _c.reverse().then((_) => widget.onDismiss?.call());
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
