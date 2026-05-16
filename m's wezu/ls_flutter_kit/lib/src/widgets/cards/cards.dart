import 'package:flutter/material.dart';

/// Spring-animated card that bounces on tap.
class BouncyCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const BouncyCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(16), this.borderRadius = 16});

  @override
  State<BouncyCard> createState() => _BouncyCardState();
}

class _BouncyCardState extends State<BouncyCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween(begin: 1.0, end: 0.97).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap?.call(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.borderRadius)),
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );
  }
}

/// Dashboard KPI / metric card with value, label, delta, and optional sparkline.
class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? delta;
  final bool deltaPositive;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final Widget? sparkline;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.deltaPositive = true,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.sparkline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BouncyCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (iconColor ?? theme.colorScheme.primary).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: iconColor ?? theme.colorScheme.primary),
                ),
              if (icon != null) const SizedBox(width: 12),
              Expanded(child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline))),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
          if (delta != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  deltaPositive ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: deltaPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
                const SizedBox(width: 4),
                Text(
                  delta!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: deltaPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          if (sparkline != null) ...[const SizedBox(height: 12), SizedBox(height: 40, child: sparkline!)],
        ],
      ),
    );
  }
}

/// Simple info card with icon, title, and subtitle.
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final VoidCallback? onTap;

  const InfoCard({super.key, required this.icon, required this.title, required this.subtitle, this.iconColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BouncyCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (iconColor ?? theme.colorScheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor ?? theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: theme.colorScheme.outline),
        ],
      ),
    );
  }
}

/// Product card with image, name, and price.
class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String price;
  final String? originalPrice;
  final double? rating;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.price,
    this.originalPrice,
    this.rating,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BouncyCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.image, size: 48, color: theme.colorScheme.outline))),
                ),
              ),
              if (onFavorite != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                      child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 18, color: isFavorite ? Colors.red : Colors.grey),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(price, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    if (originalPrice != null) ...[
                      const SizedBox(width: 6),
                      Text(originalPrice!, style: theme.textTheme.bodySmall?.copyWith(decoration: TextDecoration.lineThrough, color: theme.colorScheme.outline)),
                    ],
                  ],
                ),
                if (rating != null) ...[
                  const SizedBox(height: 4),
                  Row(children: [const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)), const SizedBox(width: 2), Text(rating!.toStringAsFixed(1), style: theme.textTheme.bodySmall)]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
