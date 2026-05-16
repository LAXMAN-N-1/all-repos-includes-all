import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer-based skeleton placeholder for loading states.
///
/// ```dart
/// SkeletonLoader(width: 200, height: 20)
/// SkeletonLoader.circle(size: 48)
/// ```
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
  });

  const SkeletonLoader.circle({super.key, double size = 48})
      : width = size,
        height = size,
        borderRadius = 0,
        shape = BoxShape.circle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
          shape: shape,
        ),
      ),
    );
  }
}

/// Pre-composed card skeleton for content loading.
class SkeletonCard extends StatelessWidget {
  final double? height;
  const SkeletonCard({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonLoader(height: 16, width: 160),
            const SizedBox(height: 12),
            const SkeletonLoader(height: 12),
            const SizedBox(height: 8),
            SkeletonLoader(height: 12, width: MediaQuery.of(context).size.width * 0.6),
            const SizedBox(height: 16),
            Row(
              children: [
                const SkeletonLoader.circle(size: 36),
                const SizedBox(width: 12),
                Expanded(child: SkeletonLoader(height: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Generates a list of skeleton loaders.
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int)? itemBuilder;
  final double spacing;
  final EdgeInsetsGeometry padding;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemBuilder,
    this.spacing = 12,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: spacing),
      itemBuilder: itemBuilder ?? (ctx, _) => const SkeletonCard(),
    );
  }
}

/// "No data" empty state with optional illustration.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
            ],
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

/// "Something went wrong" error state with retry button.
class ErrorState extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message!, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Animated toast notification.
class AdvancedToast {
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    ToastType type = ToastType.info,
  }) {
    final overlay = Overlay.of(context);
    final colors = _toastColors(type);
    final entry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        icon: icon ?? colors.icon,
        backgroundColor: backgroundColor ?? colors.bg,
        foregroundColor: colors.fg,
      ),
    );
    overlay.insert(entry);
    Future.delayed(duration, () => entry.remove());
  }

  static _ToastColors _toastColors(ToastType type) {
    switch (type) {
      case ToastType.success:
        return _ToastColors(const Color(0xFF10B981), Colors.white, Icons.check_circle);
      case ToastType.error:
        return _ToastColors(const Color(0xFFEF4444), Colors.white, Icons.error);
      case ToastType.warning:
        return _ToastColors(const Color(0xFFF59E0B), Colors.white, Icons.warning);
      case ToastType.info:
        return _ToastColors(const Color(0xFF3B82F6), Colors.white, Icons.info);
    }
  }
}

enum ToastType { success, error, warning, info }

class _ToastColors {
  final Color bg;
  final Color fg;
  final IconData icon;
  _ToastColors(this.bg, this.fg, this.icon);
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  const _ToastWidget({
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slide = Tween(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _opacity = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).viewPadding.top + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _opacity,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Icon(widget.icon, color: widget.foregroundColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(widget.message, style: TextStyle(color: widget.foregroundColor, fontWeight: FontWeight.w500, fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
